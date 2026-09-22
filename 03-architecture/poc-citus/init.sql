CREATE EXTENSION IF NOT EXISTS citus;

-- ============================================================
-- 1. Enregistrement des workers
-- ============================================================

SELECT citus_add_node('worker1', 5432)
WHERE NOT EXISTS (
    SELECT 1
    FROM pg_dist_node
    WHERE nodename = 'worker1'
      AND nodeport = 5432
);

SELECT citus_add_node('worker2', 5432)
WHERE NOT EXISTS (
    SELECT 1
    FROM pg_dist_node
    WHERE nodename = 'worker2'
      AND nodeport = 5432
);

-- ============================================================
-- 2. Nombre de shards
-- ============================================================

SET citus.shard_count = 32;

-- ============================================================
-- 3. Table POC proche du modèle solo PRESENTATION
-- ============================================================

DROP TABLE IF EXISTS public.presentation_poc CASCADE;

CREATE TABLE public.presentation_poc (
    mandat_id bigint NOT NULL,
    id_presentation bigint NOT NULL,
    bien_id bigint NOT NULL,
    date_presentation timestamp NOT NULL,
    statut varchar(30) NOT NULL,
    priorite_client integer,
    decision_client varchar(50),
    observations text,

    PRIMARY KEY (mandat_id, id_presentation),

    CHECK (
        priorite_client IS NULL
        OR priorite_client >= 0
    )
);

-- ============================================================
-- 4. Distribution Citus
-- ============================================================

SELECT create_distributed_table(
    'public.presentation_poc',
    'mandat_id'
);

-- ============================================================
-- 5. Génération de 10 000 000 lignes
-- ============================================================

INSERT INTO public.presentation_poc (
    mandat_id,
    id_presentation,
    bien_id,
    date_presentation,
    statut,
    priorite_client,
    decision_client,
    observations
)
SELECT
    1 + ((g - 1) % 100000),
    g,
    1 + ((g - 1) % 1000000),

    TIMESTAMP '2025-01-01 00:00:00'
      + ((g::bigint * 37) % 63072000) * INTERVAL '1 second',

    CASE g % 4
        WHEN 0 THEN 'propose'
        WHEN 1 THEN 'visite'
        WHEN 2 THEN 'offre'
        ELSE 'termine'
    END,

    1 + (g % 5),

    CASE g % 3
        WHEN 0 THEN 'interesse'
        WHEN 1 THEN 'refuse'
        ELSE 'a_recontacter'
    END,

    'Présentation synthétique Match-Immo n° ' || g

FROM generate_series(1, 10000000) AS g;

ANALYZE public.presentation_poc;

-- ============================================================
-- 6. Contrôle du volume
-- ============================================================

SELECT
    COUNT(*) AS nb_lignes,
    MIN(id_presentation) AS id_min,
    MAX(id_presentation) AS id_max
FROM public.presentation_poc;

-- ============================================================
-- 7. Contrôle des workers
-- ============================================================

SELECT
    nodename,
    nodeport,
    noderole,
    isactive
FROM pg_dist_node
ORDER BY nodeid;

-- ============================================================
-- 8. Contrôle de la distribution des shards
-- ============================================================

SELECT
    nodename,
    COUNT(*) AS nb_shards
FROM citus_shards
WHERE table_name = 'public.presentation_poc'::regclass
GROUP BY nodename
ORDER BY nodename;

-- ============================================================
-- 9. Test sur la clé de distribution
-- ============================================================

EXPLAIN ANALYZE
SELECT *
FROM public.presentation_poc
WHERE mandat_id = 42000;

-- Attendu :
-- Task Count: 1
--
-- Citus connaît directement le shard qui contient mandat_id.

-- ============================================================
-- 10. Test hors clé AVANT index
-- ============================================================

EXPLAIN ANALYZE
SELECT *
FROM public.presentation_poc
WHERE bien_id = 500000;

-- Attendu :
-- plusieurs tâches / scatter-gather.
--
-- La requête ne contient pas mandat_id.
-- Citus doit donc interroger plusieurs shards.

-- ============================================================
-- 11. Index complémentaire
-- ============================================================

CREATE INDEX idx_presentation_poc_bien_id
ON public.presentation_poc (bien_id);

ANALYZE public.presentation_poc;

-- ============================================================
-- 12. Test hors clé APRÈS index
-- ============================================================

EXPLAIN ANALYZE
SELECT *
FROM public.presentation_poc
WHERE bien_id = 500000;

-- L'index doit accélérer le travail dans chaque shard,
-- mais la requête reste scatter-gather car bien_id
-- n'est pas la clé de distribution.

-- ============================================================
-- 13. Résumé Citus
-- ============================================================

SELECT
    logicalrelid,
    partmethod,
    colocationid,
    repmodel
FROM pg_dist_partition
WHERE logicalrelid = 'public.presentation_poc'::regclass;
