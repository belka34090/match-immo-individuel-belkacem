# Benchmark d'indexation PostgreSQL

## 1. Objectif

Dans le cadre de la phase 3 « Absorber la croissance », ce benchmark vérifie si l'indexation actuelle de la table `bien` reste adaptée à une recherche immobilière lorsque le volume augmente.

La recherche étudiée correspond à un besoin métier courant :

- rechercher dans un secteur donné ;
- respecter une plage de prix ;
- imposer une surface minimale.

L'objectif n'est pas de démontrer que « les index sont rapides », mais de mesurer si un index composite adapté à cette recherche apporte un gain par rapport à l'indexation actuelle.

## 2. Protocole

Le benchmark est isolé dans le schéma PostgreSQL `benchmark` afin de ne pas polluer les données métier simulées de `fil_rouge_cible`.

La table `benchmark.bien` reprend la structure utile de `fil_rouge_cible.bien`.

L'état de référence reproduit :

- la clé primaire sur `id_bien` ;
- l'index simple existant sur `secteur_id`.

Un jeu synthétique déterministe de **1 000 000 de biens** a été généré.

La requête testée est :

```sql
SELECT
    id_bien,
    secteur_id,
    prix,
    surface
FROM benchmark.bien
WHERE secteur_id = 42
  AND prix BETWEEN 250000 AND 350000
  AND surface >= 60;
```

Sur le million de lignes :

- 10 000 appartiennent au secteur 42 ;
- 1 112 respectent également la plage de prix ;
- 863 respectent les trois critères.

Les mesures sont réalisées avec :

```sql
EXPLAIN (ANALYZE, BUFFERS)
```

`EXPLAIN` décrit le plan choisi par PostgreSQL, `ANALYZE` exécute réellement la requête et mesure son exécution, et `BUFFERS` indique les blocs manipulés.

La comparaison retenue utilise des exécutions en **cache chaud**, c'est-à-dire lorsque les blocs nécessaires sont déjà présents en mémoire, afin de comparer les deux stratégies dans des conditions similaires.

## 3. État initial

Index disponible :

```sql
CREATE INDEX idx_benchmark_bien_secteur
ON benchmark.bien (secteur_id);
```

PostgreSQL utilise cet index pour identifier les biens du secteur 42.

Résultat observé :

- 10 000 lignes candidates trouvées ;
- 9 137 lignes éliminées ensuite par les filtres `prix` et `surface` ;
- 863 lignes retournées ;
- 10 000 blocs de table consultés ;
- 10 010 buffers en cache (`shared hit`) ;
- temps d'exécution : **11,438 ms**.

L'index simple est donc utile, mais il ne couvre que le secteur. PostgreSQL doit encore examiner les 10 000 biens du secteur pour appliquer les deux autres critères.

## 4. Optimisation testée

L'index composite suivant a été ajouté :

```sql
CREATE INDEX idx_benchmark_bien_secteur_prix_surface
ON benchmark.bien (secteur_id, prix, surface);
```

L'ordre commence par `secteur_id`, utilisé avec une égalité, puis intègre les critères de prix et de surface correspondant à la recherche métier étudiée.

Après création de l'index, PostgreSQL utilise directement celui-ci pour appliquer les trois conditions.

Résultat observé en cache chaud :

- 863 lignes candidates ;
- 863 lignes retournées ;
- aucune ligne éliminée par un filtre supplémentaire ;
- 863 blocs de table consultés ;
- 870 buffers en cache (`shared hit`) ;
- temps d'exécution : **2,641 ms**.

## 5. Comparaison

| Indicateur | Index simple | Index composite | Évolution |
|---|---:|---:|---:|
| Lignes candidates | 10 000 | 863 | -91,4 % |
| Lignes retournées | 863 | 863 | identique |
| Lignes éliminées après lecture | 9 137 | 0 | -100 % |
| Blocs de table consultés | 10 000 | 863 | -91,4 % |
| Buffers `shared hit` | 10 010 | 870 | -91,3 % |
| Temps d'exécution | 11,438 ms | 2,641 ms | -76,9 % |

Dans cette campagne de mesure, la requête est donc environ **4,3 fois plus rapide** avec l'index composite.

Le résultat le plus important n'est toutefois pas uniquement le temps. Le plan d'exécution montre que PostgreSQL passe de 10 000 lignes candidates à 863 lignes directement pertinentes et réduit fortement les blocs de table consultés.

## 6. Décision architecturale

Le benchmark démontre qu'à **1 million de biens simulés**, un index composite adapté à la recherche `secteur + prix + surface` est plus pertinent que le seul index simple sur `secteur_id` pour ce cas d'usage.

L'index composite est donc retenu comme optimisation candidate pour ce type de recherche à forte volumétrie.

Cette décision ne signifie pas que tous les index doivent devenir composites. Un index consomme de l'espace disque et entraîne un coût de maintenance lors des insertions, mises à jour et suppressions. Son ajout doit correspondre à des requêtes métier réellement utilisées.

PostgreSQL peut également choisir de ne pas utiliser un index lorsque la requête retourne une proportion importante de la table : dans ce cas, une lecture séquentielle peut être plus efficace.

## 7. Limites et suite

Ce benchmark mesure un cas précis d'indexation sur un jeu synthétique reproductible. Il ne démontre pas à lui seul la capacité de l'ensemble du SI à absorber plusieurs dizaines ou centaines de millions de lignes.

La montée en charge sera donc étudiée progressivement dans les étapes suivantes de la phase 3 afin de déterminer, par la mesure, quand des mécanismes complémentaires comme le partitionnement ou la distribution avec Citus deviennent pertinents.

Le protocole reproductible est disponible dans :

`03-architecture/sql/benchmark-indexation.sql`
