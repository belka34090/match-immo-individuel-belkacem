-- ============================================================
-- MATCH-IMMO
-- Phase 3 - Jeu de données OLTP de démonstration
-- Fichier : oltp-jeu-test.sql
--
-- OBJECTIF
-- --------
-- Créer un petit jeu de données synthétiques cohérent afin
-- de tester réellement :
--
--     OLTP -> ETL -> OLAP
--
-- IMPORTANT
-- ---------
-- Ces données NE proviennent PAS de la reprise historique.
--
-- Elles servent uniquement :
-- - aux tests Phase 3 ;
-- - à la validation de l'ETL ;
-- - aux futurs contrôles analytiques.
--
-- Elles sont identifiables grâce au préfixe :
--
--     PHASE3_TEST
--
-- ============================================================

BEGIN;

DO $$
DECLARE
    -- Mandats existants utilisés pour le test.
    v_mandat_1 INTEGER;
    v_mandat_2 INTEGER;
    v_mandat_3 INTEGER;

    -- Chasseurs associés aux mandats.
    v_chasseur_1 INTEGER;
    v_chasseur_2 INTEGER;

    -- Secteurs existants.
    v_secteur_1 INTEGER;
    v_secteur_2 INTEGER;
    v_secteur_3 INTEGER;

    -- Biens créés.
    v_bien_1 INTEGER;
    v_bien_2 INTEGER;
    v_bien_3 INTEGER;
    v_bien_4 INTEGER;
    v_bien_5 INTEGER;
    v_bien_6 INTEGER;

    -- Présentations créées.
    v_presentation_1 INTEGER;
    v_presentation_2 INTEGER;
    v_presentation_3 INTEGER;
    v_presentation_4 INTEGER;

    -- Offres créées.
    v_offre_1 INTEGER;
    v_offre_2 INTEGER;
    v_offre_3 INTEGER;

    -- Notaires.
    v_notaire_1 INTEGER;
    v_notaire_2 INTEGER;

    -- Actes.
    v_acte_1 INTEGER;
    v_acte_2 INTEGER;

    -- Honoraires.
    v_honoraires_1 INTEGER;
    v_honoraires_2 INTEGER;

    -- Barèmes.
    v_bareme_1 INTEGER;
    v_bareme_2 INTEGER;

    -- Tranches.
    v_tranche_1 INTEGER;
    v_tranche_2 INTEGER;

