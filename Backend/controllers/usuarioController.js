const { Usuario } = require("../models/usuario");


//--------------------------
//    REGISTRAR USUARIO
//--------------------------
exports.registrarUsuario = async (req, res) => {
    const data = req.body;

    if (data.contrasena !== data.contrasena2) {
        return res.status(400).json({ mensaje: "Las credenciales no coinciden" });
    }

    try {
        // Verificar si el usuario ya existe
        const existe = await Usuario.existeUsuario(data.userName);
        if (existe) {
            return res.status(400).json({ mensaje: "El usuario ya existe" });
        }

        // Crear usuario
        const idUsuario = await Usuario.crearUsuario(data);

        // Guardar imagen si existe
        if (data.fotoPerfil) {
            await Usuario.guardarImagen(idUsuario, data.fotoPerfil);
        }

        res.json({ mensaje: "Usuario creado", id: idUsuario });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

//--------------------------
//    OBTENER PERFIL
//--------------------------
exports.obtenerPerfil = async (req, res) => {
    const { id } = req.params;

    try {
        const perfil = await Usuario.obtenerPerfil(id);

        if (!perfil) {
            return res.status(404).json({ mensaje: "Usuario no encontrado" });
        }

        res.json(perfil);

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};