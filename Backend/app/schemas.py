from pydantic import BaseModel

class RecetaBase(BaseModel):
    nombre: str
    descripcion: str

class RecetaCreate(RecetaBase):
    pass

class Receta(RecetaBase):
    id: int

    class Config:
        orm_mode = True