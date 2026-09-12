# Traçabilité des compétences — Projet Chasse Immobilière

## 1. Objectif

Ce document relie les compétences de la certification RNCP40573 aux réalisations concrètes du projet de modernisation du système d’information d’une entreprise de chasse immobilière.

Le projet mobilise :

- le BC05 comme bloc cible ;
- les blocs communs BC01, BC02 et BC03 ;
- plusieurs exigences transverses : RGPD, éco-conception, accessibilité et sécurité des données.

Un **BC — Bloc de compétences** regroupe plusieurs compétences professionnelles évaluées dans la certification.

Le rôle de ce document est de permettre au formateur ou au jury de retrouver rapidement :

- la compétence attendue ;
- ce qu’elle signifie dans ce projet ;
- le travail déjà réalisé ;
- la preuve correspondante ;
- ce qui reste encore à produire.

Ce document ne remplace pas l’auto-évaluation.

L’auto-évaluation indique un niveau d’avancement, tandis que la présente traçabilité indique **où se trouvent les preuves**.

Le projet étant réalisé individuellement, les travaux normalement répartis entre plusieurs membres sont réalisés par le porteur du projet.

---

# 2. BC05 — Construire et implémenter des modèles de big data et d’IA

Le BC05 est le bloc cible du projet.

## 2.1 Analyser une problématique big data selon les 3V

### Compétence attendue

Analyser une problématique liée au traitement de données massives en étudiant :

- le **volume** : quantité de données ;
- la **vélocité** : vitesse à laquelle les données arrivent ou doivent être traitées ;
- la **variété** : diversité des formats et des sources de données.

Ces trois notions sont appelées les **3V**.

### Application au projet

La croissance future de MatchImmo a été étudiée selon les trois dimensions Volume, Vélocité et Variété.

Le dimensionnement prend en compte notamment :

- l’augmentation du nombre de mandats ;
- l’augmentation du nombre de biens à analyser ;
- les besoins de traitement et de consultation ;
- l’évolution géographique ;
- les besoins transactionnels OLTP ;
- les besoins analytiques OLAP ;
- les futurs traitements de matching et d’intelligence artificielle.

Cette analyse a servi à comparer plusieurs architectures et à éviter une architecture distribuée prématurée.

### Preuves

- `03-architecture/note-dimensionnement-3v.md`
- `03-architecture/dossier-architecture-de-croissance.md`
- `03-architecture/matrice-décision-architecture.md`
- `03-architecture/benchmark-indexation.md`

### État actuel

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 1 : volumes et limites de l’existant identifiés ;
- Phase 2 : modèle cible préparé pour l’évolution métier ;
- Phase 3 : analyse 3V chiffrée, benchmarks et comparaison d’architectures réalisés ;
- 12/09/2026 : compétence considérée comme démontrée.

---

## 2.2 Concevoir et évaluer des modèles statistiques ou d’apprentissage

### Compétence attendue

Concevoir un modèle permettant de répondre à un besoin métier à partir de données et évaluer son comportement.

L’**apprentissage automatique — Machine Learning ou ML** permet à un système d’apprendre des relations à partir de données d’entraînement.

Dans ce projet, aucun modèle de Machine Learning n’est entraîné.

Le choix retenu pour le démonstrateur est un modèle de scoring déterministe, explicable et reproductible.

### Application au projet

Le modèle de matching rapproche les critères d’une demande immobilière avec les caractéristiques des biens disponibles.

Il utilise six features principales :

- secteur ;
- prix ;
- surface ;
- type de bien ;
- nombre de pièces ;
- DPE.

Un préfiltrage élimine d’abord les biens qui ne respectent pas certains critères obligatoires, notamment le budget maximal, le secteur demandé et le type de bien lorsqu’il est imposé.

Les biens restants reçoivent ensuite un score sur 100.

Les poids retenus pour le démonstrateur sont :

- secteur : 30 % ;
- prix : 25 % ;
- surface : 20 % ;
- type de bien : 10 % ;
- nombre de pièces : 10 % ;
- DPE : 5 %.

Le modèle conserve également le détail des contributions afin d’expliquer le score obtenu.

Une donnée demandée mais absente n’est pas inventée : elle est signalée comme indisponible et le score est renormalisé sur les critères réellement évaluables.

### Évaluation du modèle

Le comportement du moteur de matching a été vérifié par des tests automatisés couvrant notamment :

- le préfiltrage ;
- les pondérations ;
- les scores partiels ;
- les valeurs absentes ;
- le bornage du score entre 0 et 100 ;
- l’explicabilité ;
- le classement des biens.

L’exemple de référence du démonstrateur produit notamment :

- bien 2 : 100,00 / 100 ;
- bien 1 : 98,57 / 100.

Le bien 2 est donc correctement classé avant le bien 1.

### Preuves

- `04-application-ia/matching-features.md`
- `04-application-ia/backend/app/matching.py`
- `04-application-ia/backend/app/matching_service.py`
- `04-application-ia/backend/tests/test_matching.py`
- `04-application-ia/backend/tests/test_matching_service.py`
- `04-application-ia/backend/tests/test_matching_explainability.py`
- `04-application-ia/plan-de-tests.md`

### État actuel

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 2 : critères métier et données nécessaires structurés ;
- Phase 4 : features et pondérations définies ;
- Phase 4 : moteur de scoring implémenté et explicable ;
- Phase 4 : scénarios U-M01 à U-M12 exécutés avec succès ;
- 12/09/2026 : compétence considérée comme démontrée dans le périmètre du projet.

---

## 2.3 Extraire, transformer et charger les données en contrôlant leur qualité et le RGPD

### Compétence attendue

Mettre en place une démarche d’**ETL**.

ETL signifie :

- Extract : extraire les données ;
- Transform : les nettoyer ou les convertir ;
- Load : les charger dans la destination.

La qualité des données et la conformité RGPD doivent être prises en compte.

### Application au projet

Deux démarches ETL complémentaires ont été réalisées.

La première concerne la reprise des données historiques vers le modèle cible.

Elle permet notamment de :

- extraire les données du système historique ;
- appliquer les règles métier ;
- corriger les valeurs déterministes ;
- rejeter les données incohérentes ;
- charger les données valides ;
- conserver une traçabilité des corrections et des rejets.

La seconde concerne l’alimentation du modèle analytique OLAP.

Elle extrait les données du système transactionnel, les transforme selon les besoins d’analyse puis les charge dans le schéma décisionnel.

Les traitements sont documentés et réalisés avec des scripts SQL rejouables.

La qualité des données est contrôlée par des comptages, des règles métier et des vérifications de cohérence.

Les exigences RGPD sont prises en compte dans le registre dédié et dans les règles de minimisation et de protection des données.

### Preuves

- `02-modele-cible/reprise-donnees-final.sql`
- `02-modele-cible/reprise-donnees-validation.md`
- `03-architecture/sql/olap-schema.sql`
- `03-architecture/sql/olap-etl.sql`
- `03-architecture/oltp-olap-modele-decisionnel.md`
- `01-audit/preuves/03-anomalies/requetes-audit.sql`
- `01-audit/preuves/03-anomalies/resultats-anomalies.md`
- `02-modele-cible/registre-rgpd.md`

### État actuel

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 1 : qualité de l’existant auditée ;
- Phase 2 : reprise historique contrôlée et traçable ;
- Phase 3 : schéma OLAP et script ETL analytique produits ;
- Phase 3 : contrôles de cohérence et alimentation décisionnelle documentés ;
- 12/09/2026 : compétence considérée comme démontrée.

