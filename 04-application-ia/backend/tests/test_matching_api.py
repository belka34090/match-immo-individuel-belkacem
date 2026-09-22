from fastapi.testclient import TestClient

import app.main as main_module

client = TestClient(main_module.app)


def test_matching_api_retourne_des_resultats(monkeypatch) -> None:
    def faux_matching(*, session, demande_id: int) -> list[dict]:
        assert demande_id == 1

        return [
            {
                "id_bien": 2,
                "score": 100.0,
                "details": {
                    "secteur": 30.0,
                    "prix": 25.0,
                    "surface": 20.0,
                    "type_bien": 10.0,
                    "pieces": 10.0,
                    "dpe": 5.0,
                },
            },
            {
                "id_bien": 1,
                "score": 98.57,
                "details": {
                    "secteur": 30.0,
                    "prix": 25.0,
                    "surface": 18.57,
                    "type_bien": 10.0,
                    "pieces": 10.0,
                    "dpe": 5.0,
                },
            },
        ]

    monkeypatch.setattr(
        main_module,
        "classer_biens_pour_demande",
        faux_matching,
    )

    response = client.get("/demandes/1/matching")

    assert response.status_code == 200

    body = response.json()

    assert body["demande_id"] == 1
    assert body["nombre_resultats"] == 2
    assert body["resultats"][0]["id_bien"] == 2
    assert body["resultats"][0]["score"] == 100.0
    assert body["resultats"][1]["id_bien"] == 1
    assert body["resultats"][1]["score"] == 98.57


def test_matching_api_demande_inexistante(monkeypatch) -> None:
    def faux_matching(*, session, demande_id: int) -> list[dict]:
        raise ValueError(f"Demande {demande_id} introuvable.")

    monkeypatch.setattr(
        main_module,
        "classer_biens_pour_demande",
        faux_matching,
    )

    response = client.get("/demandes/999999/matching")

    assert response.status_code == 404
    assert response.json() == {
        "detail": "Demande 999999 introuvable."
    }


def test_matching_api_sans_bien_compatible(monkeypatch) -> None:
    def faux_matching(*, session, demande_id: int) -> list[dict]:
        assert demande_id == 1
        return []

    monkeypatch.setattr(
        main_module,
        "classer_biens_pour_demande",
        faux_matching,
    )

    response = client.get("/demandes/1/matching")

    assert response.status_code == 200

    body = response.json()

    assert body["demande_id"] == 1
    assert body["nombre_resultats"] == 0
    assert body["resultats"] == []
    assert body["message"] == (
        "Aucun bien compatible avec les critères obligatoires "
        "de la demande."
    )
