const multer = require("multer");
const path = require("path");

// Guardar en memoria (porque lo metes en la BD)
const storage = multer.memoryStorage();

const upload = multer({
  storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
  },
});

module.exports = upload;
