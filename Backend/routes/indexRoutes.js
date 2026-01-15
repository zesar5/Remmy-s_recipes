const express = require("express");
const router = express.Router();
const getMessages = require("../i18n");

// ---------------------
// INICIO
// ---------------------
router.get("/", (req, res) => {
    res.json({mensaje: t.apiRunning });
});

module.exports = router;