import 'package:flutter/material.dart';

import '../enums/estado_habitacion.dart';
import '../models/recepcionista.dart';
import '../services/hotel.dart';
import 'checkin_screen.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';
import 'reserve_screen.dart';
import 'rooms_screen.dart';

/// Pantalla principal del recepcionista.
///
/// Muestra un resumen del estado del hotel y las cuatro operaciones
/// del sistema. Es [StatefulWidget] para refrescar el resumen al
/// volver de cualquier otra pantalla (una reserva o un check-in
/// cambian los contadores). Sigue sin aplicar reglas de negocio:
/// solo lee `hotel.habitaciones`.
class HomeScreen extends StatefulWidget {
  final Hotel hotel;
  final Recepcionista recepcionista;

  const HomeScreen({
    super.key,
    required this.hotel,
    required this.recepcionista,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Abre una pantalla y, al volver, reconstruye el resumen.
  Future<void> _abrir(Widget pantalla) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => pantalla));
    if (mounted) setState(() {});
  }

  /// Pide confirmación antes de salir: el botón está solo y un toque
  /// accidental borraría el historial de navegación.
  Future<void> _cerrarSesion() async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Tendrás que volver a ingresar tu usuario.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (salir != true || !mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen(hotel: widget.hotel)),
      (route) => false,
    );
  }

  int _contar(EstadoHabitacion estado) =>
      widget.hotel.habitaciones.where((h) => h.estado == estado).length;

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    final texto = Theme.of(context).textTheme;
    final colores = Theme.of(context).colorScheme;

    final disponibles = _contar(EstadoHabitacion.disponible);
    final reservadas = _contar(EstadoHabitacion.reservada);
    final ocupadas = _contar(EstadoHabitacion.ocupada);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            // Encabezado: saludo + contexto, y salida discreta.
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hotel Cartagena · Recepción',
                          style: texto.labelLarge
                              ?.copyWith(color: colores.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text('Hola, ${widget.recepcionista.usuario}',
                          style: texto.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar sesión',
                  icon: const Icon(Icons.logout),
                  onPressed: _cerrarSesion,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Resumen del hotel: lo primero que necesita saber recepción.
            _Resumen(
              disponibles: disponibles,
              reservadas: reservadas,
              ocupadas: ocupadas,
              total: hotel.habitaciones.length,
            ),
            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text('Operaciones',
                  style: texto.titleSmall
                      ?.copyWith(color: colores.onSurfaceVariant)),
            ),

            // Orden = ciclo de vida de la habitación (RF03 → RF07).
            _Accion(
              icono: Icons.bed_outlined,
              titulo: 'Consultar habitaciones',
              detalle: 'Disponibilidad por tipo',
              onTap: () => _abrir(RoomsScreen(hotel: hotel)),
            ),
            _Accion(
              icono: Icons.event_available_outlined,
              titulo: 'Reservar',
              detalle: disponibles == 0
                  ? 'Hotel sin habitaciones libres'
                  : '$disponibles ${disponibles == 1 ? 'habitación libre' : 'habitaciones libres'}',
              onTap: () => _abrir(ReserveScreen(hotel: hotel)),
            ),
            _Accion(
              icono: Icons.key_outlined,
              titulo: 'Check-in',
              detalle: reservadas == 0
                  ? 'Sin llegadas pendientes'
                  : '$reservadas ${reservadas == 1 ? 'llegada pendiente' : 'llegadas pendientes'}',
              onTap: () => _abrir(CheckInScreen(hotel: hotel)),
            ),
            _Accion(
              icono: Icons.luggage_outlined,
              titulo: 'Check-out',
              detalle: ocupadas == 0
                  ? 'Sin huéspedes alojados'
                  : '$ocupadas ${ocupadas == 1 ? 'habitación ocupada' : 'habitaciones ocupadas'}',
              onTap: () => _abrir(CheckOutScreen(hotel: hotel)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta con los tres contadores y la barra de ocupación.
class _Resumen extends StatelessWidget {
  final int disponibles;
  final int reservadas;
  final int ocupadas;
  final int total;

  const _Resumen({
    required this.disponibles,
    required this.reservadas,
    required this.ocupadas,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final enUso = reservadas + ocupadas;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colores.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Dato(valor: disponibles, etiqueta: 'Libres', color: Colors.green.shade600),
              _Dato(valor: reservadas, etiqueta: 'Reservadas', color: Colors.orange.shade600),
              _Dato(valor: ocupadas, etiqueta: 'Ocupadas', color: Colors.red.shade400),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : enUso / total,
              minHeight: 6,
              backgroundColor: colores.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$enUso de $total habitaciones en uso',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: colores.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Un contador del resumen: número grande + punto de color + etiqueta.
class _Dato extends StatelessWidget {
  final int valor;
  final String etiqueta;
  final Color color;

  const _Dato({required this.valor, required this.etiqueta, required this.color});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$valor',
              style: texto.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(etiqueta,
                    overflow: TextOverflow.ellipsis,
                    style: texto.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Fila de operación: ícono, título, dato en vivo y flecha.
/// Reemplaza a `_OpcionMenu` (cuadros 2x2 sin descripción).
class _Accion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String detalle;
  final VoidCallback onTap;

  const _Accion({
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colores.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icono, color: colores.onSecondaryContainer),
      ),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(detalle),
      trailing: Icon(Icons.chevron_right, color: colores.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
