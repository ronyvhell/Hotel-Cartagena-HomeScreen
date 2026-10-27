/// Usuario del sistema encargado de operar el mostrador del hotel.
///
/// Nota: en un sistema real la contraseña debería guardarse con un
/// hash seguro (por ejemplo, con el paquete `crypto`). Aquí se guarda
/// en texto plano por tratarse de un ejercicio académico.
class Recepcionista {
  final String usuario;
  final String contrasena;

  Recepcionista({required this.usuario, required this.contrasena});
}
