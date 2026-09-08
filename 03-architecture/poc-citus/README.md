# POC Citus / Sharding — Match-Immo

## Objectif

Ce dossier contient le POC Citus utilisé dans la Phase 3 du projet Match-Immo pour tester la **distribution horizontale de données PostgreSQL**.

L'objectif est de démontrer concrètement :

* l'utilisation de Citus avec PostgreSQL ;
* un coordinator ;
* deux workers ;
* une table distribuée ;
* 32 shards ;
* une charge de 10 000 000 de lignes ;
* le routage d'une requête sur la clé de distribution ;
* le scatter-gather hors clé de distribution ;
* la complémentarité entre sharding et indexation.

Le POC est volontairement isolé du modèle opérationnel `fil_rouge_cible`.

---

## Architecture

```text
                       Client SQL
                           |
                           v
                Citus Coordinator
                           |
               +-----------+-----------+
               |                       |
               v                       v
            worker1                 worker2
             PG16                    PG16
               |                       |
            16 shards                16 shards
```

La stack utilise :

```text
Citus 14.2
PostgreSQL 16
Docker Compose
```

---

## Fichiers

```text
03-architecture/poc-citus/
├── README.md
├── benchmark-citus-sharding.md
├── docker-compose.yml
└── init.sql
```

### `docker-compose.yml`

Décrit les trois services :

```text
matchimmo-citus-coordinator
matchimmo-citus-worker1
matchimmo-citus-worker2
```

### `init.sql`

Le script :

1. active Citus ;
2. enregistre les deux workers ;
3. fixe le nombre de shards à 32 ;
4. crée `presentation_poc` ;
5. distribue la table sur `mandat_id` ;
6. génère 10 000 000 de lignes ;
7. vérifie la distribution des shards ;
8. teste une requête sur la clé de distribution ;
9. teste une requête hors clé ;
10. crée un index sur `bien_id` ;
11. rejoue le test après indexation.

### `benchmark-citus-sharding.md`

Contient l'analyse complète :

* protocole ;
* preuves ;
* résultats mesurés ;
* explications métier et techniques ;
* limites ;
* impacts ;
* décision d'architecture.

---

## Clé de distribution

La clé utilisée est :

```text
mandat_id
```

Elle a été retenue car :

* elle existe directement dans la table `presentation` du modèle solo ;
* elle possède un sens métier fort ;
* elle permet de regrouper les présentations associées à un même mandat.

---

## Démarrage

Depuis la racine du dépôt :

```bash
docker compose \
  -f 03-architecture/poc-citus/docker-compose.yml \
  up -d
```

Vérifier l'état :

```bash
docker compose \
  -f 03-architecture/poc-citus/docker-compose.yml \
  ps
```

Les trois services doivent être `healthy`.

---

## Initialisation du POC

Exécuter :

```bash
time docker exec -i matchimmo-citus-coordinator \
  psql -U postgres -d matchimmo_citus \
  < 03-architecture/poc-citus/init.sql
```

---

## Résultats principaux

Le POC a produit :

```text
10 000 000 lignes
32 shards
16 shards sur worker1
16 shards sur worker2
```

Répartition physique :

```text
worker1 = 891 MB
worker2 = 897 MB
```

La distribution est donc équilibrée.

---

## Test sur la clé de distribution

Requête :

```sql
SELECT *
FROM public.presentation_poc
WHERE mandat_id = 42000;
```

Résultat :

```text
Task Count: 1
Execution Time: 1.318 ms
```

Cela signifie que Citus sait directement quel shard interroger.

---

## Test hors clé de distribution

Requête :

```sql
SELECT *
FROM public.presentation_poc
WHERE bien_id = 500000;
```

Avant index :

```text
Task Count: 32
Execution Time: 82.851 ms
```

Citus doit interroger plusieurs shards.

Ce comportement est appelé :

```text
scatter-gather
```

---

## Test après indexation

Index :

```sql
CREATE INDEX idx_presentation_poc_bien_id
ON public.presentation_poc (bien_id);
```

Nouvelle mesure :

```text
Task Count: 32
Execution Time: 3.709 ms
```

Le nombre de tâches ne change pas.

L'index accélère la recherche dans chaque shard.

Gain observé :

```text
≈ 22,3× plus rapide
≈ 95,5 % de temps en moins
```

---

## Sharding et indexation

Les deux mécanismes sont complémentaires.

```text
SHARDING
→ détermine où chercher

INDEX
→ accélère la recherche dans le shard
```

Un index ne remplace donc pas une bonne clé de distribution.

---

## Arrêt du POC

Pour arrêter les conteneurs :

```bash
docker compose \
  -f 03-architecture/poc-citus/docker-compose.yml \
  down
```

Pour supprimer également les volumes du laboratoire :

```bash
docker compose \
  -f 03-architecture/poc-citus/docker-compose.yml \
  down -v
```

Attention :

```text
-v
```

supprime les données PostgreSQL du POC.

---

## Limites

Ce POC fonctionne sur une seule machine physique.

Il démontre :

* le sharding ;
* la distribution ;
* le routage ;
* le scatter-gather ;
* l'utilisation d'index distribués.

Il ne démontre pas :

* une architecture Citus de production multi-machine ;
* la haute disponibilité du coordinator ;
* la haute disponibilité des workers ;
* une latence réseau réelle entre serveurs ;
* que Citus doit être utilisé immédiatement en production.

---

## Décision d'architecture

Le POC Citus est techniquement validé.

La décision retenue est toutefois :

```text
CITUS = CAPACITÉ D'ÉVOLUTION
```

et non :

```text
CITUS IMMÉDIATEMENT EN PRODUCTION
```

L'architecture Match-Immo reste progressive :

```text
PostgreSQL
    ↓
indexation
    ↓
partitionnement ciblé
    ↓
réplication pour la haute disponibilité
    ↓
OLTP / OLAP
    ↓
Citus si les métriques futures le justifient
```

Le détail des preuves et de l'analyse est disponible dans :

```text
benchmark-citus-sharding.md
```
