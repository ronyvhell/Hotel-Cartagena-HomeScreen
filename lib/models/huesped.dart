/// Datos básicos de un huésped que realiza una reserva.
class Huesped {
  final String nombre;
  final String documento;

  Huesped({required this.nombre, required this.documento});

  @override
  String toString() => '$nombre (Doc: $documento)';
}
