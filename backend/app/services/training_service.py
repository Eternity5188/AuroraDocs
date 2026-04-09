import os
from typing import Any, Dict, List
from urllib.parse import urlparse
from app.core.config import settings
from app.utils.file_utils import ensure_directory
from app.core.logger import get_logger

logger = get_logger("TrainingService")


class TrainingService:
    def __init__(self, task_id: str, config: Dict[str, Any]):
        self.task_id = task_id
        self.config = config
        self.model_name = self._normalize_model_name(config.get("model_name"))
        self.sample_paths: List[str] = config.get("sample_paths", [])
        self.prompt_template = config.get("prompt_template")
        self.epochs = max(1, int(config.get("epochs", 1)))
        self.learning_rate = float(config.get("learning_rate", 2e-4))
        self.api_config: Dict[str, str] = config.get("api_config", {}) or {}
        self.model_dir = os.path.join(settings.MODEL_BASE_PATH, self.model_name)

    def _normalize_model_name(self, name: str) -> str:
        if not name:
            raise ValueError("模型名称不能为空")
        cleaned = os.path.basename(name.strip())
        if not cleaned or cleaned in {"..", "."}:
            raise ValueError("模型名称无效")
        return cleaned

    def initialize(self):
        ensure_directory(self.model_dir)
        logger.info("初始化训练目录 %s", self.model_dir)

    def execute(self):
        self._validate_api_config()
        self._validate_samples()
        return self._run_dummy_training()

    def _validate_samples(self):
        if not self.sample_paths:
            raise ValueError("请至少上传一个样例文件")

        missing_files = [path for path in self.sample_paths if not os.path.exists(path)]
        if missing_files:
            raise FileNotFoundError(f"未找到样例文件: {', '.join(missing_files)}")

    def _validate_api_config(self):
        provider = self.api_config.get("provider")
        endpoint = self.api_config.get("endpoint")
        api_key = self.api_config.get("api_key")

        if not provider or not endpoint or not api_key:
            raise ValueError("API 配置不完整，请在客户端补全 provider、endpoint 和 api_key。")

        if provider not in {"openai", "azure_openai", "custom"}:
            raise ValueError(f"不支持的 API 提供商: {provider}")

        parsed = urlparse(endpoint)
        if parsed.scheme not in {"http", "https"} or not parsed.netloc:
            raise ValueError("API 终端地址格式不正确，请输入有效 URL。")

        if len(api_key.strip()) < 20:
            raise ValueError("API Key 长度过短，请确认填写正确的 Key。")

        logger.info("API 配置校验通过：provider=%s endpoint=%s", provider, endpoint)

    def _run_dummy_training(self):
        import time
        import json

        logger.info("开始执行训练任务 %s", self.task_id)
        time.sleep(1)

        metadata = {
            "task_id": self.task_id,
            "model_name": self.model_name,
            "status": "trained",
            "epochs": self.epochs,
            "learning_rate": self.learning_rate,
        }
        output_path = os.path.join(self.model_dir, "metadata.json")
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(metadata, f, ensure_ascii=False, indent=2)

        logger.info("训练完成，模型元数据写入 %s", output_path)
        return output_path
