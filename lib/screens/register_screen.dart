import 'package:flutter/material.dart';

import '../services/hotel.dart';
import '../widgets/mensajes.dart';

/// Ventana de registro de un nuevo recepcionista (RF01).
///
/// No permite usuarios duplicados: esa validación la hace el servicio
/// [Hotel]; aquí solo se valida el formato de los campos (que no estén
/// vacíos y que las dos contraseñas escritas coincidan).
class RegisterScreen extends StatefulWidget {
  final Hotel hotel;

  const RegisterScreen({super.key, required this.hotel});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usuarioController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarController = TextEditingController();

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  /// Valida el formulario y registra el recepcionista mediante el
  /// servicio [Hotel]. Si el usuario ya existe, [Hotel] lanza una
  /// [HotelException] que se captura para mostrar el error.
  void _registrar() {
    if (!_formKey.currentState!.validate()) return;

    try {
      widget.hotel.registrarRecepcionista(
        _usuarioController.text.trim(),
        _contrasenaController.text,
      );
      mostrarExito(context, 'Recepcionista registrado exitosamente.');
      // Vuelve a la pantalla de login para que el usuario inicie sesión
      // con las credenciales que acaba de crear.
      Navigator.of(context).pop();
    } on HotelException catch (e) {
      mostrarError(context, e.mensaje);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar recepcionista')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _usuarioController,
                    decoration: const InputDecoration(
                      labelText: 'Nuevo usuario',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contrasenaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmarController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    // Validación propia de la interfaz (no es una regla
                    // de negocio del Hotel): que ambas contraseñas
                    // escritas coincidan antes de enviarlas.
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if (v != _contrasenaController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _registrar,
                    icon: const Icon(Icons.check),
                    label: const Text('Registrar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
