# PCA / PRA — Preuves techniques du POC

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

