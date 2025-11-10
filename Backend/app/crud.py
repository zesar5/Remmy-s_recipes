# crud.py
from sqlalchemy.orm import Session
from . import models, schemas

# READ - listar todas las recetas
def get_recetas(db: Session):
    return db.query(models.Receta).all()

# READ - obtener receta por ID
def get_receta(db: Session, receta_id: int):
    return db.query(models.Receta).filter(models.Receta.id == receta_id).first()

# CREATE - crear una nueva receta
def create_receta(db: Session, receta: schemas.RecetaCreate):
    nueva = models.Receta(**receta.dict())  # convierte el schema a dict para asignar campos
    db.add(nueva)
    db.commit()
    db.refresh(nueva)  # obtiene el ID autogenerado y demás campos de BD
    return nueva

# UPDATE - actualizar receta existente
def update_receta(db: Session, receta_id: int, receta_data: schemas.RecetaCreate):
    receta = get_receta(db, receta_id)
    receta.nombre = receta_data.nombre
    receta.descripcion = receta_data.descripcion
    db.commit()
    db.refresh(receta)
    return receta

# DELETE - eliminar receta
def delete_receta(db: Session, receta_id: int):
    receta = get_receta(db, receta_id)
    db.delete(receta)
    db.commit()
    return receta