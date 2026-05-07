const { RecetaModel } = require("../models/receta");
const getMessages = require("../i18n");
const logger = require('../logger');

// Importamos el modelo que contiene todos los métodos que hablan directamente con la base de datos

// ────────────────────────────────────────────────
//    ENDPOINTS PÚBLICOS (cualquiera puede verlas)
// ────────────────────────────────────────────────

/**
 * Devuelve TODAS las recetas que están marcadas como públicas
 * Se usa normalmente en la página principal o sección de exploración
 */
exports.obtenerRecetasPublicas = async (req, res) => {
  try {
    const recetas = await RecetaModel.obtenerVisibles();
    res.json(recetas); // 200 OK por defecto
  } catch (err) {
    logger.error('Error al obtener recetas publicas', {err: err.message});
    res.status(500).json({ error: err.message });
  }
};

/**
 * Obtiene una SOLA receta pública por su id
 * Reglas:
 * - Si no existe → 404
 * - Si existe pero es privada → 403
 * - Si es pública → devuelve la receta completa
 */
exports.obtenerRecetaPublicaPorId = async (req, res) => {
  try {
    const t = getMessages(req);
    console.log("🔎 obtenerRecetaPublicaPorId ID:", req.params.id);

    const receta = await RecetaModel.obtenerPorId(req.params.id);

    if (!receta) {
      logger.error('Error al obtener recetas publica');
      console.log("⚠️ Receta no encontrada");
      return res.status(404).json({ mensaje: t.recipeNotFound });
    }

    if (!receta.publica) {
      logger.error('Error al obtener receta por ser privada');
      console.log("⚠️ Receta privada");
      return res.status(403).json({ mensaje: t.recipePrivate });
    }

    console.log("✅ Receta pública encontrada:", receta.titulo);
    console.log("Datos de la receta ", receta);
    res.json(receta);
  } catch (err) {
    logger.error('Error al obtener recetas publicas por id', {err: err.message});
    console.log("🔥 ERROR obtenerRecetaPublicaPorId:", err);
    res.status(500).json({ error: err.message });
  }
};

// ────────────────────────────────────────────────
//      ENDPOINTS PARA LA HOME / Paginación simple
// ────────────────────────────────────────────────

/**
 * Versión muy simple de paginación por rango de ids
 * (normalmente usada para la home o carrusel inicial)
 * Ejemplo: ?rangoInicio=1&rangoFin=6  → recetas 1 a 6
 */
exports.getRecetas = async (req, res) => {
  try {
    const t = getMessages(req);
    const rangoInicio = parseInt(req.query.rangoInicio) || 1;
    const rangoFin = parseInt(req.query.rangoFin) || 6;

    const recetas = await RecetaModel.getByRange(rangoInicio, rangoFin);

    res.status(200).json(recetas);
  } catch (err) {
    logger.error('Error al obtener recetas', { err: err.message });
    res.status(500).json({
      message: t.errorFetchingRecipes,
      error: err.message,
    });
  }
};

// ────────────────────────────────────────────────
//      OBTENER RECETA (con control de permisos)
// ────────────────────────────────────────────────

/**
 * Obtiene una receta por id con estas reglas de visibilidad:
 *
 * 1. Si la receta es pública        → cualquiera la ve
 * 2. Si la receta es privada        → solo el dueño la ve
 * 3. Si no existe                   → 404
 * 4. Si intenta ver receta privada ajena → 403
 */
exports.obtenerRecetaPorId = async (req, res) => {
  try {
    const t = getMessages(req);
    console.log("🚀 ENTRÓ A obtenerRecetaPorId");
    console.log("📌 req.params.id:", req.params.id);
    console.log("📌 req.userId:", req.userId);

    const receta = await RecetaModel.obtenerPorId(req.params.id);
    console.log("📦 Receta obtenida de DB:", receta);

    if (!receta){
      logger.error('Error al obtener recetas: receta no encontrada');
      return res.status(404).json({ mensaje: t.recipeNotFound });
    }

    // Regla clave de privacidad
    if (!receta.publica && receta.usuarioId !== req.userId) {
      logger.error('Error por ser receta privada');
      console.log("⚠️ Acceso denegado");
      return res
        .status(403)
        .json({ mensaje: t.noPermissionView });
    }

    console.log("✅ Respondiendo con receta");
    res.json(receta);
  } catch (err) {
    logger.error('Error al obtener receta por id: ', { err: err.message });
    console.log("🔥 ERROR:", err);
    res.status(500).json({ err: err.message });
  }
};

// ────────────────────────────────────────────────
//               CRUD PROTEGIDO (solo propietario)
// ────────────────────────────────────────────────

/**
 * Crea una nueva receta
 * El usuarioId viene del token JWT (req.userId)
 */
exports.crearReceta = async (req, res) => {
  try {
    const t = getMessages(req);
    console.log("REQ.BODY:", req.body);
    console.log("Tipo de req.body:", typeof req.body);
    console.log("Tamaño de la imagen:", req.body.imagen?.length);

    if (req.file) {
      req.body.imagen = `/uploads/recetas/${req.file.filename}`;
    }

    // Parsear campos JSON que llegan como strings desde Flutter
    if (req.body.pasos && typeof req.body.pasos === 'string') {
      req.body.pasos = JSON.parse(req.body.pasos);
    }
    if (req.body.ingredientes && typeof req.body.ingredientes === 'string') {
      req.body.ingredientes = JSON.parse(req.body.ingredientes);
    }

    const id = await RecetaModel.crear(req.body, req.userId);

    res.status(200).json({
      mensaje: t.recipeCreated,
      id,
    });
  } catch (err) {
    logger.error('Error al crear una receta: ', { err: err.message });
    res.status(500).json({ mensaje: err.message });
  }
};

