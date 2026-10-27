import 'package:flutter/material.dart';

/// Funciones de ayuda para mostrar mensajes al usuario de forma
/// consistente en toda la aplicación, evitando repetir el mismo
/// código de SnackBar en cada pantalla.

/// Muestra un mensaje de error (fondo rojo) en la parte inferior de
/// la pantalla. Se usa cuando el servicio [Hotel] lanza una
/// [HotelException] (por ejemplo: usuario duplicado, habitación no
/// disponible, capacidad excedida, etc.).
void mostrarError(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensaje),
      backgroundColor: Colors.red.shade700,
    ),
  );
}

/// Muestra un mensaje de éxito (fondo verde) en la parte inferior de
/// la pantalla. Se usa cuando una operación (registro, reserva,
/// check-in, check-out) se completó correctamente.
void mostrarExito(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensaje),
      backgroundColor: Colors.green.shade700,
    ),
  );
}
