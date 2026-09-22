# Benchmark Citus / sharding — Match-Immo

## Phase 3 — Absorber la croissance

## 1. Objectif

Ce POC a pour objectif de vérifier expérimentalement si **Citus** peut constituer une solution de montée en charge horizontale pour Match-Immo lorsque les volumes dépassent les capacités raisonnables d'une seule instance PostgreSQL.

Le but n'est pas de décider à l'avance que Citus doit être utilisé en production.

La démarche retenue est :

```text
Besoin de croissance
        ↓
POC isolé
        ↓
Charge synthétique importante
        ↓
Mesures
        ↓
Preuves
        ↓
Interprétation
        ↓
Décision d'architecture
```

Le principe directeur de cette Phase 3 reste :

> **Mesurer avant de complexifier.**

---

# 2. À qui s'adresse ce livrable ?

Ce document est volontairement lisible à plusieurs niveaux.

## 2.1 Pour un décideur

Il répond principalement aux questions :

- pourquoi étudier Citus ;
- quel problème il résout ;
- quels gains ont été observés ;
- quels coûts et risques il ajoute ;
- faut-il le retenir maintenant ou seulement comme capacité d'évolution.

## 2.2 Pour un métier

Il explique comment Match-Immo pourrait continuer à fonctionner lorsque les volumes de présentations immobilières deviennent très importants.

## 2.3 Pour un profil technique

Il décrit :

- la topologie Citus ;
- la clé de distribution ;
- les shards ;
- les workers ;
- les requêtes testées ;
- les plans `EXPLAIN ANALYZE` ;
- les effets de l'indexation.

## 2.4 Pour un jury ou évaluateur

Il fournit une chaîne de preuve reproductible :

```text
affirmation
→ protocole
→ résultat observé
→ mesure
→ interprétation
→ décision
```

---

# 3. Définitions simples

## 3.1 Citus

**Citus** est une extension de PostgreSQL permettant de distribuer une table sur plusieurs serveurs PostgreSQL.

Au lieu d'avoir :

```text
1 serveur PostgreSQL
        ↓
toutes les données
```

on peut avoir :

```text
1 coordinator
       |
       +--------+
       |        |
       v        v
   worker1   worker2
```

Le coordinator reçoit la requête SQL.

Les workers stockent réellement les morceaux de données.

## 3.2 Sharding

Le **sharding** consiste à découper une grosse table en plusieurs morceaux appelés **shards**.

Exemple :

```text
10 000 000 lignes
        ↓
32 shards
        ↓
16 shards sur worker1
16 shards sur worker2
```

## 3.3 Coordinator

Le **coordinator** est le point d'entrée SQL du cluster Citus.

Il reçoit la requête, détermine quels shards doivent être interrogés, envoie les tâches aux workers puis regroupe les résultats.

## 3.4 Worker

Un **worker** est une instance PostgreSQL qui stocke physiquement des shards.

## 3.5 Clé de distribution

La **clé de distribution** est la colonne utilisée par Citus pour décider dans quel shard placer une ligne.

Dans ce POC :

```text
clé de distribution = mandat_id
```

## 3.6 Scatter-gather

Un **scatter-gather** apparaît lorsque Citus ne peut pas déterminer un seul shard à partir de la requête.

Il doit alors interroger plusieurs shards puis regrouper les résultats.

---

# 4. Pourquoi tester Citus dans Match-Immo ?

Les étapes précédentes de la Phase 3 ont déjà montré qu'il faut d'abord optimiser PostgreSQL avant de distribuer les données.

La progression retenue est :

```text
PostgreSQL
    ↓
indexation
    ↓
partitionnement ciblé
    ↓
réplication / haute disponibilité
    ↓
séparation OLTP / OLAP
    ↓
Citus si la croissance l'exige réellement
```

Citus répond à la question :

> Que faire si, malgré ces optimisations, le volume ou la charge dépasse les capacités raisonnables d'une seule instance PostgreSQL ?

Citus permet d'étudier la **scalabilité horizontale**, c'est-à-dire l'ajout de plusieurs nœuds plutôt que l'augmentation permanente de la puissance d'un seul serveur.

---

# 5. Pourquoi un POC séparé ?

Le POC Citus est volontairement isolé du modèle opérationnel cible.

