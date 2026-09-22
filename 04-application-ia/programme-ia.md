# Schéma du programme d’IA — Phase 4

## 1. Objectif

Ce document explique comment l'intelligence artificielle s'intègre dans le démonstrateur Match-Immo.

Le programme d'IA ne correspond pas à un seul modèle autonome.

Il combine plusieurs composants :

- règles métier ;
- calculs déterministes ;
- moteur de matching ;
- éventuelle génération de texte par LLM ;
- validation humaine ;
- sécurité ;
- traçabilité.

Le principe général est :

    données métier
        ↓
    règles et calculs
        ↓
    faisabilité / matching
        ↓
    chasseur-IA
        ↓
    éventuel LLM
        ↓
    validation humaine

---

## 2. Pourquoi séparer les composants

Toutes les tâches ne nécessitent pas le même outil.

Exemple :

    prix du bien > budget maximum

est une règle simple.

Elle doit être calculée par du code classique, car ce résultat est :

- fiable ;
- reproductible ;
- testable ;
- explicable.

À l'inverse, transformer plusieurs résultats en une synthèse claire peut bénéficier d'un modèle de langage.

Le choix retenu est donc :

    calcul métier
    → règles déterministes

    classement
    → moteur de matching

    reformulation / synthèse
    → LLM éventuel

    décision importante
    → humain

Cette séparation limite la complexité et réduit les risques d'invention.

---

## 3. Module de faisabilité

Le module de faisabilité analyse une demande immobilière par rapport aux données disponibles.

Il peut notamment utiliser :

- budget ;
- secteur ;
- surface ;
- type de bien ;
- nombre de pièces.

Il doit produire :

- un niveau de faisabilité ;
- les critères les plus restrictifs ;
- une explication ;
- d'éventuelles pistes de reformulation.

Le cœur du calcul reste déterministe.

L'IA peut éventuellement reformuler le résultat pour le rendre plus compréhensible.

---

## 4. Module de matching

Le module de matching compare une demande à plusieurs biens.

Le fonctionnement retenu est :

    préfiltrage
        ↓
    calcul des features
        ↓
    pondération
        ↓
    score
        ↓
    classement
        ↓
    explication

Le démonstrateur utilise notamment :

- secteur ;
- prix ;
- surface ;
- type de bien ;
- nombre de pièces ;
- DPE.

Le moteur retourne un score sur 100 ainsi que le détail de chaque contribution.

Exemple réel :

    Bien 2
    → 100 / 100

    Bien 1
    → 98,57 / 100

La différence est expliquée par la surface.

Le matching n'est donc pas une boîte noire.

---

## 5. Chasseur-IA

Le chasseur-IA utilise les résultats produits par les services métier.

Il peut notamment :

- résumer une faisabilité ;
- expliquer un classement ;
- proposer une reformulation ;
- préparer une synthèse ;
- signaler un besoin d'intervention humaine.

Il ne peut pas :

- modifier arbitrairement un score ;
- inventer une caractéristique de bien ;
- modifier seul une demande ;
- décider seul d'une offre ;
- prendre une décision contractuelle.

Le chasseur-IA est donc un assistant, pas un remplaçant du professionnel.

---

## 6. Place du LLM

Un **LLM** est un modèle de langage capable de générer ou reformuler du texte.

Dans Match-Immo, son usage éventuel est limité à des fonctions comme :

- résumer ;
- expliquer ;
- reformuler ;
- préparer un brouillon.

Il ne doit pas être utilisé pour :

- calculer un score métier ;
- modifier des montants ;
- inventer des informations ;
- décider seul d'une action importante.

Le principe retenu est :

    données vérifiées
        ↓
    calculs fiables
        ↓
    LLM éventuel
        ↓
    texte proposé

et non :

    LLM
        ↓
    décision métier

---

## 7. Données utilisées

Les données proviennent de PostgreSQL.

Les principales tables utilisées par le démonstrateur sont :

- `version_demande` ;
- `version_demande_secteur` ;
- `secteur` ;
- `bien`.

Le composant IA ne doit pas recevoir l'ensemble des données disponibles.

