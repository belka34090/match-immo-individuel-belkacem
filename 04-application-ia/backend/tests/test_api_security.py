from fastapi.testclient import TestClient

import app.main as main_module

client = TestClient(
    main_module.app,
    raise_server_exceptions=False,
)


def test_erreur_interne_ne_divulgue_pas_detail_technique(
    monkeypatch,
) -> None:
    def faux_matching(*, session, demande_id: int):
        raise RuntimeError(
            "postgresql://user:password@127.0.0.1:5433/base"
        )

    monkeypatch.setattr(
        main_module,
        "classer_biens_pour_demande",
        faux_matching,
    )

    response = client.get("/demandes/1/matching")

    assert response.status_code == 500

    body = response.json()

    assert "password" not in str(body).lower()
    assert "postgresql://" not in str(body).lower()
    assert "127.0.0.1" not in str(body)
