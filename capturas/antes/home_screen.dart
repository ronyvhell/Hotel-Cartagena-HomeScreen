import 'package:flutter/material.dart';

import 'package:hotel_cartagena_flutter/models/recepcionista.dart';
import 'package:hotel_cartagena_flutter/services/hotel.dart';
import 'package:hotel_cartagena_flutter/screens/checkin_screen.dart';
import 'package:hotel_cartagena_flutter/screens/checkout_screen.dart';
import 'package:hotel_cartagena_flutter/screens/login_screen.dart';
import 'package:hotel_cartagena_flutter/screens/reserve_screen.dart';
import 'package:hotel_cartagena_flutter/screens/rooms_screen.dart';

/// Menú principal que ve un recepcionista después de iniciar sesión.
///
/// Es puramente de navegación: solo abre las demás ventanas según el
/// botón que el usuario presione. No contiene ninguna regla de
/// negocio ni manipula directamente las listas del [Hotel].
class HomeScreen extends StatelessWidget {
  final Hotel hotel;
  final Recepcionista recepcionista;

  const HomeScreen({
    super.key,
    required this.hotel,
    required this.recepcionista,
  });

  /// Cierra la sesión actual y regresa a la ventana de login,
  /// eliminando todo el historial de navegación anterior (para que no
  /// se pueda volver al menú principal con el botón "atrás").
  void _cerrarSesion(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen(hotel: hotel)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${recepcionista.usuario}'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // Cuadrícula 2x2 con las cuatro operaciones principales del
        // sistema (consultar, reservar, check-in y check-out).
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _OpcionMenu(
              icono: Icons.meeting_room,
              titulo: 'Consultar\nhabitaciones',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => RoomsScreen(hotel: hotel)),
              ),
            ),
            _OpcionMenu(
              icono: Icons.event_available,
              titulo: 'Reservar\nhabitación',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ReserveScreen(hotel: hotel)),
              ),
            ),
            _OpcionMenu(
              icono: Icons.login,
              titulo: 'Check-in',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CheckInScreen(hotel: hotel)),
              ),
            ),
            _OpcionMenu(
              icono: Icons.logout,
              titulo: 'Check-out',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => CheckOutScreen(hotel: hotel)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón grande y reutilizable para cada opción del menú principal.
///
/// Se definió como widget aparte (en vez de repetir el mismo
/// Card + InkWell cuatro veces dentro de `build`) para mantener el
/// código corto y fácil de leer.
class _OpcionMenu extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final VoidCallback onTap;

  const _OpcionMenu({
    required this.icono,
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono,
                size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
