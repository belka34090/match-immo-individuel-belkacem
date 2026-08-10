# Analyse de l'existant

## 1. Périmètre de l'audit

L'audit porte sur la base de données héritée fournie dans les fixtures du projet.

Deux scripts sont disponibles :

- `sources/fixtures/MySQL.sql`
- `sources/fixtures/PgSQL.sql`

Ils représentent le même jeu de données, adapté respectivement à MariaDB/MySQL et PostgreSQL.

Ces fichiers constituent l'existant du système d'information et ne sont pas modifiés pendant l'audit.

La date de référence métier du projet est le **25 juillet 2026**.

---

## 2. Structure de la base héritée

La base existante contient uniquement trois tables :

- `secteurs`
- `utilisateurs`
- `mandats`

Cette structure limitée est volontaire : les autres objets métier décrits dans le parcours de l'entreprise, comme les biens, visites, offres, paiements ou barèmes de commission, ne sont pas représentés dans l'existant.

### Table `secteurs`

La table `secteurs` contient les zones géographiques utilisées par les mandats.

Principales colonnes :

- `id`
- `ville`
- `quartier`
- `code_postal`

Un secteur peut être associé à plusieurs mandats.

### Table `utilisateurs`

La table `utilisateurs` regroupe deux catégories de personnes :

- les clients ;
- les chasseurs.

Le champ `role` permet de les distinguer.

Principales colonnes :

- `id`
- `role`
- `nom`
- `prenom`
- `email`
- `telephone`
- `ville`
- `taux_commission`
- `budget_max`
- `date_creation`

Certaines colonnes ne concernent qu'un seul rôle :

- `taux_commission` concerne les chasseurs ;
- `budget_max` concerne les clients.

La table contient donc des valeurs `NULL` dues directement à cette organisation.

### Table `mandats`

La table `mandats` représente les mandats de recherche confiés aux chasseurs.

Principales colonnes :

- `id`
- `client_id`
- `chasseur_id`
- `secteur_id`
- `exclusif`
- `date_debut`
- `statut`
- `description_recherche`

Les relations principales sont :

- `mandats.client_id` → `utilisateurs.id`
- `mandats.chasseur_id` → `utilisateurs.id`
- `mandats.secteur_id` → `secteurs.id`

---

## 3. Contraintes présentes dans le schéma

Le schéma comporte plusieurs mécanismes assurant un premier niveau d'intégrité :

- clés primaires pour identifier les lignes ;
- contraintes `NOT NULL` sur certaines colonnes obligatoires ;
- contrainte `UNIQUE` sur l'adresse email ;
- clés étrangères entre les mandats, utilisateurs et secteurs ;
- valeurs autorisées limitées pour les rôles et statuts ;
- valeurs par défaut pour certains champs.

Ces contraintes garantissent principalement l'intégrité technique des références.

Par exemple, une clé étrangère garantit que l'identifiant d'un utilisateur utilisé dans un mandat existe réellement dans la table `utilisateurs`.

En revanche, elle ne garantit pas que cet utilisateur possède le bon rôle métier.

Ainsi :

- `client_id` peut techniquement référencer un utilisateur ayant le rôle `chasseur` ;
- `chasseur_id` peut techniquement référencer un utilisateur ayant le rôle `client`.

Cette limite constitue un point important à vérifier pendant l'audit.

---

## 4. Observations signalées dans les fixtures

Les scripts contiennent plusieurs commentaires préfixés par `-- [consultant]`.

Ces remarques ne sont pas considérées automatiquement comme des anomalies confirmées. Elles constituent des pistes d'audit qui doivent être vérifiées.

Les principaux points signalés sont les suivants :

- clients et chasseurs regroupés dans une seule table ;
- colonnes spécifiques à certains rôles entraînant des valeurs `NULL` ;
- absence de contrôle suffisant sur certaines données ;
- absence de `date_fin` dans les mandats ;
- absence de mode de signature ;
- critères de recherche stockés dans un champ texte libre ;
- absence de garantie sur le rôle des utilisateurs référencés par les mandats ;
- présence possible d'une incohérence métier concernant un `client_id` ;
- présence possible de mandats encore marqués `actif` alors que leur durée de six mois serait dépassée.

