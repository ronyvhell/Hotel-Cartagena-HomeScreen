import 'package:flutter/material.dart';

import '../services/hotel.dart';
import '../widgets/mensajes.dart';

/// Ventana de check-in (RF06).
///
/// Recibe el número de habitación y la cantidad de personas que
/// ingresan. El servicio [Hotel] se encarga de validar que exista una
/// reserva activa, que la habitación esté en estado "reservada" y que
/// el número de personas no supere la capacidad.
class CheckInScreen extends StatefulWidget {
  final Hotel hotel;

  const CheckInScreen({super.key, required this.hotel});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroHabitacionController = TextEditingController();
  final _personasController = TextEditingController();

  @override
  void dispose() {
    _numeroHabitacionController.dispose();
    _personasController.dispose();
    super.dispose();
  }

  void _hacerCheckIn() {
    if (!_formKey.currentState!.validate()) return;

    final numeroHabitacion = int.parse(_numeroHabitacionController.text);
    final personas = int.parse(_personasController.text);

    try {
      final checkIn = widget.hotel.realizarCheckIn(
        numeroHabitacion: numeroHabitacion,
        numeroPersonas: personas,
      );
      mostrarExito(
        context,
        'Check-in realizado: habitación ${checkIn.reserva.habitacion.numero} '
        'ahora está ocupada por $personas persona(s).',
      );
      _formKey.currentState!.reset();
      _numeroHabitacionController.clear();
      _personasController.clear();
    } on HotelException catch (e) {
      mostrarError(context, e.mensaje);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in')),
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
                  const Icon(Icons.login, size: 56, color: Colors.indigo),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _personasController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad de personas',
                      prefixIcon: Icon(Icons.groups),
                    ),
                    // La validación de "no supera la capacidad" no se
                    // puede hacer aquí porque este formulario no sabe
                    // a qué habitación corresponde hasta que se envía;
                    // esa regla la aplica el servicio Hotel (RF06).
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Requerido';
                      final personas = int.tryParse(v);
                      if (personas == null) return 'Debe ser un número';
                      if (personas <= 0) return 'Debe ser mayor que cero';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _hacerCheckIn,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Confirmar check-in'),
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
