# Benchmark réplication et haute disponibilité PostgreSQL

## Phase 3 — Absorber la croissance

## 1. Objectif

L'objectif de ce POC est de vérifier qu'une architecture PostgreSQL répliquée peut :

- conserver une copie à jour des données sur une seconde instance ;
- maintenir les données sur un stockage persistant ;
- redémarrer après un arrêt du cluster Kubernetes ;
- promouvoir automatiquement un replica en cas de perte du primaire ;
- accepter de nouvelles écritures après la bascule ;
- reconstruire la réplication après incident.

Le test est réalisé dans l'environnement local Match-Immo.

Il ne s'agit pas de données clientes réelles.

Les données utilisées sont des données synthétiques générées uniquement pour le benchmark.

---

## 2. Architecture testée

La stack utilisée est :

```text
k3d
└── Kubernetes / k3s
    └── CloudNativePG
        └── PostgreSQL 16
            ├── PRIMARY
            └── REPLICA
```

Configuration du cluster PostgreSQL :

```text
Instances PostgreSQL : 2
Réplication          : physique / streaming
Mode                 : asynchrone
Stockage             : 10 Gi par instance
Stockage Kubernetes  : PVC local-path
```

Le manifeste Kubernetes est disponible dans :

```text
03-architecture/k8s/postgresql-ha.yaml
```

---

## 3. Pourquoi CloudNativePG ?

Plusieurs approches ont été considérées :

- réplication PostgreSQL configurée manuellement ;
- réplication logique ;
- réplication physique avec gestion manuelle du failover ;
- Patroni ;
- CloudNativePG.

CloudNativePG est retenu pour le POC car il permet de rester dans l'écosystème PostgreSQL tout en automatisant :

- la création des instances ;
- la réplication ;
- la détection de panne ;
- la promotion d'un replica ;
- la reconstruction du cluster après incident.

Cette approche reste cohérente avec l'utilisation de k3d/Kubernetes prévue dans la Phase 3.

---

## 4. Vérification initiale des rôles

Après création du cluster :

```text
matchimmo-pg-1 = PRIMARY
matchimmo-pg-2 = REPLICA
```

La fonction PostgreSQL :

```sql
SELECT pg_is_in_recovery();
```

a retourné :

```text
matchimmo-pg-1 : false
matchimmo-pg-2 : true
```

Interprétation :

```text
false = instance primaire
true  = instance replica
```

---

## 5. Vérification du streaming PostgreSQL

La vue :

```sql
pg_stat_replication
```

a confirmé :

```text
application_name = matchimmo-pg-2
state            = streaming
sync_state       = async
```

Le replica était donc connecté au primaire et recevait les modifications via le mécanisme de streaming replication PostgreSQL.

---

## 6. Jeu de données de charge

Une base dédiée a été créée :

```text
matchimmo_ha_test
```

La table utilisée pour le benchmark est :

```text
test_replication_10m
```

Elle contient notamment :

- un identifiant ;
- un identifiant de mandat ;
- un identifiant de bien ;
- un statut ;
- un montant ;
- une date ;
- un commentaire.

La table est une table PostgreSQL normale.

Elle n'est pas déclarée `UNLOGGED`.

Les écritures génèrent donc du WAL et sont prises en compte par la réplication physique PostgreSQL.

---

## 7. Chargement de 10 millions de lignes

Volume chargé :

```text
10 000 000 lignes
```

Résultat PostgreSQL :

```text
INSERT 0 10000000
```

Temps observé depuis le terminal :

```text
real 0m11,639s
```

Après chargement, le PRIMARY contenait :

| Mesure | Valeur |
|---|---:|
| Nombre de lignes | 10 000 000 |
| ID minimum | 1 |
| ID maximum | 10 000 000 |
| Taille table + index | 1331 MB |

Le test porte donc sur environ 1,3 Go de données PostgreSQL.

---

## 8. Vérification du gros volume sur le replica

Le même contrôle sur le REPLICA a retourné :

| Mesure | PRIMARY | REPLICA |
|---|---:|---:|
| Nombre de lignes | 10 000 000 | 10 000 000 |
| ID minimum | 1 | 1 |
| ID maximum | 10 000 000 | 10 000 000 |
| Taille totale | 1331 MB | 1331 MB |

Le replica était toujours identifié comme replica :

```text
pg_is_in_recovery() = true
```

---

## 9. Vérification d'intégrité

Un simple `COUNT(*)` ne suffit pas à prouver que le contenu est identique.

Une vérification supplémentaire a donc été réalisée sur l'ensemble des données avec :

