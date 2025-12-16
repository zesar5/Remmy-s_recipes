const express = require("express");
const router = express.Router();
const auth = require("../middlewares/authMiddleware");
const recetaController = require("../controllers/recetaController");

//Las rutas CRUD
router.get("/usuario/:userId", auth, recetaController.obtenerRecetaUsuario);
router.get("/publicas", recetaController.obtenerRecetasPublicas);
router.get("/publicas/:id", recetaController.obtenerRecetaPublicaPorId);
router.get("/:id", auth, recetaController.obtenerRecetaPorId);
router.get('/', recetaController.getRecetas);
router.post("/", auth, recetaController.crearReceta);
router.put("/:id", auth, recetaController.actualizarReceta);
router.delete("/:id", auth, recetaController.eliminarReceta);


module.exports = router;