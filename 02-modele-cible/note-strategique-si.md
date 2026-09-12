# Note stratégique du système d’information

## 1. Contexte

L’entreprise MatchImmo exerce une activité de chasse immobilière.

L’audit du système d’information existant a montré que le fonctionnement actuel permet de soutenir l’activité, mais qu’il présente plusieurs limites :

- certaines règles métier sont insuffisamment représentées ;
- des incohérences existent dans les données historiques ;
- les critères de recherche sont insuffisamment structurés ;
- les évolutions des demandes ne sont pas correctement historisées ;
- le backend existant n’est pas exploitable comme base d’évolution ;
- le modèle actuel n’est pas adapté à la croissance future prévue.

En parallèle, l’entreprise prévoit une augmentation importante de son activité, avec davantage de mandats, de biens à analyser et une extension vers plusieurs territoires européens.

Le système d’information doit donc évoluer pour répondre aux besoins actuels tout en préparant la croissance future.

## 2. Objectifs stratégiques

La stratégie retenue repose sur six axes principaux :

1. fiabiliser les données métier ;
2. mieux représenter le parcours complet d’une recherche immobilière ;
3. historiser les évolutions importantes, notamment celles des demandes ;
4. renforcer les règles de gestion et la traçabilité ;
5. préparer la montée en charge et l’extension géographique ;
6. créer un socle exploitable pour l’analyse et l’intelligence artificielle.

L’objectif n’est donc pas uniquement de corriger l’existant, mais de construire une base durable pour les futures évolutions de l’activité.

## 3. Orientation du système cible

La stratégie choisie consiste à repartir d’un modèle de données métier cible plus structuré.

Le futur système doit permettre de représenter le parcours suivant :

    Prospect
        ↓
    Demande
        ↓
    Versions de la demande
        ↓
    Affectation d’un chasseur
        ↓
    Mandat
        ↓
    Propositions de biens
        ↓
    Visites
        ↓
    Commentaires
        ↓
    Offre d’achat
        ↓
    Vente
        ↓
    Paiement

Cette structuration permet de mieux suivre l’activité, de conserver l’historique nécessaire et de sécuriser les principales règles métier.

## 4. Principaux choix stratégiques

### Fiabilité avant croissance

La priorité est de disposer d’un socle de données cohérent avant d’augmenter la complexité du système.

Les données existantes doivent être reprises sans inventer les informations absentes et les anomalies doivent rester traçables.

### Architecture évolutive

L’architecture doit répondre au besoin actuel tout en permettant une évolution progressive.

La montée en charge doit être mesurée et justifiée par des tests de volume, d’indexation et de performance avant d’introduire des solutions plus complexes.

### Séparation OLTP / OLAP

Le système transactionnel doit rester orienté vers le fonctionnement quotidien de l’activité.

Les besoins d’analyse et de pilotage sont séparés dans un modèle décisionnel dédié afin de ne pas dégrader les traitements métier.

### Intelligence artificielle contrôlée

L’intelligence artificielle est utilisée comme outil d’assistance.

Les traitements déterministes, comme le matching immobilier ou le calcul de faisabilité, restent contrôlables et explicables.

Un LLM éventuel peut intervenir pour générer ou reformuler du texte, mais il ne doit pas remplacer les règles métier ni les validations humaines importantes.

### Protection des données

Les traitements doivent respecter le RGPD et le principe de minimisation.

Les composants IA ne doivent pas disposer d’un accès direct à l’ensemble de la base de données et seules les informations nécessaires doivent leur être transmises.

## 5. Bénéfices attendus

La stratégie doit permettre :

- de réduire les incohérences de données ;
- d’améliorer la traçabilité du parcours client ;
- de faciliter le travail des chasseurs immobiliers ;
- de mieux contrôler les règles métier ;
- de préparer l’augmentation du volume d’activité ;
- de faciliter l’extension géographique ;
- de disposer d’indicateurs décisionnels plus fiables ;
- de préparer les futurs usages d’intelligence artificielle.

Les bénéfices attendus sont donc à la fois opérationnels, techniques et stratégiques.

## 6. Gestion des risques

Les principaux risques identifiés sont :

- perte ou mauvaise reprise des données historiques ;
- dégradation des performances avec la croissance du volume ;
- non-respect des exigences de protection des données ;
- dépendance excessive à une technologie ou à un service externe ;
- complexité technique disproportionnée par rapport au besoin réel.

La stratégie retenue consiste à réduire ces risques par :

- une migration contrôlée et traçable ;
- des tests de performance ;
- une architecture progressive ;
- des contrôles RGPD et de sécurité ;
- une validation humaine des traitements importants ;
- des choix techniques justifiés par le besoin réel.

## 7. Critères de réussite

La stratégie sera considérée comme réussie si le système permet :

- de représenter correctement le parcours métier complet ;
- de contrôler les principales règles de gestion ;
- de conserver l’historique nécessaire ;
- de reprendre les données existantes de manière maîtrisée ;
- de protéger les données personnelles ;
- de supporter l’évolution future du volume ;
- de fournir un socle exploitable pour l’analyse et l’intelligence artificielle ;
- de rester maintenable et compréhensible.

## 8. Conclusion

La stratégie SI de MatchImmo consiste à construire un système plus fiable, plus structuré et plus évolutif à partir des constats réalisés lors de l’audit.

La priorité est donnée à la qualité des données, à la cohérence métier, à la traçabilité et à la maîtrise de la complexité.

La croissance, l’analyse décisionnelle et l’intelligence artificielle sont intégrées comme des évolutions préparées par le socle cible, et non comme des ajouts isolés.
