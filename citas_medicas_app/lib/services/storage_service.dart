import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';

class StorageService {
  static const String _key = 'appointments_v1';

  Future<List<Appointment>> loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) => Appointment.fromJson(s)).toList();
  }

  Future<void> saveAppointments(List<Appointment> list) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = list.map((a) => a.toJson()).toList();
    await prefs.setStringList(_key, raw);
  }

  Future<void> addAppointment(Appointment ap) async {
    final list = await loadAppointments();
    list.add(ap);
    await saveAppointments(list);
  }

  Future<void> updateAppointment(Appointment ap) async {
    final list = await loadAppointments();
    final idx = list.indexWhere((e) => e.id == ap.id);
    if (idx != -1) {
      list[idx] = ap;
      await saveAppointments(list);
    }
  }

  Future<void> deleteAppointment(String id) async {
    final list = await loadAppointments();
    list.removeWhere((e) => e.id == id);
    await saveAppointments(list);
  }
}
