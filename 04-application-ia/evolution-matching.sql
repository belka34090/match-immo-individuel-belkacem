-- ============================================================
-- Projet RNCP40573 - Chasse immobiliere
-- Phase 4 - Application et IA
-- Fichier : evolution-matching.sql
--
-- Objectif :
-- Faire evoluer le schema transactionnel valide en Phase 2
-- avec les criteres supplementaires necessaires au matching.
--
-- Cette migration ne recree pas le schema.
-- Elle applique uniquement une evolution additive et rejouable.
-- ============================================================

BEGIN;

ALTER TABLE fil_rouge_cible.version_demande
    ADD COLUMN IF NOT EXISTS type_bien_souhaite VARCHAR(50);

ALTER TABLE fil_rouge_cible.version_demande
    ADD COLUMN IF NOT EXISTS dpe_min VARCHAR(10);

-- Le DPE attendu, lorsqu'il est renseigne, doit correspondre
-- a une classe energetique connue de A a G.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_version_dpe_min'
          AND conrelid =
              'fil_rouge_cible.version_demande'::regclass
    ) THEN
        ALTER TABLE fil_rouge_cible.version_demande
            ADD CONSTRAINT chk_version_dpe_min
            CHECK (
                dpe_min IS NULL
                OR UPPER(dpe_min) IN ('A', 'B', 'C', 'D', 'E', 'F', 'G')
            );
    END IF;
END
$$;

COMMIT;
