import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hotel_cartagena_flutter/enums/tipo_habitacion.dart';
import 'package:hotel_cartagena_flutter/models/huesped.dart';
import 'package:hotel_cartagena_flutter/screens/rooms_screen.dart';
import 'package:hotel_cartagena_flutter/services/hotel.dart';

final _huesped = Huesped(nombre: 'Test', documento: '000');

Future<void> _abrir(WidgetTester tester, Hotel hotel) async {
  // Superficie alta para que el ListView construya todas las filas.
  await tester.binding.setSurfaceSize(const Size(420, 2400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(MaterialApp(home: RoomsScreen(hotel: hotel)));
}

void main() {
  testWidgets('M3 + M2: resumen, filtro y un botón por habitación', (tester) async {
    await _abrir(tester, Hotel());

    expect(find.text('Disponibles'), findsOneWidget);
    expect(find.text('Reservadas'), findsOneWidget);
    expect(find.text('Ocupadas'), findsOneWidget);
    expect(find.text('¿Cuántas personas?'), findsOneWidget);
    expect(find.text('Reservar'), findsNWidgets(9));
  });

  testWidgets('M2: el filtro "3–4" deja solo las Suites', (tester) async {
    await _abrir(tester, Hotel());

    await tester.tap(find.text('3–4'));
    await tester.pumpAndSettle();

    expect(find.text('Suite'), findsOneWidget);
    expect(find.text('Sencilla'), findsNothing);
    expect(find.text('Doble'), findsNothing);
    expect(find.text('Reservar'), findsNWidgets(3));
  });

  testWidgets('M1: Reservar abre la reserva con el número cargado', (tester) async {
    await _abrir(tester, Hotel());

    await tester.tap(find.text('Reservar').first);
    await tester.pumpAndSettle();

    expect(find.text('Reservar habitación'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '101'), findsOneWidget);
  });

  testWidgets('M5: el estado vacío sugiere qué hacer', (tester) async {
    final hotel = Hotel();
    for (final h in hotel.habitaciones.where((h) => h.tipo == TipoHabitacion.suite)) {
      hotel.reservarHabitacion(huesped: _huesped, numeroHabitacion: h.numero, dias: 1);
    }
    await _abrir(tester, hotel);

    await tester.tap(find.text('3–4'));
    await tester.pumpAndSettle();

    expect(find.text('No hay habitaciones disponibles'), findsOneWidget);
    expect(find.textContaining('Ajusta el filtro'), findsOneWidget);
  });

  testWidgets('M4: Actualizar refleja cambios hechos en Hotel', (tester) async {
    final hotel = Hotel();
    await _abrir(tester, hotel);
    expect(find.text('Habitación 101'), findsOneWidget);

    hotel.reservarHabitacion(huesped: _huesped, numeroHabitacion: 101, dias: 1);
    await tester.tap(find.byTooltip('Actualizar'));
    await tester.pumpAndSettle();

    expect(find.text('Habitación 101'), findsNothing);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('2 disponibles'), findsOneWidget);
  });
}
