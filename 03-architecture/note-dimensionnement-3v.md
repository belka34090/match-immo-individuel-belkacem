# Note de dimensionnement 3V — Match-Immo

## Phase 3 — Absorber la croissance

## 1. Objectif de cette note

Cette note a pour objectif d'évaluer la croissance future du système d'information Match-Immo avant de choisir les solutions techniques permettant de l'absorber.

L'analyse repose sur les **3V** :

- **Volume** : quantité de données que le système doit stocker et traiter ;
- **Vélocité** : vitesse à laquelle les données arrivent, évoluent et doivent être traitées ;
- **Variété** : diversité des formats, contenus et sources de données.

L'objectif n'est pas de choisir une technologie à l'avance.

La démarche retenue est :

```text
Besoin métier
→ estimation de la croissance
→ expérimentation
→ mesures
→ choix technique justifié
```

Ainsi, des solutions comme l'indexation, le partitionnement, la réplication ou le sharding ne seront retenues que si le besoin ou les mesures les justifient.

---

## 2. Point de départ fourni par le Starter Pack

Le Starter Pack prévoit une croissance importante de l'activité de Match-Immo.

Il indique notamment :

- **plusieurs milliers de mandats par semaine** ;
- **plusieurs centaines, voire plusieurs milliers de biens répertoriés par recherche** ;
- des sélections de biens réalisées **chaque jour**, voire **plusieurs fois par jour dans les zones tendues** ;
- une extension progressive de l'activité à la France entière puis à plusieurs pays européens.

Ces éléments constituent les données de départ officielles utilisées pour notre analyse.

Le Starter Pack ne fournit cependant pas un nombre exact de mandats par semaine à utiliser pour effectuer les tests.

Il est donc nécessaire de définir une hypothèse de dimensionnement.

---

## 3. Hypothèse de dimensionnement retenue

Pour disposer d'un scénario simple, compréhensible et reproductible, nous retenons comme scénario de référence :

- **5 000 nouveaux mandats par semaine** ;
- jusqu'à **1 000 biens analysés par recherche**.

Ces deux valeurs doivent être distinguées des données officielles du Starter Pack.

Le Starter Pack parle de plusieurs milliers de mandats par semaine et de plusieurs centaines à plusieurs milliers de biens par recherche.

Les valeurs **5 000** et **1 000** sont donc des **hypothèses de dimensionnement** choisies à l'intérieur de ces ordres de grandeur.

Une hypothèse de dimensionnement est une valeur de travail utilisée pour estimer la taille future du système et construire des tests reproductibles.

Elle ne signifie pas que l'entreprise possède réellement aujourd'hui 5 000 nouveaux mandats chaque semaine.

---

## 4. Première projection du volume

### 4.1 Nombre de mandats

Avec une hypothèse de 5 000 nouveaux mandats par semaine :

```text
5 000 × 52 semaines
= 260 000 mandats par an
```

Le système pourrait donc avoir à gérer environ :

**260 000 nouveaux mandats par an.**

### 4.2 Nombre de biens étudiés

Si une recherche peut examiner jusqu'à 1 000 biens :

```text
5 000 recherches × 1 000 biens
= 5 000 000 de rapprochements recherche/bien par semaine
```

Sur une année :

```text
260 000 recherches × 1 000 biens
= 260 000 000 de rapprochements recherche/bien par an
```

Il est important de comprendre que cela ne signifie pas qu'il existe nécessairement **260 millions de biens immobiliers différents**.

Un même bien immobilier peut correspondre à plusieurs recherches.

Par exemple :

```text
Bien A
├── correspond à la recherche du client 1
├── correspond à la recherche du client 2
└── correspond à la recherche du client 3
```

Le bien n'existe qu'une seule fois dans le catalogue, mais il produit trois rapprochements avec des recherches différentes.

C'est donc notamment la relation entre les recherches et les biens qui peut devenir très volumineuse.

---

## 5. V1 — Volume

Le premier V signifie **Volume**.

Le Volume correspond à la quantité de données que Match-Immo devra conserver et traiter.

Dans le système cible, plusieurs catégories de données vont progressivement augmenter :

- utilisateurs ;
- clients ;
- chasseurs ;
- demandes ;
- versions des demandes ;
- mandats ;
- biens immobiliers ;
- propositions de biens ;
- visites ;
- commentaires ;
- offres d'achat ;
- ventes ;
- paiements ;
- données d'audit et d'historisation.

Cependant, toutes les tables ne vont pas croître à la même vitesse.

Un client peut avoir un nombre limité de demandes et de mandats.

En revanche, une recherche immobilière peut être confrontée à plusieurs centaines ou plusieurs milliers de biens.

La volumétrie la plus importante peut donc provenir des données permettant d'associer les recherches aux biens correspondants.

### Ordre de grandeur retenu

| Élément | Hypothèse |
|---|---:|
| Nouveaux mandats par semaine | 5 000 |
| Nouveaux mandats par an | 260 000 |
| Biens analysés par recherche | jusqu'à 1 000 |
| Rapprochements recherche/bien par semaine | jusqu'à 5 000 000 |
| Rapprochements recherche/bien par an | jusqu'à 260 000 000 |

