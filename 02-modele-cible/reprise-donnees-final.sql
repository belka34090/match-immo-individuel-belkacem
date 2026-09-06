-- ============================================================
-- Projet RNCP40573 - Chasse immobiliere
-- Phase 2 - Reprise des donnees de l'existant vers le modele cible
-- Fichier : reprise-donnees.sql
-- SGBD    : PostgreSQL 16
--
-- Source  : schema "Fil_Rouge_Depart"
-- Cible   : schema fil_rouge_cible
-- Date de reference metier : 2026-07-25
--
-- Objectifs :
-- - reprendre uniquement les donnees justifiables depuis l'existant ;
-- - tracer les anomalies et les hypotheses de transformation ;
-- - ne pas inventer de donnees metier absentes de la source ;
-- - rendre la reprise rejouable, transactionnelle et controlable.
--
-- Prerequis :
-- 1. avoir importe fixtures/PgSQL.sql ;
-- 2. avoir execute migration-final.sql ;
-- 3. executer ce fichier avec psql (ON_ERROR_STOP est active).
-- ============================================================

\set ON_ERROR_STOP on

BEGIN;

-- ============================================================
-- 1. CONTROLES PREALABLES
-- ============================================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_namespace WHERE nspname = 'Fil_Rouge_Depart'
    ) THEN
        RAISE EXCEPTION 'Schema source "Fil_Rouge_Depart" absent. Importer PgSQL.sql avant la reprise.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_namespace WHERE nspname = 'fil_rouge_cible'
    ) THEN
        RAISE EXCEPTION 'Schema cible fil_rouge_cible absent. Executer migration-final.sql avant la reprise.';
    END IF;
END
$$;

-- Les fixtures officielles constituent la reference de depart.
DO $$
DECLARE
    v_secteurs     INTEGER;
    v_utilisateurs INTEGER;
    v_mandats      INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_secteurs
    FROM "Fil_Rouge_Depart".secteurs;

    SELECT COUNT(*) INTO v_utilisateurs
    FROM "Fil_Rouge_Depart".utilisateurs;

    SELECT COUNT(*) INTO v_mandats
    FROM "Fil_Rouge_Depart".mandats;

    IF v_secteurs <> 10 THEN
        RAISE EXCEPTION 'Source inattendue : 10 secteurs attendus, % trouves.', v_secteurs;
    END IF;

    IF v_utilisateurs <> 24 THEN
        RAISE EXCEPTION 'Source inattendue : 24 utilisateurs attendus, % trouves.', v_utilisateurs;
    END IF;

    IF v_mandats <> 18 THEN
        RAISE EXCEPTION 'Source inattendue : 18 mandats attendus, % trouves.', v_mandats;
    END IF;
END
$$;

-- ============================================================
-- 2. ZONE DE CONTROLE DE REPRISE
-- ============================================================
-- Ce schema ne fait pas partie du modele metier cible.
-- Il conserve les preuves de migration : hypotheses, rejets,
-- corrections et donnees source non injectees dans le modele cible.

DROP SCHEMA IF EXISTS reprise_controle CASCADE;
CREATE SCHEMA reprise_controle;

CREATE TABLE reprise_controle.hypothese_reprise (
    id_hypothese INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    objet VARCHAR(80) NOT NULL,
    regle TEXT NOT NULL,
    justification TEXT NOT NULL
);

