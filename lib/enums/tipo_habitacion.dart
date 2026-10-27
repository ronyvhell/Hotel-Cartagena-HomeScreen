/// Tipos de habitación disponibles en el hotel.
///
/// Cada tipo lleva asociada su capacidad máxima de personas, para no
/// duplicar ese dato en cada objeto [Habitacion] ni arriesgarnos a que
/// quede inconsistente (por ejemplo, una suite con capacidad de 1).
enum TipoHabitacion {
  sencilla(capacidadMaxima: 1),
  doble(capacidadMaxima: 2),
  suite(capacidadMaxima: 4);

  final int capacidadMaxima;

  const TipoHabitacion({required this.capacidadMaxima});

  /// Texto legible para mostrar en la interfaz (listas, chips, etc.).
  @override
  String toString() {
    switch (this) {
      case TipoHabitacion.sencilla:
        return 'Sencilla';
      case TipoHabitacion.doble:
        return 'Doble';
      case TipoHabitacion.suite:
        return 'Suite';
    }
  }
}
