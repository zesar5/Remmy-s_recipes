# auth.py
from fastapi import APIRouter, HTTPException
from .users import autenticar_usuario

router = APIRouter(prefix="/auth", tags=["Auth"])

@router.post("/login")
def login(username: str, password: str):
    user = autenticar_usuario(username, password)
    if not user:
        raise HTTPException(status_code=400, detail="Credenciales incorrectas")

    from .users import set_usuario_actual
    set_usuario_actual(user)

    return {"mensaje": "Login correcto", "usuario": user}

usuario_actual = None

def set_usuario_actual(user: dict):
    global usuario_actual
    usuario_actual = user

def get_usuario_actual() -> dict:
    return usuario_actual