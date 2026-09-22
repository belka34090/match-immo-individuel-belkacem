# Note d'éco-conception — Match Immo

## 1. Objectif

L'éco-conception numérique consiste à limiter les ressources informatiques
utilisées sans dégrader inutilement le service rendu.

Dans Match Immo, les principaux postes concernés sont :

- le stockage des données et des sauvegardes ;
- la fréquence des sauvegardes et futurs traitements analytiques ;
- l'exécution des requêtes SQL ;
- le stockage futur des médias ;
- la durée de conservation des données.

Cette note complète les exigences ENF-22, ENF-23 et ENF-24 du cahier des
charges technique.

Les mesures décrites ici constituent des choix de conception cible.
Elles devront être vérifiées et testées lors de l'implémentation.

---

## 2. Principes retenus

Le projet applique les principes suivants :

- ne pas dupliquer inutilement les données ;
- ne pas conserver indéfiniment une donnée sans finalité ;
- éviter les traitements périodiques trop fréquents lorsqu'ils n'apportent
  pas de valeur métier ;
- privilégier les sauvegardes incrémentales entre deux sauvegardes complètes ;
- optimiser les requêtes importantes avant d'augmenter les ressources
  matérielles ;
- purger les sauvegardes devenues inutiles ;
- privilégier des données fictives ou anonymisées pour les tests lorsque
  des données réelles ne sont pas nécessaires.

Ces principes sont cohérents avec le registre RGPD du projet : réduire la
quantité de données stockées participe également à la protection des données
personnelles.

---

## 3. Arbitrage des sauvegardes multi-fréquences

Le Starter Pack demande d'étudier quatre fréquences :
minute, heure, 12 heures et 24 heures.

Tout sauvegarder très fréquemment augmenterait le stockage, les écritures
disque, les transferts et les traitements sans bénéfice proportionné au besoin
actuel de Match Immo.

| Fréquence | Décision | Usage retenu | Justification |
| --- | --- | --- | --- |
| Chaque minute | Non retenue | Aucun | Coût de stockage et d'exécution disproportionné par rapport au besoin actuel |
| Chaque heure | Retenue | Sauvegarde incrémentale des changements | Limite la perte potentielle de nouvelles opérations métier sans effectuer une copie complète |
| Toutes les 12 h | Retenue | Point de restauration intermédiaire | Offre davantage de possibilités de restauration avec un coût modéré |
| Toutes les 24 h | Retenue | Sauvegarde complète de la base | Garantit quotidiennement un état complet et cohérent de la base |

Une sauvegarde incrémentale conserve uniquement les changements intervenus
depuis la sauvegarde précédente.

La sauvegarde complète quotidienne constitue le point de référence principal.
Les sauvegardes intermédiaires permettent de se rapprocher de l'état précédant
un incident sans multiplier les copies complètes.

La cible associée est un RPO d'environ une heure.

Le RPO (Recovery Point Objective) représente la quantité maximale de données
que l'organisation accepte de perdre après un incident.

Cette valeur reste une cible d'exploitation.

Le PCA/PRA de Phase 3 a validé au niveau POC la restaurabilité locale et
distante d'une sauvegarde. En revanche, une chaîne automatisée produisant
réellement un point restaurable toutes les heures n'a pas encore été démontrée.

Le RPO d'environ une heure reste donc un objectif d'architecture, et non une
mesure de production déjà obtenue.

---

## 4. Politique de rétention des sauvegardes

Une sauvegarde n'a pas vocation à être conservée indéfiniment.

La politique cible retenue est la suivante :

| Type de sauvegarde | Rétention cible | Justification |
| --- | --- | --- |
| Incrémentales horaires | 48 heures | Suffisant pour traiter les incidents récents sans accumulation excessive |
| Points intermédiaires 12 h | 7 jours | Permet plusieurs retours arrière sur une semaine |
| Sauvegardes complètes quotidiennes | 30 jours | Offre un historique raisonnable pour une restauration plus ancienne |

À l'expiration de leur durée de rétention, les sauvegardes doivent être
supprimées automatiquement, sauf nécessité réglementaire ou incident en cours
justifiant leur conservation temporaire.

Ces durées concernent les copies techniques de sauvegarde et ne remplacent pas
les durées légales de conservation des données métier définies dans le registre
RGPD.

Par exemple, un mandat devant être conservé légalement ne signifie pas qu'il
faut conserver chaque sauvegarde quotidienne pendant la même durée.

---

## 5. Stockage des données et médias

