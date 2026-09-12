from decimal import Decimal
from types import SimpleNamespace

from app.feasibility import calculer_faisabilite


def _version(**overrides):
    base = {
        "budget_max": Decimal("300000"),
        "surface_min": Decimal("70"),
        "nb_pieces_min": 3,
        "type_bien_souhaite": "Appartement",
        "dpe_min": "C",
    }
    base.update(overrides)
    return SimpleNamespace(**base)


def _bien(
    id_bien: int,
    *,
    secteur_id: int = 1,
    prix: str = "250000",
    surface: str | None = "75",
    nombre_pieces: int | None = 3,
    type_bien: str | None = "Appartement",
    dpe: str | None = "C",
):
    return SimpleNamespace(
        id_bien=id_bien,
        secteur_id=secteur_id,
        prix=Decimal(prix) if prix is not None else None,
        surface=Decimal(surface) if surface is not None else None,
        nombre_pieces=nombre_pieces,
        type_bien=type_bien,
        dpe=dpe,
    )


def test_faisabilite_favorable() -> None:
    biens = [
        _bien(1),
        _bien(2, prix="280000", surface="80", dpe="B"),
        _bien(3, prix="295000", surface="72"),
    ]

    resultat = calculer_faisabilite(
        version=_version(),
        biens=biens,
        secteurs_demandes={1},
    )

    assert resultat["niveau"] == "favorable"
    assert resultat["score"] >= Decimal("70")
    assert resultat["nombre_biens_compatibles"] == 3


def test_recherche_restrictive() -> None:
    biens = [
        _bien(
            1,
            secteur_id=2,
            prix="450000",
            surface="45",
            nombre_pieces=2,
            type_bien="Maison",
            dpe="E",
        ),
        _bien(
            2,
            secteur_id=3,
            prix="500000",
            surface="50",
            nombre_pieces=2,
            type_bien="Maison",
            dpe="F",
        ),
        _bien(
            3,
            secteur_id=4,
            prix="420000",
            surface="55",
            nombre_pieces=2,
            type_bien="Studio",
            dpe="D",
        ),
    ]

    resultat = calculer_faisabilite(
        version=_version(),
        biens=biens,
        secteurs_demandes={1},
    )

    assert resultat["niveau"] == "très restrictive"
    assert resultat["score"] < Decimal("40")
    assert resultat["nombre_biens_compatibles"] == 0


def test_secteur_identifie_comme_restrictif() -> None:
    biens = [
        _bien(1, secteur_id=1),
        _bien(2, secteur_id=2),
        _bien(3, secteur_id=2),
        _bien(4, secteur_id=3),
    ]

    resultat = calculer_faisabilite(
        version=_version(),
        biens=biens,
        secteurs_demandes={1},
    )

    assert resultat["details"]["secteur"]["score"] == Decimal("0.25")
    assert "secteur" in resultat["criteres_restrictifs"]


def test_surface_identifiee_comme_restrictive() -> None:
    biens = [
        _bien(1, surface="40"),
        _bien(2, surface="50"),
        _bien(3, surface="60"),
        _bien(4, surface="80"),
    ]

    resultat = calculer_faisabilite(
        version=_version(),
        biens=biens,
        secteurs_demandes={1},
    )

    assert resultat["details"]["surface"]["score"] == Decimal("0.25")
    assert "surface" in resultat["criteres_restrictifs"]


def test_dpe_manquant_reste_inconnu() -> None:
    biens = [
        _bien(1, dpe=None),
        _bien(2, dpe=None),
    ]

    resultat = calculer_faisabilite(
        version=_version(),
        biens=biens,
        secteurs_demandes={1},
    )

    assert resultat["details"]["dpe"]["score"] is None
    assert resultat["details"]["dpe"]["connus"] == 0
    assert resultat["details"]["dpe"]["inconnus"] == 2


def test_score_faisabilite_reste_borne() -> None:
    scenarios = [
        [
            _bien(1),
        ],
        [
            _bien(
                1,
                secteur_id=9,
                prix="900000",
                surface="20",
                nombre_pieces=1,
                type_bien="Maison",
                dpe="G",
            ),
        ],
        [],
    ]

    for biens in scenarios:
        resultat = calculer_faisabilite(
            version=_version(),
            biens=biens,
            secteurs_demandes={1},
        )

        assert Decimal("0") <= resultat["score"] <= Decimal("100")
