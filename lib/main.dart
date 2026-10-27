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
      theme: _tema(),
      // La primera ventana que ve el usuario es la de inicio de sesión.
      home: LoginScreen(hotel: hotel),
    );
  }
}

/// Tema global: color del mar Caribe, campos rellenos y esquinas
/// redondeadas. Todas las pantallas lo heredan sin tocar su código.
ThemeData _tema() {
  final colores = ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E));
  final redondeo = BorderRadius.circular(14);
  final forma = RoundedRectangleBorder(borderRadius: redondeo);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colores,
    appBarTheme: const AppBarTheme(scrolledUnderElevation: 0),
    cardTheme: CardThemeData(
      elevation: 0,
      color: colores.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colores.surfaceContainerHighest.withValues(alpha: 0.5),
      border: OutlineInputBorder(borderRadius: redondeo, borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: redondeo, borderSide: BorderSide.none),
      // El borde vuelve al enfocar, para que se note dónde se escribe.
      focusedBorder: OutlineInputBorder(
        borderRadius: redondeo,
        borderSide: BorderSide(color: colores.primary, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(64, 52), shape: forma),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: const Size(64, 52), shape: forma),
    ),
    snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, shape: forma),
  );
}
