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
| U-F01 | demande réaliste | plusieurs biens correspondent aux principaux critères | calcul de faisabilité | niveau de faisabilité favorable | À exécuter | ⬜ |
| U-F02 | recherche restrictive | très peu de biens correspondent | calcul de faisabilité | résultat indique une recherche difficile ou restrictive | À exécuter | ⬜ |
| U-F03 | critère secteur restrictif | aucun ou très peu de biens dans le secteur | analyse des critères | secteur identifié comme critère restrictif | À exécuter | ⬜ |
| U-F04 | critère surface restrictif | surface minimale supérieure à la majorité des biens | analyse des critères | surface identifiée comme restrictive | À exécuter | ⬜ |
| U-F05 | donnée manquante | DPE ou autre donnée non disponible | analyse | la donnée reste indiquée comme inconnue et n'est pas inventée | À exécuter | ⬜ |
| U-F06 | résultat borné | demande quelconque | calcul du score de faisabilité | score compris entre 0 et 100 | À exécuter | ⬜ |

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
| U-AI01 | synthèse d'un matching | scores et données vérifiées disponibles | création de la synthèse | résumé cohérent avec les données | À exécuter | ⬜ |
| U-AI02 | conservation du score | score calculé par le moteur de matching | génération de la synthèse | le chasseur-IA ne modifie pas le score | À exécuter | ⬜ |
| U-AI03 | donnée absente | information inconnue | génération de la synthèse | aucune caractéristique n'est inventée | À exécuter | ⬜ |
| U-AI04 | recommandation explicable | critères forts et faibles identifiés | génération de la synthèse | forces et points de vigilance apparaissent | À exécuter | ⬜ |
| U-AI05 | absence de LLM | LLM indisponible ou désactivé | traitement du parcours | calculs de faisabilité et matching continuent de fonctionner | À exécuter | ⬜ |

---

# 9. Tests fonctionnels — API et parcours métier

| ID | Ce qu'on teste | Given | When | Then | Résultat obtenu | Statut |
| --- | --- | --- | --- | --- | --- | --- |
| F01 | analyse de faisabilité complète | demande valide | appel de l'API de faisabilité | réponse avec niveau, score et critères restrictifs | À exécuter | ⬜ |
| F02 | matching complet | demande valide et biens disponibles | appel de l'API de matching | liste de biens classés avec scores | À exécuter | ⬜ |
| F03 | détail d'un score | résultat de matching existant | demande du détail | contributions des features retournées | À exécuter | ⬜ |
| F04 | synthèse chasseur-IA | résultats calculés disponibles | génération de la synthèse | texte cohérent avec les résultats | À exécuter | ⬜ |
| F05 | validation humaine | recommandation disponible | chasseur valide | statut de validation enregistré | À exécuter | ⬜ |
| F06 | refus humain | recommandation disponible | chasseur refuse | refus enregistré sans transmission automatique | À exécuter | ⬜ |
| F07 | modification humaine | recommandation disponible | chasseur modifie la sélection | sélection modifiée avant validation | À exécuter | ⬜ |
| F08 | parcours principal | demande valide | faisabilité → matching → synthèse → validation | parcours complet terminé sans erreur | À exécuter | ⬜ |

---

# 10. Tests fonctionnels — Erreurs et sécurité

| ID | Ce qu'on teste | Given | When | Then | Résultat obtenu | Statut |
| --- | --- | --- | --- | --- | --- | --- |
| F-S01 | requête invalide | budget absent ou format incorrect | appel API | erreur contrôlée avec message compréhensible | À exécuter | ⬜ |
| F-S02 | identifiant inconnu | ressource inexistante | appel API | réponse 404 ou erreur métier équivalente | À exécuter | ⬜ |
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

Après développement, ce document sera complété avec :

- le résultat réellement obtenu ;
- le statut ✅ ou ❌ ;
- le nombre total de tests ;
- le nombre de tests réussis ;
- le nombre de tests échoués ;
- la commande d'exécution ;
- la date d'exécution.

Exemple attendu :

    41 tests collectés
    41 tests réussis
    0 test échoué

Ces valeurs ne seront renseignées qu'après une exécution réelle.

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
