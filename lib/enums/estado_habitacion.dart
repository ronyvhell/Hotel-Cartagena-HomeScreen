/// Estados posibles de una habitación (RF08).
///
/// El flujo permitido es siempre:
/// disponible -> reservada -> ocupada -> disponible.
/// No se permiten saltos entre estados que no sigan este ciclo.
enum EstadoHabitacion {
  disponible,
  reservada,
  ocupada;

  @override
  String toString() {
    switch (this) {
      case EstadoHabitacion.disponible:
        return 'Disponible';
      case EstadoHabitacion.reservada:
        return 'Reservada';
      case EstadoHabitacion.ocupada:
        return 'Ocupada';
    }
  }
}
