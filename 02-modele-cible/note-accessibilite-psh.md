# Note d’accessibilité PSH

## 1. Objectif

Cette note définit les préconisations d’accessibilité à appliquer aux futures interfaces de MatchImmo.

**PSH** signifie *Personnes en Situation de Handicap*.

L’objectif est que les parcours essentiels de l’application puissent être utilisés aussi largement que possible, notamment par des personnes utilisant un clavier, un lecteur d’écran ou ayant des difficultés visuelles ou motrices.

L’accessibilité est prise en compte dès la conception afin que le backend, les données et les interfaces ne créent pas de blocage ultérieur.

## 2. Principes retenus

Les interfaces MatchImmo devront respecter les principes suivants :

- présenter des informations textuelles claires et compréhensibles ;
- utiliser des libellés explicites pour les champs, boutons et actions ;
- afficher des messages d’erreur compréhensibles et indiquant comment corriger le problème ;
- ne jamais transmettre une information uniquement par une couleur ;
- prévoir des contrastes suffisants entre le texte, les composants et leur arrière-plan ;
- permettre l’utilisation complète des fonctions principales au clavier ;
- conserver un ordre de navigation clavier logique et visible ;
- prévoir des zones cliquables suffisamment grandes pour faciliter leur utilisation ;
- fournir une alternative textuelle aux images ou éléments visuels porteurs d’information ;
- structurer correctement les contenus afin de faciliter leur lecture par les technologies d’assistance ;
- rendre les statuts métier compréhensibles sous forme textuelle, par exemple « favorable », « difficile » ou « très restrictive ».

## 3. Application au projet MatchImmo

Ces principes concernent notamment les écrans prévus en phase applicative :

- saisie et consultation d’une demande immobilière ;
- restitution de l’analyse de faisabilité ;
- affichage des résultats de matching ;
- consultation du détail d’un bien ;
- synthèse destinée au chasseur immobilier ;
- validation humaine d’une proposition ou d’une analyse.

Les résultats produits par le backend doivent rester exploitables sous forme textuelle. Les informations importantes, les erreurs, les scores et les points de vigilance ne doivent donc pas dépendre uniquement d’un graphique, d’une icône ou d’une couleur.

Cette exigence est cohérente avec les choix déjà retenus pour l’API, qui restitue les résultats métier sous une forme structurée et textuelle.

## 4. Vérification prévue

L’accessibilité devra être vérifiée lors de la réalisation et de la recette des interfaces.

Les contrôles porteront au minimum sur :

- la navigation intégrale au clavier ;
- la visibilité du focus clavier ;
- la lisibilité des contrastes ;
- la présence de libellés compréhensibles ;
- les alternatives textuelles nécessaires ;
- la taille et l’utilisabilité des boutons et zones interactives ;
- la compréhension des erreurs sans dépendre uniquement de la couleur ;
- la cohérence de lecture avec les technologies d’assistance.

## 5. Conclusion

L’accessibilité PSH est intégrée comme exigence de conception de MatchImmo et non comme correction ajoutée en fin de projet.

La présente note constitue le cadre de préconisations à appliquer aux interfaces. La conformité effective devra être vérifiée lors de leur réalisation et de leur recette.
