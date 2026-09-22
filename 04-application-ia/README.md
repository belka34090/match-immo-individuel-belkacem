# Phase 4 — Application, parcours futur et intelligence artificielle

## 1. Contexte

Les trois premières phases du projet Match-Immo ont permis de :

* auditer le système d’information existant ;
* concevoir un modèle de données cible plus fiable ;
* préparer la reprise des données ;
* définir une architecture capable d’absorber la croissance ;
* séparer les usages transactionnels et analytiques ;
* tester plusieurs mécanismes de performance, de disponibilité et de reprise.

La Phase 4 répond maintenant à une nouvelle question :

> Comment utiliser ce nouveau système d’information pour améliorer concrètement le travail des chasseurs immobiliers et l’expérience des particuliers, notamment grâce à l’intelligence artificielle ?

Cette phase ne consiste donc plus principalement à organiser ou stocker les données.

Elle consiste à construire les services qui vont exploiter ces données.

---

## 2. Pourquoi cette phase est nécessaire

Le futur de Match-Immo prévoit :

* une augmentation importante du nombre de demandes ;
* davantage de biens analysés pour chaque recherche ;
* une extension géographique de l’activité ;
* des chasseurs humains devant traiter davantage de dossiers ;
* des zones qui pourraient ne pas disposer de chasseur humain ;
* l’utilisation future de chasseurs assistés ou remplacés partiellement par une intelligence artificielle.

Sans assistance automatisée, certaines tâches deviendraient difficiles à réaliser manuellement à grande échelle.

Par exemple :

* analyser des centaines ou milliers de biens pour une seule demande ;
* supprimer les annonces en double ;
* comparer chaque bien avec les critères d’un client ;
* identifier rapidement les biens les plus pertinents ;
* comprendre les préférences d’un client au fil de ses choix ;
* estimer si une recherche immobilière est réaliste ;
* assister le chasseur dans la rédaction de ses recommandations.

L’objectif de la Phase 4 est donc d’automatiser ou d’assister ces tâches sans supprimer le contrôle humain lorsque celui-ci reste nécessaire.

---

## 3. Les acteurs concernés

### Le particulier

Le particulier est la personne qui recherche un bien immobilier.

Le futur système doit l’aider à :

* comprendre si son projet est réaliste ;
* ajuster ses critères de recherche ;
* recevoir des biens réellement pertinents ;
* bénéficier d’une expérience plus personnalisée ;
* faire évoluer sa recherche en fonction de ses propres choix.

---

### Le chasseur immobilier

Le chasseur accompagne le particulier dans sa recherche.

Le futur système doit lui permettre de :

* traiter davantage de demandes ;
* obtenir une première analyse automatique d’un projet ;
* recevoir des biens déjà triés et comparés ;
* identifier les biens les plus pertinents ;
* détecter les annonces en double ;
* préparer ses recommandations plus rapidement ;
* obtenir une aide à la négociation ;
* améliorer une recherche lorsqu’un mandat doit être renouvelé.

L’intelligence artificielle ne remplace donc pas systématiquement le chasseur.

Elle agit d’abord comme un outil d’assistance.

---

### Le chasseur-IA

Le projet prévoit également qu’un système automatisé puisse intervenir dans des zones où aucun chasseur humain n’est disponible.

Le chasseur-IA représente donc un ensemble de services capables d’exécuter certaines tâches habituellement réalisées par un chasseur humain.

Il ne s’agit pas nécessairement d’un seul modèle d’intelligence artificielle.

Il peut s’agir de plusieurs composants spécialisés :

* analyse de faisabilité ;
* matching entre demande et biens ;
* recommandations ;
* génération de texte ;
* aide à la négociation ;
* analyse des préférences du client.

---

## 4. Les grands besoins métier du futur système

### 4.1 Évaluer la faisabilité d’une recherche

Lorsqu’un particulier indique :

* son budget ;
* la zone recherchée ;
* la surface souhaitée ;
* le nombre de pièces ;
* le type de bien ;
* ses autres critères ;

le système doit pouvoir comparer cette demande avec les biens disponibles.

Il pourra alors indiquer si la recherche semble :

* réaliste ;
* difficile ;
* très restrictive.

Le but n’est pas de décider à la place du client.

Le but est de lui fournir des informations lui permettant d’adapter sa recherche.

---

## 4.2 Trouver les biens les plus pertinents

Le système doit comparer une demande avec les biens disponibles.

Cette opération est appelée **matching**.

Le matching signifie simplement :

> mesurer à quel point un bien correspond à ce que recherche un client.

Exemple :

Un appartement peut correspondre :

* au budget ;
* à la ville ;
* au nombre de pièces ;

mais ne pas correspondre :

* à la surface minimale ;
* au DPE souhaité.

Le système devra pouvoir calculer un niveau de correspondance et classer les biens.

---

## 4.3 Apprendre des préférences du particulier

Un client peut déclarer certains critères au début de sa recherche puis montrer, par ses actions, des préférences différentes.

Exemple :

Il demande initialement :

> appartement avec balcon.

Mais il sélectionne régulièrement :

