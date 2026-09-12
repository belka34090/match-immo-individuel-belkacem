# Architecture applicative — Phase 4

## 1. Objectif

Ce document explique comment le démonstrateur Phase 4 de Match-Immo est organisé techniquement.

Il répond à trois questions simples :

1. quelles parties composent l'application ;
2. comment elles communiquent ;
3. pourquoi cette organisation a été retenue.

Une **architecture applicative** décrit la manière dont les différentes parties d'une application sont organisées.

Le **backend** est la partie invisible de l'application qui exécute les règles métier et dialogue avec la base de données.

Une **API** est une porte d'entrée permettant à une interface ou à un autre programme de demander une action au backend et de recevoir une réponse.

Le démonstrateur doit principalement montrer :

- l'analyse de faisabilité ;
- le matching entre une demande et des biens ;
- le classement des résultats ;
- l'explication du score ;
- une assistance de type chasseur-IA ;
- la validation humaine ;
- des tests automatisés.

---

## 2. Architecture retenue

L'architecture choisie est un **monolithe modulaire**.

Cela signifie :

    une seule application
        ↓
    plusieurs modules séparés par responsabilité

Exemples de modules :

- API ;
- faisabilité ;
- matching ;
- chasseur-IA ;
- accès aux données ;
- tests.

Cette solution est adaptée au projet car elle permet :

- de limiter la complexité ;
- de faciliter le développement en solo ;
- de simplifier les tests ;
- de conserver une séparation claire des responsabilités ;
- d'éviter plusieurs services réseau inutiles.

Le principe reste cohérent avec la Phase 3 :

> mesurer avant de complexifier.

---

## 3. Pourquoi ne pas utiliser des microservices maintenant

Les **microservices** consistent à découper l'application en plusieurs services indépendants déployés séparément.

Exemple :

    service faisabilité
    service matching
    service IA

Cette architecture peut être pertinente à grande échelle, mais elle ajoute aussi :

- plusieurs déploiements ;
- des communications réseau ;
- davantage de supervision ;
- davantage de configuration ;
- plus de tests d'intégration.

Pour le démonstrateur Match-Immo, ce niveau de complexité n'apporte pas de valeur suffisante.

Le choix retenu est donc de commencer simple et de faire évoluer l'architecture uniquement si des mesures réelles le justifient.

---

## 4. Vue générale

Le fonctionnement global est :

    utilisateur
        ↓
    API FastAPI
        ↓
    services métier
        ↓
    PostgreSQL
        ↓
    résultat
        ↓
    validation humaine

Les services métier principaux sont :

- faisabilité ;
- matching ;
- chasseur-IA.

L'API ne contient pas elle-même les règles métier.

Elle reçoit une demande, appelle le bon service et retourne le résultat.

---

## 5. API

L'API sert de point d'entrée contrôlé.

Elle doit notamment :

- recevoir les requêtes ;
- vérifier les données reçues ;
- appeler le bon service métier ;
- retourner une réponse structurée ;
- gérer les erreurs de manière compréhensible.

Exemple actuellement implémenté :

    GET /demandes/{id_demande}/matching

Cet endpoint retourne les biens compatibles avec une demande, classés par score.

L'API ne calcule pas elle-même le matching : elle appelle le service métier dédié.

Cette séparation facilite les tests et évite de mélanger les responsabilités.

---

## 6. Module de faisabilité

Le module de faisabilité doit analyser une demande et déterminer si elle semble réaliste.

Il peut utiliser :

- budget ;
- secteur ;
- surface ;
- type de bien ;
- nombre de pièces ;
- données disponibles dans la base.

Il produit notamment :

- un niveau de faisabilité ;
- les critères les plus restrictifs ;
- une explication ;
- d'éventuelles pistes de reformulation.

Le cœur de ce module repose d'abord sur des règles et calculs déterministes.

Une **règle déterministe** produit toujours le même résultat pour les mêmes données.

---

## 7. Module de matching

Le module de matching compare une demande à plusieurs biens.