Ces chiffres constituent un **scénario de dimensionnement**, et non une mesure de l'activité actuelle.

Ils devront être confrontés à des expérimentations techniques.

---

## 6. V2 — Vélocité

Le deuxième V signifie **Vélocité**.

La Vélocité représente la vitesse à laquelle les données arrivent, sont modifiées et doivent être traitées.

Dans Match-Immo, le problème ne consiste donc pas uniquement à stocker beaucoup de données.

Les données immobilières évoluent également rapidement.

Le Starter Pack prévoit que le chasseur puisse recevoir une sélection de biens :

- chaque jour ;
- voire plusieurs fois par jour dans les zones immobilières tendues.

Cela implique que le système devra régulièrement :

1. recevoir de nouvelles annonces ;
2. détecter les modifications d'annonces existantes ;
3. traiter les annonces devenues indisponibles ;
4. comparer les biens aux critères des recherches ;
5. présenter les résultats pertinents aux chasseurs ;
6. enregistrer les interactions des utilisateurs.

### Exemple simple

Supposons qu'une plateforme fournisse régulièrement de nouvelles annonces.

Le système devra suivre une chaîne proche de :

```text
Nouvelle annonce
      ↓
Réception
      ↓
Contrôle des données
      ↓
Enregistrement
      ↓
Recherche des clients potentiellement intéressés
      ↓
Proposition au chasseur
```

Plus le nombre d'annonces et de clients augmente, plus cette chaîne doit être capable de fonctionner rapidement.

La Vélocité devra donc être prise en compte dans les futurs tests de performance.

---

## 7. V3 — Variété

Le troisième V signifie **Variété**.

La Variété représente les différentes formes que peuvent prendre les données.

Match-Immo ne manipulera pas uniquement des nombres et du texte parfaitement organisés dans des tables SQL.

Les données peuvent provenir de plusieurs sources immobilières et présenter des structures différentes.

Le projet devra notamment gérer plusieurs catégories de données.

### 7.1 Données structurées

Ce sont des données organisées selon un modèle précis.

Exemples :

- clients ;
- chasseurs ;
- mandats ;
- prix ;
- surfaces ;
- ventes ;
- paiements.

Ces données sont particulièrement adaptées à une base relationnelle comme PostgreSQL.

### 7.2 Données semi-structurées

Certaines données possèdent une structure, mais celle-ci peut varier selon leur source.

Exemple :

```json
{
  "prix": 280000,
  "surface": 75,
  "balcon": true
}
```

Une autre source pourrait fournir :

```json
{
  "prix_bien": "280000 €",
  "surface_m2": 75
}
```

Les deux annonces décrivent potentiellement le même type d'information, mais pas exactement sous la même forme.

Le générateur fourni avec le Starter Pack simule volontairement ce genre de situation.

### 7.3 Données géographiques

Match-Immo doit également travailler avec la localisation des biens :

- ville ;
- code postal ;
- secteur ;
- latitude ;
- longitude.

Ces informations permettront notamment d'effectuer des recherches géographiques.

### 7.4 Données textuelles

Le système peut contenir :

- descriptions d'annonces ;
- commentaires des clients ;
- avis des chasseurs ;
- critères libres de recherche.

### 7.5 Données multimédias

Le besoin métier prévoit également à terme :

- images ;
- documents ;
- fichiers audio ;
- vidéos.

Ces fichiers ne nécessitent pas forcément d'être stockés directement dans PostgreSQL.

Une architecture adaptée pourra conserver les fichiers dans un stockage spécialisé et uniquement leur référence dans la base.

Ce choix sera étudié dans le dossier d'architecture.

### 7.6 Données destinées à l'IA

La future phase IA pourra également produire des représentations numériques permettant de comparer une recherche et un bien.

Ces représentations sont généralement appelées **vecteurs** ou **embeddings**.

Un **embedding** est une représentation numérique permettant à un système d'IA de comparer la proximité entre deux contenus.

Cette problématique sera étudiée dans la phase dédiée à l'IA et ne constitue pas encore un choix technique de cette note.

---

## 8. Générateur de données fourni par le Starter Pack

Le Starter Pack fournit le script :

```text
outils/generer_annonces.py
```

Ce programme Python permet de générer :

- des critères de recherche immobilière ;
- des annonces correspondant à ces recherches.

Il est particulièrement intéressant pour l'analyse des 3V car les données générées sont volontairement hétérogènes.

Le générateur peut notamment produire :

- des champs absents ;
- des champs portant des noms différents ;
- plusieurs formats de dates ;
- des coordonnées géographiques parfois absentes ;
- différentes informations de contact ;
- des annonces provenant de profils de sources différents.

Il permet donc de tester non seulement le **Volume**, mais également une partie de la **Variété**.

Le nombre de recherches et le nombre d'annonces générées peuvent être configurés.

Cela permettra d'augmenter progressivement la charge sans modifier les fixtures de référence du projet.

