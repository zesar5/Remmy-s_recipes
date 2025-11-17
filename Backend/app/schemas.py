from pydantic import BaseModel
from typing import Optional
from datatime import date

class RecetaBase(BaseModel):
    titulo: str = Field(..., min_length=3, max_length=50)
    descripcion: str = Field(..., min_length=10, max_length=500)
    tiempoPreparacion: Optional[int] = Field(None, ge=1, description="Minutos de preparación")
    porciones: Optional[int] = Field(None, ge=1)
    dificultad: Optional[str] = Field(None, pattern="^(Fácil|Media|Difícil)$")
    categoria: Optional[str] = Field(None, min_length=3)
    imagen: Optional[str] = None
    idUsuario: Optional[str] = None

class RecetaCreate(RecetaBase):
    pass

class Receta(RecetaBase):
    id: int
    fechaCreacion: date

    class Config:
        orm_mode = True