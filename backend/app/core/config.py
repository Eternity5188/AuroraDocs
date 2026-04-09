from typing import List
from pydantic import BaseSettings


class Settings(BaseSettings):
    PROJECT_NAME: str = "AuroraDocs Backend"
    CORS_ORIGINS: List[str] = ["http://localhost:5173"]
    DATABASE_URL: str = "postgresql://user:password@localhost:5432/auroradocs"
    REDIS_URL: str = "redis://localhost:6379/0"
    MINIO_ENDPOINT: str = "localhost:9000"
    MINIO_ACCESS_KEY: str = "minioadmin"
    MINIO_SECRET_KEY: str = "minioadmin"
    MODEL_BASE_PATH: str = "/data/models"
    SAMPLE_UPLOAD_PATH: str = "/data/samples"
    VLLM_HOST: str = "localhost"
    VLLM_PORT: int = 8001

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()


CORS_ORIGINS = settings.CORS_ORIGINS