Il ne modifie pas directement `fil_rouge_cible` et ne remplace pas le cluster PostgreSQL HA testé précédemment.

Cette séparation permet :

- d'éviter de dégrader le modèle cible ;
- de tester librement la distribution ;
- de supprimer le laboratoire sans toucher aux autres preuves ;
- de mesurer Citus indépendamment ;
- de conserver une architecture reproductible.

---

# 6. Origine et adaptation du POC

Une première version de ce POC avait été réalisée dans le projet de groupe Match-Immo.

Le POC solo reprend son principe mais il a été adapté au modèle actuel.

| Ancien POC groupe | POC solo |
|---|---|
| `demande_version_id` | `mandat_id` |
| `id` | `id_presentation` |
| `statut_id` | `statut` |
| modèle simplifié | structure proche de `PRESENTATION` solo |
| 1 000 000 lignes | 10 000 000 lignes |
| Citus 14.1 / PG16 | Citus 14.2 / PG16 |
| ancien dossier groupe | `03-architecture/poc-citus` |

Les résultats du groupe ne sont pas utilisés comme preuves du présent benchmark.

---

# 7. Choix de la table testée

La table distribuée est :

```text
presentation_poc
```

Elle est inspirée de la table métier solo `PRESENTATION`.

Le modèle du POC reprend notamment :

```text
mandat_id
id_presentation
bien_id
date_presentation
statut
priorite_client
decision_client
observations
```

---

# 8. Pourquoi distribuer sur `mandat_id` ?

Plusieurs clés étaient possibles.

## 8.1 `id_presentation`

Avantage : répartition potentiellement homogène.

Limite : faible sens métier et absence de regroupement naturel des présentations d'un même mandat.

Décision :

```text
NON RETENU
```

## 8.2 `bien_id`

Avantage : pertinent pour rechercher toutes les présentations associées à un bien.

Limite : le flux métier Match-Immo est davantage organisé autour du mandat.

Décision :

```text
NON RETENU POUR CE POC
```

## 8.3 `secteur_id`

Avantage : intéressant pour une architecture géographique ou internationale.

Limites :

- `secteur_id` n'est pas directement présent dans `presentation` ;
- cela imposerait une évolution du modèle uniquement pour le POC.

Décision :

```text
NON RETENU
```

## 8.4 `mandat_id`

Avantages :

- présent directement dans `presentation` ;
- sens métier fort ;
- regroupement des présentations d'un même mandat ;
- aucune dénaturation du modèle solo.

Décision :

```text
RETENU
```

---

# 9. Architecture du POC

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

Services :

```text
matchimmo-citus-coordinator
matchimmo-citus-worker1
matchimmo-citus-worker2
```

Image :

```text
citusdata/citus:14.2.0-pg16
```

---

# 10. Fichiers reproductibles

Le POC est versionné dans :

```text
03-architecture/poc-citus/
```

avec :

```text
docker-compose.yml
init.sql
```

`docker-compose.yml` décrit le coordinator, les deux workers, les volumes et le port exposé.

`init.sql` :

1. active Citus ;
2. enregistre les workers ;
3. fixe le nombre de shards ;
4. crée la table ;
5. la distribue ;
6. génère les données ;
7. mesure la distribution ;
8. exécute les requêtes ;
9. crée un index ;
10. rejoue les mesures.

---

# 11. Configuration des shards

Le nombre de shards est fixé explicitement :

```sql
SET citus.shard_count = 32;
```

Cela rend le POC reproductible.

---

# 12. Jeu de données

Le POC génère :

```text
10 000 000 lignes
```

Les données sont synthétiques et déterministes.

Elles ne correspondent à aucun client réel.

Résultat observé :

```text
INSERT 0 10000000
```

Contrôle :

```text
nb_lignes = 10000000
id_min    = 1
id_max    = 10000000
```

---

# 13. Temps global du script

Résultat :

```text
real    0m8,183s
user    0m0,011s
sys     0m0,012s
```

Cette valeur correspond à l'exécution du script global dans cet environnement local.

Elle ne constitue pas un benchmark universel de Citus.

Les performances dépendent notamment :

- du matériel ;
- du stockage ;
- du cache ;
- de Docker ;
- de PostgreSQL ;
- de la charge du système.

