# SWOT — Système d'information existant

## Forces

- Base de données simple et facile à comprendre.
- Présence de clés primaires et de clés étrangères.
- Adresse email contrainte en unicité.
- Rôles et statuts encadrés par des valeurs autorisées.
- Structure suffisante pour gérer un premier niveau de suivi des mandats.

## Faiblesses

- Clients et chasseurs regroupés dans une seule table.
- Les clés étrangères ne garantissent pas le bon rôle métier.
- Présence d'une incohérence confirmée : un chasseur est référencé comme client dans un mandat.
- Absence de `date_fin` et de mécanisme de suivi du renouvellement des mandats.
- Plusieurs mandats restent `actif` alors que leur durée théorique de six mois est dépassée.
- Critères de recherche stockés en texte libre, difficiles à exploiter pour le filtrage et l'analyse.
- Couverture fonctionnelle limitée à trois tables.

## Opportunités

- Structurer davantage les données métier.
- Améliorer le contrôle de cohérence des rôles.
- Automatiser le calcul de la durée et du statut des mandats.
- Structurer les critères de recherche pour permettre des analyses et traitements automatisés.
- Étendre le modèle aux autres étapes du parcours métier.

## Menaces

- Risque de décisions basées sur des données incohérentes.
- Risque de mauvais suivi des mandats arrivés à échéance.
- Difficulté à faire évoluer le système sans refonte du modèle.
- Risque d'erreurs métier si les contrôles restent principalement manuels.
- Limitation des futurs traitements décisionnels ou IA si les données restent peu structurées.