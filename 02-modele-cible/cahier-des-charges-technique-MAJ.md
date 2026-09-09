# Cahier des charges technique --- Chasse immobilière

## 1. Contexte et objectifs

Le système d'information existant du service de chasse immobilière
repose sur une base de données historique devenue insuffisante pour
représenter correctement les besoins métier.

L'audit réalisé en Phase 1 a notamment mis en évidence :

-   le mélange des clients et des chasseurs dans une même table
    `utilisateurs` ;
-   des critères de recherche stockés sous forme de texte libre ;
-   l'absence d'historisation des évolutions d'une demande ;
-   une représentation insuffisante du cycle de vie des mandats ;
-   l'absence de gestion structurée des biens présentés, visites, offres
    et acquisitions ;
-   une gestion trop simplifiée des commissions des chasseurs ;
-   plusieurs anomalies de qualité et de cohérence dans les données
    héritées.

La Phase 2 vise à construire un modèle transactionnel cible répondant au
besoin métier actuel et pouvant servir de socle au futur backend.

Le système cible doit notamment permettre :

-   de distinguer clairement les clients et les chasseurs ;
-   de gérer le cycle de vie complet d'un mandat ;
-   de structurer et historiser les demandes immobilières ;
-   de rattacher les biens aux versions de recherche concernées ;
-   de conserver les commentaires, visites et offres ;
-   de tracer les acquisitions et les honoraires ;
-   de gérer les barèmes de commission par chasseur, par période et par
    tranche ;
-   de tracer les commissions, les factures des chasseurs et leurs paiements ;
-   de garantir une meilleure intégrité des données ;
-   de respecter les principes du RGPD dès la conception ;
-   de permettre aux futures interfaces de respecter les exigences
    d'accessibilité PSH.

La présente spécification complète la note de cadrage et s'appuie sur
les besoins métier, les règles de gestion, le MCD et le MLD définis pour
la Phase 2.

------------------------------------------------------------------------

## 2. Périmètre fonctionnel

### 2.1 Dans le périmètre

Le périmètre de la Phase 2 comprend :

-   le modèle de données transactionnel cible ;
-   la gestion des utilisateurs ;
-   la spécialisation des utilisateurs en profils client et chasseur ;
-   la gestion des demandes immobilières ;
-   la gestion de leur affectation aux chasseurs et de la réponse du chasseur ;
-   la gestion des mandats ;
-   l'historisation des versions de demandes ;
-   la gestion des secteurs recherchés ;
-   la gestion structurée des biens et de leurs vendeurs ;
-   la présentation d'un bien dans le contexte d'une version de demande
    ;
-   la gestion des commentaires ;
-   la gestion des visites ;
-   la gestion des avis du chasseur et des médias associés ;
-   la gestion des offres ;
-   la traçabilité des actes authentiques et du notaire ;
-   la gestion des honoraires ;
-   la gestion des barèmes de commission ;
-   la gestion des tranches de commission ;
-   le calcul et la traçabilité des commissions ;
-   la gestion des factures émises par les chasseurs ;
-   la gestion des paiements rattachés à ces factures ;
-   la reprise contrôlée des données héritées ;
-   la protection des données personnelles dès la conception ;
-   les contraintes nécessaires à la future intégration du backend.

### 2.2 Hors périmètre de la Phase 2

Ne sont pas réalisés dans cette phase :

-   le développement complet du futur backend/API ;
-   la refonte du site web existant ;
-   la refonte de l'application métier existante ;
-   l'application mobile ;
-   l'entraînement d'un modèle d'intelligence artificielle ;
-   le moteur automatique de matching bien/demande ;
-   le modèle décisionnel OLAP ;
-   le dimensionnement big data ;
-   le partitionnement, la réplication ou le sharding ;
-   le PCA/PRA ;
-   l'architecture détaillée liée à la croissance internationale.

Ces éléments seront étudiés dans les phases ultérieures prévues par le
projet.

------------------------------------------------------------------------

