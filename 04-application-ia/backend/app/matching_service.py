from sqlalchemy import select
from sqlalchemy.orm import Session

from app.matching import bien_est_compatible, calculer_score_matching
from app.models import Bien, VersionDemande, VersionDemandeSecteur


def classer_biens_pour_demande(
    session: Session,
    demande_id: int,
) -> list[dict]:
    """
    Retourne les biens compatibles avec la version courante
    d'une demande, classés du meilleur score au moins bon.
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

    resultats = []

    for bien in biens:
        if not bien_est_compatible(
            bien,
            version,
            secteurs_demandes,
        ):
            continue

        matching = calculer_score_matching(
            bien,
            version,
            secteurs_demandes,
        )

        resultats.append(
            {
                "id_bien": bien.id_bien,
                "adresse": bien.adresse,
                "type_bien": bien.type_bien,
                "prix": bien.prix,
                "surface": bien.surface,
                "nombre_pieces": bien.nombre_pieces,
                "dpe": bien.dpe,
                "score": matching["score"],
                "details": matching["details"],
            }
        )

    return sorted(
        resultats,
        key=lambda resultat: resultat["score"],
        reverse=True,
    )
