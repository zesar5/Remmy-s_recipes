// server.js
const express = require("express");
const bodyParser = require("body-parser");
const multer = require("multer");
const { v4: uuidv4 } = require("uuid");
const path = require("path");
const fs = require("fs");
const mysql = require("mysql2/promise");

const app = express();
const PORT = 8000;
const db = mysql.createPool({
    host: "localhost",
    user: "root",
    password: "",
    database: "remysrecipes"
});

// Middleware
app.use(bodyParser.json());
app.use("/images", express.static(path.join(__dirname, "images")));


// ---------------------
// RUTAS AUTH
// ---------------------
app.post("/auth/login", async (req, res) => {
    const { nombreUsuario, contrasena } = req.body;
    try{
        const [rows] = await db.query(
            "SELECT * FROM Usuario WHERE nombre = ? AND contraseña = ?",
            [nombreUsuario, contrasena]
        );

        if(rows.length === 0){
            return res.status(400).json({mensaje: "Credenciales incorrectas"});
        }

        const usuario = rows[0];

        res.json({mensaje: "Login correcto", usuario});
    }catch(err){
        res.status(500).json({ error: err.message});
    }
});

// ---------------------
// RUTAS USUARIOS
// ---------------------
app.post("/registro", async (req, res) => {
    const data = req.body;

    if(data.contrasena !== data.contrasena2){
        return res.status(400).json({ mensaje: "Las credenciales no coinciden"});
    }
    try{
        const [exists] = await db.query(
            "SELECT * FROM Usuario WHERE nombre = ?",
            [data.nombreUsuario]
        );

        if(exists.length > 0){
            return res.status(400).json({ mensaje: "El usuario ya existe"});
        }

        const [result] = await db.query(
            `INSERT INTO Usuario (nombre, email, contraseña, fecha_registro) 
             VALUES (?, ?, ?, NOW())`,
            [data.nombreUsuario, data.email, data.contrasena]
        );

        res.json({ mensaje: "Usuario creado", id: result.insertId});
    } catch(err){
        res.status(500).json({ error: err.message })
    }
});


app.get("/perfil", async (req, res) => {
    const { id } = req.params;

    try {
        const [rows] = await db.query(
            "SELECT * FROM Usuario WHERE Id_usuario = ?",
            [id]
        );

        if (rows.length === 0) {
            return res.status(404).json({ mensaje: "Usuario no encontrado" });
        }

        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ---------------------
// RUTAS RECETAS
// ---------------------
app.get("/recetas", async (req, res) => {
   try{
    const [rows] = await db.query("SELECT * FROM Receta")
    res.json(rows);
   } catch(err){
    res.status(500).json({ error: err.message});
   }
});

app.get("/recetas/:id", async (req, res) => {
    try{
        const [rows] = await db.query(
            "SELECT * FROM Receta WHERE Id_receta = ?",
            [req.params.id]
        );

        if(rows.length === 0){
            return res.status(404).json({ mensaje: "Receta no encontrada"});
        }

        res.json(rows[0]);
    } catch(err){
        res.status(500).json({ error: err.message})
    }
});

app.post("/recetas", async (req, res) => {
    const data = req.body;

    if(!data.idUsuario){
        return res.status(401).json({ mensaje: "Debes iniciar sesión"});
    }

    try{
        const [result] = await db.query(
            `INSERT INTO Receta 
            (titulo, descripcion, tiempo_preparacion, porciones, dificultad, Id_usuario) 
            VALUES (?, ?, ?, ?, ?, ?)`,
            [
                data.titulo,
                data.descripcion,
                data.tiempoPreparacion,
                data.porciones,
                data.dificultad,
                data.idUsuario
            ]
        );

        res.json({ mensaje: "Receta creada", id: result.insertId});
    } catch(err){
        res.status(500).json({ mensaje: err.message});
    }
});

app.put("/recetas/:id", async (req, res) => {
    try{
        await db.query(
            "UPDATE Receta SET ? WHERE Id_receta = ?",
            [req.body, req.params.id]
        );

        res.json({ mensaje: "Receta actualizada"});
    } catch(err){
        res.status(500).json({ error: err.message });
    }
});

app.delete("/recetas/:id", async (req, res) => {
    try{
        await db.query(
            "DELETE FROM Receta WHERE Id_receta = ?",
            [req.params.id]
        );

        res.json({ mensaje: "Receta eliminada" });
    } catch(err){
        res.status(500).json({ error: err.message });
    }
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
