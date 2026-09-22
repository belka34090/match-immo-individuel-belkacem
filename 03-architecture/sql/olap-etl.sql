-- ============================================================
-- MATCH-IMMO
-- Phase 3 - Absorber la croissance
-- Fichier : olap-etl.sql
--
-- OBJECTIF
-- --------
-- Alimenter le modèle analytique OLAP à partir de la base
-- métier OLTP réelle de Match-Immo.
--
-- SOURCE OLTP :
--     fil_rouge_cible
--
-- DESTINATION OLAP :
--     match_immo_olap
--
-- ETL signifie :
--
--     Extract   = extraire les données métier
--     Transform = les rapprocher / calculer
--     Load      = les charger dans l'OLAP
--
-- IMPORTANT
-- ---------
-- Ce script est conçu pour être réexécutable.
--
-- Une nouvelle exécution ne doit pas créer artificiellement
-- les mêmes dimensions ou les mêmes faits plusieurs fois.
--
-- ============================================================


-- ============================================================
-- 1. DÉBUT DE LA TRANSACTION
-- ============================================================

-- Une transaction regroupe plusieurs opérations SQL.
--
-- Si une erreur survient avant COMMIT, PostgreSQL peut annuler
-- l'ensemble du traitement au lieu de laisser un chargement
-- partiellement terminé.

BEGIN;


-- ============================================================
-- 2. ALIMENTATION DE DIM_TEMPS
-- ============================================================

-- DIM_TEMPS contient les dates nécessaires aux analyses.
--
-- Dans cette première version, deux événements alimentent
-- directement nos tables de faits :
--
-- MANDAT.date_signature
--     → activité du mandat
--
-- ACTE_AUTHENTIQUE.date_acte
--     → vente finalisée
--
-- UNION permet de réunir les dates des deux sources.
--
-- UNION supprime également les doublons.
--
-- ON CONFLICT DO NOTHING signifie :
-- si la date existe déjà dans DIM_TEMPS, ne pas la recréer.

INSERT INTO match_immo_olap.dim_temps (
    date_complete,
    jour,
    mois,
    trimestre,
    annee
)
SELECT
    dates.date_complete,

    EXTRACT(DAY FROM dates.date_complete)::SMALLINT,

    EXTRACT(MONTH FROM dates.date_complete)::SMALLINT,

    EXTRACT(QUARTER FROM dates.date_complete)::SMALLINT,

    EXTRACT(YEAR FROM dates.date_complete)::INTEGER

FROM (
    SELECT date_signature AS date_complete
    FROM fil_rouge_cible.mandat

    UNION

    SELECT date_acte AS date_complete
    FROM fil_rouge_cible.acte_authentique
) AS dates

WHERE dates.date_complete IS NOT NULL

ON CONFLICT (date_complete)
DO NOTHING;


-- ============================================================
-- 3. ALIMENTATION DE DIM_CHASSEUR
-- ============================================================

-- Dans l'OLTP, CHASSEUR ne contient pas directement
-- le nom et le prénom.
--
-- CHASSEUR.id_chasseur est également une clé étrangère vers :
--
-- UTILISATEUR.id_utilisateur
--
-- Il faut donc effectuer une jointure :
--
-- CHASSEUR
--     |
--     v
-- UTILISATEUR
--
-- Une jointure (JOIN) permet de rapprocher des lignes
-- appartenant à plusieurs tables grâce à leurs identifiants.

INSERT INTO match_immo_olap.dim_chasseur (
    chasseur_id_source,
    nom,
    prenom,
    matricule
)
SELECT
    c.id_chasseur,
    u.nom,
    u.prenom,
    c.matricule

FROM fil_rouge_cible.chasseur AS c

JOIN fil_rouge_cible.utilisateur AS u
    ON u.id_utilisateur = c.id_chasseur

ON CONFLICT (chasseur_id_source)
DO UPDATE SET
    nom = EXCLUDED.nom,
    prenom = EXCLUDED.prenom,
    matricule = EXCLUDED.matricule;


-- ============================================================
-- 4. ALIMENTATION DE DIM_CLIENT
-- ============================================================

-- La dimension client est volontairement minimale.
--
-- Nous conservons uniquement l'identifiant source.
--
-- Les informations personnelles telles que :
--
--     nom
--     email
--     téléphone
--
-- ne sont pas nécessaires aux indicateurs actuellement
-- définis.
--
-- Cette décision applique le principe RGPD de minimisation.

INSERT INTO match_immo_olap.dim_client (
    client_id_source
)
SELECT
    c.id_client

FROM fil_rouge_cible.client AS c

ON CONFLICT (client_id_source)
DO NOTHING;


-- ============================================================
-- 5. ALIMENTATION DE DIM_SECTEUR
-- ============================================================

