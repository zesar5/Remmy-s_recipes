const jwt = require("jsonwebtoken");

// Este middleware se utiliza para PROTEGER rutas que requieren que el usuario esté autenticado
module.exports = function (req, res, next) {
  console.log("🔐 AUTH MIDDLEWARE");
  console.log("📌 HEADER AUTH:", req.headers.authorization);

  // 1. Obtenemos el header de autorización (normalmente viene como: "Bearer xxxxx.yyyyy.zzzzz")
  const authHeader = req.headers["authorization"];

  // 2. Si no existe el header → el usuario no envió ningún token
  if (!authHeader) {
    console.log("❌ NO HAY TOKEN");
    return res.status(401).json({
      mensaje: "Debes iniciar sesión",
    });
  }

  // 3. Separamos el string "Bearer " del token real
  // Ejemplo: "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  // Nos quedamos solo con la parte después del espacio
  const token = authHeader.split(" ")[1];

  console.log("🪪 TOKEN EXTRAÍDO:", token);

  // 4. Validación extra: aunque venga el header, podría no tener token después de "Bearer"
  if (!token) {
    return res.status(401).json({
      mensaje: "Token no proporcionado",
    });
  }

  try {
    // 5. Intentamos verificar y decodificar el token
    // jwt.verify lanza error si:
    // - token está mal formado
    // - firma no coincide (clave secreta incorrecta)
    // - token expirado
    // - algoritmo diferente
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    console.log("✅ TOKEN OK, USER ID:", decoded.id);

    // 6. Guardamos el id del usuario en el objeto req
    // Así las rutas siguientes pueden saber QUIÉN está haciendo la petición
    req.userId = decoded.id;

    // 7. Todo bien → continuamos con la siguiente función/middleware/ruta
    next();
  } catch (error) {
    // Cualquier problema con el token (expirado, inválido, manipulado, etc)
    console.log("❌ TOKEN INVÁLIDO");
    return res.status(401).json({
      mensaje: "Token inválido",
    });
  }
};