## 3. Exigences fonctionnelles

  -----------------------------------------------------------------------
  ID                      Exigence                Source / parcours
                                                  concerné
  ----------------------- ----------------------- -----------------------
  EF-01                   Le système doit         RG-01
                          distinguer
                          l'utilisateur commun de
                          ses profils métier
                          client et chasseur.

  EF-02                   Un client doit pouvoir  RG-02
                          être associé à
                          plusieurs mandats.

  EF-03                   Chaque mandat doit être RG-03
                          associé à un seul
                          client.

  EF-04                   Un chasseur doit        RG-04
                          pouvoir gérer plusieurs
                          mandats.

  EF-05                   Chaque mandat doit être RG-05
                          affecté à un seul
                          chasseur.

  EF-06                   Un mandat doit          RG-06
                          conserver sa date de
                          signature.

  EF-07                   Un mandat doit          RG-07
                          conserver son mode de
                          signature.

  EF-08                   Le système doit         RG-08
                          distinguer les mandats
                          exclusifs et non
                          exclusifs.

  EF-09                   La durée initiale d'un  RG-09
                          mandat doit être de six
                          mois.

  EF-10                   La date de fin d'un     RG-10
                          mandat doit
                          correspondre à la date
                          de signature augmentée
                          de six mois.

  EF-11                   Le modèle doit          RG-11
                          permettre de tracer le
                          renouvellement d'un
                          mandat.

  EF-12                   Le statut d'un mandat   RG-12
                          doit permettre de
                          représenter son cycle
                          de vie.

  EF-13                   Chaque mandat doit      RG-13
                          pouvoir être associé à
                          une demande immobilière
                          structurée.

  EF-14                   Une demande doit        RG-14, RG-54
                          pouvoir contenir des
                          critères structurés
                          tels que budget
                          maximal, type de bien,
                          surface minimale et
                          nombre minimal de
                          pièces.

  EF-15                   Une demande doit        RG-15
                          pouvoir évoluer pendant
                          la durée du mandat.

  EF-16                   Toute évolution         RG-16
                          significative d'une
                          demande doit pouvoir
                          générer une nouvelle
                          version.

  EF-17                   Chaque version d'une    RG-17
                          demande doit conserver
                          son auteur, sa date,
                          son numéro de version
                          et le motif de la
                          modification.

  EF-18                   La création d'une       RG-18
                          nouvelle version ne
                          doit pas supprimer ni
                          écraser les versions
                          précédentes.

  EF-19                   Une version de demande  RG-19
                          doit pouvoir être
                          associée à un ou
                          plusieurs secteurs.

  EF-20                   Un bien doit posséder   RG-20
                          des caractéristiques
                          structurées utiles au
                          traitement de la
                          recherche immobilière.

  EF-21                   Un bien doit pouvoir    RG-21
                          être présenté dans le
                          contexte d'un mandat.

  EF-22                   Un mandat doit pouvoir  RG-22
                          comporter plusieurs
                          présentations de biens.

  EF-23                   Un même bien doit       RG-23
                          pouvoir être présenté
                          dans plusieurs
                          recherches différentes.

  EF-24                   La présentation doit    RG-24
                          conserver le contexte
                          entre un bien et le
                          mandat concerné.

  EF-25                   Un commentaire doit     RG-25
                          être rattaché à une
                          présentation de bien.

  EF-26                   Un commentaire doit     RG-26
                          identifier son auteur,
                          client ou chasseur.

  EF-27                   Un commentaire doit     RG-27
                          conserver sa date.

  EF-28                   Une recherche doit      RG-28
                          pouvoir conduire à
                          plusieurs visites.

  EF-29                   Une visite doit         RG-29
                          concerner un bien dans
                          le contexte de sa
                          présentation.

  EF-30                   Le système doit         RG-30
                          permettre d'enregistrer
                          plusieurs offres
                          successives concernant
                          une présentation.

  EF-31                   Une offre doit au       RG-31
                          minimum conserver sa
                          date, son montant et
                          son statut.

  EF-32                   Une offre acceptée doit RG-32
                          pouvoir être associée à
                          un acte authentique.

  EF-33                   Le système doit         RG-33
                          distinguer les
                          honoraires perçus par
                          l'entreprise de la
                          commission due au
                          chasseur.

  EF-34                   Les honoraires doivent  RG-34
                          être rattachés à une
                          acquisition
                          matérialisée par un
                          acte authentique.

  EF-35                   Les honoraires doivent  RG-35
                          pouvoir représenter une
                          composante fixe, un
                          taux et un montant
                          total.

  EF-36                   La commission du        RG-36
                          chasseur doit être
                          calculable à partir
                          d'un barème structuré.

  EF-37                   Un barème doit pouvoir  RG-37
                          contenir plusieurs
                          tranches de montant.

  EF-38                   Un barème doit posséder RG-38
                          une période de
                          validité.

  EF-39                   Les règles de           RG-39
                          commission doivent
                          pouvoir différer selon
                          le chasseur.

  EF-40                   Le barème et la tranche RG-40
                          utilisés pour
                          déterminer une
                          commission doivent
                          rester traçables.

  EF-41                   Le processus doit       RG-41
                          tracer la commission,
                          la facture du chasseur
                          puis les paiements
                          associés à cette facture.

  EF-42                   Chaque paiement doit    RG-42
                          conserver au minimum sa
                          date, son montant et
                          son statut.

  EF-43                   Chaque paiement doit    RG-43
                          être rattaché à une
                          facture chasseur
                          identifiée.

  EF-44                   Le statut de la facture RG-44
                          et du paiement doit
                          permettre de distinguer
                          les rémunérations en
                          attente de celles
                          effectivement réglées.

  EF-45                   Le modèle doit          RG-45, RG-46
                          permettre de calculer
                          ultérieurement des
                          indicateurs de
                          performance à partir
                          des données métier
                          enregistrées.

  EF-46                   Les informations        RG-55, RG-56, RG-57
                          nécessaires à un futur
                          traitement analytique
                          ou IA doivent être
                          conservées de façon
                          structurée et
                          exploitable.
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## 4. Exigences non fonctionnelles

  ----------------------------------------------------------------------------------------
  Catégorie         ID                Exigence                     Critère de vérification
  ----------------- ----------------- ---------------------------- -----------------------
  Intégrité         ENF-01            Les relations structurantes  Inspection du MLD et de
                                      du modèle doivent être       `migration-final.sql`
                                      protégées par des clés
                                      primaires, étrangères et
                                      contraintes d'unicité
                                      adaptées.

  Intégrité         ENF-02            Les montants financiers ne   Tests d'insertion SQL
                                      doivent pas accepter de
                                      valeur négative lorsqu'une
                                      telle valeur serait
                                      incompatible avec la règle
                                      métier.

  Intégrité         ENF-03            La date de fin d'un mandat   Test SQL sur la
                                      doit être contrôlée selon la contrainte
                                      règle
                                      `date_signature + 6 mois`.

  Intégrité         ENF-04            Une nouvelle version de      Vérification de
                                      demande ne doit pas écraser  l'historique des
                                      une version précédente.      versions

  Traçabilité       ENF-05            Les données reprises depuis  Comparaison des
                                      l'ancien système doivent     identifiants et rapport
                                      rester identifiables et      de reprise
                                      contrôlables.

  Traçabilité       ENF-06            Les anomalies non            Consultation du schéma
                                      corrigibles automatiquement  `reprise_controle`
                                      lors de la migration doivent
                                      être enregistrées
                                      explicitement.

  Transaction       ENF-07            Les scripts de création et   Présence de `BEGIN` /
                                      de reprise doivent être      `COMMIT` et test
                                      exécutables dans une         d'exécution
                                      transaction afin d'éviter
                                      une migration partiellement
                                      appliquée.

  Rejouabilité      ENF-08            Le script de création du     Deux exécutions
                                      modèle doit pouvoir être     successives de
                                      rejoué sur l'environnement   `migration-final.sql`
                                      de développement.

  Performance       ENF-09            Les principales relations de Analyse des plans
                                      consultation doivent pouvoir d'exécution
                                      être exploitées efficacement
                                      par PostgreSQL et les
                                      optimisations devront être
                                      justifiables par `EXPLAIN`
                                      lors des travaux de
                                      performance.

  Sécurité          ENF-10            L'accès à la base de données Test de connexion avec
                                      doit être authentifié.       et sans identifiants
                                                                   valides

  Sécurité          ENF-11            Les futures applications ne  Revue des comptes et
                                      devront pas utiliser un      privilèges
                                      compte PostgreSQL disposant
                                      de droits d'administration
                                      pour leurs opérations
                                      courantes.

  Sécurité          ENF-12            Les accès futurs devront     Tests d'autorisation
                                      respecter le principe du
                                      moindre privilège.

  Sécurité          ENF-13            Les échanges réseau exposant Vérification de la
                                      des données personnelles     configuration
                                      devront être protégés par un d'exploitation
                                      protocole chiffré en
                                      environnement déployé.

  RGPD              ENF-14            Le système doit appliquer le Revue du modèle et
                                      principe de minimisation des registre RGPD
                                      données personnelles.

  RGPD              ENF-15            Chaque traitement de données Registre des
                                      personnelles doit posséder   traitements
                                      une finalité documentée.

  RGPD              ENF-16            Chaque traitement doit       Registre des
                                      posséder une base légale     traitements
                                      identifiée et une durée de
                                      conservation définie.

  RGPD              ENF-17            Le système devra permettre   Procédure documentée et
                                      la prise en compte des       tests futurs de l'API
                                      droits des personnes
                                      concernées.

  RGPD              ENF-18            Les opérations sensibles     Vérification du
                                      portant sur les données      mécanisme de
                                      personnelles devront pouvoir journalisation lors de
                                      être tracées.                l'implémentation

  RGPD              ENF-19            Les données utilisées        Revue du flux IA et de
                                      ultérieurement pour l'IA ou  la note
                                      transmises à un service      souveraineté/sécurité
                                      externe devront être
                                      minimisées, anonymisées ou
                                      pseudonymisées lorsque cela
                                      est nécessaire.

  Accessibilité PSH ENF-20            Les interfaces futures       Audit d'accessibilité
                                      consommant le backend        de l'interface en Phase
                                      devront être conçues de      4
                                      manière à respecter les
                                      principes d'accessibilité
                                      applicables aux parcours
                                      concernés.

  Accessibilité PSH ENF-21            Les informations métier et   Revue des contrats
                                      messages d'erreur exposés    d'API et tests
                                      par l'API devront être       fonctionnels
                                      compréhensibles et
                                      exploitables par une
                                      interface accessible, sans
                                      dépendre uniquement d'un
                                      code couleur ou d'un élément
                                      visuel.

  Éco-conception    ENF-22            Les données inutiles ne      Revue du modèle et note
                                      doivent pas être conservées  d'éco-conception
                                      sans justification métier,
                                      réglementaire ou analytique.

  Éco-conception    ENF-23            Les futures sauvegardes      Note d'éco-conception
                                      devront appliquer une
                                      fréquence et une durée de
                                      rétention proportionnées à
                                      la criticité des données.

  Éco-conception    ENF-24            Les requêtes et traitements  Analyse SQL et plans
                                      répétitifs devront être      `EXPLAIN`
                                      optimisés afin de limiter
                                      les consommations CPU,
                                      stockage et entrées/sorties
                                      inutiles.

  Scalabilité       ENF-25            Le modèle transactionnel ne  Revue du modèle et
                                      doit pas empêcher les        étude d'architecture de
                                      futures évolutions liées à   Phase 3
                                      l'augmentation des volumes
                                      ou à l'internationalisation.

  Maintenabilité    ENF-26            Les scripts SQL doivent être Revue de code
                                      structurés, commentés et
                                      compréhensibles par un autre
                                      intervenant technique.

  Maintenabilité    ENF-27            Les décisions techniques     Vérification du journal
                                      structurantes doivent être   de décisions
                                      documentées dans le journal
                                      de décisions.
  ----------------------------------------------------------------------------------------

