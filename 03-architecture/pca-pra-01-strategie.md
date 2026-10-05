# PCA / PRA — Stratégie de continuité et de reprise

## Phase 3 — Absorber la croissance

## Version consolidée et mise à jour après validation du PCA, du PRA local et du PRA distant multi-site

---

# 1. Objet du document

Ce document regroupe en **un seul livrable** :

- le Plan de Continuité d'Activité — PCA ;
- le Plan de Reprise d'Activité — PRA ;
- les objectifs RPO et RTO ;
- les risques couverts ;
- la stratégie de sauvegarde ;
- les preuves de réplication et de failover ;
- les preuves de restauration locale ;
- les preuves de restauration distante multi-site ;
- les choix d'architecture ;
- les choix de fournisseurs et de régions ;
- les mesures obtenues ;
- les limites du POC ;
- les recommandations de production.

L'objectif est de répondre simplement à deux questions :

```text
PCA
→ Comment continuer à fonctionner pendant une panne ?

PRA
→ Comment redémarrer après un sinistre majeur ?
```

Le document suit la logique de preuve suivante :

```text
AFFIRMATION
        ↓
MÉTHODE DE TEST
        ↓
PREUVE OBSERVÉE
        ↓
MESURE
        ↓
INTERPRÉTATION
        ↓
DÉCISION
```

Principe important :

```text
FAIT MESURÉ
!=
INTERPRÉTATION
!=
RECOMMANDATION
```

---

# 2. À qui s'adresse ce document ?

## 2.1 Direction / décideur

La direction doit pouvoir comprendre :

- quels risques menacent la continuité ;
- quelles protections sont réellement testées ;
- ce qui est déjà validé ;
- ce qui reste une cible ;
- pourquoi certains choix Cloud ont été faits ;
- quels coûts ou complexités sont évités.

## 2.2 Métier

Le métier doit comprendre :

- ce qui se passe si la base tombe ;
- ce qui se passe si les données sont corrompues ;
- combien de temps une reprise pourrait prendre ;
- quelles fonctions sont prioritaires.

## 2.3 Architecte SI / Data Engineer / DBA

Le profil technique doit retrouver :

- les versions PostgreSQL ;
- la stratégie HA ;
- la réplication ;
- le failover ;
- la stratégie de sauvegarde ;
- le stockage distant ;
- le site B ;
- les commandes et contrôles ;
- les limites mesurées.

## 2.4 DevOps / exploitation

L'exploitation doit pouvoir comprendre :

- les critères de déclenchement ;
- les étapes de reprise ;
- les contrôles ;
- les responsabilités ;
- les prérequis réseau ;
- les règles de sécurité.

## 2.5 Jury / évaluateur

Le jury doit pouvoir distinguer :

```text
ce qui a été réellement exécuté
        ≠
ce qui est recommandé
        ≠
ce qui reste à industrialiser
```

---

# 3. Définitions simples

## 3.1 PCA — Plan de Continuité d'Activité

Le PCA cherche à **continuer à fonctionner pendant un incident**.

Exemple :

```text
PRIMARY PostgreSQL tombe
        ↓
un replica est disponible
        ↓
il est promu PRIMARY
        ↓
l'activité continue
```

Le PCA vise donc à réduire ou éviter l'interruption.

---

## 3.2 PRA — Plan de Reprise d'Activité

Le PRA sert à **reconstruire et redémarrer après un sinistre plus grave**.

Exemple :

```text
base corrompue
        ↓
replica également corrompu
        ↓
réplication insuffisante
        ↓
récupération d'une sauvegarde saine
        ↓
restauration
        ↓
contrôles
        ↓
réouverture
```

---

## 3.3 RPO — Recovery Point Objective

Le RPO représente la **quantité maximale de données que l'on accepte de perdre**.

Exemple :

```text
RPO = 1 heure
```

signifie :

> l'objectif est de pouvoir revenir à un état datant de moins d'environ une heure.

Pour Match-Immo :

```text
RPO cible ≈ 1 heure
```

Important :

> Ce RPO est une cible d'architecture. Le POC de restauration démontre la restaurabilité, mais ne prouve pas encore qu'une chaîne automatisée produit réellement un point restaurable chaque heure.

---

## 3.4 RTO — Recovery Time Objective

Le RTO représente la **durée maximale visée pour rétablir le service**.

Pour Match-Immo :

```text
panne simple
→ failover
→ cible : quelques minutes

sinistre majeur
→ PRA
→ cible : ≤ 4 heures
```

Le RTO de 4 heures est une cible de conception.

Le POC a mesuré plusieurs sous-temps, mais pas encore un RTO complet end-to-end de production.

---

## 3.5 PRIMARY

Le PRIMARY est l'instance PostgreSQL qui accepte les écritures principales.

---

## 3.6 Replica

Un replica est une copie PostgreSQL alimentée par réplication.

Il peut être promu PRIMARY si le PRIMARY courant tombe.

---

## 3.7 Failover

Le failover est la bascule vers une autre instance lorsque le PRIMARY devient indisponible.

