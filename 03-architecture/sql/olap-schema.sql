-- ============================================================
-- MATCH-IMMO
-- Phase 3 - Absorber la croissance
-- Fichier : olap-schema.sql
--
-- OBJECTIF
-- --------
-- Ce script crée le modèle décisionnel OLAP de Match-Immo.
--
-- OLTP :
-- base métier utilisée pour les opérations quotidiennes.
--
-- OLAP :
-- base analytique utilisée pour les statistiques,
-- les indicateurs et les tableaux de bord.
--
-- IMPORTANT :
-- Ce fichier crée uniquement la STRUCTURE OLAP.
--
-- Il ne copie aucune donnée depuis l'OLTP.
-- Le chargement sera réalisé ensuite dans :
--
--     olap-etl.sql
--
-- Le modèle retenu est un schéma en étoile composé de :
--
-- DIMENSIONS
--   - dim_temps
--   - dim_chasseur
--   - dim_client
--   - dim_secteur
--   - dim_type_bien
--
-- TABLES DE FAITS
--   - fact_vente
--   - fact_activite_mandat
--
-- ============================================================


-- ============================================================
-- 1. CRÉATION DU SCHÉMA OLAP
-- ============================================================

-- Un schéma PostgreSQL est un espace logique permettant
-- de regrouper des tables.
--
-- Ici, le schéma "match_immo_olap" permet de séparer
-- clairement les données analytiques des données métier OLTP.

CREATE SCHEMA IF NOT EXISTS match_immo_olap;


-- ============================================================
-- 2. DIMENSION TEMPS
-- ============================================================

-- La dimension temps sert à analyser les faits selon :
--
--   - le jour ;
--   - le mois ;
--   - le trimestre ;
--   - l'année.
--
-- Exemple :
--
-- "Combien de ventes ont été réalisées au troisième
-- trimestre 2026 ?"
--
-- Une seule ligne est créée pour chaque date.

CREATE TABLE IF NOT EXISTS match_immo_olap.dim_temps (

    -- Clé technique propre à l'OLAP.
    --
    -- BIGINT permet de disposer d'une grande capacité
    -- d'identifiants.
    --
    -- GENERATED ... AS IDENTITY demande à PostgreSQL
    -- de générer automatiquement les valeurs.
    temps_key BIGINT GENERATED ALWAYS AS IDENTITY,

    -- Date civile complète.
    date_complete DATE NOT NULL,

    -- Jour du mois : 1 à 31.
    jour SMALLINT NOT NULL,

    -- Mois : 1 à 12.
    mois SMALLINT NOT NULL,

    -- Trimestre : 1 à 4.
    trimestre SMALLINT NOT NULL,

    -- Année, par exemple 2026.
    annee INTEGER NOT NULL,

    -- La clé primaire identifie de manière unique
    -- chaque ligne de la dimension.
    CONSTRAINT pk_dim_temps
        PRIMARY KEY (temps_key),

    -- Une même date ne doit exister qu'une seule fois.
    CONSTRAINT uq_dim_temps_date
        UNIQUE (date_complete),

    -- Contrôles simples de cohérence.
    CONSTRAINT chk_dim_temps_jour
        CHECK (jour BETWEEN 1 AND 31),

    CONSTRAINT chk_dim_temps_mois
        CHECK (mois BETWEEN 1 AND 12),

    CONSTRAINT chk_dim_temps_trimestre
        CHECK (trimestre BETWEEN 1 AND 4)
);


-- ============================================================
-- 3. DIMENSION CHASSEUR
-- ============================================================

-- Cette dimension permet d'analyser l'activité
-- selon le chasseur immobilier.
--
-- Exemples :
--
--   - nombre de mandats par chasseur ;
--   - nombre de ventes ;
--   - montant des commissions ;
--   - nombre de visites ;
--   - taux de transformation.
--
-- Dans l'OLTP :
--
-- CHASSEUR.id_chasseur
--        |
--        v
-- UTILISATEUR
--
-- Le nom et le prénom proviennent donc de UTILISATEUR,
-- tandis que l'identifiant métier provient de CHASSEUR.

