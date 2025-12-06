const db = require("../db");


//--------------------------
//    REGISTRAR USUARIO
//--------------------------
exports.registrarUsuario = async (req, res) => {
    const data = req.body;

    if(data.contrasena !== data.contrasena2){
        return res.status(400).json({ mensaje: "Las credenciales no coinciden" });
    }

    try{
        const [exists] = await db.query(
            "SELECT * FROM usuario WHERE nombre = ?",
            [data.nombreUsuario]
        );

        if(exists.length > 0){
            return res.status(400).json({ mensaje: "El usuario ya existe" })
        }

        const [result] = await db.query(
            'INSERT INTO usuario (nombre, email, contraseña, fecha_registro) VALUES (?, ?, ?, NOW())',
            [data.nombreUsuario, data.email, data.contrasena]
        );

        res.json({ mensaje: "Usuario creado", id: result.insertId });
    } catch(err){
        res.status(500).json({ error: err.message });
    }
}

//--------------------------
//    PERFIL DE USUARIO
//--------------------------
exports.obtenerPerfil = async (req, res) => {
    const { id } = req.params; 

    try {
        const [rows] = await db.query(
            "SELECT * FROM Usuario WHERE Id_usuario = ?",
            [id]
        );

        if (rows.length === 0) {
            return res.status(404).json({ mensaje: "Usuario no encontrado" });
        }

        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};