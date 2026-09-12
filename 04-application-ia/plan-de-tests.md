# Plan de tests — Phase 4 Match-Immo

## 1. Objectif

Ce plan de tests vérifie que le démonstrateur Phase 4 de Match-Immo fonctionne conformément aux besoins définis.

### Comment lire ce document

Ce document répond à une question simple :

> Comment prouver que ce qui a été conçu fonctionne réellement comme prévu ?

Chaque test part d'une situation connue, exécute une action puis vérifie le résultat obtenu.

Un **test automatisé** est un contrôle exécuté par le programme lui-même afin de vérifier qu'une fonctionnalité continue de produire le résultat attendu.

Le **backend** est la partie de l'application qui exécute les règles métier et dialogue avec les données.

Une **API** est le point d'entrée utilisé pour demander une action au backend et récupérer sa réponse.

Il couvre principalement :

- la faisabilité d'une demande ;
- le matching entre une demande et des biens ;
- l'explication du score ;
- le chasseur-IA ;
- la validation humaine ;
- l'API ;
- les erreurs et contrôles de sécurité.

Les tests seront exécutés après l'implémentation du backend.

Le principe est simple :

    besoin métier
        ↓
    scénario de test
        ↓
    résultat attendu
        ↓
    exécution réelle
        ↓
    preuve

---

## 2. Types de tests

Deux niveaux sont retenus.

### Tests unitaires

Un test unitaire vérifie une petite partie du programme de manière isolée.

Exemples :

- calcul d'un score prix ;
- contrôle d'un secteur incompatible ;
- calcul du score final de matching.

### Tests fonctionnels

Un test fonctionnel vérifie un parcours métier complet.

Exemples :

- envoyer une demande à l'API et obtenir une analyse de faisabilité ;
- demander un matching et obtenir les biens classés ;
- valider humainement une recommandation.

---

## 3. Convention Given / When / Then

Chaque scénario suit le format :

- **Given** : état ou données de départ ;
- **When** : action exécutée ;
- **Then** : résultat attendu.

Exemple :

    Given
    une demande avec un budget maximal de 300 000 €

    When
    un bien à 285 000 € est évalué

    Then
    le critère prix est considéré comme compatible

---

## 4. Statuts

Les statuts utilisés sont :

- ⬜ : à exécuter ;
- ✅ : réussi ;
- ❌ : échoué.

Aucun test n'est marqué comme réussi avant son exécution réelle.

---

# 5. Tests unitaires — Faisabilité

| ID | Ce qu'on teste | Given | When | Then | Résultat obtenu | Statut |
| --- | --- | --- | --- | --- | --- | --- |
| U-F01 | demande réaliste | plusieurs biens correspondent aux principaux critères | calcul de faisabilité | niveau de faisabilité favorable | Niveau favorable obtenu sur données de test | ✅ |
| U-F02 | recherche restrictive | très peu de biens correspondent | calcul de faisabilité | résultat indique une recherche difficile ou restrictive | Niveau très restrictive obtenu | ✅ |
| U-F03 | critère secteur restrictif | aucun ou très peu de biens dans le secteur | analyse des critères | secteur identifié comme critère restrictif | Secteur détecté comme restrictif | ✅ |
| U-F04 | critère surface restrictif | surface minimale supérieure à la majorité des biens | analyse des critères | surface identifiée comme restrictive | Surface détectée comme restrictive | ✅ |
| U-F05 | donnée manquante | DPE ou autre donnée non disponible | analyse | la donnée reste indiquée comme inconnue et n'est pas inventée | DPE conservé comme inconnu, sans valeur inventée | ✅ |
| U-F06 | résultat borné | demande quelconque | calcul du score de faisabilité | score compris entre 0 et 100 | Bornage vérifié sur plusieurs scénarios | ✅ |

---

# 6. Tests unitaires — Matching