---

## 2.4 Concevoir une base adaptée aux traitements analytiques et d’IA

### Compétence attendue

Concevoir une base de données capable de répondre correctement aux traitements futurs, notamment analytiques et IA.

Il faut également s’intéresser aux performances.

### Application au projet

L’existant a d’abord été audité puis un modèle cible relationnel plus adapté au parcours métier a été conçu.

Le projet distingue ensuite deux usages :

- l’OLTP pour les opérations métier courantes ;
- l’OLAP pour les besoins d’analyse et de pilotage.

Le modèle transactionnel fournit également les données nécessaires aux traitements de matching et d’assistance IA.

Les performances ont été étudiées par des benchmarks dédiés sur des volumes importants.

Des index ont été testés et leur effet a été mesuré avec `EXPLAIN ANALYZE`.

`EXPLAIN ANALYZE` permet d’observer le plan réellement utilisé par PostgreSQL ainsi que le temps d’exécution de la requête.

Ces mesures permettent de vérifier qu’une optimisation apporte un gain réel avant de complexifier l’architecture.

### Preuves

- `01-audit/mermaid_bdd_existante.png`
- `02-modele-cible/mcd-cible-final-propre.drawio.png`
- `02-modele-cible/mld-cible-final.md`
- `02-modele-cible/migration-final.sql`
- `02-modele-cible/reprise-donnees-validation.md`
- `03-architecture/oltp-olap-modele-decisionnel.md`
- `03-architecture/sql/olap-schema.sql`
- `03-architecture/benchmark-indexation.md`
- `03-architecture/dossier-architecture-de-croissance.md`

### État actuel

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 1 : base historique auditée ;
- Phase 2 : MCD, MLD, migration et reprise du modèle cible réalisés ;
- Phase 3 : séparation OLTP / OLAP conçue ;
- Phase 3 : indexation et performances mesurées avec `EXPLAIN ANALYZE` ;
- 12/09/2026 : compétence considérée comme démontrée.

---

## 2.5 Schématiser et concevoir un programme d’IA

### Compétence attendue

Décrire comment un programme d’intelligence artificielle s’intègre dans le système.

Le schéma doit notamment montrer :

- les données d’entrée ;
- les traitements ;
- les résultats produits ;
- les points d’intégration au système d’information.

### Application au projet

Le programme d’IA a été conçu comme un ensemble de traitements d’assistance intégrés au backend.

Les principales données d’entrée sont :

- les critères de la version courante d’une demande ;
- les secteurs recherchés ;
- les caractéristiques des biens disponibles.

Les principaux traitements sont :

- le calcul de faisabilité ;
- le préfiltrage des biens ;
- le calcul du score de matching ;
- l’explication des contributions au score ;
- la génération d’une synthèse chasseur-IA.

Les principales sorties sont :

- un niveau de faisabilité ;
- une liste de biens compatibles classés ;
- un score de matching ;
- des explications et points de vigilance ;
- une synthèse destinée au chasseur immobilier.

Le système conserve une validation humaine obligatoire pour les décisions importantes.

Le composant IA n’accède pas librement à la base PostgreSQL : les données nécessaires sont sélectionnées par le backend avant traitement.

Le démonstrateur fonctionne actuellement sans LLM externe. Un LLM pourra éventuellement être ajouté pour la reformulation ou la synthèse textuelle, sans remplacer les règles métier ni les calculs déterministes.

### Preuves

- `04-application-ia/programme-ia.md`
- `04-application-ia/programme-ia.png`
- `04-application-ia/matching-features.md`
- `04-application-ia/architecture-applicative.md`
- `04-application-ia/backend/app/feasibility.py`
- `04-application-ia/backend/app/matching.py`
- `04-application-ia/backend/app/chasseur_ai.py`
- `04-application-ia/backend/app/chasseur_ai_service.py`
- `04-application-ia/backend/app/human_validation_service.py`

### État actuel

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 2 : données métier nécessaires structurées ;
- Phase 4 : programme IA schématisé et documenté ;
- Phase 4 : faisabilité, matching, explicabilité et chasseur-IA implémentés ;
- Phase 4 : validation humaine et règles de sécurité intégrées ;
- 12/09/2026 : compétence considérée comme démontrée.

---

# 3. BC01 — Définir une stratégie de systèmes d’information

## 3.1 Schématiser une cartographie du SI en utilisant une analyse des risques

### Application au projet

La Phase 1 a permis de représenter :

- les acteurs ;
- le site web ;
- le logiciel métier ;
- le backend ;
- l’API ;
- la base de données ;
- les dossiers papier.

Les anomalies et risques ont également été recensés.

### Preuves

- `01-audit/mermaid_carto_existante_SI.png`
- `01-audit/mermaid_bdd_existante.png`
- `01-audit/registre-anomalies.md`
- `01-audit/analyse-audit.md`
- `01-audit/swot.md`

### État actuel

Réalisé.

---

## 3.2 Élaborer une stratégie informatique à partir de l’existant

### Application au projet

L’audit a permis d’identifier plusieurs axes d’évolution :

- fiabiliser les rôles ;
- mieux gérer les mandats ;
- historiser les demandes ;
- structurer les critères métier ;
- remplacer le backend inexploitable ;
- préparer la croissance future.

Une étude d’opportunité et un cahier des charges ont été produits.

### Preuves actuelles

- `01-audit/analyse-audit.md`
- `02-modele-cible/etude-opportunite.md`
- `02-modele-cible/besoins-metier-final.md`
- `02-modele-cible/cahier-des-charges-technique-MAJ.md`
- `02-modele-cible/note-strategique-si.md`

### État actuel

Réalisé.

Les axes d’évolution du système d’information sont regroupés et justifiés dans une note stratégique dédiée.

---

## 3.3 Comparer différents types d’architectures

### Compétence attendue

Comparer plusieurs solutions techniques afin de choisir celle qui répond le mieux au besoin.

Le Starter Pack demande notamment d’étudier :

- OLTP ;
- OLAP ;
- réplication ;
- partitionnement ;
- sharding.

**OLTP** correspond aux traitements transactionnels quotidiens.

**OLAP** correspond aux traitements analytiques et décisionnels.

Le **sharding** consiste à répartir horizontalement des données entre plusieurs nœuds.

### Application au projet

Plusieurs solutions d’architecture ont été étudiées en Phase 3 afin de préparer la croissance du système.

La comparaison porte notamment sur :

- PostgreSQL centralisé ;
- indexation ;
- partitionnement ;
- réplication ;
- haute disponibilité ;
- séparation OLTP / OLAP ;
- distribution avec Citus et sharding.

Les solutions ont été comparées selon les besoins métier, les performances, la complexité, la résilience, la scalabilité et l’impact sur l’exploitation.

Les benchmarks ont montré qu’il n’était pas nécessaire de basculer immédiatement vers une architecture distribuée.

La stratégie retenue est donc progressive : conserver une architecture PostgreSQL adaptée au besoin courant et introduire les mécanismes plus complexes uniquement lorsque les mesures réelles le justifient.

### Preuves

- `03-architecture/dossier-architecture-de-croissance.md`
- `03-architecture/matrice-décision-architecture.md`
- `03-architecture/note-dimensionnement-3v.md`
- `03-architecture/benchmark-indexation.md`
- `03-architecture/oltp-olap-modele-decisionnel.md`
- `03-architecture/pca-pra-complet-maj.md`

