import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/events.dart';
import 'package:volopsip/database/database_helper.dart'; 
import 'package:volopsip/models/event_assignment.dart';

class EventRepository {
  /// Helper to assign volunteers to an event
  Future<void> _assignVolunteers(int eventId, List<int> volunteerIds, Database db) async {
    if (volunteerIds.isEmpty) return;

    // Remove old assignments first (for updates)
    await db.delete('event_volunteers', where: 'event_id = ?', whereArgs: [eventId]);

    // Insert new assignments in batch
    final batch = db.batch();
    for (var volId in volunteerIds) {
      batch.insert('event_volunteers', {
        'event_id': eventId,
        'volunteer_id': volId,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<Database> get database async {
    // Use the singleton DatabaseHelper
    return await DatabaseHelper.instance.database;
  }

  /// Create an event and assign volunteers
  Future<int> createEvent(Event event, {List<int>? volunteerIds}) async {
    final db = await database;
    final eventId = await db.insert('events', event.toMap());

    if (volunteerIds != null && volunteerIds.isNotEmpty) {
      final batch = db.batch();
      for (var volId in volunteerIds) {
        batch.insert('event_volunteers', {
          'event_id': eventId,
          'volunteer_id': volId,
          'attribute': event.defaultOption, // default value
        });
      }
      await batch.commit(noResult: true);
    }

    return eventId;
  }


  /// Get all events
  Future<List<Event>> getAllEvents() async {
    final db = await database;
    final maps = await db.query('events');
    return maps.map((e) => Event.fromMap(e)).toList();
  }

  /// Get all event assignments
  Future<List<EventAssignment>> getAllEventAssignments() async {
    final db = await database;
    final maps = await db.query('event_volunteers'); // table storing EventAssignment

    return List.generate(
      maps.length,
      (i) => EventAssignment.fromMap(maps[i]),
    );
  }

  /// Update an event and optionally its volunteers
  Future<int> updateEvent(Event event, {List<int>? volunteerIds}) async {
    final db = await database;

    // Update event details
    final result = await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );

    if (volunteerIds != null) {
      // Remove old assignments
      await db.delete('event_volunteers', where: 'event_id = ?', whereArgs: [event.id]);

      // Insert new assignments with default attribute
      final batch = db.batch();
      for (var volId in volunteerIds) {
        batch.insert('event_volunteers', {
          'event_id': event.id,
          'volunteer_id': volId,
          'attribute': event.defaultOption,
        });
      }
      await batch.commit(noResult: true);
    }

    return result;
  }


  /// Delete an event and its volunteer assignments
  Future<int> deleteEvent(int id) async {
    final db = await database;
    await db.delete('event_volunteers', where: 'event_id = ?', whereArgs: [id]);
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  /// Get volunteers assigned to a specific event
  Future<List<Map<String, dynamic>>> getAssignedVolunteersWithAttribute(int eventId) async {
    final db = await database;
    final result = await db.query(
      'event_volunteers',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
    // returns list of {volunteer_id, attribute}
    return result;
  }

  Future<Map<int, String>> getVolunteerAttributesMap(int eventId) async {
    final db = await database;
    final maps = await db.query(
      'event_volunteers',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );

    return {
      for (var m in maps) m['volunteer_id'] as int: m['attribute'] as String? ?? 'Unassigned'
    };
  }

  /// Update a single assignment's attribute
  Future<int> updateAssignmentAttribute(int assignmentId, String attribute) async {
    final db = await database;
    return db.update(
      'event_volunteers',
      {'attribute': attribute},
      where: 'id = ?',
      whereArgs: [assignmentId],
    );
  }

  /// Bulk update multiple assignments
  Future<void> updateAssignmentsAttributes(List<int> assignmentIds, String attribute) async {
    if (assignmentIds.isEmpty) return;

    final db = await database;
    final batch = db.batch();

    for (var id in assignmentIds) {
      batch.update(
        'event_volunteers',
        {'attribute': attribute},
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit(noResult: true);
  }

}

  
