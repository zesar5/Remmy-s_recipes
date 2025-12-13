// Server.js
const express = require("express");
const cors = require('cors');
const app = express();
const PORT = 8000;

// Middleware global
app.use(express.json());
app.use(cors());

// Rutas
app.use("/", require("./routes/indexRoutes"));
app.use("/auth", require("./routes/authRoutes"));
app.use("/usuarios", require("./routes/usuarioRoutes"));
app.use("/recetas", require("./routes/recetaRoutes"));

// Iniciar servidor
app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
