from sqlalchemy import text
from sqlalchemy.orm import Session


DECISIONS_AUTORISEES = {"VALIDER", "REFUSER", "MODIFIER"}


def enregistrer_validation_humaine(
    session: Session,
    version_demande_id: int,
    validateur_id: int,
    decision: str,
    commentaire: str | None = None,
) -> dict:
    """
    Enregistre une décision humaine sur une version précise de demande.

    Le contrôle humain reste la décision finale :
    le chasseur-IA ne valide rien lui-même.
    """
    decision_normalisee = decision.strip().upper()

    if decision_normalisee not in DECISIONS_AUTORISEES:
        raise ValueError(
            "Décision invalide. Valeurs autorisées : "
            "VALIDER, REFUSER, MODIFIER."
        )

    version_existe = session.execute(
        text(
            """
            SELECT 1
            FROM fil_rouge_cible.version_demande
            WHERE id_version = :version_demande_id
            """
        ),
        {"version_demande_id": version_demande_id},
    ).scalar_one_or_none()

    if version_existe is None:
        raise ValueError(
            f"Version de demande {version_demande_id} introuvable."
        )

    validateur_existe = session.execute(
        text(
            """
            SELECT 1
            FROM fil_rouge_cible.utilisateur
            WHERE id_utilisateur = :validateur_id
            """
        ),
        {"validateur_id": validateur_id},
    ).scalar_one_or_none()

    if validateur_existe is None:
        raise ValueError(
            f"Utilisateur {validateur_id} introuvable."
        )

    resultat = session.execute(
        text(
            """
            INSERT INTO fil_rouge_cible.validation_humaine (
                version_demande_id,
                validateur_id,
                decision,
                commentaire
            )
            VALUES (
                :version_demande_id,
                :validateur_id,
                :decision,
                :commentaire
            )
            RETURNING
                id_validation,
                version_demande_id,
                validateur_id,
                decision,
                commentaire,
                date_validation
            """
        ),
        {
            "version_demande_id": version_demande_id,
            "validateur_id": validateur_id,
            "decision": decision_normalisee,
            "commentaire": commentaire,
        },
    ).mappings().one()

    session.commit()

    return dict(resultat)


def enregistrer_validation_pour_demande(
    session: Session,
    demande_id: int,
    validateur_id: int,
    decision: str,
    commentaire: str | None = None,
) -> dict:
    """
    Enregistre une décision humaine sur la version courante d'une demande.

    L'appelant fournit l'identifiant métier de la demande.
    Le backend retrouve lui-même la version actuellement active afin
    d'éviter d'exposer ce détail technique au frontend.
    """
    version_demande_id = session.execute(
        text(
            """
            SELECT id_version
            FROM fil_rouge_cible.version_demande
            WHERE demande_id = :demande_id
              AND est_courante = TRUE
            """
        ),
        {"demande_id": demande_id},
    ).scalar_one_or_none()

    if version_demande_id is None:
        raise ValueError(
            f"Demande {demande_id} ou version courante introuvable."
        )

    return enregistrer_validation_humaine(
        session=session,
        version_demande_id=version_demande_id,
        validateur_id=validateur_id,
        decision=decision,
        commentaire=commentaire,
    )
