import os
from fastapi import APIRouter, UploadFile, File, HTTPException

#Endpoint para subir imagenes
router = APIRouter(prefix="/upload", tags=["Uploads"])

@router.post("/image")
async def upload_image(image: UploadFile = File(...)):
    # Comprobar que es imagen
    if not image.content_type.startswith("image/"):
        raise HTTPException(400, "El archivo debe ser una imagen")

    # Carpeta donde se guardarán
    save_path = "images"

    # Crear carpeta si no existe
    os.makedirs(save_path, exist_ok=True)

    # Ruta final del archivo
    image_path = os.path.join(save_path, image.filename)

    # Guardar en disco
    with open(image_path, "wb") as buffer:
        buffer.write(await image.read())

    # URL pública
    url = f"/images/{image.filename}"

    return {"url": url}