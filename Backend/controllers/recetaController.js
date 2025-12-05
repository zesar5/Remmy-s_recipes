const { param } = require("../routes/recetasRoutes");

const db = require();


//-----------------------------
//   OBTENER RECETA VISIBLE
//-----------------------------
exports.obtenerRecetaVisibles = async (req, res) => {
    const userId = req.userId || null;

    try{
        let query = "SELECT * FORM receta WHERE public = 1";
        let params = [];

        if(userId){
            query = "SELECT * FROM receta WHERE publica = 1 OR Id_usuario = ?";
            params = [userId];
        }

        const [rows] = await db.query(query, params);
        res.json(rows);

    } catch(err){
        res.status(500).json({ error: err.message});
    }
};


//---------------------------
//   OBTENER RECETA X ID
//---------------------------
exports.obtenerRecetaPorId = async (req, res) => {
    const userId = req.userId || null;
    const Id_receta = req.params.id;

    try{
        const [rows] = await db.query(
            "SELECT * FROM Receta WHERE Id_receta = ?",
            [Id_receta]
        );

        if(rows.length === 0){
            return res.status(404).json({ mensaje: "Receta no encontrada"});
        }

        const receta = rows[0];

        if(!receta.publica && receta.Id_usuario !== userId){
            return res.status(403).json({ mensaje: "No tienes permiso para ver esta receta" });
        }

        res.json(receta);

    } catch(err){
        res.status(500).json({ error: err.message})
    }
};


//------------------------
//   CREAR RECETA
//------------------------
exports.crearReceta = async (req, res) => {
    const data = req.body;
    const userId = req.userId;

    try{;
        const [result] = await db.query(
            `INSERT INTO Receta 
            (titulo, tiempo_preparacion, origen, alergenos, estacion, Id_usuario) 
            VALUES (?, ?, ?, ?, ?, ?)`,
            [
                data.titulo,
                data.duracion,
                data.pais,
                data.alergenos,
                data.estacion,
                userId
            ]
        );

        if(data.imagen){
            const base64Data = data.imagen.replace(/^data:image\/\w+;base64,/, "");

            const buffer = Buffer.from(base64Data, "base64");

            await db.query(
                'INSERT INTO receta_imagen (imagen, Id_receta) VALUES (?, ?)',
                [buffer, result.insertId]
            );
        }

        if (data.pasos && data.pasos.length > 0) {
            const pasosPromises = data.pasos.map(paso => {
                return db.query(
                    `INSERT INTO Paso (descripcion, Id_receta) VALUES (?, ?)`,
                    [paso.descripcion, result.insertId]
                );
            });
            await Promise.all(pasosPromises);
        }

        if (data.ingredientes && data.ingredientes.length > 0) {
            const ingredientesPromises = data.ingredientes.map(ingrediente => {
                return db.query(
                    `INSERT INTO Ingrediente (nombre, cantidad, Id_receta) VALUES (?, ?, ?)`,
                    [ingrediente.nombre, ingrediente.cantidad, result.insertId]
                );
            });
            await Promise.all(ingredientesPromises);
        }

        res.json({ mensaje: "Receta creada", id: result.insertId});
    } catch(err){
        res.status(500).json({ mensaje: err.message});
    }
};


//------------------------
//   ACTUALIZAR RECETA
//------------------------
exports.actualizarReceta = async (req, res) => {
    const Id_receta = req.params.id;
    const Id_usuario = req.userId;

    try{
        const [recetaRows] = await db.query(
            "SELECT Id_usuario FROM receta WHERE Id_receta = ?",
            [Id_receta]
        )

        if(recetaRows.length === 0){
            return res.status(404).json({ mensaje: "Receta no encontrada" });
        }

        if(recetaRows[0].Id_usuario !== userId){
            return res.status(403).json({ mensaje: "No tienes permiso para editar esta receta" });
        }

        await db.query(
            "UPDATE Receta SET ? WHERE Id_receta = ?",
            [req.body, Id_receta]
        );

        res.json({ mensaje: "Receta actualizada"});
    } catch(err){
        res.status(500).json({ error: err.message });
    }
};


//------------------------
//   ELIMINAR RECETA
//------------------------
exports.eliminarReceta = async (req, res) => {
    const Id_receta = req.params.id;
    const Id_usuario = req.userId;

    try{
        const [recetaRows] = await db.query(
            "SELECT Id_usuario FROM receta WHERE Id_receta = ?",
            [Id_receta]
        )

        if(recetaRows.length === 0){
            return res.status(404).json({ mensaje: "Receta no encontrada" });
        }

        if(recetaRows[0].Id_usuario !== userId){
            return res.status(403).json({ mensaje: "No tienes permiso para eliminar esta receta" });
        }

        await db.query(
            "DELETE FROM Receta WHERE Id_receta = ?",
            [req.params.id]
        );

        res.json({ mensaje: "Receta eliminada" });
    } catch(err){
        res.status(500).json({ error: err.message });
    }
};