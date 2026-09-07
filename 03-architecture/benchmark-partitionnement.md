# Benchmark de partitionnement PostgreSQL

## 1. Objectif

Dans le cadre de la phase 3 « Absorber la croissance », ce benchmark vérifie si le partitionnement temporel de la table `presentation` apporte un gain mesurable lorsque le volume devient important.

La table `presentation` est une bonne candidate car elle peut croître rapidement : chaque bien proposé à un client génère une présentation, alors que toutes les présentations ne deviennent pas forcément une visite, une offre ou un paiement.

Le cas métier étudié est une recherche des présentations réalisées pendant un mois donné.

## 2. Contrainte du modèle cible

Dans `fil_rouge_cible`, la table `presentation` possède actuellement :

```sql
PRIMARY KEY (id_presentation)
```

Cette clé primaire est référencée par plusieurs tables :

- `avis_chasseur` ;
- `commentaire` ;
- `offre` ;
- `visite`.

PostgreSQL impose que la clé d'une contrainte d'unicité ou d'une clé primaire d'une table partitionnée inclue la colonne de partitionnement.

Un partitionnement direct par `date_presentation` aurait donc un impact sur la clé primaire et sur les relations existantes.

Pour ne pas modifier artificiellement le modèle métier uniquement pour un POC de performance, le benchmark est réalisé dans le schéma isolé `benchmark`.

## 3. Protocole

Deux tables contenant exactement les mêmes données ont été créées :

```text
benchmark.presentation_non_partitionnee
benchmark.presentation_partitionnee
```

La première est une table PostgreSQL classique.

La seconde utilise un partitionnement :

```sql
PARTITION BY RANGE (date_presentation)
```

Elle est découpée en **24 partitions mensuelles**, de janvier 2025 à décembre 2026.

Les deux tables possèdent :

- les mêmes colonnes ;
- les mêmes contraintes `NOT NULL` et `CHECK` utiles ;
- aucun index secondaire ;
- exactement les mêmes **10 000 000 de présentations simulées**.

L'absence d'index secondaire permet d'isoler l'effet du partitionnement sans mélanger celui-ci avec un gain lié à l'indexation.

La période réellement générée est :

```text
2025-01-01 00:00:02
→
2026-12-31 23:59:51
```

Les 24 partitions sont alimentées.

La partition d'août 2026 contient :

**434 336 lignes**.

## 4. Requête testée

La requête utilisée recherche les présentations du mois d'août 2026 :

```sql
SELECT COUNT(*)
FROM benchmark.presentation_non_partitionnee
WHERE date_presentation >= TIMESTAMP '2026-08-01 00:00:00'
  AND date_presentation <  TIMESTAMP '2026-09-01 00:00:00';
```

La même condition est appliquée à la table partitionnée.

Les mesures sont réalisées avec :

```sql
EXPLAIN (ANALYZE, BUFFERS)
```

Deux exécutions successives sont réalisées pour chaque table dans les mêmes conditions.

La seconde exécution est retenue comme mesure comparative de référence.

## 5. Résultat sans partitionnement

Plan observé :

```text
Parallel Seq Scan on presentation_non_partitionnee
```

PostgreSQL parcourt la table complète avant de conserver uniquement les lignes du mois demandé.

Résultat mesuré :

- volume total : 10 000 000 lignes ;
- lignes utiles pour août 2026 : 434 336 ;
- blocs manipulés : 161 010 ;
- temps d'exécution : **130,166 ms**.

Le plan montre également que les lignes hors période sont éliminées après lecture.

## 6. Résultat avec partitionnement

Plan observé :

```text
Parallel Seq Scan on presentation_p_2026_08 presentation_partitionnee
```

PostgreSQL ne parcourt que la partition correspondant à août 2026.

Les 23 autres partitions sont ignorées grâce au mécanisme de **partition pruning**.

Le partition pruning signifie que PostgreSQL élimine automatiquement les partitions qui ne peuvent pas contenir les données demandées.

Résultat mesuré :

- volume total logique : 10 000 000 lignes ;
- partition réellement parcourue : `presentation_p_2026_08` ;
- lignes dans cette partition : 434 336 ;
- blocs manipulés : 7 006 ;
- temps d'exécution : **25,008 ms**.

## 7. Comparaison

| Indicateur | Non partitionnée | Partitionnée | Évolution |
|---|---:|---:|---:|
| Volume total | 10 000 000 | 10 000 000 | identique |
| Lignes utiles | 434 336 | 434 336 | identique |
| Partitions parcourues | sans objet | 1 sur 24 | 23 ignorées |
| Blocs manipulés | 161 010 | 7 006 | -95,65 % |
| Temps d'exécution | 130,166 ms | 25,008 ms | -80,79 % |

Dans cette campagne de mesure, la requête est environ :

**5,2 fois plus rapide**

avec le partitionnement mensuel.

Le nombre de blocs manipulés est réduit d'environ :

**95,7 %**.

Le gain principal vient du fait que PostgreSQL ne parcourt plus l'ensemble des données mais uniquement la partition temporelle nécessaire.

## 8. Décision architecturale

Le benchmark démontre qu'à **10 millions de présentations simulées**, le partitionnement mensuel par `date_presentation` est pertinent pour les requêtes fortement filtrées sur une période temporelle.

Le partitionnement est donc retenu comme mécanisme de montée en charge pertinent pour la table `presentation` lorsque sa volumétrie devient importante et que les accès métier sont fréquemment temporels.

Cette décision ne signifie pas qu'il faut immédiatement modifier la table `fil_rouge_cible.presentation`.

Une migration réelle nécessiterait une étude spécifique des contraintes, car la clé primaire actuelle `id_presentation` est référencée par plusieurs tables.

Le benchmark valide donc le **principe architectural**, sans casser le modèle métier actuel.

## 9. Limites

Ce test porte sur :

- une seule table ;
- une seule stratégie de partitionnement ;
- une granularité mensuelle ;
- une seule requête temporelle ;
- des données synthétiques déterministes ;
- un environnement PostgreSQL local.

Les temps mesurés ne constituent donc pas un SLA de production.

La preuve principale repose sur :

- le plan d'exécution ;
- le partition pruning ;
- la réduction du nombre de blocs manipulés ;
- le gain de temps observé.

## 10. Conclusion

Le partitionnement n'est pas retenu par principe, mais parce qu'un gain mesurable a été démontré à forte volumétrie.

À 10 millions de lignes :

```text
130,166 ms
→
25,008 ms
```

et :

```text
161 010 blocs
→
7 006 blocs
```

Le partitionnement mensuel par `date_presentation` constitue donc une optimisation crédible pour accompagner la croissance de Match-Immo sur ce type de requête temporelle.

Le protocole reproductible est disponible dans :

`03-architecture/sql/benchmark-partitionnement.sql`
