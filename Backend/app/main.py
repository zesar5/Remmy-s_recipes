from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from typing import Optional
from datetime import date
import uuid
from models import Receta
from routers import recetas
from database import db
from models import Usuario
from app.routers import recetas, uploads

app = FastAPI()
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
oauth2 = OAuth2PasswordBearer(tokenUrl="login")


def usuarioActual(token: str=Depends(oauth2)):
        user = db.buscarporID(token)
        if not user:
            raise HTTPException(401,"Token inválido")
        return user
    


    #rutas
@app.post ("/registro/", response_model = perfilOut)
def registro(datos: registroIn):
        if db.buscarUsuario(datos.nombreUsuario):
            raise HTTPException(400, "el usuario ya existe")
        if datos.contraseña != datos.contraseña2:
            raise HTTPException(400, "las contraseñas no coinciden")
        
        datos_usuario = datos.model_dump(exclude={"contraseña2"})
        nuevo =Usuario (**datos_usuario)
        guardado= db.agregarUsuario(nuevo)
        return perfilOut(**guardado.model_dump())
    
@app.post("/login/")

def login(form:OAuth2PasswordRequestForm=Depends()):
        user = db.buscarUsuario(form.nombreUsuario)
        if not user or user.contraseña != form.contraseña:
            raise HTTPException (400, "credenciales incorrectas")
        return {"access_token": user.id, "token_type": "bearer"}
    
@app.get("/perfil/", response_model=perfilOut)
def perfil (user:Usuario= Depends(usuarioActual)):
        return perfilOut(**user.model_dump())
    

@app.get("/")
def inicio():
        return{"mensaje":"API funcionando", "usuarios": len(db.usuarios)}


recetas_db = [
      Receta(
            id = str(uuid.uuid4()),
            titulo = "Pasta al pesto",
            descripcion = "Deliciosa pasta con salsa de albahaca y piñones",
            tiempoPreparacion = 20,
            porciones = 2,
            dificultad = "Fácil",
            fechaCreacion = date.today(),
            idUsuario = "usuario_demo",
            imagen = None,
            categoria = "Italiana"
      )
]

app = FastAPI()
app.include_router(recetas.router)


#Servir las imagenes
app.mount("/images", StaticFiles(directory="images"), name="images")

#Rutas
app.include_router(recetas.router)
app.include_router(uploads.router)  #router para subir imágenes