import os

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import text

from app.database import SessionLocal
from app.main import app

pytestmark = pytest.mark.skipif(
    os.getenv("RUN_INTEGRATION_TESTS") != "1",
    reason="Test PostgreSQL lancé uniquement avec RUN_INTEGRATION_TESTS=1",
)


client = TestClient(app)


def _version_courante_demande_1() -> int:
    with SessionLocal() as session:
        return session.execute(
            text(
                """
                SELECT id_version
                FROM fil_rouge_cible.version_demande
                WHERE demande_id = 1
                  AND est_courante = TRUE
                """
            )
        ).scalar_one()


def _nettoyer_validations_test() -> None:
    with SessionLocal() as session:
        session.execute(
            text(
                """
                DELETE FROM fil_rouge_cible.validation_humaine
                WHERE commentaire LIKE 'TEST INTEGRATION %'
                """
            )
        )
        session.commit()


def test_validation_humaine_postgresql_reel() -> None:
    _nettoyer_validations_test()
    version_courante_id = _version_courante_demande_1()

    decisions = [
        ("VALIDER", "TEST INTEGRATION validation"),
        ("REFUSER", "TEST INTEGRATION refus"),
        ("MODIFIER", "TEST INTEGRATION modification"),
    ]

    for decision, commentaire in decisions:
        response = client.post(
            "/demandes/1/validation-humaine",
            json={
                "validateur_id": 1,
                "decision": decision,
                "commentaire": commentaire,
            },
        )

        assert response.status_code == 200

        body = response.json()

        assert body["version_demande_id"] == version_courante_id
        assert body["validateur_id"] == 1
        assert body["decision"] == decision
        assert body["commentaire"] == commentaire

    with SessionLocal() as session:
        lignes = session.execute(
            text(
                """
                SELECT decision, commentaire
                FROM fil_rouge_cible.validation_humaine
                WHERE version_demande_id = :version_id
                  AND commentaire LIKE 'TEST INTEGRATION %'
                ORDER BY id_validation
                """
            ),
            {"version_id": version_courante_id},
        ).mappings().all()

    assert [ligne["decision"] for ligne in lignes] == [
        "VALIDER",
        "REFUSER",
        "MODIFIER",
    ]

    _nettoyer_validations_test()
