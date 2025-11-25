from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import date

class RecetaBase(BaseModel):
    titulo: str = Field(..., alias="title", min_length=3, max_length=50)
    tiempoPreparacion: Optional[int] = Field(None, alias="duration", ge=1, description="Minutos de preparación")
    categoria: Optional[str] = Field(None, alias="selectedAllergen", min_length=3)
    pais: Optional[str] = Field(None, alias="country")
    estacion: Optional[str] = Field(None, alias="season")
    imagen: Optional[str] = Field(None, alias="imagePath")
    idUsuario: Optional[str] = None

class RecetaCreate(RecetaBase):
    pass

class Ingredient(BaseModel):
    name: str

class StepItem(BaseModel):
    description: str

class Receta(RecetaBase):
    id: int
    fechaCreacion: date
    ingredients: List[Ingredient] = []
    steps: List[StepItem] = []

    class Config:
        orm_mode = True