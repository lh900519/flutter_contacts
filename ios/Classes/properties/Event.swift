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
        customLabel = (lunar.calendar?.identifier.debugDescription ?? "")
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
            if let identifier = stringToIdentifier(customLabel) {
              dateComponents.calendar = Calendar(identifier: identifier)
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

    // 从字符串转回 - 需要自己实现映射
    func stringToIdentifier(_ string: String) -> Calendar.Identifier? {
        switch string {
            case "gregorian": return .gregorian
            case "buddhist": return .buddhist
            case "chinese": return .chinese
            case "coptic": return .coptic
            case "ethiopicAmeteMihret": return .ethiopicAmeteMihret
            case "ethiopicAmeteAlem": return .ethiopicAmeteAlem
            case "hebrew": return .hebrew
            case "iso8601": return .iso8601
            case "indian": return .indian
            case "islamic": return .islamic
            case "islamicCivil": return .islamicCivil
            case "japanese": return .japanese
            case "persian": return .persian
            case "republicOfChina": return .republicOfChina
            default: return nil
        }
    }
}
