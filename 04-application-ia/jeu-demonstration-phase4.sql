-- ============================================================
-- Projet RNCP40573 - Chasse immobiliere
-- Phase 4 - Jeu de demonstration reproductible
-- Fichier : jeu-demonstration-phase4.sql
--
-- Objectif :
-- Reconstituer les donnees strictement necessaires aux tests
-- d'integration PostgreSQL de la Phase 4 apres :
--
--   1. migration-final.sql
--   2. reprise-donnees-final.sql
--   3. evolution-matching.sql
--
-- Les donnees creees ici sont synthetiques et identifiables
-- par le marqueur PHASE4_TEST.
--
-- Le script est rejouable. Il ne depend pas des identifiants
-- techniques attribues aux versions ou aux biens.
-- ============================================================

BEGIN;

DO $$
DECLARE
    v_version_id INTEGER;
    v_auteur_id INTEGER;
    v_numero_version INTEGER;
    v_secteur_1 INTEGER;
BEGIN
    -- La demande 1 est la demande de reference du demonstrateur.
    -- On reutilise son auteur existant au lieu d'inventer un utilisateur.
    SELECT auteur_id
    INTO v_auteur_id
    FROM fil_rouge_cible.version_demande
    WHERE demande_id = 1
    ORDER BY est_courante DESC, numero_version DESC
    LIMIT 1;

    IF v_auteur_id IS NULL THEN
        RAISE EXCEPTION
            'Aucune version disponible pour la demande 1. Executer la reprise avant ce script.';
    END IF;

    SELECT id_secteur
    INTO v_secteur_1
    FROM fil_rouge_cible.secteur
    ORDER BY id_secteur
    LIMIT 1;

    IF v_secteur_1 IS NULL THEN
        RAISE EXCEPTION
            'Aucun secteur disponible. Executer la reprise avant ce script.';
    END IF;

    -- Reutilise une ancienne version de demonstration si elle existe.
    SELECT id_version
    INTO v_version_id
    FROM fil_rouge_cible.version_demande
    WHERE demande_id = 1
      AND motif_modification IN (
          'PHASE4_TEST - Jeu de demonstration',
          'Jeu de démonstration Phase 4'
      )
    ORDER BY id_version DESC
    LIMIT 1;

    -- Une seule version courante est autorisee.
    UPDATE fil_rouge_cible.version_demande
    SET est_courante = FALSE
    WHERE demande_id = 1
      AND est_courante = TRUE;

    IF v_version_id IS NULL THEN
        SELECT COALESCE(MAX(numero_version), 0) + 1
        INTO v_numero_version
        FROM fil_rouge_cible.version_demande
        WHERE demande_id = 1;

        INSERT INTO fil_rouge_cible.version_demande (
            demande_id,
            auteur_id,
            numero_version,
            date_version,
            budget_min,
            budget_max,
            surface_min,
            surface_max,
            nb_pieces_min,
            motif_modification,
            est_courante,
            type_bien_souhaite,
            dpe_min
        )
        VALUES (
            1,
            v_auteur_id,
            v_numero_version,
            TIMESTAMP '2026-09-12 12:00:00',
            NULL,
            300000.00,
            70.00,
            NULL,
            3,
            'PHASE4_TEST - Jeu de demonstration',
            TRUE,
            'Appartement',
            'C'
        )
        RETURNING id_version INTO v_version_id;
    ELSE
        UPDATE fil_rouge_cible.version_demande
        SET budget_min = NULL,
            budget_max = 300000.00,
            surface_min = 70.00,
            surface_max = NULL,
            nb_pieces_min = 3,
            motif_modification = 'PHASE4_TEST - Jeu de demonstration',
            est_courante = TRUE,
            type_bien_souhaite = 'Appartement',
            dpe_min = 'C'
        WHERE id_version = v_version_id;
    END IF;

    DELETE FROM fil_rouge_cible.version_demande_secteur
    WHERE version_id = v_version_id;

    INSERT INTO fil_rouge_cible.version_demande_secteur (
        version_id,
        secteur_id
    )
    VALUES (
        v_version_id,
        v_secteur_1
    );
END
$$;

-- Les tests de faisabilite utilisent l'ensemble des biens disponibles.
-- Le jeu Phase 4 doit donc etre execute sur l'etat issu de la reprise,
-- avant tout autre jeu synthetique qui ajouterait des biens.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM fil_rouge_cible.bien
        WHERE adresse NOT LIKE 'PHASE4_TEST - %'
    ) THEN
        RAISE EXCEPTION
            'Des biens hors PHASE4_TEST existent deja. Repartir de migration + reprise pour un test reproductible.';
    END IF;
END
$$;

-- Rejouer le script remet uniquement les biens Phase 4 a leur etat de reference.
DELETE FROM fil_rouge_cible.bien
WHERE adresse LIKE 'PHASE4_TEST - %';

INSERT INTO fil_rouge_cible.bien (
    secteur_id,
    adresse,
    type_bien,
    prix,
    surface,
    nombre_pieces,
    dpe,
    description
)
SELECT
    secteur.id_secteur,
    donnees.adresse,
    donnees.type_bien,
    donnees.prix,
    donnees.surface,
    donnees.nombre_pieces,
    donnees.dpe,
    'Bien synthetique Phase 4'
FROM (
    VALUES
        (1, 'PHASE4_TEST - 10 rue des Lilas', 'Appartement', 250000.00::NUMERIC, 65.00::NUMERIC, 3, 'C'),
        (1, 'PHASE4_TEST - 12 rue des Lilas', 'Appartement', 275000.00::NUMERIC, 72.00::NUMERIC, 3, 'B'),
        (2, 'PHASE4_TEST - 5 avenue du Parc',  'Maison',      420000.00::NUMERIC, 115.00::NUMERIC, 5, 'C'),
        (2, 'PHASE4_TEST - 7 avenue du Parc',  'Maison',      460000.00::NUMERIC, 130.00::NUMERIC, 6, 'B'),
        (3, 'PHASE4_TEST - 2 place Centrale',  'Studio',      145000.00::NUMERIC, 28.00::NUMERIC, 1, 'D'),
        (3, 'PHASE4_TEST - 4 place Centrale',  'Appartement', 310000.00::NUMERIC, 82.00::NUMERIC, 4, 'C')
) AS donnees(
    rang_secteur,
    adresse,
    type_bien,
    prix,
    surface,
    nombre_pieces,
    dpe
)
JOIN (
    SELECT
        id_secteur,
        ROW_NUMBER() OVER (ORDER BY id_secteur) AS rang_secteur
    FROM fil_rouge_cible.secteur
) AS secteur
    ON secteur.rang_secteur = donnees.rang_secteur;

DO $$
BEGIN
    IF (
        SELECT COUNT(*)
        FROM fil_rouge_cible.bien
        WHERE adresse LIKE 'PHASE4_TEST - %'
    ) <> 6 THEN
        RAISE EXCEPTION
            'Le jeu Phase 4 doit contenir exactement 6 biens.';
    END IF;
END
$$;

COMMIT;

-- Controle lisible apres execution.
SELECT
    id_version,
    demande_id,
    numero_version,
    est_courante,
    budget_max,
    surface_min,
    nb_pieces_min,
    type_bien_souhaite,
    dpe_min
FROM fil_rouge_cible.version_demande
WHERE demande_id = 1
  AND est_courante = TRUE;

SELECT
    id_bien,
    secteur_id,
    adresse,
    prix,
    surface,
    nombre_pieces,
    type_bien,
    dpe
FROM fil_rouge_cible.bien
ORDER BY prix;
