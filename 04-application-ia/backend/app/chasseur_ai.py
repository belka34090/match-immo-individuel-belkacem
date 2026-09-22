from decimal import Decimal


def _formatter_score(value) -> str:
    """
    Formate un score de manière lisible sans modifier sa valeur métier.
    """
    return f"{Decimal(str(value)).quantize(Decimal('0.01'))}"


def generer_synthese_chasseur(
    faisabilite: dict,
    resultats_matching: list[dict],
    limite_biens: int = 3,
) -> dict:
    """
    Produit une synthèse déterministe pour le chasseur immobilier.

    Cette fonction :
    - conserve les scores calculés par les moteurs métier ;
    - n'invente aucune donnée ;
    - identifie les principaux points de vigilance ;
    - fonctionne sans LLM.
    """

    score_faisabilite = faisabilite["score"]
    niveau = faisabilite["niveau"]
    criteres_restrictifs = faisabilite.get(
        "criteres_restrictifs",
        [],
    )

    biens_retenus = resultats_matching[:limite_biens]

    points_vigilance = []

    for critere in criteres_restrictifs:
        points_vigilance.append(
            f"Critère restrictif identifié : {critere}."
        )

    if not resultats_matching:
        points_vigilance.append(
            "Aucun bien compatible n'est actuellement disponible."
        )

    meilleurs_biens = []

    for bien in biens_retenus:
        meilleurs_biens.append(
            {
                "id_bien": bien["id_bien"],
                "adresse": bien.get("adresse"),
                "score": bien["score"],
                "type_bien": bien.get("type_bien"),
                "prix": bien.get("prix"),
                "surface": bien.get("surface"),
                "nombre_pieces": bien.get("nombre_pieces"),
                "dpe": bien.get("dpe"),
                "details": bien.get("details", {}),
            }
        )

    if resultats_matching:
        meilleur_score = resultats_matching[0]["score"]

        message_principal = (
            f"La recherche présente un niveau de faisabilité "
            f"« {niveau} » avec un score de "
            f"{_formatter_score(score_faisabilite)} / 100. "
            f"Le meilleur bien actuellement identifié obtient "
            f"{_formatter_score(meilleur_score)} / 100."
        )
    else:
        message_principal = (
            f"La recherche présente un niveau de faisabilité "
            f"« {niveau} » avec un score de "
            f"{_formatter_score(score_faisabilite)} / 100. "
            "Aucun bien compatible n'est actuellement disponible."
        )

    return {
        "score_faisabilite": score_faisabilite,
        "niveau_faisabilite": niveau,
        "message_principal": message_principal,
        "points_vigilance": points_vigilance,
        "meilleurs_biens": meilleurs_biens,
        "validation_humaine_requise": True,
        "llm_utilise": False,
    }
