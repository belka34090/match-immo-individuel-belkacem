# Journal des décisions

Ce document conserve les décisions importantes du projet, leurs
justifications et leurs conséquences.

## ADR-001 --- Utiliser PostgreSQL pour l'audit de l'existant

-   **Date :** 22/08/2026
-   **Phase :** 1 --- Audit de l'existant
-   **Statut :** accepté
-   **Décideur :** Belkacem

### Contexte

Le projet fournit deux versions identiques des données historiques :

-   `fixtures/MySQL.sql` pour MySQL ou MariaDB ;
-   `fixtures/PgSQL.sql` pour PostgreSQL.

Un environnement doit être choisi pour importer les données et réaliser
les contrôles d'audit.

### Options envisagées

1.  Utiliser MySQL ou MariaDB avec `fixtures/MySQL.sql`.
2.  Utiliser PostgreSQL avec `fixtures/PgSQL.sql`.

### Décision

Utiliser PostgreSQL dans l'environnement Docker du projet.

### Justification

-   Une fixture PostgreSQL est fournie dans le starter pack.
-   PostgreSQL permet d'exécuter les contrôles nécessaires à l'audit.
-   Docker fournit un environnement reproductible.
-   Les requêtes d'audit sont compatibles avec le schéma PostgreSQL
    fourni.

### Conséquences

-   La base historique est importée depuis `fixtures/PgSQL.sql`.
-   Les contrôles sont exécutés sur le schéma `"Fil_Rouge_Depart"`.
-   Les fixtures originales sont conservées sans modification.
-   Les décisions concernant le modèle cible seront ajoutées lors de la
    phase 2.

### Décisions associées à l'audit de l'existant

#### Distinguer anomalies de données et risques structurels

Les anomalies réellement observées dans les données sont distinguées des
risques rendus possibles par la structure du schéma.

Cette séparation évite de présenter comme anomalie avérée un problème qui
n'est encore qu'un risque de conception.

#### Conserver la Phase 1 centrée sur l'existant

La cartographie et l'audit de la Phase 1 représentent uniquement le système
hérité.

Les futures tables, règles et solutions du modèle cible ne sont pas introduites
dans cette représentation afin de ne pas mélanger l'existant et la cible.

#### Utiliser le 25/07/2026 comme date de référence métier

Les contrôles temporels de l'audit utilisent le 25 juillet 2026 comme date de
référence métier, conformément aux données et au contexte fournis par le
projet.

Cette date sert notamment à interpréter la validité des mandats.

------------------------------------------------------------------------

## ADR-002 --- Séparer l'utilisateur de ses rôles métier

-   **Date de formalisation :** 05/09/2026
-   **Phase :** 2 --- Modèle cible
-   **Statut :** accepté
-   **Décideur :** Belkacem

### Contexte

Dans les données historiques, un utilisateur peut être référencé avec un
rôle métier incohérent. L'audit a notamment identifié un mandat dont le
client référencé est en réalité un chasseur.

### Décision

Créer une entité centrale `UTILISATEUR`, puis distinguer les rôles
`CLIENT` et `CHASSEUR`.

### Pourquoi

Cette séparation évite de confondre l'identité d'une personne avec son
rôle dans le processus métier et facilite les contrôles de cohérence.

### Conséquences

-   `CLIENT` et `CHASSEUR` sont rattachés à `UTILISATEUR`.
-   Les règles métier doivent empêcher les affectations incohérentes.
-   L'anomalie historique détectée n'est pas reproduite dans la cible.

### Preuves

-   `01-audit/registre-anomalies.md`
-   `02-modele-cible/mcd-cible-final-propre.drawio.png`
-   `02-modele-cible/mld-cible-final.md`

------------------------------------------------------------------------

## ADR-003 --- Historiser les critères d'une demande

-   **Date de formalisation :** 05/09/2026
-   **Phase :** 2 --- Modèle cible
-   **Statut :** accepté
-   **Décideur :** Belkacem

### Contexte

Les critères de recherche d'un client peuvent évoluer pendant
l'accompagnement. Écraser les anciennes valeurs ferait perdre
l'historique des besoins.

### Décision

Séparer `DEMANDE` et `VERSION_DEMANDE`. Une demande possède plusieurs
versions et une seule version peut être courante à un instant donné.

### Pourquoi

Le modèle conserve ainsi les modifications successives des critères et
permet de savoir qui a effectué une modification.

### Conséquences

-   Les anciennes versions ne sont pas écrasées.
-   Chaque version possède un numéro et un auteur.
-   Les secteurs recherchés sont rattachés aux versions de demande.

### Preuves

-   `02-modele-cible/besoins-metier-final.md`
-   `02-modele-cible/mcd-cible-final-propre.drawio.png`
-   `02-modele-cible/mld-cible-final.md`

------------------------------------------------------------------------

## ADR-004 --- Faire précéder le mandat par la demande

-   **Date de formalisation :** 05/09/2026
-   **Phase :** 2 --- Modèle cible
-   **Statut :** accepté
-   **Décideur :** Belkacem

### Contexte

Le parcours métier commence par une demande de recherche. Un chasseur
peut ensuite être affecté et la relation peut aboutir à un mandat. Une
demande ne doit donc pas être créée artificiellement après le mandat.

### Décision

Le modèle cible suit l'ordre métier `DEMANDE → AFFECTATION → MANDAT`.

### Pourquoi

Cette organisation représente le parcours réel et permet aussi de
conserver une demande qui n'aboutit pas à un mandat.

### Conséquences

