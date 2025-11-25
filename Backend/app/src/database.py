from typing import List, Optional
from pydantic import BaseModel
from datetime import date
import uuid
from models import Usuario
class baseDatos:
    def __init__(self):
        self.usuarios: List[Usuario] = []

    def agregarUsuario(self, usuario: Usuario) -> Usuario:
        self.usuarios.append(usuario)
        return usuario
    
    def buscarUsuario (self, username: str) -> Optional[Usuario]:
        for u in self.usuarios:
            if u.nombreUsuario == username:
                return u
        return None
    

    def buscarporID(self, id: str) -> Optional[Usuario]:
        for u in self.usuarios:
            if u.id == id:
                return u
        return None
        
    def listarUsuarios(self) -> List[Usuario]:
        return self.usuarios.copy()
    

    def actualizarUsuario (self, id: str, datos:dict) -> Optional[Usuario]:
        usuario = self.buscarporID(id)
        if usuario:
            for key, value in datos.items():
                if hasattr (usuario,key):
                    setattr(usuario,key,value)
            return usuario
        return None
    #simula base de datoss
db=baseDatos()