/**
 * Actualiza una receta existente
 * Solo puede hacerlo el propietario
 */
exports.actualizarReceta = async (req, res) => {
  try {
    const t = getMessages(req);
    const esPropietario = await RecetaModel.verificarPropietario(
      req.params.id,
      req.userId
    );

    if (esPropietario === null){
      logger.error('Error al editar receta: receta no encontrada');
      return res.status(404).json({ mensaje: t.recipeNotFound });
    }

    if (!esPropietario){
      logger.error('Error al editar receta: no es creador de ella');
      return res
        .status(403)
        .json({ mensaje: t.noPermissionEdit });
    }

    if (req.file) {
      req.body.imagen = `/uploads/recetas/${req.file.filename}`;
    }

    // Parsear campos JSON que llegan como strings desde Flutter
    if (req.body.pasos && typeof req.body.pasos === 'string') {
      req.body.pasos = JSON.parse(req.body.pasos);
    }
    if (req.body.ingredientes && typeof req.body.ingredientes === 'string') {
      req.body.ingredientes = JSON.parse(req.body.ingredientes);
    }

    await RecetaModel.actualizar(req.params.id, req.body);

    res.json({ mensaje: t.recipeUpdated });
  } catch (err) {
    logger.error('Error al actualizar receta: ', { err: err.message });
    res.status(500).json({ error: err.message });
  }
};

/**
 * Actualiza solo la privacidad de una receta
 * Solo el propietario puede hacerlo
 */
exports.actualizarPrivacidadReceta = async (req, res) => {
  try {
    const t = getMessages(req);
    const esPropietario = await RecetaModel.verificarPropietario(
      req.params.id,
      req.userId
    );

    if (esPropietario === null){
      logger.error('Error al cambiar privacidad: receta no encontrada');
      return res.status(404).json({ mensaje: t.recipeNotFound });
    }

    if (!esPropietario){
      logger.error('Error al cambiar privacidad: no es creador de la receta');
      return res
        .status(403)
        .json({ mensaje: t.noPermissionEdit });
    }

    const publica = req.body.publica === 1 || req.body.publica === true;
    await RecetaModel.actualizarPrivacidad(req.params.id, publica);

    res.json({ mensaje: publica ? 'Receta ahora es pública' : 'Receta ahora es privada' });
  } catch (err) {
    logger.error('Error al actualizar privacidad de receta: ', { err: err.message });
    res.status(500).json({ error: err.message });
  }
};

/**
 * Elimina una receta
 * Solo el propietario puede hacerlo
 */
exports.eliminarReceta = async (req, res) => {
  try {
    const t = getMessages(req);
    const esPropietario = await RecetaModel.verificarPropietario(
      req.params.id,
      req.userId
    );

    if (esPropietario === null){
      logger.error('Error al eliminar receta: receta no encontrada');
      return res.status(404).json({ mensaje: t.recipeNotFound });
    }

    if (!esPropietario){
      logger.error('Error al eliminar receta: no es creador de ella');
      return res
        .status(403)
        .json({ mensaje: t.noPermissionDelete });
    }

    await RecetaModel.eliminar(req.params.id);

    res.json({ mensaje: t.recipeDeleted });
  } catch (err) {
    logger.error('Error al eliminar receta: ', { err: err.message });
    res.status(500).json({ error: err.message });
  }
};

// ────────────────────────────────────────────────
//    RECETAS DE UN USUARIO EN PARTICULAR (perfil)
// ────────────────────────────────────────────────

/**
 * Devuelve todas las recetas (públicas + privadas) de un usuario concreto
 * Se usa normalmente en la vista de perfil del usuario
 */
exports.obtenerRecetaUsuario = async (req, res) => {
  console.log("🚀 ENTRÓ A /recetas/usuario/:userId");
  console.log("📌 PARAM userId:", req.params.userId);
  console.log("📌 req.userId (token):", req.userId);

  try {
    const userId = req.params.userId;
    const recetas = await RecetaModel.obtenerPorUsuario(userId);

    console.log("📦 RECETAS BD:", recetas.length);
    console.log(recetas);

    res.json(recetas);
  } catch (err) {
    logger.error('Error al obtener receta de usuario: ', { err: err.message });
    console.log("🔥 ERROR CONTROLLER:", err);
    res.status(500).json({ error: err.message });
  }
};

exports.obtenerRecetasFiltradas = async (req, res) => {
  try{
    const filtros = req.body;

    //Si el usuario está autenticado, añadimos su id
    if (req.user?.id) {
      filtros.userId = req.user.id;
    }

    if (filtros.alergenos && typeof filtros.alergenos === 'string') {
      filtros.alergenos = filtros.alergenos.split(',').map(a => a.trim());
    }

    const recetas = await RecetaModel.recetasFiltradas(filtros);

    res.status(200).json(recetas);
    }catch(err){
      console.error("❌ Error al obtener recetas filtradas:", err);
      res.status(500).json({
        error: err.message
      });
    }
};