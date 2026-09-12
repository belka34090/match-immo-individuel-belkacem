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


def test_faisabilite_api_avec_postgresql_reel() -> None:
    """
    Vérifie le parcours réel :

    API
      -> service métier
      -> PostgreSQL
      -> moteur de faisabilité
      -> réponse HTTP
    """

    response = client.get("/demandes/1/faisabilite")

    assert response.status_code == 200

    body = response.json()

    assert Decimal(str(body["score"])) == Decimal("53.33")
    assert body["niveau"] == "difficile"
    assert body["nombre_biens"] == 6
    assert body["nombre_biens_compatibles"] == 2
    assert body["criteres_restrictifs"] == ["secteur"]

    assert Decimal(
        str(body["details"]["secteur"]["score"])
    ) == Decimal("0.33")