CREATE TABLE reprise_controle.rejet_mandat (
    id_mandat_source INTEGER PRIMARY KEY,
    client_id_source INTEGER NOT NULL,
    chasseur_id_source INTEGER NOT NULL,
    code_rejet VARCHAR(40) NOT NULL,
    motif TEXT NOT NULL,
    date_rejet TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reprise_controle.correction_mandat (
    id_mandat_source INTEGER PRIMARY KEY,
    statut_source VARCHAR(30) NOT NULL,
    statut_cible VARCHAR(30) NOT NULL,
    date_debut_source DATE NOT NULL,
    date_fin_calculee DATE NOT NULL,
    code_correction VARCHAR(40) NOT NULL,
    justification TEXT NOT NULL
);

CREATE TABLE reprise_controle.donnee_source_non_reprise (
    id_trace INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_source VARCHAR(80) NOT NULL,
    id_source INTEGER NOT NULL,
    champ_source VARCHAR(80) NOT NULL,
    valeur_source TEXT,
    raison TEXT NOT NULL
);

-- Hypotheses explicites : aucune de ces valeurs n'est presente telle quelle
-- dans l'ancien schema. Elles sont necessaires pour satisfaire le modele cible.
INSERT INTO reprise_controle.hypothese_reprise (objet, regle, justification) VALUES
(
    'utilisateur.statut_compte',
    'Tous les utilisateurs repris recoivent le statut ''migre_historique''.',
    'L''ancien SI ne possede pas de statut de compte.'
),
(
    'client.statut',
    'Tous les profils clients repris recoivent le statut ''historique''.',
    'L''ancien SI ne possede pas de statut propre au profil client.'
),
(
    'chasseur.matricule',
    'Le matricule est genere sous la forme LEGACY-CH-XXX a partir de l''identifiant source.',
    'L''ancien SI ne possede pas de matricule chasseur.'
),
(
    'demande',
    'Une demande historique est reconstruite pour chaque mandat source migrable ; son identifiant reprend celui du mandat et sa date_creation reprend date_debut.',
    'L''ancien SI ne possede pas de table DEMANDE. date_debut est la premiere date certaine disponible pour cette relation metier.'
),
(
    'affectation',
    'Une affectation acceptee historique est reconstruite pour chaque mandat migrable, au chasseur porte par le mandat.',
    'Un mandat existant prouve la prise en charge par ce chasseur, mais l''ancien SI ne conserve ni la date ni le workflow d''affectation. La date_debut est utilisee comme date technique de reprise.'
),
(
    'version_demande',
    'Une version numero 1 est creee par demande ; budget_max provient du client source ; les autres criteres structures restent NULL.',
    'Les autres criteres sont enfermes dans description_recherche en texte libre et ne sont pas parses afin de ne pas inventer de donnees.'
),
(
    'mandat.date_signature',
    'date_signature reprend date_debut de l''ancien mandat.',
    'L''ancien SI ne possede pas de date de signature distincte.'
),
(
    'mandat.mode_signature',
    'mode_signature vaut ''historique_inconnu''.',
    'Aucune information de mode de signature n''existe dans la source.'
),
(
    'mandat.date_fin',
    'date_fin = date_signature + 6 mois.',
    'La duree metier officielle du mandat est de 6 mois.'
),
(
    'bareme_commission',
    'Le taux source courant de chaque chasseur devient un bareme de transition valable a partir du 2026-07-25, avec une seule tranche couvrant 0 a 9 999 999 999,99 EUR.',
    'La source ne conserve ni historique de validite ni tranches. La date de reference permet de preserver le taux connu sans fabriquer un historique anterieur.'
);

-- ============================================================
-- 3. REMISE A ZERO DE LA CIBLE
-- ============================================================
-- Le script est rejouable. CASCADE respecte les dependances de cles
-- etrangeres ; RESTART IDENTITY remet les sequences a leur etat initial.

TRUNCATE TABLE
    fil_rouge_cible.paiement,
    fil_rouge_cible.facture_chasseur,
    fil_rouge_cible.commission,
    fil_rouge_cible.tranche_commission,
    fil_rouge_cible.bareme_commission,
    fil_rouge_cible.honoraires,
    fil_rouge_cible.acte_authentique,
    fil_rouge_cible.notaire,
    fil_rouge_cible.offre,
    fil_rouge_cible.media_avis,
    fil_rouge_cible.avis_chasseur,
    fil_rouge_cible.visite,
    fil_rouge_cible.commentaire,
    fil_rouge_cible.presentation,
    fil_rouge_cible.vendeur_bien,
    fil_rouge_cible.vendeur,
    fil_rouge_cible.bien,
    fil_rouge_cible.mandat,
    fil_rouge_cible.version_demande_secteur,
    fil_rouge_cible.secteur,
    fil_rouge_cible.version_demande,
    fil_rouge_cible.affectation,
    fil_rouge_cible.demande,
    fil_rouge_cible.chasseur,
    fil_rouge_cible.client,
    fil_rouge_cible.utilisateur
RESTART IDENTITY CASCADE;

-- ============================================================
-- 4. TRACE DES DONNEES SOURCE QUI NE SONT PAS INJECTEES TELLES QUELLES
-- ============================================================

-- La ville du compte n'a pas d'equivalent dans UTILISATEUR cible.
INSERT INTO reprise_controle.donnee_source_non_reprise
    (table_source, id_source, champ_source, valeur_source, raison)
SELECT
    'utilisateurs',
    u.id,
    'ville',
    u.ville,
    'Aucun attribut equivalent dans UTILISATEUR cible ; ne pas confondre avec le secteur d''une recherche.'
FROM "Fil_Rouge_Depart".utilisateurs u
WHERE u.ville IS NOT NULL;

-- La date de creation du compte source n'a pas d'attribut equivalent
-- dans UTILISATEUR cible. Elle n'est pas reinterpretee en date de demande.
INSERT INTO reprise_controle.donnee_source_non_reprise
    (table_source, id_source, champ_source, valeur_source, raison)
SELECT
    'utilisateurs',
    u.id,
    'date_creation',
    u.date_creation::TEXT,
    'La cible ne porte pas la date historique de creation du compte utilisateur.'
FROM "Fil_Rouge_Depart".utilisateurs u;

-- Le texte libre est conserve en preuve mais n'est pas parse automatiquement.
INSERT INTO reprise_controle.donnee_source_non_reprise
    (table_source, id_source, champ_source, valeur_source, raison)
SELECT
    'mandats',
    m.id,
    'description_recherche',
    m.description_recherche,
    'Criteres non structures : conservation en trace de reprise, sans extraction automatique incertaine.'
FROM "Fil_Rouge_Depart".mandats m
WHERE m.description_recherche IS NOT NULL;

-- Les budgets de clients sans mandat migrable ne peuvent pas etre rattaches
-- de facon certaine a une VERSION_DEMANDE cible.
INSERT INTO reprise_controle.donnee_source_non_reprise
    (table_source, id_source, champ_source, valeur_source, raison)
SELECT
    'utilisateurs',
    u.id,
    'budget_max',
    u.budget_max::TEXT,
    'Client sans mandat source migrable : aucune demande cible certaine a laquelle rattacher ce budget.'
FROM "Fil_Rouge_Depart".utilisateurs u
WHERE u.role = 'client'
  AND u.budget_max IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM "Fil_Rouge_Depart".mandats m
      JOIN "Fil_Rouge_Depart".utilisateurs uc ON uc.id = m.client_id
      JOIN "Fil_Rouge_Depart".utilisateurs uh ON uh.id = m.chasseur_id
      WHERE m.client_id = u.id
        AND uc.role = 'client'
        AND uh.role = 'chasseur'
        AND m.date_debut >= uh.date_creation
  );

