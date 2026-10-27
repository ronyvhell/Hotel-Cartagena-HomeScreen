import '../enums/estado_habitacion.dart';
import '../enums/tipo_habitacion.dart';

/// Representa una habitación física del hotel.
///
/// La capacidad no se guarda como campo propio: se obtiene del [tipo]
/// mediante el getter [capacidad], así ambos datos siempre coinciden.
class Habitacion {
  final int numero;
  final TipoHabitacion tipo;

  /// Es mutable porque el estado cambia a lo largo del ciclo de vida
  /// de la habitación (reservas, check-in, check-out).
  EstadoHabitacion estado;

  Habitacion({
    required this.numero,
    required this.tipo,
    this.estado = EstadoHabitacion.disponible,
  });

  /// Capacidad máxima de personas, derivada del tipo de habitación.
  int get capacidad => tipo.capacidadMaxima;

  // Getters de conveniencia usados tanto por el servicio Hotel como
  // por las pantallas, para no comparar el enum "a mano" en la UI.
  bool get estaDisponible => estado == EstadoHabitacion.disponible;
  bool get estaReservada => estado == EstadoHabitacion.reservada;
  bool get estaOcupada => estado == EstadoHabitacion.ocupada;

  @override
  String toString() =>
      'Habitación $numero (Tipo: $tipo, Capacidad: $capacidad, Estado: $estado)';
}
