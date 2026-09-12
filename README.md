# Match-Immo — Refonte du système d'information

Projet fil rouge individuel réalisé dans le cadre du **RNCP40573 — Data / IA**.

L'objectif est de partir du système Match-Immo existant, volontairement simple,
puis de construire progressivement un système d'information plus robuste,
traçable, performant et capable d'absorber la croissance.

Le principe directeur du projet est :

> **Mesurer avant de complexifier.**

---

## 1. Démarche générale

```text
audit de l'existant
        ↓
identification des anomalies
        ↓
conception du modèle cible
        ↓
migration et reprise des données
        ↓
dimensionnement de la croissance
        ↓
mesures de performance
        ↓
comparaison des architectures
        ↓
tests de disponibilité et de reprise
        ↓
planification de la migration
        ↓
conception applicative
        ↓
matching et assistance IA
        ↓
validation humaine
        ↓
tests et sécurité
        ↓
qualité automatisée / CI
```

Les décisions techniques sont fondées autant que possible sur une chaîne de
preuve :

```text
affirmation
↓
méthode de test
↓
preuve observée
↓
mesure
↓
interprétation
↓
décision
```

---

## 2. Organisation du dépôt

```text
.
├── 01-audit/
│   └── audit et preuves du système existant
│
├── 02-modele-cible/
│   └── besoins, conception, migration et reprise
│
├── 03-architecture/
│   └── croissance, OLAP, benchmarks, HA, PCA/PRA et migration
│
├── 04-application-ia/
│   └── architecture applicative, matching, IA, tests et backend
│
├── decisions/
│   └── journal des décisions
│
├── fixtures/
│   └── données et scripts fournis comme point de départ
│
├── auto-evaluation-MAJ-2026-09-05.md
├── planning-projet_chasse_immo.gan
└── README.md
```

---

## 3. Phase 1 — Audit de l'existant

Point d'entrée :

`01-audit/README.md`

Principales preuves :

- `01-audit/analyse-audit.md`
- `01-audit/registre-anomalies.md`
- `01-audit/swot.md`
- `01-audit/mermaid_carto_existante_SI.png`
- `01-audit/mermaid_bdd_existante.png`
- `01-audit/preuves/`

Cette phase documente l'état initial du SI et les anomalies réellement
constatées avant toute refonte.

---

## 4. Phase 2 — Modèle cible et reprise

Point d'entrée :

`02-modele-cible/README.md`

Principaux livrables :

- `02-modele-cible/besoins-metier-final.md`
- `02-modele-cible/mcd-cible-final-propre.drawio.png`
- `02-modele-cible/mld-cible-final.md`
- `02-modele-cible/cahier-des-charges-technique-MAJ.md`
- `02-modele-cible/migration-final.sql`
- `02-modele-cible/reprise-donnees-final.sql`
- `02-modele-cible/reprise-donnees-validation.md`
- `02-modele-cible/registre-rgpd.md`
- `02-modele-cible/note-eco-conception.md`

### Résultat de référence de la reprise

```text
18 mandats source
=
16 mandats migrés
+
2 rejets tracés
```

Cinq statuts historiques ont également été corrigés de manière déterministe
et documentée.

---

## 5. Phase 3 — Absorber la croissance

Dossier :

`03-architecture/`

### Dimensionnement 3V

`03-architecture/note-dimensionnement-3v.md`

Scénario de travail :

```text
5 000 nouveaux mandats par semaine
jusqu'à 1 000 biens analysés par recherche
```

Soit jusqu'à environ :

```text
260 000 000 de rapprochements recherche / bien par an
```

Il s'agit d'une hypothèse de dimensionnement, pas d'une mesure de l'activité
actuelle.

### Architecture de croissance

- `03-architecture/dossier-architecture-de-croissance.md`
- `03-architecture/matrice-décision-architecture.md`

Progression retenue :

```text
PostgreSQL optimisé
↓
indexation
↓
partitionnement si nécessaire
↓
réplication si le besoin de disponibilité le justifie
↓
Citus uniquement si les volumes réels le justifient
```

---

