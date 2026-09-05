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
  (`migration.sql`,       transactionnels         
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

> **État au 05/09/2026.** Cotation : **NA** = non abordé · **EC** = en
> cours ou preuve encore incomplète · **A** = acquis, avec preuve
> produite et défendable.
>
> Principe retenu : une compétence n'est pas classée **A** uniquement
> parce qu'une partie du travail existe. Toutes les preuves essentielles
> demandées par la grille doivent être suffisamment produites et
> défendables.

### BC05 --- Big data & IA (bloc cible)

  ---------------------------------------------------------------------------------------------------------------------------------------
  Compétence                               Statut            Justification au  Preuve / reste à produire
                                                             05/09/2026        
  ---------------------------------------- ----------------- ----------------- ----------------------------------------------------------
  Analyser 3V (volume, vélocité, variété)  **NA**            L'analyse         À produire : note de dimensionnement 3V.
                                                             chiffrée des 3V   
                                                             n'a pas encore    
                                                             été produite.     

  Concevoir/évaluer un modèle ML           **NA**            La conception du  À produire : conception matching + features.
                                                             modèle de         
                                                             matching et de    
                                                             ses features      
                                                             n'est pas encore  
                                                             formalisée.       

  Extraction/transformation/chargement +   **EC**            Une reprise       `02-modele-cible/reprise-donnees-final.sql` +
  qualité + RGPD                                             réelle des        `02-modele-cible/preuves/reprise-donnees-validation.md`.
                                                             données a été     Reste : OLAP + qualité consolidée + RGPD.
                                                             conçue et         
                                                             exécutée : 18     
                                                             mandats source, 2 
                                                             rejets justifiés, 
                                                             16 migrés et 5    
                                                             corrections de    
                                                             statut parmi les  
                                                             6 anomalies A-02, 
                                                             le sixième mandat 
                                                             étant rejeté pour 
                                                             l'anomalie A-03.  
                                                             La preuve de      
                                                             validation de     
                                                             reprise est       
                                                             produite. En      
                                                             revanche, le      
                                                             schéma OLAP,      
                                                             l'alimentation    
                                                             analytique et le  
                                                             volet RGPD        
                                                             complet restent à 
                                                             produire.         

  Concevoir la base pour analytique/IA     **EC**            Le MCD cible est  `02-modele-cible/mcd-cible.png`,
                                                             validé, le MLD    `02-modele-cible/mld-cible.md`,
                                                             est validé, le    `02-modele-cible/migration-final.sql`. Reste : note
                                                             schéma PostgreSQL d'indexation avec `EXPLAIN` avant/après.
                                                             cible a été créé  
                                                             et la migration a 
                                                             été exécutée. La  
                                                             preuve attendue   
                                                             par la grille     
                                                             comprend          
                                                             toutefois aussi   
                                                             l'indexation      
                                                             documentée.       

  Schématiser/concevoir un programme d'IA  **NA**            Le programme d'IA À produire : schéma IA avec entrées, traitements et
                                                             n'est pas encore  sorties.
                                                             conçu sous la     
                                                             forme attendue    
                                                             par la grille.    
  ---------------------------------------------------------------------------------------------------------------------------------------

### BC01 --- Stratégie SI

  -----------------------------------------------------------------------------------------
  Compétence                      Statut            Justification au   Preuve / reste à
                                                    05/09/2026         produire
  ------------------------------- ----------------- ------------------ --------------------
  Cartographier le SI (analyse de **A**             L'existant a été   `01-audit/` :
  risques)                                          audité,            analyse,
                                                    cartographié et    cartographies,
                                                    contrôlé. Les      registre
                                                    anomalies ont été  d'anomalies,
                                                    identifiées et     requêtes et preuves.
                                                    tracées, puis la   
                                                    Phase 1 a été      
                                                    validée.           

  Élaborer la stratégie SI        **EC**            Les besoins,       Éléments déjà
                                                    règles de gestion  présents dans la
                                                    et cible de        Phase 2. Reste :
                                                    données sont       note stratégique
                                                    désormais          synthétique.
                                                    structurés, mais   
                                                    la note            
                                                    stratégique dédiée 
                                                    demandée par la    
                                                    grille n'est pas   
                                                    encore finalisée.  

  Comparer les architectures      **NA**            La comparaison     À produire en Phase
                                                    formalisée des     3 : dossier
                                                    architectures de   d'architecture.
                                                    croissance n'a pas 
                                                    encore été         
                                                    réalisée.          

  Analyser les composants         **NA**            Le schéma de       À produire en Phase
  d'architecture                                    composants cible   3.
                                                    n'est pas encore   
                                                    produit comme      
                                                    preuve dédiée.     

  Arbitrer                        **NA**            Les arbitrages ne  À produire : matrice
  perf/scalabilité/sécurité/éco                     sont pas encore    de décision
                                                    consolidés dans    argumentée.
                                                    une matrice de     
                                                    décision appliquée 
                                                    au projet.         

  Présenter des solutions         **NA**            La note            À produire : note
  écoresponsables                                   d'éco-conception   d'éco-conception +
                                                    du projet n'est    capacité à la
                                                    pas encore         défendre à l'oral.
                                                    produite.          
  -----------------------------------------------------------------------------------------

### BC02 --- Piloter des projets

  ------------------------------------------------------------------------------------------------------------------
  Compétence        Statut            Justification au  Preuve / reste à produire
                                      05/09/2026        
  ----------------- ----------------- ----------------- ------------------------------------------------------------
  Étude             **A**             Étude             `02-modele-cible/etude-opportunite.md`.
  d'opportunité                       d'opportunité      Document produit, contrôlé et figé dans Git
                                      produite et        le 05/09/2026 (commit `19f674e`).
                                      contrôlée le
                                      05/09/2026.

  Prioriser les     **A**             Backlog           `02-modele-cible/backlog-priorise.md`.
  fonctionnalités                     fonctionnel       Document produit, contrôlé et figé dans Git
                                      priorisé produit  le 05/09/2026 (commit `7380d91`).
                                      et contrôlé le
                                      05/09/2026.

  CDC technique     **EC**            Le cahier des     `02-modele-cible/cahier-des-charges-technique.md`. Reste :
  (RGPD + PSH)                        charges technique registre RGPD + accessibilité PSH.
                                      est produit et    
                                      validé comme      
                                      référence de      
                                      Phase 2. La       
                                      grille exige      
                                      également un      
                                      registre RGPD et  
                                      une note PSH ;    
                                      ces preuves ne    
                                      sont pas encore   
                                      finalisées.       

  Modéliser les     **A**             Le processus      `02-modele-cible/processus-metier.bpmn`
  processus métier                    métier a été      + `02-modele-cible/processus-metier.png`.
                                      formalisé en      BPMN produit, contrôlé dans Camunda
                                      BPMN à partir     et figé dans Git le 05/09/2026
                                      du parcours       (commit `5752e97`).
                                      métier validé.

  Note de cadrage   **EC**            Le cadrage a été  `02-modele-cible/note-cadrage.md` à contrôler/finaliser.
                                      travaillé en      
                                      Phase 2, mais il  
                                      doit encore être  
                                      contrôlé comme    
                                      livrable final    
                                      par rapport au    
                                      modèle officiel   
                                      avant classement  
                                      en acquis.        

  Planifier         **A**             Le Gantt couvre   `planning-projet_chasse_immo-final-coherent-05092026.gan`.
                                      l'ensemble du     
                                      projet, distingue 
                                      réalisé et futur, 
                                      comporte des      
                                      jalons et des     
                                      dépendances et    
                                      est cohérent avec 
                                      le rendu final du 
                                      31/12/2026.       

  Mitigation des    **NA**            La matrice de     À produire en Phase 3 : matrice des risques + PCA/PRA.
  risques                             risques et le     
                                      PCA/PRA appliqués 
                                      au projet ne sont 
                                      pas encore        
                                      produits.         

  Engagement des    **EC**            Le RACI projet   `02-modele-cible/RACI.md`
  parties prenantes                   adapté au projet  produit, contrôlé et figé
                                      solo est          dans Git le 05/09/2026
                                      maintenant        (commit `54cd765`).
                                      produit. Les
                                      responsabilités
                                      sont identifiées.
                                      Des traces réelles
                                      d'échanges ou de
                                      validations restent
                                      à consolider pour
                                      un passage à A.
  ------------------------------------------------------------------------------------------------------------------

### BC03 --- Concevoir & développer

  -------------------------------------------------------------------------
  Compétence        Statut            Justification au    Preuve / reste à
                                      05/09/2026          produire
  ----------------- ----------------- ------------------- -----------------
  Architecture      **NA**            La Phase 4 n'est    À produire :
  applicative +                       pas commencée.      dossier de
  maquettes                                               conception +
                                                          maquettes.

  Schématiser les   **A**             Le processus métier `02-modele-cible/processus-metier.bpmn`
  processus métier                    est représenté     + `02-modele-cible/processus-metier.png`.
                                      dans un schéma     BPMN contrôlé dans Camunda et figé
                                      BPMN complet.      dans Git le 05/09/2026
                                                         (commit `5752e97`).

  Environnement +   **NA**            L'environnement     À produire en
  réduction                           cible et son volet  Phase 3-4.
  d'impact éco                        Green IT ne sont    
                                      pas encore          
                                      documentés comme    
                                      preuve.             

  Justifier les     **NA**            L'architecture      À produire en
  patterns                            applicative n'étant Phase 4.
                                      pas encore conçue,  
                                      les patterns ne     
                                      peuvent pas encore  
                                      être justifiés.     

  Sécurité          **NA**            Le développement    À produire :
  applicative                         applicatif cible    code + note
                                      n'est pas encore    sécurité.
                                      réalisé.            

  Scénarios de      **EC**            Des contrôles SQL   Preuves SQL
  tests exécutés                      et validations de   existantes ;
                                      migration/reprise   reste : plan de
                                      ont déjà été        tests + rapports
                                      exécutés, mais le   d'exécution Phase
                                      plan de tests       4.
                                      applicatif unitaire 
                                      et fonctionnel      
                                      demandé par BC03    
                                      n'est pas encore    
                                      réalisé.            

  Suivi qualité     **NA**            Aucun pipeline CI   À produire en
  automatisé                          avec indicateurs    Phase 4.
                                      qualité n'est       
                                      encore produit pour 
                                      l'application       
                                      cible.              
  -------------------------------------------------------------------------

### Transverses

  -----------------------------------------------------------------------------
  Exigence                Statut            Justification au  Preuve / reste à
                                            05/09/2026        produire
  ----------------------- ----------------- ----------------- -----------------
  RGPD                    **EC**            Les enjeux de     Reste : registre
                                            protection des    RGPD rempli et
                                            données sont pris contextualisé.
                                            en compte dans la 
                                            conception, mais  
                                            le registre de    
                                            traitement        
                                            finalisé demandé  
                                            comme preuve      
                                            n'est pas encore  
                                            produit pour le   
                                            projet.           

  Éco-conception          **NA**            La note dédiée au À produire en
                                            projet n'est pas  Phase 3.
                                            encore produite.  

  Accessibilité PSH       **NA**            La note dédiée    À produire avec
                                            n'est pas encore  le CDC/conception
                                            produite.         applicative.

  Souveraineté/sécurité   **NA**            Le volet IA       À produire en
  IA                                        n'étant pas       Phase 4.
                                            encore conçu, la  
                                            note dédiée n'est 
                                            pas encore        
                                            produite.         
  -----------------------------------------------------------------------------

------------------------------------------------------------------------

## 3. Synthèse d'avancement au 05/09/2026

Cette auto-évaluation est volontairement prudente : **A** signifie
qu'une preuve directement exploitable et défendable existe déjà ; **EC**
signifie que le travail a commencé mais qu'une partie de la preuve
officielle manque encore.

  --------------------------------------------------------------------------------
  Bloc                            A              EC              NA Lecture
  ----------------- --------------- --------------- --------------- --------------
  **BC05**                        0               2               3 Socle de
                                                                    données cible
                                                                    avancé ;
                                                                    analytique,
                                                                    indexation et
                                                                    IA restent à
                                                                    construire.

  **BC01**                        1               1               4 Audit acquis ;
                                                                    stratégie et
                                                                    architecture
                                                                    de croissance
                                                                    à poursuivre.

  **BC02**                        4               3               1 Gantt acquis ;
                                                                    plusieurs
                                                                    livrables de
                                                                    pilotage
                                                                    restent à
                                                                    formaliser.

  **BC03**                        1               1               5 Phase
                                                                    applicative
                                                                    non commencée
                                                                    ; quelques
                                                                    fondations
                                                                    métier/tests
                                                                    SQL existent.

  **Transverses**                 0               1               3 RGPD amorcé ;
                                                                    les quatre
                                                                    preuves
                                                                    transverses
                                                                    doivent être
                                                                    consolidées.
  --------------------------------------------------------------------------------

**Total : 6 compétences/exigences classées A, 8 EC et 16 NA.**

Ce résultat ne signifie pas que le projet est « faible ». Il indique
simplement que l'auto-évaluation mesure les **preuves finales déjà
disponibles**, alors que le projet est encore en cours au 05/09/2026.

------------------------------------------------------------------------

## 4. Prochaines acquisitions prioritaires

La progression prévue dans le Gantt permet de transformer
progressivement les **NA/EC** en **A**. La priorité immédiate de Phase 2
est : étude d'opportunité → backlog priorisé → BPMN/RACI → consolidation
RGPD/éco-conception/traçabilité → validation complète de la Phase 2.

La compétence **BC05 --- Concevoir la base pour analytique/IA** pourra
passer de **EC** à **A** lorsque la preuve d'indexation demandée par la
grille sera produite et défendable. De même, **BC02 --- CDC technique**
restera **EC** tant que les preuves RGPD et PSH demandées avec le CDC ne
seront pas finalisées.

------------------------------------------------------------------------

## 5. Travail individuel et soutenance

Le Starter Pack est formulé pour un travail en groupe, mais ce dépôt
correspond à une réalisation individuelle. La règle de soutenance reste
la même sur le fond : l'intégralité des choix, livrables, scripts,
modèles et arbitrages présentés doit pouvoir être expliquée et défendue
individuellement devant le jury.
