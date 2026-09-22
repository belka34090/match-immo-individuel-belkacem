from fastapi.testclient import TestClient

import app.main as main_module
from app.main import app

client = TestClient(app)


def _reponse_validation(
    *,
    decision: str,
    commentaire: str | None,
) -> dict:
    return {
        "id_validation": 1,
        "version_demande_id": 19,
        "validateur_id": 1,
        "decision": decision,
        "commentaire": commentaire,
        "date_validation": "2026-09-12T10:54:21",
    }


def test_validation_humaine_valider(monkeypatch) -> None:
    def faux_service(**kwargs):
        return _reponse_validation(
            decision="VALIDER",
            commentaire=kwargs["commentaire"],
        )

    monkeypatch.setattr(
        main_module,
        "enregistrer_validation_pour_demande",
        faux_service,
    )

    response = client.post(
        "/demandes/1/validation-humaine",
        json={
            "validateur_id": 1,
            "decision": "VALIDER",
            "commentaire": "Résultat validé.",
        },
    )

    assert response.status_code == 200
    assert response.json()["decision"] == "VALIDER"


def test_validation_humaine_refuser(monkeypatch) -> None:
    def faux_service(**kwargs):
        return _reponse_validation(
            decision="REFUSER",
            commentaire=kwargs["commentaire"],
        )

    monkeypatch.setattr(
        main_module,
        "enregistrer_validation_pour_demande",
        faux_service,
    )

    response = client.post(
        "/demandes/1/validation-humaine",
        json={
            "validateur_id": 1,
            "decision": "REFUSER",
            "commentaire": "Résultat refusé.",
        },
    )

    assert response.status_code == 200
    assert response.json()["decision"] == "REFUSER"


def test_validation_humaine_modifier(monkeypatch) -> None:
    def faux_service(**kwargs):
        return _reponse_validation(
            decision="MODIFIER",
            commentaire=kwargs["commentaire"],
        )

    monkeypatch.setattr(
        main_module,
        "enregistrer_validation_pour_demande",
        faux_service,
    )

    response = client.post(
        "/demandes/1/validation-humaine",
        json={
            "validateur_id": 1,
            "decision": "MODIFIER",
            "commentaire": "Revoir les critères proposés.",
        },
    )

    assert response.status_code == 200
    assert response.json()["decision"] == "MODIFIER"


def test_validation_humaine_erreur_metier(monkeypatch) -> None:
    def faux_service(**kwargs):
        raise ValueError("Décision invalide.")

    monkeypatch.setattr(
        main_module,
        "enregistrer_validation_pour_demande",
        faux_service,
    )

    response = client.post(
        "/demandes/1/validation-humaine",
        json={
            "validateur_id": 1,
            "decision": "AUTOMATIQUE",
        },
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "Décision invalide."


def test_validation_humaine_requete_invalide() -> None:
    response = client.post(
        "/demandes/1/validation-humaine",
        json={
            "decision": "VALIDER",
        },
    )

    assert response.status_code == 422

    body = response.json()

    assert "detail" in body
    assert isinstance(body["detail"], list)
