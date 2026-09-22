# Futur métier — Parcours chasseur

## 1. Objectif

Ce document décrit les principales évolutions envisagées pour le travail du chasseur immobilier dans le futur système Match-Immo.

L'objectif n'est pas de remplacer le chasseur par une intelligence artificielle.

Le futur système doit surtout :

- réduire les tâches répétitives ;
- aider à analyser les demandes ;
- mieux classer les biens ;
- fournir des synthèses utiles ;
- conserver une décision humaine sur les actions importantes.

Le principe général est :

    système
        analyse et propose
            ↓
    chasseur
        contrôle et décide

---

## 2. Rapport de faisabilité de la demande

Aujourd'hui, une demande peut être difficile à évaluer rapidement lorsqu'elle combine plusieurs contraintes : budget, secteur, surface, type de bien ou nombre de pièces.

Le futur système doit produire un rapport de faisabilité permettant au chasseur de comprendre immédiatement :

- si la recherche paraît réaliste ;
- quels critères réduisent fortement les possibilités ;
- combien de biens semblent compatibles ;
- quelles modifications pourraient améliorer les chances de réussite.

Exemple :

    Budget : compatible
    Secteur : très restrictif
    Surface : restrictive

    Conclusion :
    recherche difficile

Le système ne doit pas simplement répondre « oui » ou « non ». Il doit expliquer le résultat.

La valeur pour le chasseur est de préparer plus rapidement son échange avec le particulier et de concentrer son expertise sur les décisions utiles.

---

## 3. Aide à la reformulation de la demande

Lorsqu'une recherche est trop restrictive, le futur système peut proposer plusieurs pistes de reformulation.

Exemples :

- élargir légèrement le secteur ;
- réduire la surface minimale ;
- modifier un critère secondaire ;
- réévaluer certaines préférences.

Ces propositions ne modifient jamais automatiquement la demande.

Le chasseur et le particulier restent responsables de la décision.

L'intelligence artificielle peut aider à présenter les propositions de manière claire, mais les règles et calculs de faisabilité restent la référence.

---

## 4. Automatisation de la prise de contact et des rendez-vous

Certaines tâches ne nécessitent pas nécessairement d'intelligence artificielle.

Après l'affectation d'un chasseur, le système peut par exemple :

- envoyer une notification ;
- proposer des créneaux ;
- confirmer un rendez-vous ;
- envoyer un rappel.

Il s'agit principalement d'automatisation classique.

L'intérêt est de réduire les tâches administratives et d'accélérer la prise en charge du particulier.

Une intervention humaine reste possible à tout moment.

---

## 5. Sélection, comparaison et classement des biens

Le futur système doit aider le chasseur à traiter les biens disponibles de manière structurée.

Le parcours retenu est :

    biens disponibles
        ↓
    suppression des incompatibilités
        ↓
    comparaison des critères
        ↓
    calcul d'un score
        ↓
    classement

Le **préfiltrage** élimine les biens ne respectant pas certains critères obligatoires.

Le **matching** mesure ensuite à quel point chaque bien restant correspond à la demande.

Dans le démonstrateur Phase 4, les critères utilisés sont notamment :

- secteur ;
- prix ;
- surface ;
- type de bien ;
- nombre de pièces ;
- DPE.

Le résultat doit être explicable.

Exemple :

    Bien A : 92 / 100

    secteur : très compatible
    prix : compatible
    surface : compatible
    DPE : point de vigilance

Le chasseur ne reçoit donc pas seulement une note, mais les éléments qui expliquent cette note.

Le classement aide à prioriser les biens. Il ne remplace pas l'expertise du chasseur.

---

## 6. Requalification à partir des biens rejetés

Les choix du particulier apportent progressivement de nouvelles informations sur ses préférences.

Exemple :

plusieurs appartements sont techniquement compatibles mais le particulier rejette systématiquement ceux situés dans un quartier très dense.

Le système peut détecter cette répétition et signaler au chasseur qu'un critère implicite semble apparaître.

Il peut alors proposer :

    préférence observée :
    environnement moins dense

    suggestion :
    vérifier ce critère avec le particulier

La demande n'est jamais modifiée automatiquement.

Lorsque le chasseur et le particulier valident une évolution, une nouvelle `version_demande` permet de conserver l'historique.

Cette approche évite de perdre les décisions précédentes et améliore progressivement la qualité de la recherche.

---

## 7. Pré-rédaction des avis du chasseur

Après l'étude d'un bien, le système peut préparer un brouillon d'avis à partir des informations connues.

Il peut utiliser par exemple :

- caractéristiques du bien ;
- résultat du matching ;
- points forts ;
- critères moins compatibles ;
- informations déjà saisies par le chasseur.

Exemple :

    Ce bien correspond bien au budget et au secteur recherchés.
    La surface est légèrement inférieure au souhait initial.
    Le DPE mérite une attention particulière.

L'intelligence artificielle peut être utile pour rédiger cette synthèse.

