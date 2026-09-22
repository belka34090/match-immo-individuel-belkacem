# Note de cadrage — Projet Chasse Immobilière

## 1. Contexte

Le projet porte sur la modernisation du système d'information d'une entreprise de chasse immobilière.

Le système existant repose principalement sur trois tables : `secteurs`, `utilisateurs` et `mandats`.

L'audit réalisé en Phase 1 a montré que cette structure permet de gérer un premier niveau de suivi de l'activité, mais qu'elle présente plusieurs limites importantes :

- clients et chasseurs sont gérés dans une même table ;
- certaines relations ne garantissent pas correctement le rôle métier attendu ;
- le cycle de vie des mandats est insuffisamment représenté ;
- certains critères de recherche sont stockés sous forme de texte libre ;
- plusieurs données nécessaires au fonctionnement métier futur sont absentes ;
- des anomalies de cohérence ont été identifiées ;
- l'organisation actuelle prépare mal l'augmentation future du volume de données et les futurs besoins décisionnels et IA.

Le projet vise donc à définir puis mettre en œuvre progressivement un système d'information plus structuré, plus fiable et plus évolutif.

---

## 2. Objectifs

L'objectif général est de concevoir une cible technique et fonctionnelle capable de mieux représenter le métier de la chasse immobilière et de préparer les évolutions futures.

Les principaux objectifs sont :

- fiabiliser les données existantes ;
- distinguer clairement les différents rôles métier, notamment clients et chasseurs ;
- mieux représenter le cycle complet d'une demande immobilière ;
- historiser les évolutions d'une demande client ;
- structurer les secteurs et les critères de recherche ;
- améliorer le suivi des mandats ;
- représenter les biens, vendeurs, visites, offres et ventes ;
- structurer les commissions, honoraires, factures et paiements ;
- permettre une reprise contrôlée des données historiques ;
- prendre en compte le RGPD ;
- préparer les futurs besoins d'analyse décisionnelle ;
- préparer un futur mécanisme de matching entre demandes et biens ;
- préparer la montée en charge et l'extension géographique du système.

Le **matching** désigne ici le rapprochement automatique ou semi-automatique entre les critères d'une demande immobilière et les caractéristiques de biens disponibles.

---

## 3. Périmètre

### 3.1 Dans le périmètre

Le projet couvre progressivement :

- l'audit du système existant ;
- l'identification et la traçabilité des anomalies ;
- l'analyse des besoins métier ;
- la formalisation des règles de gestion ;
- la modélisation des processus métier ;
- la conception du modèle de données cible ;
- la conception du MCD et du MLD ;
- la migration de la structure de données ;
- la reprise et le contrôle des données historiques ;
- le pilotage du projet ;
- la prise en compte du RGPD ;
- l'éco-conception ;
- l'accessibilité ;
- l'analyse des risques ;
- la conception de l'architecture cible ;
- la préparation du décisionnel et de l'OLAP ;
- l'étude du dimensionnement selon les 3V ;
- la préparation d'un futur modèle de matching ;
- la conception applicative ;
- les tests ;
- la documentation et la préparation de la soutenance.

Le **MCD — Modèle Conceptuel de Données** représente les objets métier et leurs relations sans dépendre d'un logiciel de base de données particulier.

Le **MLD — Modèle Logique de Données** traduit ce modèle en tables, clés et relations exploitables dans une base relationnelle.

L'**OLAP — Online Analytical Processing** désigne une organisation des données destinée principalement à l'analyse et au décisionnel, contrairement à l'OLTP utilisé pour les opérations métier quotidiennes.

### 3.2 Hors périmètre

Ne sont pas considérés comme devant être intégralement réalisés pendant cette phase de cadrage :

- la reconstruction complète du site web existant ;
- la reconstruction complète d'une application métier de production ;
- le déploiement réel à l'échelle internationale ;
- l'exploitation d'une infrastructure de production à grande échelle ;
- l'entraînement d'un modèle d'IA industriel sur un grand volume réel de données ;
- l'intégration avec des systèmes externes réels non fournis dans le projet ;
- la migration d'autres données historiques que celles mises à disposition dans les fixtures du projet.

Les **fixtures** sont les jeux de données fournis avec le Starter Pack afin de disposer d'un environnement de départ reproductible pour l'audit et les migrations.

Ces limites permettent de conserver un projet réalisable tout en démontrant les compétences demandées par la certification.

---

## 4. Livrables attendus

Les principaux livrables du projet sont organisés par phase.

### Audit et analyse de l'existant

- analyse de l'audit ;
- registre des anomalies ;
- SWOT ;
- cartographie du système d'information existant ;
- schéma de la base historique ;
- requêtes SQL de contrôle ;
- preuves de validation.

### Conception de la cible

