import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hotel_cartagena_flutter/models/huesped.dart';
import 'package:hotel_cartagena_flutter/models/recepcionista.dart';
import 'package:hotel_cartagena_flutter/screens/home_screen.dart';
import 'package:hotel_cartagena_flutter/services/hotel.dart';

Future<Hotel> _abrirHome(WidgetTester tester) async {
  final hotel = Hotel();
  await tester.pumpWidget(MaterialApp(
    home: HomeScreen(
      hotel: hotel,
      recepcionista: Recepcionista(usuario: 'ana', contrasena: '1'),
    ),
  ));
  return hotel;
}

void main() {
  testWidgets('Resumen inicial y refresco al volver', (tester) async {
    final hotel = await _abrirHome(tester);

    expect(find.text('Hola, ana'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('Sin llegadas pendientes'), findsOneWidget);
    expect(find.text('0 de 9 habitaciones en uso'), findsOneWidget);

    // Cambia el estado mientras otra pantalla está abierta.
    await tester.tap(find.text('Consultar habitaciones'));
    await tester.pumpAndSettle();
    hotel.reservarHabitacion(
      huesped: Huesped(nombre: 'Luis', documento: '1'),
      numeroHabitacion: 101,
      dias: 2,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('1 llegada pendiente'), findsOneWidget);
    expect(find.text('8 habitaciones libres'), findsOneWidget);
    expect(find.text('1 de 9 habitaciones en uso'), findsOneWidget);
  });

  testWidgets('Cerrar sesión pide confirmación', (tester) async {
    await _abrirHome(tester);

    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('¿Cerrar sesión?'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Hola, ana'), findsOneWidget);
  });
}
