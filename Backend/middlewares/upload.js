//AQUI HACEMOS USO DE LA LIBRERIA MULTER
/*Multer se trata de un mddleware de Express 
que sirve para poder manejar archivos desde el frontend*/

// Creamos una configuración de almacenamiento en MEMORIA

//esto es ideal cuando guardas la imagen en base de datos

const multer = require("multer");
//le decimos a multer que use la RAM como almacenamiento
const storage = multer.memoryStorage();

//creamos el middleware "upload"
/* Este middleware se encaraga de leer el el archivo enviado desde flutter
validar su tamaño, guardarlo en memoria 
y añadir el objeto req como req.file*/
const upload = multer({
  //le decimos a multer que use la RAM como almacenamiento
  storage,
  //limites de seguridad
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
  },
});
//lo exportamos para poder usarlo en rutas
module.exports = upload;
