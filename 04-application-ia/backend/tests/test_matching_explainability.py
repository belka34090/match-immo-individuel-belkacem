from decimal import Decimal
from types import SimpleNamespace

from app.matching import calculer_score_matching


def make_bien(
    *,
    prix: str = "250000.00",
    secteur_id: int = 1,
    type_bien: str = "Appartement",
    surface: str | None = "65.00",
    nombre_pieces: int | None = 3,
    dpe: str | None = "C",
):
    return SimpleNamespace(
        prix=Decimal(prix),
        secteur_id=secteur_id,
        type_bien=type_bien,
        surface=Decimal(surface) if surface is not None else None,
        nombre_pieces=nombre_pieces,
        dpe=dpe,
    )


def make_version(
    *,
    budget_max: str | None = "300000.00",
    surface_min: str | None = "70.00",
    nb_pieces_min: int | None = 3,
    type_bien_souhaite: str | None = "Appartement",
    dpe_min: str | None = "C",
):
    return SimpleNamespace(
        budget_max=Decimal(budget_max) if budget_max is not None else None,
        surface_min=Decimal(surface_min) if surface_min is not None else None,
        nb_pieces_min=nb_pieces_min,
        type_bien_souhaite=type_bien_souhaite,
        dpe_min=dpe_min,
    )


def test_explication_identifie_les_contributions() -> None:
    resultat = calculer_score_matching(
        make_bien(),
        make_version(),
        {1},
    )

    assert set(resultat["details"]) == {
        "secteur",
        "prix",
        "surface",
        "type_bien",
        "pieces",
        "dpe",
    }

    assert resultat["details"]["surface"] == Decimal("18.57")


def test_somme_contributions_coherente_avec_score() -> None:
    resultat = calculer_score_matching(
        make_bien(),
        make_version(),
        {1},
    )

    total = sum(
        (
            contribution
            for contribution in resultat["details"].values()
            if contribution is not None
        ),
        Decimal("0"),
    )

    assert total == resultat["score"]


def test_critere_faible_signale_comme_point_vigilance() -> None:
    resultat = calculer_score_matching(
        make_bien(surface="65.00"),
        make_version(surface_min="70.00"),
        {1},
    )

    assert "surface" in resultat["explication"]["points_vigilance"]


def test_donnee_inconnue_est_signalee_sans_invention() -> None:
    resultat = calculer_score_matching(
        make_bien(dpe=None),
        make_version(dpe_min="C"),
        {1},
    )

    assert resultat["details"]["dpe"] is None
    assert "dpe" in resultat["explication"]["criteres_non_disponibles"]

    assert Decimal("0") <= resultat["score"] <= Decimal("100")