------------------------------------------------------------------------

## 5. Contraintes techniques

### 5.1 SGBD cible

Le SGBD transactionnel retenu est PostgreSQL.

Ce choix est documenté dans le journal de décisions.

PostgreSQL est adapté au modèle cible car celui-ci repose fortement sur
:

-   des relations entre entités ;
-   des clés étrangères ;
-   des contraintes d'unicité ;
-   des contraintes de cohérence ;
-   des transactions ;
-   un historique de données ;
-   des traitements SQL structurés.

Le choix de PostgreSQL ne signifie pas qu'il est systématiquement
supérieur aux autres SGBD, mais qu'il constitue ici une solution
cohérente avec les besoins identifiés.

### 5.2 Compatibilité avec l'existant

Les données de départ fournies par le projet doivent être considérées
comme l'existant à migrer.

Les fichiers de fixtures ne doivent pas être modifiés pour masquer ou
corriger les anomalies constatées.

La reprise doit être effectuée par transformation vers le nouveau
modèle.

### 5.3 Schémas PostgreSQL

Le projet utilise notamment :

-   `"Fil_Rouge_Depart"` pour les données héritées ;
-   `fil_rouge_cible` pour le nouveau modèle ;
-   `reprise_controle` pour la traçabilité des rejets de migration.

