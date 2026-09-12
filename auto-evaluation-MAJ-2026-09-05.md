# 📊 Grille d'auto-évaluation & calibrage des livrables

> Projet fil-rouge « Chasse immobilière » --- RNCP40573 (cible BC05 +
> blocs communs BC01/BC02/BC03)

Ce document a deux fonctions :

1.  **Calibrer la profondeur attendue** de chaque livrable (éviter aussi
    bien le bâclage que la sur-production) ;
2.  Fournir une **grille d'auto-évaluation adossée aux compétences**, à
    remplir par le groupe avant la soutenance.

------------------------------------------------------------------------

## 1. Calibrage des livrables

> Le titre s'évalue par **livrables + mise en situation + oral**, pas
> par volume. Un livrable court et juste vaut mieux qu'un dossier
> fleuve. Les formats ci-dessous sont des **cibles**, pas des minima à
> gonfler.

  -----------------------------------------------------------------------
  Livrable                Format cible            Bloc principal
  ----------------------- ----------------------- -----------------------
  Dossier d'audit de      Cartographie (1         BC01
  l'existant              schéma) + registre      
                          d'anomalies (tableau) + 
                          1 à 2 pages d'analyse   

  Note stratégique (axes  2-3 pages               BC01
  d'évolution)                                    

  Dossier d'architecture  1 schéma de             BC01
  (croissance)            composants + 1 matrice  
                          de décision + 2-3 pages 

  Étude d'opportunité     1-2 pages               BC02

  Note de cadrage         3-4 pages               BC02

  Planning (Gantt) +      1 schéma + légende      BC02
  jalons                                          

  Matrice des risques +   1 tableau               BC02
  mitigation                                      

  RACI                    1 page                  BC02

  MCD complet (cible)     1 schéma +              BC05
                          justifications des      
                          choix débattus          

  Scripts SQL             Commentés, rejouables,  BC05
  (`02-modele-cible/migration-final.sql`,       transactionnels
  requêtes)                                       

  Note d'indexation       1 page + captures       BC05
  (EXPLAIN avant/après)                           

  Schéma analytique       1 schéma + description  BC05
  (OLAP) + alimentation   (script SQL ou code)    
  des données                                     

  Note de dimensionnement 1-2 pages chiffrées     BC05
  3V                                              

  Conception du modèle de 2 pages (conception,    BC05
  matching + features     pas entraînement)       

  Schéma du programme     1 schéma + description  BC05
  d'IA                    entrées/sorties         

  Dossier de conception   Maquettes + patterns    BC03
  applicative + maquettes justifiés, 3-5 pages    

  Plan de tests           Scénarios + rapports    BC03
  (unitaires +            d'exécution             
  fonctionnels)                                   

  Registre RGPD           1 tableau (finalité,    transverse
                          base légale, durée,     
                          données sensibles)      

  Note d'éco-conception   1-2 pages (dont         transverse
                          arbitrage sauvegardes)  

  Note d'accessibilité    1 page                  transverse
  PSH                                             

  Note                    1 page                  transverse
  souveraineté/sécurité                           
  IA                                              
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## 2. Grille d'auto-évaluation par compétence

> **État au 06/09/2026.** Cotation : **NA** = non abordé · **EC** = en
> cours ou preuve encore incomplète · **A** = acquis, avec preuve
> produite et défendable.
>
> Principe retenu : une compétence n'est pas classée **A** uniquement
> parce qu'une partie du travail existe. Toutes les preuves essentielles
> demandées par la grille doivent être suffisamment produites et
> défendables.

### BC05 --- Big data & IA (bloc cible)

| Compétence | Statut | Justification au 06/09/2026 | Preuve / reste à produire |
| --- | --- | --- | --- |
| Analyser 3V (volume, vélocité, variété) | **NA** | L'analyse chiffrée des 3V n'a pas encore été produite. | À produire : note de dimensionnement 3V. |
| Concevoir/évaluer un modèle ML | **NA** | La conception du modèle de matching et de ses features n'est pas encore formalisée. | À produire : conception matching + features. |
| Extraction/transformation/chargement + qualité + RGPD | **EC** | Une reprise réelle des données a été conçue et exécutée : 18 mandats source, 2 rejets justifiés, 16 migrés et 5 corrections de statut parmi les 6 anomalies A-02 ; le sixième mandat est rejeté en raison de l'anomalie A-03. Le registre RGPD est désormais produit. | `02-modele-cible/reprise-donnees-final.sql`, `02-modele-cible/reprise-donnees-validation.md`, `02-modele-cible/registre-rgpd.md`. Reste : OLAP, alimentation analytique et qualité analytique consolidée. |
| Concevoir la base pour analytique/IA | **EC** | Le MCD et le MLD cibles sont validés. Le schéma PostgreSQL cible a été créé et la migration exécutée. La preuve demandée par la grille comprend toutefois aussi l'optimisation documentée. | `02-modele-cible/mcd-cible-final-propre.drawio.png`, `02-modele-cible/mld-cible-final.md`, `02-modele-cible/migration-final.sql`. Reste : note d'indexation avec `EXPLAIN` avant/après. |
| Schématiser/concevoir un programme d'IA | **NA** | Le programme d'IA n'est pas encore conçu sous la forme attendue par la grille. | À produire : schéma IA avec entrées, traitements et sorties. |