-   `MANDAT` référence la demande dont il est issu.
-   L'affectation du chasseur est tracée avant la signature éventuelle.
-   La migration reconstruit les demandes nécessaires avant de charger
    les mandats historiques.

### Preuves

-   `02-modele-cible/besoins-metier-final.md`
-   `02-modele-cible/mld-cible-final.md`
-   `02-modele-cible/reprise-donnees-final.sql`

------------------------------------------------------------------------

## ADR-005 --- Utiliser le secteur comme référence géographique commune

-   **Date de formalisation :** 05/09/2026
-   **Phase :** 2 --- Modèle cible
-   **Statut :** accepté
-   **Décideur :** Belkacem

### Contexte

Les critères de recherche et les biens doivent pouvoir être comparés sur
une même référence géographique.

### Décision

Utiliser `SECTEUR` pour les zones recherchées et pour localiser les
biens.

### Pourquoi

Une référence commune simplifie les contrôles et prépare le futur
matching entre les critères d'une demande et les caractéristiques d'un
bien.

### Conséquences

-   Une version de demande peut cibler plusieurs secteurs.
-   Un bien est localisé dans un secteur.
-   La comparaison géographique ne repose pas uniquement sur du texte
    libre.

### Preuves

-   `02-modele-cible/mcd-cible-final-propre.drawio.png`
-   `02-modele-cible/mld-cible-final.md`

------------------------------------------------------------------------

## ADR-006 --- Migrer sans inventer les données absentes

-   **Date de formalisation :** 05/09/2026
-   **Phase :** 2 --- Migration et reprise
-   **Statut :** accepté
-   **Décideur :** Belkacem

### Contexte

Le modèle cible contient davantage d'informations que la base
historique. Certaines données nécessaires à la cible n'existent donc pas
dans la source.

L'audit a également identifié des anomalies : 18 mandats existent dans
la source. Deux sont rejetés lors de la reprise. Parmi les six mandats
actifs dont la durée théorique de six mois est dépassée, cinq peuvent
être corrigés en `expire` ; le sixième correspond au mandat rejeté pour
incohérence chronologique.

### Décision

Migrer uniquement les données fiables ou déterministes, tracer les
rejets et corrections, et laisser vides les informations sans équivalent
source plutôt que d'inventer un historique.

### Pourquoi

La migration doit préserver la traçabilité et la qualité des données.
Une valeur inventée donnerait une fausse information métier.

### Conséquences

-   18 mandats source sont contrôlés.
-   2 mandats sont rejetés avec motif.
-   16 mandats sont migrés.
-   5 statuts sont corrigés parmi les données migrées.
-   Les tables métier sans données historiques restent vides.
-   Les rejets, corrections et hypothèses sont conservés dans le schéma
    de contrôle de reprise.

### Preuves

-   `01-audit/registre-anomalies.md`
-   `02-modele-cible/reprise-donnees-final.sql`
-   `02-modele-cible/reprise-donnees-validation.md`

------------------------------------------------------------------------

## ADR-007 --- Utiliser le Gantt et l'auto-évaluation comme outils de pilotage vivants

-   **Date :** 05/09/2026
-   **Phase :** Pilotage transversal
-   **Statut :** accepté
-   **Décideur :** Belkacem

### Contexte

Le projet se déroule sur plusieurs phases jusqu'au rendu final. Un
planning ou une auto-évaluation remplis uniquement à la fin ne
montreraient pas l'évolution réelle du projet.

### Décision

Maintenir le Gantt et l'auto-évaluation au fil du projet et tracer les
évolutions importantes dans ce journal.

### Pourquoi

Cela permet de montrer simplement ce qui était prévu, ce qui a été
réalisé, ce qui reste à faire et pourquoi une compétence change de
niveau.

### Conséquences

-   Le Gantt est mis à jour aux jalons importants.
-   `auto-evaluation-MAJ-2026-09-05.md` représente l'état courant des compétences.
-   Le présent journal conserve les changements significatifs.
-   Git fournit l'historique technique des modifications.

### Preuves

-   `planning-projet_chasse_immo.gan`
-   `auto-evaluation-MAJ-2026-09-05.md`
-   `decisions/journal-decisions-MAJ-2026-09-05.md`

------------------------------------------------------------------------

## Suivi de l'auto-évaluation

