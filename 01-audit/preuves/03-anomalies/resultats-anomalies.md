# Preuve — Vérification des anomalies métier

## Objectif

Vérifier les incohérences métier signalées dans les fixtures et compléter l'audit par des contrôles de cohérence sur les données existantes.

## 1. Rôle du client dans les mandats

### Résultat

| Mandat | client_id | Nom       | Prénom | Rôle réel  |
| -----: | ---------: | --------- | ------ | ---------- |
|     13 |          3 | Delacroix | Inès   | `chasseur` |

### Conclusion

Le mandat `13` référence comme client un utilisateur ayant le rôle `chasseur`.

L'anomalie est confirmée.

## 2. Rôle du chasseur dans les mandats

### Résultat

Aucun mandat ne référence comme chasseur un utilisateur ayant le rôle `client`.

### Conclusion

Aucune anomalie détectée sur ce contrôle.

## 3. Durée des mandats actifs

Date de référence métier : **25/07/2026**.

La durée théorique d'un mandat est de six mois.

| Mandat | Date début | Date fin théorique | Statut  |
| -----: | ---------- | ------------------ | ------- |
|      4 | 2025-05-20 | 2025-11-20         | `actif` |
|      7 | 2025-09-01 | 2026-03-01         | `actif` |
|      9 | 2025-10-02 | 2026-04-02         | `actif` |
|     10 | 2025-11-14 | 2026-05-14         | `actif` |
|     11 | 2026-01-05 | 2026-07-05         | `actif` |
|     12 | 2026-01-20 | 2026-07-20         | `actif` |

### Conclusion

Six mandats sont toujours marqués `actif` alors que leur durée théorique de six mois est dépassée au 25/07/2026.

Cette situation est incohérente sauf si ces mandats ont été renouvelés, information qui n'est pas représentée dans le modèle actuel.

## 4. Cohérence temporelle entre les mandats et les utilisateurs

### Résultat

Aucun mandat ne commence avant la date de création de son client.

En revanche, le contrôle sur les chasseurs retourne :

| Mandat | Date début | chasseur_id | Nom    | Prénom | Date création |
| -----: | ---------- | ----------: | ------ | ------ | ------------- |
|      9 | 2025-10-02 |           6 | Perrin | Lucas  | 2025-11-03    |

### Conclusion

Le mandat `9` est daté du 02/10/2025 alors que le chasseur associé a une date de création au 03/11/2025.

Une incohérence temporelle est donc confirmée.

## 5. Contrôles complémentaires

Les contrôles suivants ont également été exécutés :

- doublons sur `(ville, quartier)` : aucun ;
- codes postaux manifestement invalides : aucun ;
- clients sans téléphone : 3 ;
- emails manifestement invalides : aucun ;
- incohérences entre rôle, `budget_max` et `taux_commission` : aucune ;
- budgets ou taux de commission non positifs : aucun ;
- références cassées dans les mandats : aucune ;
- mandats sans secteur : aucun ;
- descriptions de recherche absentes ou vides : aucune ;
- même utilisateur utilisé comme client et chasseur : aucun ;
- utilisateur créé après la date de référence du 25/07/2026 : aucun.

L'absence de téléphone pour trois clients est un constat de données, mais n'est pas classée comme anomalie métier car le schéma autorise cette valeur et aucune règle métier fournie n'impose actuellement le téléphone.

## Synthèse

Trois anomalies de données sont confirmées :

- A-01 : rôle incorrect du client sur le mandat 13 ;
- A-02 : six mandats actifs dépassant leur durée théorique de six mois ;
- A-03 : incohérence temporelle entre le mandat 9 et la date de création de son chasseur.
