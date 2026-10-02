import Contacts

@available(iOS 9.0, *)
struct Event {
    var year: Int?
    var month: Int
    var day: Int
    var leapMonth: Bool = false
    // one of: anniversary, birthday, other, custom
    var label: String = "birthday"
    var customLabel: String = ""

    init(fromMap m: [String: Any?]) {
        year = m["year"] as? Int
        month = m["month"] as! Int
        day = m["day"] as! Int
        label = m["label"] as! String
        customLabel = m["customLabel"] as! String
        leapMonth = m["leapMonth"] as! Bool
    }

    init(fromContact c: CNContact) {
        // It seems like NSDateComponents use 2^64-1 as a value for year when there is
        // no year. This should cover similar edge cases.
        let y = c.birthday!.year
        year = (y == nil || y! < -100_000 || y! > 100_000) ? nil : y
        year = c.birthday!.year
        month = c.birthday!.month ?? 1
        day = c.birthday!.day ?? 1
        label = "birthday"
    }

    init(fromLunar c: CNContact) {
        // It seems like NSDateComponents use 2^64-1 as a value for year when there is
        // no year. This should cover similar edge cases.
        let lunar = c.nonGregorianBirthday!

        let y = lunar.year
        year = (y == nil || y! < -100000 || y! > 100000) ? nil : y
        // year = c.birthday!.year
        month = lunar.month ?? 1
        day = lunar.day ?? 1
        
        leapMonth = lunar.isLeapMonth ?? false
        
        label = "birthday_lunar"
        customLabel = calendarIdentifierString(lunar.calendar)
    }

    init(fromDate d: CNLabeledValue<NSDateComponents>) {
        // It seems like NSDateComponents use 2^64-1 as a value for year when there is
        // no year. This should cover similar edge cases.
        let y = d.value.year
        year = (y < -100_000 || y > 100_000) ? nil : y
        month = d.value.month
        day = d.value.day
        switch d.label {
        case CNLabelDateAnniversary:
            label = "anniversary"
        case CNLabelOther:
            label = "other"
        default:
            label = "custom"
            customLabel = d.label ?? ""
        }
    }

    func toMap() -> [String: Any?] { [
        "year": year,
        "month": month,
        "day": day,
        "label": label,
        "customLabel": customLabel,
        "leapMonth": leapMonth,
    ]
    }

    func addTo(_ c: CNMutableContact) {
        var dateComponents: DateComponents
        if year == nil {
            dateComponents = DateComponents(month: month, day: day)
        } else {
            dateComponents = DateComponents(year: year, month: month, day: day)
        }

        if label == "birthday_lunar" {
            if let calendar = calendarFromIdentifierString(customLabel) {
              dateComponents.calendar = calendar
              dateComponents.isLeapMonth = leapMonth
            }
            c.nonGregorianBirthday = dateComponents
        } else if label == "birthday" {
            c.birthday = dateComponents
        } else {
            var labelInv: String
            switch label {
            case "anniversary":
                labelInv = CNLabelDateAnniversary
            case "other":
                labelInv = CNLabelOther
            case "custom":
                labelInv = customLabel
            default:
                labelInv = label
            }
            c.dates.append(
                CNLabeledValue(
                    label: labelInv,
                    value: dateComponents as NSDateComponents
                )
            )
        }
    }

    // Calendar.Identifier.debugDescription 在 iOS 15/16 的 Foundation 中不存在，
    // 部署目标 15+ 启动时绑定会导致 dyld 直接终止，这里统一走 NSCalendar。
    // 输出 CLDR 标识（与 iOS 17+ 的 debugDescription 一致），仅 NSCalendar 的
    // ethiopic-amete-alem 需归一化为 ethioaa。
    func calendarIdentifierString(_ calendar: Calendar?) -> String {
        guard let calendar = calendar else { return "" }
        let identifier = (calendar as NSCalendar).calendarIdentifier.rawValue
        return identifier == "ethiopic-amete-alem" ? "ethioaa" : identifier
    }

    // NSCalendar 不识别 ethioaa 及旧版写入的 Swift case 名，先映射再构造。
    func calendarFromIdentifierString(_ string: String) -> Calendar? {
        let aliases = [
            "ethioaa": "ethiopic-amete-alem",
            "ethiopicAmeteMihret": "ethiopic",
            "ethiopicAmeteAlem": "ethiopic-amete-alem",
            "islamicCivil": "islamic-civil",
            "islamicTabular": "islamic-tbla",
            "islamicUmmAlQura": "islamic-umalqura",
            "republicOfChina": "roc",
        ]
        let identifier = aliases[string] ?? string
        guard !identifier.isEmpty,
              let calendar = NSCalendar(identifier: NSCalendar.Identifier(rawValue: identifier))
        else { return nil }
        return calendar as Calendar
    }
}
