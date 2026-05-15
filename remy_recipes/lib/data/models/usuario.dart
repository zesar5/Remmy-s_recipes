// ==========================================================================
//                  MODELO DE DATOS: USUARIO
// ==========================================================================

class Usuario {
  final String
  id; // ID del usuario (string porque viene como número del backend)
  final String userName; // nombre de usuario (único)
  final String? pais;
  final String email;

  // Estos campos SOLO se usan en el formulario de registro
  final String contrasena; // contraseña (solo para registro)
  final String contrasena2; // confirmación (solo frontend)

  // Campos opcionales del perfil
  final String? descripcion;
  final int? anioNacimiento;
  final String? fotoPerfil; // base64 de la imagen de perfil
  final String? fotoUrl; // URL relativa de la imagen (/usuarios/foto/{id})

  Usuario({
    required this.id,
    required this.userName,
    required this.email,
    required this.contrasena,
    required this.contrasena2,
    this.pais,
    this.descripcion,
    this.anioNacimiento,
    this.fotoPerfil,
    this.fotoUrl,
  });

  // ------------------------------------------------------------------------
  // Constructor desde JSON → usado principalmente al obtener el PERFIL
  // ------------------------------------------------------------------------
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: (json['Id_usuario'] ?? json['id'] ?? json['userId'])?.toString() ?? '',
      userName: json['nombre'] ?? json['userName'] ?? json['nombreUsuario'] ?? json['username'] ?? '',
      pais: json['pais'] ?? json['country'],
      email: json['email'] ?? json['correo'] ?? json['user_email'] ?? '',

      // Estos campos NO vienen en el perfil → los dejamos vacíos
      contrasena: '',
      contrasena2: '',

      descripcion: json['descripcion'] ?? json['bio'] ?? json['about'],
      anioNacimiento: json['anioNacimiento'] ?? json['birthYear'],
      // La foto podría venir como base64 completo o null
      fotoPerfil: json['fotoPerfil'] ?? json['foto'] ?? json['profilePicture'],
      // La URL de la foto (nuevo campo)
      fotoUrl: json['fotoUrl'] ?? json['foto_url'] ?? json['profileUrl'],
    );
  }

  // ------------------------------------------------------------------------
  // Convierte el objeto a JSON SOLO para el REGISTRO (POST /register)
  // ------------------------------------------------------------------------
  Map<String, dynamic> toJsonRegistro() {
    return {
      'nombre': userName,
      'email': email,
      'contrasena': contrasena,
      'contrasena2': contrasena2, // el backend valida que coincidan
      'pais': pais,
      'descripcion': descripcion,
      'anioNacimiento': anioNacimiento,
      'fotoPerfil': fotoPerfil,

      // Nota importante:
      //   - No enviamos 'id' (lo genera el backend)
      //   - No enviamos otros campos que no estén en el formulario
    };
  }
}
