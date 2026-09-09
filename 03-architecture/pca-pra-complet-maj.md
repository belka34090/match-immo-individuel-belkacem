# PCA / PRA COMPLET — Match-Immo

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

# 21. PRA local — preuve réalisée

Avant le test distant, un PRA local a été réalisé.

## 21.1 Base de test

Base :

```text
matchimmo_pra_test
```

Table :

```text
test_pra
```

Volume :

```text
1 000 000 lignes
```

## 21.2 Valeurs de référence

```text
COUNT(*)        = 1 000 000
MIN(id)         = 1
MAX(id)         = 1 000 000
SUM(id)         = 500 000 500 000
SUM(mandat_id)  = 50 000 500 000
SUM(bien_id)    = 250 000 500 000
checksum logique= ca09b7405ac0b5074f8c3bce5aeed2ec
```

## 21.3 Sauvegarde locale

Format :

```text
pg_dump -Fc
```

Temps observé :

```text
0,994 s
```

SHA-256 :

```text
6fccd1e41584a64c6304cd588bf6e480e1db9b1f7584fa5de2fbb3f9643abc4d
```

## 21.4 Destruction simulée

La base a été supprimée entièrement.

Le contrôle dans `pg_database` a confirmé son absence.

## 21.5 Restauration locale

Temps observé :

```text
0,712 s
```

Après restauration :

- nombre de lignes identique ;
- agrégats identiques ;
- checksum logique identique.

## 21.6 Conclusion

```text
PRA local
→ VALIDÉ
```

Mais ce test ne suffisait pas encore à prouver une perte complète du site.

---

# 22. Pourquoi un PRA distant était nécessaire

Un restore local prouve principalement :

```text
le dump fonctionne
```

Mais pas :

```text
le site A peut disparaître
ET
la reprise reste possible ailleurs
```

Il fallait donc séparer réellement :

```text
Site A
        !=
stockage de sauvegarde
        !=
Site B
```

---

# 22.1 Ce que signifie « multi-site » dans ce POC

Dans ce document, l'expression **multi-site** signifie que la reprise a été testée sur des environnements géographiquement et techniquement distincts :

```text
Site A
→ infrastructure locale en France

Stockage de sauvegarde
→ Scaleway Object Storage à Paris

Site B
→ Azure Austria East
```

Il s'agit donc d'un **multi-site logique, géographique et inter-fournisseur**.

Cela ne signifie pas que Match-Immo dispose déjà de deux datacenters de production actifs en permanence ou d'une architecture active-active multi-région.

---

# 23. Architecture du PRA distant

```text
SITE A — France
GMKtec
PostgreSQL 16.14
        |
        | pg_dump
        v
SCALeway Object Storage
Paris / fr-par
bucket privé + versioning
        |
        | API S3
        v
SITE B
Azure Austria East
Ubuntu 22.04.5 LTS
PostgreSQL 16.15
        |
        | pg_restore
        v
Base restaurée
        |
        +--> contrôles
        |
        +--> nouvelle écriture
```

---

# 24. Pourquoi Scaleway pour le stockage de sauvegarde ?

Le besoin était :

- sauvegarde hors GMKtec ;
- stockage privé ;
- stockage distant ;
- versioning ;
- accès API ;
- localisation française ;
- cohérence RGPD / souveraineté.

Choix :

```text
Scaleway Object Storage
Région : Paris / fr-par
Bucket privé
Versioning activé
```

---

# 25. Pourquoi une API S3 ?

Scaleway expose une API compatible S3.

Cela permet d'utiliser des commandes standards :

```text
aws s3 ls
aws s3 cp
```

Important :

```text
AWS CLI
≠
stockage AWS
```

AWS CLI est utilisé comme client compatible S3.

Le fournisseur du stockage reste Scaleway.

---

# 26. Souveraineté — précision importante

Le backup est stocké en France chez Scaleway.

Cela renforce la cohérence avec :

- résidence européenne ;
- localisation française ;
- maîtrise du stockage.

Mais :

```text
région UE
!=
souveraineté totale
```

La souveraineté complète dépend aussi :

