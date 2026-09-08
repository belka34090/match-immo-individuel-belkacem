-- Benchmark réplication / haute disponibilité PostgreSQL
-- Phase 3 — Match-Immo
--
-- Prérequis :
-- - base matchimmo_ha_test déjà créée ;
-- - exécution sur le PRIMARY ;
-- - réplication physique CloudNativePG opérationnelle.

DROP TABLE IF EXISTS public.test_replication_10m;

CREATE TABLE public.test_replication_10m (
    id bigint PRIMARY KEY,
    mandat_id integer NOT NULL,
    bien_id integer NOT NULL,
    statut varchar(20) NOT NULL,
    montant numeric(12,2) NOT NULL,
    date_evenement timestamp NOT NULL,
    commentaire text
);

-- Charge synthétique déterministe.
-- Table journalisée : ne pas utiliser UNLOGGED,
-- afin que les écritures soient bien répliquées via WAL.

INSERT INTO public.test_replication_10m (
    id,
    mandat_id,
    bien_id,
    statut,
    montant,
    date_evenement,
    commentaire
)
SELECT
    g,
    1 + (g % 100000),
    1 + (g % 1000000),
    CASE g % 4
        WHEN 0 THEN 'propose'
        WHEN 1 THEN 'visite'
        WHEN 2 THEN 'offre'
        ELSE 'termine'
    END,
    (100000 + (g % 900000))::numeric(12,2),
    TIMESTAMP '2025-01-01 00:00:00'
      + ((g * 37) % 63072000) * INTERVAL '1 second',
    'preuve replication HA Match-Immo ligne ' || g
FROM generate_series(1, 10000000) AS g;

ANALYZE public.test_replication_10m;

-- Volume, bornes et taille.

SELECT
    COUNT(*) AS lignes,
    MIN(id) AS id_min,
    MAX(id) AS id_max,
    pg_size_pretty(
        pg_total_relation_size('public.test_replication_10m')
    ) AS taille_totale
FROM public.test_replication_10m;

-- Contrôle d'intégrité.
-- À exécuter sur PRIMARY puis REPLICA.

SELECT
    COUNT(*) AS lignes,
    SUM(id) AS somme_id,
    SUM(mandat_id::bigint) AS somme_mandat,
    SUM(bien_id::bigint) AS somme_bien,
    MD5(
        STRING_AGG(
            MD5(
                id::text || '|' ||
                mandat_id::text || '|' ||
                bien_id::text || '|' ||
                statut || '|' ||
                montant::text || '|' ||
                date_evenement::text || '|' ||
                COALESCE(commentaire, '')
            ),
            ''
            ORDER BY id
        )
    ) AS empreinte
FROM public.test_replication_10m;

-- Rôle de l'instance :
-- false = PRIMARY
-- true  = REPLICA

SELECT pg_is_in_recovery();

-- Contrôle côté PRIMARY.

SELECT
    application_name,
    state,
    sync_state,
    sent_lsn,
    write_lsn,
    flush_lsn,
    replay_lsn,
    pg_size_pretty(
        pg_wal_lsn_diff(sent_lsn, replay_lsn)
    ) AS retard_replay
FROM pg_stat_replication;

-- Contrôle côté REPLICA.

SELECT
    pg_last_wal_receive_lsn() AS receive_lsn,
    pg_last_wal_replay_lsn() AS replay_lsn,
    pg_size_pretty(
        pg_wal_lsn_diff(
            pg_last_wal_receive_lsn(),
            pg_last_wal_replay_lsn()
        )
    ) AS retard_local;

-- Contrôle après redémarrage ou failover.

SELECT
    pg_is_in_recovery(),
    COUNT(*) AS lignes,
    MIN(id) AS id_min,
    MAX(id) AS id_max
FROM public.test_replication_10m;

-- Écriture à réaliser sur le nouveau PRIMARY après failover.

INSERT INTO public.test_replication_10m (
    id,
    mandat_id,
    bien_id,
    statut,
    montant,
    date_evenement,
    commentaire
)
VALUES (
    10000001,
    1,
    1,
    'apres_failover',
    350000.00,
    now(),
    'écriture réalisée après bascule automatique'
)
ON CONFLICT (id) DO NOTHING;

-- Contrôle final après reconstruction de la réplication.

SELECT
    pg_is_in_recovery(),
    COUNT(*) AS lignes,
    MIN(id) AS id_min,
    MAX(id) AS id_max
FROM public.test_replication_10m;