### BC01 --- Stratégie SI

| Compétence | Statut | Justification au 06/09/2026 | Preuve / reste à produire |
| --- | --- | --- | --- |
| Cartographier le SI (analyse de risques) | **A** | L'existant a été audité, cartographié et contrôlé. Les anomalies ont été identifiées et tracées, puis la Phase 1 a été validée. | `01-audit/` : analyse, cartographies, registre d'anomalies, requêtes et preuves. |
| Élaborer la stratégie SI | **EC** | Les besoins, la cible de données et les axes d'évolution sont structurés, mais la note stratégique dédiée demandée par la grille n'est pas encore finalisée. | Éléments déjà présents en Phase 2. Reste : note stratégique synthétique. |
| Comparer les architectures | **NA** | La comparaison formalisée des architectures de croissance n'a pas encore été réalisée. | À produire en Phase 3 : dossier d'architecture. |
| Analyser les composants d'architecture | **NA** | Le schéma de composants cible n'est pas encore produit comme preuve dédiée. | À produire en Phase 3. |
| Arbitrer performance / scalabilité / sécurité / éco-conception | **NA** | Des réflexions existent, notamment sur l'éco-conception, mais les arbitrages d'architecture ne sont pas encore consolidés dans une matrice de décision appliquée au projet. | À produire : matrice de décision argumentée. |
| Présenter des solutions écoresponsables | **EC** | La note d'éco-conception du projet est désormais produite et contrôlée. La preuve écrite existe, mais la compétence comprend également la capacité à défendre ces préconisations. | `02-modele-cible/note-eco-conception.md`. Reste : défense lors de la soutenance. |

### BC02 --- Piloter des projets

| Compétence | Statut | Justification au 06/09/2026 | Preuve / reste à produire |
| --- | --- | --- | --- |
| Étude d'opportunité | **A** | L'étude d'opportunité est produite, contrôlée et figée dans Git. | `02-modele-cible/etude-opportunite.md` — commit `19f674e`. |
| Prioriser les fonctionnalités | **A** | Le backlog fonctionnel priorisé est produit et contrôlé. | `02-modele-cible/backlog-priorise.md` — commit `7380d91`. |
| CDC technique (RGPD + PSH) | **EC** | Le cahier des charges technique est produit et validé comme référence de Phase 2. Le registre RGPD est désormais produit. La preuve d'accessibilité PSH manque encore. | `02-modele-cible/cahier-des-charges-technique-MAJ.md`, `02-modele-cible/registre-rgpd.md`. Reste : note d'accessibilité PSH. |
| Modéliser les processus métier | **A** | Le processus métier principal a été formalisé en BPMN à partir du parcours métier validé. | `02-modele-cible/processus-metier.bpmn`, `02-modele-cible/processus-metier.png` — commit `5752e97`. |
| Note de cadrage | **A** | La note couvre désormais le contexte, les objectifs, le périmètre et hors-périmètre, les livrables, les parties prenantes, le planning, les ressources, les risques et les critères de réussite. Son contenu et ses références ont été contrôlés le 06/09/2026. | `02-modele-cible/note-cadrage.md`. |
| Planifier | **A** | Le Gantt couvre le projet, distingue les travaux réalisés et futurs, et suit les jalons et dépendances jusqu'au rendu final. | `planning-projet_chasse_immo.gan`. |
| Mitigation des risques | **NA** | Des risques sont déjà identifiés dans les travaux existants, mais la preuve complète demandée n'est pas encore produite. | À produire : matrice des risques + PCA/PRA. |
| Engagement des parties prenantes | **EC** | Le RACI adapté au projet individuel est produit. Les responsabilités sont identifiées, mais des traces réelles d'échanges ou de validations restent à consolider. | `02-modele-cible/RACI.md` — commit `54cd765`. |

### BC03 --- Concevoir & développer

