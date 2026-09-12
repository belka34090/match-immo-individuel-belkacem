# Conception du modèle de matching et des features — Phase 4

## 1. Objectif

Ce document explique comment Match-Immo compare une demande immobilière à des biens disponibles.

La question métier est simple :

> Parmi les biens disponibles, lesquels correspondent le mieux à la demande du particulier, et pourquoi ?

Le **matching** mesure cette compatibilité.

Une **feature** est une information utilisée pour effectuer cette comparaison.

Exemples :

- prix ;
- surface ;
- secteur ;
- type de bien ;
- nombre de pièces ;
- DPE.

Le démonstrateur utilise un système simple, explicable et testable. Aucun entraînement de modèle de machine learning n'est nécessaire à ce stade.

---

## 2. Principe général

Le fonctionnement retenu est :

    demande
        +
    biens disponibles
        ↓
    préfiltrage
        ↓
    calcul des features
        ↓
    score pondéré
        ↓
    classement
        ↓
    explication

Le **préfiltrage** élimine d'abord les biens qui ne respectent pas certains critères obligatoires.

Le scoring détaillé est ensuite appliqué uniquement aux biens restants.

Cette séparation évite de calculer un score sur des biens manifestement incompatibles.

---

## 3. Critères obligatoires et critères souhaités

Tous les critères n'ont pas le même rôle.

Un **critère obligatoire** peut exclure un bien.

Exemples retenus pour le démonstrateur :

- budget maximal ;
- secteur recherché ;
- type de bien souhaité.

Un **critère souhaité** peut réduire le score sans nécessairement exclure le bien.

Exemples :

- surface légèrement insuffisante ;
- nombre de pièces inférieur au souhait ;
- DPE moins bon que celui souhaité.

Cette distinction évite un moteur trop rigide.

---

## 4. Features retenues

### 4.1 Secteur

Le secteur possède un poids important car la localisation est souvent déterminante dans une recherche immobilière.

Si le bien appartient à un secteur demandé, il obtient la contribution maximale.

Dans le démonstrateur, un secteur incompatible est déjà écarté lors du préfiltrage.

---

### 4.2 Prix

Le prix du bien est comparé au budget maximal de la demande.

Si le bien dépasse un budget défini comme obligatoire, il est exclu avant le scoring.

Un bien restant sous le budget obtient donc la contribution maximale sur ce critère dans la première version du moteur.

---

### 4.3 Surface

La surface du bien est comparée à la surface minimale souhaitée.

Si le bien atteint ou dépasse la surface minimale :

    score surface = 1

S'il est légèrement inférieur, il conserve une partie du score.

Exemple :

    surface demandée : 80 m²
    surface du bien : 72 m²

    72 / 80 = 0,90

Le bien obtient donc 90 % de la contribution prévue pour la surface.

---

### 4.4 Type de bien

Le type de bien souhaité est comparé au type du bien disponible.

Exemples :

    Appartement ↔ Appartement
    Maison ↔ Maison

Dans le démonstrateur, lorsqu'un type est explicitement demandé, un type incompatible est éliminé lors du préfiltrage.

---

### 4.5 Nombre de pièces

Le nombre de pièces est comparé au minimum demandé.

Si le bien possède au moins le nombre demandé, il obtient la contribution maximale.

S'il en possède moins, le score est réduit proportionnellement.

---

### 4.6 DPE

Le DPE est comparé au niveau minimal souhaité.

Les classes sont ordonnées de :

    A
    ↓
    B
    ↓
    C
    ↓
    D
    ↓
    E
    ↓
    F
    ↓
    G

Un DPE égal ou meilleur que le minimum souhaité obtient la contribution maximale.

Un DPE moins bon réduit progressivement la contribution.

Une valeur absente n'est jamais inventée.

---

## 5. Pondération

La première pondération retenue est :

| Critère | Poids |
| --- | ---: |
| Secteur | 30 % |
| Prix | 25 % |
| Surface | 20 % |
| Type de bien | 10 % |
| Nombre de pièces | 10 % |
| DPE | 5 % |
| **Total** | **100 %** |

Ces valeurs constituent une première configuration du démonstrateur.

Elles ne sont pas présentées comme une vérité métier définitive.

Elles pourront être ajustées plus tard à partir :

- des retours métier ;
- des tests ;
- des usages réels ;
- de données historiques plus nombreuses.

---

## 6. Calcul du score

Chaque feature produit un score compris entre :

    0
    et
    1

Ce score est multiplié par le poids du critère.

Exemple :

    surface = 0,90
    poids surface = 20

    contribution = 18

Le score final est la somme des contributions :

    secteur
    + prix
    + surface
    + type
    + pièces
    + DPE
        ↓
    score final / 100

Le résultat reste donc compris entre `0` et `100`.

---

## 7. Exemple réel du démonstrateur

Pour la version courante de la demande `1`, les critères sont notamment :

    budget maximal : 300 000 €
    surface minimale : 70 m²
    nombre minimum de pièces : 3
    type souhaité : Appartement
    DPE minimum : C
    secteur : 1

