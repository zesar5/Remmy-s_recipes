const express = require("express");
const router = express.Router();
const usuarioController = require("../controllers/usuarioController");

// LOGIN
router.post("/login", usuarioController.loginUsuario);

// REGISTRO
router.post("/registro", usuarioController.registrarUsuario);

// PERFIL (SIN auth de momento)
router.get("/perfil/:id", usuarioController.obtenerPerfil);

// FOTO DE PERFIL
router.get("/foto/:id", usuarioController.obtenerFotoPerfil);

module.exports = router;
