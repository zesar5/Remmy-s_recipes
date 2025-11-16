from pydantic import BaseModel

class RecetaBase(BaseModel):
    titulo: str
    descripcion: str
    imagen: Optional[str] = None

class RecetaCreate(RecetaBase):
    pass

class Receta(RecetaBase):
    id: int

    class Config:
        orm_mode = True