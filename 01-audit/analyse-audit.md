# Analyse de l’existant

## 1. Objectif de l’audit

Avant de concevoir une nouvelle solution, il est nécessaire de comprendre le système actuellement utilisé par l’entreprise.

L’audit a pour objectifs de :

- comprendre le fonctionnement général du système d’information existant ;
- examiner la structure de la base de données historique ;
- vérifier que les données fournies peuvent être exploitées ;
- rechercher les anomalies présentes dans ces données ;
- identifier les limites du modèle actuel ;
- disposer d’un état de référence avant la conception de la solution cible.

La date de référence métier utilisée pour les contrôles est le **25 juillet 2026**.

---

## 2. Sources utilisées

L’analyse repose sur :

- l’énoncé et les besoins métier fournis avec le projet ;
- les fixtures MySQL et PostgreSQL du Starter Pack ;
- les contrôles réalisés sur les données après leur import.

Une **fixture** est ici un fichier SQL contenant la structure et les données historiques fournies comme point de départ du projet.

Les versions MySQL et PostgreSQL représentent le même système historique, adaptées à deux systèmes de gestion de base de données différents.

Ces données constituent l’existant à auditer. Elles ne sont donc pas corrigées directement pendant cette phase.

Les anomalies sont d’abord identifiées et documentées. Leur traitement éventuel intervient lors de la reprise des données vers la solution cible.

---

## 3. Acteurs et système d’information existant

Trois acteurs principaux interviennent dans l’activité :

- le particulier, qui recherche un bien immobilier ;
- le chasseur immobilier, qui accompagne le particulier ;
- l’entreprise, qui organise et supervise l’activité.

Le système d’information existant comprend notamment :

- un site web utilisé par les particuliers ;
- un logiciel métier utilisé par l’entreprise et les chasseurs ;
- un backend exposant une API ;
- une base de données historique ;
- des dossiers papier dont l’utilisation précise reste à déterminer.

Le **backend** correspond à la partie du système qui réalise les traitements nécessaires aux applications et communique notamment avec la base de données.

Une **API** est un moyen standardisé permettant à plusieurs applications de communiquer.

Le site web et le logiciel métier existants doivent pouvoir être conservés. En revanche, le code source du backend existant est considéré comme inexploitable dans le contexte du projet. Son remplacement devra donc être étudié dans la conception de la solution cible.

La vue générale de cet environnement est représentée dans :

`mermaid_carto_existante_SI.png`

---

## 4. Structure de la base de données historique

La base historique est relativement simple. Elle contient trois tables principales :

- `utilisateurs` ;
- `secteurs` ;
- `mandats`.

Le schéma correspondant est disponible dans :

`mermaid_bdd_existante.png`

### 4.1 Table `utilisateurs`

Cette table regroupe deux catégories de personnes :

- les clients ;
- les chasseurs immobiliers.

Le champ `role` permet de les distinguer.

Les principales informations enregistrées sont :

- l’identité ;
- l’adresse email ;
- le téléphone ;
- la ville ;
- la date de création du compte.

Deux informations dépendent directement du rôle :

- `budget_max` concerne les clients ;
- `taux_commission` concerne les chasseurs.

Cette organisation permet de regrouper les informations communes dans une seule table, mais elle présente également une limite : des informations propres à deux métiers différents sont stockées au même endroit.

Cela rend certaines règles métier plus difficiles à garantir directement dans la base.

### 4.2 Table `secteurs`

Cette table représente les zones géographiques utilisées pour les recherches immobilières.

Elle contient notamment :

- la ville ;
- le quartier ;
- le code postal.

Un secteur peut être associé à plusieurs mandats.

### 4.3 Table `mandats`

Cette table représente les mandats de recherche confiés aux chasseurs.

Elle contient notamment :

- `client_id` ;
- `chasseur_id` ;
- `secteur_id` ;
- `exclusif` ;
- `date_debut` ;
- `statut` ;
- `description_recherche`.

Les colonnes se terminant par `_id` permettent ici de relier un mandat à d’autres données.

Par exemple :

- `client_id` référence un utilisateur ;
- `chasseur_id` référence également un utilisateur ;
- `secteur_id` référence un secteur.

`secteur_id` peut être absent dans le modèle historique.

---