---

# 14. Preuve n°1 — Deux workers enregistrés

Résultat :

```text
nodename | nodeport | noderole | isactive
---------+----------+----------+---------
worker1  | 5432     | primary  | true
worker2  | 5432     | primary  | true
```

Interprétation : les deux workers sont enregistrés et actifs.

Conclusion :

```text
PREUVE VALIDÉE
```

---

# 15. Preuve n°2 — 32 shards distribués

Résultat :

```text
worker1 = 16 shards
worker2 = 16 shards
```

Soit :

```text
32 shards au total
```

Interprétation : la table de 10 millions de lignes est réellement découpée et répartie entre deux workers.

Conclusion :

```text
SHARDING OBSERVÉ
```

---

# 16. Preuve n°3 — Répartition physique du stockage

| Worker | Shards | Taille totale | Plus petit shard | Plus gros shard |
|---|---:|---:|---:|---:|
| worker1 | 16 | 891 MB | 54 MB | 57 MB |
| worker2 | 16 | 897 MB | 55 MB | 58 MB |

Volume distribué observé :

```text
891 MB + 897 MB = 1788 MB
```

soit environ :

```text
1,79 GB
```

Écart entre workers :

```text
897 MB - 891 MB = 6 MB
```

Interprétation : les deux workers stockent une quantité très proche de données.

Conclusion :

```text
DISTRIBUTION PHYSIQUE ÉQUILIBRÉE
```

---

# 17. Preuve n°4 — Requête sur la clé de distribution

Requête :

```sql
SELECT *
FROM public.presentation_poc
WHERE mandat_id = 42000;
```

Plan observé :

```text
Custom Scan (Citus Adaptive)
Task Count: 1
Node: worker2
Bitmap Heap Scan
Bitmap Index Scan
```

Résultats :

```text
100 lignes
Execution Time: 1.318 ms
```

---

# 18. Signification de `Task Count: 1`

La requête contient `mandat_id`, qui est la clé de distribution.

Citus peut donc déterminer directement le shard cible.

```text
WHERE mandat_id = 42000
          ↓
clé de distribution reconnue
          ↓
Citus calcule le shard
          ↓
1 seule tâche
          ↓
worker2
```

Conclusion :

```text
ROUTAGE DIRECT VALIDÉ
```

---

# 19. Preuve n°5 — Requête hors clé de distribution

Requête :

```sql
SELECT *
FROM public.presentation_poc
WHERE bien_id = 500000;
```

Avant index complémentaire :

```text
Custom Scan (Citus Adaptive)
Task Count: 32
Parallel Seq Scan
Execution Time: 82.851 ms
10 lignes retournées
```

---

# 20. Pourquoi `Task Count: 32` ?

La table est distribuée sur `mandat_id`, mais la requête porte uniquement sur `bien_id`.

Citus ne sait donc pas quel shard cible contient la donnée.

```text
WHERE bien_id = 500000
          ↓
pas de mandat_id
          ↓
shard cible inconnu
          ↓
32 tâches
          ↓
scatter-gather
```

Conclusion :

```text
SCATTER-GATHER OBSERVÉ
```

---

# 21. Conséquence métier du choix de clé

Le benchmark démontre qu'une clé de distribution ne doit pas être choisie uniquement pour équilibrer les données.

Elle doit aussi correspondre aux requêtes métier.

Avec `mandat_id` :

```text
recherche par mandat
→ routage très ciblé
```

mais :

```text
recherche par bien_id seul
→ scatter-gather
```

Le choix de la clé est donc une décision métier autant que technique.

---

# 22. Preuve n°6 — Ajout d'un index sur `bien_id`

Index créé :

```sql
CREATE INDEX idx_presentation_poc_bien_id
ON public.presentation_poc (bien_id);
```

La même requête est ensuite rejouée.

---

# 23. Résultat après indexation

Plan observé :

```text
Custom Scan (Citus Adaptive)
Task Count: 32
Bitmap Heap Scan
Bitmap Index Scan
Execution Time: 3.709 ms
```

Le nombre de tâches reste :

```text
32
```

---

# 24. Comparaison avant / après index

| Mesure | Sans index | Avec index |
|---|---:|---:|
| Task Count | 32 | 32 |
| Type de recherche | scans séquentiels | scans indexés |
| Temps | 82.851 ms | 3.709 ms |
| Lignes retournées | 10 | 10 |

