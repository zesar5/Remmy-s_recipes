const express = require("express");
const router = express.Router();

// ---------------------
// INICIO
// ---------------------
app.get("/", (req, res) => {
    res.json({ mensaje: "API funcionando" });
});

module.exports = router;