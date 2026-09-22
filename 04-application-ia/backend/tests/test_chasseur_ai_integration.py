import os
from decimal import Decimal

import pytest
from fastapi.testclient import TestClient

from app.main import app

pytestmark = pytest.mark.skipif(
    os.getenv("RUN_INTEGRATION_TESTS") != "1",
    reason="Test PostgreSQL lancé uniquement avec RUN_INTEGRATION_TESTS=1",
)


client = TestClient(app)


def test_chasseur_ia_avec_postgresql_reel() -> None:
    response = client.get("/demandes/1/chasseur-ia")

    assert response.status_code == 200

    body = response.json()

    assert body["demande_id"] == 1

    assert Decimal(
        str(body["faisabilite"]["score"])
    ) == Decimal("53.33")

    assert body["faisabilite"]["niveau"] == "difficile"

    assert body["matching"][0]["id_bien"] == 2
    assert Decimal(
        str(body["matching"][0]["score"])
    ) == Decimal("100.00")

    synthese = body["synthese"]

    assert synthese["niveau_faisabilite"] == "difficile"
    assert synthese["llm_utilise"] is False
    assert synthese["validation_humaine_requise"] is True

    assert Decimal(
        str(synthese["score_faisabilite"])
    ) == Decimal("53.33")

    assert Decimal(
        str(synthese["meilleurs_biens"][0]["score"])
    ) == Decimal("100.00")

    assert (
        "Critère restrictif identifié : secteur."
        in synthese["points_vigilance"]
    )

    assert "53.33 / 100" in synthese["message_principal"]
    assert "100.00 / 100" in synthese["message_principal"]
