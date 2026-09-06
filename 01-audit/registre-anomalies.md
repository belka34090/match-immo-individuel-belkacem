# Registre des anomalies et des risques

## 1. Objectif

Ce registre a pour objectif d’identifier, qualifier et prioriser :

- les anomalies réellement constatées dans les données historiques ;
- les risques structurels du système d’information existant ;
- les actions proposées pour les phases suivantes.

La date de référence de l’audit est le **25 juillet 2026**.

Les fichiers historiques fournis dans les fixtures servent de référence et ne sont pas modifiés pendant l’audit.

Les corrections éventuelles sont réalisées plus tard, lors de la reprise des données vers la solution cible.

---

## 2. Différence entre une anomalie et un risque

Une **anomalie** correspond à un problème réellement observé dans les données existantes.

Exemple :

> un utilisateur ayant le rôle `chasseur` est utilisé comme client dans un mandat.

Un **risque** correspond à une faiblesse du système susceptible de provoquer des erreurs ou des difficultés, même si aucune donnée incorrecte n’est actuellement présente.

Exemple :

> la base ne vérifie pas automatiquement que `client_id` référence réellement un utilisateur ayant le rôle `client`.

Cette distinction permet de séparer :

- les problèmes déjà présents ;
- les problèmes qui pourraient se produire à cause de la structure actuelle.

---

## 3. Anomalies de données confirmées

| ID | Type | Anomalie constatée | Impact métier | Gravité | Action proposée | Preuve |
| --- | --- | --- | --- | --- | --- | --- |
| A-01 | Intégrité métier | Le mandat `13` référence comme client l’utilisateur `3`, dont le rôle est `chasseur`. | Le mandat est associé à une personne ayant un rôle métier incorrect. | Élevée | Isoler le mandat et demander une vérification métier avant sa reprise. | `preuves/03-anomalies/resultats-anomalies.md` |
| A-02 | Cohérence métier | Les mandats `4`, `7`, `9`, `10`, `11` et `12` sont encore enregistrés comme actifs alors que leur durée théorique de six mois est dépassée au 25/07/2026. | Le statut enregistré ne permet pas de déterminer avec certitude si le mandat est réellement encore valable. | Élevée | Vérifier les éventuels renouvellements avant la reprise et prévoir dans la cible un suivi explicite de la durée des mandats. | `preuves/03-anomalies/resultats-anomalies.md` |
| A-03 | Cohérence temporelle | Le mandat `9` débute le 2 octobre 2025 alors que le compte du chasseur associé a été créé le 3 novembre 2025. | Les dates disponibles sont incompatibles entre elles. | Élevée | Isoler ce mandat et demander une vérification des dates avant sa reprise. | `preuves/03-anomalies/resultats-anomalies.md` |

### Précision concernant A-02

La règle métier indique qu’un mandat possède une durée de six mois.

Un renouvellement pourrait donc expliquer qu’un mandat reste actif au-delà de cette durée.

Cependant, la base historique ne contient pas d’information permettant de vérifier l’existence d’un renouvellement.

Les six mandats sont donc signalés comme incohérents ou à vérifier, sans inventer une information absente des données sources.

---

## 4. Risques structurels