-- ============================================================
-- 5. REPRISE DES SECTEURS
-- ============================================================

INSERT INTO fil_rouge_cible.secteur
    (id_secteur, ville, quartier, code_postal)
SELECT
    id,
    ville,
    quartier,
    code_postal
FROM "Fil_Rouge_Depart".secteurs
ORDER BY id;

-- ============================================================
-- 6. REPRISE DES UTILISATEURS
-- ============================================================

INSERT INTO fil_rouge_cible.utilisateur
    (id_utilisateur, nom, prenom, email, telephone, statut_compte)
SELECT
    id,
    nom,
    prenom,
    email,
    telephone,
    'migre_historique'
FROM "Fil_Rouge_Depart".utilisateurs
ORDER BY id;

-- Specialisation CLIENT.
INSERT INTO fil_rouge_cible.client (id_client, statut)
SELECT
    id,
    'historique'
FROM "Fil_Rouge_Depart".utilisateurs
WHERE role = 'client'
ORDER BY id;

-- Specialisation CHASSEUR.
INSERT INTO fil_rouge_cible.chasseur
    (id_chasseur, matricule, disponibilite)
SELECT
    id,
    'LEGACY-CH-' || LPAD(id::TEXT, 3, '0'),
    NULL
FROM "Fil_Rouge_Depart".utilisateurs
WHERE role = 'chasseur'
ORDER BY id;

-- ============================================================
-- 7. DETECTION ET JOURNALISATION DES MANDATS NON MIGRABLES
-- ============================================================
-- Deux anomalies confirmees pendant la Phase 1 rendent un mandat
-- non migrable sans arbitrage humain :
-- - A-01 : le client reference n'a pas le role client ;
-- - A-03 : le mandat commence avant la creation du chasseur dans le SI.
--
-- On ne corrige pas ces donnees au hasard : elles sont placees en rejet.