Cette section trace uniquement les changements de niveau significatifs.\
`NA` = non abordé · `EC` = en cours · `A` = acquis avec preuve produite
et défendable.


  -------------------------------------------------------------------------------------------------------------------------------
  Date         Bloc         Compétence        Évolution   Pourquoi            Preuve
  ------------ ------------ ----------------- ----------- ------------------- ---------------------------------------------------
  05/09/2026   BC01         Cartographier le  EC → **A**  L'audit de          `01-audit/`
                            SI et analyser                l'existant est      
                            les risques                   terminé, les        
                                                          anomalies sont      
                                                          tracées et les      
                                                          preuves sont        
                                                          disponibles.        

  05/09/2026   BC02         Planifier le      EC → **A**  Le Gantt couvre le  `planning-projet_chasse_immo.gan`
                            projet                        projet jusqu'au     
                                                          rendu final et      
                                                          comporte jalons et  
                                                          dépendances.        

  05/09/2026   BC05         Extraction,       NA → **EC** La reprise a été    `02-modele-cible/reprise-donnees-final.sql` +
                            transformation,               exécutée et         preuve de reprise
                            chargement,                   contrôlée, mais     
                            qualité et RGPD               OLAP, qualité       
                                                          consolidée et RGPD  
                                                          restent incomplets. 

  05/09/2026   BC05         Concevoir la base NA → **EC** MCD, MLD et         `02-modele-cible/`
                            pour                          migration sont      
                            analytique/IA                 réalisés ; la       
                                                          preuve d'indexation 
                                                          reste à produire.   

  05/09/2026   BC01         Élaborer la       NA → **EC** Les besoins, règles `02-modele-cible/`
                            stratégie SI                  et cible sont       
                                                          structurés ; la     
                                                          note stratégique    
                                                          dédiée reste à      
                                                          finaliser.          

  05/09/2026   BC02         CDC technique     NA → **EC** Le CDCT est produit `02-modele-cible/cahier-des-charges-technique-MAJ.md`
                            (RGPD + PSH)                  ; le registre RGPD  
                                                          et la note PSH      
                                                          restent à           
                                                          compléter.          

  05/09/2026   BC02         Modéliser les     NA → **EC** Le processus est    `02-modele-cible/`
                            processus métier              défini dans les     
                                                          règles et le modèle 
                                                          cible ; le BPMN     
                                                          reste à produire.   

  05/09/2026   BC02         Note de cadrage   NA → **EC** Un document existe  `02-modele-cible/note-cadrage.md`
                                                          mais doit encore    
                                                          être                
                                                          contrôlé/finalisé   
                                                          avant passage à A.  

  05/09/2026   BC03         Schématiser les   NA → **EC** Le processus est    `02-modele-cible/`
                            processus métier              structuré           
                                                          conceptuellement ;  
                                                          le schéma de        
                                                          processus reste à   
                                                          produire.           

  05/09/2026   BC03         Scénarios de      NA → **EC** Des contrôles SQL   preuves SQL de migration/reprise
                            tests exécutés                et validations de   
                                                          reprise existent ;  
                                                          le plan de tests    
                                                          applicatif reste à  
                                                          produire.           

  05/09/2026   Transverse   RGPD              NA → **EC** Les enjeux RGPD     CDCT + travaux de conception
                                                          sont intégrés à la  
                                                          conception mais le  
                                                          registre finalisé   
                                                          reste à produire.   
  05/09/2026   BC02         Étude             NA → **A**  Aucun document      `02-modele-cible/etude-opportunite.md`
                            d'opportunité                   dédié n'existait ;   commit `19f674e`
                                                            l'étude a été
                                                            produite et
                                                            contrôlée. Elle
                                                            formalise le
                                                            contexte, les
                                                            problèmes,
                                                            l'opportunité, les
                                                            bénéfices, les
                                                            risques, la
                                                            recommandation et
                                                            les critères de
                                                            réussite.


  05/09/2026   BC02         Prioriser les      NA → **A**  Aucun backlog       `02-modele-cible/backlog-priorise.md`
                            fonctionnalités                  priorisé n'était     commit `7380d91`
                                                            encore produit.
                                                            Les fonctionnalités
                                                            ont été classées
                                                            avec la méthode
                                                            MoSCoW afin de
                                                            distinguer le socle
                                                            indispensable, les
                                                            fonctions importantes,
                                                            les fonctions
                                                            optionnelles et celles
                                                            repoussées. Le backlog
                                                            a été produit,
                                                            contrôlé et validé.


  05/09/2026   BC02         Modéliser les      EC → **A** Le parcours métier   `02-modele-cible/processus-metier.bpmn`
                            processus métier                 était déjà décrit    + `02-modele-cible/processus-metier.png`
                                                             dans les besoins,    commit `5752e97`
                                                             règles de gestion
                                                             et modèle cible,
                                                             mais la preuve BPMN
                                                             demandée n'était
                                                             pas encore produite.
                                                             Le processus a été
                                                             formalisé, contrôlé
                                                             dans Camunda et
                                                             exporté en PNG.

  05/09/2026   BC03         Schématiser les     EC → **A** Le schéma de         `02-modele-cible/processus-metier.bpmn`
                            processus métier                 processus attendu     + `02-modele-cible/processus-metier.png`
                                                             comme preuve n'était  commit `5752e97`
                                                             pas disponible.
                                                             Le BPMN complet
                                                             représente maintenant
                                                             le parcours métier
                                                             cible et ses
                                                             principaux acteurs.


  05/09/2026   BC02         Engagement des     NA → **EC** Aucun RACI adapté    `02-modele-cible/RACI.md`
                            parties prenantes                au projet solo        commit `54cd765`
                                                             n'était disponible.
                                                             La matrice RACI
                                                             formalise désormais
                                                             les responsabilités
                                                             du porteur du projet,
                                                             de l'encadrement et
                                                             du jury. Des traces
                                                             réelles d'échanges
                                                             ou de validations
                                                             restent à consolider
                                                             avant un passage à A.

  -------------------------------------------------------------------------------------------------------------------------------

### Règle de mise à jour

À chaque livrable important :

1.  vérifier le livrable et sa preuve ;
2.  mettre à jour le Gantt si l'avancement ou le planning change ;
3.  mettre à jour `auto-evaluation-MAJ-2026-09-05.md` si une compétence change de
    niveau ;
4.  ajouter ici une ligne uniquement lorsqu'un changement de niveau a
    réellement lieu ;
5.  enregistrer les modifications dans Git.

L'objectif est de conserver un historique compréhensible par le porteur
du projet, le formateur, le jury et toute personne qui reprend le
dossier.

---

## ADR-008 — Consolidation du cadrage, de la traçabilité et de l'auto-évaluation

**Date :** 06/09/2026

### Contexte

La Phase 2 disposait déjà de plusieurs livrables validés : étude d'opportunité, backlog priorisé, BPMN, RACI, registre RGPD et note d'éco-conception.

