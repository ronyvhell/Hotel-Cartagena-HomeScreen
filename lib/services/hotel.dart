import '../enums/estado_habitacion.dart';
import '../enums/tipo_habitacion.dart';
import '../models/check_in.dart';
import '../models/check_out.dart';
import '../models/habitacion.dart';
import '../models/huesped.dart';
import '../models/recepcionista.dart';
import '../models/reserva.dart';

/// Excepción para violaciones de reglas de negocio del hotel.
///
/// Se usa una excepción propia (en vez de lanzar [Exception] directo)
/// para que las pantallas de Flutter puedan capturarla específicamente
/// con `on HotelException catch (e)` y mostrar `e.mensaje` en un
/// SnackBar, sin confundirla con otros errores inesperados.
class HotelException implements Exception {
  final String mensaje;
  HotelException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Clase central que administra el estado del hotel: habitaciones,
/// recepcionistas, reservas, check-ins y check-outs.
///
/// Es la única responsable de aplicar las reglas de negocio (RF01-RF08).
/// Las pantallas de Flutter (en `lib/screens`) solo deben leer datos
/// del usuario mediante formularios y llamar a los métodos de esta
/// clase; nunca deben validar reglas de negocio por su cuenta.
///
/// Se crea UNA sola instancia de [Hotel] en `main.dart` y se comparte
/// entre todas las pantallas (ver comentarios en `main.dart`), para
/// que el estado (habitaciones, reservas, etc.) persista mientras la
/// app esté abierta.
class Hotel {
  final List<Habitacion> habitaciones = [];
  final List<Recepcionista> recepcionistas = [];
  final List<Reserva> reservas = [];
  final List<CheckIn> checkIns = [];
  final List<CheckOut> checkOuts = [];

  Hotel() {
    _crearHabitacionesIniciales();
  }

  /// Crea un conjunto inicial de habitaciones (3 por cada tipo) al
  /// arrancar la aplicación. Toda habitación nueva inicia "disponible".
  void _crearHabitacionesIniciales() {
    int numero = 100;
    for (final tipo in TipoHabitacion.values) {
      for (int i = 0; i < 3; i++) {
        numero++;
        habitaciones.add(Habitacion(numero: numero, tipo: tipo));
      }
    }
  }

  // -------------------- RF01: Registrar recepcionista --------------------

  void registrarRecepcionista(String usuario, String contrasena) {
    if (usuario.trim().isEmpty || contrasena.trim().isEmpty) {
      throw HotelException('Usuario y contraseña no pueden estar vacíos.');
    }
    final existe = recepcionistas.any((r) => r.usuario == usuario);
    if (existe) {
      throw HotelException('El usuario "$usuario" ya existe.');
    }
    recepcionistas.add(Recepcionista(usuario: usuario, contrasena: contrasena));
  }

  // -------------------- RF02: Iniciar sesión --------------------

  Recepcionista iniciarSesion(String usuario, String contrasena) {
    return recepcionistas.firstWhere(
      (r) => r.usuario == usuario && r.contrasena == contrasena,
      orElse: () => throw HotelException('Usuario o contraseña incorrectos.'),
    );
  }

  // -------------------- RF03: Consultar habitaciones --------------------

  List<Habitacion> consultarDisponibles() {
    return habitaciones.where((h) => h.estaDisponible).toList();
  }

  /// Agrupa las habitaciones disponibles por tipo, como exige RF03.
  /// Usado directamente por `RoomsScreen` para pintar una sección por
  /// cada tipo de habitación.
  Map<TipoHabitacion, List<Habitacion>> consultarDisponiblesAgrupadas() {
    final Map<TipoHabitacion, List<Habitacion>> agrupadas = {
      for (final tipo in TipoHabitacion.values) tipo: <Habitacion>[],
    };
    for (final habitacion in consultarDisponibles()) {
      agrupadas[habitacion.tipo]!.add(habitacion);
    }
    return agrupadas;
  }

  Habitacion _buscarHabitacion(int numero) {
    return habitaciones.firstWhere(
      (h) => h.numero == numero,
      orElse: () => throw HotelException('La habitación $numero no existe.'),
    );
  }

  // -------------------- RF04 y RF05: Reservar y validar --------------------

  Reserva reservarHabitacion({
    required Huesped huesped,
    required int numeroHabitacion,
    required int dias,
  }) {
    final habitacion = _buscarHabitacion(numeroHabitacion);
    _validarReserva(habitacion, dias);

    habitacion.estado = EstadoHabitacion.reservada;
    final reserva = Reserva(huesped: huesped, habitacion: habitacion, dias: dias);
    reservas.add(reserva);
    return reserva;
  }

  void _validarReserva(Habitacion habitacion, int dias) {
    if (!habitacion.estaDisponible) {
      throw HotelException(
          'La habitación ${habitacion.numero} no está disponible.');
    }
    if (dias <= 0) {
      throw HotelException('La cantidad de días debe ser mayor que cero.');
    }
  }

  /// Busca la reserva activa más reciente asociada a una habitación.
  Reserva _buscarReservaActivaPorHabitacion(int numeroHabitacion) {
    return reservas.lastWhere(
      (r) => r.habitacion.numero == numeroHabitacion && r.activa,
      orElse: () => throw HotelException(
          'No existe una reserva activa para la habitación $numeroHabitacion.'),
    );
  }

  // -------------------- RF06: Check-in --------------------

  CheckIn realizarCheckIn({
    required int numeroHabitacion,
    required int numeroPersonas,
  }) {
    final reserva = _buscarReservaActivaPorHabitacion(numeroHabitacion);
    final habitacion = reserva.habitacion;

    if (!habitacion.estaReservada) {
      throw HotelException(
          'La habitación ${habitacion.numero} no está en estado reservada.');
    }
    if (numeroPersonas <= 0) {
      throw HotelException('El número de personas debe ser mayor que cero.');
    }
    if (numeroPersonas > habitacion.capacidad) {
      throw HotelException(
          'El número de personas supera la capacidad (${habitacion.capacidad}) de la habitación.');
    }

    habitacion.estado = EstadoHabitacion.ocupada;
    final checkIn = CheckIn(reserva: reserva, numeroPersonas: numeroPersonas);
    checkIns.add(checkIn);
    return checkIn;
  }

  // -------------------- RF07: Check-out --------------------

  CheckOut realizarCheckOut(int numeroHabitacion) {
    final habitacion = _buscarHabitacion(numeroHabitacion);

    if (!habitacion.estaOcupada) {
      throw HotelException(
          'La habitación ${habitacion.numero} no está ocupada.');
    }

    final checkIn = checkIns.lastWhere(
      (c) => c.reserva.habitacion.numero == numeroHabitacion,
      orElse: () => throw HotelException(
          'No se encontró un check-in para la habitación $numeroHabitacion.'),
    );

    // Decisión de diseño: la reserva no se elimina, se marca como
    // inactiva y queda registrada como historial (ver README).
    checkIn.reserva.activa = false;
    habitacion.estado = EstadoHabitacion.disponible;

    final checkOut = CheckOut(checkIn: checkIn);
    checkOuts.add(checkOut);
    return checkOut;
  }
}
