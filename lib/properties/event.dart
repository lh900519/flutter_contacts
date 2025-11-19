import 'package:flutter_contacts/config.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

/// Labeled event / birthday.
///
/// Android allows multiple birthdays per contact, while iOS supports only one.
class Event {
  /// Event year (can be null).
  int? year;

  /// Event month (1-12).
  int month;

  /// Event day (1-31).
  int day;

  /// Label (default [EventLabel.birthday]).
  EventLabel label;

  /// Custom label, if [label] is [EventLabel.custom].
  String customLabel;

  bool leapMonth;

  Event({
    this.year,
    required this.month,
    required this.day,
    this.label = EventLabel.birthday,
    this.customLabel = '',
    this.leapMonth = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        year: json['year'] as int?,
        month: json['month'] as int,
        day: json['day'] as int,
        label: _stringToEventLabel[json['label'] as String? ?? ''] ??
            EventLabel.birthday,
        customLabel: (json['customLabel'] as String?) ?? '',
        leapMonth: (json['leapMonth'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'year': year,
        'month': month,
        'day': day,
        'label': _eventLabelToString[label],
        'customLabel': customLabel,
        'leapMonth': leapMonth,
      };

  @override
  int get hashCode =>
      // toString() necessary because, for example,
      // 1.hashCode ^ 11.hashCode == 2.hashCode ^ 22.hashCode == 20
      year.toString().hashCode ^
      month.toString().hashCode ^
      day.toString().hashCode ^
      label.hashCode ^
      customLabel.hashCode ^
      leapMonth.hashCode;

  @override
  bool operator ==(Object o) =>
      o is Event &&
      o.year == year &&
      o.month == month &&
      o.day == day &&
      o.label == label &&
      o.customLabel == customLabel &&
      o.leapMonth == leapMonth;

  @override
  String toString() =>
      'Event(year=$year, month=$month, day=$day, label=$label, '
      'customLabel=$customLabel, leapMonth=$leapMonth)';

  List<String> toVCard() {
    // BDAY (V3): https://tools.ietf.org/html/rfc2426#section-3.1.5
    // BDAY (V4): https://tools.ietf.org/html/rfc6350#section-6.2.5
    // ANNIVERSARY (V4): https://tools.ietf.org/html/rfc6350#section-6.2.6
    if ((FlutterContacts.config.vCardVersion == VCardVersion.v3 &&
            label == EventLabel.birthday) ||
        (FlutterContacts.config.vCardVersion == VCardVersion.v4 &&
            (label == EventLabel.birthday ||
                label == EventLabel.anniversary ||
                label == EventLabel.birthday_lunar))) {
      String param = label == EventLabel.birthday ? 'BDAY' : 'ANNIVERSARY';

      if (FlutterContacts.config.vCardVersion == VCardVersion.v3) {
        return [
          '$param:'
              '${year == null ? '0000' : year.toString().padLeft(4, '0')}-'
              '${month.toString().padLeft(2, '0')}-'
              '${day.toString().padLeft(2, '0')}'
        ];
      } else {
        if (label == EventLabel.birthday_lunar) {
          param =
              'X-ALTBDAY;CALSCALE=${customLabel.isNotEmpty ? customLabel : 'chinese'}';
          return [
            '$param:0078'
                '${year == null ? '' : year.toString().padLeft(4, '0')}'
                '${month.toString().padLeft(2, '0')}'
                '${leapMonth ? 'L' : ''}'
                '${day.toString().padLeft(2, '0')}'
          ];
        }
        return [
          '$param:'
              '${year == null ? '--' : year.toString().padLeft(4, '0')}'
              '${month.toString().padLeft(2, '0')}'
              '${day.toString().padLeft(2, '0')}'
        ];
      }
    }
    return [];
  }
}

/// Event labels.
///
/// | Label          | Android | iOS |
/// |----------------|:-------:|:---:|
/// | anniversary    | ✔       | ✔   |
/// | birthday       | ✔       | ✔   |
/// | other          | ✔       | ✔   |
/// | custom         | ✔       | ✔   |
/// | birthday_lunar |         | ✔   |
enum EventLabel {
  anniversary,
  birthday,
  birthday_lunar,
  other,
  custom,
}

final _eventLabelToString = {
  EventLabel.anniversary: 'anniversary',
  EventLabel.birthday: 'birthday',
  EventLabel.birthday_lunar: 'birthday_lunar',
  EventLabel.other: 'other',
  EventLabel.custom: 'custom',
};

final _stringToEventLabel = {
  'anniversary': EventLabel.anniversary,
  'birthday': EventLabel.birthday,
  'birthday_lunar': EventLabel.birthday_lunar,
  'other': EventLabel.other,
  'custom': EventLabel.custom,
};
