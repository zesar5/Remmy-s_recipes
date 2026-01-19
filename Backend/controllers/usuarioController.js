const { Usuario } = require("../models/usuario");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const getMessages = require("../i18n");

// ────────────────────────────────────────────────
//                  LOGIN USUARIO
// ────────────────────────────────────────────────

/**
 * Endpoint: POST /login
 *
 * Autenticación básica con email + contraseña (sin hash en este ejemplo)
 *
 * Respuestas posibles:
 * - 200 → { mensaje, token, id, userName, email }
 * - 400 → faltan campos
 * - 401 → credenciales incorrectas
 * - 500 → error de base de datos
 */
exports.loginUsuario = async (req, res) => {
  const { email, contrasena } = req.body;

  // Validación básica de campos requeridos
  if (!email || !contrasena) {
    return res.status(400).json({
      mensaje: t.loginRequiredFields,
    });
  }

  try {
    // ⚠️ IMPORTANTE: Aquí se compara la contraseña en texto plano
    // Esto es inseguro en producción → debería usar bcrypt + hash
    const [rows] = await require("../config/db").query(
      "SELECT * FROM usuario WHERE email = ? ",
      [email],
    );
    
    if (rows.length === 0) {
      return res.status(401).json({
        mensaje: t.invalidCredentials,
      });
    }

    const usuario = rows[0];
    /*const passwordCorrecta = await bcrypt.compare(
      contrasena,
      usuario.contrasena,
    );
    if (!passwordCorrecta) {
      return res.status(401).json({ mensaje: t.invalidCredentials });
    if (!passwordCorrecta) {*/
    if(contrasena !== usuario.contrasena){
      return res.status(401).json({ mensaje: "Credenciales incorrectas" });
    }

    // Generamos token JWT con el id del usuario
    const token = jwt.sign(
      { id: usuario.Id_usuario }, // payload
      process.env.JWT_SECRET, // clave secreta (debe estar en .env)
      { expiresIn: "24h" }, // duración del token
    );

    console.log("JWT generado:", token);

    // Respuesta exitosa con datos útiles para el frontend
    res.json({
      mensaje: t.loginSuccess,
      token,
      id: usuario.Id_usuario,
      userName: usuario.nombre,
      email: usuario.email,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// ────────────────────────────────────────────────
//               REGISTRAR NUEVO USUARIO
// ────────────────────────────────────────────────

/**
 * Endpoint: POST /register
 *
 * Crea un nuevo usuario en el sistema
 *
 * Validaciones:
 * - Contraseñas coinciden
 * - Nombre de usuario no esté ya tomado
 *
 * Opcional: guarda foto de perfil (base64 o similar)
 */
exports.registrarUsuario = async (req, res) => {
  const data = req.body;

  // Verificación básica de coincidencia de contraseñas
  if (data.contrasena !== data.contrasena2) {
    return res.status(400).json({
      mensaje: t.passwordsDontMatch,
    });
  }

  try {
    // 1. Verificar si ya existe un usuario con ese nombre
    const existe = await Usuario.existeUsuario(data.nombre);
    if (existe) {
      return res.status(400).json({
        mensaje: t.userAlreadyExists,
      });
    }
    const saltRounds = 10;
    const hash = await bcrypt.hash(data.contrasena, saltRounds);

    data.contrasena = hash;

    // 2. Crear el usuario en la base de datos
    console.log("Datos a registrar:", data);
    const idUsuario = await Usuario.crearUsuario(data);

    // 3. Guardar foto de perfil si se envió
    if (data.fotoPerfil) {
      await Usuario.guardarImagen(idUsuario, data.fotoPerfil);
    }

    // Respuesta exitosa
    res.json({
      mensaje: t.userCreated,
      id: idUsuario,
    });
  } catch (err) {
    console.error("Error al registrar usuario:", err);
    res.status(500).json({ error: err.message });
  }
};

// ────────────────────────────────────────────────
//                 OBTENER PERFIL USUARIO
// ────────────────────────────────────────────────

/**
 * Endpoint: GET /perfil/:id   o   /usuarios/:id
 *
 * Devuelve la información pública/visible del perfil de un usuario
 *
 * Normalmente usado para:
 * - Ver perfil propio
 * - Ver perfil de otros usuarios
 */
exports.obtenerPerfil = async (req, res) => {
  const { id } = req.params;

  try {
    const perfil = await Usuario.obtenerPerfil(id);

    if (!perfil) {
      return res.status(404).json({
        mensaje: t.userNotFound,
      });
    }

    res.json(perfil);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
