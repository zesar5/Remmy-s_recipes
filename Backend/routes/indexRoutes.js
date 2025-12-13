const express = require("express");
const router = express.Router();

// ---------------------
// INICIO
// ---------------------
router.get("/", (req, res) => {
    res.json({ mensaje: "API funcionando" });
});

module.exports = router;