### État actuel

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 2 : modèle cible PostgreSQL défini ;
- Phase 3 : architectures OLTP, OLAP, réplication, partitionnement et sharding étudiées ;
- Phase 3 : benchmarks et POC utilisés pour comparer les solutions ;
- Phase 3 : architecture progressive retenue et justifiée ;
- 12/09/2026 : compétence considérée comme démontrée.

---

## 3.4 Analyser les composants d’architecture

### Compétence attendue

Identifier les composants techniques, leurs fonctions, leurs dépendances et leurs interactions.

### Application au projet

Les principaux composants de l’architecture ont été identifiés et analysés en Phase 3.

L’étude couvre notamment :

- PostgreSQL pour les traitements transactionnels OLTP ;
- le modèle OLAP pour les traitements analytiques ;
- les mécanismes d’indexation et de partitionnement ;
- la réplication PostgreSQL ;
- les composants de haute disponibilité ;
- les sauvegardes et la restauration ;
- Citus comme solution possible de distribution et de sharding ;
- les scripts ETL entre OLTP et OLAP.

Les interactions entre ces composants ont également été étudiées.

La base OLTP reste le système principal pour les opérations métier.

Le modèle OLAP reçoit des données préparées pour l’analyse afin de ne pas faire porter les traitements décisionnels lourds sur le système transactionnel.

Les mécanismes de réplication, sauvegarde et restauration ont été testés au niveau POC afin de vérifier la continuité et la reprise.

Les performances ont été analysées avec des benchmarks et des plans `EXPLAIN ANALYZE`.

### Preuves

- `03-architecture/dossier-architecture-de-croissance.md`
- `03-architecture/oltp-olap-modele-decisionnel.md`
- `03-architecture/olap-schema.mmd`
- `03-architecture/olap-schema.svg`
- `03-architecture/benchmark-indexation.md`
- `03-architecture/matrice-décision-architecture.md`
- `03-architecture/pca-pra-complet-maj.md`
- `03-architecture/sql/olap-etl.sql`

### État actuel

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 2 : composants de données du système cible définis ;
- Phase 3 : composants OLTP, OLAP, réplication, sauvegarde et distribution analysés ;
- Phase 3 : interactions et dépendances documentées ;
- Phase 3 : performances et résilience vérifiées par benchmarks et POC ;
- 12/09/2026 : compétence considérée comme démontrée.

---

## 3.5 Arbitrer performance, scalabilité, sécurité et éco-conception

### Compétence attendue

Comparer plusieurs architectures selon plusieurs critères.

La **scalabilité** désigne la capacité d’un système à supporter une augmentation de charge.

### Application au projet

Les choix d’architecture ont été comparés selon plusieurs dimensions :

- performance ;
- capacité de montée en charge ;
- résilience ;
- sécurité ;
- complexité d’exploitation ;
- coût technique ;
- impact écologique.

La matrice de décision permet de comparer les différentes solutions étudiées.

Les benchmarks ont également servi à mesurer les gains réels avant de retenir une architecture plus complexe.

L’architecture distribuée avec Citus a été testée comme capacité d’évolution, mais elle n’est pas retenue comme solution immédiate tant que les mesures réelles ne la justifient pas.

La stratégie retenue privilégie donc une architecture progressive, sécurisée, mesurable et proportionnée au besoin.

### Preuves

- `03-architecture/matrice-décision-architecture.md`
- `03-architecture/dossier-architecture-de-croissance.md`
- `03-architecture/note-dimensionnement-3v.md`
- `03-architecture/benchmark-indexation.md`
- `03-architecture/matrice-risques.md`
- `03-architecture/pca-pra-complet-maj.md`
- `02-modele-cible/note-eco-conception.md`

### État actuel

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 2 : premières contraintes techniques et d’éco-conception définies ;
- Phase 3 : solutions d’architecture comparées selon plusieurs critères ;
- Phase 3 : benchmarks, risques et résilience intégrés à l’arbitrage ;
- Phase 3 : architecture progressive retenue et justifiée ;
- 12/09/2026 : compétence considérée comme démontrée.

---

## 3.6 Présenter des préconisations SI pérennes et écoresponsables

### Application au projet

Les préconisations SI sont consolidées à partir des constats de l’audit, des besoins métier et des résultats des phases d’architecture.

La stratégie retenue privilégie :

- un socle PostgreSQL fiable ;
- une architecture progressive ;
- la séparation OLTP / OLAP ;
- l’optimisation mesurée avant complexification ;
- la maîtrise des sauvegardes et de la reprise ;
- la limitation des composants inutiles ;
- la prise en compte du RGPD, de la sécurité et de l’éco-conception ;
- une évolution vers des architectures distribuées uniquement lorsque les mesures réelles le justifient.

Ces préconisations visent à conserver un système maintenable, évolutif, sécurisé et proportionné au besoin.

### Preuves

- `02-modele-cible/note-strategique-si.md`
- `02-modele-cible/note-eco-conception.md`
- `02-modele-cible/cahier-des-charges-technique-MAJ.md`
- `03-architecture/matrice-décision-architecture.md`
- `03-architecture/dossier-architecture-de-croissance.md`
- `03-architecture/pca-pra-complet-maj.md`
- `decisions/journal-decisions-MAJ-2026-09-05.md`

### État actuel

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 1 : limites et risques du SI existant identifiés ;
- Phase 2 : besoins et contraintes du système cible formalisés ;
- Phase 3 : préconisations d’architecture, de résilience et d’éco-conception consolidées ;
- Phase 4 : architecture applicative cohérente avec ces préconisations ;
- 12/09/2026 : compétence considérée comme démontrée.

La soutenance orale constituera une preuve complémentaire de présentation et de justification de ces choix.

---

# 4. BC02 — Piloter des projets informatiques

## 4.1 Analyser la problématique client et formaliser une étude d’opportunité

### Preuves

- `01-audit/analyse-audit.md`
- `01-audit/swot.md`
- `02-modele-cible/etude-opportunite.md`

### État actuel

Réalisé.

---

## 4.2 Évaluer et organiser les fonctionnalités en les priorisant

### Application au projet

Les besoins métier ont été identifiés et transformés en backlog priorisé.

La méthode MoSCoW est utilisée.

### Preuves

- `02-modele-cible/besoins-metier-final.md`
- `02-modele-cible/backlog-priorise.md`

### État actuel

Réalisé.

---

## 4.3 Constituer un cahier des charges technique respectant le RGPD et l’accessibilité PSH

**PSH** signifie Personnes en Situation de Handicap.

### Preuves actuelles

- `02-modele-cible/cahier-des-charges-technique-MAJ.md`
- `02-modele-cible/registre-rgpd.md`
- `02-modele-cible/note-accessibilite-psh.md`

### État actuel

Réalisé.

Le volet RGPD est traité et les préconisations d’accessibilité PSH sont formalisées dans une note dédiée.

---

## 4.4 Décrire les fonctionnalités avec une méthode de modélisation des processus métier

### Application au projet

Le parcours métier principal est représenté en BPMN.

**BPMN — Business Process Model and Notation** est une notation graphique standard pour représenter les étapes et décisions d’un processus métier.

### Preuves

- `02-modele-cible/processus-metier.bpmn`
- `02-modele-cible/processus-metier.png`