- le nombre de lignes ;
- la somme des identifiants ;
- la somme des identifiants de mandat ;
- la somme des identifiants de bien ;
- une empreinte MD5 calculée à partir du contenu des différentes colonnes.

Résultat obtenu sur le PRIMARY :

```text
lignes        = 10000000
somme_id      = 50000005000000
somme_mandat  = 500005000000
somme_bien    = 5000005000000
empreinte     = 082f48b03df7b5e310c0af02b8907758
```

Résultat obtenu sur le REPLICA :

```text
lignes        = 10000000
somme_id      = 50000005000000
somme_mandat  = 500005000000
somme_bien    = 5000005000000
empreinte     = 082f48b03df7b5e310c0af02b8907758
```

Les valeurs sont strictement identiques.

Le benchmark confirme donc l'intégrité du jeu de données répliqué pour les contrôles réalisés.

---

## 10. Vérification du retard WAL

Le WAL, ou Write-Ahead Log, est le journal PostgreSQL utilisé notamment pour transmettre les modifications au replica.

Après le chargement des 10 millions de lignes, le PRIMARY indiquait :

```text
state       = streaming
sync_state  = async

sent_lsn    = 0/CC3E78E0
write_lsn   = 0/CC3E78E0
flush_lsn   = 0/CC3E78E0
replay_lsn  = 0/CC3E78E0

retard      = 0 bytes
```

Le REPLICA indiquait également :

```text
receive_lsn = 0/CC3E78E0
replay_lsn  = 0/CC3E78E0
retard      = 0 bytes
```

Au moment de la mesure, le replica avait donc entièrement rattrapé le primaire.

---

## 11. Test de persistance du replica

Le pod du replica a été supprimé volontairement :

```text
matchimmo-pg-2
```

Avant suppression, son PVC était :

```text
pvc-23aeae4f-4535-46ff-84d1-05e3f07e49c0
```

Après recréation automatique du pod, le PVC était toujours :

```text
pvc-23aeae4f-4535-46ff-84d1-05e3f07e49c0
```

La vérification PostgreSQL après recréation a retourné :

```text
pg_is_in_recovery = true
lignes            = 10000000
id_min            = 1
id_max            = 10000000
```

Le stockage persistant a donc permis au replica de conserver ses données malgré la destruction et la recréation de son pod.

---

## 12. Test après arrêt complet de k3d

Le cluster k3d a ensuite été arrêté puis redémarré.

Après redémarrage :

```text
Instances READY = 2/2
Cluster         = healthy
```

Les deux PVC de 10 Gi étaient toujours présents.

Un changement de rôle a été observé :

```text
matchimmo-pg-2 = PRIMARY
matchimmo-pg-1 = REPLICA
```

Les contrôles ont retourné :

```text
matchimmo-pg-2 :
pg_is_in_recovery = false
lignes            = 10000000

matchimmo-pg-1 :
pg_is_in_recovery = true
lignes            = 10000000
```

Les 10 millions de lignes ont donc été conservées après arrêt et redémarrage complet de l'environnement k3d.

---

## 13. Test de failover automatique

Après stabilisation du cluster, le PRIMARY était :

```text
matchimmo-pg-2
```

Ce pod PRIMARY a été volontairement supprimé.

CloudNativePG a alors automatiquement promu :

```text
matchimmo-pg-1
```

comme nouveau PRIMARY.

Le cluster est ensuite revenu à :

```text
Instances = 2
READY     = 2
STATUS    = Cluster in healthy state
PRIMARY   = matchimmo-pg-1
```

Le pod `matchimmo-pg-2` a été recréé pour restaurer la redondance.

---

## 14. Vérification des données après failover

Après promotion de `matchimmo-pg-1`, le nouveau PRIMARY contenait toujours :

```text
pg_is_in_recovery = false
lignes            = 10000000
id_min            = 1
id_max            = 10000000
```

Aucune perte n'a été observée sur le jeu de données de référence lors de ce test.

---

## 15. Écriture après failover

Une nouvelle ligne a ensuite été écrite sur le nouveau PRIMARY avec :

```text
id      = 10000001
statut  = apres_failover
```

Résultat :

```text
INSERT 0 1
```

Le nouveau replica `matchimmo-pg-2` a ensuite retourné :

```text
pg_is_in_recovery = true
lignes            = 10000001
id_min            = 1
id_max            = 10000001
```

Cela démontre que :

1. le nouveau PRIMARY accepte les écritures après failover ;
2. la réplication est reconstruite ;
3. les nouvelles écritures sont transmises au nouveau replica.

---

## 16. État final de la réplication

