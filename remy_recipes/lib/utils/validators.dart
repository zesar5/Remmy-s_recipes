bool validarCorreo(String correo) {
  final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  return regex.hasMatch(correo);
}

bool validarContrasenyaFuerte(String c) {
  return c.length >= 8 &&
      c.contains(RegExp(r'[A-Z]')) &&
      c.contains(RegExp(r'[a-z]')) &&
      c.contains(RegExp(r'[0-9]')) &&
      c.contains(RegExp(r'[^A-Za-z0-9]'));
}
