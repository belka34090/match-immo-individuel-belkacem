# Journal des décisions — Application et IA

## ADR-014 — Retenir un monolithe modulaire pour l'application

- **Date :** 12/09/2026
- **Phase :** 4 — Application et IA
- **Statut :** accepté
- **Décideur :** Belkacem

### Contexte

La Phase 4 doit transformer les besoins métier et les modèles de données déjà
validés en une application démontrable.

L'application doit notamment prendre en charge :

- la consultation des demandes ;
- le calcul de faisabilité ;
- le matching entre demandes et biens ;
- la production d'une synthèse pour le chasseur ;
- la validation humaine ;
- l'accès aux données PostgreSQL.

L'architecture doit rester :

- compréhensible ;
- testable ;
- maintenable ;
- adaptée au périmètre réel du projet ;
- suffisamment évolutive sans introduire une complexité inutile.

### Options étudiées

#### Option 1 — Microservices

Chaque domaine applicatif pourrait être déployé dans un service indépendant.

Cette solution permet une forte indépendance entre composants, mais introduit
également :

- plusieurs services à déployer ;
- des communications réseau supplémentaires ;
- davantage de configuration ;
- davantage de supervision ;
- une gestion plus complexe des erreurs et des versions ;
- un coût d'exploitation supérieur.

Le périmètre actuel ne justifie pas cette complexité.

#### Option 2 — Application monolithique sans séparation interne

Toute la logique pourrait être regroupée dans un nombre réduit de fichiers.

Cette solution serait simple au démarrage, mais mélangerait rapidement :

- les routes HTTP ;
- les règles métier ;
- les traitements de matching ;
- les traitements IA ;
- l'accès à PostgreSQL.

Elle rendrait les tests et les évolutions plus difficiles.

#### Option 3 — Monolithe modulaire

Une seule application est déployée, mais les responsabilités sont séparées
dans le code.

Le principe retenu est :

    API
    ↓
    services métier
    ↓
    logique spécialisée
    ↓
    accès aux données
    ↓
    PostgreSQL

### Décision

L'option 3 est retenue.

Match-Immo utilise un **monolithe modulaire** pour le démonstrateur applicatif.

Un monolithe modulaire est une application déployée comme un seul ensemble,
mais organisée en composants internes clairement séparés.

L'application utilise notamment :

- FastAPI pour l'API HTTP ;
- des services dédiés pour la logique métier ;
- des modules spécialisés pour la faisabilité, le matching et le chasseur-IA ;
- SQLAlchemy pour l'accès aux données ;
- PostgreSQL comme base transactionnelle.

### Justification

Cette solution offre le meilleur compromis pour le périmètre actuel.

Elle permet :

- de conserver un déploiement simple ;
- de séparer les responsabilités ;
- de tester les composants indépendamment ;
- de limiter le couplage ;
- de conserver une architecture compréhensible ;
- d'éviter la complexité prématurée des microservices.

Cette décision reste cohérente avec le principe déjà retenu en Phase 3 :

> **Mesurer avant de complexifier.**

Une évolution vers des services séparés pourra être étudiée ultérieurement si
des besoins réels de charge, d'indépendance de déploiement ou d'organisation le
justifient.

### Conséquences

Le backend est organisé autour de plusieurs responsabilités distinctes :

- routes et contrôle des requêtes ;
- services métier ;
- logique de matching ;
- calcul de faisabilité ;
- assistance chasseur-IA ;
- validation humaine ;
- accès aux données.

Les composants peuvent être testés séparément tout en restant intégrés dans une
application unique.

### Alternatives rejetées

**Microservices immédiatement**

Rejetés car ils augmenteraient fortement la complexité sans besoin démontré
dans le périmètre actuel.

**Monolithe non structuré**

Rejeté car il mélangerait les responsabilités et rendrait le code plus
difficile à maintenir et à tester.

### Preuves

- `04-application-ia/architecture-applicative.md`
- `04-application-ia/backend/app/`
- `04-application-ia/backend/tests/`
- `02-modele-cible/note-strategique-si.md`

------------------------------------------------------------------------

## ADR-015 — Retenir un matching déterministe et explicable plutôt qu'un modèle ML entraîné

- **Date :** 12/09/2026
- **Phase :** 4 — Application et IA
- **Statut :** accepté
- **Décideur :** Belkacem

### Contexte

Le projet doit proposer un mécanisme de rapprochement entre :

