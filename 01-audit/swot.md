# SWOT — Système d’information existant

Date de référence : **25 juillet 2026**.

Cette analyse porte sur le système d’information de l’entreprise de chasse immobilière.

## Forces

Éléments internes favorables :

- L’entreprise exerce une activité rentable.
- Le site web et le logiciel métier existent déjà et peuvent être conservés.
- Une base historique permet d’identifier les utilisateurs, les mandats et les secteurs.
- Les données disponibles permettent de préparer et tester leur reprise.
- Des clés primaires, clés étrangères et contraintes d’unicité assurent un premier niveau d’intégrité.

## Faiblesses

Éléments internes défavorables :

- Le code source du backend existant est inexploitable.
- Clients et chasseurs sont regroupés dans une même table.
- Les rôles associés aux mandats ne sont pas suffisamment contrôlés.
- La durée et les renouvellements des mandats ne sont pas correctement suivis.
- Les critères de recherche sont enregistrés en texte libre.
- La base historique ne couvre pas l’ensemble du parcours métier.
- Une partie de l’information repose sur des dossiers papier.

Les anomalies détaillées figurent dans `registre-anomalies.md`.

## Opportunités

Éléments externes favorables :

- Accès à de nouveaux marchés en France et dans les DROM.
- Possibilités de développement dans plusieurs pays européens.
- Possibilités de croissance externe par acquisition d’autres entreprises.
- Disponibilité de technologies d’analyse de données et d’intelligence artificielle.

## Menaces

Éléments externes défavorables :

- Hausse prévisible des volumes liée au développement du marché.
- Diversité des règles et pratiques applicables selon les pays.
- Risque de non-conformité aux réglementations sur les données personnelles.
- Risques de sécurité liés à l’exploitation et au partage des données.

## Stratégies croisées

| Croisement | Orientation |
| --- | --- |
| Forces × Opportunités | Conserver les applications existantes et exploiter les données disponibles pour accompagner le développement de l’activité. |
| Forces × Menaces | Utiliser les données et contraintes existantes pour préparer une reprise maîtrisée et sécurisée. |
| Faiblesses × Opportunités | Structurer les données métier afin de faciliter l’extension géographique et les futurs usages analytiques. |
| Faiblesses × Menaces | Remplacer le backend inexploitable, fiabiliser les mandats et anticiper les exigences de sécurité et de croissance. |

## Conclusion

L’entreprise dispose d’une activité rentable et d’applications existantes, mais son backend et son modèle de données présentent des limites importantes.

La modernisation devra conserver le site web et le logiciel métier, fiabiliser les données et préparer la croissance de l’activité.
