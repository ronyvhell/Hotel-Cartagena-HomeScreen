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
    final colores = Theme.of(context).colorScheme;
    final texto = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        // SingleChildScrollView evita que el teclado tape los campos en
        // pantallas pequeñas.
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              // Limita el ancho del formulario en tablets o escritorio.
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Marca: mismo degradado que la tarjeta de la Home.
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [colores.primary, colores.tertiary],
                          ),
                        ),
                        child: Icon(Icons.hotel_rounded,
                            size: 36, color: colores.onPrimary),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Bienvenido',
                      textAlign: TextAlign.center,
                      style: texto.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Hotel Cartagena · Recepción',
                      textAlign: TextAlign.center,
                      style: texto.bodyMedium
                          ?.copyWith(color: colores.onSurfaceVariant),
                    ),
                    const SizedBox(height: 32),

                    TextFormField(
                      controller: _usuarioController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Usuario',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (valor) =>
                          (valor == null || valor.trim().isEmpty)
                              ? 'El usuario no puede estar vacío'
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // Contraseña, con botón para mostrar/ocultar.
                    TextFormField(
                      controller: _contrasenaController,
                      obscureText: _ocultarContrasena,
                      onFieldSubmitted: (_) => _iniciarSesion(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _ocultarContrasena
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                          icon: Icon(_ocultarContrasena
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
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
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Iniciar sesión'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _irARegistro,
                      child: const Text('¿Eres nuevo? Crear cuenta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