## 6. Benchmarks et POC

| Sujet | Échelle | Résultat principal | Preuve |
| --- | ---: | --- | --- |
| Indexation | 1 M de lignes | ≈ 4,3× plus rapide | `03-architecture/benchmark-indexation.md` |
| Partitionnement | 10 M de lignes | ≈ 5,2× plus rapide sur la requête testée | `03-architecture/benchmark-partitionnement.md` |
| Réplication / HA | 10 M de lignes | failover et persistance validés au niveau POC | `03-architecture/benchmark-replication-ha.md` |
| Citus / sharding | 10 M de lignes | distribution validée ; Citus conservé comme option future | `03-architecture/poc-citus/benchmark-citus-sharding.md` |

Ces résultats ne signifient pas qu'une technologie doit être utilisée partout.

Ils servent à justifier les décisions en fonction du besoin et des mesures.

---

## 7. OLTP / OLAP

Document principal :

`03-architecture/oltp-olap-modele-decisionnel.md`

Schéma et SQL :

- `03-architecture/olap-schema.mmd`
- `03-architecture/olap-schema.svg`
- `03-architecture/sql/olap-schema.sql`
- `03-architecture/sql/olap-etl.sql`

Architecture :

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

La qualité analytique est également documentée et reliée aux contrôles de
l'ETL.

---

## 8. Risques, continuité et reprise

Matrice des risques :

`03-architecture/matrice-risques.md`

PCA / PRA :

`03-architecture/pca-pra-complet-maj.md`

Les travaux ont démontré au niveau POC :

- réplication et failover ;
- persistance des données ;
- restauration locale ;
- sauvegarde externalisée ;
- restauration distante ;
- contrôle d'intégrité ;
- reprise des écritures.

Les limites restent distinguées des preuves :

```text
RPO ≈ 1 h
→ cible d'exploitation
→ chaîne horaire automatisée non encore démontrée

RTO ≤ 4 h
→ cible d'architecture
→ non encore mesurée end-to-end
```

---

## 9. Plan de migration

`03-architecture/plan-migration.md`

Stratégie retenue pour le périmètre actuel :

```text
Big Bang contrôlé
↓
gel des écritures
↓
sauvegarde
↓
GO / NO-GO
↓
migration
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

---

## 10. Phase 4 — Application et IA

Dossier :

`04-application-ia/`

Principaux livrables :

- `04-application-ia/architecture-applicative.md`
- `04-application-ia/maquettes.html`
- `04-application-ia/matching-features.md`
- `04-application-ia/programme-ia.md`
- `04-application-ia/programme-ia.png`
- `04-application-ia/plan-de-tests.md`
- `04-application-ia/backend/`

### Architecture applicative

Le démonstrateur utilise un **monolithe modulaire**.

Le principe est :

    API FastAPI
    ↓
    services métier
    ↓
    faisabilité / matching / chasseur-IA
    ↓
    accès aux données avec SQLAlchemy
    ↓
    PostgreSQL

Ce choix conserve une architecture simple et testable sans introduire
prématurément la complexité de microservices.

### Matching

Le moteur de matching est déterministe, explicable et reproductible.

Il utilise six features :

- secteur ;
- prix ;
- surface ;
- type de bien ;
- nombre de pièces ;
- DPE.

Les pondérations sont :

- secteur : 30 % ;
- prix : 25 % ;
- surface : 20 % ;
- type de bien : 10 % ;
- nombre de pièces : 10 % ;
- DPE : 5 %.

Une donnée absente n'est pas inventée.

Le moteur conserve également le détail des contributions au score afin de
pouvoir expliquer le classement obtenu.

Exemple de référence :

    bien 2
    → 100,00 / 100

    bien 1
    → 98,57 / 100

### Faisabilité et chasseur-IA

Le backend fournit également :

- une estimation de la faisabilité d'une demande ;
- un classement des biens compatibles ;
- des explications de matching ;
- une synthèse destinée au chasseur immobilier ;
- une étape de validation humaine.

Le composant IA n'accède pas librement à PostgreSQL.

Le backend sélectionne les données nécessaires avant traitement et les
décisions importantes restent soumises à une validation humaine.

### Tests

Suite standard :

    python -m pytest -q

Résultat au 12/09/2026 :

    47 passed, 5 skipped

Les 5 tests ignorés correspondent aux tests d'intégration PostgreSQL exclus de
la suite standard.

Tests PostgreSQL exécutés explicitement :

    5 passed

### Qualité automatisée

Une CI GitHub Actions exécute automatiquement :

- Ruff ;
- pytest.

Le pipeline est déclenché sur les changements de la branche `develop` et sur
les pull requests vers `develop`.

Preuves :

- `.github/workflows/phase4-backend.yml`
- `04-application-ia/backend/ruff.toml`
- `04-application-ia/backend/requirements-dev.txt`

---

## 11. Traçabilité et pilotage

Les documents de suivi sont volontairement des **documents vivants**.

Ils conservent les états historiques puis ajoutent des mises à jour datées.

- `decisions/journal-decisions-MAJ-2026-09-05.md`
- `02-modele-cible/TRACABILITE-COMPETENCES.md`
- `auto-evaluation-MAJ-2026-09-05.md`
- `planning-projet_chasse_immo.gan`

Repères actuels :

```text
06/09/2026
→ auto-évaluation initiale

