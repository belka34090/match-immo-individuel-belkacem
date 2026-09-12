import os
from decimal import Decimal

import pytest
from app.database import SessionLocal
from app.main import app
from fastapi.testclient import TestClient
from sqlalchemy import text

pytestmark = pytest.mark.skipif(
    os.getenv("RUN_INTEGRATION_TESTS") != "1",
    reason="Test PostgreSQL lancé uniquement avec RUN_INTEGRATION_TESTS=1",
)


client = TestClient(app)


def _nettoyer_validation_test() -> None:
    with SessionLocal() as session:
        session.execute(
            text(
                """
                DELETE FROM fil_rouge_cible.validation_humaine
                WHERE version_demande_id = 19
                  AND commentaire = 'TEST PARCOURS COMPLET'
                """
            )
        )
        session.commit()


def test_parcours_complet_demande_jusqua_validation_humaine() -> None:
    _nettoyer_validation_test()

    faisabilite_response = client.get(
        "/demandes/1/faisabilite"
    )

    assert faisabilite_response.status_code == 200

    faisabilite = faisabilite_response.json()

    assert Decimal(
        str(faisabilite["score"])
    ) == Decimal("53.33")

    assert faisabilite["niveau"] == "difficile"

    matching_response = client.get(
        "/demandes/1/matching"
    )

    assert matching_response.status_code == 200

    matching = matching_response.json()

    assert matching["nombre_resultats"] == 2
    assert matching["resultats"][0]["id_bien"] == 2

    assert Decimal(
        str(matching["resultats"][0]["score"])
    ) == Decimal("100.00")

    synthese_response = client.get(
        "/demandes/1/chasseur-ia"
    )

    assert synthese_response.status_code == 200

    synthese_complete = synthese_response.json()
    synthese = synthese_complete["synthese"]

    assert synthese["niveau_faisabilite"] == "difficile"
    assert synthese["llm_utilise"] is False
    assert synthese["validation_humaine_requise"] is True

    validation_response = client.post(
        "/demandes/1/validation-humaine",
        json={
            "validateur_id": 1,
            "decision": "VALIDER",
            "commentaire": "TEST PARCOURS COMPLET",
        },
    )

    assert validation_response.status_code == 200

    validation = validation_response.json()

    assert validation["version_demande_id"] == 19
    assert validation["validateur_id"] == 1
    assert validation["decision"] == "VALIDER"

    with SessionLocal() as session:
        decision_en_base = session.execute(
            text(
                """
                SELECT decision
                FROM fil_rouge_cible.validation_humaine
                WHERE version_demande_id = 19
                  AND commentaire = 'TEST PARCOURS COMPLET'
                """
            )
        ).scalar_one()

    assert decision_en_base == "VALIDER"

    _nettoyer_validation_test()