Elle ne doit jamais inventer :

- une caractéristique absente ;
- une visite qui n'a pas eu lieu ;
- un défaut non constaté ;
- un avantage non présent dans les données.

Le texte reste un brouillon soumis au chasseur avant transmission.

---

## 8. Aide à la préparation d'une offre d'achat

Le système peut aider le chasseur à préparer plusieurs scénarios à partir des informations disponibles.

Exemples :

    scénario 1
    offre proche du prix demandé

    scénario 2
    offre légèrement inférieure avec justification

    scénario 3
    maintien de la recherche

L'objectif est d'aider à comparer différentes possibilités, pas de décider automatiquement du montant d'une offre.

Une offre d'achat possède des conséquences importantes pour le particulier.

La décision finale appartient donc au particulier accompagné du chasseur.

L'intelligence artificielle peut résumer les éléments disponibles et préparer les scénarios, mais elle ne négocie pas seule.

---

## 9. Vérification de la facture avant paiement

La Phase 2 a déjà structuré le parcours de rémunération :

    honoraires
        ↓
    barème de commission
        ↓
    commission
        ↓
    facture chasseur
        ↓
    paiement

Le futur système peut réaliser automatiquement plusieurs contrôles avant paiement :

- présence des informations obligatoires ;
- cohérence avec la vente ;
- montant attendu ;
- commission calculée ;
- doublon éventuel ;
- correspondance avec les données enregistrées.

Pour ces contrôles structurés, des règles classiques sont plus fiables et plus simples qu'un modèle d'intelligence artificielle.

L'IA peut éventuellement aider à expliquer une anomalie, mais elle ne remplace pas le calcul métier.

Une anomalie doit être signalée pour contrôle humain avant paiement.

---

## 10. Anticipation de l'échéance d'un mandat

Un mandat possède une durée limitée.

Le système peut surveiller automatiquement les dates et prévenir suffisamment tôt :

    mandat proche de son échéance
        ↓
    alerte
        ↓
    bilan de la recherche
        ↓
    décision humaine

Le système peut présenter au chasseur :

- date de fin ;
- durée restante ;
- nombre de biens étudiés ;
- visites réalisées ;
- évolution de la demande ;
- synthèse de la recherche.

Un renouvellement n'est jamais automatique.

Le chasseur et le particulier restent responsables de cette décision.

Cette fonction relève principalement de règles de dates et d'alertes. Une IA peut éventuellement produire une synthèse du bilan.

---

## 11. Rôle du chasseur-IA

Le terme **chasseur-IA** ne désigne pas un agent autonome chargé de remplacer le professionnel.

Dans Match-Immo, il représente un ensemble coordonné de fonctions :

- règles métier ;
- calculs de faisabilité ;
- moteur de matching ;
- classement ;
- explications ;
- synthèses ;
- éventuelle génération de texte.

Le chasseur-IA peut notamment :

- expliquer une faisabilité ;
- présenter les meilleurs biens ;
- signaler des critères restrictifs ;
- proposer une reformulation ;
- préparer une synthèse ;
- signaler qu'une intervention humaine est nécessaire.

Il ne peut pas :

- inventer les caractéristiques d'un bien ;
- modifier arbitrairement un score ;
- changer seul une demande ;
- décider seul d'une offre ;
- signer ou renouveler un mandat ;
- valider seul une facture ;
- prendre une décision contractuelle à la place du particulier ou du chasseur.

Dans une zone où aucun chasseur humain n'est immédiatement disponible, ce système peut fournir une première assistance au particulier.

Il doit néanmoins être présenté clairement comme un système automatisé et permettre une reprise en main humaine.

---

## 12. Pourquoi cette organisation est retenue

Toutes les tâches ne nécessitent pas de l'intelligence artificielle.

Match-Immo privilégie donc le composant le plus simple et le plus fiable pour chaque besoin :

    règles métier
    → calculs fiables et contrôles

    matching
    → comparaison et classement

    automatisation
    → notifications, rendez-vous, échéances

    IA / LLM
    → reformulation, explication et synthèse

    humain
    → décision finale

Cette séparation permet :

- de réduire la complexité ;
- d'améliorer l'explicabilité ;
- de limiter les hallucinations ;
- de faciliter les tests ;
- de conserver la responsabilité humaine.

---

## 13. Parcours futur résumé

Le parcours chasseur peut être résumé ainsi :

    demande du particulier
        ↓
    analyse de faisabilité
        ↓
    éventuelle reformulation
        ↓
    prise en charge par le chasseur
        ↓
    sélection et matching des biens
        ↓
    analyse des retours du particulier
        ↓
    avis et recommandations
        ↓
    éventuelle préparation d'une offre
        ↓
    vente
        ↓
    contrôle de la rémunération

En parallèle :

    suivi du mandat
        ↓
    anticipation de son échéance

Le système automatise et assiste lorsque cela apporte une valeur réelle.

Le chasseur conserve le contrôle des décisions importantes.
