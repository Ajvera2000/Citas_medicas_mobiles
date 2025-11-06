import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/appointment.dart';
import '../providers/appointment_provider.dart';
import '../services/auth_service.dart';
import 'add_edit_page.dart';
import 'login_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Citas Médicas',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, _) {
          final appointments = provider.appointments;

          if (appointments.isEmpty) {
            return Center(
              child: Text(
                'No hay citas registradas.\nToca el botón + para agregar una.',
                style: GoogleFonts.poppins(
                    fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
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
                      onPressed: (_) async {
                        final updatedAp = await Navigator.push<Appointment>(
                          context,
                          MaterialPageRoute(
                              builder: (_) => AddEditPage(appointment: ap)),
                        );
                        if (updatedAp != null) {
                          provider.updateAppointment(updatedAp);
                        }
                      },
                      backgroundColor: Colors.green,
                      icon: Icons.edit,
                      label: 'Editar',
                    ),
                    SlidableAction(
                      onPressed: (_) => provider.deleteAppointment(ap),
                      backgroundColor: Colors.red,
                      icon: Icons.delete,
                      label: 'Eliminar',
                    ),
                  ],
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                  child: ListTile(
                    title: Text('${ap.patientName} — ${ap.doctor}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                      '${fmt.format(ap.dateTime)}\n${ap.description}',
                      style: GoogleFonts.poppins(color: Colors.grey[700]),
                    ),
                    isThreeLine: true,
                    leading:
                        const Icon(Icons.calendar_today, color: Colors.teal),
                    onTap: () async {
                      final updatedAp = await Navigator.push<Appointment>(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AddEditPage(appointment: ap)),
                      );
                      if (updatedAp != null) {
                        provider.updateAppointment(updatedAp);
                      }
                    },
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () async {
          final newAp = await Navigator.push<Appointment>(
            context,
            MaterialPageRoute(builder: (_) => const AddEditPage()),
          );
          if (newAp != null) {
            Provider.of<AppointmentProvider>(context, listen: false)
                .addAppointment(newAp);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
