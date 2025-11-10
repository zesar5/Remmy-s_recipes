from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from .. import schemas, crud
from ..database import get_db

router = APIRouter(prefix="/recetas", tags=["Recetas"])

@router.get("/", response_model=list[schemas.Receta])
def listar_recetas(db: Session = Depends(get_db)):
    return crud.get_recetas(db)

@router.post("/", response_model=schemas.Receta)
def crear_receta(receta: schemas.RecetaCreate, db: Session = Depends(get_db)):
    return crud.create_receta(db, receta)

@router.get("/{receta_id}", response_model=schemas.Receta)
def obtener_receta(receta_id: int, db: Session = Depends(get_db)):
    return crud.get_receta(db, receta_id)

@router.put("/{receta_id}", response_model=schemas.Receta)
def editar_receta(receta_id: int, receta: schemas.RecetaCreate, db: Session = Depends(get_db)):
    return crud.update_receta(db, receta_id, receta)

@router.delete("/{receta_id}")
def eliminar_receta(receta_id: int, db: Session = Depends(get_db)):
    crud.delete_receta(db, receta_id)
    return {"message": "Receta eliminada"}