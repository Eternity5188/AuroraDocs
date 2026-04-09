from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import train
from app.core.config import settings
from app.core.db import init_db
from app.core.logger import get_logger

logger = get_logger("main")
app = FastAPI(
    title="AuroraDocs Backend",
    description="Remote GPU training and inference service for AuroraDocs.",
    version="0.1.0",
)


@app.on_event("startup")
def on_startup():
    try:
        init_db()
        logger.info("数据库初始化完成")
    except Exception:
        logger.exception("启动时数据库初始化失败")
        raise


app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(train.router, prefix="/api/train", tags=["train"])


@app.get("/health")
def health_check():
    return {"status": "ok"}