Cependant, trois points restaient à consolider :

- la note de cadrage était encore trop courte par rapport au modèle attendu ;
- la traçabilité détaillée entre compétences RNCP et preuves du projet n'était pas encore formalisée ;
- l'auto-évaluation contenait plusieurs statuts et chemins devenus obsolètes.

### Décision

La note de cadrage a été complétée pour couvrir explicitement :

- le contexte ;
- les objectifs ;
- le périmètre et le hors-périmètre ;
- les livrables ;
- les parties prenantes ;
- le planning et les jalons ;
- les ressources ;
- les risques ;
- les critères de réussite.

Une matrice dédiée de traçabilité des compétences a également été produite :

`02-modele-cible/TRACABILITE-COMPETENCES.md`

Elle relie les compétences BC05, BC01, BC02 et BC03 aux preuves réellement présentes dans le dépôt et distingue clairement :

- les compétences démontrées ;
- les compétences partiellement démontrées ;
- les compétences encore à produire.

L'auto-évaluation a ensuite été mise à jour au 06/09/2026.

### Justification

Le projet doit rester défendable devant le formateur et le jury.

Une compétence ne doit pas être déclarée acquise uniquement parce qu'un travail proche existe : une preuve identifiable et suffisamment complète doit pouvoir être présentée.

La mise à jour permet donc d'éviter :

- les chemins de fichiers obsolètes ;
- les compétences surévaluées ;
- les preuves annoncées mais absentes ;
- les incohérences entre les différents documents de pilotage.

### Résultat

Les évolutions principales de l'auto-évaluation sont :

- BC02 — Note de cadrage : `EC` → `A` ;
- transverse RGPD : `EC` → `A` ;
- transverse Éco-conception : `NA` → `A` ;
- BC01 — solutions écoresponsables : `NA` → `EC` ;
- BC03 — environnement et réduction d'impact : `NA` → `EC`.

Les éléments suivants restent volontairement incomplets tant que leurs preuves ne sont pas produites :

- accessibilité PSH ;
- architecture cible ;
- dimensionnement 3V ;
- OLAP ;
- indexation avec `EXPLAIN` ;
- PCA/PRA ;
- matching IA ;
- souveraineté et sécurité IA ;
- développement applicatif ;
- tests applicatifs et CI.

La synthèse de l'auto-évaluation passe à :

- 9 compétences/exigences acquises ;
- 8 en cours ;
- 13 non abordées.

### Preuves

- `02-modele-cible/note-cadrage.md`
- `02-modele-cible/TRACABILITE-COMPETENCES.md`
- `02-modele-cible/registre-rgpd.md`
- `02-modele-cible/note-eco-conception.md`
- `auto-evaluation-MAJ-2026-09-05.md`

------------------------------------------------------------------------

## ADR-009 — Retenir PostgreSQL comme SGBD transactionnel cible

-   **Phase :** 2 — Modèle cible
-   **Statut :** accepté
-   **Décideur :** Belkacem
-   **Origine :** consolidation de l'ancienne décision `DEC-006`

### Contexte

Le modèle cible comporte de nombreuses relations et doit garantir
l'intégrité de données métier importantes : clients, chasseurs, mandats,
demandes historisées, biens, offres, ventes, honoraires, commissions et
paiements.

Le SGBD retenu doit donc être adapté à un modèle fortement relationnel et
permettre d'appliquer des contraintes d'intégrité fiables.

### Options envisagées

1. **PostgreSQL**
   - SGBD relationnel ;
   - clés étrangères, contraintes `UNIQUE`, `CHECK` et `NOT NULL` ;
   - transactions ACID ;
   - adapté à un modèle fortement structuré ;
   - continuité avec la fixture PostgreSQL déjà utilisée pendant l'audit.

2. **MySQL / MariaDB**
   - solution relationnelle techniquement viable ;
   - aucun avantage déterminant identifié dans ce projet par rapport à
     PostgreSQL.

3. **Base NoSQL documentaire**
   - intéressante pour des données peu structurées ;
   - moins adaptée ici aux nombreuses relations et contraintes
     d'intégrité du modèle métier.

### Décision

PostgreSQL est retenu comme SGBD transactionnel du modèle cible.

### Justification

Le MLD est fortement relationnel et repose sur de nombreuses relations,
contraintes d'unicité et règles d'intégrité.

Les opérations liées notamment aux mandats, ventes, honoraires,
commissions et paiements nécessitent également des garanties
transactionnelles fortes.

MySQL / MariaDB reste une alternative techniquement possible, mais ne
présente pas d'avantage suffisant pour justifier un changement dans le
contexte du projet.

Une base NoSQL documentaire n'est pas retenue car elle ne correspond pas
au besoin transactionnel et relationnel principal de cette phase.

### Conséquences

-   `02-modele-cible/migration-final.sql` cible PostgreSQL ;
-   les types et contraintes du modèle cible suivent les capacités de
    PostgreSQL ;
-   `02-modele-cible/reprise-donnees-final.sql` charge le nouveau schéma
    PostgreSQL ;
-   les problématiques de croissance, OLAP, réplication, partitionnement
    et distribution sont traitées séparément en Phase 3.

### Preuves

-   `02-modele-cible/mld-cible-final.md`
-   `02-modele-cible/migration-final.sql`
-   `02-modele-cible/reprise-donnees-final.sql`
-   `03-architecture/dossier-architecture-de-croissance.md`

------------------------------------------------------------------------

## ADR-010 — Faire évoluer l'architecture progressivement selon les mesures

- **Date :** 09/09/2026
- **Phase :** 3 — Absorber la croissance
- **Statut :** accepté
- **Décideur :** Belkacem

