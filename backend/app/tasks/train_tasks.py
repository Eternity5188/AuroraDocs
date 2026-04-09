from app.tasks.celery_app import celery_app
from app.services.training_service import TrainingService
from app.core.db import SessionLocal
from app.models.task import TrainingTask
from app.core.logger import get_logger

logger = get_logger("tasks.run_training_task")


def update_db_status(task_id: str, status: str, message: str = None):
    session = SessionLocal()
    try:
        db_task = session.query(TrainingTask).filter(TrainingTask.id == task_id).first()
        if db_task:
            db_task.status = status
            db_task.message = message
            session.add(db_task)
            session.commit()
    except Exception:
        logger.exception("更新任务状态失败: %s", task_id)
        session.rollback()
    finally:
        session.close()


@celery_app.task(name="assignment_ai.tasks.run_training_task", bind=True)
def run_training_task(self, task_id: str, config: dict):
    update_db_status(task_id, "running", "任务正在执行")
    service = TrainingService(task_id=task_id, config=config)
    try:
        service.initialize()
        result_path = service.execute()
        update_db_status(task_id, "completed", f"训练完成，结果保存在 {result_path}")
        return {"task_id": task_id, "status": "completed"}
    except Exception as error:
        message = str(error)
        logger.exception("训练任务执行失败: %s", task_id)
        update_db_status(task_id, "failed", message)
        raise