- les critères d'une demande immobilière ;
- les caractéristiques des biens disponibles.

Le Starter Pack attend une conception du modèle de matching et de ses features.

Il n'impose pas l'entraînement d'un modèle de Machine Learning.

Le projet dispose de règles métier explicites mais ne dispose pas d'un jeu
d'entraînement historique suffisamment riche, qualifié et labellisé pour
justifier l'apprentissage d'un modèle prédictif.

### Options étudiées

#### Option 1 — Entraîner un modèle de Machine Learning

Cette option consisterait à entraîner un modèle à partir d'exemples historiques.

Elle nécessiterait notamment :

- un volume suffisant de données ;
- des exemples correctement labellisés ;
- une définition claire de la cible à prédire ;
- une séparation entraînement / validation / test ;
- des métriques adaptées ;
- une surveillance du comportement du modèle.

Ces conditions ne sont pas réunies dans le périmètre actuel.

Entraîner malgré tout un modèle sur des données insuffisantes produirait une
preuve artificielle et difficile à défendre.

#### Option 2 — Utiliser uniquement des filtres obligatoires

Cette option consisterait à éliminer les biens non compatibles sans produire
de score.

Elle serait simple mais ne permettrait pas de hiérarchiser les biens restant
compatibles.

#### Option 3 — Utiliser un scoring déterministe et explicable

Cette option combine :

1. un préfiltrage sur les critères obligatoires ;
2. un calcul pondéré sur les biens restant compatibles ;
3. une explication détaillée des contributions au score.

### Décision

L'option 3 est retenue.

Le moteur de matching utilise un modèle de scoring déterministe.

Un calcul déterministe produit le même résultat pour les mêmes données
d'entrée.

Le moteur utilise six features principales :

- secteur ;
- prix ;
- surface ;
- type de bien ;
- nombre de pièces ;
- DPE.

Les pondérations retenues sont :

- secteur : 30 % ;
- prix : 25 % ;
- surface : 20 % ;
- type de bien : 10 % ;
- nombre de pièces : 10 % ;
- DPE : 5 %.

### Préfiltrage

Certains critères sont considérés comme obligatoires.

Un bien peut être exclu avant le calcul du score lorsque, par exemple :

- son prix dépasse le budget maximal ;
- son secteur n'est pas demandé ;
- son type est incompatible lorsqu'un type précis est imposé.

### Gestion des valeurs absentes

Une donnée absente n'est pas inventée.

Lorsqu'un critère demandé ne peut pas être évalué :

- aucune valeur artificielle n'est créée ;
- le détail indique l'absence de donnée ;
- le score est renormalisé sur les critères réellement évaluables.

Ce principe reste cohérent avec la décision de migration déjà prise en Phase 2 :

> **ne pas inventer les données absentes.**

### Explicabilité

Le moteur conserve le détail de chaque contribution.

Il est donc possible d'expliquer pourquoi un bien obtient un score donné.

Exemple de référence :

    bien 2
    → 100,00 / 100

    bien 1
    → 98,57 / 100

Le bien 1 perd uniquement une partie de la contribution liée à la surface.

### Justification

Cette solution est retenue car elle est :

- cohérente avec les règles métier disponibles ;
- reproductible ;
- testable ;
- explicable ;
- adaptée au volume et à la qualité des données disponibles ;
- défendable devant un utilisateur métier et devant le jury.

Elle évite de présenter comme intelligence artificielle entraînée un modèle
qui ne disposerait pas des données nécessaires à un apprentissage sérieux.

### Conséquences

Le moteur de matching peut être testé précisément.

Les tests vérifient notamment :

- le préfiltrage ;
- les pondérations ;
- les scores partiels ;
- les valeurs absentes ;
- le bornage entre 0 et 100 ;
- l'explicabilité ;
- le classement décroissant des biens.

Un futur modèle de Machine Learning pourra être étudié si Match-Immo dispose
ultérieurement d'un historique suffisamment riche et qualifié.

Il devra alors être comparé au moteur déterministe actuel et démontrer un gain
mesurable avant remplacement.

### Alternatives rejetées

**Entraîner artificiellement un modèle ML avec les données actuelles**

Rejeté car le projet ne dispose pas d'un jeu de données d'entraînement
suffisamment qualifié pour produire un modèle pertinent et défendable.

**Utiliser uniquement des filtres**

