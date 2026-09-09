# Plan de migration et de bascule — Match-Immo

## Phase 3 — Absorber la croissance

## 1. Objet du document

Ce document décrit la stratégie permettant de passer du système
historique Match-Immo vers le modèle transactionnel cible PostgreSQL.

Il complète les travaux déjà réalisés en Phase 2 :

- création du modèle cible ;
- reprise contrôlée des données ;
- validation technique de la reprise ;
- traçabilité des anomalies ;
- PCA/PRA et stratégie de restauration.

Le plan répond à huit questions :

1. que faut-il préparer avant la migration ?
2. comment protéger les données avant toute opération ?
3. quand décider GO ou NO-GO ?
4. dans quel ordre exécuter les scripts ?
5. quels contrôles doivent être réalisés ?
6. quand peut-on basculer vers le nouveau système ?
7. quand faut-il revenir en arrière ?
8. quelles preuves conserver après l'opération ?

---

## 2. Définitions simples

### 2.1 Migration

Une migration consiste à transférer les données et le fonctionnement
d'un ancien système vers un nouveau système.

Dans Match-Immo :

```text
ancien schéma
"Fil_Rouge_Depart"
        ↓
transformation contrôlée
        ↓
nouveau schéma
fil_rouge_cible
```

### 2.2 Bascule

La bascule, ou *cutover*, est le moment où le nouveau système devient le
système utilisé par l'activité.

La migration des données et la bascule ne sont donc pas exactement la
même chose.

### 2.3 Rollback

Le rollback est le retour à l'état précédent lorsqu'un problème empêche
de valider la migration.

Dans ce plan, deux protections sont distinguées :

```text
erreur pendant les scripts
→ transaction PostgreSQL
→ aucune validation partielle

problème après migration ou après bascule
→ restauration de sauvegarde
ou
→ réouverture temporaire de l'ancien système
```

### 2.4 GO / NO-GO

Le GO / NO-GO est une décision formelle :

```text
GO
→ toutes les conditions nécessaires sont satisfaites
→ la migration peut continuer

NO-GO
→ au moins une condition critique n'est pas satisfaite
→ la migration ou la bascule est arrêtée
```

---

## 3. Périmètre de la migration

### Source

Le système historique est représenté par le schéma PostgreSQL :

```text
"Fil_Rouge_Depart"
```

Les données de référence utilisées pendant la validation contiennent :

| Donnée source | Volume validé |
|---|---:|
| secteurs | 10 |
| utilisateurs | 24 |
| mandats | 18 |

### Cible

Le nouveau modèle transactionnel est :

```text
fil_rouge_cible
```

Il est construit par :

```text
02-modele-cible/migration-final.sql
```

La reprise des données est réalisée par :

```text
02-modele-cible/reprise-donnees-final.sql
```

La zone de contrôle est :

```text
reprise_controle
```

Elle conserve notamment :

- les hypothèses de reprise ;
- les mandats rejetés ;
- les corrections appliquées ;
- les données source non intégrables directement dans la cible.

---

## 4. Stratégies étudiées

### 4.1 Migration progressive

Une migration progressive ferait fonctionner ancien et nouveau systèmes
en parallèle pendant une période déterminée.

Elle nécessiterait notamment :

- synchronisation entre les deux systèmes ;
- gestion des écritures concurrentes ;
- mécanisme de double écriture ou de réplication métier ;
- règles de résolution des conflits ;
- exploitation temporaire de deux systèmes.

### 4.2 Migration Big Bang contrôlée

Une migration Big Bang réalise la transition pendant une fenêtre de
bascule maîtrisée :

```text
gel des écritures
        ↓
sauvegarde
        ↓
migration
        ↓
contrôles
        ↓
GO / NO-GO
        ↓
ouverture de la cible
```

### 4.3 Décision retenue

Pour le périmètre historique actuellement fourni, la stratégie retenue
est :

> **Big Bang contrôlé avec sauvegarde préalable, contrôles bloquants et
> possibilité de retour arrière.**

### 4.4 Justification

Cette stratégie est retenue car :

- le système historique fourni est de faible volume ;
- il ne contient que trois tables principales ;
- la reprise validée porte sur 18 mandats ;
- la transformation est déjà automatisée ;
- les scripts sont rejouables ;
- la reprise est exécutée dans une transaction PostgreSQL ;
- les anomalies sont explicitement tracées ;
- maintenir deux modèles métier simultanément ajouterait une complexité
  non justifiée par les mesures actuelles.

Cette décision concerne le périmètre actuel.

Une migration progressive pourrait être réévaluée dans le futur si le SI
devient beaucoup plus volumineux ou si une interruption des écritures
devient métierment impossible.

---

## 5. Principe directeur

