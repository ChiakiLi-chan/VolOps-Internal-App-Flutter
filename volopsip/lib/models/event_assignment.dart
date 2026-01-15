class EventAssignment {
  int? id;
  int eventId;
  int volunteerId;
  String attribute;

  EventAssignment({
    this.id,
    required this.eventId,
    required this.volunteerId,
    required this.attribute,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'volunteer_id': volunteerId,
      'attribute': attribute,
    };
  }

  factory EventAssignment.fromMap(Map<String, dynamic> map) {
    return EventAssignment(
      id: map['id'],
      eventId: map['event_id'],
      volunteerId: map['volunteer_id'],
      attribute: map['attribute'],
    );
  }
}