Rejeté car les filtres seuls ne permettent pas de classer les biens
compatibles selon leur niveau d'adéquation.

### Preuves

- `04-application-ia/matching-features.md`
- `04-application-ia/backend/app/matching.py`
- `04-application-ia/backend/app/matching_service.py`
- `04-application-ia/backend/tests/test_matching.py`
- `04-application-ia/backend/tests/test_matching_service.py`
- `04-application-ia/backend/tests/test_matching_explainability.py`
- `04-application-ia/plan-de-tests.md`

------------------------------------------------------------------------

## ADR-016 — Imposer la validation humaine et limiter l'accès de l'IA aux données

- **Date :** 12/09/2026
- **Phase :** 4 — Application et IA
- **Statut :** accepté
- **Décideur :** Belkacem

### Contexte

Le volet IA du projet doit assister le chasseur immobilier sans lui retirer la maîtrise de la décision.

Les traitements utilisés dans le démonstrateur produisent notamment :

- un niveau de faisabilité ;
- un classement de biens ;
- des explications de matching ;
- une synthèse destinée au chasseur.

Ces traitements manipulent des données issues du système métier.

Deux risques doivent être maîtrisés :

1. laisser un composant IA prendre seul une décision métier importante ;
2. donner à ce composant un accès trop large aux données de l'application.

### Options étudiées

#### Option 1 — Donner un accès direct à la base au composant IA

Le composant IA pourrait interroger directement PostgreSQL et récupérer les données qu'il estime nécessaires.

Cette solution est rejetée car elle augmenterait :

- l'exposition des données ;
- le couplage entre IA et base ;
- les risques d'accès excessifs ;
- la difficulté de contrôler les informations réellement transmises.

#### Option 2 — Laisser l'IA valider automatiquement les décisions

Le système pourrait accepter automatiquement une recommandation ou une action produite par l'IA.

Cette solution est rejetée car elle réduirait le contrôle humain sur des décisions métier importantes.

#### Option 3 — Médiation par le backend et validation humaine obligatoire

Le backend conserve le contrôle des données.

Il sélectionne les informations nécessaires avant de les transmettre au composant d'assistance IA.

Les décisions importantes restent soumises à une validation humaine explicite.

### Décision

L'option 3 est retenue.

Le composant IA n'accède pas librement à PostgreSQL.

Le principe retenu est :

    PostgreSQL
    ↓
    backend
    ↓
    sélection des données nécessaires
    ↓
    composant IA
    ↓
    proposition / synthèse
    ↓
    validation humaine

### Minimisation des données

Le backend applique un principe de minimisation.

Seules les données utiles au traitement doivent être transmises.

Les données personnelles inutiles au calcul ou à la synthèse ne doivent pas être envoyées au composant IA.

Le démonstrateur vérifie notamment que des informations comme :

- nom ;
- email ;
- téléphone ;

ne sont pas transmises lorsqu'elles ne sont pas nécessaires.

### Validation humaine

Le système conserve une étape explicite de validation humaine.

Les décisions prévues sont :

- `VALIDER` ;
- `REFUSER` ;
- `MODIFIER`.

La validation est enregistrée avec :

- la version de demande concernée ;
- le validateur ;
- la décision ;
- la date ;
- le commentaire éventuel.

### Justification

Cette approche permet :

- de conserver le contrôle métier ;
- de limiter l'exposition des données ;
- de réduire les droits du composant IA ;
- de tracer les décisions humaines ;
- de respecter les principes RGPD de minimisation ;
- de faciliter l'audit du fonctionnement du système.

Elle permet également d'ajouter ultérieurement un service IA externe sans lui donner un accès direct au système d'information.

### Conséquences

Le composant chasseur-IA fonctionne avec des données préparées par le backend.

Il ne possède pas de connexion autonome à PostgreSQL.

Les traitements IA ne valident pas seuls les décisions métier importantes.

La couche de validation humaine devient une partie explicite du workflow applicatif.

Toute évolution future vers un fournisseur IA externe devra vérifier notamment :

- les données réellement transmises ;
- les conditions d'hébergement ;
- la conservation des données ;
- les droits d'utilisation ;
- les exigences de sécurité et de confidentialité.

### Alternatives rejetées

**Accès direct de l'IA à PostgreSQL**

Rejeté car il donnerait au composant IA un périmètre d'accès plus large que nécessaire.

**Validation entièrement automatique**

Rejetée car le projet veut conserver une décision humaine pour les actions métier importantes.