| Compétence | Statut | Justification au 06/09/2026 | Preuve / reste à produire |
| --- | --- | --- | --- |
| Architecture applicative + maquettes | **NA** | L'architecture applicative détaillée et les maquettes ne sont pas encore produites. | À produire : dossier de conception + maquettes. |
| Schématiser les processus métier | **A** | Le processus métier principal est représenté dans un schéma BPMN complet. | `02-modele-cible/processus-metier.bpmn`, `02-modele-cible/processus-metier.png` — commit `5752e97`. |
| Environnement + réduction d'impact éco | **EC** | Une politique d'éco-conception est désormais documentée, mais l'environnement technique cible complet n'est pas encore finalisé. | `02-modele-cible/note-eco-conception.md`. Reste : environnement cible en Phase 3-4. |
| Justifier les patterns | **NA** | L'architecture applicative n'étant pas encore conçue, les patterns ne peuvent pas encore être justifiés. | À produire en Phase 4. |
| Sécurité applicative | **NA** | Le développement applicatif cible n'est pas encore réalisé. | À produire : code + note sécurité. |
| Scénarios de tests exécutés | **EC** | Des contrôles SQL et des validations de migration/reprise ont été exécutés, mais le plan de tests applicatif unitaire et fonctionnel demandé par BC03 n'est pas encore réalisé. | Preuves SQL existantes. Reste : plan de tests + rapports d'exécution. |
| Suivi qualité automatisé | **NA** | Aucun pipeline CI avec indicateurs de qualité n'est encore produit pour l'application cible. | À produire en Phase 4. |

### Transverses

| Exigence | Statut | Justification au 06/09/2026 | Preuve / reste à produire |
| --- | --- | --- | --- |
| RGPD | **A** | Le registre de traitement RGPD du projet est produit, contextualisé et contrôlé. | `02-modele-cible/registre-rgpd.md`. |
| Éco-conception | **A** | La note dédiée au projet est produite et contrôlée. Elle documente notamment l'arbitrage de la stratégie de sauvegarde. | `02-modele-cible/note-eco-conception.md`. |
| Accessibilité PSH | **NA** | La note dédiée n'est pas encore produite. | À produire avec le CDC et la conception applicative. |
| Souveraineté / sécurité IA | **NA** | Le volet IA n'étant pas encore conçu, la note dédiée n'est pas encore produite. | À produire dans une phase ultérieure. |

------------------------------------------------------------------------

## 3. Synthèse d'avancement au 06/09/2026

Cette auto-évaluation est volontairement prudente :

- **A** signifie qu'une preuve directement exploitable et défendable existe ;
- **EC** signifie que le travail est engagé mais qu'une partie de la preuve attendue manque encore ;
- **NA** signifie que la compétence ou sa preuve principale n'est pas encore abordée.

| Bloc | A | EC | NA | Lecture |
| --- | ---: | ---: | ---: | --- |
| **BC05** | 0 | 2 | 3 | Socle de données cible avancé ; OLAP, indexation complète et IA restent à construire. |
| **BC01** | 1 | 2 | 3 | Audit acquis ; stratégie et architecture de croissance restent à poursuivre. |
| **BC02** | 5 | 2 | 1 | Opportunité, backlog, BPMN, cadrage et planification acquis ; PSH, risques et engagement restent à compléter. |
| **BC03** | 1 | 2 | 4 | Processus métier acquis ; éco-conception et premiers contrôles existent, mais la phase applicative reste largement à produire. |
| **Transverses** | 2 | 0 | 2 | RGPD et éco-conception acquis ; accessibilité PSH et souveraineté/sécurité IA restent à produire. |

**Total : 9 compétences/exigences classées A, 8 EC et 13 NA.**

Ce résultat ne signifie pas que le projet est terminé. Il représente uniquement les preuves effectivement disponibles et défendables au 06/09/2026.

La matrice détaillée permettant de relier les compétences aux livrables est disponible dans :

`02-modele-cible/TRACABILITE-COMPETENCES.md`

------------------------------------------------------------------------

## 4. Prochaines acquisitions prioritaires

La Phase 2 dispose désormais de plusieurs preuves consolidées : étude d'opportunité, backlog, BPMN, RACI, note de cadrage, registre RGPD, note d'éco-conception et traçabilité des compétences.

La priorité immédiate est maintenant de produire la preuve d'accessibilité PSH, puis de contrôler les derniers livrables nécessaires avant la validation complète de la Phase 2.

La compétence **BC05 — Concevoir la base pour analytique/IA** reste **EC** tant que la preuve d'indexation avec `EXPLAIN` avant/après n'est pas produite.

La compétence **BC02 — CDC technique (RGPD + PSH)** reste **EC** : le registre RGPD est désormais disponible, mais la preuve d'accessibilité PSH reste à produire.

Les travaux d'architecture, 3V, OLAP, PCA/PRA, matching IA, conception applicative, développement et tests seront acquis uniquement lorsque leurs preuves spécifiques auront été réalisées et contrôlées.

------------------------------------------------------------------------

## 5. Travail individuel et soutenance

Le Starter Pack est formulé pour un travail en groupe, mais ce dépôt
correspond à une réalisation individuelle. La règle de soutenance reste
la même sur le fond : l'intégralité des choix, livrables, scripts,
modèles et arbitrages présentés doit pouvoir être expliquée et défendue
individuellement devant le jury.

