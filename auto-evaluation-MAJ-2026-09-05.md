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