### Preuves

- `02-modele-cible/registre-rgpd.md`
- `02-modele-cible/note-souverainete-securite-ia.md`
- `04-application-ia/programme-ia.md`
- `04-application-ia/architecture-applicative.md`
- `04-application-ia/backend/app/chasseur_ai.py`
- `04-application-ia/backend/app/chasseur_ai_service.py`
- `04-application-ia/backend/app/human_validation_service.py`
- `04-application-ia/backend/tests/test_chasseur_ai_security.py`
- `04-application-ia/backend/tests/test_full_workflow_integration.py`

------------------------------------------------------------------------

## ADR-017 — Automatiser la qualité avec GitHub Actions, Ruff et pytest

- **Date :** 12/09/2026
- **Phase :** 4 — Application et IA
- **Statut :** accepté
- **Décideur :** Belkacem

### Contexte

Le backend de la Phase 4 dispose désormais de tests automatisés couvrant
notamment :

- le matching ;
- la faisabilité ;
- le chasseur-IA ;
- la validation humaine ;
- la sécurité ;
- les parcours fonctionnels ;
- les intégrations PostgreSQL.

Exécuter ces contrôles uniquement manuellement en local ne suffit pas pour
garantir qu'une modification future ne dégrade pas le projet.

La grille demande également un suivi qualité automatisé avec un pipeline CI.

CI signifie :

    Continuous Integration
    → intégration continue

Elle consiste à exécuter automatiquement des contrôles lorsqu'une modification
du code est intégrée au dépôt.

### Options étudiées

#### Option 1 — Contrôles uniquement manuels

Les tests et contrôles de qualité seraient exécutés localement avant chaque
commit.

Cette solution est simple mais dépend entièrement de l'action du développeur.

Elle ne garantit pas qu'un contrôle soit réellement exécuté après chaque
modification.

#### Option 2 — Mettre en place une plateforme CI complexe

Des solutions comme Jenkins ou une infrastructure dédiée pourraient être
déployées.

Cette solution offrirait de nombreuses possibilités mais introduirait :

- une infrastructure supplémentaire ;
- de la configuration ;
- de la maintenance ;
- une complexité disproportionnée pour le périmètre actuel.

#### Option 3 — Utiliser GitHub Actions

Le dépôt étant hébergé sur GitHub, GitHub Actions permet d'exécuter les
contrôles directement à chaque modification importante.

Le pipeline peut rester simple et reproductible.

### Décision

L'option 3 est retenue.

Le projet utilise GitHub Actions pour automatiser le contrôle qualité du
backend de la Phase 4.

Le pipeline se déclenche :

- lors d'un `push` sur la branche `develop` ;
- lors d'une `pull_request` vers la branche `develop`.

### Contrôles exécutés

La CI :

1. récupère le dépôt ;
2. installe Python 3.14.7 ;
3. installe les dépendances applicatives ;
4. installe les dépendances de développement ;
5. exécute Ruff ;
6. exécute pytest.

Ruff contrôle notamment :

- les erreurs de syntaxe ;
- certaines erreurs de code ;
- les imports ;
- plusieurs règles de qualité statique.

Pytest exécute les scénarios automatisés du backend.

### Choix sur PostgreSQL dans la CI

Les tests d'intégration PostgreSQL ne sont pas exécutés dans la suite standard
du pipeline actuel.

Ils sont volontairement séparés afin de conserver une CI simple et indépendante
d'un service PostgreSQL supplémentaire.

Ils restent exécutables explicitement dans un environnement PostgreSQL réel.

Au 12/09/2026 :

    suite standard
    → 47 passed, 5 skipped

    tests d'intégration PostgreSQL explicites
    → 5 passed

Cette séparation est volontaire et documentée.

### Justification

GitHub Actions est retenu car :

- le dépôt est déjà hébergé sur GitHub ;
- aucune infrastructure CI supplémentaire n'est nécessaire ;
- le workflow est versionné avec le code ;
- l'environnement est recréé à chaque exécution ;
- Ruff et pytest fournissent des contrôles simples et adaptés au projet ;
- le résultat est visible et vérifiable.

Cette solution répond au besoin sans introduire Jenkins, Kubernetes ou une
plateforme supplémentaire non nécessaire.

### Première exécution

La première exécution du pipeline a détecté un problème d'organisation des
imports avec Ruff.

La configuration a été corrigée puis le pipeline a été exécuté avec succès.

