# Registre des traitements RGPD — Match Immo

## 1. Objectif

Ce document recense les principaux traitements de données personnelles
prévus dans le système cible Match Immo.

Le RGPD (Règlement général sur la protection des données) impose notamment
de déterminer pourquoi une donnée personnelle est utilisée, sur quelle base
juridique, pendant combien de temps et par qui elle peut être consultée.

Une ligne du registre correspond à un traitement, c'est-à-dire à une finalité
d'utilisation des données, et non à une table de la base de données.

Le registre est établi à partir du MLD cible et du cahier des charges technique
du projet.

---

## 2. Registre des traitements

| Traitement | Finalité | Données personnelles concernées | Personnes concernées | Base légale | Durée de conservation | Accès prévu | Données sensibles |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Gestion des comptes et de la relation avant mandat | Identifier la personne et traiter sa demande de recherche immobilière avant contractualisation | nom, prénom, email, téléphone, statut du compte | prospects / futurs clients | Mesures précontractuelles prises à la demande de la personne | Pendant la phase précontractuelle. Les données qui ne sont plus nécessaires sont supprimées ou anonymisées, sauf autre justification documentée | personnel autorisé chargé de la relation client | Non |
| Gestion des critères de recherche | Enregistrer et faire évoluer le besoin immobilier du client | budget, surface, nombre de pièces, secteurs recherchés, historique des versions, auteur des modifications | prospects / clients | Mesures précontractuelles puis exécution du contrat lorsqu'un mandat est conclu | Pendant la durée nécessaire au traitement de la demande et à l'exécution du mandat ; au terme de la relation, suppression ou archivage uniquement si une autre obligation ou finalité le justifie | client concerné, chasseur affecté et personnel autorisé | Non |
| Affectation d'un chasseur | Affecter une demande à un professionnel et conserver l'historique des acceptations ou refus | identité du client et du chasseur, demande, dates d'affectation et de réponse, statut, motif de refus | clients et chasseurs | Mesures précontractuelles puis exécution du contrat | Pendant la durée nécessaire au suivi de la demande et de la relation contractuelle ; archivage ultérieur uniquement si justifié | chasseur concerné et personnel autorisé | Non |
| Gestion des mandats | Formaliser et exécuter le mandat de recherche immobilière | identité et coordonnées du client et du chasseur, demande associée, dates, mode de signature, exclusivité, statut du mandat | clients et chasseurs | Exécution du contrat puis obligation légale de conservation | 10 ans pour les mandats et le registre des mandats | client concerné selon ses droits, chasseur affecté et personnel autorisé | Non |
| Présentation des biens, commentaires et visites | Assurer le suivi opérationnel de la recherche et des biens proposés au client | biens présentés, décisions et priorités du client, commentaires, dates de visite, retours et intérêt, avis du chasseur | clients et chasseurs | Exécution du contrat | Pendant l'exécution du mandat ; après sa fin, les données non nécessaires à une autre finalité ou obligation sont supprimées ou anonymisées | client concerné, chasseur affecté et personnel autorisé | Non |
| Gestion des vendeurs et des biens | Identifier les propriétaires des biens nécessaires au parcours immobilier | nom, prénom, email, téléphone du vendeur, lien avec le bien, adresse du bien lorsqu'elle permet d'identifier une personne | vendeurs | Intérêt légitime de l'entreprise, sous réserve de nécessité et de mise en balance des droits des personnes | Pendant la durée nécessaire à la gestion du bien et de l'opération ; suppression ou anonymisation lorsque les données ne sont plus nécessaires, sauf obligation de conservation applicable | professionnels autorisés intervenant sur le dossier | Non |
| Gestion des offres et de la vente | Suivre les offres d'achat et la conclusion éventuelle de la vente | offre, montant, condition de financement, statut, identité des personnes reliées au dossier, prix de vente | clients et personnes participant à la transaction | Exécution du contrat ; obligations légales applicables aux documents devant être conservés | Pendant la relation contractuelle puis selon les obligations légales applicables aux documents concernés | client concerné, professionnels autorisés et notaire lorsque nécessaire | Non |
| Gestion du notaire et de l'acte authentique | Identifier le notaire et assurer la traçabilité de la vente authentifiée | nom, prénom, email, téléphone du notaire, date de l'acte, prix de vente, offre associée | notaires et clients concernés | Exécution du contrat et obligations légales applicables à l'opération | Selon la durée nécessaire à la finalité et les obligations légales applicables aux documents concernés | professionnels autorisés et personnes habilitées dans le cadre de la vente | Non |
| Calcul des honoraires et commissions | Calculer et justifier les montants dus à l'entreprise et au chasseur | identité du chasseur, honoraires, barème, tranche, taux appliqué, montant de commission | chasseurs | Exécution du contrat et obligations comptables applicables | Pendant la relation contractuelle puis conservation des pièces comptables concernées pendant 10 ans à compter de la clôture de l'exercice | chasseur pour les informations le concernant, personnel administratif/comptable autorisé | Non |
| Facturation et paiement du chasseur | Vérifier les factures et enregistrer les règlements | identité du chasseur, référence et montant de facture, dates, statut, montants et dates de paiement | chasseurs | Obligation légale comptable | 10 ans à compter de la clôture de l'exercice pour les factures et pièces justificatives comptables | chasseur pour les informations le concernant, personnel administratif/comptable autorisé | Non |

---

## 3. Données sensibles