------------------------------------------------------------------------

## 6. Mise à jour de l'auto-évaluation au 09/09/2026

> Cette section constitue un nouveau repère temporel.
>
> Elle ne remplace pas l'état du 06/09/2026 présenté précédemment.
> L'état antérieur est volontairement conservé afin de montrer la progression
> réelle du projet et l'apparition progressive des preuves.
>
> Cotation inchangée :
>
> - **NA** = non abordé ou preuve principale absente ;
> - **EC** = en cours ou preuve encore incomplète ;
> - **A** = acquis avec une preuve produite et défendable.

Depuis l'évaluation du 06/09/2026, plusieurs travaux de Phase 3 ont été
réalisés, expérimentés et documentés.

La nouvelle évaluation est établie uniquement à partir des preuves réellement
présentes dans le dépôt au 09/09/2026.

### BC05 --- Big data & IA

| Compétence | Statut au 06/09 | Statut au 09/09 | Justification au 09/09/2026 | Preuve principale |
| --- | --- | --- | --- | --- |
| Analyser 3V (volume, vélocité, variété) | **NA** | **A** | L'analyse 3V est désormais produite, chiffrée et reliée aux hypothèses de croissance du Starter Pack. | `03-architecture/note-dimensionnement-3v.md` |
| Concevoir/évaluer un modèle ML | **NA** | **NA** | Le modèle de matching IA et ses features ne sont pas encore formalisés. | À produire dans la phase IA. |
| Extraction/transformation/chargement + qualité + RGPD | **EC** | **A** | La reprise transactionnelle est validée, le registre RGPD existe, l'OLAP et son ETL sont produits et les contrôles de qualité analytique sont désormais formalisés. | `02-modele-cible/reprise-donnees-validation.md`, `02-modele-cible/registre-rgpd.md`, `03-architecture/sql/olap-etl.sql`, `03-architecture/oltp-olap-modele-decisionnel.md` |
| Concevoir la base pour analytique/IA | **EC** | **A** | Le modèle relationnel cible, le schéma analytique, l'alimentation OLAP et la preuve d'optimisation avec `EXPLAIN ANALYZE` sont produits. | `02-modele-cible/mld-cible-final.md`, `03-architecture/olap-schema.svg`, `03-architecture/sql/olap-schema.sql`, `03-architecture/benchmark-indexation.md` |
| Schématiser/concevoir un programme d'IA | **NA** | **NA** | Le programme IA avec entrées, traitements et sorties n'est pas encore conçu. | À produire dans la phase IA. |

### Lecture BC05 au 09/09/2026

```text
3V
→ acquis

ETL + qualité + RGPD
→ acquis

base analytique + optimisation
→ acquis

matching ML
→ à produire

programme IA
→ à produire
```

La partie **Data / Big Data / analytique** de BC05 est donc maintenant fortement
documentée.

La partie **IA / modèle de matching** reste volontairement non déclarée comme
acquise.

---

### BC01 --- Stratégie SI

| Compétence | Statut au 06/09 | Statut au 09/09 | Justification au 09/09/2026 | Preuve principale |
| --- | --- | --- | --- | --- |
| Cartographier le SI (analyse de risques) | **A** | **A** | L'audit, les cartographies, les anomalies et les preuves de Phase 1 restent validés. | `01-audit/` |
| Élaborer la stratégie SI | **EC** | **EC** | Les axes stratégiques existent dans plusieurs documents, mais la note stratégique synthétique identifiée par la grille n'est pas encore constituée comme preuve dédiée. | Besoins, cadrage et architecture existants. |
| Comparer les architectures | **NA** | **A** | Plusieurs solutions de croissance sont désormais comparées avec avantages, limites et critères de décision. | `03-architecture/dossier-architecture-de-croissance.md`, `03-architecture/matrice-décision-architecture.md` |
| Analyser les composants d'architecture | **NA** | **A** | Le dossier d'architecture décrit les composants OLTP, OLAP, ETL, réplication, stockage, IA future et Citus ainsi que leurs interactions. | `03-architecture/dossier-architecture-de-croissance.md` |
| Arbitrer performance / scalabilité / sécurité / éco-conception | **NA** | **A** | Les arbitrages reposent maintenant sur une matrice de décision, des benchmarks, une matrice de risques et l'éco-conception. | `03-architecture/matrice-décision-architecture.md`, `03-architecture/matrice-risques.md`, benchmarks Phase 3 |
| Présenter des solutions écoresponsables | **EC** | **EC** | Les préconisations et arbitrages sont documentés et renforcés par les mesures de Phase 3. La défense orale reste à démontrer lors de la soutenance. | `02-modele-cible/note-eco-conception.md` |

### Décision d'architecture démontrée

La Phase 3 a permis de formaliser la progression suivante :

