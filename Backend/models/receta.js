const db = require("../config/db");

// ----------------------------------------
//     CLASE QUE REPRESENTA UNA RECETA
// ----------------------------------------
class RecetaEntity {
  constructor(obj) {
    this.id = obj.Id_receta;
    this.titulo = obj.titulo;
    this.duracion = obj.tiempo_preparacion;
    this.pais = obj.origen;
    this.alergenos = obj.alergenos;
    this.estacion = obj.estacion;
    this.publica = obj.publica; // convertimos a booleano
    this.usuarioId = obj.Id_usuario;
    this.ingredientes = obj.ingredientes || [];
    this.pasos = obj.pasos || [];
    this.imagen = obj.imagen || null; // base64 o null
  }
}

// ----------------------------------------
//     MÉTODOS DE ACCESO A DATOS (MODELO)
// ----------------------------------------
const RecetaModel = {
  /**
   * Obtiene todas las recetas de un usuario (públicas + privadas)
   * Usado principalmente en el perfil del usuario
   */
  obtenerPorUsuario: async (userId) => {
    const [rows] = await db.query(
      `SELECT 
                r.Id_receta,
                r.titulo,
                i.imagen
            FROM receta r
            LEFT JOIN receta_imagen i ON i.Id_receta = r.Id_receta
            WHERE r.Id_usuario = ?`,
      [userId]
    );

    // Transformamos las filas en formato más amigable para el frontend
    const recetas = rows.map(row => ({
            id: row.Id_receta,
            titulo: row.titulo,
            imagenBase64: row.imagen ? `data:image/jpeg;base64,${row.imagen.toString('base64')}` : null
        }));

        return recetas;
    },

  /**
   * Obtiene recetas visibles (públicas)
   * Si se pasa userId → también incluye las recetas privadas de ese usuario
   */
  obtenerVisibles: async (userId = null) => {
    let query = "SELECT * FROM receta WHERE publica = 1";
    let params = [];

    if (userId) {
      query = "SELECT * FROM receta WHERE publica = 1 OR Id_usuario = ?";
      params = [userId];
    }

    const [rows] = await db.query(query, params);
    return rows.map(r => new RecetaEntity(r));
  },

  /**
   * Obtiene un rango de recetas (principalmente para la home / carrusel)
   * Devuelve solo lo mínimo necesario: id, título e imagen
   */
  getByRange: async (minId, maxId) => {
    const [rows] = await db.query(
      `SELECT 
                r.Id_receta,
                r.titulo,
                i.imagen
            FROM receta r
            LEFT JOIN receta_imagen i ON i.Id_receta = r.Id_receta
            WHERE r.Id_receta BETWEEN ? AND ?
            ORDER BY r.Id_receta
            LIMIT 6`,
      [minId, maxId]
    );

    return rows.map(row => ({
      Id_receta: row.Id_receta,
      titulo: row.titulo,
      imagenBase64: row.imagen
        ? `data:image/jpeg;base64,${row.imagen.toString("base64")}`
        : null,
    }));
  },

  /**
   * Obtiene UNA receta completa por su ID (con ingredientes, pasos e imagen)
   * Es la consulta más completa y usada en la vista de detalle
   */
  obtenerPorId: async (id) => {
    console.log("🔎 Consultando receta en DB, Id:", id);

    const [rows] = await db.query("SELECT * FROM Receta WHERE Id_receta = ?", [
      id,
    ]);
    if (rows.length === 0) {
      console.log("⚠️ No se encontró la receta en DB");
      return null;
    }

    const receta = rows[0];

    // ── Ingredientes ───────────────────────────────
    const [ingredientes] = await db.query(
      "SELECT nombre, cantidad FROM Ingrediente WHERE Id_receta = ?",
      [id]
    );

    // ── Pasos ──────────────────────────────────────
    const [pasos] = await db.query(
      "SELECT descripcion FROM Paso WHERE Id_receta = ?",
      [id]
    );

    // ── Imagen (solo la primera por ahora) ─────────
    const [imagenes] = await db.query(
      "SELECT imagen FROM receta_imagen WHERE Id_receta = ?",
      [id]
    );

    // Armamos el objeto final
    receta.ingredientes = ingredientes;
    receta.pasos = pasos; // solo las descripciones
    receta.imagen = imagenes.length
      ? `data:image/jpeg;base64,${imagenes[0].imagen.toString("base64")}`
      : null;

    return new RecetaEntity(receta);
  },

  /**
   * Crea una receta nueva + sus relaciones (imagen, pasos, ingredientes)
   * @returns {number} ID de la receta recién creada
   */
  crear: async (data, userId) => {
    const [result] = await db.query(
      `INSERT INTO Receta 
            (titulo, tiempo_preparacion, origen, alergenos, estacion, publica, Id_usuario) 
            VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        data.titulo,
        data.duracion,
        data.pais,
        data.alergenos,
        data.estacion,
        0,
        userId,
      ]
    );

    const recetaId = result.insertId;

    // Imagen (si existe)
    if (data.imagen) {
      const base64Data = data.imagen.replace(/^data:image\/\w+;base64,/, "");
      const buffer = Buffer.from(base64Data, "base64");
      await db.query(
        "INSERT INTO receta_imagen (imagen, Id_receta) VALUES (?, ?)",
        [buffer, recetaId]
      );
    }

    // Pasos
    if (data.pasos?.length) {
      const pasosPromises = data.pasos.map(p =>
        db.query("INSERT INTO Paso (descripcion, Id_receta) VALUES (?, ?)", [
          p.descripcion,
          recetaId,
        ])
      );
      await Promise.all(pasosPromises);
    }

    // Ingredientes
    if (data.ingredientes?.length) {
      const ingredientesPromises = data.ingredientes.map(i =>
        db.query(
          "INSERT INTO Ingrediente (nombre, cantidad, Id_receta) VALUES (?, ?, ?)",
          [i.nombre, i.cantidad, recetaId]
        )
      );
      await Promise.all(ingredientesPromises);
    }

    return recetaId;
  },

  /**
   * Actualización simple (solo campos principales de la tabla Receta)
   * Nota: no actualiza ingredientes ni pasos en esta implementación
   */
  actualizar: async (id, data) => {
    await db.query("UPDATE Receta SET ? WHERE Id_receta = ?", [data, id]);
  },

  /**
   * Eliminación física de la receta
   * (En producción se recomienda más bien un borrado lógico con campo activo/eliminado)
   */
  eliminar: async (id) => {
    await db.query("DELETE FROM Receta WHERE Id_receta = ?", [id]);
  },

  /**
   * Verifica si un usuario es el propietario de una receta
   * @returns {boolean|null} true = es propietario, false = no lo es, null = receta no existe
   */
  verificarPropietario: async (id, userId) => {
    const [rows] = await db.query(
      "SELECT Id_usuario FROM Receta WHERE Id_receta = ?",
      [id]
    );
    if (rows.length === 0) return null;
    return rows[0].Id_usuario === userId;
  },
};

module.exports = { RecetaEntity, RecetaModel };