### 5.4 Scripts SQL

Le projet comporte deux scripts principaux :

-   `migration-final.sql` : construction du modèle cible ;
-   `reprise-donnees-final.sql` : transformation et reprise des données
    héritées.

Les scripts doivent être :

-   commentés ;
-   compréhensibles ;
-   contrôlables ;
-   transactionnels ;
-   rejouables dans l'environnement de développement lorsque cela est
    prévu.

### 5.5 Conservation des identifiants historiques

Lorsque cela est possible et pertinent, les identifiants historiques
sont conservés pendant la reprise afin de faciliter :

-   la traçabilité ;
-   la comparaison avant/après ;
-   le contrôle de migration ;
-   l'identification des anomalies.

### 5.6 Intégrations futures

Le modèle devra pouvoir être exploité par le futur backend/API.

Les structures de données doivent également permettre ultérieurement :

-   l'alimentation d'un modèle analytique ;
-   le calcul d'indicateurs ;
-   la construction de variables utiles au matching bien/demande ;
-   l'exploitation contrôlée des données par des traitements IA.

Ces usages futurs ne font pas partie de l'implémentation de la Phase 2.

------------------------------------------------------------------------

## 6. Architecture cible

### 6.1 Architecture logique de la Phase 2

La Phase 2 repose sur une base transactionnelle **OLTP PostgreSQL 16**.\
OLTP signifie ici la base opérationnelle utilisée pour enregistrer les
opérations métier quotidiennes.

Le modèle final validé comporte **26 tables** :

1.  `UTILISATEUR`
2.  `CLIENT`
3.  `CHASSEUR`
4.  `DEMANDE`
5.  `AFFECTATION`
6.  `VERSION_DEMANDE`
7.  `SECTEUR`
8.  `VERSION_DEMANDE_SECTEUR`
9.  `MANDAT`
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

### 6.2 Pourquoi `UTILISATEUR` est le pivot

Les informations communes --- nom, prénom, email, téléphone et statut du
compte --- sont stockées dans `UTILISATEUR`.

Les profils métier spécialisent ensuite cet utilisateur :

``` text
UTILISATEUR
├── CLIENT
└── CHASSEUR
```

Ce choix évite de dupliquer les informations communes tout en conservant
les attributs propres à chaque rôle.

La règle métier retenue interdit qu'un même utilisateur soit
simultanément client et chasseur dans le modèle métier courant. Cette
règle transverse devra être contrôlée par la couche applicative ou par
un mécanisme PostgreSQL adapté si nécessaire.

### 6.3 Ordre réel du parcours métier

Le parcours n'est pas « mandat puis demande ». La demande existe avant
le mandat :

``` text
CLIENT
  ↓
DEMANDE
  ↓
VERSION_DEMANDE
  ↓
AFFECTATION au CHASSEUR
  ↓
acceptation / refus
  ↓
MANDAT
  ↓
PRESENTATION de BIENS
  ↓
COMMENTAIRE / VISITE / AVIS_CHASSEUR
  ↓
OFFRE
  ↓
ACTE_AUTHENTIQUE
  ↓
HONORAIRES
  ↓
COMMISSION
  ↓
FACTURE_CHASSEUR
  ↓
PAIEMENT
```

Cette chronologie permet de représenter la demande initiale, son
affectation, puis seulement la contractualisation par mandat.

### 6.4 Historisation de la demande

Une `DEMANDE` possède une ou plusieurs `VERSION_DEMANDE`.

Une nouvelle version conserve l'état précédent au lieu de l'écraser.
Elle mémorise notamment son numéro, sa date, son auteur, ses critères et
son motif de modification.

Une version peut cibler plusieurs secteurs grâce à
`VERSION_DEMANDE_SECTEUR`.

### 6.5 Mandat et renouvellement

Le mandat relie la demande, le client et le chasseur ayant accepté la
prise en charge.

La durée initiale est de six mois :

``` text
date_fin = date_signature + 6 mois
```

L'exclusivité est conservée et un mandat peut référencer son mandat
précédent afin de tracer un renouvellement.

### 6.6 Biens, vendeurs et présentations

`VENDEUR_BIEN` représente l'association entre vendeurs et biens.

`PRESENTATION` conserve le fait qu'un bien précis a été présenté dans le
cadre d'un mandat précis. Elle sert ensuite de contexte aux
commentaires, visites, avis du chasseur et offres.

### 6.7 Acquisition et rémunération

Le parcours financier est séparé volontairement :

``` text
OFFRE
→ ACTE_AUTHENTIQUE
→ HONORAIRES
→ COMMISSION
→ FACTURE_CHASSEUR
→ PAIEMENT
```

Les `HONORAIRES` correspondent aux sommes perçues par l'entreprise.

La `COMMISSION` correspond à la rémunération calculée pour le chasseur à
partir d'un barème et d'une tranche.

`FACTURE_CHASSEUR` matérialise ensuite la facture émise par le chasseur,
et `PAIEMENT` le règlement de cette facture.

Cette séparation permet de distinguer clairement ce que reçoit
l'entreprise de ce qui est dû puis payé au chasseur.