### Contexte

La Phase 3 doit déterminer comment Match-Immo peut absorber une croissance
importante des volumes sans introduire une architecture inutilement complexe.

Plusieurs solutions ont été étudiées :

1. PostgreSQL optimisé ;
2. indexation ;
3. partitionnement ;
4. réplication ;
5. séparation OLTP / OLAP ;
6. distribution avec Citus.

Une architecture distribuée peut permettre de répartir les données et la
charge, mais elle augmente également :

- la complexité d'exploitation ;
- les besoins de supervision ;
- les opérations de maintenance ;
- les contraintes de déploiement ;
- les compétences nécessaires pour exploiter le système.

La décision devait donc être fondée sur des mesures et non sur la seule
possibilité technique d'utiliser une technologie plus avancée.

### Options étudiées

#### Option 1 — Déployer directement une architecture distribuée

Cette option consiste à introduire Citus ou une architecture équivalente dès
la première version cible.

Avantage :

- capacité potentielle à répartir les données sur plusieurs nœuds.

Inconvénients :

- complexité plus élevée ;
- exploitation distribuée à maintenir ;
- coût technique supérieur ;
- absence de preuve que les volumes actuels nécessitent déjà cette solution.

#### Option 2 — Rester sur PostgreSQL sans stratégie d'évolution

Cette option minimise la complexité immédiate mais ne définit pas comment
réagir lorsque les volumes et la charge augmenteront.

Elle ne permet donc pas de répondre suffisamment au besoin de croissance.

#### Option 3 — Architecture progressive pilotée par les mesures

Cette option conserve PostgreSQL comme socle et introduit les mécanismes de
croissance dans un ordre progressif :

```text
PostgreSQL optimisé
↓
mesure avec EXPLAIN ANALYZE
↓
indexation ciblée
↓
partitionnement lorsque les volumes et les accès le justifient
↓
réplication lorsque le besoin de disponibilité le justifie
↓
distribution avec Citus uniquement si les limites du socle sont démontrées
```

### Décision

L'option 3 est retenue.

Match-Immo adopte une stratégie d'architecture progressive fondée sur le
principe :

> **Mesurer avant de complexifier.**

Citus n'est donc pas retenu comme composant obligatoire de l'architecture
actuelle.

Il reste une option d'évolution documentée et testée pour une situation future
où les limites d'une architecture PostgreSQL non distribuée seraient
effectivement démontrées.

### Justification par les mesures

Les POC de Phase 3 ont montré que des optimisations plus simples produisent déjà
des gains importants.

#### Indexation

Sur 1 000 000 de lignes :

```text
avant index
≈ 11,438 ms

après index
≈ 2,641 ms

gain
≈ 4,3 ×
```

#### Partitionnement

Sur 10 000 000 de lignes :

```text
table non partitionnée
≈ 130,166 ms

table partitionnée
≈ 25,008 ms

gain
≈ 5,2 ×
```

#### Citus

Le POC Citus a démontré qu'une table de 10 000 000 de lignes peut être
distribuée sur plusieurs workers.

Il a également montré qu'une architecture distribuée n'élimine pas les besoins
d'optimisation locale des requêtes et des index.

Citus constitue donc une preuve de capacité d'évolution, mais pas une
justification pour distribuer immédiatement le système.

### Conséquences

À court terme :

- PostgreSQL reste le socle principal ;
- les index sont utilisés de manière ciblée ;
- le partitionnement est appliqué uniquement lorsque le profil de données et
  les requêtes le justifient ;
- la réplication répond au besoin de disponibilité, pas à un besoin de
  distribution des données ;
- Citus n'est pas imposé à l'architecture actuelle.

À plus long terme :

- les volumes réels devront continuer à être mesurés ;
- les temps de réponse devront être surveillés ;
- les limites verticales et horizontales devront être identifiées ;
- Citus pourra être réévalué si les mesures montrent que PostgreSQL optimisé,
  indexé et éventuellement partitionné ne suffit plus.

### Alternatives rejetées

**Citus immédiatement**

Rejeté comme architecture obligatoire actuelle car aucune mesure du projet ne
démontre encore la nécessité de distribuer la base en production.

**PostgreSQL sans stratégie d'évolution**

Rejeté car la Phase 3 doit précisément prévoir la capacité du SI à absorber la
croissance.

### Preuves

- `03-architecture/note-dimensionnement-3v.md`
- `03-architecture/dossier-architecture-de-croissance.md`
- `03-architecture/matrice-décision-architecture.md`
- `03-architecture/benchmark-indexation.md`
- `03-architecture/benchmark-partitionnement.md`
- `03-architecture/benchmark-replication-ha.md`
- `03-architecture/poc-citus/benchmark-citus-sharding.md`

------------------------------------------------------------------------

## ADR-011 — Séparer les usages transactionnels OLTP et analytiques OLAP

- **Date :** 09/09/2026
- **Phase :** 3 — Absorber la croissance
- **Statut :** accepté
- **Décideur :** Belkacem

### Contexte

Le système Match-Immo doit servir deux usages différents.

Le premier est transactionnel :

```text
création et modification
des clients
des demandes
des mandats
des biens
des visites
des offres
des ventes
des paiements
```

Cet usage correspond à l'OLTP.

OLTP signifie :

```text
Online Transaction Processing
```

Il sert aux opérations métier courantes et nécessite notamment :

- des écritures fiables ;
- des contraintes d'intégrité ;
- des transactions ;
- des réponses rapides sur des volumes ciblés.

Le second usage est analytique :