Le modèle cible centralise les informations d'identité dans `UTILISATEUR`
afin d'éviter de répéter les mêmes coordonnées dans plusieurs tables.

Les données devenues inutiles doivent être supprimées ou anonymisées lorsque
les règles métier et légales le permettent.

Les futurs médias associés aux avis des chasseurs ne seront pas stockés
directement dans les lignes de la base relationnelle.

La table `MEDIA_AVIS` conserve seulement une référence vers leur emplacement.
La politique de stockage physique et de cycle de vie des médias devra être
définie lorsque cette fonctionnalité sera réellement implémentée.

Il faudra notamment éviter de conserver plusieurs copies inutiles du même
fichier et prévoir la suppression des médias devenus sans finalité.

---

## 6. Requêtes et traitements

Une requête SQL mal conçue peut consommer inutilement du processeur,
de la mémoire et des entrées/sorties disque.

Le projet prévoit donc de :

- mesurer les requêtes importantes avant optimisation ;
- utiliser des index uniquement lorsqu'un besoin mesuré les justifie ;
- comparer les plans d'exécution avant et après optimisation ;
- éviter de recalculer inutilement des résultats identiques ;
- séparer à terme les traitements transactionnels OLTP des traitements
  analytiques OLAP lorsque la croissance le justifie.

OLTP désigne la base utilisée pour les opérations métier quotidiennes.

OLAP désigne la future structure destinée aux analyses, statistiques et au
pilotage.

L'alimentation OLAP n'a pas vocation à être exécutée en permanence si le métier
n'a pas besoin de données analytiques en temps réel. Sa fréquence sera définie
en Phase 3 selon les besoins réels et les volumes mesurés.

---

## 7. Choix éco-conçus

| Décision | Alternative plus lourde écartée | Gain recherché |
| --- | --- | --- |
| Sauvegardes incrémentales horaires | Sauvegarde complète chaque heure | Moins de stockage, d'écritures et de transferts |
| Sauvegarde complète quotidienne | Sauvegarde complète chaque minute ou heure | Réduction importante des opérations inutiles |
| Rétention limitée des sauvegardes | Conservation indéfinie | Réduction du volume de stockage |
| Centralisation de l'identité utilisateur | Duplication des coordonnées dans plusieurs tables | Moins de données dupliquées |
| Optimisation mesurée des requêtes | Ajouter des ressources sans diagnostic | Réduction de la consommation CPU et disque |
| Traitements analytiques périodiques | Rafraîchissement permanent sans besoin métier | Réduction des calculs inutiles |
| Cycle de vie des médias | Conservation illimitée de tous les fichiers | Maîtrise du stockage futur |

---

## 8. Limites et contrôles futurs

Cette note définit des choix de conception et non un mécanisme déjà déployé.

Les travaux de Phase 3 ont déjà permis de valider au niveau POC :

- une sauvegarde restaurable ;
- une restauration locale ;
- une restauration distante sur un site indépendant ;
- un contrôle d'intégrité après restauration ;
- une reprise des écritures après restauration.

Les points restant à vérifier ou industrialiser concernent notamment :

- l'automatisation réelle des sauvegardes horaires ;
- une chaîne de sauvegarde physique et de PITR adaptée à la production ;
- le volume réellement occupé en exploitation ;
- le RTO complet mesuré de bout en bout ;
- la consommation des requêtes importantes ;
- la fréquence réellement nécessaire pour l'OLAP ;
- la politique de stockage et de purge des médias.

Les décisions pourront être ajustées si des mesures réelles montrent qu'un
autre compromis répond mieux au besoin métier.

---

## 9. Conclusion

L'approche retenue cherche un compromis entre continuité du service,
performance, coût technique et impact environnemental.

Le projet ne retient pas une sauvegarde chaque minute car le besoin actuel ne
justifie pas son coût.

Il privilégie une sauvegarde incrémentale horaire, des points de restauration
intermédiaires et une sauvegarde complète quotidienne avec une rétention
limitée.

Cette stratégie permet de viser un RPO d'environ une heure tout en évitant de
stocker et traiter inutilement de multiples copies complètes.

La politique est désormais reliée au PCA/PRA de Phase 3.

Les tests ont démontré au niveau POC qu'une sauvegarde peut être restaurée
localement puis sur un site distant indépendant avec contrôle d'intégrité et
reprise des écritures.

La cible RPO d'environ une heure reste toutefois à industrialiser et à
démontrer par une chaîne automatisée de sauvegarde et de restauration.
