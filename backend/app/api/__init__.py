from fastapi import APIRouter

router = APIRouter()

from . import train  # noqa: F401

router.include_router(train.router)
