import 'habitacion.dart';
import 'huesped.dart';

/// Representa la reserva de una habitación para un huésped.
///
/// [activa] indica si la reserva sigue vigente. Al hacer check-out la
/// reserva se marca como no activa y queda como historial en lugar de
/// eliminarse, para conservar trazabilidad de lo ocurrido.
class Reserva {
  final Huesped huesped;
  final Habitacion habitacion;
  final int dias;
  final DateTime fechaReserva;
  bool activa;

  Reserva({
    required this.huesped,
    required this.habitacion,
    required this.dias,
    DateTime? fechaReserva,
    this.activa = true,
  }) : fechaReserva = fechaReserva ?? DateTime.now();

  @override
  String toString() =>
      'Reserva [Huésped: $huesped, Habitación: ${habitacion.numero}, Días: $dias]';
}