- du fournisseur ;
- du droit applicable ;
- des contrats ;
- des sous-traitants ;
- de la gestion des clés ;
- des accès ;
- de la gouvernance.

---

# 27. Pourquoi utiliser Azure comme Site B ?

Objectif :

```text
ne pas dépendre uniquement du même fournisseur
```

Une solution :

```text
Scaleway backup
+
Scaleway VM
```

aurait été plus simple.

Mais elle aurait renforcé la dépendance à un fournisseur unique.

Le POC a donc testé :

```text
Scaleway
        !=
Azure
```

Le site B devient indépendant du stockage de sauvegarde.

---

# 28. Pourquoi Azure for Students ?

Azure a été retenu pour le POC parce que :

- abonnement étudiant disponible ;
- crédit disponible ;
- VM temporaire possible ;
- environnement indépendant ;
- régions européennes disponibles ;
- coût limité pour un exercice.

Azure n'est pas désigné ici comme choix de production définitif.

---

# 29. Pourquoi la France Azure n'a pas été retenue ?

L'abonnement appliquait une policy système :

```text
Allowed resource deployment regions
```

Régions autorisées observées :

```text
italynorth
austriaeast
norwayeast
switzerlandnorth
germanywestcentral
```

La France n'était pas dans la liste.

Donc :

```text
France Central
→ bloquée par policy d'abonnement
```

Une recherche de petites VM exploitables en France n'a pas fourni de solution utilisable dans le périmètre testé.

Décision :

```text
France Azure
→ NON RETENUE
```

---

# 30. Pourquoi Germany West Central n'a pas été retenue ?

Tailles testées :

```text
Standard_B1s
Standard_B2ats_v2
Standard_B2pts_v2
```

Erreurs observées :

```text
SkuNotAvailable
Capacity Restrictions
```

Interprétation :

> Le SKU existe, mais Azure ne pouvait pas fournir la capacité demandée dans cette région au moment du test.

Une recherche plus large a montré des familles non restreintes beaucoup trop grosses pour le POC.

Décision :

```text
Germany West Central
→ région autorisée
→ petites tailles indisponibles / non adaptées
→ NON RETENUE
```

---

# 31. Pourquoi Italy North n'a pas été retenue ?

Petites tailles trouvées :

```text
Standard_F1alds_v7
Standard_F1als_v7
Standard_F1ads_v7
Standard_F1as_v7
Standard_D2alds_v7
Standard_D2als_v7
Standard_F2alds_v7
Standard_F2als_v7
```

La candidate préférée :

```text
Standard_F1als_v7
1 vCPU
2 Go RAM
```

Mais Azure a retourné :

```text
QuotaExceeded
Current Limit: 0
```

Familles testées avec quota nul :

```text
StandardFalsv7Family
StandardFasv7Family
StandardDalsv7Family
StandardFamsv7Family
StandardDasv7Family
standardDCSv3Family
```

Une demande d'augmentation de quota a été tentée.

Réponse :

```text
ResourceNotAvailableForOffer
```

Décision :

```text
Italy North
→ techniquement autorisée
→ petites VM trouvées
→ quota = 0
→ augmentation indisponible
→ NON RETENUE
```

---

# 32. Pourquoi Norway East et Switzerland North n'ont pas été retenues ?

Filtre :

```text
restrictions == 0
CPU <= 2
RAM <= 4 Go
```

Aucune petite candidate adaptée n'a été obtenue dans le périmètre testé.

Décision :

```text
Norway East
→ NON RETENUE

Switzerland North
→ NON RETENUE
```

---

# 33. Pourquoi Austria East a été retenue ?

L'Autriche était autorisée.

Certaines familles modernes avaient aussi :

```text
Current Limit: 0
```

Exemples :

```text
Standard_D2lds_v6
Standard_D2ls_v6
Standard_D2s_v6
```

Mais deux références ont passé la validation Azure :

```text
Standard_D2_v2_Promo
Standard_DS2_v2_Promo
```

Résultat :

```text
provisioningState = Succeeded
```

La taille retenue :

```text
Standard_D2_v2_Promo
2 vCPU
environ 7 Go RAM observés
```

---

