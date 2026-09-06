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

Le Starter Pack prévoit une croissance future pouvant atteindre plusieurs milliers de mandats par semaine ainsi qu’une extension géographique internationale.

Cette évolution nécessitera un dimensionnement spécifique de la future architecture.

### État actuel

À venir.

L’audit et le modèle cible constituent des données d’entrée, mais une note chiffrée de dimensionnement 3V reste à produire.

### Preuve attendue

- note de dimensionnement 3V chiffrée.

---

## 2.2 Concevoir et évaluer des modèles statistiques ou d’apprentissage

### Compétence attendue

Concevoir un modèle permettant de répondre à un besoin métier à l’aide de statistiques ou d’apprentissage automatique.

L’**apprentissage automatique — Machine Learning ou ML** permet à un système de produire des prédictions ou des scores à partir de données.

### Application au projet

Le besoin métier prévoit à terme un mécanisme de rapprochement entre une demande immobilière et des biens disponibles.

Ce futur traitement pourra notamment exploiter :

- le budget ;
- les secteurs ;
- les caractéristiques du bien ;
- les critères du client ;
- les contraintes de la demande.

### État actuel

À venir.

La structure des données nécessaires est progressivement préparée, mais la conception formelle du modèle de matching n’est pas encore produite.

### Preuve attendue

- note de conception du modèle de matching ;
- liste documentée des variables utilisées, appelées **features**.

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

Une première démarche de transformation a déjà été réalisée pendant la reprise des données historiques.

La reprise a notamment permis de :

- lire les données historiques ;
- appliquer des règles métier ;
- corriger certains statuts ;
- rejeter des données incohérentes ;
- charger les données valides dans le modèle cible ;
- conserver une preuve des résultats.

Le registre RGPD a également été produit.

Cependant, le Starter Pack attend aussi une alimentation distincte de la future partie analytique OLAP.

### Preuves actuelles

- `02-modele-cible/reprise-donnees-final.sql`
- `02-modele-cible/reprise-donnees-validation.md`
- `01-audit/preuves/03-anomalies/requetes-audit.sql`
- `01-audit/preuves/03-anomalies/resultats-anomalies.md`
- `02-modele-cible/registre-rgpd.md`

### État actuel

Partiellement démontré.

La reprise des données est réalisée et contrôlée.

Il reste à produire :

- le schéma analytique OLAP ;
- la description ou le script d’alimentation ;
- une note spécifique sur la qualité des données analytiques.

---

## 2.4 Concevoir une base adaptée aux traitements analytiques et d’IA

### Compétence attendue

Concevoir une base de données capable de répondre correctement aux traitements futurs, notamment analytiques et IA.

Il faut également s’intéresser aux performances.

### Application au projet

L’existant a d’abord été audité.

Un nouveau MCD puis un MLD ont ensuite été conçus.

Le modèle cible couvre beaucoup plus précisément le parcours métier.

Le script de migration PostgreSQL correspondant a été exécuté avec succès.

### Preuves actuelles

- `01-audit/mermaid_bdd_existante.png`
- `02-modele-cible/mcd-cible-final-propre.drawio.png`
- `02-modele-cible/mld-cible-final.md`
- `02-modele-cible/migration-final.sql`
- `02-modele-cible/reprise-donnees-validation.md`

### État actuel

Partiellement démontré.

La conception et la migration de la base cible sont réalisées.

Il reste à produire la preuve d’optimisation demandée par le Starter Pack :

- note d’indexation ;
- comparaison `EXPLAIN` avant/après.

`EXPLAIN` est une commande PostgreSQL qui montre comment la base prévoit d’exécuter une requête.

---

## 2.5 Schématiser et concevoir un programme d’IA

### Compétence attendue

Décrire comment un futur programme d’intelligence artificielle s’intègre dans le système.

Le schéma doit notamment montrer :

- les données d’entrée ;
- les traitements ;
- les résultats produits ;
- les points d’intégration au système d’information.

### Application au projet

Le futur usage envisagé concerne notamment l’assistance au matching entre demandes immobilières et biens.

### État actuel

À venir.

### Preuve attendue

- schéma du programme d’IA ;
- description des entrées ;
- description des sorties ;
- données utilisées ;
- intégration au SI.

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

### État actuel

Partiellement démontré.

Une note stratégique dédiée pourra être produite pour regrouper explicitement les axes d’évolution attendus par la grille.

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

### État actuel

À venir dans la phase d’architecture et de croissance.

### Preuve attendue

- dossier comparatif d’architecture.

---

## 3.4 Analyser les composants d’architecture

### Compétence attendue

Identifier les composants techniques, leurs fonctions, leurs dépendances et leurs interactions.

### État actuel

À venir.

### Preuve attendue