Le fonctionnement retenu est :

    demande
        +
    biens
        ↓
    préfiltrage
        ↓
    calcul des scores
        ↓
    classement
        ↓
    explication

Le **préfiltrage** élimine les biens incompatibles avec certains critères obligatoires.

Le score utilise notamment :

- secteur ;
- prix ;
- surface ;
- type de bien ;
- nombre de pièces ;
- DPE.

Le détail du score reste accessible afin qu'un acteur métier puisse comprendre pourquoi un bien est mieux classé qu'un autre.

---

## 8. Module chasseur-IA

Le chasseur-IA utilise les résultats produits par les services métier.

Il peut :

- résumer une faisabilité ;
- expliquer un classement ;
- proposer une reformulation ;
- préparer une synthèse ;
- signaler un besoin d'intervention humaine.

Il ne doit pas modifier arbitrairement :

- les scores ;
- les montants ;
- les caractéristiques des biens ;
- les règles métier.

Lorsqu'un LLM est utilisé, son rôle reste principalement la génération ou la reformulation de texte.

Le calcul métier reste séparé.

---

## 9. Séparation entre règles métier et IA

Toutes les fonctions ne nécessitent pas une intelligence artificielle.

Le principe retenu est :

    règle simple
    → code déterministe

    comparaison de biens
    → moteur de matching

    reformulation ou synthèse
    → IA éventuelle

    décision importante
    → humain

Exemple :

    prix du bien > budget maximum

est une règle simple.

Il serait inutile et moins fiable de demander à un LLM de décider ce résultat.

Cette séparation améliore :

- l'explicabilité ;
- la fiabilité ;
- les tests ;
- la sécurité ;
- la maîtrise des coûts.

---

## 10. Accès aux données

L'accès aux données est centralisé dans une couche dédiée.

Le backend utilise SQLAlchemy pour dialoguer avec PostgreSQL.

Cela permet de séparer :

    logique métier
        ↓
    accès aux données
        ↓
    PostgreSQL

Le code de matching n'a donc pas besoin de connaître tous les détails techniques de connexion à la base.

Pour les requêtes SQL complexes ou les analyses de performance, du SQL explicite peut toujours être utilisé.

---

## 11. PostgreSQL

PostgreSQL reste la base principale.

Ce choix est cohérent avec les phases précédentes et permet de conserver :

- le modèle métier existant ;
- les contraintes ;
- les relations ;
- les index ;
- l'historisation ;
- les données analytiques déjà préparées.

Aucune nouvelle base NoSQL, vectorielle ou spécialisée n'est nécessaire pour le démonstrateur actuel.

Une technologie supplémentaire ne sera ajoutée que si un besoin réel le justifie.

---

## 12. Flux principal du démonstrateur

Le parcours principal est :

    demande du particulier
        ↓
    analyse de faisabilité
        ↓
    préfiltrage des biens
        ↓
    matching
        ↓
    classement
        ↓
    synthèse chasseur-IA
        ↓
    validation humaine
        ↓
    résultat transmis

Ce flux correspond directement aux maquettes et au schéma du programme d'IA.

---

## 13. Gestion des erreurs

Le système doit gérer les erreurs de manière compréhensible.

Exemples :

- demande inexistante ;
- données invalides ;
- aucun bien compatible ;
- erreur interne ;
- donnée manquante.

Une erreur technique ne doit pas exposer inutilement :

- mot de passe ;
- chaîne de connexion ;
- détails internes de la base ;
- trace technique sensible.

Le message retourné doit permettre à l'utilisateur ou au développeur de comprendre ce qui s'est passé sans exposer d'informations inutiles.

---

## 14. Sécurité et RGPD

Les principes retenus sont :

- accès limité aux données nécessaires ;
- séparation des responsabilités ;
- aucune exposition directe de PostgreSQL au LLM ;
- validation des entrées API ;
- limitation des données personnelles transmises aux composants IA ;
- traçabilité des traitements importants.

Le matching n'a pas besoin du nom, de l'email ou du téléphone du particulier.

Il utilise principalement les critères immobiliers.