```text
PostgreSQL
↓
mesurer
↓
indexer
↓
partitionner lorsque nécessaire
↓
répliquer lorsque la disponibilité l'exige
↓
distribuer avec Citus uniquement si les volumes le justifient
```

Le principe retenu reste :

> **Mesurer avant de complexifier.**

---

### BC02 --- Piloter des projets

| Compétence | Statut au 06/09 | Statut au 09/09 | Justification au 09/09/2026 | Preuve principale |
| --- | --- | --- | --- | --- |
| Étude d'opportunité | **A** | **A** | Preuve déjà validée. | `02-modele-cible/etude-opportunite.md` |
| Prioriser les fonctionnalités | **A** | **A** | Le backlog priorisé reste la preuve de référence. | `02-modele-cible/backlog-priorise.md` |
| CDC technique (RGPD + PSH) | **EC** | **EC** | Le CDC et le RGPD sont produits mais la preuve dédiée à l'accessibilité PSH manque encore. | `02-modele-cible/cahier-des-charges-technique-MAJ.md`, `02-modele-cible/registre-rgpd.md` |
| Modéliser les processus métier | **A** | **A** | Le BPMN reste produit et défendable. | `02-modele-cible/processus-metier.bpmn`, `02-modele-cible/processus-metier.png` |
| Note de cadrage | **A** | **A** | La note couvre le pilotage et le périmètre du projet. | `02-modele-cible/note-cadrage.md` |
| Planifier | **A** | **A** | Le planning Gantt reste la preuve de planification. | `planning-projet_chasse_immo.gan` |
| Mitigation des risques | **NA** | **A** | La matrice des risques, le PCA/PRA testé au niveau POC et le plan de migration couvrent désormais cette compétence. | `03-architecture/matrice-risques.md`, `03-architecture/pca-pra-complet-maj.md`, `03-architecture/plan-migration.md` |
| Engagement des parties prenantes | **EC** | **EC** | Le RACI est produit mais les preuves réelles d'interactions et validations restent à consolider. | `02-modele-cible/RACI.md` |

### Évolution importante

Au 06/09/2026 :

```text
mitigation des risques
→ NA
```

Au 09/09/2026 :

```text
matrice des risques
+
POC haute disponibilité
+
PCA / PRA
+
restauration distante
+
plan de migration
=
preuve désormais produite
```

---

### BC03 --- Concevoir & développer

| Compétence | Statut au 06/09 | Statut au 09/09 | Justification au 09/09/2026 | Preuve principale |
| --- | --- | --- | --- | --- |
| Architecture applicative + maquettes | **NA** | **NA** | La Phase 3 porte sur l'architecture SI et données, pas encore sur la conception détaillée de l'application. | Phase applicative ultérieure. |
| Schématiser les processus métier | **A** | **A** | Le BPMN reste produit et validé. | `02-modele-cible/processus-metier.bpmn`, `02-modele-cible/processus-metier.png` |
| Environnement + réduction d'impact éco | **EC** | **EC** | Les choix d'éco-conception et plusieurs composants d'infrastructure sont définis, mais l'environnement applicatif complet n'est pas encore finalisé. | `02-modele-cible/note-eco-conception.md`, documents Phase 3 |
| Justifier les patterns | **NA** | **NA** | Les patterns applicatifs seront justifiés lors de la conception de l'application. | Phase applicative ultérieure. |
| Sécurité applicative | **NA** | **NA** | Le développement applicatif cible n'est pas encore réalisé. | Phase applicative ultérieure. |
| Scénarios de tests exécutés | **EC** | **EC** | De nombreux tests techniques SQL, performance, HA et PRA existent, mais le plan de tests applicatif demandé par BC03 reste à produire. | Benchmarks et POC Phase 3 ; tests applicatifs à venir. |
| Suivi qualité automatisé | **NA** | **NA** | Aucun pipeline CI applicatif complet avec indicateurs de qualité n'est encore produit. | Phase applicative ultérieure. |

La Phase 3 améliore fortement les preuves techniques, mais elle ne doit pas
être utilisée pour déclarer prématurément acquises les compétences
spécifiquement applicatives de BC03.

---

### Exigences transverses

| Exigence | Statut au 06/09 | Statut au 09/09 | Justification |
| --- | --- | --- | --- |
| RGPD | **A** | **A** | Le registre RGPD reste produit et contextualisé. |
| Éco-conception | **A** | **A** | La note d'éco-conception est produite et a été mise en cohérence avec les résultats de Phase 3. |
| Accessibilité PSH | **NA** | **NA** | La preuve dédiée reste à produire. |
| Souveraineté / sécurité IA | **NA** | **NA** | Cette preuve sera traitée avec la conception du volet IA. |

---

## 6.1 Synthèse chiffrée de l'évolution

### État du 06/09/2026

