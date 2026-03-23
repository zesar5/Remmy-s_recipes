const express = require("express");
const router = express.Router();
const auth = require("../middlewares/authMiddleware");
const authOpcional = require("../middlewares/authOpcional");
const recetaController = require("../controllers/recetaController");
const { RecetaEntity, RecetaModel, FavoritoModel } = require("../models/receta");
console.log("🔍 DEBUG: FavoritoModel =", FavoritoModel);
console.log("🔍 DEBUG: FavoritoModel.esFavorito =", typeof FavoritoModel.esFavorito);
console.log("🔍 DEBUG: FavoritoModel.anadirFavorito =", typeof FavoritoModel.anadirFavorito);

// =====================================================
//                  RUTAS DE FAVORITOS
// =====================================================

/**
 * GET /recetas/favoritos
 * Obtiene todas las recetas favoritas del usuario
 */
router.get("/favoritos", auth, async (req, res) => {
  try {
    console.log("🚀 Obteniendo favoritos para usuario:", req.userId);
    const favoritos = await FavoritoModel.obtenerFavoritosPorUsuario(req.userId);
    console.log("✅ Favoritos obtenidos:", favoritos.length);
    res.json(favoritos);
  } catch (err) {
    console.error("❌ Error al obtener favoritos:", err);
    res.status(500).json({ mensaje: err.message });
  }
});

/**
 * POST /recetas/favoritos/:recetaId
 * Añade una receta a favoritos
 */
router.post("/favoritos/:recetaId", auth, async (req, res) => {
  try {
    const recetaId = parseInt(req.params.recetaId);
    console.log("⭐ Añadiendo a favoritos - Usuario:", req.userId, "Receta:", recetaId);

    const resultado = await FavoritoModel.anadirFavorito(req.userId, recetaId);

    if (resultado) {
      res.json({ mensaje: 'Receta añadida a favoritos' });
    } else {
      res.status(400).json({ mensaje: 'La receta ya está en favoritos' });
    }
  } catch (err) {
    console.error("❌ Error al añadir favorito:", err);
    res.status(500).json({ mensaje: err.message });
  }
});

/**
 * DELETE /recetas/favoritos/:recetaId
 * Elimina una receta de favoritos
 */
router.delete("/favoritos/:recetaId", auth, async (req, res) => {
  try {
    const recetaId = parseInt(req.params.recetaId);
    console.log("💔 Eliminando de favoritos - Usuario:", req.userId, "Receta:", recetaId);

    await FavoritoModel.eliminarFavorito(req.userId, recetaId);
    res.json({ mensaje: 'Receta eliminada de favoritos' });
  } catch (err) {
    console.error("❌ Error al eliminar favorito:", err);
    res.status(500).json({ mensaje: err.message });
  }
});

/**
 * GET /recetas/favoritos/:recetaId/check
 * Verifica si una receta está en favoritos
 */
router.get("/favoritos/:recetaId/check", auth, async (req, res) => {
  try {
    const recetaId = parseInt(req.params.recetaId);
    const esFavorito = await FavoritoModel.esFavorito(req.userId, recetaId);
    res.json({ esFavorito });
  } catch (err) {
    console.error("❌ Error al verificar favorito:", err);
    res.status(500).json({ mensaje: err.message });
  }
});

/**
 * POST /recetas/favoritos/:recetaId/toggle
 * Toggle: añade si no existe, elimina si existe
 */
router.post("/favoritos/:recetaId/toggle", auth, async (req, res) => {
  try {
    const recetaId = parseInt(req.params.recetaId);
    console.log("🔄 Toggle favorito - Usuario:", req.userId, "Receta:", recetaId);

    const resultado = await FavoritoModel.toggleFavorito(req.userId, recetaId);
    
    res.json({
      esFavorito: resultado.esFavorito,
      mensaje: resultado.accion === 'añadido' 
        ? 'Receta añadida a favoritos' 
        : 'Receta eliminada de favoritos'
    });
  } catch (err) {
    console.error("❌ Error en toggle favorito:", err);
    res.status(500).json({ mensaje: err.message });
  }
});
//Las rutas CRUD
router.get("/usuario/:userId", auth, recetaController.obtenerRecetaUsuario);
router.get("/publicas", recetaController.obtenerRecetasPublicas);
router.get("/publicas/:id", recetaController.obtenerRecetaPublicaPorId);
router.post("/filtrar", authOpcional, recetaController.obtenerRecetasFiltradas);
router.get("/:id", auth, recetaController.obtenerRecetaPorId);
router.get('/', recetaController.getRecetas);
router.post("/", auth, recetaController.crearReceta);
router.put("/:id", auth, recetaController.actualizarReceta);
router.delete("/:id", auth, recetaController.eliminarReceta);



module.exports = router;