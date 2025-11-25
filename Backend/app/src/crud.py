#CRUD EN MEMORIA INTERNA
from typing import List, Optional
from datetime import date
from .schemas import RecetaCreate, Receta
from fastapi import HTTPException

# Lista que simula la base de datos
recetas_db: List[Receta] = []
ultimo_id = 0  # Para asignar IDs automáticamente

def get_recetas() -> List[Receta]:
    return recetas_db

def get_receta(receta_id: int) -> Optional[Receta]:
    for r in recetas_db:
        if r.id == receta_id:
            return r
    return None

def create_receta(receta_data: RecetaCreate) -> Receta:
    global ultimo_id
    ultimo_id += 1

    nueva_receta = Receta(
        id=ultimo_id,
        fechaCreacion=date.today(),
        **receta_data.dict()
    )
    recetas_db.append(nueva_receta)
    return nueva_receta

def update_receta(receta_id: int, receta_data: RecetaCreate) -> Optional[Receta]:
    receta = get_receta(receta_id)
    if not receta:
        raise HTTPException(404, "La receta no existe")
    
    try:
        receta.titulo = receta_data.titulo
        receta.descripcion = receta_data.descripcion
        receta.tiempoPreparacion = receta_data.tiempoPreparacion
        receta.porciones = receta_data.porciones
        receta.dificultad = receta_data.dificultad
        receta.idUsuario = receta_data.idUsuario
        receta.imagen = receta_data.imagen
        receta.categoria = receta_data.categoria
    except Exception:
        raise HTTPException(500, "Error actualizando la receta")
    
    return receta

def delete_receta(receta_id: int) -> Optional[Receta]:
    receta = get_receta(receta_id)
    if not receta:
        raise HTTPException(404, "La receta no existe")

        try:
            recetas_db.remove(receta)
        except Exception:
            raise HTTPException(500, "No se puede eliminar la receta")
        
    return receta

#LA PARTE DE ABAJO LO QUE SE UTILIZARÁ CUANDO YA TENGAMOS UNA BASE DE DATOS
# crud.py
#from sqlalchemy.orm import Session
#from . import models, schemas

# READ - listar todas las recetas
#def get_recetas(db: Session):
#    return db.query(models.Receta).all()

# READ - obtener receta por ID
#def get_receta(db: Session, receta_id: int):
#    return db.query(models.Receta).filter(models.Receta.id == receta_id).first()

# CREATE - crear una nueva receta
#def create_receta(db: Session, receta: schemas.RecetaCreate):
#    nueva = models.Receta(**receta.dict())  # convierte el schema a dict para asignar campos
#    db.add(nueva)
#    db.commit()
#    db.refresh(nueva)  # obtiene el ID autogenerado y demás campos de BD
#    return nueva

# UPDATE - actualizar receta existente
#def update_receta(db: Session, receta_id: int, receta_data: schemas.RecetaCreate):
#    receta = get_receta(db, receta_id)
#    receta.nombre = receta_data.nombre
#    receta.descripcion = receta_data.descripcion
#    db.commit()
#    db.refresh(receta)
#    return receta

# DELETE - eliminar receta
#def delete_receta(db: Session, receta_id: int):
#    receta = get_receta(db, receta_id)
#    db.delete(receta)
#    db.commit()
#    return receta