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
/// Muestra el estado del hotel (ocupación y contadores) y las cuatro
/// operaciones del sistema. Es [StatefulWidget] para refrescar los
/// datos al volver de cualquier otra pantalla. Solo lee
/// `hotel.habitaciones`: las reglas de negocio siguen en [Hotel].
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
  /// Abre una pantalla y, al volver, reconstruye con datos frescos.
  Future<void> _abrir(Widget pantalla) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => pantalla));
    if (mounted) setState(() {});
  }

  /// Pide confirmación antes de salir para evitar cierres accidentales.
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

  String get _saludo {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Buenos días';
    if (hora < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    final disponibles = _contar(EstadoHabitacion.disponible);
    final reservadas = _contar(EstadoHabitacion.reservada);
    final ocupadas = _contar(EstadoHabitacion.ocupada);

    String cantidad(int n, String uno, String varios) =>
        '$n ${n == 1 ? uno : varios}';

    return Scaffold(
      body: SafeArea(
        child: Center(
          // En web/escritorio la columna no se estira a todo el ancho.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                _Encabezado(
                  saludo: _saludo,
                  usuario: widget.recepcionista.usuario,
                  onSalir: _cerrarSesion,
                ),
                const SizedBox(height: 20),
                _Ocupacion(
                  disponibles: disponibles,
                  reservadas: reservadas,
                  ocupadas: ocupadas,
                  total: hotel.habitaciones.length,
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    'Operaciones',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                // Orden = ciclo de vida de la habitación (RF03 → RF07).
                _Grupo(
                  children: [
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
                          : cantidad(disponibles, 'habitación libre',
                              'habitaciones libres'),
                      onTap: () => _abrir(ReserveScreen(hotel: hotel)),
                    ),
                    _Accion(
                      icono: Icons.key_outlined,
                      titulo: 'Check-in',
                      detalle: reservadas == 0
                          ? 'Sin llegadas pendientes'
                          : cantidad(reservadas, 'llegada pendiente',
                              'llegadas pendientes'),
                      onTap: () => _abrir(CheckInScreen(hotel: hotel)),
                    ),
                    _Accion(
                      icono: Icons.luggage_outlined,
                      titulo: 'Check-out',
                      detalle: ocupadas == 0
                          ? 'Sin huéspedes alojados'
                          : cantidad(ocupadas, 'habitación ocupada',
                              'habitaciones ocupadas'),
                      onTap: () => _abrir(CheckOutScreen(hotel: hotel)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar con la inicial, saludo según la hora y botón de salida.
class _Encabezado extends StatelessWidget {
  final String saludo;
  final String usuario;
  final VoidCallback onSalir;

  const _Encabezado({
    required this.saludo,
    required this.usuario,
    required this.onSalir,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final texto = Theme.of(context).textTheme;
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: colores.primaryContainer,
          child: Text(
            usuario.isEmpty ? '?' : usuario[0].toUpperCase(),
            style: texto.titleMedium?.copyWith(
              color: colores.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(saludo,
                  style: texto.bodyMedium
                      ?.copyWith(color: colores.onSurfaceVariant)),
              Text(
                usuario,
                overflow: TextOverflow.ellipsis,
                style: texto.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Cerrar sesión',
          icon: const Icon(Icons.logout_rounded),
          onPressed: onSalir,
        ),
      ],
    );
  }
}

/// Tarjeta principal: porcentaje de ocupación, anillo y contadores.
class _Ocupacion extends StatelessWidget {
  final int disponibles;
  final int reservadas;
  final int ocupadas;
  final int total;

  const _Ocupacion({
    required this.disponibles,
    required this.reservadas,
    required this.ocupadas,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final texto = Theme.of(context).textTheme;
    final sobre = colores.onPrimary;
    final suave = sobre.withValues(alpha: 0.8);

    final enUso = reservadas + ocupadas;
    final proporcion = total == 0 ? 0.0 : enUso / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colores.primary, colores.tertiary],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ocupación del hotel',
                        style: texto.labelLarge?.copyWith(color: suave)),
                    const SizedBox(height: 4),
                    Text(
                      '${(proporcion * 100).round()}%',
                      style: texto.displaySmall?.copyWith(
                        color: sobre,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text('$enUso de $total habitaciones en uso',
                        style: texto.bodySmall?.copyWith(color: suave)),
                  ],
                ),
              ),
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: proporcion,
                      strokeWidth: 7,
                      strokeCap: StrokeCap.round,
                      color: sobre,
                      backgroundColor: sobre.withValues(alpha: 0.2),
                    ),
                    Icon(Icons.hotel_rounded, color: sobre, size: 28),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _Dato(valor: disponibles, etiqueta: 'Libres', punto: Colors.greenAccent),
              const SizedBox(width: 8),
              _Dato(valor: reservadas, etiqueta: 'Reservadas', punto: Colors.amberAccent),
              const SizedBox(width: 8),
              _Dato(valor: ocupadas, etiqueta: 'Ocupadas', punto: Colors.redAccent.shade100),
            ],
          ),
        ],
      ),
    );
  }
}

/// Un contador translúcido dentro de la tarjeta de ocupación.
class _Dato extends StatelessWidget {
  final int valor;
  final String etiqueta;
  final Color punto;

  const _Dato({required this.valor, required this.etiqueta, required this.punto});

  @override
  Widget build(BuildContext context) {
    final sobre = Theme.of(context).colorScheme.onPrimary;
    final texto = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: sobre.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$valor',
                style: texto.titleLarge
                    ?.copyWith(color: sobre, fontWeight: FontWeight.w700)),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: punto, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    etiqueta,
                    overflow: TextOverflow.ellipsis,
                    style: texto.labelSmall
                        ?.copyWith(color: sobre.withValues(alpha: 0.85)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Agrupa las filas en una sola superficie con separadores.
class _Grupo extends StatelessWidget {
  final List<Widget> children;

  const _Grupo({required this.children});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Material(
      color: colores.surfaceContainerLow,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 76,
                color: colores.outlineVariant.withValues(alpha: 0.5),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Fila de operación: ícono, título, dato en vivo y flecha.
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colores.primaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icono, color: colores.onPrimaryContainer),
      ),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(detalle),
      trailing: Icon(Icons.chevron_right_rounded, color: colores.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
