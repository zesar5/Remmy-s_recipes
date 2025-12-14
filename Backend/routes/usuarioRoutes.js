const express = require("express");
const router = express.Router();

const usuarioController = require("../controllers/usuarioController");

router.post("/login", usuarioController.loginUsuario);
router.post("/registro", usuarioController.registrarUsuario);
router.get("/perfil/:id", usuarioController.obtenerPerfil);

module.exports = router;