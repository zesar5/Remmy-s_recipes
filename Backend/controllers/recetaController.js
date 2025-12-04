const db = require();

exports.obtenerReceta = async (req, res) => {
   try{
    const [rows] = await db.query("SELECT * FROM Receta")
    res.json(rows);
   } catch(err){
    res.status(500).json({ error: err.message});
   }
};

exports.obtenerRecetaPorId = async (req, res) => {
    try{
        const [rows] = await db.query(
            "SELECT * FROM Receta WHERE Id_receta = ?",
            [req.params.id]
        );

        if(rows.length === 0){
            return res.status(404).json({ mensaje: "Receta no encontrada"});
        }

        res.json(rows[0]);
    } catch(err){
        res.status(500).json({ error: err.message})
    }
};

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

exports.actualizarReceta = async (req, res) => {
    try{
        await db.query(
            "UPDATE Receta SET ? WHERE Id_receta = ?",
            [req.body, req.params.id]
        );

        res.json({ mensaje: "Receta actualizada"});
    } catch(err){
        res.status(500).json({ error: err.message });
    }
};

exports.eliminarReceta = async (req, res) => {
    try{
        await db.query(
            "DELETE FROM Receta WHERE Id_receta = ?",
            [req.params.id]
        );

        res.json({ mensaje: "Receta eliminada" });
    } catch(err){
        res.status(500).json({ error: err.message });
    }
};