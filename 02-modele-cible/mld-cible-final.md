# MLD cible — Service de chasse immobilière

## 1. Objectif du document

Le **MLD (Modèle Logique de Données)** traduit le MCD cible validé en une structure directement exploitable par une base de données relationnelle.

Le MCD décrit le métier : les objets importants et leurs relations.
Le MLD précise comment ces informations seront organisées en **tables**, avec leurs identifiants et les liens entre elles.

Ce document a volontairement deux niveaux de lecture :

- une explication métier simple, compréhensible sans connaissance technique ;
- une représentation logique permettant de préparer l'implémentation PostgreSQL.

Le MLD constitue donc le pont entre la conception métier et la future base de données.

---

## 2. Définitions simples

### Table

Une **table** regroupe des informations de même nature.

Exemple : la table `BIEN` contient les biens immobiliers.

### PK — clé primaire

Une **clé primaire (PK, Primary Key)** est l'identifiant unique d'une ligne.

Exemple :

```text
id_bien PK
```

signifie que chaque bien possède son propre identifiant.

### FK — clé étrangère

Une **clé étrangère (FK, Foreign Key)** permet de relier une table à une autre.

Exemple :

```text
client_id FK → CLIENT(id_client)
```

signifie qu'une demande est reliée au client qui l'a formulée.

### UQ — contrainte d'unicité

`UQ` signifie qu'une valeur, ou une combinaison de valeurs, ne peut pas apparaître plusieurs fois lorsque la règle l'interdit.

### Facultatif

Un attribut indiqué comme `facultatif` peut ne pas avoir de valeur.

### Table d'association

Une **table d'association** sert à représenter une relation « plusieurs-à-plusieurs ».

Par exemple, une version de demande peut cibler plusieurs secteurs et un même secteur peut être ciblé par plusieurs versions. La table `VERSION_DEMANDE_SECTEUR` conserve ces associations.

---

## 3. Vue d'ensemble

Le MCD cible contient 24 entités métier.

Sa traduction relationnelle produit **26 tables** :

- 24 tables issues des entités métier ;
- 2 tables d'association nécessaires pour traduire les relations plusieurs-à-plusieurs :
  - `VERSION_DEMANDE_SECTEUR` ;
  - `VENDEUR_BIEN`.

Le renouvellement d'un mandat ne nécessite pas une table supplémentaire : un mandat peut référencer le mandat précédent qu'il renouvelle.

---

# 4. Identité et rôles

## 4.1 UTILISATEUR

### Rôle métier

`UTILISATEUR` centralise l'identité des personnes connues du système.

Une personne peut ensuite disposer d'un profil `CLIENT` ou `CHASSEUR`.

```text
UTILISATEUR(
    id_utilisateur PK,
    nom,
    prenom,
    email UQ,
    telephone,
    statut_compte
)
```

### Pourquoi cette table ?

Elle évite de dupliquer le nom, le prénom, l'email et le téléphone dans plusieurs tables.

L'email est unique afin d'éviter la création de plusieurs comptes avec la même adresse.

---

## 4.2 CLIENT

### Rôle métier

`CLIENT` représente le profil client d'un utilisateur.

```text
CLIENT(
    id_client PK FK → UTILISATEUR(id_utilisateur),
    statut
)
```

`id_client` est à la fois :

- la clé primaire du client ;
- une clé étrangère vers l'utilisateur correspondant.

Cela signifie simplement qu'un client est obligatoirement un utilisateur connu du système.

Le statut permet notamment de distinguer les situations métier telles que prospect et client.

---

## 4.3 CHASSEUR

### Rôle métier

`CHASSEUR` représente le professionnel chargé de rechercher des biens pour les clients.

```text
CHASSEUR(
    id_chasseur PK FK → UTILISATEUR(id_utilisateur),
    matricule UQ,
    disponibilite
)
```

Le matricule permet d'identifier le chasseur dans l'organisation.

La disponibilité permet de connaître sa capacité à prendre en charge une demande.

---

# 5. Demandes et affectations

## 5.1 DEMANDE

### Rôle métier

Une `DEMANDE` représente le besoin immobilier exprimé par un client.

```text
DEMANDE(
    id_demande PK,
    client_id FK → CLIENT(id_client),
    date_creation,
    statut
)
```