Ces éléments doivent être vérifiés selon leur nature : par l'analyse du schéma pour les risques structurels et par des requêtes SQL pour les incohérences présentes dans les données.

---

## 5. Premiers constats sur le modèle existant

La base actuelle permet de représenter une partie minimale du fonctionnement de l'entreprise :

- les utilisateurs ;
- les secteurs ;
- les mandats de recherche.

Cependant, plusieurs informations décrites dans le besoin métier ne sont pas représentées ou sont difficilement exploitables.

### Gestion des rôles

Les clients et chasseurs sont regroupés dans une même table.

Cette organisation simplifie le nombre de tables mais rend plus difficile la garantie des règles métier liées aux rôles.

La base sait vérifier qu'un utilisateur existe, mais elle ne sait pas vérifier automatiquement qu'il est utilisé dans le bon rôle dans un mandat.

### Durée des mandats

Le besoin métier précise qu'un mandat est valable six mois et peut être renouvelé.

Le schéma contient une `date_debut`, mais aucune `date_fin`.

La cohérence entre la durée réelle du mandat et son statut dépend donc d'un traitement extérieur ou d'une vérification manuelle.

### Critères de recherche

Les critères du client sont stockés dans `description_recherche`, sous forme de texte libre.

Cette organisation est lisible par un humain mais peu adaptée aux traitements structurés.

Elle rend plus difficile :

- le filtrage ;
- la comparaison des demandes ;
- l'analyse statistique ;
- l'exploitation future par des traitements automatisés.

### Couverture fonctionnelle

Le modèle existant ne couvre qu'une petite partie du parcours métier décrit dans le sujet.

Il ne contient notamment pas de structures dédiées pour :

- les biens ;
- les visites ;
- les offres ;
- les actes authentiques ;
- les honoraires ;
- les paiements ;
- les barèmes de commission ;
- l'historique des évolutions d'une demande.

Cette absence n'est pas considérée ici comme une erreur de données : elle montre surtout que le modèle existant ne couvre pas l'ensemble des besoins métier décrits.

---

## 6. Validation de l'import

La fixture PostgreSQL a été exécutée avec succès dans un environnement local Docker.

Les contrôles confirment les volumes attendus :

| Table | Nombre |
| --- | ---: |
| `secteurs` | 10 |
| `utilisateurs` | 24 |
| `mandats` | 18 |

Les preuves détaillées sont disponibles dans :

- `preuves/01-import/import-postgresql.md`
- `preuves/02-controles/comptages-initiaux.md`

L'import est donc validé pour poursuivre l'audit.

---

## 7. Conclusion de l'audit

L'audit de l'existant confirme que la base héritée repose sur une structure simple composée de trois tables principales : `secteurs`, `utilisateurs` et `mandats`.

Les contrôles réalisés ont permis de valider l'import des données et les volumes attendus.

L'audit a également confirmé plusieurs anomalies de données :

- une incohérence de rôle a été détectée sur le mandat `13` : un utilisateur ayant le rôle `chasseur` est référencé comme client ;
- six mandats sont encore marqués `actif` alors que leur durée théorique de six mois est dépassée au 25/07/2026 ;
- une incohérence temporelle a été détectée sur le mandat `9` : sa date de début est antérieure à la date de création du chasseur associé.

Plusieurs risques structurels ont également été identifiés :

- les rôles métier ne sont pas suffisamment garantis par les relations existantes ;
- les clients et chasseurs sont regroupés dans une même table ;
- le modèle ne permet pas de représenter explicitement la date de fin, le mode de signature ou le renouvellement d'un mandat ;
- les critères de recherche sont principalement stockés sous forme de texte libre ;
- certaines contraintes de qualité et de cohérence métier ne sont pas garanties par le schéma ;
- la couverture fonctionnelle reste limitée par rapport au besoin métier décrit.

Les anomalies de données et les risques structurels identifiés sont documentés séparément dans le registre des anomalies et risques, et appuyés par les preuves conservées dans le dossier `preuves/`.

La cartographie de l'existant et la synthèse SWOT complètent cette analyse et permettent de disposer d'une vision structurée de la situation initiale avant la définition du modèle cible.
