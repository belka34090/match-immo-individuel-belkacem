# Preuve — Vérification des anomalies métier

## Objectif

Vérifier les incohérences métier signalées dans les fixtures.

## 1. Rôle du client dans les mandats

### Résultat

| Mandat | client_id | Nom | Prénom | Rôle réel |
|---:|---:|---|---|---|
| 13 | 3 | Delacroix | Inès | `chasseur` |

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

| Mandat | Date début | Date fin théorique | Statut |
|---:|---|---|---|
| 4 | 2025-05-20 | 2025-11-20 | `actif` |
| 7 | 2025-09-01 | 2026-03-01 | `actif` |
| 9 | 2025-10-02 | 2026-04-02 | `actif` |
| 10 | 2025-11-14 | 2026-05-14 | `actif` |
| 11 | 2026-01-05 | 2026-07-05 | `actif` |
| 12 | 2026-01-20 | 2026-07-20 | `actif` |

### Conclusion

Six mandats sont toujours marqués `actif` alors que leur durée théorique de six mois est dépassée au 25/07/2026.

Cette situation est incohérente sauf si ces mandats ont été renouvelés, information qui n'est pas représentée dans le modèle actuel.