```text
mesurer
agréger
comparer
produire des indicateurs
aider à la décision
```

Cet usage correspond à l'OLAP.

OLAP signifie :

```text
Online Analytical Processing
```

Les requêtes analytiques peuvent parcourir beaucoup plus de lignes et effectuer
des agrégations importantes.

Exécuter ces deux types de charge uniquement sur le modèle transactionnel
risquerait à terme de mettre en concurrence :

```text
activité métier
+
requêtes analytiques lourdes
```

### Options étudiées

#### Option 1 — Utiliser uniquement la base OLTP

Les indicateurs seraient calculés directement sur le modèle transactionnel.

Avantages :

- architecture simple ;
- aucune copie analytique à alimenter ;
- moins de composants.

Limites :

- requêtes analytiques potentiellement coûteuses sur la base métier ;
- modèle transactionnel moins pratique pour les analyses ;
- couplage entre activité opérationnelle et décisionnel ;
- risque de dégrader les performances de production lorsque les volumes
  augmentent.

#### Option 2 — Séparer OLTP et OLAP

Le modèle transactionnel reste optimisé pour les opérations métier.

Un modèle analytique distinct reçoit les données nécessaires via un ETL.

Le principe devient :

```text
PostgreSQL OLTP
↓
ETL
↓
PostgreSQL OLAP
↓
indicateurs
↓
aide à la décision
```

### Décision

L'option 2 est retenue.

Match-Immo sépare les usages transactionnels et analytiques.

Le système conserve :

```text
fil_rouge_cible
→ modèle transactionnel OLTP
```

et utilise :

```text
match_immo_olap
→ modèle analytique OLAP
```

L'alimentation est réalisée par :

```text
03-architecture/sql/olap-etl.sql
```

### Modèle analytique retenu

Le modèle OLAP utilise notamment les dimensions :

```text
DIM_TEMPS
DIM_CHASSEUR
DIM_CLIENT
DIM_SECTEUR
DIM_TYPE_BIEN
```

et les tables de faits :

```text
FACT_VENTE
FACT_ACTIVITE_MANDAT
```

Ce modèle permet de préparer des indicateurs sans reproduire l'ensemble du
modèle transactionnel.

### Justification

La séparation permet de distinguer clairement :

```text
OLTP
→ faire fonctionner le métier

OLAP
→ analyser le fonctionnement du métier
```

Elle réduit le couplage entre les traitements opérationnels et les analyses.

Elle permet également d'adapter séparément :

- les structures de données ;
- les index ;
- les fréquences de chargement ;
- les contrôles de qualité ;
- les futures politiques de performance et de disponibilité.

### Preuve d'implémentation

Au 09/09/2026, le schéma :

```text
match_immo_olap
```

est effectivement présent dans PostgreSQL.

Les volumes observés sont :

| Table OLAP | Lignes observées |
| --- | ---: |
| `dim_chasseur` | 6 |
| `dim_client` | 18 |
| `dim_secteur` | 10 |
| `dim_temps` | 18 |
| `dim_type_bien` | 3 |
| `fact_activite_mandat` | 16 |
| `fact_vente` | 2 |

La décision n'est donc pas uniquement théorique.

Le modèle analytique est :

```text
conçu
+
implémenté
+
alimenté
```

dans l'environnement du projet.

### Qualité des données

L'ETL comprend notamment :

- des filtres sur certaines valeurs nécessaires ;
- une gestion de conflits lors du chargement ;
- des contrôles de volumes ;
- des contrôles métier ;
- la conservation d'identifiants source permettant la traçabilité.

La supervision continue et les alertes de Data Quality restent des travaux
d'industrialisation futurs.

### Conséquences

Le modèle OLTP reste la référence pour les opérations métier.

Le modèle OLAP devient la base destinée :

- aux indicateurs ;
- aux agrégations ;
- à l'aide à la décision ;
- aux futurs usages analytiques.

L'ETL devient le mécanisme de passage entre les deux modèles.

Cette séparation introduit cependant de nouvelles responsabilités :

- exécuter l'ETL ;
- contrôler son résultat ;
- gérer la fraîcheur des données analytiques ;
- surveiller les erreurs de chargement ;
- définir ultérieurement une fréquence adaptée à l'exploitation réelle.

### Alternative rejetée

**Calculer tous les indicateurs directement sur l'OLTP**

Cette solution reste techniquement possible pour de petits volumes.

Elle n'est pas retenue comme architecture cible car elle mélange les charges
transactionnelles et analytiques et réduit la capacité à faire évoluer
séparément ces deux usages.

### Preuves

- `03-architecture/oltp-olap-modele-decisionnel.md`
- `03-architecture/olap-schema.mmd`
- `03-architecture/olap-schema.svg`
- `03-architecture/sql/olap-schema.sql`
- `03-architecture/sql/olap-etl.sql`

------------------------------------------------------------------------

## ADR-012 — Combiner réplication, sauvegarde externalisée et PRA distant

- **Date :** 09/09/2026
- **Phase :** 3 — Absorber la croissance
- **Statut :** accepté
- **Décideur :** Belkacem

### Contexte

La disponibilité d'une base PostgreSQL ne peut pas reposer sur un seul
mécanisme.

Trois problèmes différents doivent être distingués :

```text
panne du primaire
→ besoin de continuité

suppression ou corruption logique
→ besoin de sauvegarde

perte complète du site
→ besoin de reprise sur un environnement indépendant
```

Une réplication seule ne protège pas contre tous ces scénarios.

Par exemple, une suppression accidentelle peut être répliquée vers le replica.

La Phase 3 devait donc définir une stratégie combinant :

