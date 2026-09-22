from datetime import date, datetime
from decimal import Decimal

from sqlalchemy import (
    Boolean,
    Date,
    DateTime,
    ForeignKey,
    Integer,
    Numeric,
    String,
    Text,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base

SCHEMA = "fil_rouge_cible"


class Demande(Base):
    __tablename__ = "demande"
    __table_args__ = {"schema": SCHEMA}

    id_demande: Mapped[int] = mapped_column(Integer, primary_key=True)
    client_id: Mapped[int] = mapped_column(Integer, nullable=False)
    date_creation: Mapped[date] = mapped_column(Date, nullable=False)
    statut: Mapped[str] = mapped_column(String(30), nullable=False)


class VersionDemande(Base):
    __tablename__ = "version_demande"
    __table_args__ = {"schema": SCHEMA}

    id_version: Mapped[int] = mapped_column(Integer, primary_key=True)

    demande_id: Mapped[int] = mapped_column(
        ForeignKey(f"{SCHEMA}.demande.id_demande"),
        nullable=False,
    )

    auteur_id: Mapped[int] = mapped_column(Integer, nullable=False)
    numero_version: Mapped[int] = mapped_column(Integer, nullable=False)
    date_version: Mapped[datetime] = mapped_column(DateTime, nullable=False)

    budget_min: Mapped[Decimal | None] = mapped_column(Numeric(12, 2))
    budget_max: Mapped[Decimal | None] = mapped_column(Numeric(12, 2))
    surface_min: Mapped[Decimal | None] = mapped_column(Numeric(10, 2))
    surface_max: Mapped[Decimal | None] = mapped_column(Numeric(10, 2))
    nb_pieces_min: Mapped[int | None] = mapped_column(Integer)

    motif_modification: Mapped[str | None] = mapped_column(Text)

    est_courante: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        default=False,
    )

    type_bien_souhaite: Mapped[str | None] = mapped_column(String(50))
    dpe_min: Mapped[str | None] = mapped_column(String(10))


class Secteur(Base):
    __tablename__ = "secteur"
    __table_args__ = {"schema": SCHEMA}

    id_secteur: Mapped[int] = mapped_column(Integer, primary_key=True)
    ville: Mapped[str] = mapped_column(String(80), nullable=False)
    quartier: Mapped[str | None] = mapped_column(String(80))
    code_postal: Mapped[str] = mapped_column(String(10), nullable=False)


class VersionDemandeSecteur(Base):
    __tablename__ = "version_demande_secteur"
    __table_args__ = {"schema": SCHEMA}

    version_id: Mapped[int] = mapped_column(
        ForeignKey(f"{SCHEMA}.version_demande.id_version"),
        primary_key=True,
    )

    secteur_id: Mapped[int] = mapped_column(
        ForeignKey(f"{SCHEMA}.secteur.id_secteur"),
        primary_key=True,
    )


class Bien(Base):
    __tablename__ = "bien"
    __table_args__ = {"schema": SCHEMA}

    id_bien: Mapped[int] = mapped_column(Integer, primary_key=True)

    secteur_id: Mapped[int] = mapped_column(
        ForeignKey(f"{SCHEMA}.secteur.id_secteur"),
        nullable=False,
    )

    adresse: Mapped[str] = mapped_column(String(255), nullable=False)
    type_bien: Mapped[str] = mapped_column(String(50), nullable=False)
    prix: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    surface: Mapped[Decimal | None] = mapped_column(Numeric(10, 2))
    nombre_pieces: Mapped[int | None] = mapped_column(Integer)
    dpe: Mapped[str | None] = mapped_column(String(10))
    description: Mapped[str | None] = mapped_column(Text)
