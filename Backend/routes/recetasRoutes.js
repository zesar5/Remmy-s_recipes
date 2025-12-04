const express = require("express");
const router = express.Router();
const auth = require("../middlewares/authMiddleware");
const recetaController = require("../controllers/recetaController");

//Las rutas CRUD
router.get("/", recetaController.obtenerRecetas);
router.get("/:id", recetaController.obtenerRecetaPorId);
router.post("/", auth, recetaController.crearReceta);
router.put("/:id", recetaController.actualizarReceta);
router.delete("/:id", recetaController.eliminarReceta);