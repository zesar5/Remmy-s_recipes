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

//--------------------------------
//   OBTENER RECETA PARA HOME
//--------------------------------

exports.getRecetas = async (req, res) => {
    try{
    const rangoInicio = parseInt(req.query.rangoInicio) || 1;
    const rangoFin = parseInt(req.query.rangoFin) || 6;

    const recetas = await RecetaModel.getByRange(rangoInicio, rangoFin);

    res.status(200).json(recetas);
    }catch(error){
        res.status(500).json({ message: 'Error obtenido recetas', error });
    }
};

//---------------------------
//   OBTENER RECETA X ID
//---------------------------
exports.obtenerRecetaPorId = async (req, res) => {
    try {
        console.log("🚀 ENTRÓ A obtenerRecetaPorId"); // <-- PRINT 1
        console.log("📌 req.params.id:", req.params.id); // <-- PRINT 2
        console.log("📌 req.userId:", req.userId);

        const receta = await RecetaModel.obtenerPorId(req.params.id);
        console.log("📦 Receta obtenida de DB:", receta);

        if(!receta) return res.status(404).json({ mensaje: "Receta no encontrada" });

        if(!receta.publica && receta.usuarioId !== req.userId){
            console.log("⚠️ Acceso denegado");
            return res.status(403).json({ mensaje: "No tienes permiso para ver esta receta" });
        }

        console.log("✅ Respondiendo con receta");
        res.json(receta);
    } catch(err) {
        console.log("🔥 ERROR:", err);
        res.status(500).json({ error: err.message });
    }
};


//------------------------
//   CREAR RECETA
//------------------------
exports.crearReceta = async (req, res) => {
    try {
        console.log("REQ.BODY:", req.body);
        console.log("Tipo de req.body:", typeof req.body);
        console.log("Tamaño de la imagen:", req.body.imagen?.length);
        const id = await RecetaModel.crear(req.body, req.userId);
        res.status(200).json({ mensaje: "Receta creada", id });
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

//---------------------------
//  RECETA POR USUARIO
//---------------------------
exports.obtenerRecetaUsuario = async (req, res) => {
    console.log("📥 CONTROLLER obtenerRecetaUsuario");
    console.log("📌 req.params.userId:", req.params.userId);
    console.log("📌 req.userId (token):", req.userId);
    
    try{
        const userId = req.params.userId;
        const recetas = await RecetaModel.obtenerPorUsuario(userId);
        console.log("📦 RECETAS BD:", recetas.length);

        res.json(recetas);
    }catch(err){
        console.log("🔥 ERROR CONTROLLER:", err);
        res.status(500).json({ error: err.message});
    }
};