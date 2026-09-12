from fastapi.testclient import TestClient

import app.main as main_module


client = TestClient(main_module.app)


def test_faisabilite_api_retourne_une_analyse(monkeypatch) -> None:
    def fausse_analyse(*, session, demande_id: int) -> dict:
        assert demande_id == 1

        return {
            "score": 53.33,
            "niveau": "difficile",
            "nombre_biens": 6,
            "nombre_biens_compatibles": 2,
            "criteres_restrictifs": ["secteur"],
            "details": {
                "secteur": {
                    "score": 0.33,
                    "connus": 6,
                    "inconnus": 0,
                }
            },
        }

    monkeypatch.setattr(
        main_module,
        "analyser_faisabilite_demande",
        fausse_analyse,
    )

    response = client.get("/demandes/1/faisabilite")

    assert response.status_code == 200

    body = response.json()

    assert body["score"] == 53.33
    assert body["niveau"] == "difficile"
    assert body["nombre_biens"] == 6
    assert body["nombre_biens_compatibles"] == 2
    assert body["criteres_restrictifs"] == ["secteur"]


def test_faisabilite_api_demande_inexistante(monkeypatch) -> None:
    def fausse_analyse(*, session, demande_id: int) -> dict:
        raise ValueError(
            f"Aucune version courante trouvée pour la demande {demande_id}"
        )

    monkeypatch.setattr(
        main_module,
        "analyser_faisabilite_demande",
        fausse_analyse,
    )

    response = client.get("/demandes/999999/faisabilite")

    assert response.status_code == 404
    assert response.json() == {
        "detail": (
            "Aucune version courante trouvée "
            "pour la demande 999999"
        )
    }
