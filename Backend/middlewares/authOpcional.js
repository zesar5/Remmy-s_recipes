const jwt = require("jsonwebtoken");

module.exports = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (authHeader?.startsWith("Bearer ")) {
    const token = authHeader.split(" ")[1];
    try {
      const decoded = jwt.verify(token, config.secret);
      req.user = decoded;
    } catch (err) {
      console.warn("Token inválido, se ignora auth");
    }
  }
  next();
};