# 34. Pourquoi D2_v2_Promo plutôt que DS2_v2_Promo ?

Le POC devait seulement :

- démarrer Ubuntu ;
- installer PostgreSQL ;
- télécharger ~19 Mo ;
- restaurer 1 000 000 de lignes ;
- vérifier les données.

La variante DS apporte des capacités de stockage supplémentaires inutiles ici.

Principe :

```text
ne pas surdimensionner
```

---

# 35. Décision région / taille

| Critère | Austria East |
|---|---|
| Région autorisée | Oui |
| Région UE | Oui |
| SKU validé | Oui |
| Quota exploitable | Oui |
| Taille proportionnée | Oui |
| Site indépendant | Oui |
| Fournisseur différent de Scaleway | Oui |
| Adapté au POC | Oui |

Conclusion correcte :

> Austria East était la meilleure combinaison réellement déployable, proportionnée et autorisée dans les contraintes de l'abonnement étudiant utilisé.

---

# 36. Attention : Azure Austria n'est pas une preuve de souveraineté totale

Azure Austria East est en Union européenne.

Mais Azure reste un fournisseur américain.

Donc :

```text
résidence UE
!=
souveraineté juridique totale
```

Pour ce POC :

- données 100 % synthétiques ;
- aucune donnée personnelle réelle ;
- VM temporaire ;
- pas de choix de production définitif.

Important :

> Le POC PRA distant a été réalisé uniquement sur des données synthétiques. Il démontre une capacité technique de reprise, mais **ne constitue pas une validation réglementaire, juridique ou opérationnelle de production**.

---

# 37. Problème Hyper-V rencontré

Première tentative :

```text
Standard_D2_v2_Promo
+
Ubuntu 24.04
```

Erreur :

```text
cannot boot Hypervisor Generation 2
```

Inspection du SKU :

```text
HyperVGenerations = V1
```

Solution :

```text
Ubuntu 22.04 LTS
Gen1
```

Image retenue :

```text
Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest
```

La VM a ensuite démarré.

---

# 38. Caractéristiques mesurées du Site B

## Hôte

```text
matchimmo-pra-site-b
```

## OS

```text
Ubuntu 22.04.5 LTS
```

## CPU

```text
2 vCPU
```

## RAM

```text
6,8 GiB
```

## Disque

```text
29 GiB
≈ 28 GiB libres au contrôle
```

## Région confirmée par métadonnées Azure

```text
AustriaEast
```

---

# 39. Sécurisation SSH

La VM a été créée avec :

```text
--nsg-rule NONE
```

Donc SSH n'était pas ouvert globalement.

Une règle NSG a ensuite été créée :

```text
Nom       : Allow-SSH-Home
Direction : Inbound
Protocole : TCP
Port      : 22
Source    : une seule IPv4 /32
Action    : Allow
Priorité  : 1000
```

`/32` signifie :

> une seule adresse IP source autorisée.

L'adresse exacte n'est pas conservée dans ce document.

---

# 40. PostgreSQL sur le Site B

Ubuntu 22.04 a installé PostgreSQL 14 par défaut.

Pour rester cohérent avec le Site A, PostgreSQL 16 a ensuite été installé depuis le dépôt officiel PostgreSQL.

Version Site B :

```text
PostgreSQL 16.15
```

Version Site A :

```text
PostgreSQL 16.14
```

Même version majeure :

```text
16
```

PostgreSQL 14 a été supprimé pour éviter toute ambiguïté.

Cluster final :

```text
16 main
port 5433
online
```

---

# 41. Pourquoi garder la même version majeure PostgreSQL ?

Cela réduit les variables inutiles.

```text
Site A = PostgreSQL 16
Site B = PostgreSQL 16
```

Si la restauration échoue, il est moins probable que l'échec soit lié à une incompatibilité majeure.

---

# 42. Préparation de la base cible

Rôle :

```text
match_immo
```

Base :

```text
matchimmo_pra_test
```

Propriétaire :

```text
match_immo
```

---

# 43. Connexion Azure → Scaleway

AWS CLI a été installé.

Profil :

```text
matchimmo-scaleway
```

Région :

