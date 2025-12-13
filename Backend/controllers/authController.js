const db = require("../config/db");

exports.login = async (req, res) => {
    const { nombreUsuario, contrasena } = req.body;

    try{
        const [rows] = await db.query(
            "SELECT * FROM usuario WHERE nombre = ? AND contraseña = ?",
            [nombreUsuario, contrasena]
        )

        if(rows.length === 0){
            return res.status(400).json({ mensaje: "Credenciales incorrectas"} );
        }

        const usuario = rows[0];

        res.json({ mensaje: "Login correcto", usuario });
    } catch(err){
        res.status(500).json({ error: err.message });
    }
}