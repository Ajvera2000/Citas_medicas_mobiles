import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Appointment> _appointments = [];

  List<Appointment> get appointments => _appointments;

  Future<void> loadAppointments() async {
    _appointments = await _storage.loadAppointments();
    notifyListeners();
  }

  Future<void> addAppointment(Appointment ap) async {
    _appointments.add(ap);
    await _storage.addAppointment(ap);
    await NotificationService.scheduleAppointmentNotification(ap);
    notifyListeners();
  }

  Future<void> updateAppointment(Appointment ap) async {
    final index = _appointments.indexWhere((e) => e.id == ap.id);
    if (index != -1) {
      _appointments[index] = ap;
      await _storage.updateAppointment(ap);
      await NotificationService.cancelAppointmentNotification(ap);
      await NotificationService.scheduleAppointmentNotification(ap);
      notifyListeners();
    }
  }

  Future<void> deleteAppointment(Appointment ap) async {
    _appointments.removeWhere((e) => e.id == ap.id);
    await _storage.deleteAppointment(ap.id);
    await NotificationService.cancelAppointmentNotification(ap);
    notifyListeners();
  }
}
