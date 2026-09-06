# Preuve officielle — Validation de la reprise des données

## 1. Objectif du document

Ce document constitue la **preuve de validation de la reprise des données** entre l'ancien système et le modèle cible du projet *Chasse immobilière*.

Il permet à un formateur, un membre du jury, un développeur, un responsable métier ou un futur mainteneur de comprendre rapidement :

- quelles données ont été reprises ;
- quelles données ont été corrigées ;
- quelles données ont été rejetées ;
- pourquoi certaines tables cibles restent vides ;
- quelles hypothèses ont été nécessaires ;
- et si l'exécution SQL s'est terminée correctement.

La reprise a été exécutée avec **PostgreSQL 16**.

---

## 2. Contexte de la reprise

### Source

Schéma PostgreSQL :

```text
"Fil_Rouge_Depart"
```

Données présentes dans les fixtures officielles :

| Donnée source | Nombre |
| --- | ---: |
| Secteurs | 10 |
| Utilisateurs | 24 |
| dont clients | 18 |
| dont chasseurs | 6 |
| Mandats | 18 |

### Cible

Schéma PostgreSQL :

```text
fil_rouge_cible
```

La cible correspond au modèle relationnel final de la Phase 2.

Le script utilisé pour la reprise est :

```text
02-modele-cible/reprise-donnees-final.sql
```

Date de référence métier utilisée pour contrôler la durée des mandats :

```text
25/07/2026
```

Cette date est importante car un mandat a une durée métier de **6 mois**.

---

## 3. Principe appliqué

La reprise suit quatre règles simples :

1. **Copier directement** les données fiables ayant un équivalent clair dans la cible.
2. **Transformer** les données uniquement lorsqu'une règle déterministe permet de le faire sans ambiguïté.
3. **Rejeter et tracer** une ligne lorsqu'une anomalie ne peut pas être corrigée de manière certaine.
4. **Ne pas inventer** de données qui n'existent pas dans l'ancien système.

Les éléments de contrôle sont conservés dans le schéma technique :

```text
reprise_controle
```

Ce schéma ne fait pas partie du modèle métier. Il sert uniquement à conserver les preuves, hypothèses, corrections et rejets de la migration.

---

## 4. Résultat global

L'exécution s'est terminée par :

```text
COMMIT
```

Un `COMMIT` signifie que PostgreSQL a validé la transaction complète.

Les contrôles intégrés au script n'ont donc détecté aucune erreur bloquante.

### Volumes obtenus

| Contrôle | Nombre |
| --- | ---: |
| SOURCE secteurs | 10 |
| SOURCE utilisateurs | 24 |
| SOURCE mandats | 18 |
| CIBLE secteur | 10 |
| CIBLE utilisateur | 24 |
| CIBLE client | 18 |
| CIBLE chasseur | 6 |
| CIBLE demande | 16 |
| CIBLE affectation | 16 |
| CIBLE version_demande | 16 |
| CIBLE mandat | 16 |
| REPRISE rejets mandat | 2 |
| REPRISE corrections statut | 5 |
| CIBLE bareme_commission | 6 |
| CIBLE tranche_commission | 6 |

---

## 5. Pourquoi 18 mandats source deviennent 16 mandats cible

Deux mandats présentent des anomalies confirmées pendant l'audit de Phase 1.

### Mandat 13 — mauvais rôle métier

Le mandat source `13` contient :

```text
client_id = 3
```

Or l'utilisateur `3` est un **chasseur**, et non un client.

Le mandat ne peut donc pas être repris comme un mandat valide sans inventer quel client aurait dû être référencé.

Décision :

```text
Mandat 13
→ rejet
→ code : R-CLIENT-ROLE
```

Motif enregistré :

```text
client_id=3 référence un utilisateur de rôle chasseur au lieu de client.
```

### Mandat 9 — incohérence temporelle

Le mandat source `9` :

```text
date de début : 02/10/2025
chasseur_id   : 6
```

