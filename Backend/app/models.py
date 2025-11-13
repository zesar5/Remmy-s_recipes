from typing import List, Optional
from pydantic import BaseModel
from datetime import date
import uuid

class Usuario (BaseModel):
    id: str =str(uuid.uuid4())
    nombreUsuario: str
    email: str
    contrasena:str 
    primerApellido:Optional[str]= None
    segundoApellido :Optional[date]=None
    descripcion: Optional[str]=None
    anioNacimiento: Optional[str]= None 
    fotoPerfil: Optional [str]=None #URL o nombre del archivo
    rol:str = "usuario"

#CLASE RECETA POR AHORA NO ES NECESARIA PORQUE SE TRABAJARA CON DATOS INTERNOS
#Y NO BASE DE DATOS
#class Receta(BaseModel):
#    id: str = str(uuid.uuid4()) #Identificar Unico
#    titulo: str
#    descripcion: Optional[str] = None
#    tiempoPreparacion: Optional[int] = None #Lo introducido en números
#    porciones: Optional[int] = None
#    dificultad: Optional[str] = None  # "Fácil", "Media", "Difícil"
#    fechaCreacion: date = date.today()
#    idUsuario: uuid.UUID  # referencia al usuario que la creó
#    imagen: Optional[str] = None  # URL o nombre del archivo de imagen
#    categoria: Optional[str] = None  # Ej: "Postre", "Vegano", etc.