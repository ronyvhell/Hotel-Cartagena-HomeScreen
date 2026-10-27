import 'package:flutter/material.dart';

import '../models/huesped.dart';
import '../services/hotel.dart';
import '../widgets/mensajes.dart';

/// Ventana para reservar una habitación (RF04 y RF05).
///
/// Pide los datos del huésped, el número de habitación y la cantidad
/// de días, y delega la validación de las reglas de negocio (que la
/// habitación exista, esté disponible y los días sean mayores que
/// cero) al servicio [Hotel].
class ReserveScreen extends StatefulWidget {
  final Hotel hotel;

  const ReserveScreen({super.key, required this.hotel});

  @override
  State<ReserveScreen> createState() => _ReserveScreenState();
}

class _ReserveScreenState extends State<ReserveScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _documentoController = TextEditingController();
  final _numeroHabitacionController = TextEditingController();
  final _diasController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _documentoController.dispose();
    _numeroHabitacionController.dispose();
    _diasController.dispose();
    super.dispose();
  }

  /// Valida el formato de los campos y, si todo está bien, delega la
  /// creación de la reserva al servicio [Hotel]. Las reglas de negocio
  /// (RF05: habitación existente, disponible, días > 0) se validan
  /// allá; aquí solo se valida que los campos tengan el formato
  /// correcto (no vacíos, números válidos).
  void _reservar() {
    if (!_formKey.currentState!.validate()) return;

    final huesped = Huesped(
      nombre: _nombreController.text.trim(),
      documento: _documentoController.text.trim(),
    );
    // Ya se validó en el formulario que estos textos son números
    // válidos, por lo que es seguro usar int.parse aquí.
    final numeroHabitacion = int.parse(_numeroHabitacionController.text);
    final dias = int.parse(_diasController.text);

    try {
      final reserva = widget.hotel.reservarHabitacion(
        huesped: huesped,
        numeroHabitacion: numeroHabitacion,
        dias: dias,
      );
      mostrarExito(
        context,
        'Reserva creada: habitación ${reserva.habitacion.numero} '
        'por ${reserva.dias} día(s) para ${reserva.huesped.nombre}.',
      );
      // Limpia el formulario para permitir registrar otra reserva sin
      // tener que volver a esta pantalla.
      _formKey.currentState!.reset();
      _nombreController.clear();
      _documentoController.clear();
      _numeroHabitacionController.clear();
      _diasController.clear();
    } on HotelException catch (e) {
      mostrarError(context, e.mensaje);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reservar habitación')),
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
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del huésped',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _documentoController,
                    decoration: const InputDecoration(
                      labelText: 'Documento del huésped',
                      prefixIcon: Icon(Icons.badge),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _numeroHabitacionController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Número de habitación',
                      prefixIcon: Icon(Icons.meeting_room),
                    ),
                    // Valida que el texto no esté vacío y sea un
                    // número entero antes de intentar convertirlo.
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Requerido';
                      if (int.tryParse(v) == null) return 'Debe ser un número';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _diasController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad de días',
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                    // RF05 ya lo valida Hotel, pero se repite aquí la
                    // validación de "mayor que cero" para dar feedback
                    // inmediato en el propio campo, sin esperar a
                    // enviar el formulario.
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Requerido';
                      final dias = int.tryParse(v);
                      if (dias == null) return 'Debe ser un número';
                      if (dias <= 0) return 'Debe ser mayor que cero';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _reservar,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Confirmar reserva'),
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
