from typing import List
from pydantic_settings import BaseSettings
from pydantic import ConfigDict
import json as json_module


class Settings(BaseSettings):
    model_config = ConfigDict(
        env_file=".env",
        case_sensitive=True,
        extra="ignore"
    )
    
    PROJECT_NAME: str = "AuroraDocs Backend"
    CORS_ORIGINS: str = "http://localhost:5173,http://127.0.0.1:5173"
    DATABASE_URL: str = "sqlite:///./auroradocs.db"
    REDIS_URL: str = "redis://localhost:6379/0"
    MINIO_ENDPOINT: str = "localhost:9000"
    MINIO_ACCESS_KEY: str = "minioadmin"
    MINIO_SECRET_KEY: str = "minioadmin"
    MINIO_SECURE: str = "false"
    MODEL_BASE_PATH: str = "./models"
    SAMPLE_UPLOAD_PATH: str = "./data/samples"
    VLLM_HOST: str = "localhost"
    VLLM_PORT: int = 8001
    SECRET_KEY: str = "your-secret-key-change-this"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    @property
    def CORS_ORIGINS_LIST(self) -> List[str]:
        """兼容 JSON 数组和逗号分隔两种 .env 写法。"""
        raw = (self.CORS_ORIGINS or "").strip()
        if not raw:
            return ["http://localhost:5173"]

        if raw.startswith("["):
            try:
                parsed = json_module.loads(raw)
                if isinstance(parsed, list):
                    return [str(x).strip() for x in parsed if str(x).strip()]
            except json_module.JSONDecodeError:
                pass

        return [x.strip() for x in raw.split(",") if x.strip()]


settings = Settings()

CORS_ORIGINS = settings.CORS_ORIGINS_LIST