> des appartements anciens avec terrasse et grandes pièces.

Ses choix donnent donc de nouvelles informations sur ses goûts.

Le système pourra utiliser :

* les biens sélectionnés ;
* les biens rejetés ;
* les commentaires ;
* les visites ;

pour proposer des ajustements de la recherche.

---

## 4.4 Aider le chasseur à analyser les biens

Avant qu’un bien soit présenté au client, le système pourra :

* supprimer les doublons ;
* comparer les annonces ;
* filtrer les biens manifestement incompatibles ;
* classer les résultats ;
* signaler des caractéristiques intéressantes ;
* estimer certaines possibilités de négociation.

Le chasseur conserve ensuite la possibilité de valider ou non les recommandations.

---

## 4.5 Assister la rédaction

Le futur système pourra proposer une première rédaction pour :

* un avis sur un bien ;
* une synthèse de faisabilité ;
* une recommandation ;
* une présentation personnalisée du chasseur ;
* certains contenus destinés au client.

Le texte généré pourra ensuite être relu ou validé selon le niveau d’automatisation retenu.

---

## 5. Principe important : l’IA ne décide pas de tout

Le projet doit distinguer :

### ce qui peut être automatisé

Par exemple :

* dédoublonner des annonces ;
* calculer un score de correspondance ;
* filtrer des résultats ;
* produire une première synthèse.

### ce qui nécessite un contrôle

Par exemple :

* certaines recommandations importantes ;
* une décision ayant une conséquence financière ;
* une action engageant juridiquement le client ;
* l’accès à certaines données personnelles.

Cette séparation devra être définie précisément pendant la conception.

---

## 6. Les objectifs techniques de la Phase 4

Une fois les besoins métier compris, la Phase 4 devra permettre de concevoir :

* le nouveau backend ;
* l’API ;
* l’architecture applicative ;
* les services métier ;
* le système de matching ;
* les services d’intelligence artificielle ;
* les mécanismes de sécurité ;
* les maquettes ;
* les tests ;
* le suivi automatique de la qualité.

### Backend

Le **backend** est la partie du logiciel qui fonctionne côté serveur.

Il contient notamment :

* les règles métier ;
* les accès à la base de données ;
* les traitements ;
* les services utilisés par les interfaces utilisateur.

### API

Une **API** est une interface permettant à plusieurs logiciels de communiquer.

Par exemple :

```text
Application du particulier
        ↓
       API
        ↓
Backend Match-Immo
        ↓
PostgreSQL
```

L’application ne doit donc pas accéder directement à la base de données.

Elle passe par l’API.

---

## 7. Principe de conception retenu

La Phase 4 conservera le même principe que les phases précédentes :

> partir du besoin avant de choisir la technologie.

La démarche sera donc :

```text
Besoin métier
        ↓
Fonctionnalité
        ↓
Données nécessaires
        ↓
Architecture
        ↓
Choix technique
        ↓
Développement
        ↓
Tests
        ↓
Mesures
        ↓
Validation
```

Une technologie ne sera pas ajoutée simplement parce qu’elle est moderne ou populaire.

Elle devra résoudre un problème identifié.

---

## 8. Livrables prévus

La Phase 4 devra notamment produire :

* description du futur métier ;
* architecture applicative ;
* maquettes ;
* conception du backend et de l’API ;
* justification des patterns utilisés ;
* conception du modèle de matching ;
* description des features utilisées ;
* schéma du programme d’intelligence artificielle ;
* note de souveraineté et sécurité IA ;
* note d’accessibilité PSH ;
* plan de tests ;
* tests unitaires ;
* tests fonctionnels ;
* résultats des tests ;
* mécanisme de CI et de suivi qualité.

Une **feature** est une information utilisée par un algorithme ou un modèle pour prendre une décision.

Exemples :

* prix du bien ;
* budget maximal ;
* surface ;
* nombre de pièces ;
* secteur ;
* DPE.

Une **CI**, ou intégration continue, est un mécanisme qui exécute automatiquement certains contrôles, par exemple les tests, lorsqu’une modification est envoyée dans Git.

---

## 9. Ce que cette phase ne cherche pas à faire

La Phase 4 n’a pas pour objectif de :

* développer une plateforme immobilière complète destinée à la production ;
* entraîner un grand modèle de langage ;
* développer un modèle d’intelligence artificielle extrêmement complexe ;
* reproduire les systèmes de grandes plateformes immobilières ;
* remplacer systématiquement toutes les décisions humaines.

Le projet doit avant tout démontrer que le futur SI est :

* cohérent ;
* exploitable ;
* sécurisé ;
* testable ;
* évolutif ;
* capable d’alimenter des traitements d’intelligence artificielle.

---

## 10. Résultat attendu

À la fin de la Phase 4, le projet devra montrer comment Match-Immo peut passer :

```text
d’un système qui stocke les informations
```

à :

```text
un système qui exploite les informations
pour assister les clients,
les chasseurs
et les futurs services d’intelligence artificielle.
```

Cette phase constitue donc le lien entre les données préparées dans les phases précédentes et les futurs usages métier de Match-Immo.