La migration suit la chaîne suivante :

```text
PRÉPARER
    ↓
GELER LES ÉCRITURES
    ↓
SAUVEGARDER
    ↓
VÉRIFIER LA SOURCE
    ↓
GO / NO-GO N°1
    ↓
CRÉER LA CIBLE
    ↓
REPRENDRE LES DONNÉES
    ↓
CONTRÔLER
    ↓
GO / NO-GO N°2
    ↓
BASCULER
    ↓
SURVEILLER
    ↓
CLÔTURER
```

---

## 6. Responsabilités cibles

Dans le projet individuel, plusieurs rôles sont assumés par la même
personne, mais ils restent distingués afin de représenter une organisation
professionnelle.

| Rôle | Responsabilité principale |
|---|---|
| Responsable métier | valide l'arrêt des écritures et les résultats métier |
| Chef de projet | coordonne la fenêtre de migration et le GO / NO-GO |
| Data Engineer | exécute et contrôle la reprise |
| DBA | sauvegarde, PostgreSQL, intégrité et restauration |
| Exploitation | vérifie la disponibilité après bascule |
| DPO / sécurité | vérifie les exigences de sécurité et de traçabilité concernées |

---

## 7. Préparation avant migration

Avant toute opération destructive :

1. confirmer la version des scripts Git à utiliser ;
2. confirmer la disponibilité de PostgreSQL ;
3. vérifier l'espace disque ;
4. vérifier les accès administratifs nécessaires ;
5. vérifier que la source est accessible ;
6. annoncer la fenêtre de maintenance ;
7. empêcher les nouvelles écritures métier ;
8. effectuer une sauvegarde ;
9. vérifier l'intégrité de la sauvegarde ;
10. conserver l'identifiant du commit Git utilisé.

Aucune migration ne doit commencer tant que ces contrôles ne sont pas
terminés.

---

## 8. Gel des écritures

Le gel des écritures empêche que des données soient ajoutées dans
l'ancien système pendant la migration.

Sans gel :

```text
copie à 10:00
        ↓
nouvelle donnée créée à 10:01 dans l'ancien SI
        ↓
cette donnée peut manquer dans la cible
```

Pendant la fenêtre de bascule :

- aucune nouvelle création métier ;
- aucune modification métier ;
- aucune suppression métier ;
- les consultations peuvent rester autorisées si elles ne compromettent
  pas l'opération.

---

## 9. Sauvegarde préalable obligatoire

La sauvegarde constitue le point de retour avant migration.

Principe :

```text
SOURCE SAINE
        ↓
SAUVEGARDE
        ↓
CONTRÔLE D'INTÉGRITÉ
        ↓
MIGRATION
```

Le PCA/PRA de Match-Immo a déjà démontré au niveau POC :

- une restauration locale ;
- une externalisation de sauvegarde ;
- une restauration distante ;
- un contrôle d'intégrité ;
- une reprise des écritures après restauration.

Ces preuves démontrent la restaurabilité technique du POC.

Elles ne dispensent pas d'effectuer une nouvelle sauvegarde juste avant
une migration réelle.

---

## 10. Contrôles préalables de la source

Le script de reprise contrôle automatiquement que la source contient les
volumes attendus dans le jeu historique validé :

```text
10 secteurs
24 utilisateurs
18 mandats
```

Une différence déclenche une exception PostgreSQL.

Ce comportement est volontaire :

> une variation inattendue de la source doit être comprise avant de
> poursuivre la migration.

Dans une future migration de production avec d'autres volumes, les
valeurs attendues devront être recalculées et validées avant exécution.

---

## 11. GO / NO-GO n°1 — Autorisation de migrer

Le GO est donné uniquement si :

| Contrôle | Condition |
|---|---|
| Source accessible | Oui |
| Écritures gelées | Oui |
| Sauvegarde réalisée | Oui |
| Sauvegarde contrôlée | Oui |
| Scripts validés dans Git | Oui |
| PostgreSQL cible disponible | Oui |
| Volumes source expliqués | Oui |
| Responsable de bascule disponible | Oui |

Si une condition critique vaut NON :

```text
NO-GO
→ aucune migration
→ maintien de l'ancien système
→ correction du problème
→ nouvelle fenêtre de migration
```

---

## 12. Création du modèle cible

Le modèle cible est construit avec :

```bash
docker exec -i match-immo-conception-app-postgres-1 \
  psql -v ON_ERROR_STOP=1 -U match_immo -d match_immo \
  < 02-modele-cible/migration-final.sql
```

L'option :

```text
ON_ERROR_STOP=1
```

demande à `psql` d'arrêter immédiatement l'exécution lorsqu'une erreur SQL
est rencontrée.

Le script :