### 6.8 Évolutions d'architecture

La séparation OLTP/OLAP, le dimensionnement lié à la croissance, le
partitionnement, la réplication et la distribution des données seront
étudiés en Phase 3.

Ils ne sont pas imposés prématurément au modèle transactionnel de Phase
2.

------------------------------------------------------------------------

## 7. Données, confidentialité et RGPD

### 7.1 Données personnelles traitées

Le système traite notamment les données personnelles suivantes :

#### Identité et contact

-   nom ;
-   prénom ;
-   adresse électronique ;
-   téléphone ;
-   ville.

#### Données liées à la recherche immobilière

-   budget maximal ;
-   secteurs recherchés ;
-   type de bien ;
-   surface minimale ;
-   nombre minimal de pièces ;
-   commentaires associés aux recherches.

#### Données contractuelles

-   mandats ;
-   dates de signature ;
-   mode de signature ;
-   statut du mandat ;
-   exclusivité.

#### Données professionnelles des chasseurs

-   mandats affectés ;
-   barèmes ;
-   commissions ;
-   paiements liés aux commissions.

#### Données transactionnelles

-   offres ;
-   prix d'acquisition ;
-   honoraires ;
-   commissions ;
-   montants de paiement.

Ces informations peuvent permettre d'identifier directement ou
indirectement une personne physique et doivent donc être traitées comme
des données personnelles lorsqu'elles sont rattachées à une personne
identifiable.

### 7.2 Données sensibles au sens du RGPD

Le modèle métier défini dans cette phase n'a pas vocation à collecter
des catégories particulières de données telles que :

-   données de santé ;
-   opinions politiques ;
-   convictions religieuses ;
-   origine ethnique ;
-   orientation sexuelle ;
-   données biométriques utilisées à des fins d'identification.

Le système ne doit pas introduire ce type de données sans nouvelle
analyse de nécessité, de finalité et de conformité.

### 7.3 Finalités des traitements

Les principales finalités identifiées sont :

-   gestion de la relation avec le client ;
-   exécution et suivi du mandat de recherche ;
-   définition et évolution des critères immobiliers ;
-   présentation et suivi des biens ;
-   organisation des visites ;
-   suivi des offres et acquisitions ;
-   calcul des honoraires ;
-   calcul et paiement des commissions ;
-   pilotage de l'activité ;
-   préparation de futurs traitements analytiques ou IA.

Le détail des traitements devra être maintenu dans le registre RGPD du
projet.

### 7.4 Bases légales

Chaque traitement devra être associé dans le registre RGPD à une base
légale appropriée.

Selon le traitement concerné, celle-ci pourra notamment relever :

-   de l'exécution d'un contrat ;
-   d'une obligation légale ;
-   de l'intérêt légitime lorsqu'il est applicable ;
-   du consentement lorsque celui-ci constitue effectivement la base
    appropriée.

La base légale ne doit pas être déterminée uniquement au niveau
technique : elle doit être documentée traitement par traitement.

### 7.5 Minimisation des données

Le système applique le principe de minimisation :

-   seules les données nécessaires à une finalité identifiée doivent
    être collectées ;
-   les champs inutiles ne doivent pas être ajoutés par simple
    anticipation ;
-   les traitements analytiques ou IA futurs ne justifient pas à eux
    seuls une collecte illimitée ;
-   les données utilisées pour des tests doivent autant que possible
    être fictives, anonymisées ou pseudonymisées.

### 7.6 Privacy by design

La protection des données doit être intégrée dès la conception.

Cela implique notamment :

-   séparation claire des responsabilités métier ;
-   limitation des données stockées ;
-   contraintes d'intégrité ;
-   traçabilité des transformations ;
-   contrôle des accès ;
-   limitation des privilèges ;
-   anticipation des durées de conservation ;
-   capacité future de rectification, suppression ou anonymisation
    lorsque cela est applicable.

### 7.7 Droits des personnes

Le futur système devra permettre de prendre en compte les demandes liées
:

-   au droit d'accès ;
-   au droit de rectification ;
-   au droit à l'effacement lorsque celui-ci est applicable ;
-   au droit à la limitation du traitement ;
-   au droit à la portabilité lorsque celui-ci est applicable ;
-   au droit d'opposition lorsque celui-ci est applicable.

L'implémentation applicative de ces droits sera réalisée dans les phases
concernant le backend.

Le modèle de données ne doit cependant pas empêcher leur exercice.

### 7.8 Durées de conservation

Les données ne doivent pas être conservées indéfiniment sans
justification.

Les durées doivent être définies dans le registre RGPD en fonction :

-   de la finalité du traitement ;
-   de la durée de la relation contractuelle ;
-   des éventuelles obligations légales ;
-   des besoins de preuve ou de gestion des litiges ;
-   des besoins analytiques légitimes après anonymisation lorsque cela
    est pertinent.

À l'expiration d'une durée de conservation, une donnée devra selon le
cas pouvoir être :

-   supprimée ;
-   anonymisée ;
-   archivée avec accès restreint lorsqu'une obligation justifie sa
    conservation.

### 7.9 Contrôle des accès

Les futures applications devront appliquer des droits adaptés aux rôles.

Un utilisateur ne devra pouvoir consulter ou modifier que les
informations nécessaires à ses fonctions.

Les données relatives notamment :

-   aux coordonnées personnelles ;
-   aux honoraires ;
-   aux commissions ;
-   aux paiements ;

doivent faire l'objet d'un contrôle d'accès renforcé.

### 7.10 Traçabilité

Les opérations sensibles devront pouvoir être journalisées, notamment :

