from collections.abc import Generator

from fastapi import Depends, FastAPI, HTTPException
from sqlalchemy.orm import Session

from app.database import SessionLocal
from app.matching_service import classer_biens_pour_demande


app = FastAPI(
    title="Match-Immo API",
    description=(
        "API du démonstrateur Phase 4 Match-Immo. "
        "Elle expose les traitements métier comme le matching "
        "sans placer les règles métier directement dans l'API."
    ),
    version="0.1.0",
)


def get_session() -> Generator[Session, None, None]:
    """
    Ouvre une session temporaire avec PostgreSQL.

    Pour un acteur non technique :
    cette session permet au backend de consulter les données nécessaires
    pendant le traitement, puis de fermer proprement l'accès à la base.
    """
    with SessionLocal() as session:
        yield session


@app.get("/health")
def health() -> dict[str, str]:
    """
    Vérifie que l'API Match-Immo fonctionne.

    Cet endpoint est purement technique :
    il permet de savoir rapidement si le backend répond.
    """
    return {"status": "ok"}


@app.get("/demandes/{id_demande}/matching")
def matching_demande(
    id_demande: int,
    session: Session = Depends(get_session),
) -> dict:
    """
    Retourne les biens les plus compatibles avec une demande immobilière.

    Pour un acteur métier :
    - la demande du particulier est récupérée ;
    - les biens incompatibles sont écartés ;
    - les biens restants sont notés ;
    - les résultats sont classés du plus pertinent au moins pertinent.

    Pour un acteur technique :
    l'API ne calcule pas elle-même le matching.
    Elle appelle le service métier dédié.
    """
    try:
        resultats = classer_biens_pour_demande(
            session=session,
            demande_id=id_demande,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=404,
            detail=str(exc),
        ) from exc

    return {
        "demande_id": id_demande,
        "nombre_resultats": len(resultats),
        "resultats": resultats,
    }