| ID | Ce qu'on teste | Given | When | Then | Résultat obtenu | Statut |
| --- | --- | --- | --- | --- | --- | --- |
| U-M01 | bien parfaitement compatible | tous les critères correspondent | calcul du matching | score très élevé | À exécuter | ⬜ |
| U-M02 | prix compatible | bien inférieur ou égal au budget | calcul du critère prix | score prix élevé | À exécuter | ⬜ |
| U-M03 | bien au-dessus du budget | prix supérieur au budget maximal obligatoire | préfiltrage | bien exclu du matching | À exécuter | ⬜ |
| U-M04 | secteur incompatible | secteur différent d'un secteur obligatoire | préfiltrage | bien exclu | À exécuter | ⬜ |
| U-M05 | surface légèrement insuffisante | surface proche mais inférieure au souhait | calcul surface | score partiel et non nul | À exécuter | ⬜ |
| U-M06 | type de bien compatible | type demandé = type du bien | calcul type | score maximal sur ce critère | À exécuter | ⬜ |
| U-M07 | nombre de pièces insuffisant | bien avec moins de pièces que demandé | calcul pièces | pénalité appliquée | À exécuter | ⬜ |
| U-M08 | DPE inconnu | DPE absent | calcul matching | aucune valeur de DPE n'est inventée | À exécuter | ⬜ |
| U-M09 | score final borné | ensemble quelconque de features | calcul final | résultat compris entre 0 et 100 | À exécuter | ⬜ |
| U-M10 | pondération | scores de features connus | calcul pondéré | poids secteur 30 %, prix 25 %, surface 20 %, type 10 %, pièces 10 %, DPE 5 % appliqués | À exécuter | ⬜ |
| U-M11 | exemple de référence | contributions 24 + 30 + 19 + 10 + 7 + 2 | calcul final | score = 92/100 | À exécuter | ⬜ |
| U-M12 | classement | trois biens avec scores différents | tri des résultats | biens classés du score le plus élevé au plus faible | À exécuter | ⬜ |

---

# 7. Tests unitaires — Explicabilité

| ID | Ce qu'on teste | Given | When | Then | Résultat obtenu | Statut |
| --- | --- | --- | --- | --- | --- | --- |
| U-E01 | détail des features | un score de matching calculé | génération de l'explication | chaque contribution importante est identifiable | À exécuter | ⬜ |
| U-E02 | cohérence du score | détail des contributions disponible | affichage de l'explication | somme des contributions cohérente avec le score final | À exécuter | ⬜ |
| U-E03 | point de vigilance | un critère faible existe | génération de l'explication | le critère faible est signalé | À exécuter | ⬜ |
| U-E04 | absence d'invention | caractéristique inconnue | génération de l'explication | l'information est annoncée comme non disponible | À exécuter | ⬜ |

---

# 8. Tests unitaires — Chasseur-IA

| ID | Ce qu'on teste | Given | When | Then | Résultat obtenu | Statut |
| --- | --- | --- | --- | --- | --- | --- |
| U-AI01 | synthèse d'un matching | scores et données vérifiées disponibles | création de la synthèse | résumé cohérent avec les données | Synthèse cohérente avec faisabilité et matching | ✅ |
| U-AI02 | conservation du score | score calculé par le moteur de matching | génération de la synthèse | le chasseur-IA ne modifie pas le score | Scores 53,33, 100,00 et 98,57 conservés | ✅ |
| U-AI03 | donnée absente | information inconnue | génération de la synthèse | aucune caractéristique n'est inventée | Valeurs absentes conservées à None | ✅ |
| U-AI04 | recommandation explicable | critères forts et faibles identifiés | génération de la synthèse | forces et points de vigilance apparaissent | Critères restrictifs présents dans les points de vigilance | ✅ |
| U-AI05 | absence de LLM | LLM indisponible ou désactivé | traitement du parcours | calculs de faisabilité et matching continuent de fonctionner | Parcours exécuté avec llm_utilise = false | ✅ |