-   création d'une donnée personnelle ;
-   modification significative ;
-   suppression ;
-   changement de statut important ;
-   modification d'une demande ;
-   création ou modification d'une commission ;
-   enregistrement d'un paiement.

Les journaux techniques eux-mêmes devront respecter les principes de
minimisation et de durée de conservation.

### 7.11 Sécurité des données

Les mesures techniques attendues comprennent notamment :

-   authentification ;
-   gestion des autorisations ;
-   moindre privilège ;
-   absence d'utilisation d'un compte administrateur par l'application ;
-   protection des communications réseau ;
-   protection des sauvegardes ;
-   séparation des environnements lorsque cela sera nécessaire ;
-   gestion sécurisée des secrets et identifiants de connexion ;
-   validation des données reçues par le futur backend.

### 7.12 Données et intelligence artificielle

Les futurs traitements IA ne doivent pas obtenir automatiquement un
accès complet à la base métier.

Avant exposition à une IA ou à un service externe, les données devront
faire l'objet d'une analyse portant notamment sur :

-   la nécessité des données ;
-   leur minimisation ;
-   leur anonymisation ou pseudonymisation ;
-   les droits d'accès ;
-   la souveraineté des données ;
-   la confidentialité ;
-   la possibilité de travailler en lecture seule ;
-   la traçabilité des traitements.

Ces décisions seront détaillées dans la phase consacrée à l'IA et dans
la note de souveraineté et sécurité des données.

------------------------------------------------------------------------

## 8. Accessibilité et prise en compte des PSH

L'accessibilité doit être intégrée au projet dès le cahier des charges,
même si la réalisation des interfaces utilisateur intervient
ultérieurement.

Le backend et le modèle de données ne doivent pas empêcher la création
d'interfaces accessibles.

Les principes suivants devront être pris en compte lors de la conception
applicative :

-   fournir des informations textuelles compréhensibles ;
-   produire des messages d'erreur explicites ;
-   ne pas imposer aux futures interfaces une information dépendant
    uniquement de la couleur ;
-   permettre aux interfaces de présenter correctement les libellés et
    statuts ;
-   éviter les structures ou formats rendant inutilement complexe
    l'utilisation d'outils d'assistance ;
-   permettre une navigation future entièrement réalisable au clavier
    côté interface ;
-   permettre l'utilisation de technologies d'assistance ;
-   prévoir des contrastes, libellés de champs et restitutions adaptés
    lors de la conception des maquettes.

L'évaluation détaillée de l'accessibilité de l'espace acquéreur et des
interfaces sera réalisée au moment de leur conception et de leur
recette.

------------------------------------------------------------------------

## 9. Éco-conception et numérique responsable

Le système doit limiter les traitements, stockages et transferts
inutiles.

Les principes retenus sont :

-   ne pas dupliquer inutilement les données ;
-   conserver les données uniquement lorsqu'une finalité le justifie ;
-   structurer les données afin d'éviter des traitements coûteux répétés
    ;
-   optimiser les requêtes importantes ;
-   éviter les sauvegardes complètes excessivement fréquentes
    lorsqu'elles ne sont pas justifiées ;
-   appliquer des politiques de rétention adaptées ;
-   distinguer les données fortement volatiles des référentiels peu
    modifiés.

La politique détaillée des sauvegardes et de leur rétention fera l'objet
de la note d'éco-conception demandée dans le projet.

Les fréquences ne devront pas être choisies arbitrairement : elles
devront être proportionnées à la criticité et au rythme réel de
modification des données.

------------------------------------------------------------------------

## 10. Reprise des données héritées

### 10.1 Principe

La reprise suit le processus :

``` text
EXTRAIRE → CONTRÔLER → TRANSFORMER → CHARGER → VÉRIFIER
```

Les fixtures officielles ne sont jamais modifiées pour masquer une
anomalie.

Trois schémas PostgreSQL sont utilisés :

``` text
"Fil_Rouge_Depart" → données historiques
fil_rouge_cible    → modèle final
reprise_controle   → hypothèses, rejets, corrections et données non reprises
```

`reprise_controle` est un schéma technique de preuve et ne fait pas
partie du modèle métier.

### 10.2 Données source

Les fixtures contiennent :

  Donnée             Volume
  ---------------- --------
  Secteurs               10
  Utilisateurs           24
  dont clients           18
  dont chasseurs          6
  Mandats                18

### 10.3 Règle de décision pendant la reprise

Une donnée est :

-   copiée lorsqu'un équivalent cible existe clairement ;
-   transformée lorsqu'une règle déterministe permet de le faire sans
    ambiguïté ;
-   rejetée et tracée lorsque la bonne valeur ne peut pas être
    déterminée ;
-   laissée non transformée lorsqu'aucune donnée source fiable ne permet
    de construire la donnée cible.

Cette règle évite les corrections arbitraires et les données métier
inventées.

### 10.4 Deux mandats rejetés

**Mandat 13 --- `R-CLIENT-ROLE`.**\
Le mandat référence `client_id=3`, mais l'utilisateur `3` est un
chasseur. Aucun élément source ne permet d'identifier avec certitude le
véritable client. Le mandat est donc rejeté.

**Mandat 9 --- `R-CHASSEUR-DATE`.**\
Le mandat débute le `02/10/2025`, alors que le chasseur `6` associé a
une date de création au `03/11/2025`. La source ne permet pas de savoir
quelle date est erronée. Aucune correction arbitraire n'est appliquée et
le mandat est rejeté.

Ainsi :

``` text
18 mandats source
= 16 mandats migrés
+ 2 mandats rejetés et tracés
```

