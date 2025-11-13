from fastapi import APIRouter, HTTPException
from sqlalchemy.orm import Session
from .. import schemas, crud
from ..database import get_db

router = APIRouter(prefix="/recetas", tags=["Recetas"])

@router.get("/", response_model=list[schemas.Receta])
def listar_recetas():
    return crud.get_recetas()

@router.post("/", response_model=schemas.Receta)
def crear_receta(receta: schemas.RecetaCreate):
    return crud.create_receta(receta)

@router.get("/{receta_id}", response_model=schemas.Receta)
def obtener_receta(receta_id: int):
    receta = crud.get_receta(receta_id)
    if not receta:
        raise HTTPException(status_code=404, detail="Receta no encontrada")
    return receta

@router.put("/{receta_id}", response_model=schemas.Receta)
def editar_receta(receta_id: int, receta: schemas.RecetaCreate):
    receta_actualizada = crud.update_receta(receta_id, receta)
    if not receta_actualizada:
        raise HTTPException(status_code=404, detail="Receta no encontrada")
    return receta_actualizada

@router.delete("/{receta_id}")
def eliminar_receta(receta_id: int):
    receta_eliminada = crud.delete_receta(receta_id)
    if not receta_eliminada:
        raise HTTPException(status_code=404, detail="Receta no encontrada")
    return {"message": "Receta eliminada"}