## 5. Contraintes déjà présentes

La base historique ne présente pas uniquement des défauts. Elle contient déjà plusieurs mécanismes permettant de protéger les données.

On trouve notamment :

- des clés primaires ;
- des clés étrangères ;
- des contraintes `NOT NULL` sur certaines données obligatoires ;
- une contrainte d’unicité sur l’adresse email ;
- des valeurs autorisées pour certains rôles et statuts.

Une **clé primaire** identifie de manière unique une ligne d’une table.

Une **clé étrangère** permet de créer une relation avec une ligne d’une autre table.

Par exemple, la base peut vérifier qu’un identifiant présent dans `client_id` correspond bien à un utilisateur existant.

Cependant, cette vérification technique ne suffit pas à garantir la règle métier.

La base peut vérifier :

> « Cet utilisateur existe-t-il ? »

mais elle ne garantit pas nécessairement :

> « Cet utilisateur est-il réellement un client ? »

Cette différence entre **intégrité technique** et **cohérence métier** constitue l’un des points importants de l’audit.

---

## 6. Méthode de vérification

Les fichiers SQL fournis contiennent certaines remarques du consultant sur des problèmes potentiels.

Ces remarques ont été utilisées comme pistes de contrôle, mais elles n’ont pas été considérées automatiquement comme des anomalies confirmées.

Le principe appliqué est le suivant :

**une remarque signale quelque chose à vérifier ; une anomalie n’est confirmée qu’après contrôle des données.**

Pour rendre cette vérification reproductible, des requêtes SQL ont été exécutées sur la base historique.

Une **requête SQL** est une instruction permettant d’interroger une base de données.

Les requêtes utilisées sont conservées dans :

`preuves/03-anomalies/requetes-audit.sql`

Les résultats obtenus sont conservés dans :

`preuves/03-anomalies/resultats-anomalies.md`

Ainsi, une autre personne peut refaire les contrôles et comparer les résultats.

---

## 7. Validation de l’import et des volumes

Avant d’analyser les anomalies, il fallait vérifier que la base historique avait été correctement chargée.

La fixture PostgreSQL a donc été importée dans un environnement local.

L’import a réussi sans erreur bloquante.

Les contrôles ont ensuite confirmé les principaux volumes :

| Élément | Nombre |
| --- | ---: |
| Secteurs | 10 |
| Utilisateurs | 24 |
| Clients | 18 |
| Chasseurs | 6 |
| Mandats | 18 |
| Mandats actifs | 11 |

Les preuves correspondantes sont conservées dans :

- `preuves/01-import/import-postgresql.md` ;
- `preuves/02-controles/comptages-initiaux.md`.

Cette étape est importante : rechercher des anomalies dans une base mal importée aurait pu produire des conclusions incorrectes.

---

## 8. Anomalies de données confirmées

Les contrôles ont permis de confirmer trois catégories d’anomalies.

### A-01 — Rôle incorrect dans un mandat

Le mandat `13` référence l’utilisateur `3` comme client alors que cet utilisateur possède le rôle `chasseur`.

Le problème n’est donc pas l’absence de l’utilisateur : il existe bien dans la base.

Le problème est son **rôle métier**.

Cette anomalie démontre concrètement la limite identifiée précédemment : une relation peut être techniquement valide tout en étant incorrecte du point de vue métier.

### A-02 — Mandats toujours actifs après six mois

Au **25 juillet 2026**, six mandats sont encore enregistrés avec le statut `actif` alors que leur durée théorique de six mois est dépassée :

- mandat `4` ;
- mandat `7` ;
- mandat `9` ;
- mandat `10` ;
- mandat `11` ;
- mandat `12`.

Un renouvellement pourrait éventuellement expliquer certains cas.

Cependant, la base historique ne contient pas les informations nécessaires pour démontrer l’existence de ces renouvellements.

Ces six cas sont donc signalés afin d’éviter de considérer automatiquement leur statut comme fiable.

### A-03 — Incohérence chronologique

Le mandat `9` commence le **2 octobre 2025** alors que le compte du chasseur associé a été créé le **3 novembre 2025**.

Selon les données disponibles, le mandat existe donc avant la création du compte du chasseur auquel il est associé.

Cette incohérence doit être traitée avec prudence lors de la reprise des données.