### 10.5 Pourquoi cinq statuts sont corrigés alors que l'audit avait détecté six anomalies

L'audit de Phase 1 avait identifié **six mandats** (`4`, `7`, `9`, `10`,
`11`, `12`) encore marqués `actif` alors que leur durée de six mois
était dépassée au **25/07/2026**.

Le mandat `9` fait également l'objet de l'anomalie chronologique décrite
ci-dessus. Comme il est rejeté, il n'est pas corrigé puis migré.

Les cinq autres mandats sont cohérents sur leur identité et leurs
relations. Leur statut peut être déterminé grâce à la règle :

``` text
date_fin = date_signature + 6 mois
```

Les corrections réellement appliquées sont :

    Mandat Statut source   Statut cible   Fin calculée
  -------- --------------- -------------- --------------
         4 actif           expire         20/11/2025
         7 actif           expire         01/03/2026
        10 actif           expire         14/05/2026
        11 actif           expire         05/07/2026
        12 actif           expire         20/07/2026

Toutes sont tracées dans `reprise_controle.correction_mandat`.

### 10.6 Reconstruction du nouveau parcours

L'ancien système ne possède pas les structures `DEMANDE`, `AFFECTATION`
et `VERSION_DEMANDE`.

Pour chaque mandat historique valide, la reprise reconstruit le minimum
nécessaire :

``` text
1 mandat source valide
→ 1 demande historique
→ 1 affectation acceptée
→ 1 version initiale
→ 1 secteur associé
→ 1 mandat cible
```

Il s'agit d'une hypothèse de reprise documentée et non de la prétention
de recréer un historique absent de la source.

### 10.7 Barèmes de transition

L'ancien système contient un taux de commission courant par chasseur. Le
nouveau modèle permet plusieurs barèmes, plusieurs périodes et plusieurs
tranches.

La source ne permet pas de reconstituer l'historique réel de ces
barèmes.

Pour conserver la donnée connue sans inventer un faux historique, la
reprise crée à partir de la date de référence du `25/07/2026` :

``` text
6 chasseurs
→ 6 barèmes de transition
→ 6 tranches de transition
```

### 10.8 Tables volontairement laissées vides

Les fixtures ne contiennent pas de données fiables permettant de
reconstruire les biens, vendeurs, présentations, visites, avis, offres,
actes, notaires, honoraires, commissions calculées, factures ou
paiements.

Les tables correspondantes restent donc vides.

La règle est :

``` text
absence de donnée source fiable
→ aucune donnée métier inventée
```

### 10.9 Résultat réellement exécuté

  Contrôle                       Résultat
  ---------------------------- ----------
  SOURCE secteurs                      10
  SOURCE utilisateurs                  24
  SOURCE mandats                       18
  CIBLE secteur                        10
  CIBLE utilisateur                    24
  CIBLE client                         18
  CIBLE chasseur                        6
  CIBLE demande                        16
  CIBLE affectation                    16
  CIBLE version_demande                16
  CIBLE mandat                         16
  REPRISE rejets mandat                 2
  REPRISE corrections statut            5
  CIBLE bareme_commission               6
  CIBLE tranche_commission              6

L'exécution de `reprise-donnees-final.sql` s'est terminée par :

``` text
COMMIT
```

La preuve détaillée est conservée dans :

``` text
02-modele-cible/reprise-donnees-validation.md
```

------------------------------------------------------------------------

## 11. Livrables attendus

Pour la Phase 2, les livrables concernés comprennent :

-   note de cadrage ;
-   besoins métier ;
-   règles de gestion ;
-   modèle conceptuel de données cible ;
-   modèle logique de données cible ;
-   documentation du MLD ;
-   `migration-final.sql` ;
-   `reprise-donnees-final.sql` ;
-   `reprise-donnees-validation.md` ;
-   cahier des charges technique ;
-   étude d'opportunité ;
-   journal des décisions techniques.

Les livrables transverses liés au projet comprennent également :

-   registre RGPD ;
-   note d'éco-conception ;
-   documentation de l'accessibilité PSH ;
-   éléments de traçabilité des compétences.

Les livrables propres aux phases 3 et 4 seront réalisés uniquement au
moment prévu dans le projet.

------------------------------------------------------------------------

## 12. Planning et jalons

Le planning détaillé du projet est porté par les documents de pilotage
et la note de cadrage.

Les jalons fonctionnels sont organisés selon les quatre phases imposées
:

  -----------------------------------------------------------------------
  Phase                   Objet principal         Livrables principaux
  ----------------------- ----------------------- -----------------------
  Phase 1                 Audit de l'existant     Cartographie,
                                                  anomalies, risques,
                                                  analyse

  Phase 2                 Réponse au besoin       MCD/MLD, migration,
                          actuel                  reprise, CDCT, cadrage

  Phase 3                 Absorption de la        Architecture, OLAP, 3V,
                          croissance              PCA/PRA, migration

  Phase 4                 Backend et IA           Conception applicative,
                                                  API, tests, IA,
                                                  matching
  -----------------------------------------------------------------------

Le présent cahier des charges constitue un livrable de la Phase 2 et
pourra être précisé dans les phases suivantes sans remettre en cause les
choix déjà validés sauf décision documentée.

------------------------------------------------------------------------

## 13. Critères de recette et d'acceptation

### 13.1 Modèle de données

Le modèle est accepté si :

-   les entités définies dans le MCD sont correctement traduites dans le
    MLD ;
-   les clés primaires sont présentes ;
-   les clés étrangères structurantes sont présentes ;
-   les contraintes d'unicité nécessaires sont présentes ;
-   les principales règles d'intégrité sont représentées ;
-   l'historisation des demandes est possible ;
-   les commissions et paiements sont traçables.

