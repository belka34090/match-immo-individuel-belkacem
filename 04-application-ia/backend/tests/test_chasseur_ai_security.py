from unittest.mock import Mock

import app.chasseur_ai_service as service_module


def test_donnees_personnelles_non_transmises_au_chasseur_ia(
    monkeypatch,
) -> None:
    session = Mock()

    faisabilite = {
        "score": 53.33,
        "niveau": "difficile",
        "nombre_biens": 6,
        "nombre_biens_compatibles": 2,
        "criteres_restrictifs": ["secteur"],
        "details": {},
    }

    matching = [
        {
            "id_bien": 2,
            "adresse": "10 rue Exemple",
            "type_bien": "Appartement",
            "prix": 275000,
            "surface": 72,
            "nombre_pieces": 3,
            "dpe": "B",
            "score": 100,
            "details": {},
            "explication": {},
            "nom": "Martin",
            "email": "personne@example.fr",
            "telephone": "0600000000",
        }
    ]

    donnees_recues_par_ia = {}

    monkeypatch.setattr(
        service_module,
        "analyser_faisabilite_demande",
        lambda **kwargs: faisabilite,
    )

    monkeypatch.setattr(
        service_module,
        "classer_biens_pour_demande",
        lambda **kwargs: matching,
    )

    def faux_generer_synthese_chasseur(
        *,
        faisabilite,
        resultats_matching,
    ):
        donnees_recues_par_ia["matching"] = resultats_matching
        return {
            "validation_humaine_requise": True,
            "llm_utilise": False,
        }

    monkeypatch.setattr(
        service_module,
        "generer_synthese_chasseur",
        faux_generer_synthese_chasseur,
    )

    service_module.generer_synthese_pour_demande(
        session=session,
        demande_id=1,
    )

    bien_transmis = donnees_recues_par_ia["matching"][0]

    assert "nom" not in bien_transmis
    assert "email" not in bien_transmis
    assert "telephone" not in bien_transmis

    assert bien_transmis["id_bien"] == 2
    assert bien_transmis["score"] == 100


def test_chasseur_ia_ne_dispose_pas_acces_ecriture_base() -> None:
    import inspect

    from app.chasseur_ai import generer_synthese_chasseur

    parametres = inspect.signature(
        generer_synthese_chasseur
    ).parameters

    assert "session" not in parametres
    assert "database" not in parametres
    assert "db" not in parametres

    assert set(parametres) == {
        "faisabilite",
        "resultats_matching",
        "limite_biens",
    }
