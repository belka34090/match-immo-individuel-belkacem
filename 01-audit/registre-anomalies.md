# Registre des anomalies et risques

| ID | Anomalie | Type | Impact | Priorité | Preuve |
|---|---|---|---|---|---|
| A-01 | Le mandat 13 référence un utilisateur de rôle `chasseur` comme client | Intégrité métier | Relation client/mandat incohérente | Haute | `preuves/03-anomalies/resultats-anomalies.md` |
| A-02 | Six mandats sont encore `actif` alors que leur durée théorique de six mois est dépassée au 25/07/2026 | Cohérence métier | Statut potentiellement obsolète et suivi des mandats incorrect | Haute | `preuves/03-anomalies/resultats-anomalies.md` |