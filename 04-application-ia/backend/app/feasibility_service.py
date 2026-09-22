from sqlalchemy import select
from sqlalchemy.orm import Session

from app.feasibility import calculer_faisabilite
from app.models import Bien, VersionDemande, VersionDemandeSecteur


def analyser_faisabilite_demande(
    session: Session,
    demande_id: int,
) -> dict:
    """
    Analyse la faisabilité de la version courante d'une demande.

    Parcours :
    PostgreSQL
        -> version courante
        -> secteurs demandés
        -> biens disponibles
        -> moteur de faisabilité
        -> résultat explicable
    """

    version = session.scalar(
        select(VersionDemande).where(
            VersionDemande.demande_id == demande_id,
            VersionDemande.est_courante.is_(True),
        )
    )

    if version is None:
        raise ValueError(
            f"Aucune version courante trouvée pour la demande {demande_id}"
        )

    secteurs_demandes = set(
        session.scalars(
            select(VersionDemandeSecteur.secteur_id).where(
                VersionDemandeSecteur.version_id == version.id_version
            )
        ).all()
    )

    biens = session.scalars(
        select(Bien).order_by(Bien.id_bien)
    ).all()

    return calculer_faisabilite(
        version=version,
        biens=biens,
        secteurs_demandes=secteurs_demandes,
    )