```text
BEGIN
→ création du schéma et des 26 tables
→ contraintes
→ index
→ COMMIT
```

La commande `DROP SCHEMA IF EXISTS fil_rouge_cible CASCADE` présente dans
le script est destructive pour une cible déjà existante.

Elle ne doit donc être exécutée qu'après sauvegarde et validation du
GO / NO-GO.

---

## 13. Reprise des données

La reprise est exécutée avec :

```bash
docker exec -i match-immo-conception-app-postgres-1 \
  psql -v ON_ERROR_STOP=1 -U match_immo -d match_immo \
  < 02-modele-cible/reprise-donnees-final.sql
```

Le script réalise notamment :

1. contrôle de la présence des schémas ;
2. contrôle des volumes source ;
3. création de `reprise_controle` ;
4. remise à zéro de la cible ;
5. traçabilité des données non reprises directement ;
6. reprise des secteurs ;
7. reprise des utilisateurs ;
8. détection des mandats non migrables ;
9. correction déterministe de certains statuts ;
10. reconstruction des demandes ;
11. reconstruction des affectations ;
12. reconstruction des versions de demande ;
13. reprise des mandats ;
14. transformation des taux historiques en barèmes ;
15. réalignement des séquences ;
16. contrôles bloquants ;
17. `COMMIT` ;
18. rapport de reprise.

---

## 14. Contrôles bloquants avant COMMIT

Le script vérifie notamment :

```text
10 secteurs cible
24 utilisateurs cible
18 clients cible
6 chasseurs cible

18 mandats source
=
16 mandats migrés
+
2 rejets

16 demandes
16 affectations
16 versions de demande

5 corrections actif → expire

6 barèmes de transition
6 tranches de commission
```

Il vérifie également :

- une version courante pour chaque demande ;
- au moins un secteur pour chaque version concernée ;
- la cohérence entre mandat et affectation ;
- l'absence de mandat encore actif après sa date de fin ;
- le rejet attendu du mandat 13 ;
- le rejet attendu du mandat 9.

Une anomalie bloquante provoque une exception.

---

## 15. Preuve de reprise déjà obtenue

La Phase 2 a démontré :

```text
18 mandats source
        ↓
16 mandats migrés
+
2 mandats rejetés et tracés
```

Les deux rejets sont justifiés :

```text
mandat 13
→ rôle client incohérent

mandat 9
→ incohérence chronologique
```

Cinq statuts ont été corrigés de manière déterministe :

```text
actif
→ expire
```

Ces résultats sont documentés dans :

```text
02-modele-cible/reprise-donnees-validation.md
```

---

## 16. Contrôles après migration

Après le `COMMIT`, les contrôles portent sur quatre niveaux.

### 16.1 Contrôle technique

- connexion PostgreSQL ;
- présence du schéma cible ;
- présence des tables attendues ;
- absence d'erreur SQL.

### 16.2 Contrôle quantitatif

Comparer :

```text
source
=
cible
+
rejets expliqués
```

### 16.3 Contrôle qualitatif

Vérifier :

- rôles client / chasseur ;
- dates ;
- statuts ;
- relations demande / affectation / mandat ;
- hypothèses documentées ;
- corrections ;
- rejets.

### 16.4 Contrôle métier

Le métier doit vérifier que les données essentielles sont consultables et
compréhensibles dans le nouveau système.

---

## 17. GO / NO-GO n°2 — Autorisation de bascule

Après la migration :

### GO

La bascule est autorisée si :

- le script s'est terminé par `COMMIT` ;
- les contrôles bloquants sont passés ;
- les volumes sont conformes ;
- chaque écart est expliqué ;
- les deux rejets attendus sont présents ;
- les cinq corrections attendues sont présentes ;
- les contrôles métier prioritaires sont validés ;
- le nouveau système est accessible.

### NO-GO

La bascule est refusée si :

- le script échoue ;
- un volume critique est inexpliqué ;
- une relation métier structurante est incohérente ;
- une donnée attendue disparaît sans trace ;
- les contrôles métier échouent ;
- le nouveau système n'est pas exploitable.

---

## 18. Bascule applicative

Après GO n°2 :

```text
ancien système
→ lecture seule / arrêté

nouveau système
→ ouvert aux écritures
```

Les applications ou services doivent alors utiliser le schéma cible.

La bascule applicative complète n'a pas encore été exécutée dans le projet,
car le backend final relève des phases applicatives suivantes.

Le présent document définit donc la procédure cible de bascule sans
prétendre qu'une application de production complète a déjà été migrée.

---

## 19. Rollback — Retour arrière

### 19.1 Erreur avant COMMIT

Les scripts utilisent une transaction PostgreSQL.

En cas d'erreur bloquante avant validation :