Un client peut formuler plusieurs demandes.

Le chasseur n'est volontairement **pas enregistré directement dans `DEMANDE`**. L'affectation est historisée dans une table spécifique.

---

## 5.2 AFFECTATION

### Rôle métier

`AFFECTATION` conserve l'historique des chasseurs auxquels une demande a été proposée.

```text
AFFECTATION(
    id_affectation PK,
    demande_id FK → DEMANDE(id_demande),
    chasseur_id FK → CHASSEUR(id_chasseur),
    date_affectation,
    date_reponse facultatif,
    statut,
    motif_refus facultatif
)
```

### Pourquoi une table spécifique ?

Une demande peut être proposée à un premier chasseur.

Celui-ci peut l'accepter ou la refuser.

En cas de refus, la demande peut ensuite être proposée à un autre chasseur.

Si le chasseur était simplement enregistré dans `DEMANDE`, l'ancienne affectation serait perdue. `AFFECTATION` permet donc de conserver tout l'historique.

---

# 6. Historisation des critères de recherche

## 6.1 VERSION_DEMANDE

### Rôle métier

Les critères recherchés par un client peuvent évoluer.

Au lieu d'écraser les anciennes informations, chaque modification crée une nouvelle version.

```text
VERSION_DEMANDE(
    id_version PK,
    demande_id FK → DEMANDE(id_demande),
    auteur_id FK → UTILISATEUR(id_utilisateur),
    numero_version,
    date_version,
    budget_min,
    budget_max,
    surface_min,
    surface_max,
    nb_pieces_min,
    motif_modification,
    est_courante,
    UQ(demande_id, numero_version)
)
```

Une demande possède au moins une version.

`auteur_id` permet de savoir qui a effectué la modification.

`est_courante` permet d'identifier les critères actuellement applicables.

Une seule version doit être courante pour une même demande.

---

## 6.2 SECTEUR

### Rôle métier

`SECTEUR` représente une zone géographique utilisée dans les recherches et pour localiser les biens.

```text
SECTEUR(
    id_secteur PK,
    ville,
    quartier,
    code_postal
)
```

---

## 6.3 VERSION_DEMANDE_SECTEUR

### Rôle métier

Une version de demande peut cibler plusieurs secteurs.

Un secteur peut également être ciblé par plusieurs versions de demandes.

```text
VERSION_DEMANDE_SECTEUR(
    version_id PK FK → VERSION_DEMANDE(id_version),
    secteur_id PK FK → SECTEUR(id_secteur)
)
```

La clé primaire est composée de :

```text
(version_id, secteur_id)
```

Elle empêche d'associer deux fois le même secteur à la même version.

---

# 7. Mandats

## 7.1 MANDAT

### Rôle métier

Le `MANDAT` représente le contrat qui encadre officiellement la mission du chasseur immobilier.

```text
MANDAT(
    id_mandat PK,
    demande_id FK → DEMANDE(id_demande),
    client_id FK → CLIENT(id_client),
    chasseur_id FK → CHASSEUR(id_chasseur),
    mandat_precedent_id FK → MANDAT(id_mandat), facultatif,
    date_signature,
    mode_signature,
    exclusif,
    date_fin,
    statut
)
```

Une demande peut ne produire aucun mandat ou aboutir à plusieurs mandats au cours de son histoire.

Le champ `mandat_precedent_id` permet d'indiquer qu'un mandat renouvelle un mandat antérieur.

Pour un premier mandat, ce champ reste vide.

### Règle métier importante

La durée initiale du mandat est :

```text
date_fin = date_signature + 6 mois
```

Un mandat exclusif actif doit empêcher la coexistence d'un autre mandat actif incompatible pour la même demande.

---

# 8. Biens et vendeurs

## 8.1 BIEN

### Rôle métier

`BIEN` contient les caractéristiques structurées d'un bien immobilier.

```text
BIEN(
    id_bien PK,
    secteur_id FK → SECTEUR(id_secteur),
    adresse,
    type_bien,
    prix,
    surface,
    nombre_pieces,
    dpe,
    description
)
```

Un bien est localisé dans un secteur.

Les informations structurées pourront notamment être utilisées ultérieurement pour comparer les biens aux critères des clients.

---

## 8.2 VENDEUR

### Rôle métier