```text
fr-par
```

Les secrets ne sont pas stockés dans Git ni dans ce document.

---

# 44. Vérification du backup distant

Depuis Azure :

```text
matchimmo_pra_test.dump
```

a été listé directement dans Scaleway.

Taille :

```text
19 503 828 octets
```

Conclusion :

```text
Site B
→ voit le backup
→ sans dépendre du disque local du Site A
```

---

# 45. Téléchargement distant

Flux :

```text
Scaleway Paris
        ↓
Internet
        ↓
Azure Austria East
```

Temps observé :

```text
1,523 s
```

Ce temps concerne uniquement le fichier de test de ~19 Mo.

---

# 46. Contrôle SHA-256

Empreinte avant :

```text
6fccd1e41584a64c6304cd588bf6e480e1db9b1f7584fa5de2fbb3f9643abc4d
```

Empreinte après téléchargement Azure :

```text
6fccd1e41584a64c6304cd588bf6e480e1db9b1f7584fa5de2fbb3f9643abc4d
```

Résultat :

```text
IDENTIQUE
```

Interprétation :

> le dump transféré n'a pas été altéré.

---

# 47. Restauration distante

Outil :

```text
pg_restore 16.15
```

Temps mesuré :

```text
3,630 s
```

Aucune erreur lors de la restauration finale.

---

# 48. Contrôles d'intégrité après restauration

## Nombre de lignes

```text
1 000 000
```

## Minimum

```text
1
```

## Maximum

```text
1 000 000
```

## Sommes

```text
SUM(id)        = 500 000 500 000
SUM(mandat_id) = 50 000 500 000
SUM(bien_id)   = 250 000 500 000
```

Toutes les valeurs correspondent aux références.

---

# 49. Checksum logique

Valeur restaurée :

```text
ca09b7405ac0b5074f8c3bce5aeed2ec
```

Valeur de référence :

```text
ca09b7405ac0b5074f8c3bce5aeed2ec
```

Résultat :

```text
IDENTIQUE
```

---

# 50. Preuve de reprise en écriture

Après restauration :

```text
INSERT INTO test_pra ...
```

Résultat :

```text
INSERT 0 1
```

Ligne créée :

```text
id          = 1000001
statut      = PRA_OK
montant     = 123456.78
commentaire = Ecriture apres restauration sur site B Azure
```

La ligne a ensuite été relue.

Conclusion :

> la base restaurée n'est pas seulement lisible ; elle peut reprendre des transactions.

---

# 51. Tableau de preuve PRA distant

| Affirmation | Test | Preuve | Statut |
|---|---|---|---|
| Backup hors site | Listing S3 depuis Azure | Objet visible | Validé |
| Accès depuis site B | `aws s3 ls` | Succès | Validé |
| Transfert inter-fournisseur | `aws s3 cp` | Succès | Validé |
| Intégrité binaire | SHA-256 | Identique | Validé |
| Restauration | `pg_restore` | Succès | Validé |
| Volume conservé | `COUNT(*)` | 1 000 000 | Validé |
| Agrégats conservés | `SUM/MIN/MAX` | Identiques | Validé |
| Contenu logique | checksum | Identique | Validé |
| Reprise écriture | `INSERT + SELECT` | Succès | Validé |
| Site B distant | Métadonnées Azure | AustriaEast | Validé |
| Fournisseur indépendant | Azure != Scaleway | Oui | Validé |

---

# 52. Mesures consolidées

| Mesure | Valeur |
|---|---:|
| Lignes | 1 000 000 |
| Taille dump | 19 503 828 octets |
| Download Scaleway → Azure | 1,523 s |
| `pg_restore` distant | 3,630 s |
| `pg_dump` local | 0,994 s |
| `pg_restore` local | 0,712 s |
| PostgreSQL Site A | 16.14 |
| PostgreSQL Site B | 16.15 |
| CPU Site B | 2 vCPU |
| RAM Site B | 6,8 GiB |
| Disque Site B | 29 GiB |
| Région Site B | Austria East |
| SHA-256 | identique |
| Checksum logique | identique |
| Écriture post-PRA | réussie |

---

