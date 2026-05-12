from urllib.parse import urlparse

import httpx
from fastapi import APIRouter, Depends, File, Form, HTTPException, Query, UploadFile
from fastapi.responses import Response

from backend.app.core.config import settings
from backend.app.core.security import AuthenticatedUser, require_owner
from backend.app.schemas.common_schema import success_response
from backend.app.services.image_storage_service import ImageStorageService


router = APIRouter()


def _allowed_proxy_hosts() -> set[str]:
    upload_host = urlparse(settings.image_upload_url).hostname
    return {upload_host} if upload_host else set()


@router.post("/images/upload")
def upload_image(
    file: UploadFile = File(..., description="Image file"),
    product_seq: int | None = Form(default=None),
    subfolder: str | None = Form(default=None),
    _: AuthenticatedUser = Depends(require_owner),
) -> dict:
    data = ImageStorageService().upload_image(file, product_seq=product_seq, subfolder=subfolder)
    return success_response(data)


@router.get("/images")
def list_images(
    subfolder: str | None = Query(default=None),
    _: AuthenticatedUser = Depends(require_owner),
) -> dict:
    data = ImageStorageService().list_images(subfolder=subfolder)
    return success_response(data)


@router.get("/images/{file_name}")
def get_image(
    file_name: str,
    subfolder: str | None = Query(default=None),
    _: AuthenticatedUser = Depends(require_owner),
) -> dict:
    data = ImageStorageService().get_image(file_name, subfolder=subfolder)
    return success_response(data)


@router.put("/images/{file_name}")
def update_image(
    file_name: str,
    file: UploadFile = File(..., description="Replacement image file"),
    subfolder: str | None = Form(default=None),
    _: AuthenticatedUser = Depends(require_owner),
) -> dict:
    data = ImageStorageService().update_image(file_name, file, subfolder=subfolder)
    return success_response(data)


@router.delete("/images/{file_name}")
def delete_image(
    file_name: str,
    subfolder: str | None = Query(default=None),
    _: AuthenticatedUser = Depends(require_owner),
) -> dict:
    data = ImageStorageService().delete_image(file_name, subfolder=subfolder)
    return success_response(data)


@router.get("/public-images/proxy")
def proxy_public_image(url: str = Query(..., description="Remote public image URL")) -> Response:
    parsed = urlparse(url)
    if parsed.scheme not in {"http", "https"} or not parsed.hostname:
        raise HTTPException(status_code=400, detail="invalid image url")

    if parsed.hostname not in _allowed_proxy_hosts():
        raise HTTPException(status_code=400, detail="image host not allowed")

    try:
        with httpx.Client(timeout=settings.image_upload_timeout_seconds, follow_redirects=True) as client:
            upstream = client.get(url)
            upstream.raise_for_status()
    except httpx.TimeoutException as exc:
        raise HTTPException(status_code=504, detail="image fetch timeout") from exc
    except httpx.HTTPError as exc:
        raise HTTPException(status_code=502, detail="image fetch failed") from exc

    media_type = upstream.headers.get("content-type", "").split(";")[0].strip()
    if not media_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="invalid image content type")

    return Response(
        content=upstream.content,
        media_type=media_type,
        headers={"Cache-Control": "public, max-age=3600"},
    )
