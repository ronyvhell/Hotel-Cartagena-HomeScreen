import 'package:flutter/material.dart';

import '../enums/estado_habitacion.dart';
import '../enums/tipo_habitacion.dart';
import '../models/habitacion.dart';
import '../services/hotel.dart';

/// Ventana de consulta de habitaciones disponibles (RF03).
///
/// Muestra las habitaciones disponibles agrupadas por tipo, tal como
/// exige el requisito funcional. Es un [StatelessWidget] porque no
/// necesita guardar estado propio: cada vez que se abre, vuelve a leer
/// los datos actuales del [Hotel].
class RoomsScreen extends StatelessWidget {
  final Hotel hotel;

  const RoomsScreen({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    // Se calcula la agrupación en cada construcción de la pantalla,
    // para reflejar siempre el estado más reciente de las habitaciones
    // (por ejemplo, después de una reserva hecha desde otra ventana).
    final Map<TipoHabitacion, List<Habitacion>> agrupadas =
        hotel.consultarDisponiblesAgrupadas();

    return Scaffold(
      appBar: AppBar(title: const Text('Habitaciones disponibles')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        // Se recorre cada tipo de habitación y se muestra una tarjeta
        // desplegable (ExpansionTile) con sus habitaciones disponibles.
        children: TipoHabitacion.values.map((tipo) {
          final habitaciones = agrupadas[tipo]!;
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              // Se muestra ya expandida para que el recepcionista vea
              // de inmediato cuántas habitaciones hay de cada tipo.
              initiallyExpanded: true,
              title: Text(
                '$tipo (${habitaciones.length} disponible(s))',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: habitaciones.isEmpty
                  ? const [
                      ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text('Sin habitaciones disponibles'),
                      ),
                    ]
                  : habitaciones
                      .map((h) => ListTile(
                            leading: const Icon(Icons.door_front_door),
                            title: Text('Habitación ${h.numero}'),
                            subtitle:
                                Text('Capacidad: ${h.capacidad} persona(s)'),
                            trailing: _EstadoChip(estado: h.estado),
                          ))
                      .toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Pequeña etiqueta de color que muestra el estado de una habitación.
///
/// Aunque en esta pantalla todas las habitaciones listadas están
/// disponibles, el widget se deja genérico (soporta los tres estados)
/// por si en el futuro se reutiliza para mostrar habitaciones en
/// cualquier estado.
class _EstadoChip extends StatelessWidget {
  final EstadoHabitacion estado;

  const _EstadoChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    final MaterialColor color = switch (estado) {
      EstadoHabitacion.disponible => Colors.green,
      EstadoHabitacion.reservada => Colors.orange,
      EstadoHabitacion.ocupada => Colors.red,
    };
    return Chip(
      label: Text(estado.toString()),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color.shade700),
    );
  }
}
