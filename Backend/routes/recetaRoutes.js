const express = require("express");
const router = express.Router();
const auth = require("../middlewares/authMiddleware");
const recetaController = require("../controllers/recetaController");

//Las rutas CRUD
router.get("/home", recetaController.obtenerRecetaVisibles);
router.get('/', recetaController.getRecetas);
router.get("/:id", recetaController.obtenerRecetaPorId);
router.post("/", auth, recetaController.crearReceta);
router.put("/:id", auth, recetaController.actualizarReceta);
router.delete("/:id", auth, recetaController.eliminarReceta);


module.exports = router;