// Genera capturas PNG de la app en tamaño celular (no corre con `flutter test`).
// Uso: PREFIJO=despues flutter test capturas/ --update-goldens
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hotel_cartagena_flutter/main.dart';
import 'package:hotel_cartagena_flutter/models/huesped.dart';
import 'package:hotel_cartagena_flutter/services/hotel.dart';

final prefijo = Platform.environment['PREFIJO'] ?? 'despues';

/// Carga Roboto e íconos reales del SDK (por defecto los tests usan cuadros).
Future<void> _cargarFuentes() async {
  final dir = Directory(
      '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts');
  final roboto = FontLoader('Roboto');
  final iconos = FontLoader('MaterialIcons');
  for (final f in dir.listSync(recursive: true).whereType<File>()) {
    final nombre = f.uri.pathSegments.last;
    final datos = Future.value(ByteData.sublistView(f.readAsBytesSync()));
    if (nombre.startsWith('Roboto-')) roboto.addFont(datos);
    if (nombre.startsWith('MaterialIcons')) iconos.addFont(datos);
  }
  await roboto.load();
  await iconos.load();
}

Future<void> _foto(String nombre) => expectLater(
    find.byType(MaterialApp), matchesGoldenFile('out/${prefijo}_$nombre.png'));

void main() {
  testWidgets('capturas', (tester) async {
    await tester.runAsync(_cargarFuentes);
    debugDisableShadows = false; // sombras reales, no borde negro de test
    tester.view.physicalSize = const Size(1170, 2532); // iPhone 13
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // Hotel con algo de movimiento para que la Home tenga datos.
    final hotel = Hotel()..registrarRecepcionista('rony', '1234');
    final h = Huesped(nombre: 'Ana', documento: '1');
    hotel.reservarHabitacion(huesped: h, numeroHabitacion: 101, dias: 2);
    hotel.reservarHabitacion(huesped: h, numeroHabitacion: 104, dias: 3);
    hotel.reservarHabitacion(huesped: h, numeroHabitacion: 107, dias: 1);
    hotel.realizarCheckIn(numeroHabitacion: 104, numeroPersonas: 2);

    await tester.pumpWidget(HotelCartagenaApp(hotel: hotel));
    await tester.pumpAndSettle();
    await _foto('login');

    await tester.enterText(find.widgetWithText(TextFormField, 'Usuario'), 'rony');
    await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), '1234');
    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();
    await _foto('home');

    if (prefijo == 'despues') {
      await tester.tap(find.byTooltip('Cerrar sesión'));
      await tester.pumpAndSettle();
      await _foto('salir');
    }
    debugDisableShadows = true; // el framework exige dejarlo como estaba
  });
}
