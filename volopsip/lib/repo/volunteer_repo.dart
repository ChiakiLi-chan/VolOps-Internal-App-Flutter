import '../database/database_helper.dart';
import '../models/volunteer.dart';

class VolunteerRepository {
  final _dbHelper = DatabaseHelper.instance;

  /// CREATE
  Future<int> createVolunteer(Volunteer volunteer) async {
    final db = await _dbHelper.database;
    return db.insert('volunteers', volunteer.toMap());
  }

  /// READ (all)
  Future<List<Volunteer>> getAllVolunteers() async {
    final db = await _dbHelper.database;
    final result = await db.query('volunteers');

    return result.map((e) => Volunteer.fromMap(e)).toList();
  }

  /// READ (single)
  Future<Volunteer?> getVolunteerById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'volunteers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;
    return Volunteer.fromMap(result.first);
  }
  
   /// READ (single by UUID)
  Future<Volunteer?> getVolunteerByUuid(String uuid) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'volunteers',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );

    if (result.isEmpty) return null;
    return Volunteer.fromMap(result.first);
  }

  /// UPDATE
  Future<int> updateVolunteer(Volunteer volunteer) async {
    final db = await _dbHelper.database;
    return db.update(
      'volunteers',
      volunteer.toMap(),
      where: 'id = ?',
      whereArgs: [volunteer.id],
    );
  }

  /// DELETE
  Future<int> deleteVolunteer(int id) async {
    final db = await _dbHelper.database;
    return db.delete(
      'volunteers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
