const { Usuario } = require("../models/usuario");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const getMessages = require("../i18n");
const logger = require("../logger");

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
  const t = getMessages(req);

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
      logger.info(
        "Intento de login fallido: Iniciar sesión sin datos introducidos",
      );
      return res.status(401).json({
        mensaje: t.invalidCredentials,
      });
    }

    const usuario = rows[0];
    const passwordCorrecta = await bcrypt.compare(
      contrasena,
      usuario.contrasena
    );

    if (!passwordCorrecta) {
      logger.info("Intento de login fallido: contraseña incorrecta", { email });
      return res.status(401).json({ mensaje: t.invalidCredentials });
    }
    /*if (contrasena !== usuario.contrasena) {
      logger.info("Intento de login fallido: contraseña incorrecta", {
        email,
      });
      return res.status(401).json({ mensaje: "Credenciales incorrectas" });
    }*/

    // Generamos token JWT con el id del usuario
    const token = jwt.sign(
      { id: usuario.Id_usuario }, // payload
      process.env.JWT_SECRET, // clave secreta (debe estar en .env)
      { expiresIn: "24h" }, // duración del token
    );

    console.log("JWT generado:", token);

    if (logger.isDebugEnabled()) {
      logger.debug("Login exitoso", { email });
    }

    console.log("usuario.nombre: ", usuario.nombre);
    console.log("usuario.userName: ", usuario.email);

    // Respuesta exitosa con datos útiles para el frontend
    res.json({
      mensaje: t.loginSuccess,
      token,
      id: usuario.Id_usuario,
      userName: usuario.nombre,
      email: usuario.email,
    });
  } catch (err) {
    logger.error("Error de registro", { error: err.message });
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
  const t = getMessages(req);

  // Verificación básica de coincidencia de contraseñas
  if (data.contrasena !== data.contrasena2) {
    logger.info(
      "Fallo de registro: las contraseñas no coinciden a la hora de registrarse",
    );
    return res.status(400).json({
      mensaje: t.passwordsDontMatch,
    });
  }

  try {
    // 1. Verificar si ya existe un usuario con ese nombre
    const existe = await Usuario.existeUsuario(data.nombre);
    if (existe) {
      logger.info("Fallo de registro: usuario ya existe en la base de datos");
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

    if (logger.isDebugEnabled()) {
      logger.debug("Registro exitoso", { username });
    }

    // Respuesta exitosa
    res.json({
      mensaje: t.userCreated,
      id: idUsuario,
    });
  } catch (err) {
    logger.error("Error de registro", { err: err.message });
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
  const t = getMessages(req);

  try {
    const perfil = await Usuario.obtenerPerfil(id);

    if (!perfil) {
      logger.info("Error al obtener perfil: usuario no encontrado");
      return res.status(404).json({
        mensaje: t.userNotFound,
      });
    }

    res.json(perfil);
  } catch (err) {
    logger.error("Error al obtener perfil", { err: err.message });
    res.status(500).json({ err: err.message });
  }
};

// ────────────────────────────────────────────────
//               SUBIR FOTO DE PERFIL
// ────────────────────────────────────────────────
// Esta función:
// 1️. Recibe un ID de usuario por la URL
// 2️. Busca su imagen de perfil en la base de datos
// 3️. Devuelve la imagen como archivo (NO como JSON)
// 4️. Permite que Flutter la muestre con Image.network()



exports.obtenerFotoPerfil = async (req, res) => {
  
  //extraemos el id del usuario desde la URL
  const { id } = req.params;

  try {
    //ejecutamos una consulta a la base de daros 
    //buscamos la ultim foto subida por ese usuario
    const [rows] = await require("../config/db").query(
      `SELECT imagen 
       FROM usuario_imagen 
       WHERE Id_usuario = ? 
       ORDER BY creado_en DESC 
       LIMIT 1`,
      [id],//valor que sustituye el ?
    );
      // si el user no tiene imagen guardada mandamos un 404 para que flutter mandeicono por defecto
    if (rows.length === 0) {
      return res.status(404).send("Sin imagen");
    }

    //indicamos que la respuesta es una imagen JPEG
    //sin este header flutter no sabria como interpretar el contenido
    res.setHeader("Content-Type", "image/jpeg");

    //enviamos el contenido BLOB de la imagen
    //Express se encarga de enviarlo correctamente al cliente
    res.send(rows[0].imagen);
    //cualquier error que ocurra lo indicamos en consola
  } catch (error) {
    console.error("Error al obtener foto de perfil:", error);
    res.status(500).json({ error: error.message });
  }
};

// ────────────────────────────────────────────────
//               ACTUALIZAR PERFIL USUARIO
// ────────────────────────────────────────────────

/**
 * Endpoint: PUT /perfil/:id
 *
 * Actualiza el perfil completo del usuario (nombre, descripción, foto)
 *
 * Requiere autenticación (middleware auth)
 * Solo el usuario autenticado puede actualizar su propio perfil
 */
exports.actualizarPerfilUsuario = async (req, res) => {
  const { id } = req.params;
  const { nombre, descripcion, fotoPerfil } = req.body;  // Campos enviados por Flutter
  const t = getMessages(req);

  try {
    // Verifica que el usuario autenticado sea el mismo que se actualiza
    if (req.userId !== parseInt(id)) {
      logger.info("Intento de actualización no autorizado", { id, userId: req.userId });
      return res.status(403).json({ mensaje: t.notAuthorized });
    }

    // Actualiza usando el modelo
    const updatedUser = await Usuario.actualizarPerfil(id, { nombre, descripcion, fotoPerfil });

    if (!updatedUser) {
      logger.info("Usuario no encontrado para actualizar", { id });
      return res.status(404).json({ mensaje: t.userNotFound });
    }

    logger.info("Perfil actualizado exitosamente", { id });
    res.json(updatedUser);  // Devuelve el usuario actualizado
  } catch (err) {
    logger.error("Error al actualizar perfil", { err: err.message });
    res.status(500).json({ error: err.message });
  }
};
// FORGOT PASSWORD - Enviar código
exports.forgotPassword = async (req, res) => {
  const { email } = req.body;
  try {
    // Busca usuario por email en tabla 'usuario' (obtiene Id_usuario y email)
    const [rows] = await require("../config/db").query('SELECT Id_usuario, email FROM usuario WHERE email = ?', [email]);
    if (rows.length === 0) {
      return res.status(404).json({ mensaje: 'Usuario no encontrado' });
    }
    const userId = rows[0].Id_usuario;
    const userEmail = rows[0].email; // Lo usamos para el email, pero no lo guardamos en usuario_recuperacion

    // Genera código de 6 dígitos
    const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
    const expires = new Date(Date.now() + 10 * 60 * 1000); // Expira en 10 min

    // Inserta o actualiza en tabla 'usuario_recuperacion' (solo Id_usuario, reset_code, reset_expires)
    await require("../config/db").query(
      'INSERT INTO usuario_recuperacion (Id_usuario, reset_code, reset_expires) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE reset_code = VALUES(reset_code), reset_expires = VALUES(reset_expires)',
      [userId, resetCode, expires]
    );

    // Envía email (usa userEmail obtenido de usuario)
    const nodemailer = require('nodemailer');
    const transporter = nodemailer.createTransport({
      host: 'smtp.gmail.com',
  port: 587,
  secure: false,
  auth: { user: process.env.EMAIL_USER, pass: process.env.EMAIL_PASS },
  tls: { ciphers: 'SSLv3' },
  family: 4 // Fuerza IPv4 (agrega esta línea)
});
    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: userEmail, // Usa el email de la tabla usuario
      subject: 'Código de recuperación de contraseña',
      text: `Tu código de verificación es: ${resetCode}. Expira en 10 minutos.`,
    });

    logger.info(`Código enviado a ${userEmail}`);
    res.status(200).json({ mensaje: 'Código enviado' });
  } catch (error) {
    logger.error('Error en forgotPassword:', error);
    res.status(500).json({ mensaje: 'Error interno del servidor' });
  }
};

