# Futur métier — Parcours particulier

## 1. Objectif

Ce document décrit les principales évolutions prévues pour le parcours du particulier dans le futur système Match-Immo.

L'objectif est de rendre la recherche immobilière :

- plus compréhensible ;
- plus personnalisée ;
- plus réaliste ;
- plus progressive ;
- mieux accompagnée par le chasseur.

Le système peut utiliser des règles métier, du matching et éventuellement de l'intelligence artificielle, mais le particulier reste libre de ses choix.

---

## 2. Assistance à la faisabilité du projet immobilier

Lorsqu'un particulier renseigne sa demande, il peut être difficile pour lui de savoir si ses critères sont réalistes par rapport aux biens disponibles.

Le futur système doit donc analyser la faisabilité de la recherche dès la saisie des critères.

Il peut par exemple produire :

    recherche réaliste

ou :

    recherche difficile

ou :

    recherche très restrictive

Le résultat doit être expliqué.

Exemple :

    Budget : compatible
    Surface : restrictive
    Secteur : très restrictif

Le système peut ensuite proposer des pistes simples :

- élargir légèrement le secteur ;
- réduire une surface minimale ;
- revoir un critère secondaire ;
- conserver la recherche telle quelle.

Ces propositions ne doivent pas modifier automatiquement la demande.

Le particulier conserve le choix, éventuellement accompagné du chasseur.

La valeur principale est de comprendre rapidement pourquoi une recherche est simple ou difficile, au lieu de découvrir ce problème plusieurs semaines plus tard.

---

## 3. Présentation personnalisée du chasseur affecté

Lorsqu'un chasseur est affecté à une demande, le particulier doit comprendre qui l'accompagne et pourquoi cette personne est adaptée à sa recherche.

Le système peut présenter des informations vérifiées comme :

- secteur couvert ;
- expérience connue ;
- spécialisation éventuelle ;
- type de recherche traité ;
- contexte de la demande.

Exemple :

    Chasseur affecté : Marie Dupont

    Secteur :
    Montpellier et communes proches

    Expérience :
    recherches d'appartements familiaux

    Pourquoi cette affectation :
    votre demande concerne une zone et un type de bien
    correspondant à son périmètre d'intervention.

Une intelligence artificielle peut aider à rédiger cette présentation de manière plus naturelle.

Elle ne doit jamais inventer :

- une expérience inexistante ;
- une spécialisation non enregistrée ;
- un taux de réussite non connu ;
- une information personnelle non vérifiée.

Le but est d'améliorer la confiance et la compréhension du rôle du chasseur.

---

## 4. Prendre en compte les préférences révélées

Les critères déclarés au début d'une recherche ne décrivent pas toujours complètement les préférences réelles du particulier.

Ses choix peuvent progressivement révéler de nouvelles tendances.

Exemple :

    plusieurs biens avec balcon sont sélectionnés

ou :

    plusieurs logements situés sur des axes très passants sont rejetés

Le système peut détecter ces répétitions et signaler une préférence possible.

Exemple :

    préférence observée :
    environnement calme

    suggestion :
    vérifier si ce critère doit être ajouté à la demande

Le système ne doit jamais modifier automatiquement la recherche.

Le particulier doit confirmer la nouvelle préférence, éventuellement avec le chasseur.

Lorsqu'une modification est validée, l'historisation via `version_demande` permet de conserver :

- la demande précédente ;
- la nouvelle demande ;
- l'origine de l'évolution.

Cette approche permet au système de mieux comprendre la recherche au fil du temps sans perdre la traçabilité.

Au début du projet, cette fonction peut reposer sur des règles simples plutôt que sur un modèle d'apprentissage complexe.

---

## 5. Contenus et services personnalisés après l'achat

Le parcours du particulier ne s'arrête pas nécessairement au moment de l'achat.

Après une vente, Match-Immo pourrait proposer des contenus ou services adaptés au contexte du bien.

Exemples :

- informations liées au déménagement ;
- services locaux ;
- rappels utiles ;
- contenus liés au logement ;
- accompagnement complémentaire.

Cette évolution appartient au futur parcours et n'est pas nécessaire au démonstrateur principal de Phase 4.

La personnalisation doit utiliser uniquement les données réellement nécessaires.

Elle ne doit pas conduire à :

- exposer inutilement des données personnelles ;
- inventer des offres ;
- transmettre des informations sans base légitime ;
- utiliser des données sans lien avec le service proposé.

Le principe RGPD reste donc :

    données nécessaires uniquement
        ↓
    traitement identifié
        ↓
    service utile au particulier

Une intelligence artificielle peut éventuellement aider à présenter ou résumer les contenus, mais elle ne doit pas créer de fausses offres ou de faux partenaires.

---

## 6. Place de l'intelligence artificielle

Toutes les évolutions du parcours particulier ne nécessitent pas une IA complexe.

Le choix retenu est :

    règles métier
    → faisabilité et contrôles fiables

    matching
    → comparaison des demandes et des biens

    historique
    → suivi de l'évolution des préférences

    IA / LLM éventuel
    → reformulation, explication et personnalisation du texte

    humain
    → validation des décisions importantes

Cette séparation évite d'utiliser l'intelligence artificielle lorsqu'une règle simple suffit.

Elle permet également :

- de mieux expliquer les résultats ;
- de réduire les risques d'invention ;
- de faciliter les tests ;
- de mieux protéger les données.

---

## 7. Contrôle et transparence

Le particulier doit savoir lorsqu'une recommandation ou une synthèse a été produite automatiquement.

Le système peut :

- analyser ;
- comparer ;
- suggérer ;
- expliquer.

Il ne doit pas :

- modifier seul la demande ;
- décider d'une offre d'achat ;
- inventer des caractéristiques de biens ;
- remplacer une décision contractuelle ;
- masquer l'intervention d'un système automatisé.

Lorsqu'une décision importante est nécessaire, le particulier et le chasseur gardent la maîtrise.

---

## 8. Parcours futur résumé

Le parcours particulier peut être résumé ainsi :

    saisie de la demande
        ↓
    analyse de faisabilité
        ↓
    éventuelle reformulation
        ↓
    affectation et présentation du chasseur
        ↓
    propositions de biens
        ↓
    matching et classement
        ↓
    retours du particulier
        ↓
    détection éventuelle de nouvelles préférences
        ↓
    validation humaine des évolutions
        ↓
    poursuite de la recherche
        ↓
    achat
        ↓
    éventuels services personnalisés

Le futur système accompagne progressivement le particulier sans lui retirer le contrôle de sa recherche.
