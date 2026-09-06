# Phase 1 — Audit de l’existant

## 1. Objectif de cette phase

Avant de concevoir une nouvelle solution, il est nécessaire de comprendre le système d’information déjà utilisé par l’entreprise.

Un **système d’information (SI)** désigne l’ensemble des personnes, applications, données et moyens utilisés par une organisation pour gérer son activité.

Cette première phase a donc pour objectif de :

- comprendre le fonctionnement du système existant ;
- examiner la structure de la base de données historique ;
- contrôler les données fournies ;
- identifier les anomalies présentes dans les données ;
- identifier les risques et limites de la solution actuelle ;
- conserver les preuves des contrôles réalisés.

La date de référence utilisée pour l’audit est le **25 juillet 2026**.

---

## 2. Sources utilisées

L’audit repose sur :

- l’énoncé et les besoins métier fournis avec le projet ;
- les fichiers SQL historiques fournis dans le Starter Pack ;
- les contrôles réalisés sur les données après leur import.

Les fichiers SQL historiques sont conservés dans le dossier `fixtures/` à la racine du projet.

Ils représentent les données de départ du projet et ne sont pas modifiés pendant l’audit.

---

## 3. Livrables principaux

Les fichiers suivants présentent les résultats de l’audit.

### `analyse-audit.md`

Présente le système d’information existant, la structure de la base historique, les contrôles réalisés et les principaux constats.

Son objectif est d’expliquer **ce qui existe aujourd’hui et pourquoi certaines évolutions sont nécessaires**.

### `registre-anomalies.md`

Recense les anomalies réellement constatées et les risques identifiés.

Pour chaque problème important, le registre précise notamment :

- ce qui a été observé ;
- son impact sur le métier ;
- sa gravité ;
- l’action proposée.

### `swot.md`

Présente une synthèse des :

- forces ;
- faiblesses ;
- opportunités ;
- menaces.

Une **SWOT** est une méthode permettant de résumer la situation d’une organisation ou d’un projet afin d’aider à orienter les décisions futures.

---

## 4. Cartographie de l’existant

Deux schémas sont utilisés car ils présentent deux niveaux différents du système existant.

### `mermaid_carto_existante_SI.png`

Cette cartographie donne une vue globale du système d’information.

Elle représente notamment :

- les principaux acteurs ;
- le site web ;
- le logiciel métier ;
- le backend et son API ;
- la base de données historique ;
- l’existence de dossiers papier.

Le **backend** est la partie du système qui traite les demandes des applications et communique notamment avec la base de données.

Une **API** est un moyen standardisé permettant à plusieurs applications de communiquer entre elles.

### `mermaid_bdd_existante.png`

Ce schéma se concentre uniquement sur la base de données historique.

Il représente les trois tables existantes :

- `utilisateurs` ;
- `secteurs` ;
- `mandats`.

Il permet également de visualiser leurs principales colonnes et leurs relations.

La cartographie du SI montre donc **l’environnement complet**, tandis que le schéma de la base de données effectue un **zoom sur les données existantes**.

---

## 5. Preuves de l’audit

Le dossier `preuves/` conserve les éléments permettant de vérifier comment les conclusions de l’audit ont été obtenues.

Autrement dit :

> les livrables principaux expliquent les conclusions ; les preuves montrent comment elles ont été vérifiées.

### `preuves/01-import/`

Contient la preuve de l’import de la base historique dans PostgreSQL.

Fichier principal :

- `import-postgresql.md`

### `preuves/02-controles/`

Contient les contrôles réalisés après l’import afin de vérifier que les données attendues sont bien présentes.

Fichier principal :

- `comptages-initiaux.md`

### `preuves/03-anomalies/`

Contient les requêtes SQL utilisées pour rechercher les anomalies ainsi que les résultats obtenus.

Fichiers principaux :

- `requetes-audit.sql`
- `resultats-anomalies.md`

Une **requête SQL** est une instruction envoyée à une base de données pour consulter ou contrôler ses données.

Conserver ces requêtes permet de rendre l’audit **reproductible** : une autre personne peut les exécuter à nouveau et vérifier les résultats.

### `preuves/04-validation-finale/`

Contient le contrôle final de la Phase 1.

Fichier principal :

- `validation-phase1.md`

Cette dernière vérification permet de confirmer que l’existant a été suffisamment analysé avant de commencer la conception de la solution cible.

---

## 6. Organisation générale

La logique de la Phase 1 est donc la suivante :

**Système existant → import des données → contrôles → détection des anomalies → analyse des risques → synthèse → validation finale**

Cette organisation permet de distinguer clairement :

- ce qui existait avant le projet ;
- ce qui a réellement été observé dans les données ;
- les risques identifiés ;
- les preuves techniques utilisées pour justifier les conclusions.

La solution cible et les choix de conception correspondants sont traités dans les phases suivantes du projet.
