# Validation finale — Phase 1

## Objectif

Vérifier que l'audit de l'existant est complet, cohérent et appuyé par des contrôles reproductibles avant de passer à la Phase 2.

## Contrôles réalisés

| Contrôle | Résultat |
| --- | --- |
| Doublons sur `(ville, quartier)` dans `secteurs` | Aucun doublon détecté |
| Format des codes postaux | Aucune valeur invalide détectée |
| Clients sans téléphone | 3 clients concernés ; absence autorisée par le schéma |
| Format des emails | Aucune valeur manifestement invalide détectée |
| Cohérence rôle / `budget_max` / `taux_commission` | Aucune incohérence détectée |
| Valeurs négatives ou nulles sur budgets / commissions | Aucune incohérence détectée |
| Références vers utilisateurs et secteurs | Aucune référence cassée |
| Mandats sans secteur | Aucun |
| Demandes de recherche vides | Aucune |
| Mandat antérieur à la création du client | Aucun |
| Mandat antérieur à la création du chasseur | 1 anomalie détectée : mandat 9 |
| Même utilisateur comme client et chasseur | Aucun |

## Anomalies de données confirmées

- A-01 : le mandat 13 référence un utilisateur de rôle `chasseur` comme client.
- A-02 : six mandats sont encore `actif` alors que leur durée théorique de six mois est dépassée au 25/07/2026.
- A-03 : le mandat 9 débute le 02/10/2025 alors que le chasseur associé, utilisateur 6, a une date de création au 03/11/2025.

## Risques structurels confirmés

L'analyse du schéma confirme également plusieurs faiblesses de conception, notamment :

- clients et chasseurs regroupés dans la même table ;
- absence de garantie du rôle métier pour `client_id` et `chasseur_id` ;
- présence de colonnes spécifiques aux rôles dans une table commune ;
- absence de `date_fin` et de mode de signature ;
- critères de recherche stockés dans un champ texte libre ;
- absence de contrainte d'unicité sur `(ville, quartier)` ;
- absence de contrôles de format sur certaines données ;
- absence de certaines contraintes métier simples.

## Conclusion

Les contrôles complémentaires ont permis d'identifier une anomalie supplémentaire et de distinguer les anomalies présentes dans les données des risques liés à la structure du schéma.

La Phase 1 est considérée comme validée sur le plan documentaire et technique après mise à jour du registre des anomalies, des preuves SQL et de l'analyse d'audit.