Le matching n'a par exemple pas besoin de connaître :

- le nom complet du particulier ;
- son email ;
- son téléphone.

Le principe appliqué est donc :

    traitement
        ↓
    uniquement les données nécessaires

Cette approche respecte le principe RGPD de minimisation.

---

## 8. Accès aux données et sécurité

Un composant IA ne doit pas disposer d'un accès libre à toute la base.

Le fonctionnement retenu est :

    PostgreSQL
        ↓
    backend contrôlé
        ↓
    sélection des données nécessaires
        ↓
    composant IA

Le LLM n'accède donc pas directement à PostgreSQL.

Les écritures importantes restent sous le contrôle des services métier du backend.

Lorsqu'un composant IA consulte des données, un accès limité et idéalement en lecture seule est privilégié.

---

## 9. Souveraineté des traitements

Avant d'utiliser un service IA externe, il faut connaître :

- le lieu de traitement des données ;
- les conditions de conservation ;
- les données réellement envoyées ;
- les possibilités de pseudonymisation ;
- l'existence éventuelle d'une solution locale.

La **pseudonymisation** consiste à remplacer une information directement identifiable par un identifiant indirect.

Exemple :

    Jean Dupont
        ↓
    client_1842

L'objectif est de limiter l'exposition de données personnelles.

---

## 10. Contrôle humain

Le contrôle humain reste obligatoire pour les décisions importantes.

Le système peut :

- analyser ;
- classer ;
- expliquer ;
- proposer.

L'humain conserve la décision finale pour :

- modifier une demande ;
- sélectionner certains biens ;
- valider un avis ;
- préparer une offre ;
- renouveler un mandat ;
- prendre une décision contractuelle.

Le principe est :

    système
    propose
        ↓
    humain
    contrôle
        ↓
    humain
    décide

---

## 11. Traçabilité

Les traitements importants doivent pouvoir être retrouvés.

Il doit être possible de savoir :

- quelle demande a été analysée ;
- quelles données ont été utilisées ;
- quel score a été calculé ;
- quels biens ont été classés ;
- quelle recommandation a été produite ;
- si un humain l'a validée ou refusée.

Cette traçabilité est utile pour :

- les tests ;
- le contrôle ;
- la sécurité ;
- l'explicabilité ;
- la soutenance.

---

## 12. Gestion des données inconnues

Une information absente ne doit jamais être inventée.

Exemple :

    DPE non renseigné

ne doit jamais devenir :

    DPE = C

Le système doit indiquer que la donnée est indisponible.

Le même principe s'applique à toutes les informations manquantes.

---

## 13. Schéma logique

Le schéma visuel officiel associé à ce document est :

    programme-ia.png

Il représente :

- l'utilisateur ;
- l'API FastAPI ;
- les traitements métier et IA ;
- PostgreSQL ;
- les contrôles sécurité / RGPD ;
- le LLM optionnel ;
- la validation humaine ;
- la traçabilité.

Le flux principal est :

    utilisateur
        ↓
    API
        ↓
    faisabilité / matching
        ↓
    chasseur-IA
        ↓
    LLM éventuel
        ↓
    validation humaine
        ↓
    résultat

---

## 14. Évolution future

Le programme pourra évoluer lorsque les besoins et les données le justifieront.

Exemples :

- apprentissage à partir des retours clients ;
- modèle de matching entraîné ;
- recherche sémantique ;
- traitement local par un modèle spécialisé ;
- analyse de texte plus avancée.

Ces évolutions ne sont pas nécessaires au démonstrateur actuel.

---

## 15. Décision de conception

Le programme d'IA Match-Immo repose donc sur :

    PostgreSQL
        ↓
    backend contrôlé
        ↓
    règles métier
        +
    faisabilité
        +
    matching
        ↓
    chasseur-IA
        ↓
    LLM éventuel
        ↓
    validation humaine
        ↓
    traçabilité

Le cœur métier reste déterministe et explicable.

L'intelligence artificielle intervient uniquement lorsqu'elle apporte une valeur réelle, principalement pour expliquer, reformuler ou synthétiser.
