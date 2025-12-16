const jwt = require("jsonwebtoken");

module.exports = function (req, res, next){
    console.log("🔐 AUTH MIDDLEWARE");
    console.log("📌 HEADER AUTH:", req.headers.authorization);

    const authHeader = req.headers["authorization"];

    if(!authHeader){
        console.log("❌ NO HAY TOKEN");
        return res.status(401).json({ mensaje: "Debes iniciar sesión"});
    }

    const token = authHeader.split(" ")[1];
    console.log("🪪 TOKEN EXTRAÍDO:", token);
    if (!token) {
    return res.status(401).json({ mensaje: "Token no proporcionado" });
    }

    try{
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        console.log("✅ TOKEN OK, USER ID:", decoded.id);
        req.userId = decoded.id;
        next();
    } catch{
        console.log("❌ TOKEN INVÁLIDO");
        return res.status(401).json({ mensaje: "Token inválido" });
    }
}