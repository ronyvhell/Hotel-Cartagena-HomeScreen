import 'package:flutter/material.dart';

import '../services/hotel.dart';
import '../widgets/mensajes.dart';
import 'home_screen.dart';
import 'register_screen.dart';

/// Ventana de inicio de sesión (RF02).
///
/// Es la primera pantalla que ve cualquier persona al abrir la app.
/// Permite iniciar sesión con un usuario ya registrado, o navegar a
/// la pantalla de registro para crear uno nuevo.
class LoginScreen extends StatefulWidget {
  /// Instancia única de [Hotel] que se comparte con toda la app.
  final Hotel hotel;

  const LoginScreen({super.key, required this.hotel});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // GlobalKey que identifica el formulario y permite validarlo con
  // `_formKey.currentState!.validate()`.
  final _formKey = GlobalKey<FormState>();

  // Controladores para leer el texto escrito en cada campo.
  final _usuarioController = TextEditingController();
  final _contrasenaController = TextEditingController();

  // Controla si la contraseña se muestra en texto plano o con puntos.
  bool _ocultarContrasena = true;

  @override
  void dispose() {
    // Buena práctica: liberar los controladores cuando la pantalla se
    // destruye, para evitar fugas de memoria.
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  /// Intenta iniciar sesión usando los datos del formulario.
  ///
  /// 1. Si la validación de formato del formulario falla (campos
  ///    vacíos), no hace nada más: los mensajes de error ya se
  ///    muestran automáticamente bajo cada campo.
  /// 2. Si el formato es correcto, delega la validación de
  ///    credenciales al servicio [Hotel]. Si lanza [HotelException]
  ///    (usuario o contraseña incorrectos), se muestra el mensaje en
  ///    un SnackBar.
  void _iniciarSesion() {
    if (!_formKey.currentState!.validate()) return;

    try {
      final recepcionista = widget.hotel.iniciarSesion(
        _usuarioController.text.trim(),
        _contrasenaController.text,
      );

      // pushReplacement en vez de push: así el usuario no puede volver
      // a esta pantalla de login presionando el botón "atrás".
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            hotel: widget.hotel,
            recepcionista: recepcionista,
          ),
        ),
      );
    } on HotelException catch (e) {
      mostrarError(context, e.mensaje);
    }
  }

  /// Abre la pantalla de registro de un nuevo recepcionista.
  void _irARegistro() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RegisterScreen(hotel: widget.hotel)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hotel Cartagena')),
      // SingleChildScrollView evita que el teclado tape los campos en
      // pantallas pequeñas.
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            // Limita el ancho del formulario para que también se vea
            // bien en pantallas grandes (tablets o escritorio).
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.hotel, size: 72, color: Colors.indigo),
                  const SizedBox(height: 8),
                  const Text(
                    'Bienvenido',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Campo de usuario.
                  TextFormField(
                    controller: _usuarioController,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (valor) =>
                        (valor == null || valor.trim().isEmpty)
                            ? 'El usuario no puede estar vacío'
                            : null,
                  ),
                  const SizedBox(height: 16),

                  // Campo de contraseña, con botón para mostrar/ocultar.
                  TextFormField(
                    controller: _contrasenaController,
                    obscureText: _ocultarContrasena,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_ocultarContrasena
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () => setState(
                            () => _ocultarContrasena = !_ocultarContrasena),
                      ),
                    ),
                    validator: (valor) => (valor == null || valor.isEmpty)
                        ? 'La contraseña no puede estar vacía'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  FilledButton.icon(
                    onPressed: _iniciarSesion,
                    icon: const Icon(Icons.login),
                    label: const Text('Iniciar sesión'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _irARegistro,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Registrar nuevo recepcionista'),
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
