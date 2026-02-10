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

  /// Returns a map of eventId -> attribute for the given volunteer
  Future<Map<int, String>> getVolunteerEventAssignments(int volunteerId) async {
    final db = await database;
    final result = await db.query(
      'event_volunteers',
      where: 'volunteer_id = ?',
      whereArgs: [volunteerId],
    );

    // Map: eventId -> attribute
    return {
      for (var m in result)
        m['event_id'] as int: (m['attribute'] as String?) ?? 'Unassigned',
    };
  }

  /// Update attribute for a volunteer already assigned to an event
  Future<void> updateAssignmentAttributeForVolunteer(
      int volunteerId, int eventId, String attribute) async {
    final db = await database;
    await db.update(
      'event_volunteers',
      {'attribute': attribute},
      where: 'volunteer_id = ? AND event_id = ?',
      whereArgs: [volunteerId, eventId],
    );
  }

  /// Get a single event by its ID
  Future<Event?> getEventById(int id) async {
    final db = await database;
    final maps = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Event.fromMap(maps.first);
    } else {
      return null; // not found
    }
  }



    /// Add a single volunteer to an event with attribute
  Future<void> addVolunteerToEventWithAttribute(
      int volunteerId, int eventId, String attribute) async {
    final db = await database;

    // Avoid duplicates
    final exists = await db.query(
      'event_volunteers',
      where: 'volunteer_id = ? AND event_id = ?',
      whereArgs: [volunteerId, eventId],
      limit: 1,
    );

    if (exists.isEmpty) {
      await db.insert('event_volunteers', {
        'volunteer_id': volunteerId,
        'event_id': eventId,
        'attribute': attribute,
      });
    } else {
      // update attribute if already exists
      await db.update(
        'event_volunteers',
        {'attribute': attribute},
        where: 'volunteer_id = ? AND event_id = ?',
        whereArgs: [volunteerId, eventId],
      );
    }
  }

  /// Delete assignment for a specific volunteer and event
  Future<void> deleteAssignment(int volunteerId, int eventId) async {
    final db = await database;
    await db.delete(
      'event_volunteers',
      where: 'volunteer_id = ? AND event_id = ?',
      whereArgs: [volunteerId, eventId],
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

  Future<void> addVolunteersToEvent(int eventId, List<int> volunteerIds) async {
    if (volunteerIds.isEmpty) return;

    final db = await database;
    final batch = db.batch();

    for (var volId in volunteerIds) {
      // Check if this volunteer is already assigned to avoid duplicates
      final exists = await db.query(
        'event_volunteers',
        where: 'event_id = ? AND volunteer_id = ?',
        whereArgs: [eventId, volId],
        limit: 1,
      );

      if (exists.isEmpty) {
        batch.insert('event_volunteers', {
          'event_id': eventId,
          'volunteer_id': volId,
          'attribute': '', // default to Unassigned
        });
      }
    }

    await batch.commit(noResult: true);
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

  