---

# 9. Tests fonctionnels — API et parcours métier

| ID | Ce qu'on teste | Given | When | Then | Résultat obtenu | Statut |
| --- | --- | --- | --- | --- | --- | --- |
| F01 | analyse de faisabilité complète | demande valide | appel de l'API de faisabilité | réponse avec niveau, score et critères restrictifs | Score 53,33/100, niveau difficile, secteur restrictif, 2 biens compatibles sur 6 | ✅ |
| F02 | matching complet | demande valide et biens disponibles | appel de l'API de matching | liste de biens classés avec scores | 2 biens retournés, classés : bien 2 = 100/100, bien 1 = 98,57/100 | ✅ |
| F03 | détail d'un score | résultat de matching existant | demande du détail | contributions des features retournées | À exécuter | ⬜ |
| F04 | synthèse chasseur-IA | résultats calculés disponibles | génération de la synthèse | texte cohérent avec les résultats | Synthèse réelle produite depuis faisabilité + matching PostgreSQL | ✅ |
| F05 | validation humaine | recommandation disponible | chasseur valide | statut de validation enregistré | Décision VALIDER enregistrée via API puis persistée dans PostgreSQL | ✅ |
| F06 | refus humain | recommandation disponible | chasseur refuse | refus enregistré sans transmission automatique | Décision REFUSER enregistrée et persistée sans validation automatique | ✅ |
| F07 | modification humaine | recommandation disponible | chasseur modifie la sélection | sélection modifiée avant validation | Décision MODIFIER enregistrée et persistée avant toute validation | ✅ |
| F08 | parcours principal | demande valide | faisabilité → matching → synthèse → validation | parcours complet terminé sans erreur | Parcours complet API → PostgreSQL exécuté sans erreur jusqu'à la validation humaine | ✅ |

---

# 10. Tests fonctionnels — Erreurs et sécurité

| ID | Ce qu'on teste | Given | When | Then | Résultat obtenu | Statut |
| --- | --- | --- | --- | --- | --- | --- |
| F-S01 | requête invalide | budget absent ou format incorrect | appel API | erreur contrôlée avec message compréhensible | À exécuter | ⬜ |
| F-S02 | identifiant inconnu | ressource inexistante | appel API | réponse 404 ou erreur métier équivalente | HTTP 404 retourné avec message métier contrôlé | ✅ |
| F-S03 | absence de biens compatibles | aucun bien après préfiltrage | matching | liste vide et explication claire | À exécuter | ⬜ |
| F-S04 | données personnelles inutiles | opération de matching | préparation des données | nom, email et téléphone non transmis au composant IA | À exécuter | ⬜ |
| F-S05 | protection des écritures | composant IA exécuté | tentative de modification directe des données métier | modification interdite ou impossible | À exécuter | ⬜ |
| F-S06 | erreur interne | erreur provoquée dans un service | appel API | erreur gérée sans exposition d'informations techniques sensibles | À exécuter | ⬜ |

---

# 11. Tests de non-régression

Après chaque modification importante du backend :

    pytest

doit rejouer automatiquement l'ensemble des tests.

Un changement est accepté uniquement si les tests précédemment réussis restent au vert.

---

# 12. Rapport d'exécution

## Exécution intermédiaire — matching

Les tests suivants ont réellement été exécutés pendant le développement.

### Suite automatisée courante

Commande :

    python -m pytest -q

Résultat :

    28 passed, 3 skipped

Le test ignoré correspond au test d'intégration PostgreSQL, volontairement désactivé dans la suite standard afin de garder les tests rapides et indépendants de l'état de la base locale.

### Test d'intégration PostgreSQL — validation humaine

Commande :

    RUN_INTEGRATION_TESTS=1 python -m pytest -q tests/test_human_validation_integration.py

Résultat :

    1 passed