`VENDEUR` représente une personne qui possède un bien proposé à la vente.

```text
VENDEUR(
    id_vendeur PK,
    nom,
    prenom,
    email,
    telephone
)
```

---

## 8.3 VENDEUR_BIEN

### Rôle métier

Un vendeur peut posséder plusieurs biens et un bien peut appartenir à plusieurs vendeurs.

```text
VENDEUR_BIEN(
    vendeur_id PK FK → VENDEUR(id_vendeur),
    bien_id PK FK → BIEN(id_bien)
)
```

Cette table conserve simplement les liens de propriété entre vendeurs et biens.

---

# 9. Présentation des biens

## 9.1 PRESENTATION

### Rôle métier

Une `PRESENTATION` signifie qu'un bien a été présenté à un client dans le cadre précis d'un mandat.

```text
PRESENTATION(
    id_presentation PK,
    mandat_id FK → MANDAT(id_mandat),
    bien_id FK → BIEN(id_bien),
    date_presentation,
    statut,
    priorite_client,
    decision_client,
    observations
)
```

Cette table permet de conserver le contexte : **quel bien a été présenté, dans le cadre de quel mandat, et quelle a été la réaction du client**.

---

## 9.2 COMMENTAIRE

### Rôle métier

`COMMENTAIRE` conserve les remarques formulées sur une présentation.

```text
COMMENTAIRE(
    id_commentaire PK,
    presentation_id FK → PRESENTATION(id_presentation),
    auteur_id FK → UTILISATEUR(id_utilisateur),
    texte,
    date_commentaire
)
```

L'auteur est conservé afin de distinguer les commentaires du client de ceux du chasseur.

---

## 9.3 VISITE

### Rôle métier

`VISITE` conserve les visites organisées à partir d'un bien présenté.

```text
VISITE(
    id_visite PK,
    presentation_id FK → PRESENTATION(id_presentation),
    date_visite,
    retour_client,
    interet
)
```

Une présentation peut ne donner lieu à aucune visite ou à plusieurs visites.

---

# 10. Avis du chasseur

## 10.1 AVIS_CHASSEUR

### Rôle métier

`AVIS_CHASSEUR` conserve l'avis professionnel du chasseur sur un bien présenté.

```text
AVIS_CHASSEUR(
    id_avis PK,
    presentation_id FK → PRESENTATION(id_presentation),
    chasseur_id FK → CHASSEUR(id_chasseur),
    date_avis,
    texte
)
```

---

## 10.2 MEDIA_AVIS

### Rôle métier

Un avis peut être complété par des médias, par exemple un enregistrement audio ou une vidéo.

```text
MEDIA_AVIS(
    id_media PK,
    avis_id FK → AVIS_CHASSEUR(id_avis),
    type_media,
    emplacement
)
```

`emplacement` conserve la référence permettant de retrouver le média. Le stockage physique du fichier relève de l'architecture technique.

---

# 11. Offre et vente

## 11.1 OFFRE

### Rôle métier

`OFFRE` représente une offre d'achat formulée à la suite de la présentation d'un bien.

```text
OFFRE(
    id_offre PK,
    presentation_id FK → PRESENTATION(id_presentation),
    date_offre,
    montant_offre,
    condition_financement,
    statut
)
```

Une présentation peut donner lieu à plusieurs offres au cours des négociations.

Le statut permet de suivre leur évolution : par exemple en attente, acceptée ou refusée.

---

## 11.2 NOTAIRE

### Rôle métier

`NOTAIRE` identifie le professionnel chargé d'authentifier la vente.

```text
NOTAIRE(
    id_notaire PK,
    nom,
    prenom,
    email,
    telephone
)
```

---

## 11.3 ACTE_AUTHENTIQUE

### Rôle métier

`ACTE_AUTHENTIQUE` représente la vente définitivement conclue et authentifiée par le notaire.

```text
ACTE_AUTHENTIQUE(
    id_acte PK,
    offre_id FK UQ → OFFRE(id_offre),
    notaire_id FK → NOTAIRE(id_notaire),
    date_acte,
    prix_vente
)
```

Une offre peut ne jamais aboutir à une vente.

Lorsqu'elle aboutit, elle ne peut produire qu'un seul acte authentique.