INSERT INTO reprise_controle.rejet_mandat
    (id_mandat_source, client_id_source, chasseur_id_source, code_rejet, motif)
SELECT
    m.id,
    m.client_id,
    m.chasseur_id,
    CASE
        WHEN uc.role <> 'client' AND uh.role <> 'chasseur' THEN 'R-ROLE-DOUBLE'
        WHEN uc.role <> 'client' THEN 'R-CLIENT-ROLE'
        WHEN uh.role <> 'chasseur' THEN 'R-CHASSEUR-ROLE'
        WHEN m.date_debut < uh.date_creation THEN 'R-CHASSEUR-DATE'
        ELSE 'R-INCONNU'
    END,
    CASE
        WHEN uc.role <> 'client' AND uh.role <> 'chasseur'
            THEN 'client_id et chasseur_id portent tous deux un role incompatible.'
        WHEN uc.role <> 'client'
            THEN 'client_id=' || m.client_id || ' reference un utilisateur de role ' || uc.role::TEXT || ' au lieu de client.'
        WHEN uh.role <> 'chasseur'
            THEN 'chasseur_id=' || m.chasseur_id || ' reference un utilisateur de role ' || uh.role::TEXT || ' au lieu de chasseur.'
        WHEN m.date_debut < uh.date_creation
            THEN 'Le mandat debute le ' || m.date_debut::TEXT ||
                 ' alors que le chasseur_id=' || m.chasseur_id ||
                 ' a ete cree dans le SI le ' || uh.date_creation::TEXT ||
                 '. Aucune correction fiable ne peut etre deduite.'
        ELSE 'Mandat non migrable pour une raison non classee.'
    END
FROM "Fil_Rouge_Depart".mandats m
JOIN "Fil_Rouge_Depart".utilisateurs uc ON uc.id = m.client_id
JOIN "Fil_Rouge_Depart".utilisateurs uh ON uh.id = m.chasseur_id
WHERE uc.role <> 'client'
   OR uh.role <> 'chasseur'
   OR m.date_debut < uh.date_creation;

-- Jeu temporaire des mandats effectivement migrables.
-- Les roles doivent etre coherents ET le mandat ne doit pas preceder
-- la date de creation du chasseur dans le SI source.
CREATE TEMP TABLE tmp_mandats_valides ON COMMIT DROP AS
SELECT
    m.id,
    m.client_id,
    m.chasseur_id,
    m.secteur_id,
    m.exclusif,
    m.date_debut,
    m.statut::TEXT AS statut_source,
    m.description_recherche,
    uc.budget_max
FROM "Fil_Rouge_Depart".mandats m
JOIN "Fil_Rouge_Depart".utilisateurs uc
    ON uc.id = m.client_id
   AND uc.role = 'client'
JOIN "Fil_Rouge_Depart".utilisateurs uh
    ON uh.id = m.chasseur_id
   AND uh.role = 'chasseur'
WHERE m.date_debut >= uh.date_creation;

-- ============================================================
-- 8. CORRECTION DOCUMENTEE DES STATUTS DE MANDAT
-- ============================================================
-- Au 25/07/2026, un mandat marque actif mais dont la date_debut + 6 mois
-- est deja passee est migre avec le statut 'expire'.
-- La Phase 1 detectait 6 cas A-02. Le mandat 9 est aussi A-03 et est
-- desormais rejete : il reste donc 5 corrections actif -> expire en cible.

INSERT INTO reprise_controle.correction_mandat
    (id_mandat_source, statut_source, statut_cible,
     date_debut_source, date_fin_calculee,
     code_correction, justification)
SELECT
    id,
    statut_source,
    'expire',
    date_debut,
    (date_debut + INTERVAL '6 months')::DATE,
    'C-ACTIF-EXPIRE',
    'Statut source actif incoherent avec la duree metier de 6 mois a la date de reference 2026-07-25.'
FROM tmp_mandats_valides
WHERE statut_source = 'actif'
  AND (date_debut + INTERVAL '6 months')::DATE < DATE '2026-07-25';

-- ============================================================
-- 9. RECONSTRUCTION DES DEMANDES HISTORIQUES
-- ============================================================

INSERT INTO fil_rouge_cible.demande
    (id_demande, client_id, date_creation, statut)