- schéma de composants ;
- analyse des interactions ;
- points de performance.

---

## 3.5 Arbitrer performance, scalabilité, sécurité et éco-conception

### Compétence attendue

Comparer plusieurs architectures selon plusieurs critères.

La **scalabilité** désigne la capacité d’un système à supporter une augmentation de charge.

### Application actuelle

Une note d’éco-conception a déjà été produite et contient notamment un arbitrage sur la stratégie de sauvegarde.

### Preuve actuelle

- `02-modele-cible/note-eco-conception.md`

### État actuel

Partiellement démontré.

La matrice de décision d’architecture reste à produire.

---

## 3.6 Présenter des préconisations SI pérennes et écoresponsables

### Application au projet

Les choix de conception sont documentés progressivement et une note dédiée à l’éco-conception est disponible.

### Preuves actuelles

- `02-modele-cible/note-eco-conception.md`
- `02-modele-cible/cahier-des-charges-technique-MAJ.md`
- `decisions/journal-decisions-MAJ-2026-09-05.md`

### État actuel

En cours.

La restitution orale constituera également une preuve de cette compétence.

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

### État actuel

Partiellement démontré.

Le volet RGPD est traité.

Une note dédiée à l’accessibilité PSH reste à produire.

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

### Application actuelle

Des risques ont été identifiés dès l’audit et des actions ont été proposées.

Une politique de sauvegarde a également été étudiée.

### Preuves actuelles

- `01-audit/registre-anomalies.md`
- `02-modele-cible/note-eco-conception.md`

### État actuel

Partiellement démontré.

Il reste à compléter cette compétence avec :

- une matrice de risques projet structurée ;
- le PCA/PRA.

---

## 4.8 Coordonner et gérer l’engagement des parties prenantes

### Application au projet

Une matrice RACI formalise les responsabilités du porteur du projet, du formateur et du jury.

### Preuve actuelle

- `02-modele-cible/RACI.md`

### État actuel

Partiellement démontré.

La preuve de l’engagement réel des parties prenantes devra être complétée par les échanges, comptes rendus ou validations du projet.

---

# 5. BC03 — Concevoir et développer une application informatique

## 5.1 Concevoir une architecture applicative et des maquettes

### Application actuelle

Le besoin et les processus sont définis, mais l’architecture applicative détaillée et les maquettes ne sont pas encore produites.

### État actuel

À venir.

### Preuves attendues

- dossier de conception applicative ;
- maquettes.

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

### Application actuelle

La réflexion sur l’éco-conception est engagée.

### Preuve actuelle

- `02-modele-cible/note-eco-conception.md`

### État actuel

Partiellement démontré.

La note d’environnement technique cible reste à compléter avec l’architecture.

---

## 5.4 Justifier l’utilisation de patterns logiciels

Un **pattern** est une solution de conception réutilisable à un problème fréquent de développement.

### État actuel

À venir pendant la conception applicative.

### Preuve attendue

- dossier de conception applicative ;
- patterns utilisés et justification de leur choix.

---

## 5.5 Développer l’application en appliquant des pratiques de sécurité

### État actuel

À venir.

### Preuves attendues

- code applicatif ;
- note de sécurité ;
- contrôles de sécurité.

---

## 5.6 Rédiger et exécuter les scénarios de tests

### État actuel

À venir pour la partie applicative.

### Preuves attendues

- plan de tests ;
- tests unitaires ;
- tests fonctionnels ;
- résultats d’exécution.

---

## 5.7 Concevoir un suivi automatisé de la qualité

### État actuel

À venir.

### Preuves attendues

- pipeline d’intégration continue ;
- contrôles automatiques ;
- indicateurs de qualité.

Une **intégration continue — CI** exécute automatiquement des contrôles lorsqu’une modification du code est intégrée au projet.

---

# 6. Exigences transverses

## 6.1 RGPD

### Preuve actuelle

- `02-modele-cible/registre-rgpd.md`

### État

Réalisé au niveau de la conception.

Les contrôles techniques seront complétés lors de l’implémentation.

---

## 6.2 Éco-conception et numérique responsable

### Preuve actuelle

- `02-modele-cible/note-eco-conception.md`

### État

Réalisé au niveau de la politique et des choix de conception.

---

## 6.3 Accessibilité PSH

### État

À produire.

### Preuve attendue

- note de préconisations d’accessibilité.

---

## 6.4 Souveraineté et sécurité des données pour l’IA

### État

À produire.

### Preuve attendue

- note dédiée à la souveraineté et à la sécurité IA ;
- règles d’accès ;
- anonymisation si nécessaire ;
- limitation des droits ;
- usage en lecture seule lorsque cela est pertinent.

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
| Note accessibilité PSH | À produire |
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
| Note souveraineté / sécurité IA | À produire |
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