Ce test vérifie réellement les trois décisions humaines :

    VALIDER
    REFUSER
    MODIFIER

Chaque décision passe par l'API puis est enregistrée dans PostgreSQL.

### Test d'intégration PostgreSQL — parcours complet

Commande :

    RUN_INTEGRATION_TESTS=1 python -m pytest -q tests/test_full_workflow_integration.py

Résultat :

    1 passed

Ce test vérifie le parcours complet :

    demande
        ↓
    faisabilité
        ↓
    matching
        ↓
    synthèse chasseur-IA
        ↓
    validation humaine
        ↓
    enregistrement PostgreSQL

### Test d'intégration PostgreSQL — chasseur-IA

Commande :

    RUN_INTEGRATION_TESTS=1 python -m pytest -q tests/test_chasseur_ai_integration.py

Résultat :

    1 passed

Ce test vérifie le parcours réel :

    API FastAPI
        ↓
    PostgreSQL
        ↓
    faisabilité
        ↓
    matching
        ↓
    synthèse chasseur-IA
        ↓
    validation humaine requise

Le test vérifie également que :

- le score de faisabilité reste à 53,33 / 100 ;
- le meilleur bien conserve son score de 100 / 100 ;
- le secteur reste identifié comme critère restrictif ;
- aucun LLM n'est nécessaire au fonctionnement du cœur métier.

### Test d'intégration PostgreSQL — faisabilité

Commande :

    RUN_INTEGRATION_TESTS=1 python -m pytest -q tests/test_feasibility_integration.py

Résultat :

    1 passed

Pour la demande de démonstration `1`, le résultat obtenu est :

    score : 53,33 / 100
    niveau : difficile
    biens disponibles : 6
    biens compatibles : 2
    critère restrictif : secteur

Ce test vérifie le parcours réel :

    API FastAPI
        ↓
    service de faisabilité
        ↓
    PostgreSQL
        ↓
    moteur de faisabilité
        ↓
    réponse HTTP

### Test d'intégration PostgreSQL

Commande :

    RUN_INTEGRATION_TESTS=1 python -m pytest -q tests/test_matching_integration.py

Résultat :

    1 passed

Ce test vérifie le parcours réel :

    API FastAPI
        ↓
    service métier
        ↓
    PostgreSQL
        ↓
    moteur de matching
        ↓
    classement
        ↓
    réponse HTTP

Pour la demande de démonstration `1`, le résultat obtenu est :

    2 biens compatibles

    bien 2
    score : 100 / 100

    bien 1
    score : 98,57 / 100

Le classement est retourné du score le plus élevé au plus faible.

### Test d'erreur API

Un test fonctionnel vérifie également qu'une demande inexistante provoque une réponse HTTP `404` contrôlée.

Ces résultats constituent des preuves intermédiaires. Le rapport final sera complété lorsque l'ensemble des scénarios prévus aura été implémenté et exécuté.


Après développement, ce document sera complété avec :

- le résultat réellement obtenu ;
- le statut ✅ ou ❌ ;
- le nombre total de tests ;
- le nombre de tests réussis ;
- le nombre de tests échoués ;
- la commande d'exécution ;
- la date d'exécution.

Le bilan final indiquera :

- le nombre de tests réellement collectés ;
- le nombre de tests réussis ;
- le nombre de tests échoués ;
- le nombre de tests volontairement ignorés.

Ces valeurs seront renseignées à partir des exécutions réelles du projet.

---

# 13. Critère de validation de la Phase 4

Le plan de tests sera considéré comme validé lorsque :

- les scénarios principaux auront été implémentés ;
- les tests unitaires auront été exécutés ;
- les tests fonctionnels auront été exécutés ;
- les erreurs importantes auront été testées ;
- les résultats auront été reportés dans ce document ;
- les tests pourront être rejoués automatiquement.

Le plan de tests constitue ainsi une preuve technique pour le bloc BC03.
