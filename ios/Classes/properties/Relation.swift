import Contacts

@available(iOS 9.0, *)
struct Relation {
    var name: String
    var label: String = "other"    // flutter_contacts 用的自定义 label
    var customLabel: String = ""

    // -------- LABEL MAPPING --------
    // Flutter → iOS
    static let labelToCNLabel: [String: String] = [
        // base relations (common)
        "assistant": CNLabelContactRelationAssistant,
        "manager": CNLabelContactRelationManager,
        "father": CNLabelContactRelationFather,
        "mother": CNLabelContactRelationMother,
        "parent": CNLabelContactRelationParent,
        "child": CNLabelContactRelationChild,
        "daughter": {
            if #available(iOS 11.0, *) { return CNLabelContactRelationDaughter }
            return CNLabelOther
        }(),
        "son": {
            if #available(iOS 11.0, *) { return CNLabelContactRelationSon }
            return CNLabelOther
        }(),
        "friend": CNLabelContactRelationFriend,
        "spouse": CNLabelContactRelationSpouse,
        "partner": CNLabelContactRelationPartner,
        "other": CNLabelOther,

        // ——— iOS 13+ labels ———
        // sibling
        "colleague": avail(iOS13: CNLabelContactRelationColleague),
        "teacher":  avail(iOS13: CNLabelContactRelationTeacher),

        "sibling": avail(iOS13: CNLabelContactRelationSibling),
        "youngerSibling": avail(iOS13: CNLabelContactRelationYoungerSibling),
        "elderSibling": avail(iOS13: CNLabelContactRelationElderSibling),

        "sister": CNLabelContactRelationSister,
        "youngerSister": avail(iOS13: CNLabelContactRelationYoungerSister),
        "youngestSister": avail(iOS13: CNLabelContactRelationYoungestSister),
        "elderSister": avail(iOS13: CNLabelContactRelationElderSister),
        "eldestSister": avail(iOS13: CNLabelContactRelationEldestSister),

        "brother": CNLabelContactRelationBrother,
        "youngerBrother": avail(iOS13: CNLabelContactRelationYoungerBrother),
        "youngestBrother": avail(iOS13: CNLabelContactRelationYoungestBrother),
        "elderBrother": avail(iOS13: CNLabelContactRelationElderBrother),
        "eldestBrother": avail(iOS13: CNLabelContactRelationEldestBrother),

        // friend subtypes
        "maleFriend": avail(iOS13: CNLabelContactRelationMaleFriend),
        "femaleFriend": avail(iOS13: CNLabelContactRelationFemaleFriend),

        // spouse subtypes
        "wife": avail(iOS13: CNLabelContactRelationWife),
        "husband": avail(iOS13: CNLabelContactRelationHusband),

        // partner subtypes
        "malePartner": avail(iOS13: CNLabelContactRelationMalePartner),
        "femalePartner": avail(iOS13: CNLabelContactRelationFemalePartner),

        "girlfriendOrBoyfriend": avail(iOS13: CNLabelContactRelationGirlfriendOrBoyfriend),
        "girlfriend": avail(iOS13: CNLabelContactRelationGirlfriend),
        "boyfriend": avail(iOS13: CNLabelContactRelationBoyfriend),

        // --- (很多父系、祖系、姻亲等标签略，建议持续追加) ---
        // 你可以继续把所有 iOS 13+ 标签 append 到这个字典
    ]

    // iOS → Flutter
    static let cnLabelToLabel: [String: String] = {
        var map: [String: String] = [:]
        for (k, v) in labelToCNLabel {
            map[v] = k
        }
        return map
    }()


    // -------- INITIALIZERS --------
    init(fromMap m: [String: Any]) {
        name = m["name"] as! String
        label = m["label"] as! String
        customLabel = m["customLabel"] as! String
    }

    init(fromRelation r: CNLabeledValue<CNContactRelation>) {
        name = r.value.name

        if let mapped = Relation.cnLabelToLabel[r.label ?? ""] {
            label = mapped
        } else {
            label = "custom"
            customLabel = r.label ?? ""
        }
    }

    // -------- CONVERT TO MAP --------
    func toMap() -> [String: Any] {
        return [
            "name": name,
            "label": label,
            "customLabel": customLabel,
        ]
    }

    // -------- ADD TO CONTACT --------
    func addTo(_ c: CNMutableContact) {
        let relation = CNContactRelation(name: name)

        let labelInv: String
        if label == "custom" {
            labelInv = customLabel
        } else if let mapped = Relation.labelToCNLabel[label] {
            labelInv = mapped
        } else {
            labelInv = CNLabelOther
        }

        c.contactRelations.append(
            CNLabeledValue<CNContactRelation>(label: labelInv, value: relation)
        )
    }
}


// -------- SMALL HELPER --------
// return label only if iOS >= 13
@available(iOS 9.0, *)
func avail(iOS13 label: String) -> String {
    if #available(iOS 13.0, *) { return label }
    return CNLabelOther
}
