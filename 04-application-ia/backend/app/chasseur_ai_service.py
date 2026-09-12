from sqlalchemy.orm import Session

from app.chasseur_ai import generer_synthese_chasseur
from app.feasibility_service import analyser_faisabilite_demande
from app.matching_service import classer_biens_pour_demande


def generer_synthese_pour_demande(
    session: Session,
    demande_id: int,
) -> dict:
    """
    Produit la synthèse chasseur-IA d'une demande réelle.

    Parcours :
    PostgreSQL
        -> faisabilité
        -> matching
        -> synthèse chasseur-IA
        -> validation humaine requise
    """

    faisabilite = analyser_faisabilite_demande(
        session=session,
        demande_id=demande_id,
    )

    matching = classer_biens_pour_demande(
        session=session,
        demande_id=demande_id,
    )

    matching_minimise = [
        {
            cle: bien.get(cle)
            for cle in (
                "id_bien",
                "adresse",
                "type_bien",
                "prix",
                "surface",
                "nombre_pieces",
                "dpe",
                "score",
                "details",
                "explication",
            )
        }
        for bien in matching
    ]

    synthese = generer_synthese_chasseur(
        faisabilite=faisabilite,
        resultats_matching=matching_minimise,
    )

    return {
        "demande_id": demande_id,
        "faisabilite": faisabilite,
        "matching": matching,
        "synthese": synthese,
    }