### État actuel

Réalisé.

---

## 4.5 Rédiger une note de cadrage

### Preuve

- `02-modele-cible/note-cadrage.md`

### État actuel

Réalisé.

---

## 4.6 Planifier le projet

### Application au projet

Un diagramme de Gantt est utilisé pour organiser les tâches dans le temps.

### Preuves

- `planning-projet_chasse_immo.gan`
- `auto-evaluation-MAJ-2026-09-05.md`

### État actuel

En cours pendant toute la durée du projet.

---

## 4.7 Développer des stratégies de mitigation des risques

La **mitigation** consiste à prévoir des actions permettant de réduire la probabilité ou l’impact d’un risque.

### Application au projet

Les risques ont été identifiés dès l’audit puis consolidés en Phase 3 dans une matrice structurée.

Les risques de disponibilité, perte de données, migration, performance, sécurité, RGPD et continuité d’activité disposent de mesures de mitigation et d’un niveau de risque résiduel.

Le PCA/PRA a également fait l’objet de validations techniques au niveau POC.

### Preuves

- `01-audit/registre-anomalies.md`
- `02-modele-cible/note-eco-conception.md`
- `03-architecture/matrice-risques.md`
- `03-architecture/pca-pra-complet-maj.md`
- `03-architecture/plan-migration.md`

### État actuel

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 1 : identification initiale des risques ;
- Phase 2 : traitement des risques liés aux données et à la migration ;
- Phase 3 : matrice consolidée, PCA/PRA et preuves de restauration/failover ;
- 12/09/2026 : compétence considérée comme démontrée.

---

## 4.8 Coordonner et gérer l’engagement des parties prenantes

### Application au projet

Le projet est réalisé individuellement.

Une matrice RACI formalise les responsabilités du porteur du projet, du formateur / encadrant et du jury sans inventer de rôles d’équipe inexistants.

Le porteur du projet assure la réalisation, les décisions, les contrôles et la conservation des preuves. Le formateur / encadrant intervient comme référence pédagogique et peut être consulté sur les orientations importantes. Le jury intervient lors de l’évaluation finale.

### Preuves actuelles

- `02-modele-cible/RACI.md`
- `02-modele-cible/note-cadrage.md`
- `decisions/journal-decisions-MAJ-2026-09-05.md`

### État actuel

Partiellement démontré — situation vérifiée le 12/09/2026.

### Repère d’avancement

- Phase 1 : conduite et validation technique de l’audit par le porteur du projet ;
- Phase 2 : décisions de modélisation et de migration formalisées dans le journal des décisions ;
- Phase 3 : poursuite des arbitrages d’architecture et des validations techniques ;
- 12/09/2026 : rôles et responsabilités formalisés, mais preuve externe d’engagement encore à compléter.

### Preuve restant à apporter

La compétence sera considérée comme totalement démontrée lorsqu’au moins une preuve réelle d’interaction avec une partie prenante externe sera conservée, par exemple :

- retour ou validation du formateur / encadrant ;
- compte rendu d’un échange réel ;
- consigne reçue et décision prise en conséquence ;
- validation formelle d’un jalon du projet.

Aucune réunion, validation ou interaction ne doit être inventée.

---

# 5. BC03 — Concevoir et développer une application informatique

## 5.1 Concevoir une architecture applicative et des maquettes

### Application au projet

L’architecture applicative de la Phase 4 a été définie à partir des besoins métier et des processus déjà validés.

Le choix retenu est une architecture applicative simple et évolutive, avec séparation des responsabilités entre API, services métier, accès aux données et composants d’assistance IA.

Des maquettes ont également été produites pour représenter les principaux parcours de l’application.

### Preuves

- `04-application-ia/architecture-applicative.md`
- `04-application-ia/maquettes.html`
- `04-application-ia/perimetre-fonctionnel.md`
- `04-application-ia/futur-metier-chasseur.md`
- `04-application-ia/futur-metier-particulier.md`

### État actuel

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 2 : besoins métier et processus formalisés ;
- Phase 3 : architecture de croissance et contraintes techniques définies ;
- Phase 4 : architecture applicative et maquettes produites ;
- 12/09/2026 : compétence considérée comme démontrée.

---

## 5.2 Schématiser les processus métier en tenant compte des contraintes et vulnérabilités

### Preuves actuelles

- `02-modele-cible/processus-metier.bpmn`
- `02-modele-cible/processus-metier.png`
- `01-audit/registre-anomalies.md`
- `01-audit/mermaid_carto_existante_SI.png`

### État actuel

Réalisé pour le processus métier principal.

---

## 5.3 Recommander un environnement informatique en réduisant l’impact écologique

### Application au projet

L’environnement technique cible a été défini progressivement à partir des besoins réels du projet.

Le principe retenu est d’éviter la sur-complexification : utiliser une architecture suffisante pour le besoin courant, mesurer les limites réelles, puis faire évoluer l’infrastructure uniquement lorsque les volumes ou les performances le justifient.

Cette approche réduit les ressources inutiles, limite les composants à maintenir et évite de déployer prématurément une architecture distribuée plus coûteuse.

Les choix d’architecture, de dimensionnement, de sauvegarde, de rétention et de séparation OLTP / OLAP sont également reliés aux principes d’éco-conception.

### Preuves

- `02-modele-cible/note-eco-conception.md`
- `03-architecture/dossier-architecture-de-croissance.md`
- `03-architecture/matrice-décision-architecture.md`
- `03-architecture/note-dimensionnement-3v.md`
- `04-application-ia/architecture-applicative.md`

### État actuel

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 2 : premiers principes d’éco-conception formalisés ;
- Phase 3 : comparaison des architectures, dimensionnement et choix progressifs ;
- Phase 4 : environnement applicatif cohérent avec les choix précédents ;
- 12/09/2026 : compétence considérée comme démontrée.

---

## 5.4 Justifier l’utilisation de patterns logiciels

Un **pattern** est une solution de conception réutilisable à un problème fréquent de développement.

### Application au projet

L’architecture applicative utilise plusieurs principes de conception destinés à séparer clairement les responsabilités.

L’API FastAPI agit comme point d’entrée contrôlé : elle reçoit les requêtes, vérifie les données, appelle le service métier approprié et retourne une réponse structurée.

Les règles métier sont isolées dans des services dédiés, notamment pour la faisabilité, le matching et le chasseur-IA.

L’accès aux données est centralisé dans une couche dédiée utilisant SQLAlchemy pour communiquer avec PostgreSQL.

Cette organisation correspond notamment à une architecture en couches et au principe de séparation des responsabilités.

Le choix d’un monolithe modulaire est également volontaire : il permet de conserver une architecture simple, testable et maintenable sans introduire prématurément la complexité de microservices.

### Justification

Ces choix permettent :

- de ne pas mélanger l’API, la logique métier et l’accès aux données ;
- de faciliter les tests unitaires et fonctionnels ;
- de rendre le code plus maintenable ;
- de limiter le couplage entre les composants ;
- de conserver une architecture suffisamment simple pour le besoin réel ;
- de permettre une évolution future si les volumes ou usages le justifient.

### Preuves

- `04-application-ia/architecture-applicative.md`
- `04-application-ia/backend/app/`

### État actuel

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 3 : principes d’architecture et de séparation des responsabilités préparés ;
- Phase 4 : architecture applicative en couches et monolithe modulaire définis et implémentés ;
- 12/09/2026 : compétence considérée comme démontrée.