CREATE TABLE IF NOT EXISTS match_immo_olap.dim_chasseur (

    -- Identifiant technique OLAP.
    chasseur_key BIGINT GENERATED ALWAYS AS IDENTITY,

    -- Identifiant original provenant de :
    --
    -- CHASSEUR.id_chasseur
    --
    -- Ce champ garantit la traçabilité avec l'OLTP.
    chasseur_id_source INTEGER NOT NULL,

    -- Informations lisibles utilisées dans les analyses.
    nom VARCHAR(80) NOT NULL,
    prenom VARCHAR(80) NOT NULL,

    -- Le matricule permet également d'identifier
    -- le professionnel dans les restitutions métier.
    matricule VARCHAR(50),

    CONSTRAINT pk_dim_chasseur
        PRIMARY KEY (chasseur_key),

    -- Dans cette première version simple du modèle,
    -- un chasseur OLTP correspond à une seule ligne
    -- dans la dimension.
    CONSTRAINT uq_dim_chasseur_source
        UNIQUE (chasseur_id_source)
);


-- ============================================================
-- 4. DIMENSION CLIENT
-- ============================================================

-- La dimension client est volontairement minimale.
--
-- Le but n'est pas de recopier toutes les données personnelles
-- dans l'environnement analytique.
--
-- Cette décision applique le principe RGPD de minimisation :
--
-- ne stocker que les informations réellement nécessaires.
--
-- Pour les premiers indicateurs, l'identifiant source suffit.

CREATE TABLE IF NOT EXISTS match_immo_olap.dim_client (

    -- Clé technique OLAP.
    client_key BIGINT GENERATED ALWAYS AS IDENTITY,

    -- Identifiant provenant de :
    --
    -- CLIENT.id_client
    client_id_source INTEGER NOT NULL,

    CONSTRAINT pk_dim_client
        PRIMARY KEY (client_key),

    CONSTRAINT uq_dim_client_source
        UNIQUE (client_id_source)
);


-- ============================================================
-- 5. DIMENSION SECTEUR
-- ============================================================

-- Cette dimension permet les analyses géographiques.
--
-- Dans le modèle OLTP, SECTEUR contient :
--
--   - ville ;
--   - quartier ;
--   - code postal.
--
-- Exemples d'indicateurs :
--
--   - nombre de ventes par ville ;
--   - activité par quartier ;
--   - prix moyen par secteur ;
--   - nombre de mandats par territoire.

CREATE TABLE IF NOT EXISTS match_immo_olap.dim_secteur (

    secteur_key BIGINT GENERATED ALWAYS AS IDENTITY,

    -- Identifiant original :
    --
    -- SECTEUR.id_secteur
    secteur_id_source INTEGER NOT NULL,

    ville VARCHAR(80) NOT NULL,
    quartier VARCHAR(80),
    code_postal VARCHAR(10) NOT NULL,

    CONSTRAINT pk_dim_secteur
        PRIMARY KEY (secteur_key),

    CONSTRAINT uq_dim_secteur_source
        UNIQUE (secteur_id_source)
);


-- ============================================================
-- 6. DIMENSION TYPE DE BIEN
-- ============================================================

-- Dans le modèle OLTP, le type de bien est directement
-- enregistré dans :
--
-- BIEN.type_bien
--
-- Exemples :
--
--   Appartement
--   Maison
--   Terrain
--
-- Dans l'OLAP, on transforme cette valeur en dimension
-- afin de faciliter les regroupements statistiques.

CREATE TABLE IF NOT EXISTS match_immo_olap.dim_type_bien (

    type_bien_key BIGINT GENERATED ALWAYS AS IDENTITY,

    -- Valeur provenant de BIEN.type_bien.
    type_bien_source VARCHAR(50) NOT NULL,

    CONSTRAINT pk_dim_type_bien
        PRIMARY KEY (type_bien_key),

    -- Un même type de bien ne doit être enregistré
    -- qu'une seule fois dans la dimension.
    CONSTRAINT uq_dim_type_bien_source
        UNIQUE (type_bien_source)
);


-- ============================================================
-- 7. TABLE DE FAITS : FACT_VENTE
-- ============================================================