Deux biens passent le préfiltrage.

### Bien 2

    prix : 275 000 €
    surface : 72 m²
    pièces : 3
    type : Appartement
    DPE : B

Résultat :

    secteur : 30,00
    prix : 25,00
    surface : 20,00
    type : 10,00
    pièces : 10,00
    DPE : 5,00

    score final : 100,00 / 100

### Bien 1

    prix : 250 000 €
    surface : 65 m²
    pièces : 3
    type : Appartement
    DPE : C

La surface est inférieure au minimum souhaité de 70 m².

Contribution surface :

    65 / 70 × 20
    = 18,57

Résultat :

    score final : 98,57 / 100

Le bien 2 est donc classé avant le bien 1.

Le résultat est compréhensible : la différence provient uniquement de la surface.

---

## 8. Données utilisées

Le matching s'appuie sur les données PostgreSQL existantes.

Les tables principales sont :

- `version_demande` ;
- `version_demande_secteur` ;
- `secteur` ;
- `bien`.

La Phase 4 a ajouté de manière additive dans `version_demande` :

- `type_bien_souhaite` ;
- `dpe_min`.

Ces deux données étaient nécessaires pour comparer correctement le souhait du particulier aux caractéristiques déjà présentes dans `bien`.

Cette évolution est isolée dans :

    evolution-matching.sql

Elle ne remet pas en cause le modèle validé en Phase 2.

---

## 9. Pourquoi ne pas créer une base spécialisée

Les features utilisées sont structurées et déjà disponibles dans PostgreSQL.

Il n'est donc pas nécessaire d'ajouter :

- une base vectorielle ;
- une base NoSQL ;
- un moteur de recherche spécialisé.

Créer un nouveau stockage maintenant ajouterait de la complexité sans besoin réel.

Le principe reste :

> utiliser la technologie la plus simple capable de répondre correctement au besoin.

---

## 10. Pourquoi ne pas entraîner un modèle de machine learning maintenant

Un modèle supervisé nécessiterait suffisamment de données historiques fiables associant :

    demande
        +
    bien
        +
    résultat réel

Exemples de résultats exploitables :

- bien retenu ;
- bien rejeté ;
- visite réalisée ;
- offre déposée ;
- vente conclue.

Le jeu de données actuel est trop limité pour justifier un entraînement pertinent.

Le starter pack demande la conception du modèle et des features, pas l'entraînement.

Le choix d'un scoring déterministe est donc plus pertinent pour le démonstrateur.

---

## 11. Explicabilité

Le score final ne doit jamais être présenté seul.

Le système retourne également les contributions de chaque critère.

Exemple :

    score : 98,57 / 100

    secteur : 30,00
    prix : 25,00
    surface : 18,57
    type : 10,00
    pièces : 10,00
    DPE : 5,00

Cette transparence permet :

- au particulier de comprendre le résultat ;
- au chasseur de contrôler le classement ;
- au développeur de vérifier les calculs ;
- au jury de défendre le choix technique.

---

## 12. Place de l'intelligence artificielle

Le calcul du score n'a pas besoin d'un LLM.

Il repose sur des règles déterministes et testables.

Une intelligence artificielle peut éventuellement intervenir après le calcul pour :

- résumer le classement ;
- reformuler les résultats ;
- produire une explication plus naturelle ;
- préparer une synthèse pour le chasseur.

Le principe reste :

    calcul fiable
        ↓
    données vérifiées
        ↓
    éventuelle génération de texte

et non :

    LLM
        ↓
    score métier

---

## 13. Tests

Le moteur doit notamment vérifier :

- bien compatible ;
- dépassement du budget ;
- secteur incompatible ;
- type incompatible ;
- surface légèrement insuffisante ;
- nombre de pièces insuffisant ;
- DPE meilleur ou moins bon ;
- score compris entre 0 et 100 ;
- classement correct ;
- cohérence entre score et détail.

Ces tests sont automatisés avec `pytest`.

Le plan détaillé se trouve dans :

    plan-de-tests.md

---

## 14. Évolution future

Le moteur pourra évoluer plus tard avec :

- ajustement des poids ;
- préférences observées ;
- critères supplémentaires ;
- apprentissage à partir des retours clients ;
- modèle supervisé lorsque suffisamment de données fiables seront disponibles.

Ces évolutions ne sont pas nécessaires pour le démonstrateur actuel.

---

## 15. Décision de conception

Le modèle retenu pour la Phase 4 est donc :

    préfiltrage
        ↓
    scoring déterministe
        ↓
    pondération
        ↓
    score sur 100
        ↓
    classement
        ↓
    explication

Cette solution est retenue parce qu'elle est :

- simple ;
- explicable ;
- testable ;
- adaptée aux données disponibles ;
- évolutive ;
- cohérente avec le besoin métier.

Elle constitue une base fiable pour une évolution future vers des approches de machine learning lorsque les données réelles le permettront.