---

## 5.5 Développer l’application en appliquant des pratiques de sécurité

### Application au projet

Le backend de la Phase 4 applique plusieurs pratiques de sécurité directement dans le code applicatif.

Les entrées reçues par l’API sont validées avant traitement.

Les erreurs sont gérées de manière contrôlée afin d’éviter d’exposer des informations techniques inutiles à l’utilisateur.

Les traitements IA sont séparés de l’accès direct à la base de données. Les fonctions de synthèse chasseur-IA ne disposent pas d’un accès d’écriture direct à PostgreSQL.

Les données personnelles non nécessaires ne sont pas transmises au composant IA.

Les décisions importantes produites dans le parcours IA restent soumises à une validation humaine.

### Contrôles démontrés

- validation des entrées API ;
- gestion contrôlée des erreurs HTTP ;
- réponse serveur générique en cas d’erreur interne ;
- absence d’accès direct en écriture de la fonction chasseur-IA à la base ;
- limitation des données transmises au composant IA ;
- validation humaine obligatoire ;
- tests spécifiques sur la sécurité de l’API et du composant IA.

### Preuves

- `04-application-ia/backend/app/main.py`
- `04-application-ia/backend/app/chasseur_ai.py`
- `04-application-ia/backend/app/chasseur_ai_service.py`
- `04-application-ia/backend/app/human_validation_service.py`
- `04-application-ia/backend/tests/test_api_security.py`
- `04-application-ia/backend/tests/test_chasseur_ai_security.py`
- `02-modele-cible/registre-rgpd.md`
- `02-modele-cible/note-souverainete-securite-ia.md`

### État actuel

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 2 : exigences RGPD et sécurité formalisées ;
- Phase 3 : risques de sécurité intégrés dans l’architecture et la matrice de risques ;
- Phase 4 : contrôles de sécurité implémentés dans le backend et vérifiés par des tests ;
- 12/09/2026 : compétence considérée comme démontrée.

---

## 5.6 Rédiger et exécuter les scénarios de tests

### Application au projet

Un plan de tests applicatif a été rédigé pour couvrir les principaux traitements de la Phase 4.

Les tests couvrent notamment :

- le matching ;
- l’explicabilité des scores ;
- la faisabilité ;
- le chasseur-IA ;
- la validation humaine ;
- les réponses API ;
- la sécurité ;
- le parcours complet avec PostgreSQL réel.

Les scénarios unitaires de matching U-M01 à U-M12 ont été exécutés et alignés avec le moteur réellement implémenté.

### Résultats d’exécution

Suite standard :

    python -m pytest -q

Résultat :

    47 passed, 5 skipped

Les 5 tests ignorés correspondent aux tests d’intégration PostgreSQL, volontairement exclus de la suite standard.

Suite d’intégration PostgreSQL réelle :

    RUN_INTEGRATION_TESTS=1 python -m pytest -q \
      tests/test_human_validation_integration.py \
      tests/test_full_workflow_integration.py \
      tests/test_chasseur_ai_integration.py \
      tests/test_feasibility_integration.py \
      tests/test_matching_integration.py

Résultat :

    5 passed in 0.30s

### Preuves

- `04-application-ia/plan-de-tests.md`
- `04-application-ia/backend/tests/`
- `04-application-ia/backend/tests/test_matching.py`
- `04-application-ia/backend/tests/test_matching_service.py`
- `04-application-ia/backend/tests/test_matching_explainability.py`
- `04-application-ia/backend/tests/test_api_security.py`
- `04-application-ia/backend/tests/test_chasseur_ai_security.py`
- `04-application-ia/backend/tests/test_full_workflow_integration.py`

### État actuel

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 4 : scénarios de tests rédigés ;
- Phase 4 : tests unitaires, fonctionnels et sécurité exécutés ;
- Phase 4 : 5 tests d’intégration PostgreSQL exécutés avec succès ;
- 12/09/2026 : compétence considérée comme démontrée.

---

## 5.7 Concevoir un suivi automatisé de la qualité

Une **intégration continue — CI** exécute automatiquement des contrôles lorsqu’une modification du code est intégrée au projet.

### Application au projet

Un pipeline GitHub Actions a été mis en place pour contrôler automatiquement la qualité du backend de la Phase 4.

Le pipeline se déclenche :

- lors d’un `push` sur la branche `develop` ;
- lors d’une `pull_request` vers la branche `develop`.

Chaque exécution :

1. récupère le dépôt ;
2. installe Python 3.14.7 ;
3. installe les dépendances du projet ;
4. contrôle le code avec Ruff ;
5. exécute automatiquement la suite de tests avec pytest.

Ruff contrôle notamment les erreurs de syntaxe, certaines erreurs de code et l’organisation des imports.

Pytest vérifie automatiquement que les comportements couverts par les tests continuent de fonctionner après une modification.

### Preuves

- `.github/workflows/phase4-backend.yml`
- `04-application-ia/backend/ruff.toml`
- `04-application-ia/backend/requirements-dev.txt`
- `04-application-ia/backend/tests/`

### Résultat observé

Le pipeline GitHub Actions a été exécuté avec succès sur la branche `develop`.

La CI valide automatiquement :

- le contrôle Ruff ;
- l’exécution de la suite standard pytest.

### État actuel

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 4 : ajout de Ruff pour le contrôle automatisé du code ;
- Phase 4 : ajout du workflow GitHub Actions ;
- Phase 4 : première exécution corrigée après détection d’un problème d’import ;
- Phase 4 : pipeline exécuté avec succès sur `develop` ;
- 12/09/2026 : compétence considérée comme démontrée.

---

# 6. Exigences transverses

## 6.1 RGPD

### Application au projet

Les exigences RGPD ont d’abord été formalisées dans le registre dédié, puis prises en compte dans l’architecture et l’implémentation applicative.

Les traitements de la Phase 4 appliquent notamment le principe de minimisation : seules les données nécessaires sont transmises aux composants d’assistance IA.

Les données personnelles inutiles, comme le nom, l’email ou le téléphone, ne sont pas transmises au composant chasseur-IA.

L’accès aux données est contrôlé par le backend et les traitements IA ne disposent pas d’un accès direct à l’ensemble de la base PostgreSQL.

### Preuves

- `02-modele-cible/registre-rgpd.md`
- `02-modele-cible/note-souverainete-securite-ia.md`
- `04-application-ia/architecture-applicative.md`
- `04-application-ia/backend/app/chasseur_ai_service.py`
- `04-application-ia/backend/tests/test_chasseur_ai_security.py`
- `04-application-ia/backend/tests/test_api_security.py`

### État

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 2 : registre RGPD et règles de traitement formalisés ;
- Phase 3 : risques liés aux données personnelles intégrés à l’architecture ;
- Phase 4 : minimisation et contrôles techniques appliqués et testés ;
- 12/09/2026 : exigence considérée comme démontrée.

---

## 6.2 Éco-conception et numérique responsable

### Application au projet

Les principes d’éco-conception ont été intégrés dans les choix d’architecture et de dimensionnement.

Le projet privilégie une architecture progressive afin d’éviter de déployer prématurément des composants distribués ou des ressources inutiles.

Les choix de sauvegarde, de rétention, de séparation OLTP / OLAP et de montée en charge sont également reliés à une logique de sobriété et de maîtrise des ressources.