-- GRAIN
-- -----
-- Le "grain" définit ce que représente UNE ligne
-- d'une table de faits.
--
-- Ici :
--
--     1 ligne FACT_VENTE
--     =
--     1 ACTE_AUTHENTIQUE
--
-- Dans le modèle métier, l'acte authentique représente
-- la vente immobilière finalisée.
--
-- Le parcours de reconstruction est :
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
-- Pour la commission :
--
-- ACTE_AUTHENTIQUE
--        |
--        v
--    HONORAIRES
--        |
--        v
--    COMMISSION

CREATE TABLE IF NOT EXISTS match_immo_olap.fact_vente (

    -- Clé technique de la table de faits.
    vente_key BIGINT GENERATED ALWAYS AS IDENTITY,

    -- Identifiant de l'acte authentique source.
    --
    -- Il correspond exactement à :
    --
    -- ACTE_AUTHENTIQUE.id_acte
    --
    -- On utilise "acte_id_source" plutôt que
    -- "vente_id_source" afin de conserver une traçabilité
    -- explicite avec le modèle OLTP réel.
    acte_id_source INTEGER NOT NULL,

    -- Référence vers la date de signature de l'acte :
    --
    -- ACTE_AUTHENTIQUE.date_acte
    temps_key BIGINT NOT NULL,

    -- Chasseur provenant du MANDAT.
    chasseur_key BIGINT NOT NULL,

    -- Client provenant du MANDAT.
    client_key BIGINT NOT NULL,

    -- Secteur du BIEN vendu.
    secteur_key BIGINT NOT NULL,

    -- Type du BIEN vendu.
    type_bien_key BIGINT NOT NULL,

    -- Prix final enregistré dans :
    --
    -- ACTE_AUTHENTIQUE.prix_vente
    prix_vente NUMERIC(12,2) NOT NULL,

    -- Honoraires totaux facturés pour la vente.
    --
    -- Source :
    -- HONORAIRES.montant_total
    montant_honoraires NUMERIC(12,2),

    -- Commission versée au chasseur.
    --
    -- Source :
    -- COMMISSION.montant_commission
    montant_commission NUMERIC(12,2),

    CONSTRAINT pk_fact_vente
        PRIMARY KEY (vente_key),

    -- Un acte authentique OLTP ne doit produire
    -- qu'une seule ligne FACT_VENTE.
    CONSTRAINT uq_fact_vente_acte_source
        UNIQUE (acte_id_source),

    -- Les montants ne peuvent pas être négatifs.
    CONSTRAINT chk_fact_vente_prix
        CHECK (prix_vente >= 0),

    CONSTRAINT chk_fact_vente_honoraires
        CHECK (
            montant_honoraires IS NULL
            OR montant_honoraires >= 0
        ),

    CONSTRAINT chk_fact_vente_commission
        CHECK (
            montant_commission IS NULL
            OR montant_commission >= 0
        ),

    -- ========================================================
    -- CLÉS ÉTRANGÈRES VERS LES DIMENSIONS
    -- ========================================================

    CONSTRAINT fk_fact_vente_temps
        FOREIGN KEY (temps_key)
        REFERENCES match_immo_olap.dim_temps (temps_key),

    CONSTRAINT fk_fact_vente_chasseur
        FOREIGN KEY (chasseur_key)
        REFERENCES match_immo_olap.dim_chasseur (chasseur_key),

    CONSTRAINT fk_fact_vente_client
        FOREIGN KEY (client_key)
        REFERENCES match_immo_olap.dim_client (client_key),

    CONSTRAINT fk_fact_vente_secteur
        FOREIGN KEY (secteur_key)
        REFERENCES match_immo_olap.dim_secteur (secteur_key),

    CONSTRAINT fk_fact_vente_type_bien
        FOREIGN KEY (type_bien_key)
        REFERENCES match_immo_olap.dim_type_bien (type_bien_key)
);


-- ============================================================
-- 8. TABLE DE FAITS : FACT_ACTIVITE_MANDAT
-- ============================================================

