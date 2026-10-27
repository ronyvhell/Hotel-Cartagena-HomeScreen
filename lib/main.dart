import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'services/hotel.dart';

/// Punto de entrada de la aplicación Flutter.
///
/// Se crea UNA sola instancia de [Hotel] aquí y se pasa hacia abajo
/// por los constructores de cada pantalla (login -> home -> reservas,
/// check-in, check-out, etc.). De esta forma todas las pantallas
/// comparten el mismo estado en memoria (habitaciones, reservas,
/// recepcionistas) mientras la app está abierta, sin necesidad de usar
/// paquetes externos de manejo de estado (Provider, Bloc, etc.), lo
/// cual mantiene el proyecto simple para fines académicos.
void main() {
  runApp(HotelCartagenaApp(hotel: Hotel()));
}

/// Widget raíz de la aplicación.
class HotelCartagenaApp extends StatelessWidget {
  final Hotel hotel;

  const HotelCartagenaApp({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Cartagena',
      debugShowCheckedModeBanner: false,
      // Tema simple y consistente para todas las ventanas de la app.
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      // La primera ventana que ve el usuario es la de inicio de sesión.
      home: LoginScreen(hotel: hotel),
    );
  }
}
