import 'package:flutter/material.dart';

import '../enums/estado_habitacion.dart';
import '../enums/tipo_habitacion.dart';
import '../models/habitacion.dart';
import '../services/hotel.dart';
import 'reserve_screen.dart';

/// Consulta de habitaciones disponibles (RF03), rediseñada.
///
/// Mejoras sobre la versión original (StatelessWidget con un
/// ExpansionTile por tipo):
/// 1. Botón "Reservar" por habitación: abre [ReserveScreen] con el
///    número ya cargado.
/// 2. Filtro "¿Cuántas personas?" según la capacidad (solo presentación).
/// 3. Resumen con disponibles, reservadas y ocupadas.
/// 4. [StatefulWidget]: se actualiza al volver, con gesto y botón.
/// 5. Limpieza visual: sin chip redundante, capacidad con ícono,
///    plurales correctos y estado vacío con sugerencia.
///
/// Las reglas de negocio siguen en [Hotel]; aquí solo se leen datos.
class RoomsScreen extends StatefulWidget {
  final Hotel hotel;

  const RoomsScreen({super.key, required this.hotel});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  /// Opciones del filtro: etiqueta y capacidad mínima que deben tener.
  static const _filtros = [('Todas', 1), ('1', 1), ('2', 2), ('3–4', 3)];

  int _filtro = 0;

  /// Abre la reserva con el número precargado y refresca al volver.
  Future<void> _reservar(Habitacion habitacion) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ReserveScreen(
        hotel: widget.hotel,
        numeroInicial: habitacion.numero,
      ),
    ));
    if (mounted) setState(() {});
  }

  /// [Hotel] vive en memoria: basta con reconstruir para ver lo actual.
  Future<void> _refrescar() async => setState(() {});

  int _contar(EstadoHabitacion estado) =>
      widget.hotel.habitaciones.where((h) => h.estado == estado).length;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final minimo = _filtros[_filtro].$2;
    final agrupadas = widget.hotel.consultarDisponiblesAgrupadas();

    // Solo los tipos con habitaciones que sirven al grupo elegido.
    final secciones = [
      for (final tipo in TipoHabitacion.values)
        if (tipo.capacidadMaxima >= minimo && agrupadas[tipo]!.isNotEmpty)
          _Seccion(
            tipo: tipo,
            habitaciones: agrupadas[tipo]!,
            onReservar: _reservar,
          ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habitaciones'),
        actions: [
          // En escritorio el gesto de arrastrar no existe: botón visible.
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refrescar,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refrescar,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Row(
                  children: [
                    _Dato(
                        valor: _contar(EstadoHabitacion.disponible),
                        etiqueta: 'Disponibles',
                        color: Colors.green.shade500),
                    const SizedBox(width: 8),
                    _Dato(
                        valor: _contar(EstadoHabitacion.reservada),
                        etiqueta: 'Reservadas',
                        color: Colors.amber.shade600),
                    const SizedBox(width: 8),
                    _Dato(
                        valor: _contar(EstadoHabitacion.ocupada),
                        etiqueta: 'Ocupadas',
                        color: Colors.red.shade400),
                  ],
                ),
                const SizedBox(height: 24),
                Text('¿Cuántas personas?',
                    style: texto.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: [
                    for (var i = 0; i < _filtros.length; i++)
                      ButtonSegment(value: i, label: Text(_filtros[i].$1)),
                  ],
                  selected: {_filtro},
                  onSelectionChanged: (s) => setState(() => _filtro = s.first),
                ),
                const SizedBox(height: 8),
                if (secciones.isEmpty) const _Vacio() else ...secciones,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Contador del resumen: punto de color, etiqueta y número.
class _Dato extends StatelessWidget {
  final int valor;
  final String etiqueta;
  final Color color;

  const _Dato({required this.valor, required this.etiqueta, required this.color});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final texto = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colores.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      style: texto.labelMedium
                          ?.copyWith(color: colores.onSurfaceVariant)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('$valor',
                style: texto.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

/// Un tipo de habitación: encabezado con capacidad y conteo, y sus filas.
class _Seccion extends StatelessWidget {
  final TipoHabitacion tipo;
  final List<Habitacion> habitaciones;
  final void Function(Habitacion) onReservar;

  const _Seccion({
    required this.tipo,
    required this.habitaciones,
    required this.onReservar,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final texto = Theme.of(context).textTheme;
    final n = habitaciones.length;
    final icono = switch (tipo) {
      TipoHabitacion.sencilla => Icons.single_bed_outlined,
      TipoHabitacion.doble => Icons.bed_outlined,
      TipoHabitacion.suite => Icons.king_bed_outlined,
    };

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                Icon(icono, size: 22, color: colores.primary),
                const SizedBox(width: 8),
                Text('$tipo',
                    style: texto.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('$n ${n == 1 ? 'disponible' : 'disponibles'}',
                    style: texto.labelLarge?.copyWith(color: colores.onSurfaceVariant)),
              ],
            ),
          ),
          Material(
            color: colores.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < n; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 76,
                      color: colores.outlineVariant.withValues(alpha: 0.5),
                    ),
                  _Fila(
                    habitacion: habitaciones[i],
                    onReservar: () => onReservar(habitaciones[i]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Una habitación: número, capacidad con ícono y botón Reservar.
class _Fila extends StatelessWidget {
  final Habitacion habitacion;
  final VoidCallback onReservar;

  const _Fila({required this.habitacion, required this.onReservar});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final capacidad = habitacion.capacidad;
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
      leading: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colores.primaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text('${habitacion.numero}',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: colores.onPrimaryContainer)),
      ),
      title: Text('Habitación ${habitacion.numero}',
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, size: 16, color: colores.onSurfaceVariant),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$capacidad ${capacidad == 1 ? 'persona' : 'personas'}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: FilledButton.tonal(
        onPressed: onReservar,
        style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
        child: const Text('Reservar'),
      ),
    );
  }
}

/// Estado vacío con una sugerencia de qué hacer.
class _Vacio extends StatelessWidget {
  const _Vacio();

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final texto = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: colores.onSurfaceVariant),
          const SizedBox(height: 12),
          Text('No hay habitaciones disponibles',
              style: texto.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Ajusta el filtro de personas o vuelve más tarde.',
              textAlign: TextAlign.center,
              style: texto.bodyMedium?.copyWith(color: colores.onSurfaceVariant)),
        ],
      ),
    );
  }
}
