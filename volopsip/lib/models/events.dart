class Event {
  int? id;
  String name;
  String defaultOption; // e.g., "Unassigned"
  List<String> attributes; // e.g., ["Absent", "Present", "Late"]

  Event({
    this.id,
    required this.name,
    this.defaultOption = 'Unassigned',
    required this.attributes,
  });

  // Convert Event to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'default_option': defaultOption,
      'attributes': attributes.join(','), // store as comma-separated string
    };
  }

  // Create Event from Map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      name: map['name'],
      defaultOption: map['default_option'],
      attributes: map['attributes'] != null
          ? (map['attributes'] as String).split(',')
          : [],
    );
  }
}
