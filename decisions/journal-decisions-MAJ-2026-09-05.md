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
-   `02-modele-cible/mcd-cible.png`
-   `02-modele-cible/mld-cible.md`

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

-   `02-modele-cible/besoins-metier.md`
-   `02-modele-cible/regles-gestion.md`
-   `02-modele-cible/mcd-cible.png`
-   `02-modele-cible/mld-cible.md`

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

-   `02-modele-cible/besoins-metier.md`
-   `02-modele-cible/regles-gestion.md`
-   `02-modele-cible/mld-cible.md`
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

-   `02-modele-cible/mcd-cible.png`
-   `02-modele-cible/mld-cible.md`

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
-   `02-modele-cible/preuves/reprise-donnees-validation.md`

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
-   `auto-evaluation.md` représente l'état courant des compétences.
-   Le présent journal conserve les changements significatifs.
-   Git fournit l'historique technique des modifications.

### Preuves

-   `planning-projet_chasse_immo.gan`
-   `auto-evaluation.md`
-   `decisions/journal-decisions.md`

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

  05/09/2026   BC02         CDC technique     NA → **EC** Le CDCT est produit `02-modele-cible/cahier-des-charges-technique.md`
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
3.  mettre à jour `auto-evaluation.md` si une compétence change de
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