### Preuves

- `02-modele-cible/note-eco-conception.md`
- `03-architecture/matrice-décision-architecture.md`
- `03-architecture/note-dimensionnement-3v.md`
- `04-application-ia/architecture-applicative.md`

### État

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 2 : principes d’éco-conception formalisés ;
- Phase 3 : choix d’architecture et de dimensionnement justifiés ;
- Phase 4 : architecture applicative cohérente avec ces principes ;
- 12/09/2026 : exigence considérée comme démontrée.

---

## 6.3 Accessibilité PSH

### Application au projet

Les besoins d’accessibilité pour les personnes en situation de handicap ont été intégrés dans la conception de l’application.

Les principes retenus concernent notamment :

- la compréhension des textes ;
- les contrastes ;
- la navigation au clavier ;
- les libellés explicites ;
- les erreurs compréhensibles ;
- les alternatives textuelles ;
- les zones d’interaction suffisamment utilisables ;
- la compatibilité future avec les technologies d’assistance.

### Preuves

- `02-modele-cible/note-accessibilite-psh.md`
- `02-modele-cible/cahier-des-charges-technique-MAJ.md`
- `04-application-ia/maquettes.html`
- `04-application-ia/architecture-applicative.md`

### État

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 2 : exigences d’accessibilité intégrées au cahier des charges ;
- Phase 4 : principes consolidés dans une note dédiée et pris en compte dans les maquettes ;
- 12/09/2026 : exigence considérée comme démontrée au niveau de la conception.

---

## 6.4 Souveraineté et sécurité des données pour l’IA

### Application au projet

Les traitements d’intelligence artificielle sont conçus pour limiter l’exposition des données.

Le composant IA ne dispose pas d’un accès libre à l’ensemble de la base PostgreSQL.

Le backend sélectionne les données nécessaires avant transmission.

Les principes appliqués sont :

- minimisation des données ;
- contrôle des accès ;
- anonymisation ou pseudonymisation lorsque nécessaire ;
- limitation des droits ;
- absence d’accès direct en écriture depuis le composant IA ;
- validation humaine pour les décisions importantes ;
- vérification des conditions d’utilisation avant recours à un service IA externe.

### Preuves

- `02-modele-cible/note-souverainete-securite-ia.md`
- `02-modele-cible/registre-rgpd.md`
- `04-application-ia/architecture-applicative.md`
- `04-application-ia/backend/app/chasseur_ai_service.py`
- `04-application-ia/backend/tests/test_chasseur_ai_security.py`

### État

Réalisé — validé le 12/09/2026.

### Repère d’avancement

- Phase 2 : principes RGPD et protection des données définis ;
- Phase 4 : règles de souveraineté et sécurité IA formalisées ;
- Phase 4 : limitation des données et absence d’accès direct base testées ;
- 12/09/2026 : exigence considérée comme démontrée.

---

# 7. Traçabilité des travaux déjà réalisés

## Audit de l’existant

### Documents de synthèse

- `01-audit/README.md`
- `01-audit/analyse-audit.md`
- `01-audit/registre-anomalies.md`
- `01-audit/swot.md`
- `01-audit/mermaid_carto_existante_SI.png`
- `01-audit/mermaid_bdd_existante.png`

### Preuves techniques

- `01-audit/preuves/01-import/import-postgresql.md`
- `01-audit/preuves/02-controles/comptages-initiaux.md`
- `01-audit/preuves/03-anomalies/requetes-audit.sql`
- `01-audit/preuves/03-anomalies/resultats-anomalies.md`
- `01-audit/preuves/04-validation-finale/validation-phase1.md`

---

## Conception et reprise des données

- `02-modele-cible/besoins-metier-final.md`
- `02-modele-cible/etude-opportunite.md`
- `02-modele-cible/backlog-priorise.md`
- `02-modele-cible/note-cadrage.md`
- `02-modele-cible/cahier-des-charges-technique-MAJ.md`
- `02-modele-cible/processus-metier.bpmn`
- `02-modele-cible/processus-metier.png`
- `02-modele-cible/RACI.md`
- `02-modele-cible/mcd-cible-final-propre.drawio.png`
- `02-modele-cible/mld-cible-final.md`
- `02-modele-cible/migration-final.sql`
- `02-modele-cible/reprise-donnees-final.sql`
- `02-modele-cible/reprise-donnees-validation.md`
- `02-modele-cible/registre-rgpd.md`
- `02-modele-cible/note-eco-conception.md`

---

## Pilotage et décisions

- `planning-projet_chasse_immo.gan`
- `auto-evaluation-MAJ-2026-09-05.md`
- `decisions/journal-decisions-MAJ-2026-09-05.md`

---

# 8. Synthèse de l’avancement

| Compétence / livrable | État actuel |
| --- | --- |
| Audit de l’existant | Réalisé |
| Cartographie du SI | Réalisée |
| Étude d’opportunité | Réalisée |
| Besoins métier | Réalisés |
| Backlog priorisé | Réalisé |
| Note de cadrage | Réalisée |
| Cahier des charges technique | Réalisé |
| Registre RGPD | Réalisé |
| BPMN | Réalisé |
| RACI | Réalisé |
| MCD cible | Validé |
| MLD cible | Validé |
| Migration PostgreSQL | Exécutée |
| Reprise des données | Exécutée et contrôlée |
| Note d’éco-conception | Réalisée |
| Planning Gantt | En cours |
| Traçabilité des décisions | En cours |
| Note accessibilité PSH | Réalisée |
| Matrice de risques projet | À compléter |
| PCA/PRA | À produire |
| Note de dimensionnement 3V | À produire |
| Dossier d’architecture | À produire |
| Matrice de décision d’architecture | À produire |
| Indexation / EXPLAIN | À produire |
| Schéma OLAP et alimentation | À produire |
| Note qualité des données analytiques | À produire |
| Modèle de matching IA | À produire |
| Schéma du programme IA | À produire |
| Note souveraineté / sécurité IA | Réalisée |
| Architecture applicative | À produire |
| Maquettes | À produire |
| Patterns logiciels | À produire |
| Développement applicatif | À produire |
| Plan de tests | À produire |
| Pipeline qualité / CI | À produire |

---

# 9. Conclusion

La traçabilité montre que les premières phases du projet ont principalement permis de démontrer :

- l’audit du système existant ;
- l’analyse du besoin ;
- le pilotage initial du projet ;
- la modélisation métier ;
- la conception du modèle de données cible ;
- la migration de la structure ;
- la reprise contrôlée des données ;
- la prise en compte du RGPD ;
- les premiers choix d’éco-conception.

Les compétences liées à l’architecture distribuée, au décisionnel, au big data, à l’IA et au développement applicatif ne sont volontairement pas déclarées comme terminées tant que leurs preuves spécifiques n’ont pas été produites.

Le principe de traçabilité retenu est :

**compétence attendue → travail réalisé → preuve vérifiable → état réel → travail restant**

Cette organisation permettra de mettre à jour progressivement le dossier sans perdre le lien entre les exigences du référentiel RNCP40573 et les livrables réels du projet.

---

# 10. Mise à jour d’avancement — 09/09/2026

## 10.1 Objet de cette mise à jour

Cette section complète l’état présenté précédemment dans le document.

Elle ne remplace pas les états historiques indiqués comme « À produire ».

