const db = require("../config/db");

// ----------------------------------------
//     ENTIDAD / MODELO DE RECETA
// ----------------------------------------
class RecetaEntity {
    constructor(obj) {
        this.id = obj.Id_receta;
        this.titulo = obj.titulo;
        this.duracion = obj.tiempo_preparacion;
        this.pais = obj.origen;
        this.alergenos = obj.alergenos;
        this.estacion = obj.estacion;
        this.publica = obj.publica;
        this.usuarioId = obj.Id_usuario;
        this.ingredientes = obj.ingredientes || [];
        this.pasos = obj.pasos || [];
        this.imagen = obj.imagen || null;
    }
}

// ----------------------------------------
//     FUNCIONES DE ACCESO A DATOS
// ----------------------------------------
const RecetaModel = {
    obtenerPorUsuario: async (userId) =>{
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

        const recetas = rows.map(row => ({
            id: row.Id_receta,
            titulo: row.titulo,
            imagenBase64: row.imagen ? `data:image/jpeg;base64,${row.imagen.toString('base64')}` : null
        }));

        return recetas;
    },
    obtenerVisibles: async (userId = null) => {
        let query = "SELECT * FROM receta WHERE publica = 1";
        let params = [];

        if(userId){
            query = "SELECT * FROM receta WHERE publica = 1 OR Id_usuario = ?";
            params = [userId];
        }

        const [rows] = await db.query(query, params);
        return rows.map(r => new RecetaEntity(r));
    },

    //Función para obtener recetas para home
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

        const recetas = rows.map(row => ({
            Id_receta: row.Id_receta,
            titulo: row.titulo,
            imagenBase64: row.imagen
            ? `data:image/jpeg;base64,${row.imagen.toString('base64')}` : null
        }));

        return recetas;
    },

    obtenerPorId: async (id) => {
        const [rows] = await db.query("SELECT * FROM Receta WHERE Id_receta = ?", [id]);
        if(rows.length === 0) return null;

        const receta = rows[0];

        // Obtener ingredientes
        const [ingredientes] = await db.query(
            "SELECT nombre, cantidad FROM Ingrediente WHERE Id_receta = ?",
            [id]
        );

        // Obtener pasos
        const [pasos] = await db.query(
            "SELECT descripcion FROM Paso WHERE Id_receta = ?",
            [id]
        );

        // Obtener imagen
        const [imagenes] = await db.query(
            "SELECT imagen FROM receta_imagen WHERE Id_receta = ?",
            [id]
        );

        receta.ingredientes = ingredientes;
        receta.pasos = pasos;
        receta.imagen = imagenes.length ? imagenes[0].imagen : null;

        return new RecetaEntity(receta);
    },

    crear: async (data, userId) => {
        const [result] = await db.query(
            `INSERT INTO Receta 
            (titulo, tiempo_preparacion, origen, alergenos, estacion, publica, Id_usuario) 
            VALUES (?, ?, ?, ?, ?, ?, ?)`,
            [data.titulo, data.duracion, data.pais, data.alergenos, data.estacion, 0, userId]
        );

        const recetaId = result.insertId;

        if(data.imagen){
            const base64Data = data.imagen.replace(/^data:image\/\w+;base64,/, "");
            const buffer = Buffer.from(base64Data, "base64");
            await db.query("INSERT INTO receta_imagen (imagen, Id_receta) VALUES (?, ?)", [buffer, recetaId]);
        }

        if(data.pasos?.length){
            const pasosPromises = data.pasos.map(p => 
                db.query("INSERT INTO Paso (descripcion, Id_receta) VALUES (?, ?)", [p.descripcion, recetaId])
            );
            await Promise.all(pasosPromises);
        }

        if(data.ingredientes?.length){
            const ingredientesPromises = data.ingredientes.map(i =>
                db.query("INSERT INTO Ingrediente (nombre, cantidad, Id_receta) VALUES (?, ?, ?)", [i.nombre, i.cantidad, recetaId])
            );
            await Promise.all(ingredientesPromises);
        }

        return recetaId;
    },

    actualizar: async (id, data) => {
        await db.query("UPDATE Receta SET ? WHERE Id_receta = ?", [data, id]);
    },

    eliminar: async (id) => {
        await db.query("DELETE FROM Receta WHERE Id_receta = ?", [id]);
    },

    verificarPropietario: async (id, userId) => {
        const [rows] = await db.query("SELECT Id_usuario FROM Receta WHERE Id_receta = ?", [id]);
        if(rows.length === 0) return null;
        return rows[0].Id_usuario === userId;
    }
};

module.exports = { RecetaEntity, RecetaModel };