Calcul du gain :

```text
82.851 / 3.709 ≈ 22,3
```

Soit environ :

```text
22,3 fois plus rapide
```

Réduction du temps :

```text
1 - (3.709 / 82.851)
≈ 95,5 %
```

Conclusion :

```text
≈ 95,5 % de temps en moins
```

---

# 25. Pourquoi l'index ne réduit-il pas `Task Count` ?

Avant index :

```text
32 shards interrogés
+
recherche coûteuse dans chaque shard
```

Après index :

```text
32 shards interrogés
+
recherche rapide dans chaque shard
```

L'index améliore la recherche locale.

Il ne change pas la clé de distribution.

---

# 26. Différence entre sharding et indexation

Le sharding répond à :

> Où faut-il chercher ?

L'index répond à :

> Comment trouver rapidement la donnée une fois au bon endroit ?

```text
SHARDING
    ↓
choisir où chercher
    ↓
INDEX
    ↓
chercher rapidement
```

Ils sont complémentaires.

---

# 27. Résultats synthétiques

| Preuve | Résultat |
|---|---|
| Coordinator Citus | Validé |
| Workers | 2 |
| Workers actifs | Validé |
| Lignes | 10 000 000 |
| Shards | 32 |
| Shards worker1 | 16 |
| Shards worker2 | 16 |
| Stockage worker1 | 891 MB |
| Stockage worker2 | 897 MB |
| Volume distribué observé | ~1,79 GB |
| Clé de distribution | `mandat_id` |
| Requête sur clé | 1 tâche |
| Temps sur clé | 1.318 ms |
| Requête hors clé | 32 tâches |
| Hors clé sans index | 82.851 ms |
| Hors clé avec index | 3.709 ms |
| Gain index | ~22,3× |
| Réduction de temps | ~95,5 % |
| Scatter-gather | Démontré |
| Index + sharding complémentaires | Démontré |

---

# 28. Affirmations et preuves

## Affirmation 1

> Citus distribue réellement la table.

Preuve :

```text
32 shards
16 sur worker1
16 sur worker2
```

Conclusion : validée.

## Affirmation 2

> Les données sont physiquement réparties.

Preuve :

```text
worker1 = 891 MB
worker2 = 897 MB
```

Conclusion : validée.

## Affirmation 3

> Une requête alignée sur la clé cible directement un shard.

Preuve :

```text
WHERE mandat_id = 42000
Task Count = 1
```

Conclusion : validée.

## Affirmation 4

> Une requête hors clé peut provoquer un scatter-gather.

Preuve :

```text
WHERE bien_id = 500000
Task Count = 32
```

Conclusion : validée.

## Affirmation 5

> L'indexation reste utile dans une architecture distribuée.

Preuve :

```text
sans index = 82.851 ms
avec index = 3.709 ms
```

Conclusion : validée.

---

# 29. Ce que le POC prouve réellement

Le POC démontre que Citus sait :

- distribuer une table PostgreSQL ;
- créer des shards ;
- répartir les shards sur plusieurs workers ;
- router certaines requêtes vers un seul shard ;
- exécuter des scatter-gather ;
- utiliser des index dans les shards ;
- conserver l'interface SQL PostgreSQL ;
- traiter le jeu de 10 millions de lignes utilisé dans l'environnement testé.

---

# 30. Ce que le POC ne prouve pas

Le POC ne démontre pas que :

- Citus est obligatoire pour Match-Immo ;
- Citus est plus rapide pour toutes les requêtes ;
- `mandat_id` est définitivement optimal pour tous les usages futurs ;
- deux workers suffisent pour une production mondiale ;
- Docker Compose représente une architecture de production ;
- la haute disponibilité du coordinator est couverte ;
- les workers sont eux-mêmes hautement disponibles ;
- le réseau réel d'un cluster multi-machine est reproduit ;
- les coûts opérationnels sont négligeables.

---

# 31. Limite — environnement local

Les trois conteneurs tournent sur la même machine physique.

Le POC démontre les mécanismes de Citus, mais pas :

- une vraie latence réseau inter-machine ;
- une panne physique indépendante des workers ;
- une scalabilité sur plusieurs serveurs réels.

