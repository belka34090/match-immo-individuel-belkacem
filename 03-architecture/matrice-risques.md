# Matrice des risques — Match-Immo

## Phase 3 — Absorber la croissance

## 1. Objectif

Cette matrice identifie les principaux risques susceptibles d'affecter la continuité, la disponibilité, l'intégrité, la sécurité et la migration du SI Match-Immo.

Elle sert de base aux décisions de mitigation, au PCA (Plan de Continuité d'Activité), au PRA (Plan de Reprise d'Activité) et au plan de migration.

La matrice distingue :

- le risque initial ;
- les mesures de réduction ;
- les preuves déjà produites ;
- le risque résiduel après mitigation.

---

## 2. Méthode de cotation

### Probabilité

| Note | Niveau | Signification |
|---:|---|---|
| 1 | Faible | Événement peu probable |
| 2 | Moyenne | Événement possible |
| 3 | Élevée | Événement probable |
| 4 | Très élevée | Événement fréquent ou fortement attendu |

### Impact

| Note | Niveau | Signification |
|---:|---|---|
| 1 | Faible | Gêne limitée, sans interruption majeure |
| 2 | Modéré | Dégradation du service ou reprise simple |
| 3 | Fort | Interruption significative, risque métier important |
| 4 | Critique | Arrêt du service, perte/corruption majeure ou impact réglementaire |

### Criticité

La criticité est calculée ainsi :

```text
Criticité = Probabilité × Impact
```

| Score | Niveau |
|---:|---|
| 1 à 3 | Faible |
| 4 à 7 | Modéré |
| 8 à 11 | Élevé |
| 12 à 16 | Critique |

---

## 3. Matrice des risques

| ID | Risque | Actif / activité concerné | Prob. | Impact | Criticité initiale | Mesures de mitigation | Preuve / contrôle | Risque résiduel | Responsable cible |
|---|---|---|---:|---:|---:|---|---|---|---|
| R01 | Panne de l'instance PostgreSQL primaire | Base OLTP / activité métier | 3 | 4 | 12 — Critique | Réplication PostgreSQL, replica, failover automatique, stockage persistant | POC CloudNativePG : 10 M lignes, promotion automatique, nouvelle écriture après bascule, retour à `streaming`, retard WAL final 0 byte | Modéré | Exploitation / DBA |
| R02 | Perte physique de la machine ou du site hébergeant toutes les instances | Ensemble du SI | 2 | 4 | 8 — Élevé | Nœuds physiques distincts en production, sauvegardes externalisées, PRA documenté | Limite explicitement identifiée dans le POC HA local ; test multi-site non couvert par le laboratoire | Modéré | Infrastructure / exploitation |
| R03 | Perte de données après incident | Données métier | 2 | 4 | 8 — Élevé | Sauvegardes incrémentales horaires, points 12 h, sauvegarde complète quotidienne, rétention contrôlée | Note d'éco-conception : cible RPO ≈ 1 h ; test réel de restauration à produire dans le PRA | Modéré tant que restauration non testée | DBA / exploitation |
| R04 | Sauvegarde inutilisable ou restauration impossible | Données / PRA | 2 | 4 | 8 — Élevé | Tests périodiques de restauration, contrôle d'intégrité, journal de tests | Test de sauvegarde/restauration à produire dans la Phase 3 | Élevé tant que non testé | DBA / exploitation |
| R05 | Réplication asynchrone non totalement à jour au moment d'une panne brutale | Base OLTP | 2 | 3 | 6 — Modéré | Supervision du lag WAL, politique RPO, sauvegardes indépendantes | POC HA : `streaming`, `async`, retard observé 0 byte après synchronisation ; limite RPO nul explicitement non garantie | Faible à modéré | DBA |
| R06 | Corruption logique ou suppression accidentelle propagée au replica | Données métier | 2 | 4 | 8 — Élevé | Sauvegardes historiques, contrôles d'accès, restauration à un point sain, séparation réplication/sauvegarde | Dossier architecture : réplication ≠ sauvegarde ; politique de rétention documentée | Modéré | DBA / sécurité |
| R07 | Requête lente ou saturation liée à la croissance des volumes | Performance OLTP | 3 | 3 | 9 — Élevé | Indexation mesurée, partitionnement ciblé, suivi `EXPLAIN ANALYZE`, dimensionnement 3V | Benchmark indexation : ≈4,3× ; benchmark partitionnement : ≈5,2× | Modéré | DBA / Data Engineer |
| R08 | Sur-complexification prématurée de l'architecture | Coût / exploitabilité / éco-conception | 3 | 3 | 9 — Élevé | Architecture progressive, matrice de décision, Citus seulement si métriques réelles le justifient | Matrice d'architecture + POC Citus ; décision : Citus = capacité d'évolution | Faible | Architecte SI |
| R09 | Mauvais choix de clé de distribution Citus provoquant du scatter-gather | Architecture distribuée | 2 | 3 | 6 — Modéré | Choix métier de la clé, benchmarks des requêtes, colocation des tables si migration future | POC Citus : `mandat_id` → Task Count 1 ; `bien_id` seul → Task Count 32 | Faible à modéré | Architecte / DBA |
| R10 | Déséquilibre des shards ou surcharge d'un worker | Citus / scalabilité | 2 | 3 | 6 — Modéré | Contrôle de distribution, choix de clé, monitoring, rééquilibrage si nécessaire | POC : 16/16 shards ; 891 MB / 897 MB | Faible dans le POC | DBA / exploitation |
| R11 | Échec de migration de `Fil_Rouge_Depart` vers `fil_rouge_cible` | Migration / mise en production | 3 | 4 | 12 — Critique | Sauvegarde avant migration, scripts transactionnels, contrôles de reprise, journal des rejets, rollback | `migration-final.sql`, `reprise-donnees-final.sql`, schéma `reprise_controle` | Modéré | Chef de projet / DBA |
| R12 | Perte ou transformation incorrecte de données pendant la migration | Qualité / intégrité | 3 | 4 | 12 — Critique | Comptages source/cible, contrôles métier, gestion des anomalies, tables de contrôle, validation avant bascule | Reprise de données et contrôles déjà produits en Phase 2 | Modéré | Data Engineer / métier |
| R13 | Incompatibilité du modèle distribué avec certaines PK/FK ou transactions | Modèle relationnel / Citus | 2 | 3 | 6 — Modéré | POC isolé, étude préalable des contraintes, colocation, tables de référence ; pas de migration directe sans étude | Limite documentée dans le benchmark Citus | Faible tant que Citus reste une option | Architecte / DBA |
| R14 | Accès non autorisé ou exposition de données personnelles | Sécurité / RGPD | 2 | 4 | 8 — Élevé | Moindre privilège, authentification, journalisation, chiffrement lorsque nécessaire, registre RGPD | Registre RGPD + cahier des charges technique | Modéré | Sécurité / DPO / exploitation |
| R15 | Conservation excessive des données ou sauvegardes | RGPD / stockage / éco-conception | 2 | 3 | 6 — Modéré | Durées de conservation, purge automatique, rétention différenciée des sauvegardes | Registre RGPD + note d'éco-conception : 48 h / 7 j / 30 j selon type de sauvegarde | Faible | DPO / exploitation |
| R16 | Indisponibilité du composant analytique perturbant le métier | OLAP / reporting | 2 | 2 | 4 — Modéré | Séparation OLTP/OLAP : l'analytique ne doit pas bloquer le transactionnel | Modèle OLTP/OLAP et ETL séparés | Faible | Data Engineer |
| R17 | Erreur humaine lors d'une opération d'exploitation ou de bascule | Exploitation | 3 | 3 | 9 — Élevé | Procédures écrites, commandes reproductibles, validation avant action destructive, rollback | Méthode de projet + scripts versionnés Git | Modéré | Exploitation |
| R18 | Dépendance à un unique savoir technique | Maintenabilité / continuité humaine | 2 | 3 | 6 — Modéré | Documentation explicative, scripts reproductibles, README, procédures compréhensibles par plusieurs profils | Livrables détaillés et versionnés dans le dépôt | Faible à modéré | Chef de projet / équipe |