Le chasseur `6`, Lucas Perrin, a cependant une date de création dans l'ancien SI au :

```text
03/11/2025
```

Le mandat commence donc **avant l'existence du chasseur dans le système**.

Il est impossible de savoir avec certitude si :

- la date du mandat est fausse ;
- la date de création du chasseur est fausse ;
- ou une autre donnée historique manque.

Aucune date n'est donc corrigée arbitrairement.

Décision :

```text
Mandat 9
→ rejet
→ code : R-CHASSEUR-DATE
```

### Synthèse

```text
18 mandats source
- 2 mandats rejetés
= 16 mandats migrés
```

---

## 6. Pourquoi il y a 5 corrections de statut alors que l'audit avait détecté 6 mandats concernés

L'audit de Phase 1 avait identifié **6 mandats marqués `actif` alors que leur durée théorique de 6 mois était déjà dépassée au 25/07/2026**.

Les mandats concernés dans la source étaient :

| Mandat | Début | Fin théorique | Statut source |
| ---: | --- | --- | --- |
| 4 | 20/05/2025 | 20/11/2025 | actif |
| 7 | 01/09/2025 | 01/03/2026 | actif |
| 9 | 02/10/2025 | 02/04/2026 | actif |
| 10 | 14/11/2025 | 14/05/2026 | actif |
| 11 | 05/01/2026 | 05/07/2026 | actif |
| 12 | 20/01/2026 | 20/07/2026 | actif |

Cependant, le **mandat 9** présente également l'anomalie temporelle décrite précédemment et est rejeté dans son ensemble.

Il ne doit donc pas être :

```text
corrigé puis migré
```

mais simplement :

```text
rejeté et tracé
```

Les cinq autres mandats sont fiables sur leur identité et leurs relations. Leur statut peut donc être corrigé de façon déterministe grâce à la règle métier :

```text
date_fin = date_signature + 6 mois
```

Au 25/07/2026, leur date de fin est dépassée. Leur statut cible devient donc :

```text
expire
```

### Les cinq corrections réellement appliquées

| Mandat | Statut source | Statut cible | Fin calculée |
| ---: | --- | --- | --- |
| 4 | actif | expire | 20/11/2025 |
| 7 | actif | expire | 01/03/2026 |
| 10 | actif | expire | 14/05/2026 |
| 11 | actif | expire | 05/07/2026 |
| 12 | actif | expire | 20/07/2026 |

Ces corrections sont enregistrées dans :

```text
reprise_controle.correction_mandat
```

Ainsi, aucune modification n'est silencieuse : chaque correction peut être expliquée et auditée.

---

## 7. Reconstruction des données dans le nouveau modèle

L'ancien système ne possédait pas les tables `DEMANDE`, `AFFECTATION` et `VERSION_DEMANDE`.

Pour chaque mandat source valide, la reprise reconstruit donc le minimum nécessaire au fonctionnement du modèle cible :

```text
Mandat source valide
        │
        ├── DEMANDE
        ├── AFFECTATION
        ├── VERSION_DEMANDE
        ├── VERSION_DEMANDE_SECTEUR
        └── MANDAT
```

Résultat :

```text
16 mandats valides
→ 16 demandes
→ 16 affectations
→ 16 versions de demande
→ 16 mandats cible
```

Cette reconstruction est explicitement documentée dans la table :

```text
reprise_controle.hypothese_reprise
```

---

## 8. Hypothèses nécessaires à la reprise

Certaines informations exigées par le nouveau modèle n'existaient pas dans l'ancien SI.

Elles ont donc reçu une valeur technique ou ont été reconstruites selon une règle documentée.

### Statut du compte utilisateur

L'ancien système ne possède pas de statut de compte.

Valeur utilisée :

```text
migre_historique
```

### Statut du profil client

L'ancien système ne possède pas de statut spécifique au profil client.

Valeur utilisée :

```text
historique
```

### Matricule du chasseur

L'ancien système ne possède pas de matricule.

