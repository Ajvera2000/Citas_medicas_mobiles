// lib/pages/add_edit_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../services/storage_service.dart';

class AddEditAppointmentPage extends StatefulWidget {
  final Appointment? appointment;
  const AddEditAppointmentPage({super.key, this.appointment});

  @override
  State<AddEditAppointmentPage> createState() => _AddEditAppointmentPageState();
}

class _AddEditAppointmentPageState extends State<AddEditAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final StorageService storage = StorageService();

  late TextEditingController _patientController;
  late TextEditingController _doctorController;
  late TextEditingController _notesController;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    final ap = widget.appointment;
    _patientController = TextEditingController(text: ap?.patientName ?? '');
    _doctorController = TextEditingController(text: ap?.doctor ?? '');
    _notesController = TextEditingController(text: ap?.notes ?? '');
    _selectedDateTime = ap?.dateTime ?? DateTime.now().add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _patientController.dispose();
    _doctorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final initialDate = _selectedDateTime ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return;
    setState(() {
      _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final id = widget.appointment?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final newAp = Appointment(
      id: id,
      patientName: _patientController.text.trim(),
      doctor: _doctorController.text.trim(),
      dateTime: _selectedDateTime ?? DateTime.now(),
      notes: _notesController.text.trim(),
    );

    if (widget.appointment == null) {
      await storage.addAppointment(newAp);
    } else {
      await storage.updateAppointment(newAp);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.appointment != null;
    final fmt = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar cita' : 'Nueva cita')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _patientController,
                decoration: const InputDecoration(labelText: 'Nombre del paciente'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _doctorController,
                decoration: const InputDecoration(labelText: 'Doctor / Especialidad'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDateTime,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Fecha y hora'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedDateTime == null ? 'Seleccionar' : fmt.format(_selectedDateTime!)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notas (opcional)'),
                maxLines: 3,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(isEdit ? 'Guardar cambios' : 'Crear cita'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
