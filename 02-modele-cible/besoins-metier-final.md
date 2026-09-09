# Besoins métier — Modèle cible

## 1. Objectif du document

Ce document décrit les besoins métier auxquels doit répondre le futur système de chasse immobilière.

Il est volontairement rédigé pour être compréhensible par une personne non technique : il explique **ce que le système doit permettre de faire et pourquoi**, sans entrer dans les détails d'implémentation de la base de données.

Ces besoins constituent la référence fonctionnelle du modèle cible de la phase 2.

## 2. Acteurs du système

Le système concerne principalement :

- le particulier qui recherche un bien immobilier ;
- le chasseur immobilier qui accompagne cette recherche ;
- l'entreprise qui organise l'activité et rémunère les chasseurs ;
- le vendeur d'un bien immobilier ;
- le notaire qui intervient lors de la finalisation d'une vente.

Les clients et les chasseurs partagent des informations d'identité communes, mais leurs responsabilités métier doivent rester clairement distinguées.

Un particulier peut être enregistré comme prospect avant la signature d'un mandat.

## 3. Demande de recherche immobilière

Un prospect ou un client doit pouvoir formuler une demande de recherche avant la signature d'un mandat.

La demande représente son besoin immobilier et contient notamment :

- un budget minimal et maximal ;
- une surface minimale et maximale ;
- un nombre minimal de pièces ;
- un ou plusieurs secteurs géographiques recherchés ;
- une date de création ;
- un statut.

Un même client peut formuler plusieurs demandes.

## 4. Historisation des critères

Les critères d'un client peuvent évoluer pendant sa recherche.

Le système ne doit pas écraser les anciennes informations : chaque modification crée une nouvelle version de la demande.

Chaque version conserve :

- son numéro ;
- sa date ;
- son auteur ;
- le motif de la modification ;
- les critères applicables à ce moment ;
- les secteurs recherchés ;
- l'indication permettant d'identifier la version courante.

Les versions précédentes restent consultables.

## 5. Affectation des demandes aux chasseurs

Une demande peut être proposée à un chasseur.

Le chasseur peut accepter ou refuser sa prise en charge. En cas de refus, le motif peut être conservé et la demande peut ensuite être proposée à un autre chasseur.

Le système doit donc conserver l'historique des affectations :

- la demande concernée ;
- le chasseur concerné ;
- la date d'affectation ;
- la date de réponse ;
- le statut ;
- le motif d'un éventuel refus.

Ainsi, une réaffectation ne fait pas disparaître l'historique précédent.

## 6. Mandats

Lorsqu'un client confie officiellement sa recherche à un chasseur, un mandat peut être signé.

Un mandat est associé à une demande, un client et un chasseur. Il conserve :

- la date de signature ;
- le mode de signature ;
- le caractère exclusif ou non ;
- la date de fin ;
- son statut.

La durée initiale d'un mandat est de six mois à compter de sa signature.

Une demande peut ne produire aucun mandat ou être liée à plusieurs mandats au cours de son histoire, notamment en cas de renouvellement ou selon les règles applicables à un mandat non exclusif.

Le système doit permettre d'identifier qu'un mandat renouvelle un mandat précédent.

Lorsqu'un mandat exclusif est actif, un autre mandat actif incompatible pour la même demande doit être empêché.

## 7. Secteurs géographiques

Le système doit gérer les zones géographiques utilisées pour les recherches et la localisation des biens.

Un secteur peut être décrit par :

- une ville ;
- un quartier ;
- un code postal.

Une version de demande peut cibler plusieurs secteurs et un même secteur peut être ciblé par plusieurs demandes.

## 8. Biens immobiliers

Le système doit enregistrer les biens susceptibles de correspondre aux recherches.

Un bien possède notamment :

- une adresse ;
- un type de bien ;
- un prix ;
- une surface ;
- un nombre de pièces ;
- un diagnostic de performance énergétique (DPE) ;
- une description ;
- un secteur géographique.