```text
BEGIN
→ opérations
→ erreur
→ transaction non validée
```

L'exécution avec `ON_ERROR_STOP=1` empêche de poursuivre silencieusement.

### 19.2 Échec avant la bascule applicative

Si les données migrées ne sont pas validées :

```text
NO-GO
→ ne pas ouvrir la cible
→ conserver l'ancien SI comme référence
→ analyser le problème
→ corriger le script
→ rejouer en environnement de validation
```

### 19.3 Échec après bascule

Si un incident majeur apparaît après ouverture de la cible :

1. arrêter les nouvelles écritures ;
2. qualifier l'incident ;
3. décider si une correction immédiate est sûre ;
4. sinon déclencher le retour arrière ;
5. restaurer le dernier point sain lorsque nécessaire ;
6. contrôler l'intégrité ;
7. réouvrir le système validé.

Le mécanisme de restauration est détaillé dans :

```text
03-architecture/pca-pra-complet-maj.md
```

---

## 20. Relation avec le PCA / PRA

Le plan de migration et le PRA répondent à deux objectifs différents :

```text
PLAN DE MIGRATION
→ changer volontairement de système

PRA
→ redémarrer après un incident grave
```

Ils se rejoignent sur un point essentiel :

> une migration ne doit jamais supprimer la possibilité de revenir à un
> état sain.

Le risque de migration est notamment couvert dans la matrice des risques
par :

```text
R11 — échec de migration
R12 — perte ou transformation incorrecte de données
R17 — erreur humaine lors d'une bascule
```

---

## 21. Surveillance après bascule

Après ouverture du nouveau système, une période de surveillance renforcée
doit être appliquée.

À contrôler :

- erreurs applicatives ;
- erreurs PostgreSQL ;
- temps de réponse ;
- intégrité des nouvelles écritures ;
- séquences d'identifiants ;
- contraintes ;
- journaux ;
- espace disque ;
- sauvegardes ;
- réplication lorsque la HA est activée.

Une anomalie importante pendant cette période peut entraîner un NO-GO
tardif et un rollback.

---

## 22. Critères de clôture

La migration peut être déclarée terminée lorsque :

- la cible est opérationnelle ;
- les contrôles techniques sont validés ;
- les contrôles métier sont validés ;
- les rejets sont documentés ;
- les corrections sont documentées ;
- les sauvegardes sont opérationnelles ;
- les preuves sont conservées ;
- le journal de décisions est mis à jour ;
- Git contient les scripts réellement utilisés.

---

## 23. Preuves associées

| Élément | Preuve |
|---|---|
| Audit de la source | `01-audit/` |
| Modèle cible | `02-modele-cible/mld-cible-final.md` |
| Création de la cible | `02-modele-cible/migration-final.sql` |
| Reprise | `02-modele-cible/reprise-donnees-final.sql` |
| Validation de reprise | `02-modele-cible/reprise-donnees-validation.md` |
| Risques migration | `03-architecture/matrice-risques.md` |
| PCA / PRA | `03-architecture/pca-pra-complet-maj.md` |
| Architecture de croissance | `03-architecture/dossier-architecture-de-croissance.md` |
| Journal des décisions | `decisions/journal-decisions-MAJ-2026-09-05.md` |

---

## 24. Limites du plan

Ce plan distingue volontairement :

### Démontré

- création PostgreSQL de la cible ;
- reprise transactionnelle ;
- contrôles bloquants ;
- 16 mandats migrés ;
- 2 rejets tracés ;
- 5 corrections tracées ;
- restauration locale au niveau POC ;
- restauration distante au niveau POC.

### Défini mais non encore démontré end-to-end en production

- fenêtre réelle de maintenance ;
- gel d'une application de production ;
- bascule d'un backend final ;
- validation métier par de vrais utilisateurs ;
- RTO complet de migration ;
- chaîne de sauvegarde horaire automatisée ;
- rollback d'une application de production complète.

Cette distinction évite de présenter une cible d'architecture comme une
preuve déjà obtenue.

---

## 25. Décision finale

Pour le périmètre actuel de Match-Immo :

> **La migration vers le modèle cible est réalisée selon une stratégie
> Big Bang contrôlée, précédée d'une sauvegarde, protégée par des
> transactions et des contrôles bloquants, puis soumise à deux décisions
> GO / NO-GO avant la bascule définitive.**

La stratégie progressive n'est pas retenue à ce stade car elle imposerait
une synchronisation temporaire de deux systèmes sans justification
technique ou volumétrique démontrée.

Le principe directeur reste :

```text
SAUVEGARDER
→ MIGRER
→ MESURER
→ VALIDER
→ BASCULER
→ SURVEILLER
→ POUVOIR REVENIR EN ARRIÈRE
```
