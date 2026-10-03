/// Contact container (iOS only).
///
/// On iOS contacts and groups live in containers such as the local container
/// ("On My iPhone"), iCloud / CardDAV accounts or Exchange accounts.
class ContactContainer {
  /// Container identifier.
  String id;

  /// Container name.
  String name;

  /// Container type: local, exchange, cardDAV or unassigned.
  String type;

  /// Whether this is the default container for new contacts.
  bool isDefault;

  ContactContainer(this.id, this.name, this.type, this.isDefault);

  factory ContactContainer.fromJson(Map<String, dynamic> json) =>
      ContactContainer(
        (json['id'] as String?) ?? '',
        (json['name'] as String?) ?? '',
        (json['type'] as String?) ?? '',
        (json['isDefault'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'type': type,
    'isDefault': isDefault,
  };

  @override
  String toString() =>
      'ContactContainer(id=$id, name=$name, type=$type, isDefault=$isDefault)';
}