---

# 32. Limite — haute disponibilité

Le POC CloudNativePG précédent a démontré :

```text
réplication
+
failover
+
persistance
```

Le présent POC démontre :

```text
distribution
+
sharding
+
routage
```

Ce sont deux problèmes différents.

Une architecture de production distribuée demanderait d'étudier aussi :

```text
coordinator HA
+
workers HA
+
sauvegardes
+
monitoring
```

---

# 33. Limite — contraintes du vrai modèle

La vraie table `fil_rouge_cible.presentation` possède des relations et contraintes supplémentaires.

Une migration réelle vers Citus nécessiterait notamment d'étudier :

- clés primaires ;
- clés étrangères ;
- colocation ;
- tables de référence ;
- jointures distribuées ;
- transactions multi-shards ;
- contraintes uniques ;
- accès applicatifs.

Le POC valide donc le principe technique, pas une migration immédiate du modèle complet.

---

# 34. Impact sur les jointures

Dans une architecture distribuée, les jointures sont critiques.

Des tables distribuées avec des clés compatibles peuvent être colocated.

Des clés incompatibles peuvent provoquer :

```text
transferts réseau
+
plusieurs shards
+
travail du coordinator
```

La clé doit donc être choisie en tenant compte des parcours métier et des jointures.

---

# 35. Impact opérationnel

Citus ajoute de la capacité mais aussi de la complexité.

Il faut gérer :

- coordinator ;
- workers ;
- shards ;
- pannes ;
- sauvegardes ;
- monitoring ;
- mises à jour ;
- migrations ;
- réseau ;
- rééquilibrage éventuel.

---

# 36. Impact coût

Même avec des composants open source, une architecture distribuée consomme davantage :

- CPU ;
- mémoire ;
- stockage ;
- réseau ;
- machines ;
- temps d'administration.

---

# 37. Impact éco-conception

Le fait que Citus fonctionne ne signifie pas qu'il faut le déployer immédiatement.

La stratégie reste :

```text
PostgreSQL simple
        ↓
indexation
        ↓
partitionnement ciblé
        ↓
réplication si besoin HA
        ↓
OLTP / OLAP
        ↓
Citus seulement si le besoin est démontré
```

---

# 38. Comparaison avec les autres solutions de Phase 3

| Solution | Problème principal |
|---|---|
| PostgreSQL optimisé | performance locale |
| Indexation | recherche rapide |
| Partitionnement | très grandes tables / pruning |
| Réplication | haute disponibilité |
| OLTP / OLAP | isolation transactionnel / analytique |
| Citus | distribution horizontale |

Ces solutions ne répondent pas au même problème.

---

# 39. Faits, interprétations et décisions

## Fait mesuré

```text
10 000 000 lignes
32 shards
16 shards par worker
891 MB / 897 MB
```

Interprétation : Citus distribue correctement les données du POC.

Décision : mécanisme de distribution validé.

## Fait mesuré

```text
mandat_id = 42000
Task Count = 1
Execution Time = 1.318 ms
```

Interprétation : `mandat_id` permet un routage direct pour ce type de requête.

Décision : clé pertinente pour ce parcours métier.

## Fait mesuré

```text
bien_id = 500000
Task Count = 32
```

Interprétation : une requête hors clé provoque un scatter-gather.

Décision : la clé doit être évaluée sur l'ensemble des usages.

## Fait mesuré

```text
sans index = 82.851 ms
avec index = 3.709 ms
```

Interprétation : l'index reste très utile dans les shards.

Décision : indexation et sharding doivent être pensés ensemble.

---

# 40. Décision d'architecture

Le POC Citus est :

```text
TECHNIQUEMENT VALIDÉ
```

Mais la décision n'est pas :

```text
CITUS IMMÉDIATEMENT EN PRODUCTION
```

La décision retenue est :

```text
CITUS = CAPACITÉ D'ÉVOLUTION
```

Il devient pertinent lorsque :

- une instance PostgreSQL correctement optimisée devient réellement insuffisante ;
- la charge nécessite plusieurs nœuds ;
- les parcours métier permettent une clé de distribution adaptée ;
- le coût opérationnel supplémentaire est justifié.

---

# 41. Architecture cible recommandée après le POC