# 53. Ce que le PRA distant prouve réellement

Le test prouve que :

```text
Site A
peut produire un backup
        ↓
le backup peut être externalisé
        ↓
le Site B peut le récupérer
        ↓
PostgreSQL peut être restauré
        ↓
les données restent cohérentes
        ↓
les écritures peuvent reprendre
```

Conclusion :

```text
PRA distant multi-site logique et inter-fournisseur
→ VALIDÉ au niveau POC
```

---

# 54. Ce que le test ne prouve pas

## 54.1 RTO complet

```text
3,630 s
```

est uniquement le temps `pg_restore`.

Ce n'est pas le RTO complet.

Un vrai RTO comprend :

- détection ;
- décision ;
- création/démarrage Site B ;
- installation ;
- secrets ;
- réseau ;
- téléchargement ;
- restauration ;
- contrôles ;
- application ;
- DNS ;
- validation ;
- réouverture.

Donc :

```text
RTO réel
!=
3,630 s
```

---

## 54.2 RPO réel

Le POC n'a pas démontré une sauvegarde automatique toutes les heures.

Donc :

```text
RPO ≈ 1 h
→ cible
→ pas encore prouvé en exploitation continue
```

---

## 54.3 Volume production

Le dump fait environ 19 Mo.

Une production réelle peut être bien plus volumineuse.

Les temps dépendront de :

- volume ;
- index ;
- contraintes ;
- débit réseau ;
- stockage ;
- parallélisme ;
- CPU ;
- concurrence.

---

# 55. Synthèse PCA / PRA

```text
PCA PostgreSQL
→ VALIDÉ au niveau POC

PRA local
→ VALIDÉ

PRA distant
→ VALIDÉ au niveau POC

RPO ≈ 1 h
→ CIBLE

RTO ≤ 4 h
→ CIBLE
```

---

# 56. Risques couverts

| Risque | Réponse |
|---|---|
| Panne PRIMARY | Réplication + failover |
| Perte pod | Stockage persistant |
| Perte hôte | PRA distant |
| Perte site | Backup externalisé + Site B |
| Corruption logique | Backup sain |
| Suppression accidentelle | Backup historique |
| Ransomware | Isolement + backup sain |
| Migration défectueuse | Rollback / restauration |
| Restore impossible | Test réel |
| Dépendance fournisseur unique | Scaleway + Azure POC |
| Erreur humaine | Procédures + contrôles |

---

# 57. Critères de déclenchement PCA

Le PCA est utilisé lorsque :

```text
une instance tombe
ET
une autre copie saine est disponible
```

Exemples :

- PRIMARY indisponible ;
- pod détruit ;
- instance redémarrée.

---

# 58. Critères de déclenchement PRA

Le PRA est utilisé lorsque :

- aucune instance saine n'est disponible ;
- les données sont corrompues ;
- la corruption est répliquée ;
- un retour dans le temps est nécessaire ;
- le site est perdu ;
- une migration doit être annulée.

---

# 59. Priorités de reprise

Ordre cible :

```text
1. PostgreSQL OLTP
2. accès applicatif
3. écritures critiques
4. réplication / HA
5. services secondaires
6. OLAP / reporting
```

---

# 60. Responsabilités cibles

| Action | Responsable cible |
|---|---|
| Détection | Exploitation / monitoring |
| Décision failover | Exploitation / DBA |
| Choix du backup | DBA |
| Restauration | DBA / DevOps |
| Validation métier | Responsable métier |
| Sécurité | RSSI / sécurité / DPO selon incident |
| Communication | Responsable SI / chef de projet |
| REX | Équipe SI |

Dans le projet individuel, plusieurs rôles sont naturellement portés par la même personne.

---

# 61. Sécurité des sauvegardes

Les sauvegardes doivent être :

- privées ;
- versionnées ;
- surveillées ;
- chiffrées selon la politique ;
- protégées contre la suppression ;
- accessibles avec des droits minimaux.

Les identifiants ne doivent jamais être :

- committés ;
- écrits dans les scripts ;
- présents dans la documentation ;
- partagés dans des logs.

---

# 62. Principe du moindre privilège