---

## 9. Stratégie expérimentale

Les calculs précédents constituent des projections.

Ils ne suffisent pas à démontrer qu'une architecture particulière est nécessaire.

Le projet prévoit donc de compléter l'analyse théorique par des mesures réelles.

Les tests seront réalisés progressivement afin d'éviter de tirer des conclusions à partir d'un seul volume.

Exemple de progression :

| Niveau | Ordre de grandeur | Objectif |
|---|---:|---|
| Test initial | 10 000 annonces | Vérifier la chaîne de génération et de chargement |
| Test intermédiaire | 100 000 annonces | Commencer à observer les performances |
| Test volumineux | 1 000 000 annonces | Mesurer PostgreSQL sur une volumétrie significative |
| Test spécialisé | plusieurs millions de relations | Étudier les tables à très forte croissance |

Les volumes exacts seront ajustés selon les résultats obtenus.

---

## 10. Mesures prévues

Pour chaque expérimentation pertinente, plusieurs mesures pourront être conservées :

- nombre de lignes ;
- taille des tables ;
- taille des index ;
- durée de chargement ;
- durée des requêtes ;
- plan d'exécution PostgreSQL ;
- nombre de blocs de données consultés ;
- consommation de ressources lorsque cela apporte une information utile.

Un **plan d'exécution** indique comment PostgreSQL décide d'effectuer une requête.

La commande :

```sql
EXPLAIN (ANALYZE, BUFFERS)
```

permet notamment d'observer :

- la stratégie choisie par PostgreSQL ;
- le temps réellement nécessaire ;
- les lignes réellement parcourues ;
- les blocs de données consultés.

Ces mesures serviront ensuite de preuves pour justifier ou rejeter certaines optimisations.

---

## 11. Principe de décision pour l'architecture

Cette analyse 3V ne conclut pas que Match-Immo doit immédiatement utiliser une architecture complexe.

Elle permet au contraire d'éviter ce raisonnement :

```text
Il y aura beaucoup de données
→ donc il faut Citus.
```

La démarche retenue sera plutôt :

```text
Croissance métier
      ↓
Volume estimé
      ↓
Données de test
      ↓
Mesure de PostgreSQL
      ↓
Identification d'un problème
      ↓
Test d'une optimisation
      ↓
Nouvelle mesure
      ↓
Décision
```

Les solutions étudiées pourront notamment être :

- **indexation** : accélérer certaines recherches ;
- **partitionnement** : découper certaines très grandes tables ;
- **réplication** : disposer de plusieurs instances PostgreSQL pour la disponibilité et certaines lectures ;
- **sharding** : répartir les données entre plusieurs nœuds lorsque la capacité d'une seule instance devient insuffisante.

Le **sharding** consiste à découper horizontalement les données et à les répartir sur plusieurs serveurs.

Citus pourra être étudié comme solution de sharding PostgreSQL, mais son utilisation devra être justifiée par les besoins et les mesures.

---

## 12. Résultat de l'analyse 3V

L'analyse met en évidence trois contraintes principales.

| Axe | Constat | Conséquence à étudier |
|---|---|---|
| Volume | Jusqu'à plusieurs milliers de biens par recherche et plusieurs milliers de mandats par semaine | Croissance importante des données et surtout des associations recherche/bien |
| Vélocité | Nouvelles sélections quotidiennes ou plusieurs fois par jour | Besoin d'intégration et de recherche suffisamment rapides |
| Variété | Données relationnelles, annonces hétérogènes, géographie, texte et futurs médias | Besoin d'une architecture capable de traiter plusieurs formes de données |

Le scénario de dimensionnement retenu pour guider les expérimentations est :

```text
5 000 nouveaux mandats par semaine
×
jusqu'à 1 000 biens analysés par recherche

= jusqu'à 5 000 000 de rapprochements recherche/bien par semaine
```

Soit théoriquement :

```text
260 000 mandats par an
et
jusqu'à 260 000 000 de rapprochements recherche/bien par an
```

---

## 13. Conclusion

L'analyse des 3V montre que le futur Match-Immo doit être conçu pour une activité très supérieure au petit volume de données actuellement disponible dans les fixtures.

Le principal enjeu de croissance n'est pas uniquement le nombre de clients ou de mandats.

Il provient également du nombre potentiellement très important de biens analysés pour chaque recherche et de la fréquence de renouvellement des annonces.

Cependant, cette note ne considère pas ces projections comme une preuve suffisante pour imposer une architecture distribuée.

La suite de la Phase 3 devra confronter ces hypothèses à des mesures réelles.

Le générateur fourni par le Starter Pack permettra de produire des données représentatives, puis PostgreSQL sera testé progressivement sur des volumes croissants.

Les résultats permettront ensuite de justifier les choix concernant :

- l'indexation ;
- le partitionnement ;
- la réplication ;
- et, si le besoin est démontré, le sharding avec Citus.

Cette démarche permet de passer d'une hypothèse métier à une décision technique mesurée, reproductible et défendable.