from decimal import Decimal

from app.chasseur_ai import generer_synthese_chasseur


def _faisabilite(**overrides) -> dict:
    base = {
        "score": Decimal("53.33"),
        "niveau": "difficile",
        "criteres_restrictifs": ["secteur"],
    }
    base.update(overrides)
    return base


def _matching() -> list[dict]:
    return [
        {
            "id_bien": 2,
            "adresse": "Adresse 2",
            "type_bien": "Appartement",
            "prix": Decimal("275000"),
            "surface": Decimal("72"),
            "nombre_pieces": 3,
            "dpe": "B",
            "score": Decimal("100.00"),
            "details": {
                "secteur": Decimal("30.00"),
                "prix": Decimal("25.00"),
                "surface": Decimal("20.00"),
                "type_bien": Decimal("10.00"),
                "pieces": Decimal("10.00"),
                "dpe": Decimal("5.00"),
            },
        },
        {
            "id_bien": 1,
            "adresse": "Adresse 1",
            "type_bien": "Appartement",
            "prix": Decimal("250000"),
            "surface": Decimal("65"),
            "nombre_pieces": 3,
            "dpe": "C",
            "score": Decimal("98.57"),
            "details": {
                "secteur": Decimal("30.00"),
                "prix": Decimal("25.00"),
                "surface": Decimal("18.57"),
                "type_bien": Decimal("10.00"),
                "pieces": Decimal("10.00"),
                "dpe": Decimal("5.00"),
            },
        },
    ]


def test_synthese_matching_coherente() -> None:
    resultat = generer_synthese_chasseur(
        faisabilite=_faisabilite(),
        resultats_matching=_matching(),
    )

    assert "difficile" in resultat["message_principal"]
    assert "53.33 / 100" in resultat["message_principal"]
    assert "100.00 / 100" in resultat["message_principal"]
    assert len(resultat["meilleurs_biens"]) == 2


def test_synthese_ne_modifie_pas_les_scores() -> None:
    matching = _matching()

    resultat = generer_synthese_chasseur(
        faisabilite=_faisabilite(),
        resultats_matching=matching,
    )

    assert resultat["score_faisabilite"] == Decimal("53.33")
    assert resultat["meilleurs_biens"][0]["score"] == Decimal("100.00")
    assert resultat["meilleurs_biens"][1]["score"] == Decimal("98.57")


def test_donnee_absente_n_est_pas_inventee() -> None:
    matching = _matching()
    matching[0]["dpe"] = None
    matching[0]["surface"] = None

    resultat = generer_synthese_chasseur(
        faisabilite=_faisabilite(),
        resultats_matching=matching,
    )

    meilleur_bien = resultat["meilleurs_biens"][0]

    assert meilleur_bien["dpe"] is None
    assert meilleur_bien["surface"] is None


def test_points_de_vigilance_sont_conserves() -> None:
    resultat = generer_synthese_chasseur(
        faisabilite=_faisabilite(
            criteres_restrictifs=["secteur", "prix"],
        ),
        resultats_matching=_matching(),
    )

    assert (
        "Critère restrictif identifié : secteur."
        in resultat["points_vigilance"]
    )
    assert (
        "Critère restrictif identifié : prix."
        in resultat["points_vigilance"]
    )


def test_fonctionne_sans_llm() -> None:
    resultat = generer_synthese_chasseur(
        faisabilite=_faisabilite(),
        resultats_matching=_matching(),
    )

    assert resultat["llm_utilise"] is False
    assert resultat["validation_humaine_requise"] is True