- continuité ;
- sauvegarde ;
- restauration ;
- reprise distante.

### Options étudiées

#### Option 1 — Réplication seule

Avantage :

- permet une reprise rapide lorsqu'une instance primaire tombe.

Limites :

- ne remplace pas une sauvegarde ;
- une corruption logique peut être propagée ;
- ne protège pas à elle seule contre la perte complète du site ;
- une réplication asynchrone peut présenter un décalage au moment d'une panne.

#### Option 2 — Sauvegarde seule

Avantage :

- permet de restaurer un état indépendant de la base active.

Limites :

- pas de continuité immédiate lors de la panne du primaire ;
- temps de restauration nécessaire ;
- indisponibilité plus importante.

#### Option 3 — Combiner réplication, sauvegarde et PRA distant

Le principe devient :

```text
réplication
→ continuité face à la panne d'instance

sauvegarde externalisée
→ protection indépendante des données actives

restauration locale
→ preuve de restaurabilité

restauration distante
→ reprise en cas de perte du site principal
```

### Décision

L'option 3 est retenue.

La stratégie de continuité et de reprise de Match-Immo repose sur des mécanismes
complémentaires et non sur une technologie unique.

La réplication PostgreSQL répond principalement au besoin de disponibilité.

La sauvegarde répond au besoin de restauration d'un état indépendant.

Le PRA distant répond au scénario de perte du site principal.

### Preuves obtenues

#### Haute disponibilité

Le POC PostgreSQL a été réalisé avec :

```text
10 000 000 de lignes
```

Les essais ont démontré notamment :

- présence d'un primaire et d'un replica ;
- réplication en mode asynchrone ;
- état `streaming` ;
- retard WAL observé à 0 byte après synchronisation ;
- suppression volontaire du primaire ;
- promotion automatique d'une autre instance ;
- conservation des données ;
- nouvelle écriture après failover ;
- réplication de cette nouvelle écriture.

Le volume final observé après le test est :

```text
10 000 001 lignes
```

#### Sauvegarde et restauration

Le POC PRA a démontré :

- création d'une sauvegarde ;
- contrôle de son empreinte ;
- restauration dans une base locale distincte ;
- contrôle du nombre de lignes ;
- contrôle d'intégrité ;
- externalisation de la sauvegarde ;
- récupération de cette sauvegarde depuis un site distant ;
- restauration sur un environnement indépendant ;
- écriture réussie après reprise.

### Limites explicitement conservées

Les POC ne permettent pas de déclarer toutes les cibles d'exploitation comme
déjà atteintes.

#### RPO

RPO signifie :

```text
Recovery Point Objective
```

Il représente la quantité maximale de données que l'organisation accepte de
perdre après un incident.

La cible retenue est :

```text
RPO ≈ 1 heure
```

Cette valeur reste une cible d'architecture.

Une chaîne automatisée produisant et validant réellement un point restaurable
chaque heure n'a pas encore été démontrée.

#### RTO

RTO signifie :

```text
Recovery Time Objective
```

Il représente le délai maximal visé pour remettre le service en fonctionnement.

La cible retenue pour un sinistre majeur est :

```text
RTO ≤ 4 heures
```

Les temps mesurés pendant les POC démontrent des opérations partielles de
restauration, mais ils ne constituent pas encore un RTO complet mesuré de bout
en bout.

### Conséquences

La cible d'exploitation devra distinguer clairement :

```text
réplication
≠
sauvegarde
```

et :

```text
failover
≠
PRA complet
```

La production devra notamment prévoir :

- des nœuds réellement séparés physiquement lorsque nécessaire ;
- une stratégie de sauvegarde adaptée à PostgreSQL ;
- une externalisation des sauvegardes ;
- des tests périodiques de restauration ;
- une supervision du lag de réplication ;
- une mesure réelle du RPO ;
- une mesure end-to-end du RTO ;
- des procédures de reprise documentées.

### Alternatives rejetées

**Répliquer uniquement la base**

Rejeté car la réplication ne protège pas suffisamment contre la corruption
logique, la suppression accidentelle ou la perte complète du site.

**Conserver uniquement des sauvegardes**

Rejeté car une sauvegarde ne permet pas à elle seule de maintenir rapidement
le service lors d'une simple panne du primaire.

### Preuves

- `03-architecture/benchmark-replication-ha.md`
- `03-architecture/pca-pra-complet-maj.md`
- `03-architecture/matrice-risques.md`
- `02-modele-cible/note-eco-conception.md`

------------------------------------------------------------------------

## ADR-013 — Retenir un Big Bang contrôlé pour la migration du périmètre actuel

- **Date :** 09/09/2026
- **Phase :** 3 — Absorber la croissance
- **Statut :** accepté
- **Décideur :** Belkacem

### Contexte

La Phase 2 a permis de construire et tester :

- le modèle PostgreSQL cible ;
- le script de création du schéma ;
- le script de reprise des données ;
- les contrôles de migration ;
- la traçabilité des rejets et corrections.

La Phase 3 doit définir comment passer du système historique au système cible
dans des conditions maîtrisées.

Deux grandes stratégies sont possibles :

```text
migration progressive
ou
Big Bang contrôlé
```

Le choix doit tenir compte du périmètre réellement observé et non uniquement
des architectures possibles à grande échelle.

### Périmètre mesuré

Le système historique validé pour la reprise contient notamment :

```text
10 secteurs
24 utilisateurs
18 mandats
```

La reprise contrôlée a produit :

```text
18 mandats source
↓
16 mandats migrés
+
2 rejets tracés
```

