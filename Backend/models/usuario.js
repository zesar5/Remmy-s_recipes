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
  static async guardarImagen(idUsuario, imagePath) {
    await db.query(
      `INSERT INTO usuario_imagen (imagen, Id_usuario)
      VALUES (?, ?)`,
      [imagePath, idUsuario],
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
      user.fotoPerfil = `/uploads/usuarios/${user.imagen}`;
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
  static async obtenerUsuariosComunidad(incluirImagenes = false) {
    let query = `
      SELECT 
        u.Id_usuario,
        u.nombre,
        u.descripcion
    `;
    
    // Solo incluir imagen si se solicita
    if (incluirImagenes) {
      query += `, ui.imagen`;
    }
    
    query += `
     FROM usuario u
     LEFT JOIN usuario_imagen ui
       ON u.Id_usuario = ui.Id_usuario
     GROUP BY u.Id_usuario, u.nombre, u.descripcion
     LIMIT 50
    `;

    const [rows] = await db.query(query);

    return rows.map((user) => {
      const result = {
        Id_usuario: user.Id_usuario,
        nombre: user.nombre,
        descripcion: user.descripcion,
      };

      // Si se incluyen imágenes y el usuario tiene, convertir a base64
      if (user.imagen) {
        result.fotoPerfil = user.imagen;
      }

      return result;
    });
  }

  static async actualizarPerfil(id, data) {
    const { nombre, descripcion, fotoPerfil } = data;

    await db.query(
      "UPDATE usuario SET nombre = ?, descripcion = ? WHERE ID_usuario = ?",
      [nombre, descripcion, id],
    );

    if (fotoPerfil) {
      await db.query(
        `INSERT INTO usuario_imagen (Id_usuario, imagen)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE imagen = VALUES(imagen)`,
        [id, fotoPerfil],
      );
    }
    //Devuelve el perfil actualizado
    return await Usuario.obtenerPerfil(id);
  }
  static async actualizarRutaFotoPerfil(idUsuario, imagePath) {
    const db = require("../config/db");

    try {
      await db.query(
        `
        INSERT INTO usuario_imagen (Id_usuario, imagen)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE imagen = VALUES(imagen)
        `,
        [idUsuario, imagePath]
      );

    } catch (error) {
      console.error("Error en el modelo de actualizar foto:", error);
      throw error;
    }
  }
}

module.exports = { Usuario, UsuarioEntity };