SELECT
    id,                -- identifiant technique deterministe = mandat source
    client_id,
    date_debut,        -- hypothese documentee
    'historique_migree'
FROM tmp_mandats_valides
ORDER BY id;

-- ============================================================
-- 10. RECONSTRUCTION DES AFFECTATIONS HISTORIQUES
-- ============================================================

INSERT INTO fil_rouge_cible.affectation
    (id_affectation, demande_id, chasseur_id,
     date_affectation, date_reponse, statut, motif_refus)
SELECT
    id,
    id,
    chasseur_id,
    date_debut::TIMESTAMP,
    date_debut::TIMESTAMP,
    'acceptee_historique',
    NULL
FROM tmp_mandats_valides
ORDER BY id;

-- ============================================================
-- 11. RECONSTRUCTION DE LA VERSION INITIALE DE DEMANDE
-- ============================================================
-- Seul budget_max provient d'une colonne structuree de la source.
-- Les surfaces, le nombre de pieces et budget_min restent NULL.

INSERT INTO fil_rouge_cible.version_demande
    (id_version, demande_id, auteur_id,
     numero_version, date_version,
     budget_min, budget_max,
     surface_min, surface_max, nb_pieces_min,
     motif_modification, est_courante)
SELECT
    id,
    id,
    client_id,
    1,
    date_debut::TIMESTAMP,
    NULL,
    budget_max,
    NULL,
    NULL,
    NULL,
    'Reprise historique : criteres libres conserves dans reprise_controle, sans parsing automatique.',
    TRUE
FROM tmp_mandats_valides
ORDER BY id;

-- Chaque version cible le secteur explicitement reference par le mandat source.
INSERT INTO fil_rouge_cible.version_demande_secteur
    (version_id, secteur_id)
SELECT
    id,
    secteur_id
FROM tmp_mandats_valides
WHERE secteur_id IS NOT NULL
ORDER BY id;

-- ============================================================
-- 12. REPRISE DES MANDATS
-- ============================================================

INSERT INTO fil_rouge_cible.mandat
    (id_mandat, demande_id, client_id, chasseur_id,
     mandat_precedent_id,
     date_signature, mode_signature,
     exclusif, date_fin, statut)
SELECT
    id,
    id,
    client_id,
    chasseur_id,
    NULL,
    date_debut,
    'historique_inconnu',
    exclusif,
    (date_debut + INTERVAL '6 months')::DATE,
    CASE
        WHEN statut_source = 'actif'
         AND (date_debut + INTERVAL '6 months')::DATE < DATE '2026-07-25'
            THEN 'expire'
        ELSE statut_source
    END
FROM tmp_mandats_valides
ORDER BY id;

-- Aucun renouvellement ne peut etre reconstruit avec certitude :
-- la source n'en conserve pas la filiation.

-- ============================================================
-- 13. TRANSFORMATION DU TAUX LEGACY EN BAREME DE TRANSITION
-- ============================================================
-- On ne pretend pas reconstruire l'historique des baremes.
-- Le taux connu dans la photographie du 25/07/2026 devient un bareme
-- de transition applicable a partir de cette date.

INSERT INTO fil_rouge_cible.bareme_commission
    (id_bareme, chasseur_id, date_debut_validite, date_fin_validite)
SELECT
    id,
    id,
    DATE '2026-07-25',
    NULL
FROM "Fil_Rouge_Depart".utilisateurs
WHERE role = 'chasseur'
  AND taux_commission IS NOT NULL
ORDER BY id;

INSERT INTO fil_rouge_cible.tranche_commission
    (id_tranche, bareme_id, montant_min, montant_max, taux_pourcentage)
SELECT
    id,
    id,
    0.00,
    9999999999.99,
    taux_commission
FROM "Fil_Rouge_Depart".utilisateurs
WHERE role = 'chasseur'
  AND taux_commission IS NOT NULL
ORDER BY id;

-- ============================================================
-- 14. TABLES CIBLES VOLONTAIREMENT LAISSEES VIDES
-- ============================================================
-- La source ne contient aucune donnee certaine permettant d'alimenter :
-- BIEN, VENDEUR, VENDEUR_BIEN, PRESENTATION, COMMENTAIRE, VISITE,
-- AVIS_CHASSEUR, MEDIA_AVIS, OFFRE, NOTAIRE, ACTE_AUTHENTIQUE,
-- HONORAIRES, COMMISSION, FACTURE_CHASSEUR et PAIEMENT.
--
-- Aucun enregistrement fictif n'est cree pour ces objets.

