const { param } = require("../routes/recetaRoutes");

const { RecetaModel } = require("../models/receta");

//-----------------------------
//   OBTENER RECETA VISIBLE
//-----------------------------
exports.obtenerRecetaVisibles = async (req, res) => {
    try {
        const recetas = await RecetaModel.obtenerVisibles(req.userId);
        res.json(recetas);
    } catch(err) {
        res.status(500).json({ error: err.message });
    }
};

//---------------------------
//   OBTENER RECETA X ID
//---------------------------
exports.obtenerRecetaPorId = async (req, res) => {
    try {
        const receta = await RecetaModel.obtenerPorId(req.params.id);

        if(!receta) return res.status(404).json({ mensaje: "Receta no encontrada" });

        if(!receta.publica && receta.usuarioId !== req.userId){
            return res.status(403).json({ mensaje: "No tienes permiso para ver esta receta" });
        }

        res.json(receta);
    } catch(err) {
        res.status(500).json({ error: err.message });
    }
};


//------------------------
//   CREAR RECETA
//------------------------
exports.crearReceta = async (req, res) => {
    try {
        const id = await RecetaModel.crear(req.body, req.userId);
        res.json({ mensaje: "Receta creada", id });
    } catch(err) {
        res.status(500).json({ mensaje: err.message });
    }
};


//------------------------
//   ACTUALIZAR RECETA
//------------------------
exports.actualizarReceta = async (req, res) => {
    try {
        const esPropietario = await RecetaModel.verificarPropietario(req.params.id, req.userId);

        if(esPropietario === null) return res.status(404).json({ mensaje: "Receta no encontrada" });
        if(!esPropietario) return res.status(403).json({ mensaje: "No tienes permiso para editar esta receta" });

        await RecetaModel.actualizar(req.params.id, req.body);
        res.json({ mensaje: "Receta actualizada" });
    } catch(err) {
        res.status(500).json({ error: err.message });
    }
};


//------------------------
//   ELIMINAR RECETA
//------------------------
exports.eliminarReceta = async (req, res) => {
    try {
        const esPropietario = await RecetaModel.verificarPropietario(req.params.id, req.userId);

        if(esPropietario === null) return res.status(404).json({ mensaje: "Receta no encontrada" });
        if(!esPropietario) return res.status(403).json({ mensaje: "No tienes permiso para eliminar esta receta" });

        await RecetaModel.eliminar(req.params.id);
        res.json({ mensaje: "Receta eliminada" });
    } catch(err) {
        res.status(500).json({ error: err.message });
    }
};