### 13.2 Script de migration

`migration-final.sql` est accepté si :

-   il s'exécute sans erreur sous PostgreSQL ;
-   la transaction aboutit à un `COMMIT` ;
-   le schéma `fil_rouge_cible` est créé ;
-   les 26 tables du modèle final sont créées ;
-   une nouvelle exécution de développement reste possible selon la
    procédure prévue.

Le test réalisé a confirmé la création des 26 tables attendues.

### 13.3 Script de reprise

`reprise-donnees-final.sql` est accepté si :

-   la reprise s'exécute dans une transaction ;
-   les données sources ne sont pas modifiées ;
-   les contrôles de cohérence réussissent ;
-   les données valides sont chargées ;
-   les anomalies non déterministes sont tracées ;
-   les comptages source et cible restent explicables.

Le contrôle réalisé a confirmé :

``` text
18 mandats source
= 16 mandats migrés
+ 2 mandats rejetés

6 mandats source étaient encore actifs après leur durée théorique de six mois
= 5 corrections actif → expire appliquées aux mandats migrés
+ le mandat 9 rejeté pour l'anomalie chronologique A-03
```

La transaction de reprise s'est terminée par `COMMIT`. La preuve détaillée est conservée dans `reprise-donnees-validation.md`.

### 13.4 Historisation

Le modèle est accepté si :

-   une demande peut posséder plusieurs versions ;
-   le numéro de version est unique dans une même demande ;
-   les anciennes versions restent conservées ;
-   chaque version conserve son auteur et sa date ;
-   plusieurs secteurs peuvent être associés à une version.

### 13.5 Commissions

Le modèle est accepté si :

-   un chasseur peut posséder un barème ;
-   un barème peut posséder plusieurs tranches ;
-   les barèmes peuvent être versionnés dans le temps par leurs dates de
    validité ;
-   la commission calculée conserve le barème logique utilisé via sa
    tranche ;
-   une commission peut donner lieu à une facture chasseur ;
-   une facture chasseur peut faire l'objet de plusieurs paiements.

### 13.6 RGPD

Le volet RGPD est accepté si :

-   les données personnelles ont été identifiées ;
-   les traitements sont documentés dans un registre ;
-   une finalité est associée à chaque traitement ;
-   une base légale est documentée ;
-   une durée de conservation est définie ;
-   les accès sont limités selon les besoins ;
-   les principes de minimisation et privacy by design sont pris en
    compte ;
-   les futurs usages IA font l'objet d'une analyse spécifique de
    confidentialité.

### 13.7 Accessibilité PSH

Le volet accessibilité est accepté si :

-   l'accessibilité est explicitement présente dans les exigences ;
-   les futures interfaces sont identifiées comme devant respecter les
    exigences d'accessibilité applicables ;
-   les contrats d'API ne rendent pas l'information dépendante
    exclusivement d'éléments visuels ;
-   l'accessibilité fait l'objet d'une vérification lors de la
    conception et de la recette des interfaces.

### 13.8 Traçabilité

Toute décision structurante doit pouvoir être reliée :

-   à un besoin ;
-   à une règle de gestion ;
-   à un choix de conception ;
-   à une décision documentée lorsque nécessaire ;
-   à un test ou critère de vérification.

------------------------------------------------------------------------

## 14. Principe de traçabilité documentaire

Une décision structurante ne doit pas être présentée sans son contexte.

Pour chaque choix important, la documentation doit permettre de
comprendre :

``` text
constat initial
→ besoin ou risque
→ règle métier concernée
→ décision prise
→ justification
→ conséquence technique
→ preuve ou contrôle
```

Exemple : il ne suffit pas d'écrire « cinq statuts ont été corrigés ».
Il faut préciser que six mandats actifs dépassaient leur durée théorique
de six mois, que le mandat `9` faisait également l'objet d'une anomalie
chronologique empêchant sa migration, et que les cinq autres pouvaient
être corrigés de façon certaine grâce à la règle métier des six mois.

Ce principe s'applique aux choix de modélisation, de migration, de
sécurité et d'architecture.

------------------------------------------------------------------------

## 15. Références et annexes

Le présent cahier des charges doit être lu conjointement avec :

-   `note-cadrage.md` ;
-   `besoins-metier-final.md` ;
-   le MCD cible validé ;
-   `mld-cible-final.md` ;
-   `migration-final.sql` ;
-   `reprise-donnees-final.sql` ;
-   `reprise-donnees-validation.md` ;
-   le journal de décisions ;
-   le registre RGPD ;
-   la note d'éco-conception ;
-   le plan de tests ;
-   la matrice de traçabilité des compétences ;
-   le glossaire métier.

------------------------------------------------------------------------

## 16. Synthèse

La solution cible de Phase 2 repose sur un modèle transactionnel
PostgreSQL normalisé et structuré autour du cycle métier complet :

`client → demande → versions → affectation → mandat → présentations/visites/avis → offre → acte authentique → honoraires → commission → facture chasseur → paiement`

Elle corrige les principales limites structurelles de l'ancien système
tout en conservant une reprise de données traçable.

Le modèle :

-   répond au besoin métier actuel ;
-   structure les informations nécessaires aux futurs traitements
    analytiques et IA ;
-   protège l'intégrité des relations ;
-   historise les évolutions importantes ;
-   sépare clairement les dimensions financières ;
-   intègre la protection des données dès la conception ;
-   prend en compte l'accessibilité PSH ;
-   prépare les futures évolutions sans imposer prématurément
    l'architecture de croissance de la Phase 3.
