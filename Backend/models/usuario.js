const db = require("../config/db");

// ----------------------------------------
//     CLASE QUE REPRESENTA UN USUARIO
// ----------------------------------------
class UsuarioEntity {
  constructor(obj) {
    this.id = obj.Id_usuario;
    this.nombre = obj.nombre;
    this.pais = obj.pais;
    this.email = obj.email;
    this.contrasena = obj.contrasena; // ← ¡OJO! Contraseña en plano (muy inseguro)
    this.descripcion = obj.descripcion;
    this.anioNacimiento = obj.anioNacimiento;
  }
}

// ----------------------------------------
//     MÉTODOS DE ACCESO A DATOS (MODELO)
// ----------------------------------------
class Usuario {
  /**
   * Verifica si ya existe un usuario con ese nombre de usuario
   * Se usa principalmente durante el registro para evitar duplicados
   * @returns {boolean} true si ya existe
   */
  static async existeUsuario(nombre) {
    const [rows] = await db.query("SELECT * FROM usuario WHERE nombre = ?", [
      nombre,
    ]);
    return rows.length > 0;
  }

  /**
   * Crea un nuevo usuario en la base de datos
   * @param {Object} data - Datos del formulario de registro
   * @returns {number} ID del usuario recién creado
   *
   * IMPORTANTE: Actualmente guarda la contraseña en texto plano → ¡Muy inseguro!
   */
  static async crearUsuario(data) {
    const [result] = await db.query(
      `INSERT INTO usuario
            (nombre, pais, email, contrasena, descripcion, anioNacimiento)
            VALUES (?, ?, ?, ?, ?, ?)`,
      [
        data.nombre,
        data.pais,
        data.email,
        data.contrasena, // ← Aquí está el problema de seguridad
        data.descripcion,
        data.anioNacimiento,
      ]
    );

    return result.insertId;
  }

  /**
   * Guarda la foto de perfil del usuario (almacenada como binario en BD)
   * @param {number} idUsuario
   * @param {string} base64Image - Imagen en formato data:image/...;base64,...
   */
  static async guardarImagen(idUsuario, base64Image) {
    // Quitamos el prefijo "data:image/jpeg;base64," (o similar)
    const cleanBase64 = base64Image.replace(/^data:image\/\w+;base64,/, "");

    // Convertimos base64 a buffer (formato binario que puede guardar MySQL)
    const buffer = Buffer.from(cleanBase64, "base64");

    await db.query(
      `INSERT INTO usuario_imagen (imagen, Id_usuario)
            VALUES (?, ?)`,
      [buffer, idUsuario]
    );
  }

  /**
   * Obtiene los datos básicos del perfil de un usuario por su ID
   * @param {number} id
   * @returns {UsuarioEntity|null} Objeto usuario o null si no existe
   *
   * Nota: NO incluye la imagen de perfil en esta consulta
   */
  static async obtenerPerfil(id) {
    const [rows] = await db.query(
      "SELECT * FROM usuario WHERE Id_usuario = ?",
      [id]
    );

    if (rows.length === 0) return null;

    // Convertimos la fila cruda de la BD en nuestra entidad
    return new UsuarioEntity(rows[0]);
  }
}

module.exports = { Usuario, UsuarioEntity };
