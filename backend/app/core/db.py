from sqlalchemy import create_engine, text
from sqlalchemy.engine import make_url
from sqlalchemy.orm import sessionmaker
from .config import settings
import importlib


def _import_symbol(module_candidates, symbol_name):
    last_error = None
    for module_name in module_candidates:
        try:
            module = importlib.import_module(module_name)
            return getattr(module, symbol_name)
        except Exception as exc:
            last_error = exc
    raise ModuleNotFoundError(
        f"Unable to import {symbol_name} from candidates: {module_candidates}"
    ) from last_error


Base = _import_symbol(
    [
        "app.models.base",
        "models.base",
        "app.model.base",
        "model.base",
    ],
    "Base",
)

engine = create_engine(settings.DATABASE_URL, future=True, echo=False)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def create_database_if_not_exists():
    url_object = make_url(settings.DATABASE_URL)
    database_name = url_object.database
    if not database_name:
        return

    admin_url = url_object.set(database="postgres")
    admin_engine = create_engine(admin_url, future=True, echo=False)

    with admin_engine.connect() as connection:
        result = connection.execute(
            text("SELECT 1 FROM pg_database WHERE datname = :name"),
            {"name": database_name},
        )
        if result.scalar() is None:
            connection.execution_options(isolation_level="AUTOCOMMIT").execute(
                text(f"CREATE DATABASE \"{database_name}\"")
            )


def init_db():
    create_database_if_not_exists()

    # Import all models so that they are registered on the metadata.
    for module_name in [
        "app.models.task",
        "models.task",
        "app.model.task",
        "model.task",
    ]:
        try:
            importlib.import_module(module_name)
            break
        except Exception:
            continue

    Base.metadata.create_all(bind=engine)
