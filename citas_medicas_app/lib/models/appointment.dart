// lib/models/appointment.dart
import 'dart:convert';

class Appointment {
  String id;
  String patientName;
  String doctor;
  DateTime dateTime;
  String notes;

  Appointment({
    required this.id,
    required this.patientName,
    required this.doctor,
    required this.dateTime,
    this.notes = '',
  });

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as String,
      patientName: map['patientName'] as String,
      doctor: map['doctor'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      notes: map['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientName': patientName,
      'doctor': doctor,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
    };
  }

  String toJson() => json.encode(toMap());

  factory Appointment.fromJson(String source) =>
      Appointment.fromMap(json.decode(source) as Map<String, dynamic>);
}