---

## 3.8 WAL

Le WAL — Write-Ahead Log — est le journal PostgreSQL contenant les changements avant leur écriture définitive.

Il sert notamment à la réplication.

---

## 3.9 Sauvegarde externalisée

Une sauvegarde est externalisée lorsqu'elle est stockée hors de l'infrastructure qu'elle protège.

Exemple correct :

```text
Site A
        ↓
backup
        ↓
stockage distant
```

Exemple insuffisant :

```text
base
+
backup
sur le même disque
```

---

# 4. Périmètre critique de Match-Immo

## 4.1 Fonctions métier prioritaires

Les fonctions critiques sont notamment :

- utilisateurs ;
- clients ;
- demandes ;
- mandats ;
- biens ;
- propositions ;
- visites ;
- offres ;
- ventes ;
- paiements.

Une indisponibilité longue de l'OLTP bloque directement l'activité.

---

## 4.2 Fonctions moins prioritaires à court terme

Peuvent être temporairement différées :

- OLAP ;
- reporting ;
- statistiques ;
- traitements décisionnels ;
- alimentation analytique.

Principe :

```text
OLTP prioritaire
OLAP secondaire en crise
```

---

# 5. Objectifs de continuité

Le système doit pouvoir :

1. supporter une panne simple ;
2. limiter l'interruption ;
3. protéger les données ;
4. restaurer après un sinistre ;
5. vérifier l'intégrité ;
6. reprendre les écritures ;
7. conserver un point de retour ;
8. documenter la reprise.

---

# 6. Tableau RPO / RTO

| Situation | Mécanisme | RPO cible | RTO cible |
|---|---|---:|---:|
| Perte d'un PRIMARY | Réplication + failover | Proche de 0 si replica à jour, sans garantie absolue en asynchrone | Quelques minutes |
| Redémarrage pod / conteneur | Stockage persistant + orchestration | 0 si stockage intact | Quelques minutes |
| Corruption logique | Backup sain | ≈ 1 h cible | ≤ 4 h cible |
| Suppression répliquée | Backup historique | ≈ 1 h cible | ≤ 4 h cible |
| Perte d'hôte / site | Backup externalisé + reconstruction | ≈ 1 h cible | ≤ 4 h cible |
| OLAP indisponible | Reconstruction / ré-alimentation | Tolérance supérieure | Non prioritaire |

---

# 7. Architecture générale de continuité

```text
                         MATCH-IMMO
                             |
                             v
                      PostgreSQL OLTP
                             |
             +---------------+---------------+
             |                               |
             v                               v
        PCA / HA                         PRA / Backup
  réplication + failover             sauvegarde externe
             |                               |
             v                               v
      continuité locale          Scaleway Object Storage
                                             |
                                             v
                                      Site B distant
                                      Azure Austria
                                             |
                                             v
                                        restauration
                                             |
                                             v
                                   contrôles d'intégrité
                                             |
                                             v
                                      reprise écriture
```

---

# 8. PCA — stratégie retenue

Le PCA PostgreSQL repose sur :

```text
PostgreSQL 16
+
CloudNativePG
+
k3d
+
2 instances
+
réplication
+
failover
+
stockage persistant
```

Le POC a été exécuté sur :

```text
10 000 000 lignes
```

---

# 9. Preuve de réplication

Avant failover :

```text
PRIMARY : 10 000 000 lignes
Replica : 10 000 000 lignes
```

Le replica indiquait :

```text
pg_is_in_recovery = true
```

La réplication était :

```text
state = streaming
sync_state = async
```

Le retard WAL final observé était :

```text
0 byte
```

---

# 10. Ce que signifie réplication asynchrone

Asynchrone signifie que le PRIMARY n'attend pas nécessairement que le replica confirme l'écriture avant de poursuivre.

Conséquence :

```text
lag observé = 0
```

ne signifie pas :

```text
RPO garanti = 0
```

En cas de panne brutale, une très petite quantité de données pourrait théoriquement ne pas avoir été répliquée.

---

# 11. Preuve de persistance

Un pod replica a été supprimé puis recréé.

Après recréation :

```text
10 000 000 lignes
```

étaient encore présentes.

Conclusion :

```text
suppression du pod
≠
suppression des données
```

Le stockage persistant a rempli son rôle.

---

# 12. Preuve après arrêt du cluster k3d

Le cluster k3d a été arrêté puis redémarré.

Après redémarrage :

- les instances sont revenues ;
- les volumes étaient présents ;
- les données étaient conservées ;
- les 10 millions de lignes étaient toujours disponibles.

---

# 13. Preuve de failover

Le PRIMARY actif a été supprimé volontairement.

Résultat :

```text
PRIMARY supprimé
        ↓
autre instance promue
        ↓
10 000 000 lignes présentes
```

Une nouvelle écriture a ensuite été effectuée :

```text
id = 10000001
statut = apres_failover
```

Puis le nouveau replica contenait :

```text
10 000 001 lignes
max(id) = 10000001
```