| Bloc | A | EC | NA |
| --- | ---: | ---: | ---: |
| BC05 | 0 | 2 | 3 |
| BC01 | 1 | 2 | 3 |
| BC02 | 5 | 2 | 1 |
| BC03 | 1 | 2 | 4 |
| Transverses | 2 | 0 | 2 |
| **Total** | **9** | **8** | **13** |

### État au 09/09/2026

| Bloc | A | EC | NA |
| --- | ---: | ---: | ---: |
| BC05 | 3 | 0 | 2 |
| BC01 | 4 | 2 | 0 |
| BC02 | 6 | 2 | 0 |
| BC03 | 1 | 2 | 4 |
| Transverses | 2 | 0 | 2 |
| **Total** | **16** | **6** | **8** |

La progression est donc :

```text
A
9 → 16

EC
8 → 6

NA
13 → 8
```

Cette évolution ne résulte pas d'un changement de méthode de notation.

Elle correspond à l'apparition de nouvelles preuves entre le 06/09 et le
09/09/2026.

---

## 6.2 Principales preuves acquises depuis le 06/09/2026

Les évolutions principales sont :

```text
3V
→ produit

architecture de croissance
→ produite

comparaison des architectures
→ produite

schéma de composants
→ produit

matrice de décision
→ produite

benchmark indexation
→ exécuté et documenté

benchmark partitionnement
→ exécuté et documenté

réplication / haute disponibilité
→ testée au niveau POC

Citus / sharding
→ testé et positionné comme option future

OLTP / OLAP
→ conçu et documenté

ETL
→ produit

qualité analytique
→ formalisée

matrice de risques
→ produite

PCA / PRA
→ testé au niveau POC

plan de migration
→ produit
```

---

## 6.3 Compétences restant prioritaires

Au 09/09/2026, les principaux manques ne concernent plus le cœur de
l'architecture de croissance de Phase 3.

Ils concernent surtout les phases suivantes :

1. accessibilité PSH ;
2. modèle de matching et features ;
3. programme IA ;
4. souveraineté et sécurité IA ;
5. architecture applicative ;
6. maquettes ;
7. patterns logiciels ;
8. sécurité applicative ;
9. plan de tests applicatif ;
10. pipeline CI et suivi qualité.

La note stratégique synthétique BC01 et les preuves d'engagement réel des
parties prenantes restent également à consolider.

---

## 6.4 Conclusion au 09/09/2026

L'état du projet a sensiblement évolué depuis l'auto-évaluation du 06/09/2026.

La Phase 3 a transformé plusieurs éléments qui étaient encore théoriques ou
absents en preuves concrètes :

```text
hypothèses
→ architecture

architecture
→ expérimentations

expérimentations
→ mesures

mesures
→ décisions

décisions
→ risques et continuité

continuité
→ tests de reprise

reprise
→ stratégie de migration
```

La Phase 3 peut désormais être auditée sur la base de livrables et de preuves
techniques réelles.

Les statuts historiques du 06/09/2026 restent volontairement conservés afin que
le document montre l'évolution du projet au lieu d'effacer son historique.

---

## 7. Mise à jour de l'auto-évaluation au 12/09/2026

> Cette section constitue un nouveau repère temporel.
>
> Elle complète les états du 06/09/2026 et du 09/09/2026 sans les supprimer.
>
> Cotation inchangée :
>
> - **NA** = non abordé ou preuve principale absente ;
> - **EC** = en cours ou preuve encore incomplète ;
> - **A** = acquis avec une preuve produite, vérifiable et défendable.

Depuis le jalon du 09/09/2026, la Phase 4 applicative et IA a été réalisée et plusieurs preuves transverses ont été consolidées.

La présente évaluation repose uniquement sur les éléments réellement présents et testés dans le dépôt au 12/09/2026.

### BC05 --- Big data & IA

| Compétence | Statut au 09/09 | Statut au 12/09 | Justification au 12/09/2026 | Preuve principale |
| --- | --- | --- | --- | --- |
| Analyser 3V (volume, vélocité, variété) | **A** | **A** | L'analyse 3V reste produite, chiffrée et reliée aux choix d'architecture. | `03-architecture/note-dimensionnement-3v.md` |
| Concevoir/évaluer un modèle de matching | **NA** | **A** | Le projet n'entraîne pas de modèle de Machine Learning. Le démonstrateur utilise un scoring déterministe, explicable et reproductible avec six features, pondérations documentées et tests automatisés. | `04-application-ia/matching-features.md`, `04-application-ia/backend/app/matching.py`, `04-application-ia/backend/tests/test_matching.py` |
| Extraction/transformation/chargement + qualité + RGPD | **A** | **A** | La reprise historique, l'alimentation OLAP, les contrôles qualité et les règles RGPD disposent de preuves dédiées. | `02-modele-cible/reprise-donnees-validation.md`, `03-architecture/sql/olap-etl.sql`, `02-modele-cible/registre-rgpd.md` |
| Concevoir la base pour analytique/IA | **A** | **A** | Les modèles OLTP et OLAP, l'alimentation analytique et les preuves d'optimisation sont produits. | `03-architecture/olap-schema.svg`, `03-architecture/sql/olap-schema.sql`, `03-architecture/benchmark-indexation.md` |
| Schématiser/concevoir un programme d'IA | **NA** | **A** | Les entrées, traitements, sorties, règles de sécurité et validation humaine du programme IA sont désormais décrits et schématisés. | `04-application-ia/programme-ia.md`, `04-application-ia/programme-ia.png` |

