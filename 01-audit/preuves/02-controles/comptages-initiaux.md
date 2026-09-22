# Preuve — Comptages initiaux

## Objectif

Vérifier les volumes présents dans les trois tables de l'existant après l'import.

## Requête exécutée

```sql
SET search_path TO "Fil_Rouge_Depart";

SELECT COUNT(*) AS secteurs
FROM secteurs;

SELECT COUNT(*) AS utilisateurs
FROM utilisateurs;

SELECT COUNT(*) AS mandats
FROM mandats;
```

## Résultats

| Table | Nombre de lignes |
|---|---:|
| `secteurs` | 10 |
| `utilisateurs` | 24 |
| `mandats` | 18 |

## Comparaison avec les valeurs attendues

| Table | Attendu | Obtenu | Statut |
|---|---:|---:|---|
| `secteurs` | 10 | 10 | Conforme |
| `utilisateurs` | 24 | 24 | Conforme |
| `mandats` | 18 | 18 | Conforme |

## Conclusion

Les volumes obtenus correspondent exactement aux valeurs attendues dans la documentation des fixtures.

L'import est donc validé pour la suite de l'audit.