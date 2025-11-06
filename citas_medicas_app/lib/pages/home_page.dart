import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/appointment.dart';
import '../services/storage_service.dart';
import 'add_edit_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StorageService storage = StorageService();
  List<Appointment> appointments = [];
  final DateFormat fmt = DateFormat('dd MMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await storage.loadAppointments();
    setState(() => appointments = loaded);
  }

  Future<void> _delete(String id) async {
    await storage.deleteAppointment(id);
    await _load();
  }

  void _openAdd() async {
    final appt = await Navigator.push<Appointment>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditPage()),
    );
    if (appt != null) {
      await storage.addAppointment(appt);
      await _load();
    }
  }

  void _openEdit(Appointment ap) async {
    final appt = await Navigator.push<Appointment>(
      context,
      MaterialPageRoute(builder: (_) => AddEditPage(appointment: ap)),
    );
    if (appt != null) {
      await storage.updateAppointment(appt);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Citas Médicas',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: appointments.isEmpty
          ? Center(
              child: Text(
                'No hay citas registradas.\nToca el botón + para agregar una.',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: appointments.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, i) {
                final ap = appointments[i];
                return Slidable(
                  key: Key(ap.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _openEdit(ap),
                        backgroundColor: Colors.green,
                        icon: Icons.edit,
                        label: 'Editar',
                      ),
                      SlidableAction(
                        onPressed: (_) => _delete(ap.id),
                        backgroundColor: Colors.red,
                        icon: Icons.delete,
                        label: 'Eliminar',
                      ),
                    ],
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    child: ListTile(
                      title: Text('${ap.patientName} — ${ap.doctor}',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                      subtitle: Text(
                        '${fmt.format(ap.dateTime)}\n${ap.description}',
                        style: GoogleFonts.poppins(color: Colors.grey[700]),
                      ),
                      isThreeLine: true,
                      leading: const Icon(Icons.calendar_today, color: Colors.teal),
                      onTap: () => _openEdit(ap),
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}
