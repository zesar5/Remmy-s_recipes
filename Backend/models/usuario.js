const db = require("../config/db");

// ----------------------------------------
//     ENTIDAD / MODELO DE USUARIO
// ----------------------------------------
class UsuarioEntity {
    constructor(obj) {
        this.id = obj.Id_usuario;
        this.nombre = obj.nombre;
        this.pais = obj.pais;
        this.email = obj.email;
        this.contrasena = obj.contrasena;
        this.descripcion = obj.descripcion;
        this.anioNacimiento = obj.anioNacimiento;
    }
}

// ----------------------------------------
//         ACCESO A LA BD (MODELO)
// ----------------------------------------
class Usuario {

    // Verificar si existe
    static async existeUsuario(nombre) {
        const [rows] = await db.query(
            "SELECT * FROM usuario WHERE nombre = ?",
            [nombre]
        );
        return rows.length > 0;
    }

    // Crear usuario
    static async crearUsuario(data) {
        const [result] = await db.query(
            `INSERT INTO usuario
            (nombre, pais, email, contrasena, descripcion, anioNacimiento)
            VALUES (?, ?, ?, ?, ?, ?)`,
            [
                data.userName,
                data.pais,
                data.email,
                data.contrasena,
                data.descripcion,
                data.anioNacimiento
            ]
        );

        return result.insertId;
    }

    // Guardar imagen
    static async guardarImagen(idUsuario, base64Image) {
        const cleanBase64 = base64Image.replace(/^data:image\/\w+;base64,/, "");
        const buffer = Buffer.from(cleanBase64, "base64");

        await db.query(
            `INSERT INTO usuario_imagen (imagen, Id_usuario)
            VALUES (?, ?)`,
            [buffer, idUsuario]
        );
    }

    // Obtener perfil
    static async obtenerPerfil(id) {
        const [rows] = await db.query(
            "SELECT * FROM usuario WHERE Id_usuario = ?",
            [id]
        );

        if (rows.length === 0) return null;

        return new UsuarioEntity(rows[0]); // ← Aquí convertimos el objeto a entidad
    }
}

module.exports = { Usuario, UsuarioEntity };