| ID | Type | Risque identifié | Impact métier | Gravité | Action proposée | Preuve / origine |
| --- | --- | --- | --- | --- | --- | --- |
| R-01 | Intégrité métier | `client_id` et `chasseur_id` référencent tous les deux la table `utilisateurs` sans garantir automatiquement le rôle métier attendu. | Un utilisateur peut être utilisé dans un mauvais rôle dans un mandat. | Élevée | Mettre en place dans la solution cible une structure garantissant les rôles attendus. | `analyse-audit.md` |
| R-02 | Gestion des mandats | La base historique ne représente pas suffisamment la date de fin, le mode de signature et les renouvellements des mandats. | La validité et le cycle de vie d’un mandat sont difficiles à suivre de manière fiable. | Élevée | Modéliser explicitement les informations nécessaires au suivi du mandat. | `analyse-audit.md` |
| R-03 | Qualité des données | Les critères de recherche immobilière sont principalement stockés dans `description_recherche` sous forme de texte libre. | Recherche, comparaison, analyse et automatisation sont difficiles. | Élevée | Structurer les critères utiles au métier dans la solution cible. | `analyse-audit.md` |
| R-04 | Couverture métier | La base historique ne possède pas de structures dédiées pour une grande partie du parcours métier : demandes, biens, visites, offres, ventes, honoraires, commissions et paiements. | Le système ne permet pas de suivre complètement l’activité décrite dans le besoin métier. | Élevée | Étendre le modèle de données cible aux objets métier nécessaires. | `analyse-audit.md` |
| R-05 | Maintenabilité | Le code source du backend existant est considéré comme inexploitable dans le contexte du projet. | Le backend ne peut pas être maintenu ou faire évoluer correctement les applications existantes. | Élevée | Concevoir un nouveau backend compatible avec les besoins et les applications conservées. | Énoncé du projet et cartographie de l’existant |
| R-06 | Modélisation | Clients et chasseurs sont regroupés dans une même table alors que certaines informations et règles leur sont propres. | Les contrôles métier sont plus difficiles à appliquer et certaines colonnes ne concernent qu’une partie des utilisateurs. | Moyenne | Séparer les informations communes des informations propres à chaque rôle dans le modèle cible. | `analyse-audit.md` |
| R-07 | Traçabilité | Les évolutions des critères de recherche ne sont pas historisées. | Il est impossible de retracer précisément les différentes versions d’une demande au cours du temps. | Moyenne | Prévoir une gestion des versions de la demande. | `analyse-audit.md` |
| R-08 | Gestion documentaire | Une partie de l’activité repose sur des dossiers papier dont l’utilisation précise reste à déterminer. | Certaines informations peuvent être difficiles à retrouver, partager ou suivre. | Moyenne | Identifier les documents concernés et déterminer lesquels doivent être pris en charge par le futur système. | `mermaid_carto_existante_SI.png` |
| R-09 | Qualité des données | Certains formats et certaines valeurs métier ne sont pas suffisamment contrôlés par le schéma historique. | Des valeurs incohérentes ou mal formatées peuvent être enregistrées. | Moyenne | Définir des contraintes adaptées dans le modèle cible et lors des traitements applicatifs. | `preuves/04-validation-finale/validation-phase1.md` |
| R-10 | Intégrité géographique | Le modèle historique ne garantit pas suffisamment l’unicité logique de certaines informations géographiques et `secteur_id` peut être absent sur un mandat. | Risque de doublons de secteurs ou de mandats insuffisamment rattachés à une zone géographique. | Moyenne | Renforcer les règles de gestion géographique dans la solution cible. | `analyse-audit.md` et `preuves/04-validation-finale/validation-phase1.md` |

---

## 5. Comment les anomalies ont été vérifiées

Les anomalies A-01, A-02 et A-03 ont été recherchées à l’aide de requêtes SQL exécutées sur la base historique.

Les requêtes techniques ne sont pas dupliquées dans ce registre.

Elles sont conservées dans :

`preuves/03-anomalies/requetes-audit.sql`

Les résultats obtenus sont conservés dans :

`preuves/03-anomalies/resultats-anomalies.md`

Cette organisation permet de distinguer clairement :

- le **registre**, qui explique et priorise les problèmes ;
- les **requêtes SQL**, qui montrent comment les données ont été contrôlées ;
- les **résultats**, qui constituent la preuve des anomalies constatées.

---

## 6. Traitement prévu dans les phases suivantes

Les anomalies historiques ne sont pas corrigées directement dans les fixtures.

La reprise vers la solution cible applique une démarche contrôlée :

**identifier → vérifier → décider → corriger ou rejeter → conserver une trace**

Cela permet d’éviter de modifier silencieusement les données historiques.

À titre de traçabilité pour la suite du projet :

- l’anomalie A-02 concerne initialement **six mandats** : `4`, `7`, `9`, `10`, `11`, `12` ;
- lors de la reprise des données, les mandats `4`, `7`, `10`, `11` et `12` peuvent faire l’objet d’un traitement adapté ;
- le mandat `9` nécessite un traitement différent car il est également concerné par l’anomalie temporelle A-03.

Le détail du traitement réel appartient aux livrables de migration et de reprise de la Phase 2.

Cette distinction évite de confondre :

- **ce qui a été trouvé pendant l’audit** ;
- **ce qui a ensuite été décidé pendant la migration**.

---

## 7. Conclusion

L’audit confirme trois catégories d’anomalies de données et plusieurs risques structurels importants.

Les problèmes les plus critiques concernent :

- la cohérence des rôles ;
- le suivi de la durée des mandats ;
- la cohérence chronologique ;
- la faible structuration des critères de recherche ;
- la couverture incomplète du parcours métier.

Ces constats servent directement à justifier les choix du modèle cible et de la stratégie de reprise des données.

Les preuves techniques restent conservées séparément dans le dossier `preuves/` afin que les conclusions puissent être vérifiées et reproduites.