À court et moyen terme :

```text
PostgreSQL
+
indexation ciblée
+
partitionnement ciblé
+
réplication pour la HA
+
OLAP séparé
```

À plus grande échelle, si les métriques le nécessitent :

```text
                 Citus Coordinator
                       |
              +--------+--------+
              |                 |
              v                 v
          Worker 1          Worker 2
           shards             shards
```

---

# 42. Critères déclenchant une étude Citus en production

L'adoption de Citus devrait être déclenchée par des mesures réelles, par exemple :

- saturation durable du serveur PostgreSQL ;
- croissance très importante des tables ;
- requêtes trop lentes malgré optimisation ;
- limites raisonnables de la montée verticale atteintes ;
- besoin démontré de distribution horizontale ;
- clé de distribution métier stable.

---

# 43. Synthèse pour un décideur

Le POC montre que Citus fonctionne sur une charge de 10 millions de lignes.

Distribution :

```text
worker1 = 891 MB
worker2 = 897 MB
```

Requête sur la bonne clé :

```text
Task Count = 1
```

Requête hors clé :

```text
Task Count = 32
```

Après ajout d'un index :

```text
82.851 ms
→
3.709 ms
```

soit environ :

```text
22,3× plus rapide
```

Citus constitue donc une technologie crédible pour une croissance future importante.

Mais il ajoute des coûts et de la complexité.

Il reste donc une capacité d'évolution, pas une obligation immédiate.

---

# 44. Synthèse pour un néophyte

Imagine une bibliothèque avec 10 millions de fiches.

Avec un seul serveur :

```text
toutes les fiches
dans une seule bibliothèque
```

Avec Citus :

```text
bibliothèque centrale
        ↓
32 rayons
        ↓
répartis entre
2 bâtiments
```

Si tu connais l'information qui permet de savoir dans quel rayon chercher :

```text
mandat_id
```

tu vas directement au bon rayon :

```text
Task Count = 1
```

Si tu cherches avec une information qui ne permet pas de savoir dans quel rayon regarder :

```text
bien_id
```

tu demandes aux 32 rayons :

```text
Task Count = 32
```

L'index agit comme un catalogue rapide dans chaque rayon.

Il ne réduit pas le nombre de rayons interrogés, mais il accélère fortement la recherche à l'intérieur de chaque rayon.

---

# 45. Chaîne de preuve finale

```text
Citus 14.2 / PostgreSQL 16
        ↓
1 coordinator
        ↓
2 workers
        ↓
10 000 000 lignes
        ↓
32 shards
        ↓
16 shards par worker
        ↓
891 MB / 897 MB
        ↓
distribution physique équilibrée
        ↓
WHERE mandat_id = 42000
        ↓
Task Count = 1
        ↓
routage direct
        ↓
WHERE bien_id = 500000
        ↓
Task Count = 32
        ↓
scatter-gather
        ↓
82.851 ms
        ↓
index sur bien_id
        ↓
Task Count toujours = 32
        ↓
3.709 ms
        ↓
≈ 22,3× plus rapide
        ↓
≈ 95,5 % de temps en moins
```

---

# 46. Conclusion

Le POC Citus / sharding de Match-Immo est validé techniquement.

Il démontre expérimentalement :

- la création d'un cluster distribué ;
- l'utilisation d'un coordinator ;
- deux workers actifs ;
- la distribution de 10 millions de lignes ;
- 32 shards ;
- une répartition équilibrée des shards ;
- une répartition physique équilibrée du stockage ;
- le routage direct via `mandat_id` ;
- le scatter-gather hors clé ;
- la complémentarité entre sharding et indexation ;
- un gain d'environ 22,3× après indexation sur la requête hors clé testée.

La conclusion d'architecture reste volontairement mesurée :

> **Citus fonctionne et constitue une option crédible de scalabilité horizontale, mais il ne doit être introduit en exploitation que lorsque les métriques démontrent qu'un PostgreSQL correctement optimisé, partitionné et dimensionné ne suffit plus.**

La décision finale de la Phase 3 reste donc cohérente avec le principe général :

```text
mesurer
↓
optimiser
↓
partitionner si nécessaire
↓
répliquer pour la disponibilité
↓
distribuer seulement lorsque la croissance le justifie
```
