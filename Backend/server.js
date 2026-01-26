// Server.js
const express = require("express");
const cors = require("cors");
const app = express();
const PORT = 8000;
const https = require("https");
const fs = require("fs");
const path = require("path");
const logger = require("./logger.js");
require("dotenv").config();

const usuarioRoutes = require("./routes/usuarioRoutes");

app.use(usuarioRoutes);
/*// Opciones SSL
const sslOptions = {
  key: fs.readFileSync(path.join(__dirname, 'key.pem')),
  cert: fs.readFileSync(path.join(__dirname, 'cert.pem'))
};

// Cambia app.listen por https.createServer
const server = https.createServer(sslOptions, app);
server.listen(PORT, () => {
  console.log(`Servidor HTTPS corriendo en https://localhost:${PORT}`);
  logger.info('Mensaje informativo', `Servidor seguro corriendo en https://localhost:${PORT}`);
});*/

// Middleware global
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ limit: "10mb", extended: true }));
app.use(cors());
app.use("/uploads", express.static("uploads"));
// Rutas
app.use("/", require("./routes/indexRoutes"));
app.use("/usuarios", require("./routes/usuarioRoutes"));
app.use("/recetas", require("./routes/recetaRoutes"));

// Iniciar servidor
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
  logger.info(
    "Mensaje informativo",
    `Servidor seguro corriendo en https://localhost:${PORT}`,
  );
});