-- ============================================================
-- 15. REALIGNEMENT DES SEQUENCES D'IDENTITE
-- ============================================================
-- Les identifiants source ont ete conserves explicitement. PostgreSQL doit
-- donc etre informe du dernier identifiant utilise avant les futurs INSERT.

SELECT setval(
    pg_get_serial_sequence('fil_rouge_cible.utilisateur', 'id_utilisateur'),
    (SELECT MAX(id_utilisateur) FROM fil_rouge_cible.utilisateur),
    TRUE
);

SELECT setval(
    pg_get_serial_sequence('fil_rouge_cible.secteur', 'id_secteur'),
    (SELECT MAX(id_secteur) FROM fil_rouge_cible.secteur),
    TRUE
);

SELECT setval(
    pg_get_serial_sequence('fil_rouge_cible.demande', 'id_demande'),
    (SELECT MAX(id_demande) FROM fil_rouge_cible.demande),
    TRUE
);

SELECT setval(
    pg_get_serial_sequence('fil_rouge_cible.affectation', 'id_affectation'),
    (SELECT MAX(id_affectation) FROM fil_rouge_cible.affectation),
    TRUE
);

SELECT setval(
    pg_get_serial_sequence('fil_rouge_cible.version_demande', 'id_version'),
    (SELECT MAX(id_version) FROM fil_rouge_cible.version_demande),
    TRUE
);

SELECT setval(
    pg_get_serial_sequence('fil_rouge_cible.mandat', 'id_mandat'),
    (SELECT MAX(id_mandat) FROM fil_rouge_cible.mandat),
    TRUE
);

SELECT setval(
    pg_get_serial_sequence('fil_rouge_cible.bareme_commission', 'id_bareme'),
    (SELECT MAX(id_bareme) FROM fil_rouge_cible.bareme_commission),
    TRUE
);

SELECT setval(
    pg_get_serial_sequence('fil_rouge_cible.tranche_commission', 'id_tranche'),
    (SELECT MAX(id_tranche) FROM fil_rouge_cible.tranche_commission),
    TRUE
);

-- ============================================================
-- 16. CONTROLES BLOQUANTS AVANT COMMIT
-- ============================================================
-- Si un resultat n'est pas celui attendu, la transaction echoue et aucune
-- reprise partielle n'est validee.

DO $$
DECLARE
    v INTEGER;
BEGIN
    SELECT COUNT(*) INTO v FROM fil_rouge_cible.secteur;
    IF v <> 10 THEN RAISE EXCEPTION 'Controle cible : 10 secteurs attendus, % trouves.', v; END IF;

    SELECT COUNT(*) INTO v FROM fil_rouge_cible.utilisateur;
    IF v <> 24 THEN RAISE EXCEPTION 'Controle cible : 24 utilisateurs attendus, % trouves.', v; END IF;

    SELECT COUNT(*) INTO v FROM fil_rouge_cible.client;
    IF v <> 18 THEN RAISE EXCEPTION 'Controle cible : 18 clients attendus, % trouves.', v; END IF;

    SELECT COUNT(*) INTO v FROM fil_rouge_cible.chasseur;
    IF v <> 6 THEN RAISE EXCEPTION 'Controle cible : 6 chasseurs attendus, % trouves.', v; END IF;

    SELECT COUNT(*) INTO v FROM reprise_controle.rejet_mandat;
    IF v <> 2 THEN RAISE EXCEPTION 'Controle reprise : 2 mandats rejetes attendus, % trouves.', v; END IF;

    SELECT COUNT(*) INTO v FROM fil_rouge_cible.demande;
    IF v <> 16 THEN RAISE EXCEPTION 'Controle cible : 16 demandes historiques attendues, % trouvees.', v; END IF;

    SELECT COUNT(*) INTO v FROM fil_rouge_cible.affectation;
    IF v <> 16 THEN RAISE EXCEPTION 'Controle cible : 16 affectations historiques attendues, % trouvees.', v; END IF;

    SELECT COUNT(*) INTO v FROM fil_rouge_cible.version_demande;
    IF v <> 16 THEN RAISE EXCEPTION 'Controle cible : 16 versions de demande attendues, % trouvees.', v; END IF;

    SELECT COUNT(*) INTO v FROM fil_rouge_cible.version_demande_secteur;
    IF v <> 16 THEN RAISE EXCEPTION 'Controle cible : 16 associations version/secteur attendues, % trouvees.', v; END IF;

    SELECT COUNT(*) INTO v FROM fil_rouge_cible.mandat;
    IF v <> 16 THEN RAISE EXCEPTION 'Controle cible : 16 mandats migres attendus, % trouves.', v; END IF;

    SELECT COUNT(*) INTO v FROM reprise_controle.correction_mandat;
    IF v <> 5 THEN RAISE EXCEPTION 'Controle reprise : 5 statuts actif->expire attendus parmi les mandats migres, % trouves.', v; END IF;

    SELECT COUNT(*) INTO v FROM fil_rouge_cible.bareme_commission;
    IF v <> 6 THEN RAISE EXCEPTION 'Controle cible : 6 baremes de transition attendus, % trouves.', v; END IF;

    SELECT COUNT(*) INTO v FROM fil_rouge_cible.tranche_commission;
    IF v <> 6 THEN RAISE EXCEPTION 'Controle cible : 6 tranches de transition attendues, % trouvees.', v; END IF;