// VERIFY RESET CODE - Verificar código
exports.verifyResetCode = async (req, res) => {
  const { code } = req.body;
  try {
    const [rows] = await require("../config/db").query('SELECT Id_usuario FROM usuario_recuperacion WHERE reset_code = ? AND reset_expires > NOW()', [code]);
    if (rows.length === 0) {
      return res.status(400).json({ mensaje: 'Código inválido o expirado' });
    }

    // Genera token temporal (usa jsonwebtoken)
    const jwt = require('jsonwebtoken');
    const resetToken = jwt.sign({ userId: rows[0].Id_usuario }, process.env.JWT_SECRET, { expiresIn: '15m' });

    logger.info(`Código verificado para usuario ${rows[0].Id_usuario}`);
    res.status(200).json({ resetToken });
  } catch (error) {
    logger.error('Error en verifyResetCode:', error);
    res.status(500).json({ mensaje: 'Error interno del servidor' });
  }
};

// RESET PASSWORD - Cambiar contraseña
exports.resetPassword = async (req, res) => {
  const { resetToken, newPassword } = req.body;
  try {
    const jwt = require('jsonwebtoken');
    const decoded = jwt.verify(resetToken, process.env.JWT_SECRET);
    const bcrypt = require('bcrypt');

    // Hash nueva contraseña
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Actualiza contraseña en tabla 'usuario'
    await require("../config/db").query('UPDATE usuario SET contrasena = ? WHERE Id_usuario = ?', [hashedPassword, decoded.userId]);

    // Limpia código en tabla 'usuario_recuperacion'
    await require("../config/db").query('UPDATE usuario_recuperacion SET reset_code = NULL, reset_expires = NULL WHERE Id_usuario = ?', [decoded.userId]);

    logger.info(`Contraseña reseteada para usuario ${decoded.userId}`);
    res.status(200).json({ mensaje: 'Contraseña cambiada exitosamente' });
  } catch (error) {
    logger.error('Error en resetPassword:', error);
    res.status(400).json({ mensaje: 'Token inválido o expirado' });
  }
};

module.exports = exports;


