// server.js
const express = require("express");
const bodyParser = require("body-parser");
const multer = require("multer");
const { v4: uuidv4 } = require("uuid");
const path = require("path");
const fs = require("fs");

const app = express();
const PORT = 8000;

// Middleware
app.use(bodyParser.json());
app.use("/images", express.static(path.join(__dirname, "images")));

// ---------------------
// BASE DE DATOS SIMULADA
// ---------------------
const usuariosDB = [];
const recetasDB = [];
let usuarioActual = null;

// ---------------------
// MODELOS
// ---------------------
class Usuario {
    constructor({ nombreUsuario, email, contrasena, primerApellido, segundoApellido, descripcion, anioNacimiento, rol }) {
        this.id = uuidv4();
        this.nombreUsuario = nombreUsuario;
        this.email = email;
        this.contrasena = contrasena;
        this.primerApellido = primerApellido || null;
        this.segundoApellido = segundoApellido || null;
        this.descripcion = descripcion || null;
        this.anioNacimiento = anioNacimiento || null;
        this.rol = rol || "usuario";
    }
}

class Receta {
    constructor({ titulo, descripcion, tiempoPreparacion, porciones, dificultad, idUsuario, imagen, categoria }) {
        this.id = uuidv4();
        this.titulo = titulo;
        this.descripcion = descripcion || null;
        this.tiempoPreparacion = tiempoPreparacion || null;
        this.porciones = porciones || null;
        this.dificultad = dificultad || null;
        this.fechaCreacion = new Date();
        this.idUsuario = idUsuario;
        this.imagen = imagen || null;
        this.categoria = categoria || null;
    }
}

// ---------------------
// RUTAS AUTH
// ---------------------
app.post("/auth/login", (req, res) => {
    const { nombreUsuario, contrasena } = req.body;
    const user = usuariosDB.find(u => u.nombreUsuario === username && u.contrasena === password);
    if (!user) return res.status(400).json({ mensaje: "Credenciales incorrectas" });

    usuarioActual = user;
    res.json({ mensaje: "Login correcto", usuario: user });
});

// ---------------------
// RUTAS USUARIOS
// ---------------------
app.post("/registro", (req, res) => {
    const data = req.body;

    if (usuariosDB.find(u => u.nombreUsuario === data.nombreUsuario)) {
        return res.status(400).json({ mensaje: "El usuario ya existe" });
    }
    if (data.contrasena !== data.contrasena2) {
    return res.status(400).json({ mensaje: "Las contraseñas no coinciden" });
    }

    const nuevoUsuario = new Usuario({
        nombreUsuario: data.nombreUsuario,
        email: data.email,
        contrasena: data.contrasena,
        primerApellido: data.primerApellido,
        segundoApellido: data.segundoApellido,
        descripcion: data.descripcion,
        anioNacimiento: data.añoNacimiento,
        rol: data.rol
    });

    usuariosDB.push(nuevoUsuario);
    res.json(nuevoUsuario);
});

app.get("/perfil", (req, res) => {
    if (!usuarioActual) return res.status(401).json({ mensaje: "No has iniciado sesión" });
    res.json(usuarioActual);
});

// ---------------------
// RUTAS RECETAS
// ---------------------
app.get("/recetas", (req, res) => {
    res.json(recetasDB);
});

app.get("/recetas/:id", (req, res) => {
    const receta = recetasDB.find(r => r.id === req.params.id);
    if (!receta) return res.status(404).json({ mensaje: "Receta no encontrada" });
    res.json(receta);
});

app.post("/recetas", (req, res) => {
    if (!usuarioActual) return res.status(401).json({ mensaje: "Debes iniciar sesión" });

    const data = req.body;
    const nuevaReceta = new Receta({ ...data, idUsuario: usuarioActual.id });
    recetasDB.push(nuevaReceta);
    res.json(nuevaReceta);
});

app.put("/recetas/:id", (req, res) => {
    const receta = recetasDB.find(r => r.id === req.params.id);
    if (!receta) return res.status(404).json({ mensaje: "Receta no encontrada" });

    Object.assign(receta, req.body);
    res.json(receta);
});

app.delete("/recetas/:id", (req, res) => {
    const index = recetasDB.findIndex(r => r.id === req.params.id);
    if (index === -1) return res.status(404).json({ mensaje: "Receta no encontrada" });

    recetasDB.splice(index, 1);
    res.json({ mensaje: "Receta eliminada" });
});

// ---------------------
// SUBIDA DE IMÁGENES
// ---------------------
const upload = multer({ dest: "images/" });

app.post("/upload/image", upload.single("image"), (req, res) => {
    if (!req.file) return res.status(400).json({ mensaje: "No se subió ningún archivo" });

    // Renombrar archivo a nombre original
    const targetPath = path.join("images", req.file.originalname);
    fs.renameSync(req.file.path, targetPath);

    res.json({ url: `/images/${req.file.originalname}` });
});

// ---------------------
// INICIO
// ---------------------
app.get("/", (req, res) => {
    res.json({ mensaje: "API funcionando", usuarios: usuariosDB.length, recetas: recetasDB.length });
});

// ---------------------
// INICIAR SERVIDOR
// ---------------------
app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
