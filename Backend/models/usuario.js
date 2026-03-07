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
    this.contrasenaHash = obj.contrasenaHash; // ← ¡OJO! Contraseña en plano (muy inseguro)
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

  //crear usuario
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
      ],
    );

    return result.insertId;
  }

  //Guardar imagen
  static async guardarImagen(idUsuario, base64Image) {
    // Quitamos el prefijo "data:image/jpeg;base64," (o similar)
    const cleanBase64 = base64Image.replace(/^data:image\/\w+;base64,/, "");

    // Convertimos base64 a buffer (formato binario que puede guardar MySQL)
    const buffer = Buffer.from(cleanBase64, "base64");

    await db.query(
      `INSERT INTO usuario_imagen (imagen, Id_usuario)
            VALUES (?, ?)`,
      [buffer, idUsuario],
    );
  }

  // Obtener perfil
  static async obtenerPerfil(id) {
    const [rows] = await db.query(
      "SELECT u.*, ui.imagen FROM usuario u LEFT JOIN usuario_imagen ui ON u.Id_usuario = ui.Id_usuario WHERE u.Id_usuario = ?",
      [id],
    );

    if (rows.length === 0) return null;
    const user = rows[0];

    if (user.imagen) {
      user.fotoPerfil = `data:image/jpeg;base64,${user.imagen.toString("base64")}`;
    } else {
      user.fotoPerfil = null;
    }
    console.log("FOTO PERFIL ENVIADA:");
    console.log(user.fotoPerfil);

    return user;
  }

  static async obtenerTodosUsuarios() {
    const [rows] = await db.query(
      "SELECT Id_usuario, nombre, pais, email, descripcion, anioNacimiento FROM usuario",
    );
    return rows;
  }
  static async obtenerUsuariosComunidad() {
    const [rows] = await db.query(
      `SELECT
      u.Id_usuario,
      u.nombre,
      u.descripcion,
      ui.imagen
      FROM usuario u
      LEFT JOIN usuario_imagen ui
      ON u.Id_usuario = ui.Id_usuario
      `,
    );
    return rows.map((user) => {
      if (user.imagen) {
        user.fotoPerfil = `data:image/jpeg;base64,${user.imagen.toString("base64")}`;
      } else {
        user.fotoPerfil = null;
      }
      return user;
    });
  }

  static async actualizarPerfil(id, data) {
    const { nombre, descripcion, fotoPerfil } = data;

    await db.query(
      "UPDATE usuario SET nombre = ?, descripcion = ? WHERE ID_usuario = ?",
      [nombre, descripcion, id],
    );

    if (fotoPerfil) {
      const cleanBase64 = fotoPerfil.replace(/^data:image\/\w+;base64,/, "");
      const buffer = Buffer.from(cleanBase64, "base64");
      await db.query(
        "INSERT INTO usuario_imagen (Id_usuario, imagen) VALUES (?, ?) ON DUPLICATE KEY UPDATE imagen = VALUES(imagen)",
        [id, buffer],
      );
    }
    //Devuelve el perfil actualizado
    return await Usuario.obtenerPerfil(id);
  }
  static async actualizarRutaFotoPerfil(idUsuario, imagenBuffer) {
    const db = require("../config/db");
    try {
      await db.query("DELETE FROM usuario_imagen WHERE Id_usuario=?", [
        idUsuario,
      ]);

      const sql =
        "INSERT INTO usuario_imagen (Id_usuario, imagen) VALUES (?, ?)";

      const [result] = await db.query(sql, [idUsuario, imagenBuffer]);
      return result;
    } catch (error) {
      console.error("Error en el modelo de actualizar foto:", error);
      throw error;
    }
  }
}

module.exports = { Usuario, UsuarioEntity };
