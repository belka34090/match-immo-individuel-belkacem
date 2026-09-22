from decimal import Decimal
from types import SimpleNamespace

from app.matching_service import classer_biens_pour_demande


class FakeScalars:
    def __init__(self, valeurs):
        self.valeurs = valeurs

    def all(self):
        return self.valeurs


class FakeSession:
    def __init__(self, version, secteurs, biens):
        self.version = version
        self.secteurs = secteurs
        self.biens = biens
        self.appels_scalars = 0

    def scalar(self, statement):
        return self.version

    def scalars(self, statement):
        self.appels_scalars += 1

        if self.appels_scalars == 1:
            return FakeScalars(self.secteurs)

        return FakeScalars(self.biens)


def make_bien(
    id_bien: int,
    surface: str,
):
    return SimpleNamespace(
        id_bien=id_bien,
        adresse=f"Adresse {id_bien}",
        prix=Decimal("250000.00"),
        secteur_id=1,
        type_bien="Appartement",
        surface=Decimal(surface),
        nombre_pieces=3,
        dpe="C",
    )


def test_classement_decroissant_des_biens() -> None:
    version = SimpleNamespace(
        id_version=19,
        demande_id=1,
        est_courante=True,
        budget_max=Decimal("300000.00"),
        surface_min=Decimal("70.00"),
        nb_pieces_min=3,
        type_bien_souhaite="Appartement",
        dpe_min="C",
    )

    bien_moins_bon = make_bien(
        id_bien=1,
        surface="65.00",
    )
    bien_meilleur = make_bien(
        id_bien=2,
        surface="72.00",
    )

    session = FakeSession(
        version=version,
        secteurs=[1],
        biens=[bien_moins_bon, bien_meilleur],
    )

    resultats = classer_biens_pour_demande(
        session=session,
        demande_id=1,
    )

    assert [resultat["id_bien"] for resultat in resultats] == [2, 1]
    assert resultats[0]["score"] == Decimal("100.00")
    assert resultats[1]["score"] == Decimal("98.57")
