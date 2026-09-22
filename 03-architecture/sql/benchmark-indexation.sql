-- ============================================================================
-- Match-Immo — Benchmark d'indexation PostgreSQL
-- Phase 3 : Absorber la croissance
--
-- Objectif :
-- Mesurer l'intérêt d'un index composite pour une recherche immobilière
-- combinant secteur, prix et surface.
--
-- Le schéma benchmark est isolé des données métier simulées du projet.
-- Le jeu de charge est synthétique, déterministe et reproductible.
-- ============================================================================

DROP SCHEMA IF EXISTS benchmark CASCADE;
CREATE SCHEMA benchmark;

-- ---------------------------------------------------------------------------
-- 1. Reproduction de la structure de la table métier fil_rouge_cible.bien
-- ---------------------------------------------------------------------------

CREATE TABLE benchmark.bien
(
    LIKE fil_rouge_cible.bien
    INCLUDING DEFAULTS
    INCLUDING IDENTITY
    INCLUDING CONSTRAINTS
);

-- Reproduction de la clé primaire de la table métier.
ALTER TABLE benchmark.bien
    ADD CONSTRAINT bien_benchmark_pkey PRIMARY KEY (id_bien);

-- Reproduction de l'index simple présent dans l'état actuel du modèle cible.
CREATE INDEX idx_benchmark_bien_secteur
    ON benchmark.bien (secteur_id);

-- ---------------------------------------------------------------------------
-- 2. Génération déterministe de 1 000 000 de biens synthétiques
-- ---------------------------------------------------------------------------

INSERT INTO benchmark.bien
    (secteur_id, adresse, type_bien, prix, surface,
     nombre_pieces, dpe, description)
SELECT
    ((g::bigint % 100) + 1)::integer,
    'Adresse benchmark ' || g,
    CASE (g % 4)
        WHEN 0 THEN 'Appartement'
        WHEN 1 THEN 'Maison'
        WHEN 2 THEN 'Studio'
        ELSE 'Villa'
    END,
    100000 + ((g::bigint * 7919) % 900001),
    20 + ((g::bigint * 104729) % 181),
    1 + (g % 8),
    chr(65 + (g % 7)),
    'Bien synthétique de benchmark n°' || g
FROM generate_series(1, 1000000) AS g;

-- Mise à jour des statistiques utilisées par le planificateur PostgreSQL.
ANALYZE benchmark.bien;

-- ---------------------------------------------------------------------------
-- 3. Contrôle du volume et de la sélectivité de la requête
-- ---------------------------------------------------------------------------

SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE secteur_id = 42) AS secteur_42,
    COUNT(*) FILTER (
        WHERE secteur_id = 42
          AND prix BETWEEN 250000 AND 350000
    ) AS secteur_prix,
    COUNT(*) FILTER (
        WHERE secteur_id = 42
          AND prix BETWEEN 250000 AND 350000
          AND surface >= 60
    ) AS secteur_prix_surface
FROM benchmark.bien;

-- ---------------------------------------------------------------------------
-- 4. AVANT optimisation
-- État de référence : index simple sur secteur_id
-- ---------------------------------------------------------------------------

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    id_bien,
    secteur_id,
    prix,
    surface
FROM benchmark.bien
WHERE secteur_id = 42
  AND prix BETWEEN 250000 AND 350000
  AND surface >= 60;

-- Seconde exécution : mesure de référence en cache chaud.
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    id_bien,
    secteur_id,
    prix,
    surface
FROM benchmark.bien
WHERE secteur_id = 42
  AND prix BETWEEN 250000 AND 350000
  AND surface >= 60;

-- ---------------------------------------------------------------------------
-- 5. Optimisation candidate
-- ---------------------------------------------------------------------------

CREATE INDEX idx_benchmark_bien_secteur_prix_surface
    ON benchmark.bien (secteur_id, prix, surface);

ANALYZE benchmark.bien;

-- ---------------------------------------------------------------------------
-- 6. APRES optimisation
-- Même requête, mêmes données et mêmes conditions fonctionnelles.
-- ---------------------------------------------------------------------------

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    id_bien,
    secteur_id,
    prix,
    surface
FROM benchmark.bien
WHERE secteur_id = 42
  AND prix BETWEEN 250000 AND 350000
  AND surface >= 60;

-- Seconde exécution : mesure finale en cache chaud.
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    id_bien,
    secteur_id,
    prix,
    surface
FROM benchmark.bien
WHERE secteur_id = 42
  AND prix BETWEEN 250000 AND 350000
  AND surface >= 60;