BEGIN

    -- ========================================================
    -- 1. PROTECTION CONTRE UNE DOUBLE INSERTION
    -- ========================================================

    -- Si un bien portant notre marqueur existe déjà,
    -- le jeu de test a déjà été injecté.
    --
    -- On quitte alors le bloc sans créer de doublons.

    IF EXISTS (
        SELECT 1
        FROM fil_rouge_cible.bien
        WHERE adresse LIKE 'PHASE3_TEST%'
    ) THEN
        RAISE NOTICE 'Jeu de test Phase 3 déjà présent : aucune insertion.';
        RETURN;
    END IF;


    -- ========================================================
    -- 2. RÉCUPÉRATION DE MANDATS EXISTANTS
    -- ========================================================

    -- Nous réutilisons les trois premiers mandats existants.
    --
    -- Cela évite d'inventer de nouveaux clients/chasseurs
    -- uniquement pour les tests analytiques.

    SELECT id_mandat, chasseur_id
    INTO v_mandat_1, v_chasseur_1
    FROM fil_rouge_cible.mandat
    ORDER BY id_mandat
    LIMIT 1;

    SELECT id_mandat, chasseur_id
    INTO v_mandat_2, v_chasseur_2
    FROM fil_rouge_cible.mandat
    ORDER BY id_mandat
    OFFSET 1
    LIMIT 1;

    SELECT id_mandat
    INTO v_mandat_3
    FROM fil_rouge_cible.mandat
    ORDER BY id_mandat
    OFFSET 2
    LIMIT 1;


    -- Vérification minimale.
    --
    -- Si moins de trois mandats existent, le script s'arrête.

    IF v_mandat_1 IS NULL
       OR v_mandat_2 IS NULL
       OR v_mandat_3 IS NULL THEN

        RAISE EXCEPTION
            'Au moins trois mandats sont nécessaires pour le jeu Phase 3.';
    END IF;


    -- ========================================================
    -- 3. RÉCUPÉRATION DE SECTEURS EXISTANTS
    -- ========================================================

    SELECT id_secteur
    INTO v_secteur_1
    FROM fil_rouge_cible.secteur
    ORDER BY id_secteur
    LIMIT 1;

    SELECT id_secteur
    INTO v_secteur_2
    FROM fil_rouge_cible.secteur
    ORDER BY id_secteur
    OFFSET 1
    LIMIT 1;

    SELECT id_secteur
    INTO v_secteur_3
    FROM fil_rouge_cible.secteur
    ORDER BY id_secteur
    OFFSET 2
    LIMIT 1;


    IF v_secteur_1 IS NULL
       OR v_secteur_2 IS NULL
       OR v_secteur_3 IS NULL THEN

        RAISE EXCEPTION
            'Au moins trois secteurs sont nécessaires pour le jeu Phase 3.';
    END IF;


    -- ========================================================
    -- 4. CRÉATION DES BIENS
    -- ========================================================

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
    VALUES (
        v_secteur_1,
        'PHASE3_TEST - 10 rue des Lilas',
        'Appartement',
        250000.00,
        65.00,
        3,
        'C',
        'Bien synthétique Phase 3'
    )
    RETURNING id_bien INTO v_bien_1;


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
    VALUES (
        v_secteur_1,
        'PHASE3_TEST - 12 rue des Lilas',
        'Appartement',
        275000.00,
        72.00,
        3,
        'B',
        'Bien synthétique Phase 3'
    )
    RETURNING id_bien INTO v_bien_2;


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
    VALUES (
        v_secteur_2,
        'PHASE3_TEST - 5 avenue du Parc',
        'Maison',
        420000.00,
        115.00,
        5,
        'C',
        'Bien synthétique Phase 3'
    )
    RETURNING id_bien INTO v_bien_3;


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
    VALUES (
        v_secteur_2,
        'PHASE3_TEST - 7 avenue du Parc',
        'Maison',
        460000.00,
        130.00,
        6,
        'B',
        'Bien synthétique Phase 3'
    )
    RETURNING id_bien INTO v_bien_4;


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
    VALUES (
        v_secteur_3,
        'PHASE3_TEST - 2 place Centrale',
        'Studio',
        145000.00,
        28.00,
        1,
        'D',
        'Bien synthétique Phase 3'
    )
    RETURNING id_bien INTO v_bien_5;


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
    VALUES (
        v_secteur_3,
        'PHASE3_TEST - 4 place Centrale',
        'Appartement',
        310000.00,
        82.00,
        4,
        'C',
        'Bien synthétique Phase 3'
    )
    RETURNING id_bien INTO v_bien_6;


    -- ========================================================
    -- 5. PRÉSENTATIONS
    -- ========================================================

    INSERT INTO fil_rouge_cible.presentation (
        mandat_id,
        bien_id,
        date_presentation,
        statut,
        priorite_client,
        decision_client,
        observations
    )
    VALUES (
        v_mandat_1,
        v_bien_1,
        '2025-02-10 10:00:00',
        'presente',
        1,
        'interesse',
        'PHASE3_TEST'
    )
    RETURNING id_presentation INTO v_presentation_1;


    INSERT INTO fil_rouge_cible.presentation (
        mandat_id,
        bien_id,
        date_presentation,
        statut,
        priorite_client,
        decision_client,
        observations
    )
    VALUES (
        v_mandat_1,
        v_bien_2,
        '2025-02-12 14:00:00',
        'presente',
        2,
        'refuse',
        'PHASE3_TEST'
    )
    RETURNING id_presentation INTO v_presentation_2;


    INSERT INTO fil_rouge_cible.presentation (
        mandat_id,
        bien_id,
        date_presentation,
        statut,
        priorite_client,
        decision_client,
        observations
    )
    VALUES (
        v_mandat_2,
        v_bien_3,
        '2025-03-18 11:00:00',
        'presente',
        1,
        'interesse',
        'PHASE3_TEST'
    )
    RETURNING id_presentation INTO v_presentation_3;


    INSERT INTO fil_rouge_cible.presentation (
        mandat_id,
        bien_id,
        date_presentation,
        statut,
        priorite_client,
        decision_client,
        observations
    )
    VALUES (
        v_mandat_3,
        v_bien_5,
        '2025-04-15 09:30:00',
        'presente',
        1,
        'interesse',
        'PHASE3_TEST'
    )
    RETURNING id_presentation INTO v_presentation_4;


    -- ========================================================
    -- 6. VISITES
    -- ========================================================

    INSERT INTO fil_rouge_cible.visite (
        presentation_id,
        date_visite,
        retour_client,
        interet
    )
    VALUES (
        v_presentation_1,
        '2025-02-15 15:00:00',
        'Client intéressé',
        'fort'
    );


    INSERT INTO fil_rouge_cible.visite (
        presentation_id,
        date_visite,
        retour_client,
        interet
    )
    VALUES (
        v_presentation_3,
        '2025-03-22 10:00:00',
        'Bien correspondant aux critères',
        'fort'
    );


    INSERT INTO fil_rouge_cible.visite (
        presentation_id,
        date_visite,
        retour_client,
        interet
    )
    VALUES (
        v_presentation_4,
        '2025-04-20 16:00:00',
        'Bien intéressant mais négociation souhaitée',
        'moyen'
    );


    -- ========================================================
    -- 7. OFFRES
    -- ========================================================

    INSERT INTO fil_rouge_cible.offre (
        presentation_id,
        date_offre,
        montant_offre,
        condition_financement,
        statut
    )
    VALUES (
        v_presentation_1,
        '2025-02-18',
        242000.00,
        'Financement bancaire',
        'acceptee'
    )
    RETURNING id_offre INTO v_offre_1;


    INSERT INTO fil_rouge_cible.offre (
        presentation_id,
        date_offre,
        montant_offre,
        condition_financement,
        statut
    )
    VALUES (
        v_presentation_3,
        '2025-03-25',
        410000.00,
        'Financement bancaire',
        'acceptee'
    )
    RETURNING id_offre INTO v_offre_2;


    INSERT INTO fil_rouge_cible.offre (
        presentation_id,
        date_offre,
        montant_offre,
        condition_financement,
        statut
    )
    VALUES (
        v_presentation_4,
        '2025-04-23',
        138000.00,
        'Comptant',
        'refusee'
    )
    RETURNING id_offre INTO v_offre_3;


    -- ========================================================
    -- 8. NOTAIRES
    -- ========================================================

    INSERT INTO fil_rouge_cible.notaire (
        nom,
        prenom,
        email,
        telephone
    )
    VALUES (
        'Phase3',
        'NotaireA',
        'phase3.notaire.a@example.test',
        '0000000001'
    )
    RETURNING id_notaire INTO v_notaire_1;


    INSERT INTO fil_rouge_cible.notaire (
        nom,
        prenom,
        email,
        telephone
    )
    VALUES (
        'Phase3',
        'NotaireB',
        'phase3.notaire.b@example.test',
        '0000000002'
    )
    RETURNING id_notaire INTO v_notaire_2;


    -- ========================================================
    -- 9. ACTES AUTHENTIQUES
    -- ========================================================

    -- Seules les deux offres acceptées deviennent des ventes.

    INSERT INTO fil_rouge_cible.acte_authentique (
        offre_id,
        notaire_id,
        date_acte,
        prix_vente
    )
    VALUES (
        v_offre_1,
        v_notaire_1,
        '2025-03-20',
        245000.00
    )
    RETURNING id_acte INTO v_acte_1;


    INSERT INTO fil_rouge_cible.acte_authentique (
        offre_id,
        notaire_id,
        date_acte,
        prix_vente
    )
    VALUES (
        v_offre_2,
        v_notaire_2,
        '2025-04-30',
        415000.00
    )
    RETURNING id_acte INTO v_acte_2;


    -- ========================================================
    -- 10. HONORAIRES
    -- ========================================================

    INSERT INTO fil_rouge_cible.honoraires (
        acte_id,
        montant_fixe,
        pourcentage,
        montant_total
    )
    VALUES (
        v_acte_1,
        NULL,
        3.0000,
        7350.00
    )
    RETURNING id_honoraires INTO v_honoraires_1;


    INSERT INTO fil_rouge_cible.honoraires (
        acte_id,
        montant_fixe,
        pourcentage,
        montant_total
    )
    VALUES (
        v_acte_2,
        NULL,
        3.0000,
        12450.00
    )
    RETURNING id_honoraires INTO v_honoraires_2;


    -- ========================================================
    -- 11. BARÈMES DE COMMISSION
    -- ========================================================

    INSERT INTO fil_rouge_cible.bareme_commission (
        chasseur_id,
        date_debut_validite,
        date_fin_validite
    )
    VALUES (
        v_chasseur_1,
        '2025-01-01',
        NULL
    )
    RETURNING id_bareme INTO v_bareme_1;


    INSERT INTO fil_rouge_cible.bareme_commission (
        chasseur_id,
        date_debut_validite,
        date_fin_validite
    )
    VALUES (
        v_chasseur_2,
        '2025-01-01',
        NULL
    )
    RETURNING id_bareme INTO v_bareme_2;


    -- ========================================================
    -- 12. TRANCHES DE COMMISSION
    -- ========================================================

    INSERT INTO fil_rouge_cible.tranche_commission (
        bareme_id,
        montant_min,
        montant_max,
        taux_pourcentage
    )
    VALUES (
        v_bareme_1,
        0.00,
        1000000.00,
        50.0000
    )
    RETURNING id_tranche INTO v_tranche_1;


    INSERT INTO fil_rouge_cible.tranche_commission (
        bareme_id,
        montant_min,
        montant_max,
        taux_pourcentage
    )
    VALUES (
        v_bareme_2,
        0.00,
        1000000.00,
        50.0000
    )
    RETURNING id_tranche INTO v_tranche_2;


    -- ========================================================
    -- 13. COMMISSIONS
    -- ========================================================

    -- Commission = 50 % des honoraires pour ce jeu de test.

    INSERT INTO fil_rouge_cible.commission (
        honoraires_id,
        chasseur_id,
        tranche_id,
        montant_commission,
        taux_applique
    )
    VALUES (
        v_honoraires_1,
        v_chasseur_1,
        v_tranche_1,
        3675.00,
        50.0000
    );


    INSERT INTO fil_rouge_cible.commission (
        honoraires_id,
        chasseur_id,
        tranche_id,
        montant_commission,
        taux_applique
    )
    VALUES (
        v_honoraires_2,
        v_chasseur_2,
        v_tranche_2,
        6225.00,
        50.0000
    );


    RAISE NOTICE 'Jeu de test Phase 3 créé avec succès.';

END $$;

COMMIT;


-- ============================================================
-- 14. CONTRÔLE
-- ============================================================

SELECT 'bien' AS table_source, COUNT(*) AS lignes
FROM fil_rouge_cible.bien

UNION ALL

SELECT 'presentation', COUNT(*)
FROM fil_rouge_cible.presentation

UNION ALL

SELECT 'visite', COUNT(*)
FROM fil_rouge_cible.visite

UNION ALL

SELECT 'offre', COUNT(*)
FROM fil_rouge_cible.offre

UNION ALL

SELECT 'acte_authentique', COUNT(*)
FROM fil_rouge_cible.acte_authentique

UNION ALL

SELECT 'honoraires', COUNT(*)
FROM fil_rouge_cible.honoraires

UNION ALL

SELECT 'commission', COUNT(*)
FROM fil_rouge_cible.commission;