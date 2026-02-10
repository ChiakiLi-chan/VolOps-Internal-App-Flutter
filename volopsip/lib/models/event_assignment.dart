class EventAssignment {
  int? id;
  int eventId;
  int volunteerId;
  String attribute;
  DateTime? lastModified; // ✅ new field

  EventAssignment({
    this.id,
    required this.eventId,
    required this.volunteerId,
    required this.attribute,
    this.lastModified, // optional
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'volunteer_id': volunteerId,
      'attribute': attribute,
      'last_modified': lastModified?.toIso8601String(), // store as text
    };
  }

  factory EventAssignment.fromMap(Map<String, dynamic> map) {
    return EventAssignment(
      id: map['id'],
      eventId: map['event_id'],
      volunteerId: map['volunteer_id'],
      attribute: map['attribute'],
      lastModified: map['last_modified'] != null
          ? DateTime.parse(map['last_modified'])
          : null, // parse string to DateTime
    );
  }
}
