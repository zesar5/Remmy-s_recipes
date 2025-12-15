const jwt = require("jsonwebtoken");

module.exports = function (req, res, next){
    const token = req.headers["authorization"];

    if(!token){
        return res.status(401).json({ mensaje: "Debes iniciar sesión"});
    }

    try{
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            const userId = decoded.id;
            req.userId=decoded.id;
            next();
    } catch{
        return res.status(401).json({ mensaje: "Token inválido" });
    }
}