-- La dimension secteur reprend les données géographiques
-- nécessaires aux analyses :
--
--     ville
--     quartier
--     code postal

INSERT INTO match_immo_olap.dim_secteur (
    secteur_id_source,
    ville,
    quartier,
    code_postal
)
SELECT
    s.id_secteur,
    s.ville,
    s.quartier,
    s.code_postal

FROM fil_rouge_cible.secteur AS s

ON CONFLICT (secteur_id_source)
DO UPDATE SET
    ville = EXCLUDED.ville,
    quartier = EXCLUDED.quartier,
    code_postal = EXCLUDED.code_postal;


-- ============================================================
-- 6. ALIMENTATION DE DIM_TYPE_BIEN
-- ============================================================

-- Dans l'OLTP, le type de bien est une colonne de BIEN :
--
--     BIEN.type_bien
--
-- DISTINCT permet de récupérer chaque type une seule fois.
--
-- Exemple :
--
-- Appartement
-- Appartement
-- Maison
--
-- devient :
--
-- Appartement
-- Maison

INSERT INTO match_immo_olap.dim_type_bien (
    type_bien_source
)
SELECT DISTINCT
    b.type_bien

FROM fil_rouge_cible.bien AS b

WHERE b.type_bien IS NOT NULL

ON CONFLICT (type_bien_source)
DO NOTHING;


-- ============================================================
-- 7. ALIMENTATION DE FACT_VENTE
-- ============================================================

-- GRAIN :
--
--     1 ligne FACT_VENTE
--     =
--     1 ACTE_AUTHENTIQUE
--
-- Pour construire une vente analytique, il faut reconstruire
-- son contexte métier.
--
-- La chaîne réelle est :
--
-- ACTE_AUTHENTIQUE
--        |
--        v
--      OFFRE
--        |
--        v
--   PRESENTATION
--      /     \
--     v       v
--  MANDAT    BIEN
--   /  \       |
--  v    v      v
-- CLIENT CHASSEUR SECTEUR
--
-- La partie financière suit :
--
-- ACTE_AUTHENTIQUE
--        |
--        v
--    HONORAIRES
--        |
--        v
--    COMMISSION
--
-- Les dimensions ont déjà été alimentées.
--
-- Nous retrouvons donc leurs clés OLAP grâce aux identifiants
-- provenant de l'OLTP.


INSERT INTO match_immo_olap.fact_vente (
    acte_id_source,
    temps_key,
    chasseur_key,
    client_key,
    secteur_key,
    type_bien_key,
    prix_vente,
    montant_honoraires,
    montant_commission
)
SELECT
    -- Traçabilité vers l'acte métier d'origine.
    aa.id_acte,

    -- Date de la vente.
    dt.temps_key,

    -- Chasseur responsable du mandat.
    dc.chasseur_key,

    -- Client associé au mandat.
    dcl.client_key,

    -- Secteur du bien vendu.
    ds.secteur_key,

    -- Type du bien vendu.
    dtb.type_bien_key,

    -- Prix réellement enregistré dans l'acte authentique.
    aa.prix_vente,

    -- Honoraires liés à l'acte.
    h.montant_total,

    -- Commission du chasseur.
    co.montant_commission

FROM fil_rouge_cible.acte_authentique AS aa

-- ACTE_AUTHENTIQUE → OFFRE
JOIN fil_rouge_cible.offre AS o
    ON o.id_offre = aa.offre_id

-- OFFRE → PRESENTATION
JOIN fil_rouge_cible.presentation AS p
    ON p.id_presentation = o.presentation_id

-- PRESENTATION → MANDAT
JOIN fil_rouge_cible.mandat AS m
    ON m.id_mandat = p.mandat_id

-- PRESENTATION → BIEN
JOIN fil_rouge_cible.bien AS b
    ON b.id_bien = p.bien_id

-- BIEN → SECTEUR
JOIN fil_rouge_cible.secteur AS s
    ON s.id_secteur = b.secteur_id

-- Recherche de la date correspondante dans DIM_TEMPS.
JOIN match_immo_olap.dim_temps AS dt
    ON dt.date_complete = aa.date_acte

-- Recherche du chasseur dans DIM_CHASSEUR.
JOIN match_immo_olap.dim_chasseur AS dc
    ON dc.chasseur_id_source = m.chasseur_id

-- Recherche du client dans DIM_CLIENT.
JOIN match_immo_olap.dim_client AS dcl
    ON dcl.client_id_source = m.client_id

-- Recherche du secteur dans DIM_SECTEUR.
JOIN match_immo_olap.dim_secteur AS ds
    ON ds.secteur_id_source = s.id_secteur

