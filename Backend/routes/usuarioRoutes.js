const express = require("express");
const router = express.Router();
const authMiddleware = require("../middlewares/authMiddleware");

const usuarioController = require("../controllers/usuarioController");

router.post("/login", usuarioController.loginUsuario);
router.post("/registro", usuarioController.registrarUsuario);
router.get("/perfil/:id",authMiddleware, usuarioController.obtenerPerfil);

module.exports = router;