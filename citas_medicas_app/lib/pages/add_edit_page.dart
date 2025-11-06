// lib/pages/add_edit_page.dart
import 'package:flutter/material.dart';
import '../models/appointment.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddEditPage extends StatefulWidget {
  final Appointment? appointment;

  const AddEditPage({super.key, this.appointment});

  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late TextEditingController _patientCtrl;
  late TextEditingController _doctorCtrl;
  late TextEditingController _descCtrl;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _patientCtrl = TextEditingController(text: widget.appointment?.patientName ?? '');
    _doctorCtrl = TextEditingController(text: widget.appointment?.doctor ?? '');
    _descCtrl = TextEditingController(text: widget.appointment?.description ?? '');
    _selectedDate = widget.appointment?.dateTime;
  }

  @override
  void dispose() {
    _patientCtrl.dispose();
    _doctorCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
    );
    if (time == null) return;
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;
    final appt = Appointment(
      id: widget.appointment?.id ?? _uuid.v4(),
      patientName: _patientCtrl.text.trim(),
      doctor: _doctorCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      dateTime: _selectedDate!,
    );
    Navigator.pop(context, appt);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy – HH:mm');
    final isEditing = widget.appointment != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Cita' : 'Nueva Cita'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _patientCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nombre del paciente',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _doctorCtrl,
                    decoration: InputDecoration(
                      labelText: 'Doctor',
                      prefixIcon: const Icon(Icons.medical_services),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descCtrl,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'Sin fecha seleccionada'
                              : fmt.format(_selectedDate!),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pickDateTime,
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Seleccionar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: Text(isEditing ? 'Guardar cambios' : 'Guardar cita'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