-- Recherche du type de bien dans DIM_TYPE_BIEN.
JOIN match_immo_olap.dim_type_bien AS dtb
    ON dtb.type_bien_source = b.type_bien

-- Une vente peut théoriquement être présente avant
-- l'enregistrement de ses honoraires.
--
-- LEFT JOIN permet donc de conserver la vente même
-- si la partie financière n'est pas encore disponible.
LEFT JOIN fil_rouge_cible.honoraires AS h
    ON h.acte_id = aa.id_acte

LEFT JOIN fil_rouge_cible.commission AS co
    ON co.honoraires_id = h.id_honoraires


-- acte_id_source possède une contrainte UNIQUE.
--
-- Si l'acte existe déjà dans FACT_VENTE, on met à jour
-- ses valeurs au lieu de créer un doublon.

ON CONFLICT (acte_id_source)
DO UPDATE SET
    temps_key = EXCLUDED.temps_key,
    chasseur_key = EXCLUDED.chasseur_key,
    client_key = EXCLUDED.client_key,
    secteur_key = EXCLUDED.secteur_key,
    type_bien_key = EXCLUDED.type_bien_key,
    prix_vente = EXCLUDED.prix_vente,
    montant_honoraires = EXCLUDED.montant_honoraires,
    montant_commission = EXCLUDED.montant_commission;


-- ============================================================
-- 8. ALIMENTATION DE FACT_ACTIVITE_MANDAT
-- ============================================================

-- GRAIN :
--
--     1 ligne FACT_ACTIVITE_MANDAT
--     =
--     1 MANDAT
--
-- Cette table permet de mesurer le parcours commercial :
--
-- MANDAT
--    |
--    v
-- PRESENTATION
--    |
--    +----> VISITE
--    |
--    +----> OFFRE
--             |
--             v
--      ACTE_AUTHENTIQUE
--
-- Pour chaque mandat, nous voulons calculer :
--
--     nombre_presentations
--     nombre_visites
--     nombre_offres
--     vente_realisee
--
--
-- ATTENTION AU COMPTAGE
-- ---------------------
--
-- Un simple JOIN de toutes les tables pourrait multiplier
-- artificiellement les lignes.
--
-- Exemple :
--
-- 1 présentation
-- 2 visites
-- 3 offres
--
-- un mauvais JOIN pourrait produire 6 lignes.
--
-- Nous utilisons donc COUNT(DISTINCT identifiant).
--
-- DISTINCT signifie ici :
-- "ne compter chaque événement réel qu'une seule fois".


INSERT INTO match_immo_olap.fact_activite_mandat (
    mandat_id_source,
    temps_key,
    chasseur_key,
    client_key,
    nombre_presentations,
    nombre_visites,
    nombre_offres,
    vente_realisee
)
SELECT
    -- Mandat OLTP d'origine.
    m.id_mandat,

    -- Date de signature du mandat.
    dt.temps_key,

    -- Chasseur responsable.
    dc.chasseur_key,

    -- Client concerné.
    dcl.client_key,

    -- Nombre de biens présentés.
    COUNT(DISTINCT p.id_presentation)::INTEGER,

    -- Nombre de visites.
    COUNT(DISTINCT v.id_visite)::INTEGER,

    -- Nombre d'offres.
    COUNT(DISTINCT o.id_offre)::INTEGER,

    -- BOOL_OR retourne TRUE si au moins une ligne
    -- satisfait la condition.
    --
    -- Ici :
    -- TRUE si au moins une offre issue du mandat
    -- possède un acte authentique.
    COALESCE(
        BOOL_OR(aa.id_acte IS NOT NULL),
        FALSE
    ) AS vente_realisee

FROM fil_rouge_cible.mandat AS m

-- Dimension temps correspondant à la signature du mandat.
JOIN match_immo_olap.dim_temps AS dt
    ON dt.date_complete = m.date_signature

-- Dimension chasseur.
JOIN match_immo_olap.dim_chasseur AS dc
    ON dc.chasseur_id_source = m.chasseur_id

-- Dimension client.
JOIN match_immo_olap.dim_client AS dcl
    ON dcl.client_id_source = m.client_id


-- LEFT JOIN est utilisé pour les événements suivants.
--
-- Pourquoi ?
--
-- Un mandat peut exister sans présentation.
-- Une présentation peut exister sans visite.
-- Une présentation peut exister sans offre.
-- Une offre peut exister sans acte authentique.
--
-- On doit malgré tout conserver le mandat dans l'OLAP.

LEFT JOIN fil_rouge_cible.presentation AS p
    ON p.mandat_id = m.id_mandat

LEFT JOIN fil_rouge_cible.visite AS v
    ON v.presentation_id = p.id_presentation

LEFT JOIN fil_rouge_cible.offre AS o
    ON o.presentation_id = p.id_presentation