Le modèle cible n'a pas pour finalité de collecter des catégories particulières
de données personnelles au sens du RGPD, telles que les données de santé,
les opinions politiques, les convictions religieuses, l'origine ethnique,
l'orientation sexuelle ou les données biométriques utilisées pour identifier
une personne.

Les zones de texte libre, notamment les commentaires, retours de visite,
avis et motifs de refus, présentent néanmoins un risque de saisie accidentelle
d'informations non nécessaires.

Ces champs devront donc faire l'objet de consignes de saisie et de contrôles
adaptés afin de limiter la collecte aux informations utiles au service.

---

## 4. Minimisation des données

Le principe de minimisation signifie que le système ne doit collecter que
les données réellement nécessaires à une finalité identifiée.

Dans Match Immo :

- les données d'identité sont centralisées dans `UTILISATEUR` afin d'éviter
  leur duplication entre les profils client et chasseur ;
- l'historisation des critères et affectations répond à un besoin métier
  explicite et ne doit pas devenir une conservation illimitée ;
- aucune catégorie particulière de données sensibles n'est demandée par le
  modèle métier ;
- les futurs traitements analytiques ou d'intelligence artificielle ne
  justifient pas une collecte supplémentaire par anticipation ;
- les données devenues inutiles doivent être supprimées ou anonymisées
  lorsqu'aucune obligation de conservation ne s'y oppose.

---

## 5. Sécurité et contrôle des accès

L'accès aux données personnelles doit respecter le principe du moindre
privilège : une personne ou une application ne doit disposer que des droits
nécessaires à sa mission.

Le système cible devra notamment prévoir :

- une authentification des accès ;
- des droits adaptés aux rôles ;
- l'absence d'utilisation quotidienne d'un compte PostgreSQL administrateur
  par les applications ;
- le chiffrement des communications exposant des données personnelles dans
  un environnement déployé ;
- la journalisation des opérations sensibles lorsque celle-ci est nécessaire ;
- la protection des sauvegardes contenant des données personnelles.

Les mécanismes techniques précis seront contrôlés lors des phases
d'implémentation et de tests.

---

## 6. Droits des personnes

Le système devra permettre de traiter les demandes relatives aux droits
prévus par le RGPD lorsque ceux-ci sont applicables, notamment :

- droit d'accès ;
- droit de rectification ;
- droit à l'effacement ;
- droit à la limitation ;
- droit à la portabilité pour les traitements concernés ;
- droit d'opposition lorsque la base légale du traitement le permet.

L'exercice d'un droit ne signifie pas nécessairement la suppression immédiate
de toutes les données : certaines informations peuvent devoir être conservées
pour respecter une obligation légale, par exemple la conservation réglementaire
des mandats ou des pièces comptables.

---

## 7. IA, analytique et données de test

Les futurs traitements analytiques ou d'intelligence artificielle feront
l'objet d'une analyse spécifique avant leur mise en œuvre.

Les données personnelles ne devront pas être transmises automatiquement à un
service d'IA ou à un tiers simplement parce qu'elles existent dans la base.

Selon le besoin, les données devront être minimisées, anonymisées ou
pseudonymisées avant utilisation.

La pseudonymisation consiste à remplacer les éléments directement identifiants
par des identifiants indirects tout en conservant séparément la possibilité
de rétablir le lien.

L'anonymisation vise, elle, à empêcher de manière irréversible l'identification
de la personne.

Les jeux de données de développement et de test devront privilégier les données
fictives ou anonymisées.

---

## 8. Justification des principales durées et bases légales

Les durées de conservation ne sont pas choisies arbitrairement.

Pour les traitements nécessaires à une relation contractuelle ou aux mesures
précontractuelles demandées par la personne, la base légale « contrat » est
retenue uniquement lorsque le traitement est objectivement nécessaire à cette
relation.

Pour les mandats immobiliers, l'article 72 du décret n° 72-678 du
20 juillet 1972 prévoit une conservation des mandats et du registre des mandats
pendant dix ans.

Pour les factures et autres pièces justificatives comptables, les règles
applicables aux entreprises prévoient une conservation de dix ans à compter
de la clôture de l'exercice.

Lorsqu'aucun texte ne fixe une durée précise, le principe retenu est celui
rappelé par la CNIL : la durée doit être déterminée en fonction de la finalité
du traitement et les données ne doivent pas être conservées indéfiniment.

---

## 9. Références

Sources réglementaires et institutionnelles consultées :

- CNIL — « Le contrat : dans quels cas fonder un traitement sur cette base légale ? »
- CNIL — « Les durées de conservation des données »
- CNIL — « L'obligation légale : dans quels cas fonder un traitement sur cette base légale ? »
- Légifrance — Décret n° 72-678 du 20 juillet 1972, article 72
- Entreprendre.Service-Public.fr — « Quels sont les délais de conservation des documents pour les entreprises ? »

Documents internes du projet :

- `02-modele-cible/mld-cible-final.md`
- `02-modele-cible/cahier-des-charges-technique-MAJ.md`
- `02-modele-cible/besoins-metier-final.md`

---

## 10. Conclusion

Ce registre permet de relier les données personnelles du modèle cible à une
finalité, une base légale, une durée de conservation et des règles d'accès.

Il constitue une preuve de prise en compte du RGPD dès la conception du système.

Il devra évoluer si de nouveaux traitements, de nouvelles données, des services
tiers ou des fonctionnalités d'intelligence artificielle sont introduits dans
le projet.