Le détail de ces anomalies et les actions proposées sont présentés dans :

`registre-anomalies.md`

Les résultats techniques permettant de les vérifier sont conservés dans :

`preuves/03-anomalies/resultats-anomalies.md`

---

## 9. Risques structurels identifiés

L’audit ne recherche pas uniquement les données actuellement incorrectes.

Il identifie également les caractéristiques du système susceptibles de provoquer des difficultés futures.

### 9.1 Gestion des clients et des chasseurs

Clients et chasseurs sont regroupés dans `utilisateurs`.

Cette organisation rend plus difficile l’application de règles différentes selon le rôle et a notamment permis l’incohérence observée sur le mandat `13`.

### 9.2 Cycle de vie des mandats

La base historique ne représente pas suffisamment certaines informations nécessaires au suivi complet d’un mandat, notamment sa fin, son mode de signature et son éventuel renouvellement.

Cela rend difficile la détermination automatique de sa validité réelle.

### 9.3 Critères de recherche en texte libre

Les critères immobiliers sont principalement enregistrés dans `description_recherche`.

Un texte libre est facile à lire pour une personne, mais beaucoup plus difficile à exploiter automatiquement.

Cela complique notamment :

- les recherches ;
- les comparaisons ;
- les statistiques ;
- les futurs traitements automatisés.

### 9.4 Historisation insuffisante

Le modèle historique ne permet pas de retracer correctement les différentes évolutions des critères d’une recherche.

Or un particulier peut modifier sa demande au cours du temps.

Sans historique, il devient difficile de savoir :

- ce qui a changé ;
- quand le changement a eu lieu ;
- quelle version était utilisée à un moment donné.

### 9.5 Couverture métier limitée

La base historique ne représente qu’une partie du parcours métier.

Elle ne possède pas de structures dédiées permettant de suivre complètement des éléments tels que :

- les demandes et leurs évolutions ;
- les biens proposés ;
- les visites ;
- les commentaires et avis ;
- les offres ;
- les ventes ;
- les honoraires ;
- les commissions ;
- les paiements.

Cette situation n’est pas une anomalie de donnée.

Il s’agit d’une **limite fonctionnelle** : le modèle existant ne couvre pas l’ensemble du fonctionnement décrit dans le besoin métier.

### 9.6 Autres risques de qualité

D’autres risques ont été identifiés concernant notamment :

- le contrôle de certains formats ;
- certaines valeurs métier ;
- l’unicité de certaines informations géographiques ;
- le caractère facultatif du secteur d’un mandat.

Ces risques sont détaillés et priorisés dans `registre-anomalies.md`.

---

## 10. Ce que l’audit implique pour la suite

L’objectif de cette phase n’est pas encore de concevoir la nouvelle base.

L’audit permet d’abord de déterminer ce que la future solution devra améliorer.

Les principaux besoins qui en découlent sont notamment :

- mieux distinguer les rôles métier ;
- fiabiliser les relations entre les données ;
- mieux gérer le cycle de vie des mandats ;
- structurer les critères de recherche ;
- historiser les évolutions importantes ;
- couvrir davantage le parcours métier ;
- préparer une reprise contrôlée des données historiques.

Ces constats servent d’entrée à la Phase 2 consacrée à la conception de la solution cible.

---

## 11. Conclusion

L’audit montre que le système existant permet déjà de gérer un premier niveau d’activité autour des utilisateurs, des secteurs et des mandats.

La base possède également plusieurs mécanismes d’intégrité technique utiles.

Cependant, les contrôles ont confirmé des anomalies de données et plusieurs limites structurelles.

Trois catégories d’anomalies ont notamment été confirmées :

- un utilisateur de rôle `chasseur` utilisé comme client sur le mandat `13` ;
- six mandats encore actifs alors que leur durée théorique de six mois est dépassée au 25 juillet 2026 ;
- le mandat `9` dont la date de début précède la création du compte du chasseur associé.

Ces résultats ne sont pas seulement déclaratifs : les requêtes exécutées et leurs résultats sont conservés dans le dossier `preuves/`.

Le contrôle final de la Phase 1 est documenté dans :

`preuves/04-validation-finale/validation-phase1.md`

L’ensemble constitue l’état de référence utilisé avant la conception et la migration vers le modèle cible.