### BC01 --- Stratégie SI

| Compétence | Statut au 09/09 | Statut au 12/09 | Justification au 12/09/2026 | Preuve principale |
| --- | --- | --- | --- | --- |
| Cartographier le SI (analyse de risques) | **A** | **A** | L'audit et les cartographies restent validés. | `01-audit/` |
| Élaborer la stratégie SI | **EC** | **A** | Une note stratégique SI dédiée consolide désormais les constats, objectifs et axes d'évolution. | `02-modele-cible/note-strategique-si.md` |
| Comparer les architectures | **A** | **A** | Les architectures de croissance ont été comparées et expérimentées. | `03-architecture/dossier-architecture-de-croissance.md`, `03-architecture/matrice-décision-architecture.md` |
| Analyser les composants d'architecture | **A** | **A** | Les composants OLTP, OLAP, réplication, sauvegarde, ETL et distribution sont analysés avec leurs interactions. | `03-architecture/dossier-architecture-de-croissance.md` |
| Arbitrer performance / scalabilité / sécurité / éco-conception | **A** | **A** | Les arbitrages reposent sur des benchmarks, une matrice de décision, une matrice de risques et les principes d'éco-conception. | `03-architecture/matrice-décision-architecture.md`, `03-architecture/matrice-risques.md` |
| Présenter des solutions écoresponsables | **EC** | **A** | Les préconisations SI et d'éco-conception sont désormais consolidées et reliées aux choix techniques réels. L'oral constituera une preuve complémentaire de présentation. | `02-modele-cible/note-eco-conception.md`, `02-modele-cible/note-strategique-si.md` |

### BC02 --- Piloter des projets

| Compétence | Statut au 09/09 | Statut au 12/09 | Justification au 12/09/2026 | Preuve principale |
| --- | --- | --- | --- | --- |
| Étude d'opportunité | **A** | **A** | Preuve déjà produite et validée. | `02-modele-cible/etude-opportunite.md` |
| Prioriser les fonctionnalités | **A** | **A** | Le backlog priorisé reste la preuve de référence. | `02-modele-cible/backlog-priorise.md` |
| CDC technique (RGPD + PSH) | **EC** | **A** | Le CDC, le registre RGPD et la note dédiée à l'accessibilité PSH sont désormais produits. | `02-modele-cible/cahier-des-charges-technique-MAJ.md`, `02-modele-cible/registre-rgpd.md`, `02-modele-cible/note-accessibilite-psh.md` |
| Modéliser les processus métier | **A** | **A** | Le processus métier principal reste formalisé en BPMN. | `02-modele-cible/processus-metier.bpmn`, `02-modele-cible/processus-metier.png` |
| Note de cadrage | **A** | **A** | La note couvre le périmètre, les objectifs, risques, acteurs, planning et critères de réussite. | `02-modele-cible/note-cadrage.md` |
| Planifier | **A** | **EC** | Le Gantt existe et structure le projet, mais son suivi reste actif jusqu'à la clôture du projet. | `planning-projet_chasse_immo.gan` |
| Mitigation des risques | **A** | **A** | La matrice de risques, le PCA/PRA et le plan de migration couvrent la gestion et la réduction des risques. | `03-architecture/matrice-risques.md`, `03-architecture/pca-pra-complet-maj.md`, `03-architecture/plan-migration.md` |
| Engagement des parties prenantes | **EC** | **EC** | Les responsabilités sont formalisées, mais aucune interaction externe ne doit être inventée. Une preuve réelle d'échange ou de validation reste nécessaire. | `02-modele-cible/RACI.md`, `decisions/journal-decisions-MAJ-2026-09-05.md` |

### BC03 --- Concevoir & développer

