-- ============================================================================
-- Benchmark de partitionnement PostgreSQL
-- Phase 3 - Absorber la croissance
-- ============================================================================
--
-- Objectif :
-- comparer une table non partitionnée et une table partitionnée mensuellement
-- contenant exactement les mêmes 10 000 000 de présentations simulées.
--
-- Cas métier testé :
-- recherche des présentations réalisées pendant le mois d'août 2026.
--
-- Principe :
-- - même structure ;
-- - mêmes données ;
-- - aucun index secondaire ;
-- - seule l'organisation physique change ;
-- - 24 partitions mensuelles de janvier 2025 à décembre 2026.
--
-- ATTENTION :
-- le schéma benchmark est partagé avec les autres tests de performance.
-- Ce script ne doit donc jamais exécuter :
--
--     DROP SCHEMA benchmark CASCADE;
--
-- ============================================================================


-- ============================================================================
-- 1. Nettoyage limité au benchmark de partitionnement
-- ============================================================================

DROP TABLE IF EXISTS benchmark.presentation_partitionnee CASCADE;
DROP TABLE IF EXISTS benchmark.presentation_non_partitionnee CASCADE;


-- ============================================================================
-- 2. Table de référence non partitionnée
-- ============================================================================

CREATE TABLE benchmark.presentation_non_partitionnee (
    id_presentation   integer NOT NULL,
    mandat_id         integer NOT NULL,
    bien_id           integer NOT NULL,
    date_presentation timestamp without time zone NOT NULL,
    statut            varchar NOT NULL,
    priorite_client   integer,
    decision_client   varchar,
    observations      text,
    CHECK (priorite_client IS NULL OR priorite_client >= 0)
);


-- ============================================================================
-- 3. Table partitionnée
-- ============================================================================

CREATE TABLE benchmark.presentation_partitionnee (
    id_presentation   integer NOT NULL,
    mandat_id         integer NOT NULL,
    bien_id           integer NOT NULL,
    date_presentation timestamp without time zone NOT NULL,
    statut            varchar NOT NULL,
    priorite_client   integer,
    decision_client   varchar,
    observations      text,
    CHECK (priorite_client IS NULL OR priorite_client >= 0)
)
PARTITION BY RANGE (date_presentation);


-- ============================================================================
-- 4. Création de 24 partitions mensuelles
--    Janvier 2025 -> décembre 2026
-- ============================================================================

DO $$
DECLARE
    d date := DATE '2025-01-01';
BEGIN
    WHILE d < DATE '2027-01-01' LOOP

        EXECUTE format(
            'CREATE TABLE benchmark.%I
             PARTITION OF benchmark.presentation_partitionnee
             FOR VALUES FROM (%L) TO (%L)',
            'presentation_p_' || to_char(d, 'YYYY_MM'),
            d::timestamp,
            (d + INTERVAL '1 month')::timestamp
        );

        d := (d + INTERVAL '1 month')::date;

    END LOOP;
END
$$;


-- ============================================================================
-- 5. Génération de 10 000 000 de présentations synthétiques déterministes
-- ============================================================================

INSERT INTO benchmark.presentation_non_partitionnee (
    id_presentation,
    mandat_id,
    bien_id,
    date_presentation,
    statut,
    priorite_client,
    decision_client,
    observations
)
SELECT
    g,
    1 + (g % 100000),
    1 + (g % 1000000),

    TIMESTAMP '2025-01-01 00:00:00'
        + ((g::bigint * 37) % 63072000) * INTERVAL '1 second',

    CASE (g % 4)
        WHEN 0 THEN 'proposee'
        WHEN 1 THEN 'acceptee'
        WHEN 2 THEN 'refusee'
        ELSE 'en_attente'
    END,

    1 + (g % 5),

    CASE (g % 3)
        WHEN 0 THEN 'interesse'
        WHEN 1 THEN 'a_revoir'
        ELSE 'non_interesse'
    END,

    'Présentation synthétique benchmark n°' || g

FROM generate_series(1, 10000000) AS g;


ANALYZE benchmark.presentation_non_partitionnee;


-- ============================================================================
-- 6. Copie exacte vers la table partitionnée
-- ============================================================================

INSERT INTO benchmark.presentation_partitionnee (
    id_presentation,
    mandat_id,
    bien_id,
    date_presentation,
    statut,
    priorite_client,
    decision_client,
    observations
)
SELECT
    id_presentation,
    mandat_id,
    bien_id,
    date_presentation,
    statut,
    priorite_client,
    decision_client,
    observations
FROM benchmark.presentation_non_partitionnee;


ANALYZE benchmark.presentation_partitionnee;


-- ============================================================================
-- 7. Contrôle des volumes et de la période
-- ============================================================================

SELECT
    'non_partitionnee' AS table_test,
    COUNT(*) AS nb_lignes,
    MIN(date_presentation) AS date_min,
    MAX(date_presentation) AS date_max
FROM benchmark.presentation_non_partitionnee

UNION ALL

SELECT
    'partitionnee' AS table_test,
    COUNT(*) AS nb_lignes,
    MIN(date_presentation) AS date_min,
    MAX(date_presentation) AS date_max
FROM benchmark.presentation_partitionnee;


-- ============================================================================
-- 8. Contrôle des 24 partitions
-- ============================================================================

SELECT
    tableoid::regclass AS partition,
    COUNT(*) AS nb_lignes
FROM benchmark.presentation_partitionnee
GROUP BY tableoid
ORDER BY tableoid::regclass::text;


-- ============================================================================
-- 9. AVANT - table non partitionnée
-- ============================================================================

-- Première exécution.
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*)
FROM benchmark.presentation_non_partitionnee
WHERE date_presentation >= TIMESTAMP '2026-08-01 00:00:00'
  AND date_presentation <  TIMESTAMP '2026-09-01 00:00:00';


-- Seconde exécution retenue comme mesure comparative de référence.
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*)
FROM benchmark.presentation_non_partitionnee
WHERE date_presentation >= TIMESTAMP '2026-08-01 00:00:00'
  AND date_presentation <  TIMESTAMP '2026-09-01 00:00:00';


-- ============================================================================
-- 10. APRES - table partitionnée
-- ============================================================================

-- PostgreSQL doit éliminer les partitions inutiles et ne parcourir
-- que benchmark.presentation_p_2026_08.

-- Première exécution.
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*)
FROM benchmark.presentation_partitionnee
WHERE date_presentation >= TIMESTAMP '2026-08-01 00:00:00'
  AND date_presentation <  TIMESTAMP '2026-09-01 00:00:00';


-- Seconde exécution retenue comme mesure comparative de référence.
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*)
FROM benchmark.presentation_partitionnee
WHERE date_presentation >= TIMESTAMP '2026-08-01 00:00:00'
  AND date_presentation <  TIMESTAMP '2026-09-01 00:00:00';


-- ============================================================================
-- Résultat attendu conceptuellement
-- ============================================================================
--
-- Non partitionnée :
--   Parallel Seq Scan sur les 10 000 000 de lignes.
--
-- Partitionnée :
--   Parallel Seq Scan uniquement sur presentation_p_2026_08.
--
-- Le mécanisme recherché est le partition pruning :
-- PostgreSQL élimine les 23 partitions qui ne peuvent pas contenir
-- les données d'août 2026.
--
-- Les temps exacts dépendent de l'environnement d'exécution.
-- La preuve principale repose sur :
-- - le plan d'exécution ;
-- - les partitions parcourues ;
-- - les buffers ;
-- - le temps mesuré.
-- ============================================================================
