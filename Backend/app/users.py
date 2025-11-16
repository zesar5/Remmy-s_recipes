# users.py
from typing import Optional

# Usuario predeterminado
usuarios_db = [
    {"id": 1, "username": "admin123@gmail.com", "password": "admin123"}
]

def autenticar_usuario(username: str, password: str) -> Optional[dict]:
    for user in usuarios_db:
        if user["username"] == username and user["password"] == password:
            return user
    return None

