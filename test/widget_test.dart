import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hotel_cartagena_flutter/main.dart';
import 'package:hotel_cartagena_flutter/services/hotel.dart';

/// Prueba de humo ("smoke test"): verifica que la app arranca y que
/// la primera pantalla que se muestra es la de inicio de sesión, con
/// sus campos de usuario y contraseña visibles.
void main() {
  testWidgets('La app inicia mostrando la pantalla de login',
      (WidgetTester tester) async {
    await tester.pumpWidget(HotelCartagenaApp(hotel: Hotel()));

    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Usuario'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Contraseña'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Iniciar sesión'), findsOneWidget);
  });
}