END
$$;

-- Chaque demande doit avoir exactement une version courante issue de la reprise.
DO $$
DECLARE
    v INTEGER;
BEGIN
    SELECT COUNT(*) INTO v
    FROM fil_rouge_cible.demande d
    LEFT JOIN fil_rouge_cible.version_demande vd
      ON vd.demande_id = d.id_demande
     AND vd.est_courante = TRUE
    WHERE vd.id_version IS NULL;

    IF v <> 0 THEN
        RAISE EXCEPTION 'Controle integrite : % demande(s) sans version courante.', v;
    END IF;
END
$$;

-- Chaque version reprise doit cibler au moins un secteur.
DO $$
DECLARE
    v INTEGER;
BEGIN
    SELECT COUNT(*) INTO v
    FROM fil_rouge_cible.version_demande vd
    LEFT JOIN fil_rouge_cible.version_demande_secteur vds
      ON vds.version_id = vd.id_version
    WHERE vds.version_id IS NULL;

    IF v <> 0 THEN
        RAISE EXCEPTION 'Controle integrite : % version(s) sans secteur.', v;
    END IF;
END
$$;

-- Le chasseur du mandat doit correspondre a l'affectation reconstruite.
DO $$
DECLARE
    v INTEGER;
BEGIN
    SELECT COUNT(*) INTO v
    FROM fil_rouge_cible.mandat m
    LEFT JOIN fil_rouge_cible.affectation a
      ON a.demande_id = m.demande_id
     AND a.chasseur_id = m.chasseur_id
    WHERE a.id_affectation IS NULL;

    IF v <> 0 THEN
        RAISE EXCEPTION 'Controle coherence : % mandat(s) sans affectation coherente.', v;
    END IF;
END
$$;

-- Au 25/07/2026, aucun mandat cible conserve 'actif' si ses 6 mois sont depasses.
DO $$
DECLARE
    v INTEGER;
BEGIN
    SELECT COUNT(*) INTO v
    FROM fil_rouge_cible.mandat
    WHERE statut = 'actif'
      AND date_fin < DATE '2026-07-25';

    IF v <> 0 THEN
        RAISE EXCEPTION 'Controle statut : % mandat(s) encore actif(s) apres date_fin.', v;
    END IF;
END
$$;

-- Les deux rejets attendus doivent correspondre aux anomalies A-01 et A-03.
DO $$
DECLARE
    v INTEGER;
BEGIN
    SELECT COUNT(*) INTO v
    FROM reprise_controle.rejet_mandat
    WHERE id_mandat_source = 13
      AND client_id_source = 3
      AND code_rejet = 'R-CLIENT-ROLE';

    IF v <> 1 THEN
        RAISE EXCEPTION 'Controle anomalie A-01 : le mandat 13 avec client_id=3 n''a pas ete rejete comme attendu.';
    END IF;

    SELECT COUNT(*) INTO v
    FROM reprise_controle.rejet_mandat
    WHERE id_mandat_source = 9
      AND chasseur_id_source = 6
      AND code_rejet = 'R-CHASSEUR-DATE';

    IF v <> 1 THEN
        RAISE EXCEPTION 'Controle anomalie A-03 : le mandat 9 n''a pas ete rejete pour incoherence temporelle comme attendu.';
    END IF;
