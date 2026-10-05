# OLTP / OLAP — Qualité et preuves d'exécution

# 45. Mise à jour du 09/09/2026 — Qualité des données analytiques

## 45.1 Pourquoi cette mise à jour ?

Lors de la première rédaction de ce document, les scripts techniques OLAP
étaient présentés comme les prochaines preuves à produire.

Au 09/09/2026, ces éléments existent désormais :

```text
03-architecture/sql/olap-schema.sql
03-architecture/sql/olap-etl.sql
03-architecture/olap-schema.mmd
03-architecture/olap-schema.svg
```

L'alimentation analytique est donc formalisée et les contrôles de qualité
peuvent être rattachés directement au fonctionnement réel de l'ETL.

Cette section ne remplace pas l'état précédent du document.

Elle constitue un repère temporel permettant de tracer l'avancement du projet.

---

## 45.2 Définition de la qualité analytique

La qualité analytique consiste à vérifier que les données utilisées pour les
indicateurs sont suffisamment :

- complètes ;
- cohérentes ;
- non dupliquées ;
- reliées aux bonnes données métier ;
- traçables jusqu'à leur source ;
- exploitables pour les calculs décisionnels.

Une donnée peut être techniquement chargée dans l'OLAP mais rester incorrecte
pour le métier.

Exemple :

```text
vente présente dans FACT_VENTE
+
mauvais chasseur associé
=
donnée techniquement présente
mais indicateur métier faux
```

La qualité doit donc être contrôlée à plusieurs niveaux.

---

## 45.3 Contrôles intégrés dans l'ETL

Le script :

```text
03-architecture/sql/olap-etl.sql
```

intègre déjà plusieurs mécanismes de qualité.

### Contrôle des valeurs nécessaires

Certaines données ne sont chargées que lorsqu'une valeur nécessaire existe.

Exemples présents dans le script :

```sql
WHERE dates.date_complete IS NOT NULL
```

et :

```sql
WHERE b.type_bien IS NOT NULL
```

L'objectif est d'éviter d'introduire dans certaines dimensions des valeurs
inexploitables pour l'analyse.

---

## 45.4 Gestion des doublons

Le script utilise notamment `UNION`.

Contrairement à `UNION ALL`, `UNION` élimine les lignes identiques produites
par les différentes branches d'une requête.

Le chargement utilise également une logique :

```sql
ON CONFLICT (...)
DO UPDATE
```

Lorsqu'une donnée métier déjà connue est rencontrée, ses valeurs analytiques
sont recalculées et mises à jour au lieu de créer systématiquement une nouvelle
ligne.

Cette logique contribue à rendre le chargement rejouable.

---

## 45.5 Contrôle transactionnel

L'ETL fonctionne dans une transaction PostgreSQL.

Le principe est :

```text
BEGIN
↓
transformations et chargements
↓
contrôles techniques
↓
COMMIT
```

Avec une exécution utilisant :

```text
psql -v ON_ERROR_STOP=1
```

une erreur SQL interrompt le traitement avant sa validation définitive.

Cela limite le risque de conserver un chargement partiellement exécuté.

---

## 45.6 Contrôles de volumes après ETL

Après le chargement, le script compte les lignes présentes dans :

```text
dim_temps
dim_chasseur
dim_client
dim_secteur
dim_type_bien
fact_vente
fact_activite_mandat
```

Ces comptages permettent notamment de détecter :

- une table restée vide de manière inattendue ;
- un chargement incomplet ;
- une différence importante de volumétrie entre deux exécutions.

Un comptage ne prouve cependant pas à lui seul la qualité métier.

Il constitue un premier niveau de contrôle.

---

## 45.7 Contrôle métier des ventes

Le script reconstruit une vue lisible des ventes chargées en reliant :

```text
FACT_VENTE
↓
DIM_TEMPS
DIM_CHASSEUR
DIM_SECTEUR
DIM_TYPE_BIEN
```

Il affiche notamment :

- l'identifiant de l'acte source ;
- la date de vente ;
- le chasseur ;
- le secteur ;
- le type de bien ;
- le prix de vente ;
- les honoraires ;
- la commission.

Ce contrôle permet de vérifier humainement qu'une vente analytique reste
compréhensible et cohérente avec son contexte métier.

---

## 45.8 Contrôle métier de l'activité des mandats

Le second contrôle métier porte sur :

```text
FACT_ACTIVITE_MANDAT
```

Il restitue notamment :

- le mandat source ;
- la date de signature ;
- le chasseur ;
- le nombre de présentations ;
- le nombre de visites ;
- le nombre d'offres ;
- l'existence ou non d'une vente.

Ce contrôle permet de vérifier les agrégations utilisées ensuite pour calculer
des indicateurs de performance.