09/09/2026
→ mise à jour après production des principales preuves de Phase 3

12/09/2026
→ consolidation de la Phase 4 applicative et IA
```

---

## 12. État du projet au 12/09/2026

Les Phases 1 à 3 disposent de leurs principales preuves :

- audit et cartographie de l'existant ;
- modèle cible ;
- migration et reprise contrôlée ;
- dimensionnement 3V ;
- benchmarks ;
- architecture de croissance ;
- OLTP / OLAP ;
- risques ;
- PCA / PRA au niveau POC ;
- plan de migration.

Depuis le jalon du 09/09/2026, la Phase 4 a également produit :

- architecture applicative ;
- maquettes ;
- modèle de matching ;
- features et pondérations ;
- programme IA ;
- faisabilité ;
- chasseur-IA ;
- validation humaine ;
- sécurité applicative et IA ;
- tests unitaires et fonctionnels ;
- tests d'intégration PostgreSQL ;
- pipeline CI ;
- accessibilité PSH au niveau conception ;
- note de souveraineté et sécurité IA ;
- note stratégique SI.

La synthèse d'auto-évaluation au 12/09/2026 est :

    28 compétences / exigences acquises
    2 en cours
    0 non abordée

Les deux éléments encore ouverts sont :

- le suivi du planning jusqu'à la clôture du projet ;
- la preuve réelle d'engagement d'une partie prenante externe.

Le projet entre donc dans une phase de clôture documentaire et de préparation
de la soutenance.

---

## 13. Ordre de lecture conseillé

```text
README.md
↓
01-audit/README.md
↓
02-modele-cible/README.md
↓
02-modele-cible/besoins-metier-final.md
↓
02-modele-cible/mld-cible-final.md
↓
03-architecture/note-dimensionnement-3v.md
↓
03-architecture/dossier-architecture-de-croissance.md
↓
03-architecture/matrice-décision-architecture.md
↓
03-architecture/oltp-olap-modele-decisionnel.md
↓
03-architecture/matrice-risques.md
↓
03-architecture/pca-pra-complet-maj.md
↓
03-architecture/plan-migration.md
↓
04-application-ia/README.md
↓
04-application-ia/architecture-applicative.md
↓
04-application-ia/matching-features.md
↓
04-application-ia/programme-ia.md
↓
04-application-ia/plan-de-tests.md
↓
02-modele-cible/TRACABILITE-COMPETENCES.md
↓
auto-evaluation-MAJ-2026-09-05.md
```

---

## 14. Référentiel

Projet :

```text
Chasse immobilière
RNCP40573
```

Blocs principalement mobilisés :

- **BC01** — stratégie SI ;
- **BC02** — pilotage de projet ;
- **BC03** — conception et développement ;
- **BC05** — Data / Big Data / IA.
