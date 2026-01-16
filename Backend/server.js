// Server.js
const express = require("express");
const cors = require('cors');
const app = express();
const PORT = 8000;
require("dotenv").config();

// Middleware global
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));
app.use(cors());

// Rutas
app.use("/", require("./routes/indexRoutes"));
app.use("/usuarios", require("./routes/usuarioRoutes"));
app.use("/recetas", require("./routes/recetaRoutes"));

// Iniciar servidor
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