Le compte utilisé pour Object Storage a été limité aux opérations nécessaires.

Idée :

```text
Read Object
Write Object
```

et non des permissions administratives générales.

---

# 63. Pourquoi ne pas laisser la VM Azure allumée ?

La VM sert à un POC de reprise.

La conserver inutilement entraînerait :

- coût ;
- énergie ;
- maintenance ;
- surface d'attaque ;
- supervision.

Décision :

```text
conserver les preuves
+
conserver la procédure
+
détruire la ressource temporaire après validation
```

---

# 64. Cohérence éco-conception

Le PCA/PRA ne doit pas devenir une duplication illimitée.

Stratégie :

```text
HA ciblée
+
sauvegardes incrémentales
+
full quotidiennes
+
rétention
+
site B temporaire / reconstructible
```

Principe :

> ne pas maintenir une infrastructure surdimensionnée en permanence si le besoin ne le justifie pas.

---

# 65. Cohérence avec la matrice de décision

L'architecture générale reste progressive :

```text
PostgreSQL optimisé
        ↓
indexation
        ↓
partitionnement
        ↓
HA / réplication
        ↓
PRA distant
        ↓
Citus uniquement si besoin démontré
```

Principe :

> mesurer avant de complexifier.

---

# 66. Cohérence avec la croissance

Le PRA distant ajoute une protection sans imposer immédiatement :

- multi-région active-active ;
- cluster distribué permanent ;
- infrastructure Cloud lourde ;
- duplication complète en continu.

Cela reste proportionné au niveau actuel du projet.

---

# 67. Recommandations production — sauvegardes

À industrialiser :

- planification automatique ;
- monitoring ;
- alertes ;
- horodatage ;
- rétention ;
- contrôle périodique ;
- journalisation ;
- politique de chiffrement.

---

# 68. Recommandations production — Site B

Automatiser la reconstruction via :

- Terraform ;
- Ansible ;
- scripts reproductibles ;
- pipeline sécurisé.

Objectif :

```text
réduire le temps manuel
```

---

# 69. Recommandations production — secrets

Utiliser :

- secret manager ;
- coffre ;
- identité managée quand disponible ;
- rotation ;
- expiration ;
- droits minimaux.

---

# 70. Recommandations production — RTO end-to-end

Le prochain exercice mature devra chronométrer :

```text
déclaration sinistre
        ↓
déclenchement PRA
        ↓
Site B disponible
        ↓
backup récupéré
        ↓
base restaurée
        ↓
application validée
        ↓
service réouvert
```

Ce temps sera le vrai RTO mesuré.

---

# 71. Recommandations production — RPO réel

Pour prouver RPO ≈ 1 h :

- sauvegarde automatique horaire ;
- surveillance des échecs ;
- vérification du dernier point disponible ;
- alerte si ancienneté > seuil ;
- test de restauration périodique.

---

# 72. Fréquence des exercices PRA

Recommandation :

```text
trimestrielle
ou
semestrielle
```

selon criticité et coût.

---

# 73. Règle importante

Une sauvegarde non testée n'est pas une preuve de restauration.

Le projet a précisément réduit ce risque en effectuant :

```text
backup
→ destruction / environnement séparé
→ restore
→ contrôle
→ écriture
```

---

# 74. Lecture néophyte

## Panne simple

```text
un serveur tombe
→ un autre prend le relais
→ PCA
```

## Sinistre grave

```text
tout est perdu ou corrompu
→ on récupère une sauvegarde saine
→ on restaure ailleurs
→ PRA
```

---

# 75. Lecture direction

En langage simple :

> Match-Immo dispose désormais d'une preuve que la base PostgreSQL peut survivre à une panne simple grâce au failover, et qu'en cas de sinistre plus grave une sauvegarde stockée en France peut être récupérée depuis un autre Cloud européen, restaurée et remise en écriture.

---

# 76. Lecture jury — chaîne de preuve

## Affirmation

Match-Immo doit pouvoir reprendre après perte du site principal.

## Méthode

