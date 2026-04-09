from sqlalchemy import create_engine, text
from sqlalchemy.engine import make_url
from sqlalchemy.orm import sessionmaker
from app.core.config import settings
from ..models.base import Base

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
    from ..models import task  # noqa: F401

    Base.metadata.create_all(bind=engine)
