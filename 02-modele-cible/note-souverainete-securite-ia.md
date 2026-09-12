# Note de souveraineté et de sécurité des données pour l’IA

## 1. Objectif

Cette note définit les principes de souveraineté, de sécurité et de protection des données à appliquer aux traitements d’intelligence artificielle du projet MatchImmo.

L’objectif est d’éviter qu’un composant IA dispose d’un accès excessif aux données ou qu’un service externe reçoive des informations personnelles inutiles.

## 2. Accès contrôlé aux données

Un composant IA ne doit pas accéder librement à l’ensemble de la base PostgreSQL.

Le fonctionnement retenu est le suivant :

    PostgreSQL
        ↓
    backend contrôlé
        ↓
    sélection des données nécessaires
        ↓
    composant IA

Le backend joue donc un rôle de filtre entre la base de données et l’IA.

Le LLM, lorsqu’il est utilisé, n’accède pas directement à PostgreSQL.

Les écritures importantes restent sous le contrôle des services métier du backend. Un composant IA ne doit pas pouvoir modifier directement les données métier sensibles.

Lorsqu’un accès aux données est nécessaire, il doit être limité au strict besoin du traitement et, lorsque cela est possible, réalisé en lecture seule.

## 3. Minimisation des données

Les traitements IA doivent respecter le principe RGPD de minimisation.

Cela signifie que seules les données réellement nécessaires doivent être utilisées.

Pour le matching immobilier, les informations comme le nom, l’adresse e-mail ou le numéro de téléphone du particulier ne sont pas nécessaires. Le traitement repose principalement sur des critères immobiliers.

Les données personnelles ne doivent donc pas être transmises automatiquement à un composant IA simplement parce qu’elles existent dans la base.

## 4. Anonymisation et pseudonymisation

Lorsque des données personnelles doivent être utilisées, elles doivent être minimisées et, selon le besoin, anonymisées ou pseudonymisées.

La pseudonymisation consiste à remplacer une information directement identifiable par un identifiant indirect.

Exemple :

    Jean Dupont
        ↓
    client_1842

Cette méthode réduit l’exposition directe des personnes concernées.

## 5. Utilisation d’un service IA externe

Avant tout recours à un service IA externe, les points suivants doivent être vérifiés :

- le lieu de traitement des données ;
- les conditions de conservation ;
- les données réellement transmises ;
- les possibilités de pseudonymisation ou d’anonymisation ;
- l’existence éventuelle d’une solution locale permettant de limiter l’exposition des données.

Un service externe ne doit recevoir que les données strictement nécessaires à la tâche demandée.

## 6. Traçabilité et sécurité

Les traitements importants doivent être traçables.

Les principes retenus sont :

- contrôle des accès ;
- séparation des responsabilités ;
- validation des entrées API ;
- limitation des données transmises à l’IA ;
- journalisation des opérations sensibles ;
- absence d’exposition directe de PostgreSQL au LLM ;
- maintien des écritures métier sensibles dans les services backend.

Les messages techniques ne doivent pas exposer inutilement des informations sensibles.

## 7. Contrôle humain

L’IA reste un outil d’assistance.

Les décisions importantes doivent rester sous contrôle humain, notamment lorsqu’un résultat IA peut avoir un impact sur une décision métier.

Le composant IA ne doit pas remplacer automatiquement la validation du chasseur immobilier.

## 8. Conclusion

La stratégie retenue pour MatchImmo repose sur un principe simple : l’IA reçoit uniquement les données nécessaires, par l’intermédiaire d’un backend contrôlé.

Les données personnelles doivent être limitées, pseudonymisées ou anonymisées lorsque cela est nécessaire, et tout recours à un service IA externe doit faire l’objet d’un contrôle préalable sur le lieu de traitement, la conservation et les données transmises.

Cette approche réduit les risques de fuite, d’accès excessif et de dépendance non maîtrisée à un service externe.