Après failover et reconstruction du cluster :

```text
PRIMARY = matchimmo-pg-1
REPLICA = matchimmo-pg-2
```

La vue `pg_stat_replication` a retourné :

```text
application_name = matchimmo-pg-2
state            = streaming
sync_state       = async

sent_lsn         = 0/D1000110
write_lsn        = 0/D1000110
flush_lsn        = 0/D1000110
replay_lsn       = 0/D1000110

retard_replay    = 0 bytes
```

Le replica indiquait :

```text
receive_lsn = 0/D1000110
replay_lsn  = 0/D1000110
retard      = 0 bytes
```

Le cluster était donc revenu à un état nominal après l'incident.

---

## 17. Résultats synthétiques

| Test | Résultat |
|---|---|
| Deux instances PostgreSQL | Validé |
| PRIMARY / REPLICA | Validé |
| Streaming replication | Validé |
| Réplication asynchrone | Validé |
| Charge de 10 000 000 lignes | Validée |
| Volume PostgreSQL testé | 1331 MB |
| Intégrité PRIMARY / REPLICA | Validée |
| Retard WAL après synchronisation | 0 byte |
| Persistance après suppression du replica | Validée |
| Persistance après redémarrage k3d | Validée |
| Promotion automatique d'un replica | Validée |
| Conservation des 10 M lignes après failover | Validée |
| Écriture après failover | Validée |
| Réplication après reconstruction | Validée |
| Volume final | 10 000 001 lignes |
| Retard WAL final | 0 byte |

---

## 18. Limites du POC

Le POC démontre le fonctionnement de la réplication, du stockage persistant et du failover dans l'environnement local utilisé pour Match-Immo.

Cependant, plusieurs limites doivent être clairement distinguées d'une architecture de production.

### 18.1 Une seule machine physique

k3d fonctionne ici sur une seule machine physique.

Les nœuds Kubernetes sont donc virtualisés sous forme de conteneurs.

Le POC démontre notamment la perte d'un pod ou d'une instance PostgreSQL, mais il ne démontre pas la continuité de service après destruction physique complète de la machine hôte.

En production, les instances devraient être réparties sur plusieurs nœuds physiques et, selon le besoin, plusieurs zones de panne.

### 18.2 Réplication asynchrone

La réplication observée est :

```text
sync_state = async
```

Lors des mesures, le retard observé était de :

```text
0 byte
```

Cela ne signifie toutefois pas qu'une réplication asynchrone garantit un RPO nul dans tous les scénarios.

Une panne brutale peut théoriquement survenir alors que certaines transactions validées sur le PRIMARY n'ont pas encore été rejouées sur le replica.

### 18.3 La réplication ne remplace pas les sauvegardes

Une réplication protège principalement contre la perte d'une instance.

Elle ne protège pas automatiquement contre :

- une suppression logique accidentelle ;
- une corruption propagée ;
- une erreur humaine ;
- un ransomware ;
- la destruction simultanée de toutes les copies.

Une stratégie de sauvegarde et de restauration reste donc nécessaire dans le PCA/PRA.

---

## 19. Décision d'architecture

Le POC confirme que la réplication PostgreSQL gérée par CloudNativePG constitue une solution pertinente pour améliorer la haute disponibilité de Match-Immo.

La solution apporte :

- une copie continue des données ;
- une promotion automatique d'un replica ;
- une restauration automatique de la redondance ;
- un fonctionnement cohérent avec PostgreSQL ;
- une intégration naturelle dans Kubernetes.

La réplication n'est toutefois pas retenue comme optimisation directe des écritures ou comme remplacement des sauvegardes.

Son rôle principal dans l'architecture cible est :

```text
HAUTE DISPONIBILITÉ
+
CONTINUITÉ DE SERVICE
```

---

## 20. Conclusion

Le benchmark a démontré sur l'environnement solo Match-Immo :

```text
10 000 000 lignes
        ↓
réplication streaming asynchrone
        ↓
intégrité PRIMARY / REPLICA
        ↓
retard WAL observé = 0 byte
        ↓
persistance des données
        ↓
arrêt / redémarrage de k3d
        ↓
conservation des données
        ↓
perte volontaire du PRIMARY
        ↓
promotion automatique du REPLICA
        ↓
10 000 000 lignes conservées
        ↓
nouvelle écriture
        ↓
10 000 001 lignes répliquées
        ↓
retour à streaming / async
        ↓
retard WAL final = 0 byte
```

La réplication PostgreSQL avec CloudNativePG est donc validée comme solution de haute disponibilité dans le cadre du POC Match-Immo.