-- GRAIN
-- -----
--
--     1 ligne FACT_ACTIVITE_MANDAT
--     =
--     1 MANDAT
--
-- Cette table ne mesure pas seulement les ventes.
--
-- Elle permet de comprendre tout le travail effectué
-- autour d'un mandat.
--
-- Parcours métier :
--
-- MANDAT
--    |
--    v
-- PRESENTATION
--    |
--    v
-- VISITE
--    |
--    v
-- OFFRE
--    |
--    v
-- ACTE_AUTHENTIQUE
--
-- Les compteurs seront calculés par l'ETL.

CREATE TABLE IF NOT EXISTS match_immo_olap.fact_activite_mandat (

    -- Clé technique OLAP.
    activite_mandat_key BIGINT GENERATED ALWAYS AS IDENTITY,

    -- Identifiant source :
    --
    -- MANDAT.id_mandat
    mandat_id_source INTEGER NOT NULL,

    -- Date choisie pour positionner le mandat dans le temps.
    --
    -- Dans la première version de l'ETL,
    -- elle correspondra à :
    --
    -- MANDAT.date_signature
    temps_key BIGINT NOT NULL,

    -- Chasseur directement présent dans MANDAT.
    chasseur_key BIGINT NOT NULL,

    -- Client directement présent dans MANDAT.
    client_key BIGINT NOT NULL,

    -- Un mandat peut concerner des présentations dans plusieurs
    -- secteurs.
    --
    -- On ne place donc PAS de secteur_key ici afin de ne pas
    -- inventer un "secteur unique du mandat" qui n'existe pas
    -- réellement dans le modèle OLTP.
    --
    -- L'analyse géographique détaillée de l'activité pourra
    -- être faite à partir des biens présentés si le besoin
    -- décisionnel l'exige dans une évolution future.

    -- Nombre de biens présentés pour ce mandat.
    --
    -- Source :
    -- COUNT(PRESENTATION)
    nombre_presentations INTEGER NOT NULL DEFAULT 0,

    -- Nombre de visites liées aux présentations du mandat.
    --
    -- Source :
    -- COUNT(VISITE)
    nombre_visites INTEGER NOT NULL DEFAULT 0,

    -- Nombre d'offres liées aux présentations du mandat.
    --
    -- Source :
    -- COUNT(OFFRE)
    nombre_offres INTEGER NOT NULL DEFAULT 0,

    -- Indique si au moins une offre issue du mandat
    -- a conduit à un acte authentique.
    --
    -- TRUE  = vente finalisée
    -- FALSE = aucune vente finalisée
    vente_realisee BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT pk_fact_activite_mandat
        PRIMARY KEY (activite_mandat_key),

    -- Un mandat OLTP correspond à une seule ligne
    -- analytique dans cette première version.
    CONSTRAINT uq_fact_activite_mandat_source
        UNIQUE (mandat_id_source),

    -- Les compteurs ne peuvent pas être négatifs.
    CONSTRAINT chk_fact_activite_presentations
        CHECK (nombre_presentations >= 0),

    CONSTRAINT chk_fact_activite_visites
        CHECK (nombre_visites >= 0),

    CONSTRAINT chk_fact_activite_offres
        CHECK (nombre_offres >= 0),

    CONSTRAINT fk_fact_activite_temps
        FOREIGN KEY (temps_key)
        REFERENCES match_immo_olap.dim_temps (temps_key),

    CONSTRAINT fk_fact_activite_chasseur
        FOREIGN KEY (chasseur_key)
        REFERENCES match_immo_olap.dim_chasseur (chasseur_key),

    CONSTRAINT fk_fact_activite_client
        FOREIGN KEY (client_key)
        REFERENCES match_immo_olap.dim_client (client_key)
);


-- ============================================================
-- 9. INDEX DES TABLES DE FAITS
-- ============================================================

-- Un index est une structure auxiliaire permettant
-- à PostgreSQL de retrouver certaines lignes plus rapidement.
--
-- Les index suivants correspondent aux axes d'analyse
-- les plus naturels du modèle en étoile.
--
-- Exemple :
--
-- "Toutes les ventes du chasseur X"
--
-- PostgreSQL pourra utiliser :
--
-- idx_fact_vente_chasseur
--
-- IMPORTANT :
-- La Phase 3 comprend également un benchmark spécifique
-- d'indexation.
--
-- Les index ci-dessous sont ceux du modèle analytique.
-- Ils ne remplacent pas la démonstration avant/après
-- qui sera réalisée sur l'OLTP avec EXPLAIN ANALYZE.


