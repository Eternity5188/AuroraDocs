from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from fastapi.responses import JSONResponse
from uuid import uuid4
from sqlalchemy.orm import Session
from app.schemas.train import TrainTaskCreate, TrainTaskStatus
from app.tasks.train_tasks import run_training_task
from app.core.config import settings
from app.core.db import get_db
from app.models.task import TrainingTask
from app.utils.file_utils import ensure_directory
from celery.result import AsyncResult
from app.core.logger import get_logger

logger = get_logger("api.train")
router = APIRouter()


@router.post("/tasks", response_model=TrainTaskStatus)
def create_training_task(task: TrainTaskCreate, db: Session = Depends(get_db)):
    task_id = str(uuid4())
    try:
        celery_task = run_training_task.apply_async(kwargs={"task_id": task_id, "config": task.dict()})
        provider = None
        endpoint = None
        if task.api_config:
            provider = task.api_config.get("provider")
            endpoint = task.api_config.get("endpoint")

        db_task = TrainingTask(
            id=task_id,
            celery_id=celery_task.id,
            status="queued",
            config=task.dict(exclude={"api_config"}),
            user_api_provider=provider,
            user_api_endpoint=endpoint,
        )
        db.add(db_task)
        db.commit()
        logger.info("创建训练任务 %s, Celery ID=%s", task_id, celery_task.id)
    except Exception as error:
        db.rollback()
        logger.exception("创建训练任务失败")
        raise HTTPException(status_code=500, detail="训练任务创建失败，请稍后重试")

    return TrainTaskStatus(task_id=task_id, status="queued")


@router.get("/tasks/{task_id}", response_model=TrainTaskStatus)
def get_training_task_status(task_id: str, db: Session = Depends(get_db)):
    db_task = db.query(TrainingTask).filter(TrainingTask.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")

    celery_result = AsyncResult(db_task.celery_id)
    status = db_task.status
    message = db_task.message

    if celery_result.failed:
        status = "failed"
        message = message or str(celery_result.result)
    elif celery_result.successful:
        status = "completed"
        message = message or "任务已成功完成"
    elif celery_result.status:
        status = celery_result.status.lower()

    return TrainTaskStatus(task_id=task_id, status=status, message=message)


@router.post("/samples")
def upload_sample(file: UploadFile = File(...)):
    if not file.filename:
        raise HTTPException(status_code=400, detail="No file uploaded")

    try:
        ensure_directory(settings.SAMPLE_UPLOAD_PATH)
        file_location = f"{settings.SAMPLE_UPLOAD_PATH}/{uuid4()}_{file.filename}"
        with open(file_location, "wb") as f:
            f.write(file.file.read())
    except Exception:
        logger.exception("样例上传失败")
        raise HTTPException(status_code=500, detail="样例上传失败，请重试")

    return JSONResponse({"file_path": file_location, "detail": "uploaded"})
