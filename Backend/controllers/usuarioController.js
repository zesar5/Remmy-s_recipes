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
            [data.userName]
        );

        if(exists.length > 0){
            return res.status(400).json({ mensaje: "El usuario ya existe" })
        }

        const [result] = await db.query(
            'INSERT INTO usuario (nombre, pais, email, contrasena, descripcion, anioNacimiento) VALUES (?, ?, ?, ?, ?, ?)',
            [data.userName, data.pais, data.email, data.contrasena, data.descripcion, data.anioNacimiento]
        );

        if(data.fotoPerfil){
            const base64Data = data.fotoPerfil.replace(/^data:image\/\w+;base64,/, "");

            const buffer = Buffer.from(base64Data, "base64");

            await db.query(
                'INSERT INTO usuario_imagen (imagen, Id_usuario) VALUES (?, ?)',
                [buffer, result.insertId]
            )
        }

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
            "SELECT * FROM usuario WHERE Id_usuario = ?",
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