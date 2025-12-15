const jwt = require("jsonwebtoken");

module.exports = function (req, res, next){
    const authHeader = req.headers["authorization"];

    if(!authHeader){
        return res.status(401).json({ mensaje: "Debes iniciar sesión"});
    }

    const token = authHeader.split(" ")[1];
    if (!token) {
    return res.status(401).json({ mensaje: "Token no proporcionado" });
    }

    try{
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.userId = decoded.id;
        next();
    } catch{
        return res.status(401).json({ mensaje: "Token inválido" });
    }
}