LEFT JOIN fil_rouge_cible.acte_authentique AS aa
    ON aa.offre_id = o.id_offre


-- Toutes les colonnes qui ne sont pas agrégées
-- doivent apparaître dans GROUP BY.
--
-- COUNT et BOOL_OR sont des fonctions d'agrégation.

GROUP BY
    m.id_mandat,
    dt.temps_key,
    dc.chasseur_key,
    dcl.client_key


-- Un mandat ne doit apparaître qu'une seule fois
-- dans FACT_ACTIVITE_MANDAT.
--
-- Lors d'une nouvelle exécution, les compteurs sont
-- recalculés et mis à jour.

ON CONFLICT (mandat_id_source)
DO UPDATE SET
    temps_key = EXCLUDED.temps_key,
    chasseur_key = EXCLUDED.chasseur_key,
    client_key = EXCLUDED.client_key,
    nombre_presentations = EXCLUDED.nombre_presentations,
    nombre_visites = EXCLUDED.nombre_visites,
    nombre_offres = EXCLUDED.nombre_offres,
    vente_realisee = EXCLUDED.vente_realisee;


-- ============================================================
-- 9. VALIDATION DE LA TRANSACTION
-- ============================================================

-- COMMIT valide définitivement les opérations réalisées
-- depuis BEGIN.
--
-- Si le script est exécuté avec :
--
--     psql -v ON_ERROR_STOP=1
--
-- une erreur SQL interrompt le traitement avant cette étape.

COMMIT;


-- ============================================================
-- 10. CONTRÔLES DE FIN D'ETL
-- ============================================================

-- Ces requêtes ne modifient aucune donnée.
--
-- Elles affichent simplement le nombre de lignes chargées
-- dans chaque table analytique.


SELECT
    'dim_temps' AS table_olap,
    COUNT(*) AS nombre_lignes
FROM match_immo_olap.dim_temps

UNION ALL

SELECT
    'dim_chasseur',
    COUNT(*)
FROM match_immo_olap.dim_chasseur

UNION ALL

SELECT
    'dim_client',
    COUNT(*)
FROM match_immo_olap.dim_client

UNION ALL

SELECT
    'dim_secteur',
    COUNT(*)
FROM match_immo_olap.dim_secteur

UNION ALL

SELECT
    'dim_type_bien',
    COUNT(*)
FROM match_immo_olap.dim_type_bien

UNION ALL

SELECT
    'fact_vente',
    COUNT(*)
FROM match_immo_olap.fact_vente

UNION ALL

SELECT
    'fact_activite_mandat',
    COUNT(*)
FROM match_immo_olap.fact_activite_mandat

ORDER BY table_olap;


-- ============================================================
-- 11. CONTRÔLE MÉTIER DES VENTES
-- ============================================================

-- Cette requête permet de visualiser les ventes chargées
-- avec leurs principales dimensions.
--
-- Elle sert de contrôle humain du résultat ETL.

SELECT
    fv.acte_id_source,
    dt.date_complete AS date_vente,
    dc.nom AS nom_chasseur,
    dc.prenom AS prenom_chasseur,
    ds.ville,
    ds.quartier,
    dtb.type_bien_source AS type_bien,
    fv.prix_vente,
    fv.montant_honoraires,
    fv.montant_commission

FROM match_immo_olap.fact_vente AS fv

JOIN match_immo_olap.dim_temps AS dt
    ON dt.temps_key = fv.temps_key

JOIN match_immo_olap.dim_chasseur AS dc
    ON dc.chasseur_key = fv.chasseur_key

JOIN match_immo_olap.dim_secteur AS ds
    ON ds.secteur_key = fv.secteur_key

JOIN match_immo_olap.dim_type_bien AS dtb
    ON dtb.type_bien_key = fv.type_bien_key

ORDER BY dt.date_complete, fv.acte_id_source;


-- ============================================================
-- 12. CONTRÔLE MÉTIER DE L'ACTIVITÉ DES MANDATS
-- ============================================================

SELECT
    fam.mandat_id_source,
    dt.date_complete AS date_signature,
    dc.nom AS nom_chasseur,
    dc.prenom AS prenom_chasseur,
    fam.nombre_presentations,
    fam.nombre_visites,
    fam.nombre_offres,
    fam.vente_realisee

FROM match_immo_olap.fact_activite_mandat AS fam

JOIN match_immo_olap.dim_temps AS dt
    ON dt.temps_key = fam.temps_key

JOIN match_immo_olap.dim_chasseur AS dc
    ON dc.chasseur_key = fam.chasseur_key

ORDER BY dt.date_complete, fam.mandat_id_source;


-- ============================================================
-- FIN DE L'ETL
-- ============================================================