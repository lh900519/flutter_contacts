import 'package:flutter_contacts/vcard.dart';

/// Labeled relation (contact relationship).
class Relation {
  /// Relation name (e.g. "Father", "Assistant", "Friend").
  String name;

  /// Label (default [RelationLabel.other]).
  RelationLabel label;

  /// Custom label, if [label] is [RelationLabel.custom].
  String customLabel;

  Relation(
    this.name, {
    this.label = RelationLabel.other,
    this.customLabel = '',
  });

  factory Relation.fromJson(Map<String, dynamic> json) => Relation(
        (json['name'] as String?) ?? '',
        label: _stringToRelationLabel[json['label'] as String? ?? ''] ??
            RelationLabel.other,
        customLabel: (json['customLabel'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'label': _relationLabelToString[label],
        'customLabel': customLabel,
      };

  @override
  int get hashCode => name.hashCode ^ label.hashCode ^ customLabel.hashCode;

  @override
  bool operator ==(Object o) =>
      o is Relation &&
      o.name == name &&
      o.label == label &&
      o.customLabel == customLabel;

  @override
  String toString() =>
      'Relation(name=$name, label=$label, customLabel=$customLabel)';

  List<String> toVCard() {
    // X-ABRELATEDNAMES is used for relationships on iOS.
    // https://github.com/apple/contactsservice/blob/master/docs/vcard-format.md
    return [
      'X-ABRELATEDNAMES;TYPE=${vCardEncode(_relationLabelToString[label] ?? "")}:${vCardEncode(name)}',
    ];
  }
}

/// Relation labels.
///
/// 你可以继续在这里追加所有 iOS/Android 支持的标签：
/// father / mother / parent / child / friend / spouse / partner / manager / assistant …
///
/// | Label  | Android | iOS |
/// |--------|:-------:|:---:|
/// | father | ✔       | ✔   |
/// | mother | ✔       | ✔   |
/// | parent | ✔       | ✔   |
/// | child  | ✔       | ✔   |
/// | friend | ✔       | ✔   |
/// | spouse | ✔       | ✔   |
/// | partner| ✔       | ✔   |
/// | other  | ✔       | ✔   |
/// | custom | ✔       | ✔   |
enum RelationLabel {
  father,
  mother,
  parent,
  child,
  friend,
  spouse,
  partner,
  manager,
  assistant,
  other,
  custom,
}

/// Dart enum → string
final _relationLabelToString = {
  RelationLabel.father: 'father',
  RelationLabel.mother: 'mother',
  RelationLabel.parent: 'parent',
  RelationLabel.child: 'child',
  RelationLabel.friend: 'friend',
  RelationLabel.spouse: 'spouse',
  RelationLabel.partner: 'partner',
  RelationLabel.manager: 'manager',
  RelationLabel.assistant: 'assistant',
  RelationLabel.other: 'other',
  RelationLabel.custom: 'custom',
};

/// string → Dart enum
final _stringToRelationLabel = {
  'father': RelationLabel.father,
  'mother': RelationLabel.mother,
  'parent': RelationLabel.parent,
  'child': RelationLabel.child,
  'friend': RelationLabel.friend,
  'spouse': RelationLabel.spouse,
  'partner': RelationLabel.partner,
  'manager': RelationLabel.manager,
  'assistant': RelationLabel.assistant,
  'other': RelationLabel.other,
  'custom': RelationLabel.custom,
};