Le matricule technique est généré sous la forme :

```text
LEGACY-CH-XXX
```

Exemple :

```text
LEGACY-CH-006
```

### Date de création de la demande

L'ancien système ne possède pas de table `DEMANDE`.

Pour une reprise historique, la première date certaine associée au mandat est utilisée :

```text
DEMANDE.date_creation = mandat_source.date_debut
```

Il s'agit d'une **hypothèse de reprise documentée**, et non de l'affirmation que la demande métier avait réellement été créée ce jour-là.

### Affectation

L'ancien système ne conserve pas le workflow d'affectation.

L'existence d'un mandat valide prouve néanmoins qu'un chasseur a pris en charge le client.

Une affectation historique `acceptee` est donc reconstruite entre la demande et le chasseur du mandat.

### Version de demande

Une version `1` est créée pour chaque demande historique.

Le `budget_max` est repris depuis le client source lorsqu'il peut être rattaché au mandat.

Les autres critères structurés restent `NULL` lorsqu'ils ne peuvent pas être déterminés avec certitude.

### Date de signature du mandat

L'ancien système contient `date_debut`, mais pas de date de signature distincte.

Règle :

```text
date_signature = date_debut
```

### Mode de signature

Aucune information source ne permet de connaître le mode de signature.

Valeur technique :

```text
historique_inconnu
```

### Date de fin

La règle métier connue est :

```text
date_fin = date_signature + 6 mois
```

---

## 9. Traitement des anciens taux de commission

L'ancien système contient un seul `taux_commission` courant par chasseur.

Le nouveau modèle permet au contraire :

- plusieurs barèmes ;
- des périodes de validité ;
- plusieurs tranches de commission.

La source ne permet pas de reconstituer cet historique.

Pour ne pas perdre les taux réellement présents dans l'ancien SI, la reprise crée donc pour chacun des 6 chasseurs :

```text
1 barème historique de transition
+
1 tranche
```

La validité démarre à la date de référence :

```text
25/07/2026
```

Cela donne :

```text
6 chasseurs
→ 6 barèmes
→ 6 tranches
```

Cette transformation conserve la donnée connue sans inventer un historique de commission inexistant.

---

## 10. Données volontairement non transformées

### Description de recherche en texte libre

L'ancien SI contient des descriptions telles que :

```text
T3 Ecusson, budget 320000, 65m2 min, balcon, calme, DPE C max
```

Le nouveau modèle possède des critères structurés.

Le script ne tente pas d'extraire automatiquement toutes ces informations, car cela pourrait produire des erreurs d'interprétation.

Le texte original est conservé dans :

```text
reprise_controle.donnee_source_non_reprise
```

La donnée n'est donc pas perdue, mais elle n'est pas transformée en information structurée incertaine.

### Ville associée à l'utilisateur

La ville du compte utilisateur n'a pas d'équivalent direct dans `UTILISATEUR` cible.

Elle n'est surtout pas transformée automatiquement en secteur de recherche, car :

```text
ville d'habitation ≠ secteur recherché
```

Elle est conservée comme donnée source non reprise.

### Date de création de l'utilisateur

La date de création du compte n'a pas d'attribut équivalent dans la cible.

Elle n'est pas réinterprétée comme une date de demande.

Elle reste tracée dans la zone de contrôle.

---

## 11. Pourquoi certaines tables cible restent vides

Les tables suivantes contiennent `0` ligne après la reprise :

| Table cible | Nombre |
| --- | ---: |
| acte_authentique | 0 |
| avis_chasseur | 0 |
| bien | 0 |
| commentaire | 0 |
| commission | 0 |
| facture_chasseur | 0 |
| honoraires | 0 |
| media_avis | 0 |
| notaire | 0 |
| offre | 0 |
| paiement | 0 |
| presentation | 0 |
| vendeur | 0 |
| visite | 0 |

Ce résultat est **volontaire**.

Les fixtures officielles ne contiennent aucune donnée permettant de reconstruire de façon fiable :

