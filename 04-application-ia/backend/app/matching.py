from decimal import Decimal

from app.models import Bien, VersionDemande


def bien_est_compatible(
    bien: Bien,
    version: VersionDemande,
    secteurs_demandes: set[int],
) -> bool:
    """
    Vérifie si un bien respecte les critères obligatoires
    d'une version de demande.

    Retourne True si le bien peut passer à l'étape de scoring.
    Retourne False s'il doit être exclu.
    """

    # 1. Budget maximum
    if version.budget_max is not None and bien.prix > version.budget_max:
        return False

    # 2. Secteur demandé
    if secteurs_demandes and bien.secteur_id not in secteurs_demandes:
        return False

    # 3. Type de bien souhaité
    if (
        version.type_bien_souhaite is not None
        and bien.type_bien.lower() != version.type_bien_souhaite.lower()
    ):
        return False

    return True


POIDS = {
    "secteur": Decimal("30"),
    "prix": Decimal("25"),
    "surface": Decimal("20"),
    "type_bien": Decimal("10"),
    "pieces": Decimal("10"),
    "dpe": Decimal("5"),
}

ORDRE_DPE = {
    "A": 1,
    "B": 2,
    "C": 3,
    "D": 4,
    "E": 5,
    "F": 6,
    "G": 7,
}


def score_prix(bien: Bien, version: VersionDemande) -> Decimal:
    """Évalue la compatibilité du prix entre 0 et 1."""
    if version.budget_max is None:
        return Decimal("1")

    if bien.prix > version.budget_max:
        return Decimal("0")

    return Decimal("1")


def score_surface(bien: Bien, version: VersionDemande) -> Decimal:
    """Évalue la compatibilité de la surface entre 0 et 1."""
    if version.surface_min is None or bien.surface is None:
        return Decimal("1")

    if bien.surface >= version.surface_min:
        return Decimal("1")

    if version.surface_min == 0:
        return Decimal("1")

    ratio = bien.surface / version.surface_min
    return max(Decimal("0"), min(Decimal("1"), ratio))


def score_secteur(
    bien: Bien,
    secteurs_demandes: set[int],
) -> Decimal:
    """Évalue la compatibilité du secteur entre 0 et 1."""
    if not secteurs_demandes:
        return Decimal("1")

    return Decimal("1") if bien.secteur_id in secteurs_demandes else Decimal("0")


def score_type_bien(
    bien: Bien,
    version: VersionDemande,
) -> Decimal:
    """Évalue la compatibilité du type de bien entre 0 et 1."""
    if version.type_bien_souhaite is None:
        return Decimal("1")

    return (
        Decimal("1")
        if bien.type_bien.lower() == version.type_bien_souhaite.lower()
        else Decimal("0")
    )


def score_pieces(
    bien: Bien,
    version: VersionDemande,
) -> Decimal:
    """Évalue la compatibilité du nombre de pièces entre 0 et 1."""
    if version.nb_pieces_min is None or bien.nombre_pieces is None:
        return Decimal("1")

    if bien.nombre_pieces >= version.nb_pieces_min:
        return Decimal("1")

    if version.nb_pieces_min == 0:
        return Decimal("1")

    return Decimal(bien.nombre_pieces) / Decimal(version.nb_pieces_min)


def score_dpe(
    bien: Bien,
    version: VersionDemande,
) -> Decimal:
    """Évalue la compatibilité du DPE entre 0 et 1."""
    if version.dpe_min is None or bien.dpe is None:
        return Decimal("1")

    souhaite = ORDRE_DPE.get(version.dpe_min.upper())
    observe = ORDRE_DPE.get(bien.dpe.upper())

    if souhaite is None or observe is None:
        return Decimal("0")

    if observe <= souhaite:
        return Decimal("1")

    ecart = observe - souhaite

    return max(
        Decimal("0"),
        Decimal("1") - Decimal(ecart) * Decimal("0.25"),
    )


def calculer_score_matching(
    bien: Bien,
    version: VersionDemande,
    secteurs_demandes: set[int],
) -> dict:
    """
    Calcule un score de matching explicable sur 100.

    Une donnée explicitement demandée mais absente n'est jamais
    inventée et ne reçoit aucun bonus artificiel.

    Les critères non demandés restent neutres.
    """

    scores = {
        "secteur": score_secteur(bien, secteurs_demandes),
        "prix": score_prix(bien, version),
        "surface": (
            None
            if version.surface_min is not None and bien.surface is None
            else score_surface(bien, version)
        ),
        "type_bien": score_type_bien(bien, version),
        "pieces": (
            None
            if version.nb_pieces_min is not None
            and bien.nombre_pieces is None
            else score_pieces(bien, version)
        ),
        "dpe": (
            None
            if version.dpe_min is not None and bien.dpe is None
            else score_dpe(bien, version)
        ),
    }

    criteres_non_disponibles = [
        critere
        for critere, score in scores.items()
        if score is None
    ]

    criteres_evalues = [
        critere
        for critere, score in scores.items()
        if score is not None
    ]

    poids_evalue = sum(
        (POIDS[critere] for critere in criteres_evalues),
        Decimal("0"),
    )

    contributions_brutes = {
        critere: (
            scores[critere] * POIDS[critere]
            if scores[critere] is not None
            else None
        )
        for critere in POIDS
    }

    if poids_evalue == 0:
        score_final = Decimal("0.00")
        contributions = {
            critere: None
            for critere in POIDS
        }
    else:
        facteur_normalisation = Decimal("100") / poids_evalue

        contributions = {
            critere: (
                (
                    contributions_brutes[critere]
                    * facteur_normalisation
                ).quantize(Decimal("0.01"))
                if contributions_brutes[critere] is not None
                else None
            )
            for critere in POIDS
        }

        score_final = sum(
            (
                contributions_brutes[critere]
                for critere in criteres_evalues
            ),
            Decimal("0"),
        )

        score_final = (
            score_final * facteur_normalisation
        ).quantize(Decimal("0.01"))

    points_vigilance = [
        critere
        for critere in criteres_evalues
        if scores[critere] < Decimal("1")
    ]

    return {
        "score": score_final,
        "details": contributions,
        "explication": {
            "criteres_evalues": criteres_evalues,
            "criteres_non_disponibles": criteres_non_disponibles,
            "points_vigilance": points_vigilance,
        },
    }
