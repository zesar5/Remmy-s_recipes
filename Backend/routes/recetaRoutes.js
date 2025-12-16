const express = require("express");
const router = express.Router();
const auth = require("../middlewares/authMiddleware");
const recetaController = require("../controllers/recetaController");
const authMiddleware = require("../middlewares/authMiddleware");

//Las rutas CRUD
router.get("/home", recetaController.obtenerRecetaVisibles);
router.get('/', recetaController.getRecetas);
router.get("/:id", recetaController.obtenerRecetaPorId);
router.post("/", auth, recetaController.crearReceta);
router.put("/:id", auth, recetaController.actualizarReceta);
router.delete("/:id", auth, recetaController.eliminarReceta);

//Obtener recetas de un usuario específico (para perfil)
router.get("/usuario/:userId", authMiddleware, recetaController.obtenerRecetasPorUsuario);

module.exports = router;