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
