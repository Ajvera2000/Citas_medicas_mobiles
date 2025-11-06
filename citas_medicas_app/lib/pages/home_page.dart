// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/appointment.dart';
import '../services/storage_service.dart';
import 'add_edit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StorageService storage = StorageService();
  List<Appointment> appointments = [];
  final DateFormat fmt = DateFormat('yyyy-MM-dd HH:mm');

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
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditAppointmentPage()),
    );
    if (result == true) await _load();
  }

  void _openEdit(Appointment ap) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEditAppointmentPage(appointment: ap)),
    );
    if (result == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas Médicas'),
        centerTitle: true,
      ),
      body: appointments.isEmpty
          ? const Center(
              child: Text('No hay citas. Usa el botón + para agregar.'),
            )
          : ListView.builder(
              itemCount: appointments.length,
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
                  child: ListTile(
                    title: Text('${ap.patientName} — ${ap.doctor}'),
                    subtitle: Text(fmt.format(ap.dateTime)),
                    onTap: () => _openEdit(ap),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}
