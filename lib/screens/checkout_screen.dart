import 'package:flutter/material.dart';

import '../services/hotel.dart';
import '../widgets/mensajes.dart';

/// Ventana de check-out (RF07).
///
/// Solo pide el número de habitación. El servicio [Hotel] valida que
/// la habitación esté ocupada antes de liberarla y dejarla disponible
/// nuevamente.
class CheckOutScreen extends StatefulWidget {
  final Hotel hotel;

  const CheckOutScreen({super.key, required this.hotel});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroHabitacionController = TextEditingController();

  @override
  void dispose() {
    _numeroHabitacionController.dispose();
    super.dispose();
  }

  void _hacerCheckOut() {
    if (!_formKey.currentState!.validate()) return;

    final numeroHabitacion = int.parse(_numeroHabitacionController.text);

    try {
      final checkOut = widget.hotel.realizarCheckOut(numeroHabitacion);
      mostrarExito(
        context,
        'Check-out realizado: la habitación '
        '${checkOut.checkIn.reserva.habitacion.numero} ya está disponible.',
      );
      _formKey.currentState!.reset();
      _numeroHabitacionController.clear();
    } on HotelException catch (e) {
      mostrarError(context, e.mensaje);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-out')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.logout, size: 56, color: Colors.indigo),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _numeroHabitacionController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Número de habitación',
                      prefixIcon: Icon(Icons.meeting_room),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Requerido';
                      if (int.tryParse(v) == null) return 'Debe ser un número';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _hacerCheckOut,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Confirmar check-out'),
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
