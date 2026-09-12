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


def test_matching_api_avec_postgresql_reel() -> None:
    """
    Vérifie le parcours réel :

    API
      -> service métier
      -> PostgreSQL
      -> moteur de matching
      -> réponse HTTP

    La demande 1 correspond aux données de démonstration Phase 4.
    """

    response = client.get("/demandes/1/matching")

    assert response.status_code == 200

    body = response.json()

    assert body["demande_id"] == 1
    assert body["nombre_resultats"] == 2

    resultats = body["resultats"]

    assert [resultat["id_bien"] for resultat in resultats] == [2, 1]

    assert Decimal(str(resultats[0]["score"])) == Decimal("100.00")
    assert Decimal(str(resultats[1]["score"])) == Decimal("98.57")

    assert resultats[0]["adresse"]
    assert resultats[0]["details"]
    assert resultats[0]["explication"]

    assert Decimal(
        str(resultats[1]["details"]["surface"])
    ) == Decimal("18.57")
    assert (
        "surface"
        in resultats[1]["explication"]["points_vigilance"]
    )

    assert (
        resultats[1]["explication"]["criteres_non_disponibles"]
        == []
    )

    scores = [
        Decimal(str(resultat["score"]))
        for resultat in resultats
    ]

    assert scores == sorted(scores, reverse=True)