Cela applique le principe RGPD de minimisation des données.

Les écritures importantes doivent passer par les services métier du backend et non par un composant IA directement connecté à la base.

---

## 15. Accessibilité

L'architecture doit permettre à une future interface de respecter les principes d'accessibilité.

Les maquettes prévoient notamment :

- informations textuelles explicites ;
- boutons identifiables ;
- hiérarchie claire ;
- navigation simple ;
- informations qui ne reposent pas uniquement sur une couleur.

L'accessibilité détaillée fera également l'objet du livrable transverse prévu par la grille.

---

## 16. Éco-conception

Le choix d'un monolithe modulaire limite le nombre de services à déployer.

Le système évite également d'utiliser un modèle IA pour des calculs simples.

Cela réduit :

- les ressources nécessaires ;
- les composants à maintenir ;
- les appels inutiles à des services externes ;
- la complexité d'exploitation.

Le principe est d'utiliser la solution la plus simple capable de répondre correctement au besoin.

---

## 17. Évolutivité

L'architecture reste évolutive.

Des composants pourraient être séparés plus tard si des besoins réels apparaissent.

Exemples :

- service de matching très sollicité ;
- traitement IA lourd ;
- volumétrie fortement accrue ;
- besoin de montée en charge indépendante.

Cette évolution devra être fondée sur des mesures, conformément à la stratégie définie en Phase 3.

---

## 18. Technologies retenues

### Python

Python est utilisé pour le backend.

Il est adapté au projet car il possède un écosystème mature pour :

- API ;
- données ;
- tests ;
- intelligence artificielle.

Il permet également d'utiliser un même langage pour les règles métier, le matching et les futurs traitements IA.

### FastAPI

FastAPI est le framework retenu pour créer l'API.

Il apporte notamment :

- validation des entrées ;
- typage ;
- documentation OpenAPI automatique ;
- simplicité de test ;
- performances adaptées au démonstrateur.

Il est plus directement adapté à une API que Flask, qui demande davantage d'assemblage manuel.

Django n'est pas retenu car son périmètre complet de framework web serait plus lourd que nécessaire ici.

### SQLAlchemy

SQLAlchemy est utilisé pour l'accès à PostgreSQL depuis Python.

Il permet :

- de représenter les tables sous forme de classes ;
- de centraliser les connexions ;
- de limiter le SQL dispersé dans le code ;
- de faciliter les tests et l'évolution.

### PostgreSQL

PostgreSQL est conservé car il est déjà utilisé et validé dans le projet.

Aucune nouvelle base n'est nécessaire pour le besoin actuel.

### pytest

pytest est utilisé pour les tests automatisés.

Il permet de vérifier simplement :

- les fonctions de matching ;
- les règles métier ;
- les endpoints API ;
- les cas d'erreur.

Les tests peuvent ensuite être rejoués automatiquement dans une chaîne CI.

---

## 19. Pourquoi aucun framework IA lourd n'est retenu

Le cœur du démonstrateur repose actuellement sur :

- des règles ;
- des calculs ;
- du scoring ;
- du classement.

Ces traitements peuvent être développés en Python simple.

Ajouter immédiatement un framework IA lourd augmenterait la complexité sans besoin concret.

Un outil supplémentaire sera introduit uniquement lorsqu'une fonction réelle le nécessitera.

---

## 20. Décision d'architecture

L'architecture retenue est donc :

    FastAPI
        ↓
    monolithe modulaire Python
        ↓
    services métier
        ↓
    SQLAlchemy
        ↓
    PostgreSQL

avec, lorsque cela apporte une valeur réelle :

    services métier
        ↓
    chasseur-IA / LLM éventuel
        ↓
    validation humaine

Cette architecture est retenue parce qu'elle est :

- simple ;
- explicable ;
- testable ;
- adaptée au développement individuel ;
- cohérente avec les phases précédentes ;
- suffisamment évolutive pour les besoins futurs.

Le choix principal reste :

> commencer avec une architecture simple et mesurable, puis complexifier uniquement lorsqu'un besoin réel le justifie.