La réplication finale était de nouveau :

```text
streaming
```

avec :

```text
lag = 0 byte
```

---

# 14. Conclusion PCA

## Fait mesuré

```text
perte du PRIMARY
→ promotion d'une autre instance
→ données conservées
→ nouvelle écriture possible
→ réplication rétablie
```

## Interprétation

Le système testé sait continuer à fonctionner face à la perte d'une instance PostgreSQL.

## Décision

```text
PCA PostgreSQL
→ VALIDÉ au niveau POC
```

---

# 15. Limite du PCA

Le laboratoire k3d fonctionne sur une seule machine physique.

Donc :

```text
instances séparées logiquement
≠
sites physiques séparés
```

Si le GMKtec entier disparaît :

```text
PRIMARY perdu
+
replica perdu
+
cluster perdu
```

Cette limite justifie le PRA distant.

---

# 16. Réplication et sauvegarde ne sont pas la même chose

Exemple :

```text
DELETE incorrect
        ↓
PRIMARY modifié
        ↓
modification répliquée
        ↓
replica modifié aussi
```

Donc :

```text
RÉPLICATION
≠
SAUVEGARDE
```

La réplication protège principalement contre la panne d'une instance.

La sauvegarde protège notamment contre :

- erreur humaine ;
- corruption logique ;
- ransomware ;
- erreur applicative ;
- migration défectueuse ;
- perte de site.

Les deux mécanismes sont complémentaires.

---

# 17. Stratégie de sauvegarde cible

| Type | Fréquence cible | Rétention cible |
|---|---:|---:|
| Sauvegarde incrémentale / journaux permettant un retour fin dans le temps | 1 h maximum entre deux points restaurables | 48 h |
| Point intermédiaire | 12 h | 7 jours |
| Sauvegarde complète | 24 h | 30 jours |

Objectif :

```text
RPO cible ≈ 1 heure
```

Important :

> Cette politique est une **cible d'exploitation**. Le POC actuel démontre la sauvegarde et la restauration avec `pg_dump` / `pg_restore`, mais `pg_dump` n'est pas à lui seul une solution de sauvegarde incrémentale ni de PITR.

Le **PITR — Point-In-Time Recovery** — permet de restaurer PostgreSQL à un instant précis à partir d'une sauvegarde de base et des journaux WAL archivés.

Pour industrialiser réellement cette cible, il faudrait utiliser un mécanisme adapté, par exemple :

- archivage des WAL ;
- sauvegardes physiques PostgreSQL ;
- outil spécialisé compatible PostgreSQL, tel que `pgBackRest` ou `Barman` ;
- supervision des sauvegardes et des journaux ;
- tests périodiques de restauration.

Le présent POC ne prétend donc pas avoir validé une chaîne de sauvegarde incrémentale/PITR en production.

---

# 18. Pourquoi pas une sauvegarde complète chaque minute ?

Cela augmenterait inutilement :

- stockage ;
- réseau ;
- I/O disque ;
- consommation ;
- coût ;
- complexité ;
- maintenance.

Le choix doit rester proportionné à la criticité.

---

# 19. PRA — scénarios couverts

```text
S1 — corruption logique
S2 — suppression accidentelle massive
S3 — perte de la base et des replicas
S4 — perte de l'hôte
S5 — perte du site
S6 — migration défectueuse
S7 — ransomware / compromission
```

---

# 20. Procédure générale PRA

## Étape 1 — Détecter

Identifier :

- service impacté ;
- heure de début ;
- données potentiellement touchées ;
- disponibilité d'un replica ;
- état des sauvegardes.

## Étape 2 — Qualifier

```text
PRIMARY seul indisponible
→ PCA

PRIMARY + replicas indisponibles
→ PRA

corruption répliquée
→ PRA

retour historique nécessaire
→ PRA
```

## Étape 3 — Stopper l'aggravation

Selon le cas :

- couper les écritures ;
- isoler la ressource compromise ;
- suspendre une migration ;
- conserver les journaux ;
- révoquer des accès compromis.

## Étape 4 — Choisir le point de restauration

La sauvegarde doit être :

```text
saine
+
antérieure à l'incident
+
compatible avec l'objectif RPO
```

## Étape 5 — Restaurer

Restaurer dans un environnement contrôlé.

## Étape 6 — Contrôler

Vérifier :

- tables ;
- contraintes ;
- volumes ;
- agrégats ;
- checksum ;
- échantillons métier.

## Étape 7 — Tester fonctionnellement

Vérifier :

- lecture ;
- écriture ;
- transactions ;
- cohérence métier.

## Étape 8 — Réouvrir

Reconnecter l'application et réautoriser les écritures.

## Étape 9 — Surveiller

Contrôler :

- logs ;
- performances ;
- erreurs ;
- sauvegarde suivante ;
- éventuelle réplication.

## Étape 10 — Documenter

Enregistrer :

- cause ;
- durée ;
- pertes ;
- RPO observé ;
- RTO observé ;
- décisions ;
- actions correctives.

---

