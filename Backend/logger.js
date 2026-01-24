// src/logger.js
const winston = require('winston');
const path = require('node:path');

// Configura rotado de logs (archivos diarios)
const logFormat = winston.format.combine(
  winston.format.timestamp(),  // Agrega timestamp
  winston.format.errors({ stack: true }),  // Incluye stack traces en errores
  winston.format.json()  // Formato JSON estructurado
);

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',  // Nivel mínimo (info incluye debug y error)
  format: logFormat,
  transports: [
    // Consola para desarrollo
    new winston.transports.Console({
      format: winston.format.simple()  // Formato legible en consola
    }),
    // Archivo con rotado diario
    new winston.transports.File({
      filename: path.join(__dirname, '../logs/app.log'),
      maxsize: 5242880,  // 5MB por archivo
      maxFiles: 5,  // Máximo 5 archivos
      tailable: true  // Rotado automático
    }),
    // Archivo separado para errores
    new winston.transports.File({
      filename: path.join(__dirname, '../logs/error.log'),
      level: 'error'  // Solo errores
    })
  ]
});

module.exports = logger;