import 'package:uuid/uuid.dart';
class Volunteer {
  static const _uuid = Uuid();

  final int? id;
  final String uuid;
  final String firstName;
  final String lastName;
  final String? nickname; 
  final int age;
  final String email;
  final String contactNumber;
  final String volunteerType;

  Volunteer({
    this.id,
    String? uuid,
    required this.firstName,
    required this.lastName,
    this.nickname, 
    required this.age,
    required this.email,
    required this.contactNumber,
    required this.volunteerType,
  }) : uuid = uuid ?? _uuid.v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'nickname': nickname,
      'age': age,
      'email': email,
      'contact_number': contactNumber,
      'volunteer_type': volunteerType,
    };
  }

  factory Volunteer.fromMap(Map<String, dynamic> map) {
    return Volunteer(
      id: map['id'],
      uuid: map['uuid'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      nickname: map['nickname'], // may be null
      age: map['age'],
      email: map['email'],
      contactNumber: map['contact_number'],
      volunteerType: map['volunteer_type'],
    );
  }

  String get fullName => '$firstName $lastName';
}