La contrainte `UQ` sur `offre_id` traduit cette règle.

---

# 12. Honoraires et rémunération

## 12.1 HONORAIRES

### Rôle métier

`HONORAIRES` conserve les honoraires générés par une vente authentifiée.

```text
HONORAIRES(
    id_honoraires PK,
    acte_id FK UQ → ACTE_AUTHENTIQUE(id_acte),
    montant_fixe,
    pourcentage,
    montant_total
)
```

Un acte authentique génère un seul enregistrement d'honoraires.

---

## 12.2 BAREME_COMMISSION

### Rôle métier

`BAREME_COMMISSION` décrit les règles de rémunération applicables à un chasseur pendant une période donnée.

```text
BAREME_COMMISSION(
    id_bareme PK,
    chasseur_id FK → CHASSEUR(id_chasseur),
    date_debut_validite,
    date_fin_validite facultatif
)
```

Un chasseur peut disposer de plusieurs barèmes au cours du temps.

Les périodes applicables doivent être cohérentes et ne pas se chevaucher pour un même chasseur.

---

## 12.3 TRANCHE_COMMISSION

### Rôle métier

Un barème est découpé en une ou plusieurs tranches.

Chaque tranche définit le taux applicable à une plage de montant.

```text
TRANCHE_COMMISSION(
    id_tranche PK,
    bareme_id FK → BAREME_COMMISSION(id_bareme),
    montant_min,
    montant_max,
    taux_pourcentage
)
```

Les tranches appartenant au même barème ne doivent pas se chevaucher.

---

## 12.4 COMMISSION

### Rôle métier

`COMMISSION` conserve le résultat du calcul de la rémunération due au chasseur.

```text
COMMISSION(
    id_commission PK,
    honoraires_id FK UQ → HONORAIRES(id_honoraires),
    chasseur_id FK → CHASSEUR(id_chasseur),
    tranche_id FK → TRANCHE_COMMISSION(id_tranche),
    montant_commission,
    taux_applique
)
```

Cette table conserve :

- les honoraires ayant servi au calcul ;
- le chasseur bénéficiaire ;
- la tranche utilisée ;
- le taux réellement appliqué ;
- le montant obtenu.

Cela rend le calcul traçable et vérifiable.

---

# 13. Facturation et paiement

## 13.1 FACTURE_CHASSEUR

### Rôle métier

Une fois sa commission déterminée, le chasseur peut émettre une facture.

```text
FACTURE_CHASSEUR(
    id_facture PK,
    commission_id FK UQ → COMMISSION(id_commission),
    chasseur_id FK → CHASSEUR(id_chasseur),
    reference UQ,
    date_depot,
    montant,
    statut,
    date_verification facultatif
)
```

Le statut permet notamment de suivre le dépôt et la vérification de la facture avant paiement.

---

## 13.2 PAIEMENT

### Rôle métier

`PAIEMENT` enregistre les sommes réellement versées au titre d'une facture.

```text
PAIEMENT(
    id_paiement PK,
    facture_id FK → FACTURE_CHASSEUR(id_facture),
    montant_paye,
    date_paiement,
    statut
)
```

Une facture peut faire l'objet de plusieurs paiements, par exemple en cas de paiement fractionné.

La séparation entre facture et paiement permet de distinguer :

- ce qui est demandé par le chasseur ;
- ce qui a été contrôlé ;
- ce qui a réellement été payé.

---

# 14. Principales relations

