from typing import List, Optional
from pyndamic import BaseModel
from datetime import date
import uuid
class Usuario (BaseModel):
    id: str =str(uuid.uuid4())
    nombreUsuario: str
    email: str
    contraseña:str 
    primerApellido:Optional[str]= None
    segundoApellido :Optional[date]=None
    descripcion: Optional[str]=None
    añoNacimiento: Optional[str]= None 
    fotoPerfil: Optional [str]=None #URL o nombre del archivo
    rol:str = "usuario"