Ce comportement confirme l'intérêt du contrôle automatisé : une anomalie
réelle a été détectée avant validation définitive.

### Conséquences

Toute modification du backend sur `develop` est soumise automatiquement aux
contrôles de qualité définis dans le workflow.

Les contrôles locaux restent utiles, mais la CI fournit une vérification
indépendante et reproductible.

Le pipeline pourra évoluer ultérieurement si le projet nécessite :

- un service PostgreSQL dans la CI ;
- davantage de contrôles de sécurité ;
- des métriques supplémentaires ;
- une construction ou un déploiement automatisé.

Ces extensions ne sont pas nécessaires au périmètre actuel.

### Alternatives rejetées

**Contrôles uniquement locaux**

Rejetés comme unique mécanisme car ils ne fournissent pas de preuve automatisée
et indépendante à chaque intégration.

**Jenkins ou plateforme CI dédiée**

Rejetés pour le périmètre actuel car ils introduiraient une infrastructure et
une maintenance supplémentaires sans bénéfice démontré.

### Preuves

- `.github/workflows/phase4-backend.yml`
- `04-application-ia/backend/ruff.toml`
- `04-application-ia/backend/requirements-dev.txt`
- `04-application-ia/backend/tests/`
- `04-application-ia/plan-de-tests.md`

------------------------------------------------------------------------

## ADR-018 — Aligner le modèle de rémunération sur les règles métier clarifiées

- **Date :** 22/09/2026
- **Phase :** 2 — Consolidation du modèle cible
- **Statut :** accepté
- **Décideur :** Belkacem

### Contexte

Une mise à jour du Starter Pack a précisé plusieurs règles liées à la rémunération du chasseur : lien avec le mandat, origine de la vente, assiette basée sur les honoraires de l'entreprise, barème applicable dans le temps et critères de performance.

Ces précisions nécessitaient de vérifier le modèle cible sans inventer de données historiques ni transformer des exemples numériques du Starter Pack en règles obligatoires.

### Décision

Le modèle cible est aligné selon les principes suivants :

- `CHASSEUR.date_debut_activite` est ajouté comme donnée métier optionnelle pour permettre le calcul futur de l'ancienneté ;
- aucune date historique existante n'est réinterprétée artificiellement comme date de début d'activité ;
- `ACTE_AUTHENTIQUE` est relié directement au `MANDAT` ;
- le lien vers `OFFRE` reste optionnel afin de représenter une vente conclue sans offre interne enregistrée ;
- `ACTE_AUTHENTIQUE.origine_vente` conserve l'origine de la vente ;
- `COMMISSION` conserve le résultat et les paramètres du calcul afin d'assurer la traçabilité historique ;
- la tranche de commission peut être absente lorsqu'aucun droit à rémunération n'est ouvert ;
- les anciens `taux_commission` de la source ne sont pas transformés en barèmes cibles faute de sémantique suffisante ;
- ces valeurs historiques sont conservées dans `reprise_controle.donnee_source_non_reprise` ;
- les montants, taux, pondérations et seuils numériques présentés comme exemples dans le Starter Pack ne sont pas imposés comme paramètres métier du projet.

### Conséquences

Le MCD, le MLD, la migration PostgreSQL, la reprise des données, le cahier des charges technique, le registre RGPD et le plan de tests ont été synchronisés avec cette décision.

Le projet conserve volontairement une distinction entre :

- la structure permettant de tracer une rémunération ;
- les règles métier déjà clarifiées ;
- les paramètres chiffrés qui devront être validés avant implémentation d'un moteur complet.

Les scénarios `F-R01` à `F-R05` restent donc des tests futurs et ne sont pas présentés comme exécutés.

Après recréation et reprise de la base, une non-régression a également été rejouée le 22/09/2026. Après remise en place du jeu de démonstration Phase 4 attendu par les tests d'intégration, la suite complète obtient :

    52 passed in 0.33s

### Preuves

- `02-modele-cible/besoins-metier-final.md`
- `02-modele-cible/mcd-cible-final-propre.drawio.png`
- `02-modele-cible/mld-cible-final.md`
- `02-modele-cible/migration-final.sql`
- `02-modele-cible/reprise-donnees-final.sql`
- `02-modele-cible/cahier-des-charges-technique-MAJ.md`
- `02-modele-cible/registre-rgpd.md`
- `04-application-ia/plan-de-tests.md`