---

## 45.9 Traçabilité avec l'OLTP

Les tables de faits conservent des références vers les objets métier sources,
notamment :

```text
acte_id_source
mandat_id_source
```

Cette traçabilité permet de revenir de l'indicateur analytique vers la donnée
opérationnelle ayant servi à le produire.

La chaîne de preuve devient donc :

```text
donnée OLTP
↓
transformation ETL
↓
donnée OLAP
↓
contrôle
↓
indicateur
```

---

## 45.10 Règles qualité retenues

| Risque qualité | Contrôle retenu | État au 09/09/2026 |
| --- | --- | --- |
| Valeur analytique nécessaire absente | Filtrage des valeurs `NULL` concernées | Implémenté |
| Doublon lors du chargement | `UNION` et gestion `ON CONFLICT` | Implémenté |
| ETL partiellement exécuté | Transaction PostgreSQL + arrêt sur erreur | Implémenté |
| Mauvaise volumétrie après chargement | Comptage des dimensions et faits | Implémenté |
| Vente mal reconstruite | Contrôle métier détaillé de `FACT_VENTE` | Implémenté |
| Activité mandat incohérente | Contrôle métier de `FACT_ACTIVITE_MANDAT` | Implémenté |
| Perte de traçabilité avec la source | Identifiants métier source conservés | Implémenté |
| Donnée personnelle inutile dans l'OLAP | Sélection limitée aux informations utiles aux indicateurs | Prévu dans le modèle |

---

## 45.11 Ce que les contrôles ne démontrent pas encore

Au 09/09/2026, ces contrôles constituent une base technique défendable, mais ils
ne représentent pas encore une chaîne complète de Data Quality industrialisée.

Ne sont notamment pas encore démontrés :

- un tableau de bord automatisé de qualité ;
- des seuils d'alerte de production ;
- une historisation des résultats de contrôle à chaque ETL ;
- une notification automatique lorsqu'un seuil est dépassé ;
- un catalogue de règles de qualité administré ;
- une supervision continue de l'alimentation analytique.

Ces mécanismes pourront être ajoutés lorsque l'exploitation réelle du système
le justifiera.

Le principe reste :

> **contrôler ce qui est utile avant d'ajouter une plateforme de qualité plus
> complexe.**

---

## 45.12 État de la preuve au 09/09/2026

La preuve demandée pour la partie analytique peut désormais être reliée à trois
éléments complémentaires :

```text
SCHÉMA OLAP
→ olap-schema.mmd
→ olap-schema.svg
→ sql/olap-schema.sql

ALIMENTATION
→ sql/olap-etl.sql

QUALITÉ ANALYTIQUE
→ contrôles intégrés dans l'ETL
→ présente section du dossier OLTP / OLAP
```

Ainsi, la qualité analytique n'est pas décrite dans un document isolé et
redondant.

Elle est documentée dans le dossier qui explique déjà le modèle décisionnel et
rattachée au script qui réalise effectivement l'alimentation.

---

## 45.13 Conclusion de la mise à jour

Au 09/09/2026, le bloc OLTP / OLAP dispose désormais :

- d'un modèle décisionnel documenté ;
- d'un schéma logique et SQL ;
- d'un ETL ;
- de mécanismes de prévention de doublons ;
- de contrôles de volumes ;
- de contrôles métier ;
- d'une traçabilité avec les données sources ;
- d'une formalisation explicite de la qualité analytique.

Les travaux futurs concernent principalement l'industrialisation et la
supervision continue, et non la preuve de conception initiale de la chaîne
analytique.

---

# 46. Mise à jour du 09/09/2026 — Preuve d'exécution de l'OLAP

## 46.1 Objet

Cette section complète la preuve de conception et de qualité analytique par une
mesure observée directement dans la base PostgreSQL du projet.

Elle ne remplace pas les sections précédentes.

Elle ajoute une preuve d'exécution datée au 09/09/2026.

---

## 46.2 Présence des tables analytiques

Le schéma PostgreSQL :

```text
match_immo_olap
```

contient les sept tables attendues :

```text
dim_chasseur
dim_client
dim_secteur
dim_temps
dim_type_bien
fact_activite_mandat
fact_vente
```

Le schéma analytique n'est donc pas uniquement défini dans un fichier SQL.

Il est effectivement présent dans la base utilisée pour les travaux du projet.

---

## 46.3 Volumes observés au 09/09/2026

Le contrôle exécuté dans PostgreSQL retourne :

| Table OLAP | Nombre de lignes observé |
| --- | ---: |
| `dim_chasseur` | 6 |
| `dim_client` | 18 |
| `dim_secteur` | 10 |
| `dim_temps` | 18 |
| `dim_type_bien` | 3 |
| `fact_activite_mandat` | 16 |
| `fact_vente` | 2 |

