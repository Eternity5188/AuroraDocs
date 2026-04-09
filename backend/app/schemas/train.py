from pydantic import BaseModel, Field
from typing import Dict, Optional, List


class TrainTaskCreate(BaseModel):
    model_name: str = Field(..., description="Name of the custom model")
    sample_paths: List[str] = Field(..., description="Uploaded sample file paths for training")
    prompt_template: Optional[str] = Field(None, description="Prompt template for fine-tuning")
    epochs: Optional[int] = Field(1, description="Number of fine-tuning epochs")
    learning_rate: Optional[float] = Field(2e-4, description="Learning rate for LoRA training")
    api_config: Optional[Dict[str, str]] = Field(None, description="User provided API configuration for model generation")


class TrainTaskStatus(BaseModel):
    task_id: str
    status: str
    message: Optional[str] = None