| Relation | Explication simple |
| --- | --- |
| `UTILISATEUR` → `CLIENT` | Un utilisateur peut posséder un profil client. |
| `UTILISATEUR` → `CHASSEUR` | Un utilisateur peut posséder un profil chasseur. |
| `CLIENT` → `DEMANDE` | Un client peut formuler plusieurs demandes. |
| `DEMANDE` → `AFFECTATION` | Une demande conserve l'historique de ses affectations. |
| `CHASSEUR` → `AFFECTATION` | Un chasseur peut recevoir plusieurs demandes. |
| `DEMANDE` → `VERSION_DEMANDE` | Une demande possède une ou plusieurs versions de ses critères. |
| `UTILISATEUR` → `VERSION_DEMANDE` | Chaque modification conserve son auteur. |
| `VERSION_DEMANDE` ↔ `SECTEUR` | Une version peut cibler plusieurs secteurs. |
| `DEMANDE` → `MANDAT` | Une demande peut aboutir à plusieurs mandats au cours du temps. |
| `CLIENT` → `MANDAT` | Un client peut signer plusieurs mandats. |
| `CHASSEUR` → `MANDAT` | Un chasseur peut exécuter plusieurs mandats. |
| `MANDAT` → `MANDAT` | Un mandat peut renouveler un mandat précédent. |
| `SECTEUR` → `BIEN` | Un secteur peut contenir plusieurs biens. |
| `VENDEUR` ↔ `BIEN` | Plusieurs vendeurs peuvent posséder plusieurs biens. |
| `MANDAT` → `PRESENTATION` | Un mandat peut comporter plusieurs présentations de biens. |
| `BIEN` → `PRESENTATION` | Un bien peut être présenté dans plusieurs contextes. |
| `PRESENTATION` → `COMMENTAIRE` | Une présentation peut recevoir plusieurs commentaires. |
| `PRESENTATION` → `VISITE` | Une présentation peut donner lieu à plusieurs visites. |
| `PRESENTATION` → `AVIS_CHASSEUR` | Une présentation peut recevoir plusieurs avis du chasseur. |
| `AVIS_CHASSEUR` → `MEDIA_AVIS` | Un avis peut contenir plusieurs médias. |
| `PRESENTATION` → `OFFRE` | Une présentation peut donner lieu à plusieurs offres. |
| `OFFRE` → `ACTE_AUTHENTIQUE` | Une offre acceptée peut aboutir à une vente authentifiée. |
| `NOTAIRE` → `ACTE_AUTHENTIQUE` | Un notaire peut authentifier plusieurs actes. |
| `ACTE_AUTHENTIQUE` → `HONORAIRES` | Une vente génère ses honoraires. |
| `CHASSEUR` → `BAREME_COMMISSION` | Un chasseur peut avoir plusieurs barèmes successifs. |
| `BAREME_COMMISSION` → `TRANCHE_COMMISSION` | Un barème contient une ou plusieurs tranches. |
| `HONORAIRES` → `COMMISSION` | Les honoraires servent au calcul de la commission. |
| `CHASSEUR` → `COMMISSION` | Le chasseur perçoit la commission calculée. |
| `TRANCHE_COMMISSION` → `COMMISSION` | La tranche permet de justifier le taux appliqué. |
| `COMMISSION` → `FACTURE_CHASSEUR` | Une commission peut donner lieu à une facture. |
| `CHASSEUR` → `FACTURE_CHASSEUR` | Le chasseur émet sa facture. |
| `FACTURE_CHASSEUR` → `PAIEMENT` | Une facture peut faire l'objet de plusieurs paiements. |

---

# 15. Principales règles de cohérence

Le futur schéma PostgreSQL devra notamment garantir les règles suivantes.

### Identité

- l'email d'un utilisateur est unique ;
- le matricule d'un chasseur est unique ;
- les profils client et chasseur respectent les règles métier définies pour les utilisateurs.

### Demandes

- une demande appartient à un seul client ;
- une demande possède au moins une version ;
- les numéros de version sont uniques à l'intérieur d'une même demande ;
- une seule version peut être marquée comme courante pour une demande ;
- chaque version conserve son auteur et sa date ;
- une version doit cibler au moins un secteur.

### Affectations

- chaque affectation concerne une demande et un chasseur ;
- un refus peut conserver son motif ;
- les anciennes affectations ne sont pas supprimées lors d'une réaffectation.

### Mandats

- un mandat est relié à une demande, un client et un chasseur ;
- une demande peut posséder plusieurs mandats au cours du temps ;
- la date de fin initiale correspond à la date de signature augmentée de six mois ;
- un mandat renouvelé peut référencer son mandat précédent ;
- un mandat exclusif actif empêche la coexistence d'un autre mandat actif incompatible pour la même demande ;
- le client et le chasseur du mandat doivent être cohérents avec le parcours de la demande.

### Biens

- un bien est localisé dans un secteur ;
- les prix et surfaces doivent être positifs ou nuls selon les règles métier retenues ;
- la propriété vendeur/bien est conservée dans `VENDEUR_BIEN`.

### Présentations et visites

