# Preuve — Import de la fixture PostgreSQL

## Objectif

Vérifier que la fixture PostgreSQL fournie peut être exécutée correctement dans un environnement local.

## Commande exécutée

```bash
docker compose exec -T postgres \
  psql -U user -d DB_Cours \
  < sources/fixtures/PgSQL.sql
```

## Résultat de l'import

- Schéma supprimé puis recréé : `Fil_Rouge_Depart`
- Types PostgreSQL créés
- Tables créées
- 10 secteurs insérés
- 6 chasseurs insérés
- 18 clients insérés
- 18 mandats insérés
- Aucun échec bloquant pendant l'import

## Contrôles produits par la fixture

### Utilisateurs

| Rôle | Nombre |
|---|---:|
| `chasseur` | 6 |
| `client` | 18 |

### Mandats par statut

| Statut | Nombre |
|---|---:|
| `actif` | 11 |
| `termine` | 3 |
| `expire` | 2 |
| `suspendu` | 2 |

### Secteurs

| Élément | Nombre |
|---|---:|
| Secteurs | 10 |

## Conclusion

La fixture PostgreSQL a été importée correctement.

Le schéma `Fil_Rouge_Depart` est disponible et contient les données attendues pour poursuivre l'audit.