Ces données structurées facilitent le rapprochement futur entre les critères d'une demande et les caractéristiques des biens.

## 9. Vendeurs

Le système doit identifier les vendeurs des biens.

Pour chaque vendeur, il doit être possible de conserver le nom, le prénom, l'email et le téléphone.

Un vendeur peut posséder plusieurs biens et un bien peut appartenir à plusieurs vendeurs.

## 10. Présentation des biens

Lorsqu'un chasseur sélectionne un bien, le système doit enregistrer sa présentation au client dans le cadre du mandat concerné.

Une présentation relie donc un mandat et un bien.

Elle conserve notamment :

- la date de présentation ;
- son statut ;
- la priorité donnée par le client ;
- la décision du client ;
- les observations utiles.

Un mandat peut comporter plusieurs présentations et un même bien peut être présenté dans plusieurs contextes.

## 11. Commentaires

Une présentation peut recevoir des commentaires.

Chaque commentaire doit conserver :

- la présentation concernée ;
- son auteur ;
- son texte ;
- sa date.

L'auteur peut notamment être le client ou le chasseur.

## 12. Visites

Un bien présenté peut donner lieu à une ou plusieurs visites.

Le système doit conserver :

- la présentation concernée ;
- la date de visite ;
- le retour du client ;
- son niveau d'intérêt.

Une présentation peut également ne donner lieu à aucune visite.

## 13. Avis du chasseur et médias

Le chasseur doit pouvoir produire un avis professionnel sur un bien présenté.

Cet avis conserve :

- la présentation concernée ;
- le chasseur qui l'a rédigé ;
- sa date ;
- son contenu.

Il peut être complété par des médias, par exemple un enregistrement audio ou une vidéo.

Le système conserve le type du média et une référence permettant de le retrouver. Le stockage physique des fichiers relève de l'architecture technique.

## 14. Offres d'achat

Une présentation peut donner lieu à une ou plusieurs offres d'achat.

Une offre conserve notamment :

- la présentation concernée ;
- sa date ;
- le montant proposé ;
- les conditions de financement ;
- son statut.

Toutes les présentations ne donnent pas nécessairement lieu à une offre.

## 15. Vente et notaire

Lorsqu'une offre aboutit à une vente, le système doit conserver l'acte authentique.

Un **acte authentique** est l'acte officiel de vente authentifié par un notaire.

Le système doit identifier :

- l'offre ayant abouti ;
- le notaire intervenant ;
- la date de l'acte ;
- le prix définitif de vente.

Une offre peut ne jamais aboutir à une vente. Lorsqu'elle aboutit, elle correspond à un seul acte authentique dans le modèle retenu.

## 16. Honoraires

Une vente finalisée génère les honoraires de l'entreprise.

Le système doit conserver :

- le montant fixe éventuel ;
- le pourcentage éventuel ;
- le montant total ;
- la vente ayant généré ces honoraires.

Les honoraires de l'entreprise restent distincts de la commission du chasseur.

## 17. Barèmes de commission

Les règles de rémunération peuvent varier selon :

- le chasseur ;
- la période de validité ;
- les tranches de montant.

Un chasseur peut disposer de plusieurs barèmes au cours du temps.

Chaque barème conserve ses dates de validité et comporte une ou plusieurs tranches.

Chaque tranche précise :

- un montant minimal ;
- un montant maximal ;
- un taux de commission.

Les barèmes et leurs tranches doivent rester identifiables afin de garantir la traçabilité des calculs.

## 18. Commission du chasseur

Le système doit distinguer les honoraires de l'entreprise de la commission due au chasseur.

Pour chaque commission calculée, il doit être possible d'identifier :

- les honoraires ayant servi de base au calcul ;
- le chasseur bénéficiaire ;
- la tranche utilisée ;
- le taux appliqué ;
- le montant obtenu.

Cette traçabilité permet de justifier le calcul de la rémunération.

Les indicateurs de performance du chasseur doivent pouvoir être recalculés après le paiement d'une rémunération.

