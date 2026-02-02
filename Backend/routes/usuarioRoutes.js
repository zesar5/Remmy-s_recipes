const express = require("express");
const router = express.Router();
const usuarioController = require("../controllers/usuarioController");
const auth = require("../middlewares/authMiddleware");
const upload = require("../middlewares/upload");
const db = require("../config/db");

// LOGIN
router.post("/login", usuarioController.loginUsuario);

// REGISTRO
router.post("/registro", usuarioController.registrarUsuario);

// PERFIL
router.get("/perfil/:id", usuarioController.obtenerPerfil);

// OBTENER FOTO
router.get("/foto/:id", usuarioController.obtenerFotoPerfil);

// SUBIR FOTO DE PERFIL
router.post(
  "/foto/:id",
  /* MIDDLEWARE DE AUTENTICACIÓN
   - Lee el token del header Authorization
  - Verifica que sea válido
   - Extrae el ID del usuario
  - Lo guarda en: req.userId*/
  auth,
  //MIDDLEWARE DE MULTER
  //espera el archivo, lo guarda en la RAM
  //el archivo estara disponible como:req.file
  upload.single("profilePic"),
  async (req, res) => {
    try {
//ID REAL DEL USUARIO
// viene del token JWT
 //lo que hace esque extrae el id y lo guarda en req.userId
 //para que no se hagan un lio entre los usuarios
      const userId = req.userId; 
        
      //log utiles para la depuracion
      console.log("FILE:", req.file);
      console.log("USER ID TOKEN:", userId);


      //en caso de que no se envio ningun archivo
      if (!req.file) {
        return res.status(400).json({ message: "No se envió imagen" });
      }
//guardamos la imagen en la base de datos
      await db.query(
        `INSERT INTO usuario_imagen (Id_usuario, imagen)
         VALUES (?, ?)
         ON DUPLICATE KEY UPDATE imagen = VALUES(imagen)`,
        [userId, req.file.buffer],
      );
//en caso de que todo haya ido bien
      res.json({ ok: true });

    } catch (error) {
        //capturamos cualquier error
      console.error("❌ Error subiendo foto:", error);
      res.status(500).json({ message: "Error subiendo imagen" });
    }
  },
);
router.put("/perfil/:id", auth, usuarioController.actualizarPerfilUsuario);
module.exports = router;
