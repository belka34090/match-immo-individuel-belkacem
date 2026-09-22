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


-- ------------------------------------------------------------
-- Controle humain des recommandations produites en Phase 4
-- ------------------------------------------------------------
--
-- Une validation est rattachee a une version precise de la
-- demande afin de conserver la trace du contexte qui a ete
-- effectivement examine par le chasseur.
--
-- Plusieurs decisions peuvent etre conservees pour une meme
-- version : par exemple MODIFIER puis VALIDER.
CREATE TABLE IF NOT EXISTS fil_rouge_cible.validation_humaine (
    id_validation INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    version_demande_id INTEGER NOT NULL,
    validateur_id INTEGER NOT NULL,

    decision VARCHAR(20) NOT NULL,
    commentaire TEXT,

    date_validation TIMESTAMP WITHOUT TIME ZONE
        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_validation_version_demande
        FOREIGN KEY (version_demande_id)
        REFERENCES fil_rouge_cible.version_demande(id_version),

    CONSTRAINT fk_validation_validateur
        FOREIGN KEY (validateur_id)
        REFERENCES fil_rouge_cible.utilisateur(id_utilisateur),

    CONSTRAINT chk_validation_decision
        CHECK (decision IN ('VALIDER', 'REFUSER', 'MODIFIER'))
);

COMMIT;