END
$$;

COMMIT;

-- ============================================================
-- 17. RAPPORT DE REPRISE POST-COMMIT
-- ============================================================
-- Ces SELECT produisent une preuve lisible dans psql / DataGrip.

SELECT 'SOURCE secteurs' AS controle, COUNT(*) AS nb
FROM "Fil_Rouge_Depart".secteurs
UNION ALL
SELECT 'SOURCE utilisateurs', COUNT(*)
FROM "Fil_Rouge_Depart".utilisateurs
UNION ALL
SELECT 'SOURCE mandats', COUNT(*)
FROM "Fil_Rouge_Depart".mandats
UNION ALL
SELECT 'CIBLE secteur', COUNT(*)
FROM fil_rouge_cible.secteur
UNION ALL
SELECT 'CIBLE utilisateur', COUNT(*)
FROM fil_rouge_cible.utilisateur
UNION ALL
SELECT 'CIBLE client', COUNT(*)
FROM fil_rouge_cible.client
UNION ALL
SELECT 'CIBLE chasseur', COUNT(*)
FROM fil_rouge_cible.chasseur
UNION ALL
SELECT 'CIBLE demande', COUNT(*)
FROM fil_rouge_cible.demande
UNION ALL
SELECT 'CIBLE affectation', COUNT(*)
FROM fil_rouge_cible.affectation
UNION ALL
SELECT 'CIBLE version_demande', COUNT(*)
FROM fil_rouge_cible.version_demande
UNION ALL
SELECT 'CIBLE mandat', COUNT(*)
FROM fil_rouge_cible.mandat
UNION ALL
SELECT 'REPRISE rejets mandat', COUNT(*)
FROM reprise_controle.rejet_mandat
UNION ALL
SELECT 'REPRISE corrections statut', COUNT(*)
FROM reprise_controle.correction_mandat
UNION ALL
SELECT 'CIBLE bareme_commission', COUNT(*)
FROM fil_rouge_cible.bareme_commission
UNION ALL
SELECT 'CIBLE tranche_commission', COUNT(*)
FROM fil_rouge_cible.tranche_commission;

-- Detail des rejets.
SELECT *
FROM reprise_controle.rejet_mandat
ORDER BY id_mandat_source;

-- Detail des statuts corriges.
SELECT *
FROM reprise_controle.correction_mandat
ORDER BY id_mandat_source;

-- Repartition finale des statuts des 16 mandats migres.
SELECT statut, COUNT(*) AS nb
FROM fil_rouge_cible.mandat
GROUP BY statut
ORDER BY statut;

-- Donnees volontairement non inventees : ces tables doivent rester vides.
SELECT 'bien' AS table_cible, COUNT(*) AS nb FROM fil_rouge_cible.bien
UNION ALL SELECT 'vendeur', COUNT(*) FROM fil_rouge_cible.vendeur
UNION ALL SELECT 'presentation', COUNT(*) FROM fil_rouge_cible.presentation
UNION ALL SELECT 'commentaire', COUNT(*) FROM fil_rouge_cible.commentaire
UNION ALL SELECT 'visite', COUNT(*) FROM fil_rouge_cible.visite
UNION ALL SELECT 'avis_chasseur', COUNT(*) FROM fil_rouge_cible.avis_chasseur
UNION ALL SELECT 'media_avis', COUNT(*) FROM fil_rouge_cible.media_avis
UNION ALL SELECT 'offre', COUNT(*) FROM fil_rouge_cible.offre
UNION ALL SELECT 'notaire', COUNT(*) FROM fil_rouge_cible.notaire
UNION ALL SELECT 'acte_authentique', COUNT(*) FROM fil_rouge_cible.acte_authentique
UNION ALL SELECT 'honoraires', COUNT(*) FROM fil_rouge_cible.honoraires
UNION ALL SELECT 'commission', COUNT(*) FROM fil_rouge_cible.commission
UNION ALL SELECT 'facture_chasseur', COUNT(*) FROM fil_rouge_cible.facture_chasseur
UNION ALL SELECT 'paiement', COUNT(*) FROM fil_rouge_cible.paiement
ORDER BY table_cible;

-- ============================================================
-- FIN DU SCRIPT
-- ============================================================