Elle permet de tracer les travaux réalisés depuis cette première évaluation et
de relier chaque nouvelle réalisation à une preuve vérifiable dans le dépôt.

Le principe appliqué est :

```text
état antérieur
→ travail réalisé
→ preuve produite
→ nouvel état daté
```

---

## 10.2 Évolution des livrables de Phase 3

| Compétence / livrable | État précédent | État au 09/09/2026 | Preuve principale |
| --- | --- | --- | --- |
| Note de dimensionnement 3V | À produire | Produite | `03-architecture/note-dimensionnement-3v.md` |
| Dossier d’architecture de croissance | À produire | Produit | `03-architecture/dossier-architecture-de-croissance.md` |
| Matrice de décision d’architecture | À produire | Produite | `03-architecture/matrice-décision-architecture.md` |
| Indexation / `EXPLAIN ANALYZE` | À produire | Benchmark réalisé | `03-architecture/benchmark-indexation.md` |
| Partitionnement | Non encore tracé | Benchmark réalisé | `03-architecture/benchmark-partitionnement.md` |
| Réplication / haute disponibilité | Non encore tracé | POC réalisé | `03-architecture/benchmark-replication-ha.md` |
| Citus / sharding | Non encore tracé | POC réalisé, retenu comme option future | `03-architecture/poc-citus/benchmark-citus-sharding.md` |
| Schéma OLAP | À produire | Produit | `03-architecture/olap-schema.mmd`, `03-architecture/olap-schema.svg`, `03-architecture/sql/olap-schema.sql` |
| Alimentation OLAP | À produire | ETL produit | `03-architecture/sql/olap-etl.sql` |
| Qualité des données analytiques | À produire | Formalisée et reliée aux contrôles ETL | `03-architecture/oltp-olap-modele-decisionnel.md` |
| Matrice de risques projet | À compléter | Produite et mise à jour avec les résultats des POC | `03-architecture/matrice-risques.md` |
| PCA / PRA | À produire | Validé au niveau POC | `03-architecture/pca-pra-complet-maj.md` |
| Plan de migration | Non encore tracé | Produit | `03-architecture/plan-migration.md` |
| Éco-conception | Réalisée au niveau conception | Mise en cohérence avec les preuves de Phase 3 | `02-modele-cible/note-eco-conception.md` |

---

## 10.3 Preuves de performance obtenues

La Phase 3 ne repose pas uniquement sur des choix théoriques.

Des benchmarks ont été exécutés afin de mesurer l’intérêt des différentes
solutions.

### Indexation

Sur un jeu de test de 1 000 000 de lignes :

```text
avant index
≈ 11,438 ms

après index
≈ 2,641 ms

gain
≈ 4,3 ×
```

La décision consiste donc à privilégier l’indexation ciblée avant d’augmenter
la complexité de l’architecture.

Preuve :

```text
03-architecture/benchmark-indexation.md
```

### Partitionnement

Sur un jeu de test de 10 000 000 de lignes :

```text
table non partitionnée
≈ 130,166 ms

table partitionnée
≈ 25,008 ms

gain
≈ 5,2 ×
```

Le partitionnement reste une optimisation à appliquer lorsqu’un volume et un
mode d’accès aux données le justifient.

Preuve :

```text
03-architecture/benchmark-partitionnement.md
```

### Citus / sharding

Le POC Citus a démontré la distribution de 10 000 000 de lignes sur plusieurs
workers.

Il a également montré qu’une mauvaise requête distribuée peut rester coûteuse,
et que l’indexation demeure importante même dans une architecture distribuée.

La décision actuelle est donc :

```text
PostgreSQL optimisé
→ indexation
→ partitionnement
→ réplication si besoin
→ Citus seulement si les volumes réels le justifient
```

Preuve :

```text
03-architecture/poc-citus/benchmark-citus-sharding.md
```

---

## 10.4 Évolution de la continuité et de la reprise

L’état précédent indiquait le PCA/PRA comme « À produire ».

Depuis, plusieurs preuves ont été réalisées au niveau POC :

- réplication PostgreSQL ;
- persistance après redémarrage ;
- promotion d’un replica ;
- conservation des données après failover ;
- sauvegarde ;
- restauration locale ;
- externalisation de sauvegarde ;
- restauration distante sur un environnement indépendant ;
- contrôle d’intégrité ;
- reprise des écritures.

La preuve principale est :

```text
03-architecture/pca-pra-complet-maj.md
```

Les limites restent explicitement tracées :

```text
RPO ≈ 1 h
→ cible d’exploitation
→ chaîne automatisée horaire non encore démontrée

RTO ≤ 4 h
→ cible d’architecture
→ mesure end-to-end encore à réaliser
```

---

## 10.5 Évolution du bloc OLTP / OLAP

L’état précédent indiquait encore :

```text
Schéma OLAP et alimentation
→ À produire

Note qualité des données analytiques
→ À produire
```

Au 09/09/2026, le bloc décisionnel comprend désormais :

```text
modèle OLAP
+
schéma en étoile
+
schéma SQL
+
ETL
+
contrôles de volumes
+
contrôles métier
+
gestion de certains doublons
+
traçabilité vers les données OLTP
+
formalisation de la qualité analytique
```

Les principales preuves sont :

- `03-architecture/oltp-olap-modele-decisionnel.md`
- `03-architecture/olap-schema.mmd`
- `03-architecture/olap-schema.svg`
- `03-architecture/sql/olap-schema.sql`
- `03-architecture/sql/olap-etl.sql`

Les mécanismes de supervision continue de Data Quality restent à
industrialiser ultérieurement.

---

## 10.6 Plan de migration

Le passage de l’ancien système vers le modèle cible dispose désormais d’un plan
de migration et de bascule formalisé.

La stratégie retenue pour le périmètre actuel est :

```text
Big Bang contrôlé
→ gel des écritures
→ sauvegarde
→ contrôles préalables
→ GO / NO-GO
→ création de la cible
→ reprise
→ contrôles
→ GO / NO-GO
→ bascule
→ surveillance
→ possibilité de rollback
```

Preuve :

```text
03-architecture/plan-migration.md
```

La stratégie progressive n’est pas retenue à ce stade car elle ajouterait une
synchronisation temporaire de deux systèmes sans justification par les volumes
actuels.

---

## 10.7 Compétences restant réellement à produire après cette mise à jour

La production des preuves de Phase 3 ne signifie pas que l’ensemble du projet
est terminé.

Au 09/09/2026, restent notamment à produire ou à poursuivre :

| Domaine | État |
| --- | --- |
| Accessibilité PSH | Réalisé |
| Modèle de matching IA | À produire |
| Schéma du programme IA | À produire |
| Souveraineté / sécurité IA | Réalisé |
| Architecture applicative détaillée | Phase ultérieure |
| Maquettes | Phase ultérieure |
| Patterns logiciels | Phase ultérieure |
| Développement applicatif | Phase ultérieure |
| Plan de tests applicatifs | Phase ultérieure |
| Pipeline qualité / CI | Phase ultérieure |

Ces éléments ne doivent pas être déclarés comme acquis avant production de
leurs preuves.

---

## 10.8 Synthèse au 09/09/2026

Depuis l’état précédent du document, la Phase 3 a permis de passer :

```text
architecture envisagée
        ↓
architecture comparée
        ↓
architecture expérimentée
        ↓
mesures obtenues
        ↓
risques analysés
        ↓
continuité testée au niveau POC
        ↓
reprise testée au niveau POC
        ↓
migration planifiée
```

