# Journal des décisions

Ce document conserve les principales décisions prises pendant le projet ainsi que leur justification.

---

## DEC-001 — Utiliser PostgreSQL pour l'environnement local d'audit

**Décision :** utiliser la fixture `PgSQL.sql` avec PostgreSQL 16 dans Docker pour réaliser les contrôles de l'existant.

**Justification :**
- une fixture PostgreSQL est fournie dans le projet ;
- PostgreSQL permet de disposer d'un environnement reproductible ;
- Docker évite de dépendre d'une installation locale spécifique.

**Statut :** Adoptée

---

## DEC-002 — Ne pas modifier les fixtures héritées

**Décision :** conserver `MySQL.sql` et `PgSQL.sql` sans modification pendant la Phase 1.

**Justification :**
- les fixtures représentent le système d'information hérité à auditer ;
- modifier les données supprimerait la possibilité de reproduire fidèlement l'état initial ;
- les anomalies doivent être détectées et documentées, pas corrigées directement dans la source.

**Statut :** Adoptée

---

## DEC-003 — Distinguer anomalies de données et risques structurels

**Décision :** séparer dans le registre :
- les anomalies réellement observées dans les données (`A-*`) ;
- les risques liés à la conception du schéma (`R-*`).

**Justification :**

Une donnée actuellement correcte ne signifie pas nécessairement que le modèle empêche une future incohérence.

Cette séparation évite de présenter comme anomalie réelle un problème qui est seulement rendu possible par la structure de la base.

**Statut :** Adoptée

---

## DEC-004 — Conserver la Phase 1 centrée sur l'existant

**Décision :** ne pas introduire dans la cartographie d'audit les futures tables ou solutions du modèle cible.

**Justification :**

La Phase 1 doit représenter fidèlement le système hérité. Les évolutions du modèle seront étudiées dans les phases suivantes.

**Statut :** Adoptée

---

## DEC-005 — Utiliser le 25/07/2026 comme date de référence métier

**Décision :** utiliser le 25 juillet 2026 pour les contrôles temporels de l'audit.

**Justification :**

Cette date est celle définie dans les fixtures du projet pour interpréter notamment la validité des mandats.

**Statut :** Adoptée
