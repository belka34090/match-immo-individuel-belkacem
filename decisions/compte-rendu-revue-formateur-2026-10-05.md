# Compte rendu de revue avec une partie prenante — 05/10/2026

## 1. Contexte

Cette revue intermédiaire porte sur le dépôt individuel Match-Immo et sur la lisibilité des livrables produits.

La partie prenante consultée est le formateur / encadrant du projet, déjà identifié comme acteur consulté dans le RACI.

L'échange est réel et a eu lieu le 05/10/2026. Il ne s'agit pas d'un atelier fictif ni d'une validation finale du projet.

## 2. Retour reçu

Le formateur indique qu'il n'a pas encore terminé la lecture de l'ensemble des documents, mais que, sur la partie déjà lue, il estime que le travail est globalement correct.

Trois remarques concrètes sont formulées :

1. le dépôt contient beaucoup de documentation et certains documents sont trop longs à lire ;
2. des captures d'écran / éléments visuels doivent être ajoutés pour appuyer certaines preuves ;
3. un mot de passe apparaît en clair dans `docker-compose.yml` et doit être externalisé dans un fichier `.env`, avec un `.env.example` versionné.

Le retour sur les documents mentionne explicitement qu'un document d'environ 2 300 lignes est difficile à lire et qu'il faut découper certains documents.

## 3. Actions engagées à la suite de la revue

### 3.1 Externalisation des secrets — réalisée

Les identifiants PostgreSQL et Citus ont été retirés des fichiers Compose versionnés.

Le dépôt contient désormais un `.env.example` servant de modèle, tandis que le fichier `.env` local est ignoré par Git.

Le backend exige explicitement la variable `DATABASE_URL`.

La configuration CI fournit une URL de base dédiée aux tests standards sans introduire de secret réel dans le dépôt.

Contrôles réalisés le 05/10/2026 :

- suite standard : `47 passed, 5 skipped` ;
- suite complète avec PostgreSQL réel : `52 passed in 0.37s` ;
- conteneur PostgreSQL de développement confirmé `healthy` sur le port 5433 ;
- GitHub Actions : run `#54` terminé avec le statut `success`.

### 3.2 Découpage des documents volumineux — réalisé

Trois documents de plus de 2 200 lignes ont été transformés en points d'entrée courts et leur contenu détaillé a été réparti par responsabilité :

- journal des décisions : 2 341 lignes avant découpage ;
- documentation OLTP / OLAP : 2 237 lignes avant découpage ;
- dossier PCA / PRA : 2 450 lignes avant découpage.

Après découpage, le contenu est conservé dans des fichiers thématiques plus courts, avec un index à l'ancien emplacement afin de préserver un point d'entrée stable.

Le dernier workflow GitHub Actions associé à cette réorganisation, run `#66`, est terminé avec le statut `success`.

### 3.3 Preuves visuelles — à compléter

Le retour demande également davantage de captures d'écran pour appuyer certaines preuves techniques.

Cette action reste à réaliser à partir de captures réelles. Aucune image de preuve ne doit être fabriquée ou reconstituée artificiellement.

## 4. Impact sur le pilotage

Cette revue constitue une interaction réelle avec une partie prenante du projet.

Elle a produit des remarques vérifiables et a entraîné des corrections concrètes sur :

- la gestion des secrets ;
- la lisibilité documentaire ;
- la stratégie de présentation des preuves.

La remarque sur les captures d'écran reste ouverte jusqu'à l'ajout de preuves visuelles réelles.

## 5. Statut

| Retour | Statut au 05/10/2026 |
| --- | --- |
| Externaliser les secrets | Réalisé et testé |
| Découper les documents trop longs | Réalisé |
| Ajouter des preuves visuelles | À compléter |

Ce compte rendu documente la revue réelle et les actions qui en découlent. Il ne remplace pas la capture originale de l'échange, qui devra être conservée comme preuve visuelle lorsque celle-ci sera ajoutée au dépôt.