- une présentation concerne un mandat et un bien ;
- les commentaires conservent leur auteur ;
- les visites et avis restent rattachés à la présentation qui leur donne leur contexte.

### Vente

- une offre appartient à une présentation ;
- une offre ne peut produire qu'un seul acte authentique ;
- l'acte conserve le notaire qui l'a authentifié ;
- les dates doivent respecter l'ordre logique du parcours : présentation, offre, acte.

### Rémunération

- un barème appartient à un chasseur ;
- un barème comporte au moins une tranche ;
- les périodes de validité des barèmes d'un même chasseur ne doivent pas se chevaucher lorsque la règle métier l'exige ;
- les tranches d'un même barème ne doivent pas se chevaucher ;
- `montant_max` doit être supérieur ou égal à `montant_min` ;
- les montants et taux ne peuvent pas être négatifs ;
- la commission doit être reliée au chasseur et à la tranche ayant servi à son calcul ;
- la facture doit être cohérente avec la commission facturée ;
- un paiement doit être rattaché à une facture existante.

Certaines règles seront directement garanties par les PK, FK, contraintes d'unicité et contrôles SQL.

Les règles faisant intervenir plusieurs tables pourront nécessiter des contraintes complémentaires, des fonctions ou des contrôles applicatifs lors de l'implémentation.

---

# 16. Liste finale des tables

Le MLD cible contient **26 tables** :

1. `UTILISATEUR`
2. `CLIENT`
3. `CHASSEUR`
4. `DEMANDE`
5. `AFFECTATION`
6. `VERSION_DEMANDE`
7. `SECTEUR`
8. `VERSION_DEMANDE_SECTEUR`
9. `MANDAT`
10. `BIEN`
11. `VENDEUR`
12. `VENDEUR_BIEN`
13. `PRESENTATION`
14. `COMMENTAIRE`
15. `VISITE`
16. `AVIS_CHASSEUR`
17. `MEDIA_AVIS`
18. `OFFRE`
19. `NOTAIRE`
20. `ACTE_AUTHENTIQUE`
21. `HONORAIRES`
22. `BAREME_COMMISSION`
23. `TRANCHE_COMMISSION`
24. `COMMISSION`
25. `FACTURE_CHASSEUR`
26. `PAIEMENT`

Les tables `VERSION_DEMANDE_SECTEUR` et `VENDEUR_BIEN` sont des tables d'association ajoutées lors du passage du MCD au MLD.

---

# 17. Justification générale du modèle

Le MLD cible répond aux principales faiblesses identifiées lors de l'audit de l'existant.

Il permet notamment :

- de séparer clairement l'identité d'un utilisateur de ses responsabilités métier ;
- de conserver l'historique des affectations d'une demande ;
- de conserver toutes les évolutions des critères de recherche ;
- de structurer les secteurs et les caractéristiques des biens ;
- de gérer plusieurs mandats dans le temps ;
- de conserver les présentations, commentaires, visites et avis ;
- de suivre une offre jusqu'à la vente authentifiée ;
- de rendre le calcul de la rémunération du chasseur traçable ;
- de distinguer commission, facture et paiement ;
- de préparer les futurs usages analytiques et de matching sans mélanger ces besoins avec le fonctionnement transactionnel courant.

Le MLD reste volontairement indépendant des détails physiques de PostgreSQL.

Les types SQL précis, les index, les contraintes techniques détaillées et les mécanismes d'implémentation seront définis dans le **MPD (Modèle Physique de Données)** et dans les scripts SQL de migration.

---

# 18. Conclusion

Ce MLD constitue la traduction logique du MCD cible validé.

Il conserve les règles métier importantes tout en préparant leur implémentation dans une base relationnelle.

La chaîne générale devient ainsi compréhensible de bout en bout :

```text
Utilisateur
    ↓
Client
    ↓
Demande
    ↓
Versions des critères
    ↓
Affectation à un chasseur
    ↓
Mandat
    ↓
Présentation de biens
    ↓
Commentaires / visites / avis
    ↓
Offre
    ↓
Acte authentique
    ↓
Honoraires
    ↓
Commission du chasseur
    ↓
Facture
    ↓
Paiement
```

Cette organisation permet à la fois de répondre au besoin métier, de conserver l'historique des événements importants et de rendre les opérations sensibles traçables.
