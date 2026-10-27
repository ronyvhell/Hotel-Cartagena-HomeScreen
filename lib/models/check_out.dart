import 'check_in.dart';

/// Registra la salida de un huésped, cerrando el ciclo abierto por el
/// [CheckIn] correspondiente y liberando la habitación.
class CheckOut {
  final CheckIn checkIn;
  final DateTime fecha;

  CheckOut({required this.checkIn, DateTime? fecha})
      : fecha = fecha ?? DateTime.now();

  @override
  String toString() =>
      'Check-out [Habitación: ${checkIn.reserva.habitacion.numero}]';
}
