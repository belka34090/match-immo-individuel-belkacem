# Périmètre fonctionnel — Phase 4

## Objectif

Ce document définit le périmètre fonctionnel réellement retenu pour la Phase 4 du projet Match-Immo.

Les parcours futurs du particulier et du chasseur ont permis d’identifier de nombreuses évolutions possibles.

Toutes ces évolutions ne doivent pas nécessairement être développées dans le démonstrateur.

L’objectif est donc de distinguer :

- les fonctionnalités à réaliser ;
- les fonctionnalités à concevoir ou documenter ;
- les fonctionnalités qui restent hors du démonstrateur.

Cette distinction permet de rester conforme au besoin tout en évitant de développer une solution inutilement complexe.

---

## Principe de priorisation

La priorité est donnée aux fonctionnalités directement liées aux objectifs principaux de la Phase 4 :

- faisabilité d’une demande ;
- matching entre une demande et un bien ;
- chasseur-IA ;
- backend et API ;
- architecture applicative ;
- tests unitaires et fonctionnels ;
- qualité et traçabilité.

Les autres fonctionnalités du futur parcours restent importantes mais peuvent être décrites sans être entièrement développées.

---

## 1. Fonctionnalités à réaliser et démontrer

### 1.1 Analyse de faisabilité

Le système doit pouvoir analyser une demande immobilière et produire un indicateur de faisabilité.

Cette analyse doit notamment permettre :

- de comparer les critères d’une demande avec les biens disponibles ;
- d’identifier les critères les plus restrictifs ;
- de produire un résultat explicable ;
- de proposer des pistes simples d’ajustement.

La faisabilité constitue une fonctionnalité centrale du démonstrateur.

---

### 1.2 Matching entre demande et bien

Le système doit pouvoir mesurer le niveau de correspondance entre une demande et un bien.

Le matching doit permettre :

- de filtrer les incompatibilités évidentes ;
- de comparer plusieurs critères ;
- de produire un score de pertinence ;
- d’expliquer les principaux éléments du score ;
- de classer plusieurs biens.

Le modèle doit rester simple, compréhensible et testable.

---

### 1.3 Backend et API

Un backend doit être développé pour exécuter les règles métier.

Le **backend** est la partie du logiciel qui traite les données et les règles côté serveur.

Une **API** est une interface permettant aux différentes parties du système de communiquer entre elles.

Le backend devra au minimum permettre :

- de recevoir les données nécessaires à une demande ;
- d’analyser sa faisabilité ;
- de lancer un matching ;
- de retourner les résultats ;
- de gérer les principales erreurs ;
- de permettre les tests automatisés.

---

### 1.4 Chasseur-IA limité

Le démonstrateur doit prévoir un chasseur-IA limité à des tâches clairement définies.

Il pourra notamment :

- exploiter le résultat de faisabilité ;
- utiliser les résultats du matching ;
- produire une synthèse ;
- proposer des pistes de reformulation ;
- préparer une sélection de biens ;
- signaler lorsqu’une intervention humaine est nécessaire.

Le chasseur-IA ne doit pas remplacer toutes les fonctions du chasseur humain.

---

### 1.5 Tests unitaires

Des tests unitaires doivent vérifier les principales règles métier.

Un **test unitaire** vérifie une petite partie précise du code de manière isolée.

Les tests devront notamment couvrir :

- le calcul de faisabilité ;
- les règles de filtrage ;
- le calcul du score de matching ;
- les cas limites ;
- les erreurs attendues.

---

### 1.6 Tests fonctionnels

Des tests fonctionnels doivent vérifier que plusieurs composants fonctionnent correctement ensemble.

Un **test fonctionnel** vérifie un comportement complet du point de vue du besoin métier.

Exemples :

    demande réaliste
            ↓
    analyse
            ↓
    résultat de faisabilité cohérent

ou :

    demande
        +
    plusieurs biens
            ↓
    matching
            ↓
    classement attendu

---

## 2. Fonctionnalités à concevoir ou documenter

Les fonctionnalités suivantes doivent être prises en compte dans la conception du futur système, mais elles ne nécessitent pas une implémentation complète dans le démonstrateur.

### 2.1 Personnalisation de la présentation du chasseur