- étude d'opportunité ;
- besoins métier ;
- backlog priorisé ;
- note de cadrage ;
- cahier des charges technique ;
- processus BPMN ;
- matrice RACI ;
- MCD cible ;
- MLD cible ;
- script de migration ;
- script de reprise des données ;
- preuve de validation de la reprise ;
- registre RGPD ;
- note d'éco-conception ;
- matrice de traçabilité des compétences.

### Architecture, données et continuité

Les phases suivantes devront notamment produire :

- dossier d'architecture ;
- matrice de décision d'architecture ;
- analyse de dimensionnement 3V ;
- note d'indexation avec preuves `EXPLAIN` ;
- schéma OLAP ;
- alimentation des données analytiques ;
- matrice des risques ;
- PCA/PRA ;
- note d'accessibilité PSH ;
- note sur la souveraineté et la sécurité des données IA.

### Application et IA

Seront également préparés ou réalisés :

- architecture applicative ;
- maquettes ;
- justification des patterns logiciels ;
- modèle de matching ;
- schéma du programme IA ;
- développement applicatif ;
- plan de tests ;
- preuves d'exécution des tests ;
- suivi automatisé de la qualité.

La liste détaillée et son état d'avancement sont suivis dans :

- `02-modele-cible/TRACABILITE-COMPETENCES.md`
- `auto-evaluation-MAJ-2026-09-05.md`

---

## 5. Parties prenantes

Le projet est réalisé individuellement.

Les principales parties prenantes sont les suivantes :

| Partie prenante | Rôle dans le projet |
| --- | --- |
| Porteur du projet | Analyse, conception, réalisation, documentation, tests, suivi et soutenance |
| Formateur / encadrant | Fournit le cadre pédagogique, accompagne et valide les grandes orientations |
| Jury | Évalue les compétences démontrées à partir des livrables et de la soutenance |

La répartition détaillée des responsabilités est documentée dans :

`02-modele-cible/RACI.md`

La **RACI** est une matrice qui précise qui réalise une tâche, qui en porte la responsabilité finale, qui est consulté et qui doit être informé.

---

## 6. Planning et jalons

Le projet est piloté à l'aide d'un diagramme de Gantt.

Un **diagramme de Gantt** représente les tâches du projet dans le temps, leurs durées et leurs dépendances.

Les grands jalons sont :

| Jalon | Période cible | Résultat associé |
| --- | --- | --- |
| Phase 1 — Audit de l'existant | Réalisée | Audit, anomalies, SWOT, cartographies et preuves |
| Phase 2 — Modèle cible et cadrage | En cours | Besoins, MCD, MLD, migration, reprise, pilotage et conformité |
| Phase 3 — Architecture et données | À venir | Architecture, dimensionnement, OLAP, performance, risques, PCA/PRA |
| Phase 4 — Application et IA | À venir | Conception applicative, matching, développement et tests |
| Consolidation finale | Avant soutenance | Documentation, auto-évaluation, traçabilité et préparation orale |
| Rendu final | 31/12/2026 | Dépôt complet et preuves associées |

Le planning détaillé est conservé dans :

`planning-projet_chasse_immo.gan`

Les dates et pourcentages d'avancement sont mis à jour uniquement après production et contrôle des livrables correspondants.

---

## 7. Ressources

### Ressources humaines

Le projet est réalisé par une seule personne.

Cela implique que le porteur du projet assure plusieurs fonctions :

- analyse métier ;
- modélisation ;
- conception de données ;
- administration technique ;
- développement ;
- tests ;
- documentation ;
- pilotage.

Le formateur intervient comme encadrant et référence pédagogique.

### Ressources techniques

Le projet utilise ou prévoit d'utiliser plusieurs outils adaptés aux différentes phases.

#### Git et GitHub

Git est un système de gestion de versions.

Il permet de conserver l'historique des modifications et de revenir à un état antérieur.

GitHub héberge le dépôt Git du projet et facilite la consultation des livrables.

#### PostgreSQL

PostgreSQL est un système de gestion de base de données relationnelle.

Il est utilisé pour construire et tester le modèle cible et pour exécuter la migration et la reprise des données.

#### Docker

Docker permet d'exécuter des logiciels dans des environnements isolés appelés conteneurs.

Dans ce projet, il facilite la création d'un environnement de base de données reproductible sans installer directement chaque composant dans le système principal.

#### k3d

k3d permet d'exécuter localement un petit cluster Kubernetes basé sur k3s.

Kubernetes est un orchestrateur de conteneurs : il permet d'organiser le déploiement et l'exécution de plusieurs services.

k3d sera notamment utile pour expérimenter une architecture distribuée de type Citus dans les phases d'architecture.

#### Citus

Citus est une extension de PostgreSQL permettant de répartir certaines données et certains traitements entre plusieurs nœuds PostgreSQL.

Il est étudié dans le projet pour répondre à la problématique future de montée en charge et de distribution des données.