Cinq statuts historiques ont également été corrigés de manière déterministe et
documentée.

Le périmètre actuel reste donc limité et maîtrisable dans une fenêtre de
bascule planifiée.

### Options étudiées

#### Option 1 — Migration progressive

Une migration progressive ferait fonctionner ancien et nouveau systèmes en
parallèle pendant une période donnée.

Elle nécessiterait notamment :

- synchronisation des données ;
- gestion des écritures concurrentes ;
- double écriture ou réplication métier ;
- résolution des conflits ;
- exploitation simultanée de deux modèles ;
- mécanismes supplémentaires de retour arrière.

Avantage :

- possibilité de réduire la durée d'interruption visible lorsque le système
  devient très volumineux ou fortement sollicité.

Inconvénients dans le contexte actuel :

- complexité importante ;
- risques supplémentaires de désynchronisation ;
- exploitation temporaire de deux systèmes ;
- coût technique non justifié par le faible volume actuel.

#### Option 2 — Big Bang sans contrôles formels

Cette option consisterait à arrêter l'ancien système, exécuter les scripts puis
ouvrir directement le nouveau système.

Elle est rejetée car elle ne prévoit pas suffisamment :

- de critères GO / NO-GO ;
- de contrôles bloquants ;
- de sauvegarde préalable ;
- de procédure de rollback ;
- de conservation systématique des preuves.

#### Option 3 — Big Bang contrôlé

Le principe est :

```text
préparation
↓
gel des écritures
↓
sauvegarde
↓
contrôles de la source
↓
GO / NO-GO
↓
création de la cible
↓
reprise des données
↓
contrôles
↓
GO / NO-GO
↓
bascule
↓
surveillance
↓
rollback si nécessaire
```

### Décision

L'option 3 est retenue pour le périmètre actuel.

Match-Immo utilise donc une stratégie :

> **Big Bang contrôlé avec sauvegarde préalable, contrôles bloquants,
> décisions GO / NO-GO et possibilité de retour arrière.**

### Justification

Cette stratégie correspond au contexte réellement mesuré :

- faible volume historique ;
- nombre limité de tables sources principales ;
- migration déjà automatisée ;
- transformation des données connue ;
- anomalies déjà identifiées ;
- rejets tracés ;
- scripts transactionnels ;
- contrôles bloquants déjà intégrés à la reprise.

Mettre en place une synchronisation bidirectionnelle ou une double écriture
introduirait une complexité supplémentaire sans bénéfice démontré sur le
périmètre actuel.

### Ordre de bascule retenu

La chaîne opérationnelle est :

```text
1. préparer l'intervention
2. geler les écritures
3. sauvegarder l'état source
4. contrôler les prérequis
5. décider GO ou NO-GO
6. créer le modèle cible
7. exécuter la reprise
8. contrôler les résultats
9. décider GO ou NO-GO
10. basculer vers la cible
11. surveiller
12. revenir en arrière si un critère critique échoue
```

### Mécanismes de protection

#### Transaction PostgreSQL

Les scripts de migration et de reprise utilisent les transactions PostgreSQL
pour éviter de valider certaines opérations partielles en cas d'erreur SQL.

Cela protège l'exécution technique du script.

#### Sauvegarde

Une sauvegarde doit être réalisée avant la bascule afin de disposer d'un état
restaurable indépendant.

#### GO / NO-GO

La décision de continuer n'est prise que si les contrôles nécessaires sont
satisfaits.

Exemples de critères :

- volumes source conformes ;
- sauvegarde disponible ;
- création de la cible réussie ;
- absence d'erreur bloquante ;
- volumes migrés cohérents ;
- rejets expliqués ;
- contraintes d'intégrité respectées.

#### Rollback

Le rollback peut prendre différentes formes selon le moment où le problème est
détecté :

```text
erreur pendant transaction
→ annulation PostgreSQL

échec avant ouverture de la cible
→ ancien système maintenu ou réouvert

échec critique après bascule
→ restauration ou retour contrôlé vers l'état précédent
```

### Relation avec le PCA / PRA

Le plan de migration et le PCA/PRA sont complémentaires.

Le plan de migration répond à :

```text
comment changer de système ?
```

Le PRA répond à :

```text
comment reprendre après un sinistre ?
```

Les mécanismes de sauvegarde et de restauration validés pendant la Phase 3
renforcent donc la capacité de rollback, mais ne remplacent pas les contrôles
spécifiques à la migration.

### Cas où cette décision devra être réévaluée

Le Big Bang contrôlé est retenu pour le périmètre actuel.

Il devra être réévalué si les conditions changent fortement, par exemple :

- volume de données beaucoup plus important ;
- fenêtre d'arrêt métier devenue inacceptable ;
- fonctionnement 24 h/24 ;
- nombreuses applications dépendantes ;
- synchronisation obligatoire avec des systèmes externes ;
- migration nécessitant plusieurs jours.

Dans ce cas, une stratégie progressive ou hybride pourra devenir préférable.

### Alternatives rejetées

**Migration progressive immédiatement**

Rejetée pour le périmètre actuel car elle introduirait une synchronisation
temporaire de deux systèmes sans besoin démontré.

**Big Bang non contrôlé**

Rejeté car il ne fournit pas un niveau de maîtrise, de traçabilité et de retour
arrière suffisant.

### Preuves

- `03-architecture/plan-migration.md`
- `02-modele-cible/migration-final.sql`
- `02-modele-cible/reprise-donnees-final.sql`
- `02-modele-cible/reprise-donnees-validation.md`
- `03-architecture/matrice-risques.md`
- `03-architecture/pca-pra-complet-maj.md`