-- ------------------------------------------------------------
-- FACT_VENTE
-- ------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_fact_vente_temps
    ON match_immo_olap.fact_vente (temps_key);

CREATE INDEX IF NOT EXISTS idx_fact_vente_chasseur
    ON match_immo_olap.fact_vente (chasseur_key);

CREATE INDEX IF NOT EXISTS idx_fact_vente_client
    ON match_immo_olap.fact_vente (client_key);

CREATE INDEX IF NOT EXISTS idx_fact_vente_secteur
    ON match_immo_olap.fact_vente (secteur_key);

CREATE INDEX IF NOT EXISTS idx_fact_vente_type_bien
    ON match_immo_olap.fact_vente (type_bien_key);


-- ------------------------------------------------------------
-- FACT_ACTIVITE_MANDAT
-- ------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_fact_activite_temps
    ON match_immo_olap.fact_activite_mandat (temps_key);

CREATE INDEX IF NOT EXISTS idx_fact_activite_chasseur
    ON match_immo_olap.fact_activite_mandat (chasseur_key);

CREATE INDEX IF NOT EXISTS idx_fact_activite_client
    ON match_immo_olap.fact_activite_mandat (client_key);


-- ============================================================
-- 10. COMMENT LIRE CE MODÈLE
-- ============================================================

-- Le modèle analytique peut être résumé ainsi :
--
--
--                    DIM_TEMPS
--                        |
--                        |
-- DIM_CLIENT ------ FACT_VENTE ------ DIM_CHASSEUR
--                        |
--                        |
--                   DIM_SECTEUR
--                        |
--                        |
--                  DIM_TYPE_BIEN
--
--
-- Pour l'activité des mandats :
--
--
--                    DIM_TEMPS
--                        |
--                        |
-- DIM_CLIENT -- FACT_ACTIVITE_MANDAT -- DIM_CHASSEUR
--
--
-- FACT_VENTE répond principalement à :
--
-- "Quels résultats commerciaux avons-nous obtenus ?"
--
--
-- FACT_ACTIVITE_MANDAT répond principalement à :
--
-- "Quel travail a été nécessaire pour parvenir
--  ou non à une vente ?"


-- ============================================================
-- 11. TRAÇABILITÉ OLTP → OLAP
-- ============================================================

-- Correspondance principale :
--
-- OLTP                               OLAP
-- ------------------------------------------------------------
--
-- ACTE_AUTHENTIQUE.id_acte       -> FACT_VENTE.acte_id_source
--
-- ACTE_AUTHENTIQUE.date_acte     -> DIM_TEMPS
--
-- ACTE_AUTHENTIQUE.prix_vente    -> FACT_VENTE.prix_vente
--
-- HONORAIRES.montant_total       -> FACT_VENTE.montant_honoraires
--
-- COMMISSION.montant_commission  -> FACT_VENTE.montant_commission
--
-- MANDAT.id_mandat               -> FACT_ACTIVITE_MANDAT
--
-- PRESENTATION                    -> nombre_presentations
--
-- VISITE                          -> nombre_visites
--
-- OFFRE                           -> nombre_offres
--
-- ACTE_AUTHENTIQUE                -> vente_realisee
--
-- CHASSEUR                        -> DIM_CHASSEUR
--
-- CLIENT                          -> DIM_CLIENT
--
-- SECTEUR                         -> DIM_SECTEUR
--
-- BIEN.type_bien                 -> DIM_TYPE_BIEN


-- ============================================================
-- 12. FIN DU SCRIPT
-- ============================================================

-- Après exécution de ce fichier, PostgreSQL doit contenir :
--
-- match_immo_olap.dim_temps
-- match_immo_olap.dim_chasseur
-- match_immo_olap.dim_client
-- match_immo_olap.dim_secteur
-- match_immo_olap.dim_type_bien
--
-- match_immo_olap.fact_vente
-- match_immo_olap.fact_activite_mandat
--
--
-- Étape suivante :
--
--     olap-etl.sql
--
-- Ce second fichier remplira réellement ces tables
-- à partir de l'OLTP Match-Immo.
--
-- ============================================================