---

## 4. Risques prioritaires

Les risques nécessitant la plus forte attention sont :

```text
R01 — panne du primaire
R11 — échec de migration
R12 — perte ou transformation incorrecte pendant migration
R03 — perte de données
R04 — sauvegarde/restauration défaillante
```

Les POC réalisés réduisent déjà fortement R01.

Les risques R03 et R04 ne seront considérés comme correctement maîtrisés qu'après un **test réel de sauvegarde et de restauration**.

Les risques R11 et R12 seront traités dans le plan de migration avec :

- préparation ;
- sauvegarde ;
- extraction ;
- transformation ;
- chargement ;
- contrôles ;
- bascule ;
- rollback.

---

## 5. Lecture pour un néophyte

Une matrice de risques répond simplement à quatre questions :

```text
Qu'est-ce qui peut mal se passer ?
        ↓
Quelle serait la gravité ?
        ↓
Comment réduit-on le risque ?
        ↓
Quelle preuve montre que la protection fonctionne ?
```

Exemple :

```text
Le serveur PostgreSQL principal tombe
        ↓
les utilisateurs pourraient être bloqués
        ↓
un replica est disponible
        ↓
CloudNativePG le transforme en nouveau PRIMARY
        ↓
le POC a vérifié la conservation de 10 M de lignes
et une nouvelle écriture après bascule
```

La mitigation ne signifie pas qu'un risque disparaît complètement.

Elle signifie que sa probabilité ou son impact est réduit à un niveau acceptable.

---

## 6. Décision

La Phase 3 ne considère pas la croissance uniquement sous l'angle des performances.

La stratégie de maîtrise des risques repose sur quatre niveaux :

```text
PRÉVENIR
→ architecture progressive, sécurité, contrôles

RÉSISTER
→ réplication et continuité

RESTAURER
→ sauvegardes et PRA

REVENIR EN ARRIÈRE
→ rollback de migration
```

Cette matrice alimente directement le PCA, le PRA et le plan de migration de Match-Immo.
