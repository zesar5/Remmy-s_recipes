const express = require("express");
const router = express.Router();
const getMessages = require("../i18n");

// ---------------------
// INICIO
// ---------------------
router.get("/", (req, res) => {
    const messages = getMessages(req);
    res.json({mensaje: messages.apiRunning });
});

module.exports = router;