Le système pourra produire une présentation adaptée du chasseur affecté.

Cette fonction sera décrite dans la conception mais ne constitue pas le cœur du démonstrateur.

---

### 2.2 Apprentissage des préférences

Les sélections, rejets et commentaires du particulier pourront servir à détecter des préférences.

Le démonstrateur n’a pas besoin d’entraîner un modèle complexe.

Une approche future pourra utiliser :

- des règles ;
- des comportements répétés ;
- l’historique des versions de demande.

---

### 2.3 Automatisation de la prise de rendez-vous

L’organisation de rendez-vous peut être automatisée avec des règles classiques.

Cette fonction sera décrite mais ne nécessite pas d’intégration réelle avec un calendrier externe dans le démonstrateur.

---

### 2.4 Pré-rédaction des avis

Une intelligence artificielle pourra préparer un brouillon à partir de données vérifiées.

La validation finale reste sous responsabilité du chasseur.

Cette fonction peut être conçue sans être développée intégralement.

---

### 2.5 Aide à la négociation

Le système pourra proposer plusieurs scénarios d’offre.

Les scénarios doivent rester explicables et soumis à validation humaine.

Cette fonction reste hors du noyau de développement de la Phase 4.

---

### 2.6 Vérification des factures

Le futur système pourra comparer la facture du chasseur avec la rémunération calculée.

Les contrôles simples pourront être automatisés.

La lecture automatique de documents PDF ou l’OCR ne font pas partie du noyau du démonstrateur.

---

### 2.7 Renouvellement du mandat

Le système pourra détecter les échéances et préparer une synthèse pour le chasseur.

La décision de renouvellement reste humaine.

Cette fonctionnalité sera documentée mais ne nécessite pas de développement complet.

---

### 2.8 Personnalisation après achat

Des contenus ou services pourront être proposés après la transaction selon le contexte du particulier.

Cette fonctionnalité reste une évolution future.

---

## 3. Hors périmètre du démonstrateur

Les éléments suivants ne seront pas développés intégralement dans la Phase 4 :

- plateforme immobilière complète de production ;
- intégration réelle avec toutes les plateformes d’annonces ;
- moteur de négociation autonome ;
- signature automatique de documents ;
- renouvellement automatique des mandats ;
- OCR complet des factures ;
- entraînement d’un grand modèle d’intelligence artificielle ;
- remplacement complet du chasseur humain ;
- système autonome prenant des décisions contractuelles.

---

## 4. Périmètre du démonstrateur retenu

Le démonstrateur se concentre donc sur la chaîne suivante :

    demande du particulier
            ↓
    analyse de faisabilité
            ↓
    filtrage des biens incompatibles
            ↓
    matching
            ↓
    classement des biens
            ↓
    synthèse ou recommandation du chasseur-IA
            ↓
    validation humaine

Cette chaîne permet de démontrer les principales capacités attendues sans construire l’intégralité de la future plateforme.

---

## 5. Principes de conception

La conception devra respecter plusieurs principes.

### Simplicité

Une règle classique doit être utilisée lorsqu’elle suffit.

L’intelligence artificielle ne doit pas être ajoutée uniquement pour rendre la solution plus complexe.

### Explicabilité

Les principaux résultats doivent pouvoir être expliqués.

Par exemple, un score de matching doit pouvoir indiquer quels critères ont augmenté ou diminué la correspondance.

### Contrôle humain

Les décisions importantes restent sous contrôle humain.

### Traçabilité

Les résultats, modifications et décisions importantes doivent pouvoir être retrouvés et expliqués.

### Protection des données

Les données personnelles utilisées doivent respecter les règles RGPD définies dans le projet.

### Évolutivité

La solution doit pouvoir évoluer plus tard sans obliger à reconstruire entièrement le système.

---

## 6. Décision de périmètre

Le périmètre retenu pour la réalisation de la Phase 4 est donc :

    FAISABILITÉ
        +
    MATCHING
        +
    BACKEND / API
        +
    CHASSEUR-IA LIMITÉ
        +
    TESTS
        +
    QUALITÉ ET TRAÇABILITÉ

Les autres fonctionnalités identifiées dans les parcours futurs sont conservées comme besoins d’évolution et éléments de conception.
