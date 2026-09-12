from decimal import Decimal

from app.matching import ORDRE_DPE, POIDS, bien_est_compatible
from app.models import Bien, VersionDemande

SEUIL_FAVORABLE = Decimal("70")
SEUIL_DIFFICILE = Decimal("40")
SEUIL_CRITERE_RESTRICTIF = Decimal("0.50")


def _ratio(
    compatibles: int,
    connus: int,
) -> Decimal | None:
    """
    Retourne une proportion comprise entre 0 et 1.

    Si aucune donnée n'est connue, retourne None :
    une donnée absente ne doit pas être inventée.
    """
    if connus == 0:
        return None

    return Decimal(compatibles) / Decimal(connus)


def _detail(
    score: Decimal | None,
    connus: int,
    inconnus: int,
) -> dict:
    """Prépare une sortie explicable pour un critère."""
    return {
        "score": (
            score.quantize(Decimal("0.01"))
            if score is not None
            else None
        ),
        "connus": connus,
        "inconnus": inconnus,
    }


def calculer_faisabilite(
    version: VersionDemande,
    biens: list[Bien],
    secteurs_demandes: set[int],
) -> dict:
    """
    Évalue à quel point une demande est facile ou difficile
    à satisfaire avec les biens disponibles.

    Le score final est compris entre 0 et 100.

    Chaque critère mesure la proportion de biens disponibles
    qui respecte le besoin exprimé.

    Une donnée absente reste inconnue :
    elle n'est ni inventée ni considérée automatiquement
    comme compatible.
    """

    nombre_biens = len(biens)

    if nombre_biens == 0:
        return {
            "score": Decimal("0.00"),
            "niveau": "très restrictive",
            "nombre_biens": 0,
            "nombre_biens_compatibles": 0,
            "criteres_restrictifs": ["aucun bien disponible"],
            "details": {},
        }

    details = {}
    scores_actifs: dict[str, Decimal] = {}

    # Secteur
    if secteurs_demandes:
        compatibles = sum(
            bien.secteur_id in secteurs_demandes
            for bien in biens
        )

        score = _ratio(compatibles, nombre_biens)

        details["secteur"] = _detail(
            score=score,
            connus=nombre_biens,
            inconnus=0,
        )

        if score is not None:
            scores_actifs["secteur"] = score

    # Prix
    if version.budget_max is not None:
        connus = sum(
            bien.prix is not None
            for bien in biens
        )

        compatibles = sum(
            bien.prix is not None
            and bien.prix <= version.budget_max
            for bien in biens
        )

        score = _ratio(compatibles, connus)

        details["prix"] = _detail(
            score=score,
            connus=connus,
            inconnus=nombre_biens - connus,
        )

        if score is not None:
            scores_actifs["prix"] = score

    # Surface
    if version.surface_min is not None:
        connus = sum(
            bien.surface is not None
            for bien in biens
        )

        compatibles = sum(
            bien.surface is not None
            and bien.surface >= version.surface_min
            for bien in biens
        )

        score = _ratio(compatibles, connus)

        details["surface"] = _detail(
            score=score,
            connus=connus,
            inconnus=nombre_biens - connus,
        )

        if score is not None:
            scores_actifs["surface"] = score

    # Type de bien
    if version.type_bien_souhaite is not None:
        connus = sum(
            bien.type_bien is not None
            for bien in biens
        )

        compatibles = sum(
            bien.type_bien is not None
            and bien.type_bien.lower()
            == version.type_bien_souhaite.lower()
            for bien in biens
        )

        score = _ratio(compatibles, connus)

        details["type_bien"] = _detail(
            score=score,
            connus=connus,
            inconnus=nombre_biens - connus,
        )

        if score is not None:
            scores_actifs["type_bien"] = score

    # Nombre de pièces
    if version.nb_pieces_min is not None:
        connus = sum(
            bien.nombre_pieces is not None
            for bien in biens
        )

        compatibles = sum(
            bien.nombre_pieces is not None
            and bien.nombre_pieces >= version.nb_pieces_min
            for bien in biens
        )

        score = _ratio(compatibles, connus)

        details["pieces"] = _detail(
            score=score,
            connus=connus,
            inconnus=nombre_biens - connus,
        )

        if score is not None:
            scores_actifs["pieces"] = score

    # DPE
    if version.dpe_min is not None:
        dpe_souhaite = ORDRE_DPE.get(
            version.dpe_min.upper()
        )

        valeurs_connues = [
            ORDRE_DPE.get(bien.dpe.upper())
            for bien in biens
            if bien.dpe is not None
            and ORDRE_DPE.get(bien.dpe.upper()) is not None
        ]

        connus = len(valeurs_connues)

        compatibles = (
            sum(
                valeur <= dpe_souhaite
                for valeur in valeurs_connues
            )
            if dpe_souhaite is not None
            else 0
        )

        score = (
            _ratio(compatibles, connus)
            if dpe_souhaite is not None
            else None
        )

        details["dpe"] = _detail(
            score=score,
            connus=connus,
            inconnus=nombre_biens - connus,
        )

        if score is not None:
            scores_actifs["dpe"] = score

    # Aucun critère exploitable :
    # la demande n'est pas restrictive.
    if not scores_actifs:
        score_final = Decimal("100.00")
    else:
        poids_utilises = sum(
            (POIDS[critere] for critere in scores_actifs),
            Decimal("0"),
        )

        score_final = (
            sum(
                scores_actifs[critere] * POIDS[critere]
                for critere in scores_actifs
            )
            / poids_utilises
            * Decimal("100")
        ).quantize(Decimal("0.01"))

    score_final = max(
        Decimal("0.00"),
        min(Decimal("100.00"), score_final),
    )

    if score_final >= SEUIL_FAVORABLE:
        niveau = "favorable"
    elif score_final >= SEUIL_DIFFICILE:
        niveau = "difficile"
    else:
        niveau = "très restrictive"

    criteres_restrictifs = [
        critere
        for critere, score in scores_actifs.items()
        if score < SEUIL_CRITERE_RESTRICTIF
    ]

    nombre_biens_compatibles = sum(
        bien_est_compatible(
            bien=bien,
            version=version,
            secteurs_demandes=secteurs_demandes,
        )
        for bien in biens
    )

    return {
        "score": score_final,
        "niveau": niveau,
        "nombre_biens": nombre_biens,
        "nombre_biens_compatibles": nombre_biens_compatibles,
        "criteres_restrictifs": criteres_restrictifs,
        "details": details,
    }