- des biens ;
- des vendeurs ;
- des présentations ;
- des visites ;
- des commentaires ;
- des avis chasseurs ;
- des offres ;
- des actes authentiques ;
- des notaires ;
- des honoraires ;
- des commissions calculées ;
- des factures ;
- ou des paiements.

Créer artificiellement ces lignes aurait constitué une invention de données métier.

La décision retenue est donc :

```text
absence de donnée source fiable
→ aucune donnée cible inventée
```

---

## 12. Preuve d'exécution

Commande utilisée :

```bash
docker exec -i match-immo-conception-app-postgres-1 \
  psql -U match_immo -d match_immo \
  < /home/mlops/match-immo-individuel-belkacem/02-modele-cible/reprise-donnees-final.sql
```

### Résultat déterminant

```text
COMMIT
```

### Contrôles de sortie

```text
SOURCE secteurs             10
SOURCE utilisateurs         24
SOURCE mandats              18

CIBLE secteur               10
CIBLE utilisateur           24
CIBLE client                18
CIBLE chasseur               6

CIBLE demande               16
CIBLE affectation           16
CIBLE version_demande       16
CIBLE mandat                16

REPRISE rejets mandat        2
REPRISE corrections statut   5

CIBLE bareme_commission      6
CIBLE tranche_commission     6
```

### Rejets enregistrés

```text
Mandat 9  → R-CHASSEUR-DATE
Mandat 13 → R-CLIENT-ROLE
```

### Corrections de statut enregistrées

```text
Mandat 4  : actif → expire
Mandat 7  : actif → expire
Mandat 10 : actif → expire
Mandat 11 : actif → expire
Mandat 12 : actif → expire
```

---

## 13. Contrôles de cohérence finaux

La reprise valide les égalités suivantes :

```text
24 utilisateurs source
= 24 utilisateurs cible

18 clients source
= 18 clients cible

6 chasseurs source
= 6 chasseurs cible

18 mandats source
= 16 mandats cible + 2 rejets

16 mandats migrés
= 16 demandes
= 16 affectations
= 16 versions de demande
```

Les écarts de volume sont donc **expliqués et tracés**.

Il ne s'agit pas de pertes silencieuses.

---

## 14. Conclusion de validation

La reprise est considérée comme **validée techniquement** pour la Phase 2.

Elle respecte les principes suivants :

- script SQL rejouable ;
- exécution transactionnelle ;
- contrôles avant validation ;
- conservation des volumes attendus ;
- séparation claire entre données migrées, corrigées et rejetées ;
- traçabilité des hypothèses ;
- aucune correction arbitraire d'une anomalie non déterministe ;
- aucune invention de données absentes de la source ;
- conservation des informations source non directement intégrables dans une zone de contrôle.

### Résumé métier

> L'ancien système contenait 18 mandats. Deux présentaient des incohérences impossibles à corriger de façon certaine et ont été isolés dans un registre de rejet. Seize mandats ont donc été repris dans le nouveau modèle. Parmi les six mandats initialement détectés comme encore actifs après leur durée théorique de six mois, l'un correspond au mandat 9 rejeté pour une autre incohérence ; les cinq autres ont été migrés avec un statut corrigé de `actif` vers `expire`. Toutes ces décisions sont tracées. Les nouvelles tables pour lesquelles aucune donnée historique fiable n'existait ont volontairement été laissées vides.

---

## 15. Fichiers associés

Les principaux éléments permettant de contrôler cette preuve sont :

```text
01-audit/registre-anomalies.md
01-audit/preuves/03-anomalies/resultats-anomalies.md
02-modele-cible/mld-cible.md
02-modele-cible/migration-final.sql
02-modele-cible/reprise-donnees-final.sql
02-modele-cible/preuves/reprise-donnees-validation.md
```

Ce document doit être conservé avec les livrables de Phase 2 afin que la reprise puisse être comprise et défendue sans devoir reconstruire le raisonnement à partir des scripts SQL seuls.