Son utilisation devra être justifiée par comparaison avec des solutions plus simples avant d'être retenue comme choix définitif d'architecture.

#### Outils de modélisation

Des outils de représentation graphique sont utilisés pour produire :

- les cartographies ;
- le MCD ;
- les processus BPMN ;
- les futurs schémas d'architecture.

Camunda Modeler est notamment utilisé pour le BPMN.

### Ressources de données

Les données historiques proviennent des fixtures fournies avec le Starter Pack.

Ces fichiers sources sont conservés sans modification afin de garantir la reproductibilité de l'audit et de la reprise.

### Ressources budgétaires

Aucun budget d'infrastructure de production réel n'est engagé dans le cadre pédagogique.

Les choix doivent néanmoins prendre en compte :

- le coût potentiel d'exploitation ;
- la consommation de ressources ;
- la simplicité de maintenance ;
- la capacité à évoluer.

---

## 8. Risques identifiés

Plusieurs catégories de risques sont déjà connues.

| Risque | Impact potentiel | Parade envisagée |
| --- | --- | --- |
| Données historiques incohérentes | Migration erronée ou perte de confiance dans les données | Audit SQL, registre d'anomalies, règles de reprise et rejets tracés |
| Mauvaise interprétation des rôles métier | Relations incorrectes entre clients, chasseurs et mandats | Séparation explicite des rôles dans le modèle cible |
| Perte de données pendant la migration | Données manquantes ou non exploitables | Transactions SQL, contrôles de comptage et preuve de validation |
| Évolution importante du volume | Dégradation des performances | Étude 3V, indexation, tests `EXPLAIN`, comparaison d'architectures |
| Architecture inutilement complexe | Coût et maintenance excessifs | Comparer plusieurs solutions avant décision |
| Non-conformité RGPD | Risque juridique et mauvaise protection des données | Registre RGPD, minimisation, durées de conservation, contrôles d'accès |
| Panne ou perte de service | Interruption de l'activité | PCA/PRA et stratégie de sauvegarde à formaliser |
| Dérive du périmètre | Retard et multiplication des travaux non prioritaires | Backlog priorisé, note de cadrage et suivi Gantt |
| Manque de preuves pour le jury | Compétence réalisée mais non démontrable | Traçabilité des compétences, journal de décisions et auto-évaluation |
| Dépendance à une solution technique unique | Difficulté d'évolution ou de remplacement | Comparaison d'architectures et justification des choix |
| Utilisation future de données sensibles avec l'IA | Risque de fuite ou usage inapproprié | Note souveraineté/sécurité IA, minimisation et contrôle des accès |

Une matrice des risques plus complète ainsi que le PCA/PRA seront produits dans les étapes prévues par le projet.

Le **PCA — Plan de Continuité d'Activité** décrit comment maintenir les fonctions essentielles en cas d'incident.

Le **PRA — Plan de Reprise d'Activité** décrit comment rétablir le système après une panne ou un sinistre.

---

## 9. Critères de réussite

Le projet sera considéré comme réussi si les conditions suivantes sont réunies :

- l'existant est audité et les anomalies importantes sont documentées ;
- le modèle cible correspond au fonctionnement métier attendu ;
- le MCD et le MLD sont cohérents et explicables ;
- la structure PostgreSQL cible peut être créée de manière reproductible ;
- les données historiques peuvent être reprises sans perte silencieuse ;
- les corrections et rejets de migration sont justifiés et tracés ;
- les règles métier essentielles sont représentées ;
- les décisions techniques importantes sont argumentées ;
- le projet prend en compte le RGPD, l'éco-conception et l'accessibilité ;
- la future montée en charge est étudiée avec des éléments mesurables ;
- les besoins analytiques et IA sont formalisés ;
- les performances sont mesurées lorsque cela est attendu ;
- les risques importants disposent d'une stratégie de réduction ;
- les tests nécessaires sont exécutés et leurs résultats conservés ;
- chaque compétence revendiquée peut être associée à une preuve identifiable dans le dépôt ;
- les livrables restent compréhensibles par un lecteur non spécialiste ;
- le projet peut être expliqué et défendu pendant la soutenance.

---

## 10. Suivi du cadrage

Cette note constitue le cadre de référence initial du projet.

Elle est complétée par :

- le cahier des charges technique pour les exigences techniques ;
- le backlog pour les priorités fonctionnelles ;
- le RACI pour les responsabilités ;
- le Gantt pour le planning ;
- le journal de décisions pour les arbitrages ;
- l'auto-évaluation pour l'état des compétences ;
- la matrice de traçabilité pour relier compétences et preuves.

Toute évolution importante du périmètre ou de l'architecture devra être expliquée et tracée afin de conserver la cohérence entre le besoin initial, les décisions prises et les livrables produits.
