import os

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker


DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql+psycopg://match_immo:match_immo@127.0.0.1:5433/match_immo",
)


class Base(DeclarativeBase):
    """Classe de base commune aux modèles SQLAlchemy."""


engine = create_engine(DATABASE_URL)

SessionLocal = sessionmaker(
    bind=engine,
    autoflush=False,
    expire_on_commit=False,
)