Le principe directeur reste :

> **Mesurer avant de complexifier.**

Cette mise à jour constitue le nouveau repère temporel de la traçabilité au
09/09/2026.

Les états antérieurs sont volontairement conservés dans le document afin de
montrer la progression réelle du projet.

---

# 11. Mise à jour d’avancement — 12/09/2026

## 11.1 Objet de cette mise à jour

Cette section complète le jalon du 09/09/2026.

Elle conserve volontairement les états historiques précédents afin de montrer l’évolution réelle du projet.

Le principe reste :

    état précédent
    → travail réalisé
    → preuve produite
    → nouvel état daté

---

## 11.2 Évolution de la Phase 4

Depuis le jalon du 09/09/2026, les principaux livrables applicatifs et IA ont été produits.

| Domaine | État au 09/09/2026 | État au 12/09/2026 | Preuve principale |
| --- | --- | --- | --- |
| Modèle de matching IA | À produire | Réalisé et testé | `04-application-ia/matching-features.md` |
| Schéma du programme IA | À produire | Réalisé | `04-application-ia/programme-ia.png` |
| Conception du programme IA | À produire | Réalisée | `04-application-ia/programme-ia.md` |
| Architecture applicative détaillée | Phase ultérieure | Réalisée | `04-application-ia/architecture-applicative.md` |
| Maquettes | Phase ultérieure | Réalisées | `04-application-ia/maquettes.html` |
| Patterns logiciels | Phase ultérieure | Réalisés et justifiés | `04-application-ia/architecture-applicative.md` |
| Développement applicatif | Phase ultérieure | Backend démonstrateur réalisé | `04-application-ia/backend/` |
| Faisabilité | Non encore tracée | Réalisée et testée | `04-application-ia/backend/app/feasibility.py` |
| Chasseur-IA | Non encore tracé | Réalisé et testé | `04-application-ia/backend/app/chasseur_ai.py` |
| Validation humaine | Non encore tracée | Réalisée et testée | `04-application-ia/backend/app/human_validation_service.py` |
| Plan de tests applicatifs | Phase ultérieure | Réalisé et exécuté | `04-application-ia/plan-de-tests.md` |
| Sécurité applicative | Non encore tracée | Réalisée et testée | `04-application-ia/backend/tests/test_api_security.py` |
| Sécurité IA | Réalisée au niveau conception | Réalisée et testée | `04-application-ia/backend/tests/test_chasseur_ai_security.py` |
| Pipeline qualité / CI | Phase ultérieure | Réalisé et validé | `.github/workflows/phase4-backend.yml` |
| Accessibilité PSH | Réalisé | Consolidée | `02-modele-cible/note-accessibilite-psh.md` |
| Souveraineté / sécurité IA | Réalisé | Consolidée | `02-modele-cible/note-souverainete-securite-ia.md` |
| Note stratégique SI | Non encore tracée | Réalisée | `02-modele-cible/note-strategique-si.md` |

---

## 11.3 Résultats de tests au 12/09/2026

La suite standard du backend a été exécutée avec :

    python -m pytest -q

Résultat :

    47 passed, 5 skipped

Les 5 tests ignorés correspondent aux tests d’intégration PostgreSQL volontairement exclus de la suite standard.

Les 5 tests d’intégration PostgreSQL ont ensuite été exécutés explicitement.

Résultat :

    5 passed in 0.30s

Ces tests couvrent notamment :

- le matching ;
- la faisabilité ;
- le chasseur-IA ;
- la validation humaine ;
- le parcours applicatif complet avec PostgreSQL réel.

---

## 11.4 Qualité automatisée

Un pipeline GitHub Actions contrôle automatiquement le backend lors des changements sur la branche `develop`.

Il exécute notamment :

- l’installation d’un environnement Python propre ;
- le contrôle Ruff ;
- la suite standard pytest.

Le pipeline a été exécuté avec succès après correction d’un problème d’import détecté lors d’une première exécution.

Cette preuve montre que le contrôle qualité n’est plus uniquement manuel.

---

## 11.5 État consolidé au 12/09/2026

| Bloc / domaine | État |
| --- | --- |
| BC05 — 3V | Réalisé |
| BC05 — Matching / modèle de scoring | Réalisé |
| BC05 — ETL / qualité / RGPD | Réalisé |
| BC05 — Base analytique / IA / performance | Réalisé |
| BC05 — Programme IA | Réalisé |
| BC01 — Cartographie SI | Réalisé |
| BC01 — Stratégie SI | Réalisé |
| BC01 — Comparaison d’architectures | Réalisé |
| BC01 — Analyse des composants | Réalisé |
| BC01 — Arbitrages architecture | Réalisé |
| BC01 — Préconisations SI | Réalisé |
| BC02 — Étude d’opportunité | Réalisé |
| BC02 — Priorisation des besoins | Réalisé |
| BC02 — Cahier des charges / RGPD / PSH | Réalisé |
| BC02 — Processus métier | Réalisé |
| BC02 — Note de cadrage | Réalisé |
| BC02 — Planification | En cours |
| BC02 — Gestion des risques | Réalisé |
| BC02 — Engagement parties prenantes | Partiellement démontré |
| BC03 — Architecture applicative / maquettes | Réalisé |
| BC03 — Processus métier | Réalisé |
| BC03 — Environnement et éco-conception | Réalisé |
| BC03 — Patterns logiciels | Réalisé |
| BC03 — Sécurité applicative | Réalisé |
| BC03 — Tests | Réalisé |
| BC03 — Qualité automatisée / CI | Réalisé |
| RGPD | Réalisé |
| Éco-conception | Réalisé |
| Accessibilité PSH | Réalisé au niveau conception |
| Souveraineté / sécurité IA | Réalisé |

---

## 11.6 Éléments restant réellement ouverts

Au 12/09/2026, les Phases 1 à 4 sont réalisées et leurs principales preuves
techniques et documentaires sont présentes dans le dépôt.

Les documents de pilotage ont également été consolidés :

- README racine mis à jour ;
- auto-évaluation RNCP mise à jour ;
- journal des décisions complété ;
- Gantt recalé sur la chronologie réelle des travaux ;
- traçabilité des compétences actualisée.

Les éléments encore réellement ouverts sont désormais :

- le suivi continu du planning jusqu’au rendu final du 31/12/2026 ;
- la preuve réelle d’engagement d’une partie prenante externe pour BC02 4.8 ;
- la préparation du support de soutenance ;
- la répétition de la soutenance et le contrôle final du dépôt.

Aucune preuve d’engagement externe n’est inventée. Cette compétence reste donc
partiellement démontrée tant qu’une interaction réelle et vérifiable avec une
partie prenante n’est pas disponible.

---

## 11.7 Repère temporel

Le projet est passé de :

    09/09/2026
    Phase 3 consolidée
    Phase 4 encore majoritairement à produire

à :

    12/09/2026
    Phases 1 à 4 réalisées
    backend et matching opérationnels
    tests exécutés
    sécurité vérifiée
    CI opérationnelle
    documentation principale consolidée
    Gantt recalé sur la chronologie réelle
    traçabilité RNCP largement consolidée

Le développement principal du projet est terminé.

Le travail restant concerne désormais le pilotage jusqu’au rendu final,
l’éventuelle preuve réelle d’engagement d’une partie prenante et la préparation
de la soutenance.
