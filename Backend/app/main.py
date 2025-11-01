from fastapi import FastAPI, HTTPException, Depends
from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from typing import Optional
from datetime import date


from database import baseDatos,Usuarios
#esquemas
class registroIn(BaseModel):
    nombreUsuario: str
    email: str
    contraseña:str 
    contraseña2: str
    primerApellido:Optional[str]= None
    segundoApellido :Optional[date]=None
    descripcion: Optional[str]=None
    añoNacimiento: Optional[str]= None 
    rol:str = "usuario"



class perfilOut(BaseModel):
    id: str
    nombreUsuario: str
    email: str
    primerApellido:Optional[str]= None
    segundoApellido :Optional[date]=None
    descripcion: Optional[str]=None
    añoNacimiento: Optional[str]= None 
    fotoPerfil: Optional [str]=None #URL o nombre del archivo
    rol:str 


    #autenticación
    oauth2 =OAuth2PasswordBearer(tokenUr1="login")


    def usuarioActual(token: str=Depends(oauth2)):
        user = baseDatos.buscarporID(token)
        if not user:
            raise HTTPException(401,"Token inválido")
        return user
    


    #rutas
    @app.post ("/registro/", response_model = perfilOut)
    def registro(datos: registroIn):
        if baseDatos.buscarUsuario(datos.nombreUsuario):
            raise HTTPException(400, "el usuario ya existe")
        if datos.contraseña != datos.contraseña2:
            raise HTTPException(400, "las contraseñas no coinciden")
        
        nuevo =Usuario (**datos.__dict__(exclude={"contraseña2"}))
        guardado= baseDatos.agregarUsuario(nuevo)
        return perfilOut(**guardado.dict())
    
    @app.post("/login/")
    def login(form:OAuth2PasswordRequestForm=Depends()):
        user = baseDatos.buscarUsuario(form.nombreUsuario)
        if not user or user.contraseña != form.contraseña:
            raise HTTPException (400, "credenciales incorrectas")
        return {"access_token": user.id, "token_type": "bearer"}
    
    @app.get("/perfil/", response_model=perfilOut)
    def perfil (user:Usuarios= Depends(usuarioActual)):
        return perfilOut(**user.dict())
    

    @app.get("/")
    def inicio():
        return{"mensje":"API funcionando", "usuarios": len(baseDatos.usuaarios)}