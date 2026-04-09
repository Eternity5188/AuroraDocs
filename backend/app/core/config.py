from typing import List, Annotated
from pydantic_settings import BaseSettings, NoDecode
from pydantic import field_validator, ConfigDict, Field
import json as json_module


class Settings(BaseSettings):
    model_config = ConfigDict(
        env_file=".env",
        case_sensitive=True,
        extra="ignore"
    )
    
    PROJECT_NAME: str = "AuroraDocs Backend"
    CORS_ORIGINS: Annotated[List[str], NoDecode] = Field(default=["http://localhost:5173"])
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

    @field_validator("CORS_ORIGINS", mode="before")
    @classmethod
    def parse_cors_origins(cls, v):
        """
        支持多种格式：
        1. JSON 格式: ["http://localhost:5173","http://127.0.0.1:5173"]
        2. 逗号分隔: http://localhost:5173,http://127.0.0.1:5173
        3. 空字符串: "" → 使用默认值
        4. 列表: [...] → 直接使用
        """
        if isinstance(v, list):
            return v
        if isinstance(v, str):
            v = v.strip()
            # 空字符串返回默认值
            if not v:
                return ["http://localhost:5173"]
            # 尝试作为 JSON 解析
            if v.startswith("["):
                try:
                    return json_module.loads(v)
                except json_module.JSONDecodeError:
                    pass
            # 作为逗号分隔字符串解析
            return [x.strip() for x in v.split(",") if x.strip()]
        return ["http://localhost:5173"]


settings = Settings()

CORS_ORIGINS = settings.CORS_ORIGINS