| Compétence | Statut au 09/09 | Statut au 12/09 | Justification au 12/09/2026 | Preuve principale |
| --- | --- | --- | --- | --- |
| Architecture applicative + maquettes | **NA** | **A** | Une architecture applicative et des maquettes des principaux parcours sont désormais produites. | `04-application-ia/architecture-applicative.md`, `04-application-ia/maquettes.html` |
| Schématiser les processus métier | **A** | **A** | Le BPMN reste produit et défendable. | `02-modele-cible/processus-metier.bpmn`, `02-modele-cible/processus-metier.png` |
| Environnement + réduction d'impact éco | **EC** | **A** | L'environnement applicatif s'inscrit dans une architecture progressive et proportionnée, cohérente avec la note d'éco-conception. | `04-application-ia/architecture-applicative.md`, `02-modele-cible/note-eco-conception.md` |
| Justifier les patterns | **NA** | **A** | L'architecture en couches, la séparation des responsabilités et le monolithe modulaire sont décrits et justifiés. | `04-application-ia/architecture-applicative.md` |
| Sécurité applicative | **NA** | **A** | Le backend applique la validation des entrées, une gestion contrôlée des erreurs, la minimisation des données IA et la validation humaine. Ces comportements sont testés. | `04-application-ia/backend/tests/test_api_security.py`, `04-application-ia/backend/tests/test_chasseur_ai_security.py` |
| Scénarios de tests exécutés | **EC** | **A** | Le plan de tests est produit et exécuté. La suite standard obtient `47 passed, 5 skipped` et les 5 tests d'intégration PostgreSQL passent explicitement. | `04-application-ia/plan-de-tests.md`, `04-application-ia/backend/tests/` |
| Suivi qualité automatisé | **NA** | **A** | Une CI GitHub Actions exécute automatiquement Ruff et pytest sur la branche `develop`. Le pipeline est opérationnel et validé. | `.github/workflows/phase4-backend.yml`, `04-application-ia/backend/ruff.toml` |

### Exigences transverses

| Exigence | Statut au 09/09 | Statut au 12/09 | Justification | Preuve principale |
| --- | --- | --- | --- | --- |
| RGPD | **A** | **A** | Le registre RGPD est complété par des contrôles techniques de minimisation des données dans le backend. | `02-modele-cible/registre-rgpd.md`, `04-application-ia/backend/tests/test_chasseur_ai_security.py` |
| Éco-conception | **A** | **A** | Les principes sont intégrés aux choix d'architecture et de dimensionnement. | `02-modele-cible/note-eco-conception.md` |
| Accessibilité PSH | **NA** | **A** | Une note dédiée est produite et les principes sont intégrés à la conception et aux maquettes. L'acquisition porte sur le niveau de conception, pas sur une déclaration de conformité complète de l'interface. | `02-modele-cible/note-accessibilite-psh.md` |
| Souveraineté / sécurité IA | **NA** | **A** | Une note dédiée et des contrôles techniques encadrent l'accès aux données, leur minimisation et le rôle de la validation humaine. | `02-modele-cible/note-souverainete-securite-ia.md`, `04-application-ia/backend/tests/test_chasseur_ai_security.py` |

---

## 7.1 Synthèse chiffrée au 12/09/2026

| Bloc | A | EC | NA |
| --- | ---: | ---: | ---: |
| BC05 | 5 | 0 | 0 |
| BC01 | 6 | 0 | 0 |
| BC02 | 6 | 2 | 0 |
| BC03 | 7 | 0 | 0 |
| Transverses | 4 | 0 | 0 |
| **Total** | **28** | **2** | **0** |

L'évolution globale est donc :

    06/09/2026
    9 A / 8 EC / 13 NA

    09/09/2026
    16 A / 6 EC / 8 NA

    12/09/2026
    28 A / 2 EC / 0 NA

Cette progression correspond à la production de nouvelles preuves. Elle ne résulte pas d'un assouplissement de la méthode d'évaluation.

---

## 7.2 Éléments restant réellement ouverts

Deux compétences restent volontairement classées **EC** :

1. **Planification du projet**
   - le planning existe ;
   - les jalons sont structurés ;
   - son suivi doit continuer jusqu'à la clôture du projet.

2. **Engagement des parties prenantes**
   - le RACI existe ;
   - les responsabilités sont formalisées ;
   - une preuve réelle d'interaction, de retour ou de validation externe reste à conserver.

Aucune interaction externe ne doit être inventée pour transformer artificiellement cette compétence en **A**.

Les autres compétences disposent désormais de preuves produites et défendables dans le périmètre du projet.

---

## 7.3 Repère d'avancement

Au 09/09/2026, les principaux éléments encore manquants concernaient la Phase 4 applicative et IA.

Au 12/09/2026, sont désormais produits et contrôlés :

- le modèle de matching ;
- les features et pondérations ;
- le programme IA ;
- l'architecture applicative ;
- les maquettes ;
- les patterns logiciels ;
- le backend démonstrateur ;
- la faisabilité ;
- le chasseur-IA ;
- la validation humaine ;
- la sécurité applicative ;
- les tests unitaires et fonctionnels ;
- les tests d'intégration PostgreSQL ;
- le pipeline CI ;
- l'accessibilité PSH au niveau conception ;
- la souveraineté et la sécurité IA ;
- la note stratégique SI.

Le projet entre donc dans une phase de clôture documentaire, de mise à jour du pilotage et de préparation de la soutenance.
