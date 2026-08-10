# Registre des anomalies et risques

## Anomalies de données confirmées

| ID | Anomalie | Type | Impact | Priorité | Preuve |
| --- | --- | --- | --- | --- | --- |
| A-01 | Le mandat 13 référence un utilisateur de rôle `chasseur` comme client | Intégrité métier | Relation client/mandat incohérente | Haute | `preuves/03-anomalies/resultats-anomalies.md` |
| A-02 | Six mandats sont encore `actif` alors que leur durée théorique de six mois est dépassée au 25/07/2026 | Cohérence métier | Statut potentiellement obsolète et suivi des mandats incorrect | Haute | `preuves/03-anomalies/resultats-anomalies.md` |
| A-03 | Le mandat 9 débute le 02/10/2025 alors que le chasseur associé a une date de création au 03/11/2025 | Cohérence temporelle | Mandat associé à un chasseur avant sa création dans le SI | Haute | `preuves/03-anomalies/resultats-anomalies.md` |

## Risques structurels

| ID | Risque | Type | Impact | Priorité | Preuve |
| --- | --- | --- | --- | --- | --- |
| R-01 | Clients et chasseurs sont regroupés dans la table `utilisateurs` | Modélisation | Difficulté à appliquer des règles différentes selon le rôle | Haute | `analyse-audit.md` |
| R-02 | Les clés `client_id` et `chasseur_id` ne garantissent pas le rôle métier de l'utilisateur référencé | Intégrité métier | Possibilité d'associer un mauvais rôle à un mandat | Haute | `analyse-audit.md` |
| R-03 | `budget_max` et `taux_commission` sont stockés dans une table commune alors qu'ils concernent des rôles différents | Modélisation | Colonnes inutiles ou `NULL` selon le rôle et incohérences possibles | Moyenne | `analyse-audit.md` |
| R-04 | Le modèle ne contient ni date de fin du mandat, ni mode de signature, ni gestion explicite du renouvellement | Fonctionnel | Suivi incomplet du cycle de vie des mandats | Haute | `analyse-audit.md` |
| R-05 | Les critères de recherche sont stockés dans `description_recherche` sous forme de texte libre | Qualité des données | Recherche, comparaison, analyse et futur matching IA difficiles | Haute | `analyse-audit.md` |
| R-06 | Aucune contrainte d'unicité ne garantit l'absence de doublons sur `(ville, quartier)` | Intégrité des données | Création possible de secteurs dupliqués | Moyenne | `preuves/04-validation-finale/validation-phase1.md` |
| R-07 | Le format du code postal n'est pas contrôlé par le schéma | Qualité des données | Valeurs incorrectes possibles | Faible | `preuves/04-validation-finale/validation-phase1.md` |
| R-08 | Le format des emails n'est pas garanti au niveau du schéma | Qualité des données | Valeurs incorrectes possibles malgré l'unicité | Faible | `preuves/04-validation-finale/validation-phase1.md` |
| R-09 | `secteur_id` peut être `NULL` dans un mandat | Modélisation | Mandat potentiellement créé sans rattachement géographique | Moyenne | `analyse-audit.md` |
| R-10 | Aucune contrainte métier ne vérifie que `budget_max` et `taux_commission` sont positifs | Intégrité des données | Valeurs incohérentes possibles | Moyenne | `preuves/04-validation-finale/validation-phase1.md` |
