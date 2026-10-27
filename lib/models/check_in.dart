import 'reserva.dart';

/// Registra el ingreso efectivo de un huésped a una habitación que ya
/// contaba con una [Reserva] vigente.
class CheckIn {
  final Reserva reserva;
  final int numeroPersonas;
  final DateTime fecha;

  CheckIn({
    required this.reserva,
    required this.numeroPersonas,
    DateTime? fecha,
  }) : fecha = fecha ?? DateTime.now();

  @override
  String toString() =>
      'Check-in [Habitación: ${reserva.habitacion.numero}, Personas: $numeroPersonas]';
}