Ces valeurs constituent une observation réelle de l'état de l'OLAP au
09/09/2026.

---

## 46.4 Interprétation

Les dimensions principales sont alimentées :

```text
6 chasseurs
18 clients
10 secteurs
18 dates
3 types de bien
```

La table :

```text
fact_activite_mandat
```

contient :

```text
16 lignes
```

Ce volume est cohérent avec les 16 mandats historiquement migrés dans le modèle
cible.

La table :

```text
fact_vente
```

contient :

```text
2 lignes
```

Cela démontre que le processus analytique est capable de produire des faits de
vente à partir des données présentes dans l'OLTP.

---

## 46.5 Chaîne de preuve

La chaîne analytique peut désormais être représentée ainsi :

```text
modèle OLTP
↓
données métier présentes
↓
ETL
↓
schéma match_immo_olap
↓
dimensions alimentées
↓
tables de faits alimentées
↓
contrôles de volumes
```

La preuve ne repose donc plus uniquement sur :

```text
un schéma
+
un script
```

mais également sur :

```text
des données effectivement chargées
+
des volumes observés
```

---

## 46.6 Limites

Cette preuve confirme l'exécution et l'alimentation de l'OLAP sur le jeu de
données actuel du projet.

Elle ne démontre pas encore :

- une exécution automatisée planifiée ;
- une supervision continue ;
- des alertes de qualité ;
- une historisation automatique des résultats de contrôle ;
- un ETL de production à grande échelle.

Ces éléments relèvent de l'industrialisation future.

---

## 46.7 Conclusion

Au 09/09/2026, le bloc OLTP / OLAP dispose désormais de quatre niveaux de
preuve :

```text
1. conception
2. implémentation SQL
3. contrôles de qualité
4. alimentation réelle observée
```

Les volumes observés dans `match_immo_olap` constituent une preuve technique
supplémentaire que le modèle analytique est non seulement conçu mais également
alimenté dans l'environnement du projet.

---

# 47. Mise à jour du 22/09/2026 — Revalidation du jeu OLTP Phase 3

## 47.1 Objet

Le modèle cible de rémunération a évolué après la création initiale du jeu de
données synthétiques Phase 3.

Le fichier :

```text
03-architecture/sql/oltp-jeu-test.sql
```

a donc été réaligné sur les contraintes actuelles de :

- `ACTE_AUTHENTIQUE` ;
- `COMMISSION`.

Les actes authentiques renseignent désormais le mandat concerné et l'origine de
la vente. Les commissions renseignent notamment la date de calcul et le droit à
rémunération attendu par le schéma courant.

---

## 47.2 Validation sur une base PostgreSQL isolée

Afin de ne pas modifier l'état de la base utilisée par le démonstrateur Phase 4,
le contrôle a été exécuté dans une base temporaire dédiée.

La chaîne rejouée a été :

```text
fixtures/PgSQL.sql
        ↓
02-modele-cible/migration-final.sql
        ↓
02-modele-cible/reprise-donnees-final.sql
        ↓
03-architecture/sql/oltp-jeu-test.sql
```

La reprise a produit les volumes attendus du modèle cible, notamment :

```text
16 demandes
16 affectations
16 versions de demande
16 mandats
2 rejets de mandat
5 corrections de statut
```

Le jeu OLTP Phase 3 corrigé a ensuite été exécuté sans erreur SQL.

---

## 47.3 Résultat observé

Le contrôle final du script a retourné :

| Table | Lignes |
| --- | ---: |
| `bien` | 6 |
| `presentation` | 4 |
| `visite` | 3 |
| `offre` | 3 |
| `acte_authentique` | 2 |
| `honoraires` | 2 |
| `commission` | 2 |

PostgreSQL a confirmé :

```text
NOTICE: Jeu de test Phase 3 créé avec succès.
COMMIT
```

Le script est donc compatible avec le modèle cible de rémunération en vigueur
au 22/09/2026.

La base temporaire utilisée pour cette validation a ensuite été supprimée. Le
jeu Phase 3 n'a pas été injecté dans la base courante de la Phase 4, afin de ne
pas modifier ses résultats de faisabilité et de matching.

---

## 47.4 Portée de la preuve

Cette validation démontre que le jeu synthétique nécessaire à la chaîne
OLTP → ETL → OLAP peut de nouveau être construit sur une base recréée à partir
des scripts versionnés du projet.

Elle ne constitue pas une preuve d'implémentation du moteur complet de
rémunération. Les scénarios de calcul détaillés restent traités séparément dans
le plan de tests comme évolutions futures.