Le renouvellement d'un mandat arrivé à échéance sans achat doit également pouvoir être pris en compte dans le calcul de performance du chasseur.

## 19. Facturation du chasseur

Une commission peut donner lieu à une facture émise par le chasseur.

Le système doit conserver :

- la commission concernée ;
- le chasseur émetteur ;
- la référence de facture ;
- la date de dépôt ;
- le montant ;
- le statut ;
- la date de vérification.

La facture peut ainsi être contrôlée avant paiement.

## 20. Paiements

Le système doit enregistrer les paiements réellement effectués au titre d'une facture.

Un paiement conserve :

- la facture concernée ;
- le montant payé ;
- la date du paiement ;
- son statut.

Une facture peut faire l'objet de plusieurs paiements, par exemple en cas de règlement fractionné.

La séparation entre commission, facture et paiement permet de distinguer ce qui est calculé, ce qui est facturé et ce qui est réellement versé.

## 21. Qualité, cohérence et traçabilité

Le modèle cible doit permettre de garantir notamment :

- la séparation claire des profils client et chasseur ;
- la cohérence des rôles associés aux demandes et aux mandats ;
- la conservation de l'historique des versions de demande ;
- la conservation de l'historique des affectations ;
- la gestion correcte de l'exclusivité et des renouvellements de mandat ;
- la cohérence chronologique des événements ;
- la traçabilité des présentations, commentaires, visites et avis ;
- la traçabilité des offres et des ventes ;
- la traçabilité des honoraires, barèmes et commissions ;
- la traçabilité des factures et paiements ;
- l'interdiction des montants financiers négatifs ;
- le contrôle des données obligatoires par le modèle de données ou par les règles applicatives ;
- la reprise contrôlée des données provenant du système existant.

Les contrôles techniques précis seront définis lors de l'implémentation de la base de données.

## 22. Exploitation future

La structuration des données doit préparer les futurs usages sans les imposer dans le périmètre transactionnel de la phase 2.

Les données pourront notamment servir à :

- rechercher les biens correspondant aux critères des clients ;
- effectuer du matching entre demandes et biens ;
- suivre l'activité des chasseurs ;
- analyser les délais de prise en charge ;
- analyser les présentations, visites, offres et ventes ;
- produire des indicateurs ;
- alimenter ultérieurement un modèle analytique ;
- préparer de futures fonctionnalités d'intelligence artificielle.

Le **matching** désigne le rapprochement entre les critères recherchés par un client et les caractéristiques des biens disponibles.

## 23. Parcours métier résumé

Pour un lecteur non technique, le fonctionnement général peut être résumé ainsi :

```text
Un particulier exprime son besoin
        ↓
Une demande est créée
        ↓
Ses critères sont conservés et peuvent évoluer
        ↓
La demande est proposée à un chasseur
        ↓
Le chasseur accepte ou refuse
        ↓
Un mandat peut être signé
        ↓
Le chasseur recherche et présente des biens
        ↓
Le client commente, priorise et visite certains biens
        ↓
Le chasseur peut ajouter son avis
        ↓
Le client peut formuler une offre
        ↓
Une offre acceptée peut aboutir à une vente chez le notaire
        ↓
La vente génère des honoraires
        ↓
La commission du chasseur est calculée
        ↓
Le chasseur émet sa facture
        ↓
La facture est vérifiée puis payée
```

Ce parcours constitue le fil conducteur du modèle cible.

## 24. Conclusion

Le modèle cible doit suivre l'ensemble du parcours d'une recherche immobilière, depuis l'expression initiale du besoin jusqu'au paiement du chasseur lorsqu'une vente est finalisée.

Il doit conserver les événements importants plutôt que d'écraser les anciennes informations.

Cette organisation améliore :

- la compréhension du parcours client ;
- la qualité des données ;
- la traçabilité des décisions ;
- le contrôle de la rémunération ;
- la capacité future d'analyse et de matching.

Ces besoins métier constituent la base fonctionnelle du MCD et du MLD cibles de la phase 2.
