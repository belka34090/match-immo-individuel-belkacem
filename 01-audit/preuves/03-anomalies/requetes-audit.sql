SET search_path TO "Fil_Rouge_Depart";

-- 1. Vérifier que client_id référence bien un utilisateur de rôle client
SELECT
    m.id AS mandat_id,
    m.client_id,
    u.nom,
    u.prenom,
    u.role
FROM mandats m
JOIN utilisateurs u ON u.id = m.client_id
WHERE u.role <> 'client';


-- 2. Vérifier que chasseur_id référence bien un utilisateur de rôle chasseur
SELECT
    m.id AS mandat_id,
    m.chasseur_id,
    u.nom,
    u.prenom,
    u.role
FROM mandats m
JOIN utilisateurs u ON u.id = m.chasseur_id
WHERE u.role <> 'chasseur';


-- 3. Vérifier les mandats marqués actif mais dépassant 6 mois au 25/07/2026
SELECT
    id AS mandat_id,
    client_id,
    chasseur_id,
    date_debut,
    date_debut + INTERVAL '6 months' AS date_fin_theorique,
    statut
FROM mandats
WHERE statut = 'actif'
  AND date_debut + INTERVAL '6 months' < DATE '2026-07-25';



-- 4. Vérifier les doublons de secteurs sur (ville, quartier)
SELECT
    ville,
    quartier,
    COUNT(*) AS nombre
FROM secteurs
GROUP BY ville, quartier
HAVING COUNT(*) > 1;


-- 5. Vérifier le format des codes postaux présents
SELECT
    id,
    ville,
    quartier,
    code_postal
FROM secteurs
WHERE code_postal !~ '^[0-9]{5}$';


-- 6. Identifier les clients sans téléphone
SELECT
    id,
    nom,
    prenom,
    telephone
FROM utilisateurs
WHERE role = 'client'
  AND telephone IS NULL;


-- 7. Vérifier les formats d'email manifestement invalides
SELECT
    id,
    email
FROM utilisateurs
WHERE email !~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$';


-- 8. Vérifier la cohérence entre le rôle et les colonnes spécifiques
SELECT
    id,
    role,
    nom,
    prenom,
    taux_commission,
    budget_max
FROM utilisateurs
WHERE (role = 'chasseur' AND budget_max IS NOT NULL)
   OR (role = 'client' AND taux_commission IS NOT NULL);


-- 9. Vérifier les budgets et taux de commission non positifs
SELECT
    id,
    role,
    nom,
    prenom,
    taux_commission,
    budget_max
FROM utilisateurs
WHERE (budget_max IS NOT NULL AND budget_max <= 0)
   OR (taux_commission IS NOT NULL AND taux_commission <= 0);


-- 10. Vérifier les références cassées dans les mandats
SELECT
    m.id
FROM mandats m
LEFT JOIN utilisateurs c ON c.id = m.client_id
LEFT JOIN utilisateurs ch ON ch.id = m.chasseur_id
LEFT JOIN secteurs s ON s.id = m.secteur_id
WHERE c.id IS NULL
   OR ch.id IS NULL
   OR (m.secteur_id IS NOT NULL AND s.id IS NULL);


-- 11. Vérifier les mandats sans secteur
SELECT
    id,
    client_id,
    chasseur_id,
    secteur_id
FROM mandats
WHERE secteur_id IS NULL;


-- 12. Vérifier les recherches absentes ou vides
SELECT
    id,
    description_recherche
FROM mandats
WHERE description_recherche IS NULL
   OR TRIM(description_recherche) = '';


-- 13. Vérifier les mandats antérieurs à la création du client
SELECT
    m.id AS mandat_id,
    m.date_debut,
    c.id AS client_id,
    c.nom,
    c.prenom,
    c.date_creation
FROM mandats m
JOIN utilisateurs c ON c.id = m.client_id
WHERE c.date_creation > m.date_debut;


-- 14. Vérifier les mandats antérieurs à la création du chasseur
SELECT
    m.id AS mandat_id,
    m.date_debut,
    ch.id AS chasseur_id,
    ch.nom,
    ch.prenom,
    ch.date_creation
FROM mandats m
JOIN utilisateurs ch ON ch.id = m.chasseur_id
WHERE ch.date_creation > m.date_debut;


-- 15. Vérifier qu'un même utilisateur n'est pas client et chasseur du même mandat
SELECT
    id,
    client_id,
    chasseur_id
FROM mandats
WHERE client_id = chasseur_id;


-- 16. Vérifier les utilisateurs créés après la date de référence du projet
SELECT
    id,
    role,
    nom,
    prenom,
    date_creation
FROM utilisateurs
WHERE date_creation > DATE '2026-07-25';
