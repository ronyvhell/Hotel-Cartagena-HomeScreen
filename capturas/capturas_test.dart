// Genera capturas PNG (390x844, tamaño de celular) de las pantallas
// antes y después. Se ejecuta en CI: flutter test capturas --update-goldens
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_cartagena_flutter/main.dart';
import 'package:hotel_cartagena_flutter/models/huesped.dart';
import 'package:hotel_cartagena_flutter/screens/home_screen.dart';
import 'package:hotel_cartagena_flutter/screens/login_screen.dart';
import 'package:hotel_cartagena_flutter/services/hotel.dart';

import 'antes/home_screen.dart' as antes;
import 'antes/login_screen.dart' as antes;

/// Carga Roboto e íconos reales (por defecto el test usa cajas grises).
Future<void> _fuentes() async {
  final raiz = Platform.environment['FLUTTER_ROOT']!;
  final dir = Directory('$raiz/bin/cache/artifacts/material_fonts');
  final roboto = FontLoader('Roboto');
  final iconos = FontLoader('MaterialIcons');
  for (final f in dir.listSync().whereType<File>()) {
    final nombre = f.uri.pathSegments.last;
    final datos = Future.value(ByteData.sublistView(f.readAsBytesSync()));
    if (nombre.startsWith('Roboto-')) roboto.addFont(datos);
    if (nombre.startsWith('MaterialIcons')) iconos.addFont(datos);
  }
  await roboto.load();
  await iconos.load();
}

/// Hotel con datos de ejemplo: 2 reservadas y 1 ocupada.
Hotel _hotel() {
  final hotel = Hotel()..registrarRecepcionista('rony', '1');
  for (final n in [101, 104, 107]) {
    hotel.reservarHabitacion(
        huesped: Huesped(nombre: 'Huésped $n', documento: '$n'),
        numeroHabitacion: n,
        dias: 2);
  }
  hotel.realizarCheckIn(numeroHabitacion: 107, numeroPersonas: 2);
  return hotel;
}

final _temaAntes = ThemeData(
  colorSchemeSeed: Colors.indigo,
  useMaterial3: true,
  inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
);

Future<void> _foto(
    WidgetTester t, String nombre, ThemeData tema, Widget pantalla) async {
  final clave = GlobalKey();
  await t.pumpWidget(RepaintBoundary(
    key: clave,
    child: MaterialApp(
        debugShowCheckedModeBanner: false, theme: tema, home: pantalla),
  ));
  await t.pumpAndSettle();
  await expectLater(find.byKey(clave), matchesGoldenFile('out/$nombre.png'));
}

void main() {
  testWidgets('capturas', (t) async {
    await t.runAsync(_fuentes);
    t.view.physicalSize = const Size(1170, 2532);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);

    // El tema nuevo se toma de la app real.
    await t.pumpWidget(HotelCartagenaApp(hotel: Hotel()));
    final temaNuevo = Theme.of(t.element(find.byType(LoginScreen)));

    final hotel = _hotel();
    final rony = hotel.iniciarSesion('rony', '1');

    await _foto(t, 'antes_login', _temaAntes, antes.LoginScreen(hotel: hotel));
    await _foto(t, 'despues_login', temaNuevo, LoginScreen(hotel: hotel));
    await _foto(t, 'antes_home', _temaAntes,
        antes.HomeScreen(hotel: hotel, recepcionista: rony));
    await _foto(t, 'despues_home', temaNuevo,
        HomeScreen(hotel: hotel, recepcionista: rony));
  });
}