- `pg_dump` ;
- stockage Scaleway Paris ;
- VM Azure Austria East ;
- transfert S3 ;
- SHA-256 ;
- `pg_restore` ;
- contrôles SQL ;
- checksum ;
- écriture.

## Preuves

- backup visible ;
- téléchargement réussi ;
- SHA-256 identique ;
- 1 000 000 lignes ;
- agrégats identiques ;
- checksum identique ;
- écriture réussie.

## Mesures

```text
dump local    : 0,994 s
restore local : 0,712 s
download      : 1,523 s
restore distant: 3,630 s
```

## Interprétation

La reprise distante est techniquement réalisable.

## Décision

```text
PRA distant
→ VALIDÉ au niveau POC
```

---

# 77. Statut final des exigences

| Élément | Statut |
|---|---|
| Réplication PostgreSQL | Validée |
| Persistance | Validée |
| Failover | Validé |
| Écriture après failover | Validée |
| PRA local | Validé |
| Sauvegarde externalisée | Validée |
| Téléchargement inter-fournisseur | Validé |
| SHA-256 | Validé |
| Restore distant | Validé |
| Contrôle logique | Validé |
| Écriture après PRA | Validée |
| RPO 1 h | Cible à industrialiser |
| RTO ≤ 4 h | Cible à mesurer end-to-end |
| Multi-site de production permanent | Non nécessaire à ce stade |

---

# 78. Décision d'architecture finale

La stratégie retenue pour Match-Immo est :

```text
PCA
→ PostgreSQL HA
→ réplication
→ failover
→ stockage persistant

PRA
→ sauvegardes externalisées
→ versioning
→ stockage distant
→ restauration sur site séparé
→ contrôles d'intégrité
→ reprise en écriture
```

---

# 79. Ce qui est retenu maintenant

```text
PostgreSQL 16
+
HA / réplication
+
backup externalisé
+
PRA testé
+
procédures documentées
```

---

# 80. Ce qui reste une évolution

```text
automatisation complète du backup
+
monitoring RPO
+
RTO end-to-end
+
Infrastructure as Code
+
gestion centralisée des secrets
+
tests PRA réguliers
```

---

# 81. Conclusion générale

Le projet ne se contente plus d'un PRA théorique.

Il a démontré trois niveaux :

```text
NIVEAU 1
PCA
→ failover PostgreSQL fonctionnel

NIVEAU 2
PRA local
→ destruction + restauration validées

NIVEAU 3
PRA distant multi-site logique et inter-fournisseur
→ backup France
→ restore Azure Autriche
→ intégrité validée
→ écriture validée
```

Le choix d'`AustriaEast` n'est pas arbitraire.

Il résulte des contraintes réellement observées :

```text
France
→ bloquée par policy

Allemagne
→ petites capacités indisponibles

Italie
→ quotas Compute à 0

Norvège / Suisse
→ pas de petite candidate adaptée

Autriche
→ SKU validé
→ quota exploitable
→ déploiement réussi
```

La conclusion finale est donc :

```text
PCA PostgreSQL
→ VALIDÉ au niveau POC

PRA local
→ VALIDÉ

PRA distant multi-site logique et inter-fournisseur
→ VALIDÉ au niveau POC

RPO ≈ 1 h
→ CIBLE D'EXPLOITATION

RTO ≤ 4 h
→ CIBLE D'ARCHITECTURE
→ À MESURER END-TO-END
```

Le principe directeur reste :

> **Mesurer avant de complexifier.**

---

# 82. Décision de clôture du bloc PCA / PRA

Le bloc PCA / PRA peut être considéré comme **validé pour la Phase 3 au niveau POC**.

Les preuves sont suffisantes pour démontrer :

- continuité sur panne d'instance ;
- persistance ;
- failover ;
- restauration locale ;
- externalisation ;
- restauration distante ;
- contrôle d'intégrité ;
- reprise des écritures.

Le travail suivant ne consiste plus à ajouter un nouveau POC PCA/PRA.

La suite logique de la Phase 3 est :

```text
1. plan de migration
2. cohérence transverse / éco-conception
3. audit contre Starter Pack
4. audit contre grille d'évaluation
5. vérification des preuves
6. nettoyage Git
7. commit / push
```
