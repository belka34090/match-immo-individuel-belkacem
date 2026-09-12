from decimal import Decimal
from types import SimpleNamespace

from app.matching import bien_est_compatible


def make_bien(
    prix: str = "250000.00",
    secteur_id: int = 1,
    type_bien: str = "Appartement",
):
    return SimpleNamespace(
        prix=Decimal(prix),
        secteur_id=secteur_id,
        type_bien=type_bien,
    )


def make_version(
    budget_max: str | None = "300000.00",
    type_bien_souhaite: str | None = "Appartement",
):
    return SimpleNamespace(
        budget_max=Decimal(budget_max) if budget_max is not None else None,
        type_bien_souhaite=type_bien_souhaite,
    )


def test_bien_compatible() -> None:
    bien = make_bien()
    version = make_version()

    assert bien_est_compatible(bien, version, {1}) is True


def test_bien_exclu_si_prix_superieur_budget() -> None:
    bien = make_bien(prix="350000.00")
    version = make_version(budget_max="300000.00")

    assert bien_est_compatible(bien, version, {1}) is False


def test_bien_exclu_si_secteur_incompatible() -> None:
    bien = make_bien(secteur_id=2)
    version = make_version()

    assert bien_est_compatible(bien, version, {1}) is False


def test_bien_exclu_si_type_incompatible() -> None:
    bien = make_bien(type_bien="Maison")
    version = make_version(type_bien_souhaite="Appartement")

    assert bien_est_compatible(bien, version, {1}) is False


def test_absence_type_souhaite_ne_bloque_pas() -> None:
    bien = make_bien(type_bien="Maison")
    version = make_version(type_bien_souhaite=None)

    assert bien_est_compatible(bien, version, {1}) is True


def test_absence_secteur_ne_bloque_pas() -> None:
    bien = make_bien(secteur_id=99)
    version = make_version()

    assert bien_est_compatible(bien, version, set()) is True


from app.matching import (
    calculer_score_matching,
    score_dpe,
    score_surface,
)


def make_bien_complet(
    prix: str = "285000.00",
    secteur_id: int = 1,
    type_bien: str = "Appartement",
    surface: str | None = "86.00",
    nombre_pieces: int | None = 3,
    dpe: str | None = "C",
):
    return SimpleNamespace(
        prix=Decimal(prix),
        secteur_id=secteur_id,
        type_bien=type_bien,
        surface=Decimal(surface) if surface is not None else None,
        nombre_pieces=nombre_pieces,
        dpe=dpe,
    )


def make_version_complete(
    budget_max: str | None = "300000.00",
    surface_min: str | None = "80.00",
    nb_pieces_min: int | None = 3,
    type_bien_souhaite: str | None = "Appartement",
    dpe_min: str | None = "C",
):
    return SimpleNamespace(
        budget_max=Decimal(budget_max) if budget_max is not None else None,
        surface_min=Decimal(surface_min) if surface_min is not None else None,
        nb_pieces_min=nb_pieces_min,
        type_bien_souhaite=type_bien_souhaite,
        dpe_min=dpe_min,
    )


def test_surface_parfaite() -> None:
    bien = make_bien_complet(surface="86.00")
    version = make_version_complete(surface_min="80.00")

    assert score_surface(bien, version) == Decimal("1")


def test_surface_legèrement_insuffisante() -> None:
    bien = make_bien_complet(surface="72.00")
    version = make_version_complete(surface_min="80.00")

    assert score_surface(bien, version) == Decimal("0.9")


def test_dpe_meilleur_que_souhaite() -> None:
    bien = make_bien_complet(dpe="B")
    version = make_version_complete(dpe_min="C")

    assert score_dpe(bien, version) == Decimal("1")


def test_dpe_un_niveau_moins_bon() -> None:
    bien = make_bien_complet(dpe="D")
    version = make_version_complete(dpe_min="C")

    assert score_dpe(bien, version) == Decimal("0.75")


def test_score_parfait() -> None:
    bien = make_bien_complet()
    version = make_version_complete()

    resultat = calculer_score_matching(
        bien,
        version,
        {1},
    )

    assert resultat["score"] == Decimal("100.00")


def test_score_reste_entre_zero_et_cent() -> None:
    bien = make_bien_complet(
        surface="40.00",
        nombre_pieces=1,
        dpe="G",
    )
    version = make_version_complete(
        surface_min="80.00",
        nb_pieces_min=4,
        dpe_min="A",
    )

    resultat = calculer_score_matching(
        bien,
        version,
        {1},
    )

    assert Decimal("0") <= resultat["score"] <= Decimal("100")
