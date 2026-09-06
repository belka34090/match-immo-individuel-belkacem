# Phase 2 — Conception du système cible

## Objectif de cette phase

La Phase 1 a permis d'auditer le système d'information existant et d'identifier ses anomalies et ses limites.

La Phase 2 décrit maintenant le **système cible**, c'est-à-dire la manière dont Match-Immo devra fonctionner après la refonte.

L'objectif n'est donc plus de décrire ce qui existe aujourd'hui, mais de définir une solution plus cohérente, plus fiable et mieux adaptée aux besoins métier.

---

## Logique générale retenue

Le parcours métier cible suit principalement cette logique :

**Utilisateur → Demande → Version de demande → Affectation à un chasseur → Mandat → Présentation de biens → Visite → Offre → Acte authentique → Honoraires / Commission / Paiement**

Quelques principes structurants ont été retenus :

- séparer un utilisateur de son rôle métier de client ou de chasseur ;
- historiser les critères de recherche grâce aux versions de demande ;
- faire précéder le mandat par une demande et une affectation ;
- structurer les secteurs géographiques au lieu de conserver uniquement du texte libre ;
- renforcer les contraintes permettant d'éviter certaines incohérences détectées pendant l'audit ;
- reprendre les données existantes sans inventer les informations absentes de la source.

---

## Documents de cadrage et besoins

### `etude-opportunite.md`

Explique pourquoi la refonte du système d'information est pertinente.

Elle présente le problème, les enjeux, les bénéfices attendus et l'intérêt du projet.

### `besoins-metier-final.md`

Décrit les besoins des différents acteurs métier et le fonctionnement attendu du futur système.

Il constitue une référence pour comprendre **ce que le système doit permettre de faire**.

### `backlog-priorise.md`

Le backlog est la liste organisée des fonctionnalités et besoins à réaliser.

Les éléments sont priorisés afin de distinguer ce qui est indispensable de ce qui peut être réalisé ultérieurement.

### `note-cadrage.md`

La note de cadrage fixe le cadre général du projet :

- contexte ;
- objectifs ;
- périmètre ;
- livrables ;
- acteurs ;
- planning ;
- ressources ;
- risques ;
- critères de réussite.

### `cahier-des-charges-technique-MAJ.md`

Traduit les besoins métier en exigences techniques.

Il explique notamment les règles que le futur système devra respecter concernant les données, la sécurité, la qualité, la performance et l'exploitation.

---

## Modélisation des données

### `mcd-cible-final-propre.drawio.png`

Le **MCD — Modèle Conceptuel de Données** représente les grandes informations métier et leurs relations, indépendamment de la technologie utilisée.

Il permet par exemple de visualiser les liens entre une demande, un mandat, un bien, une visite ou une offre.

### `mld-cible-final.md`

Le **MLD — Modèle Logique de Données** transforme le MCD en une structure plus proche d'une base de données relationnelle.

Il précise notamment :

- les tables ;
- les clés primaires ;
- les clés étrangères ;
- les principales contraintes.

Le modèle cible comporte **26 tables**.

---

## Création et reprise de la base cible

### `migration-final.sql`

Script SQL permettant de créer le schéma de base de données cible sous PostgreSQL.

Il crée les tables, relations et contraintes correspondant au MLD.

### `reprise-donnees-final.sql`

Script permettant de transférer les données utilisables de l'ancien système vers le nouveau modèle.

La reprise ne modifie pas les fixtures sources et n'invente pas les informations absentes.

Sur les 18 mandats historiques :

- 16 sont repris dans le système cible ;
- 2 sont rejetés car ils présentent des incohérences empêchant une migration fiable ;
- parmi les 6 mandats concernés par l'anomalie A-02, 5 voient leur statut corrigé pendant la reprise ;
- le sixième correspond au mandat 9, rejeté en raison de l'anomalie chronologique A-03.

### `reprise-donnees-validation.md`

Conserve les preuves permettant de vérifier le résultat de la reprise.

Il permet notamment de comparer les quantités de données sources, migrées, corrigées et rejetées.

---

## Processus métier

### `processus-metier.bpmn`

Fichier source du processus métier au format BPMN.

**BPMN — Business Process Model and Notation** est une notation standard permettant de représenter graphiquement les différentes étapes d'un processus métier et les décisions prises pendant ce processus.

### `processus-metier.png`

Version image du processus BPMN, directement consultable sans logiciel spécialisé.

---

## Pilotage et responsabilités

### `RACI.md`

La matrice RACI précise les responsabilités des acteurs du projet.

- **R — Responsible** : réalise l'action ;
- **A — Accountable** : en assume la responsabilité finale ;
- **C — Consulted** : est consulté ;
- **I — Informed** : est informé.

Dans ce projet individuel, le porteur du projet assure naturellement une grande partie des responsabilités opérationnelles.

### `TRACABILITE-COMPETENCES.md`

Relie les travaux réalisés aux compétences attendues dans le référentiel de certification.

Pour chaque compétence, le document indique les livrables et preuves disponibles dans le dépôt.

---

## RGPD et éco-conception

### `registre-rgpd.md`

Le registre RGPD identifie les traitements de données personnelles prévus dans le futur système.

Pour chaque traitement, il précise notamment :

- les données concernées ;
- la finalité ;
- la base légale ;
- les destinataires ;
- la durée de conservation ;
- les principales mesures de protection.

### `note-eco-conception.md`

Présente les choix destinés à limiter l'impact environnemental du futur système.

Elle traite notamment :

- de la quantité de données conservées ;
- de la fréquence des traitements ;
- de l'optimisation des requêtes ;
- des sauvegardes ;
- des durées de conservation.

---

## Ordre de lecture conseillé

Pour comprendre la Phase 2 sans connaissance technique préalable, l'ordre suivant est recommandé :

1. `etude-opportunite.md`
2. `besoins-metier-final.md`
3. `backlog-priorise.md`
4. `note-cadrage.md`
5. `processus-metier.png`
6. `mcd-cible-final-propre.drawio.png`
7. `mld-cible-final.md`
8. `cahier-des-charges-technique-MAJ.md`
9. `migration-final.sql`
10. `reprise-donnees-validation.md`
11. `registre-rgpd.md`
12. `note-eco-conception.md`
13. `RACI.md`
14. `TRACABILITE-COMPETENCES.md`

---

## État de la phase

Les principaux travaux de conception de la Phase 2 sont produits.

Les livrables sont contrôlés progressivement avant leur intégration définitive dans Git.

La validation formelle de clôture de la Phase 2 reste distincte de la production des documents et doit être réalisée après le contrôle final de l'ensemble des preuves.
