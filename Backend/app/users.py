# users.py
from typing import Optional

# Usuario predeterminado
usuarios_db = [
    {"id": 1, "username": "admin123@gmail.com", "password": "admin123"}
]

# Variable global para simular sesión
usuario_actual: Optional[dict] = None

def autenticar_usuario(username: str, password: str) -> Optional[dict]:
    global usuario_actual
    for user in usuarios_db:
        if user["username"] == username and user["password"] == password:
            usuario_actual = user  # Guardamos el usuario como "logueado"
            return user
    return None

def get_usuario_actual() -> Optional[dict]:
    return usuario_actual