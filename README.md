
---

````markdown
# 🚏 Réseau de Stations avec NetLogo : Construction, Simplification et Export

Ce projet permet de construire, analyser et exporter un **réseau de stations** à partir d’un fichier **Shapefile (.shp)** en utilisant **NetLogo**. Il intègre des fonctions pour :

- Créer le réseau depuis des lignes géographiques
- Identifier et simplifier les nœuds du réseau selon leur alignement
- Exporter des informations structurées dans un fichier CSV

---

## 🧩 Extensions nécessaires

```netlogo
extensions [gis table]
````

* `gis` : pour manipuler des fichiers SIG (shapefiles)
* `table` : pour stocker et retrouver les nœuds rapidement

---

## 📄 Données nécessaires

* Un fichier `.shp` et son fichier de projection `.prj`
* Les propriétés `ID` et `NATURE` doivent être présentes dans les entités géographiques

---

## 🚀 Lancement rapide

```netlogo
create-network-from-shp-file "data/ton_fichier_sans_extension"
simplify-by-angle 170
export-csv-line-vertices-info "exports/ligne_stations.csv" "data/ton_fichier_sans_extension"
```

---

## 📚 Description des fonctions

### ⚙️ Initialisation

| Fonction | Description                                                               |
| -------- | ------------------------------------------------------------------------- |
| `setup`  | Réinitialise l'environnement NetLogo, les variables et efface les agents. |

---

### 📥 Import du réseau depuis un fichier `.shp`

| Fonction                                  | Rôle                                                                                            |
| ----------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `get-features-from-dataset [path]`        | Charge un shapefile et retourne les entités (features).                                         |
| `extract-vertex-from-features [features]` | Extrait tous les sommets des lignes et supprime les doublons.                                   |
| `get-create-turtles-from-coords [coords]` | Crée des `stations` (turtles) à partir des coordonnées et retourne une table de correspondance. |
| `create-links [table features]`           | Crée les connexions (liens) entre stations à partir des lignes du shapefile.                    |
| `create-network-from-shp-file [path]`     | Fonction principale qui appelle toutes les étapes précédentes pour construire le réseau.        |

---

### 🧠 Logique de simplification

| Fonction                                                     | Rôle                                                                                     |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------------- |
| `simplify-by-angle [limite]`                                 | Supprime les stations intermédiaires quasi-alignées (si angle entre voisins > `limite`). |
| `produit-scalaire`, `distances`, `angle-between-and-rapport` | Utilitaires pour calculer les angles entre trois nœuds consécutifs.                      |
| `delete-station-degre-one`                                   | Supprime les stations sans connexion (isolées).                                          |

✅ **Exemple :**

```netlogo
simplify-by-angle 170
```

---

### 📤 Export CSV

| Fonction                                       | Fichier généré       | Rôle                                                                                      |
| ---------------------------------------------- | -------------------- | ----------------------------------------------------------------------------------------- |
| `export-csv-line-vertices-info [fichier path]` | `ligne_stations.csv` | Pour chaque ligne : ID, NATURE, nombre de sommets, Turtle-ID, degré, coordonnées `(x, y)` |

✅ **Exemple :**

```netlogo
export-csv-line-vertices-info "exports/ligne_stations.csv" "data/ton_fichier_sans_extension"
```


---

## 📈 Données enregistrées dans `stations-own`

| Attribut                       | Signification                                            |
| ------------------------------ | -------------------------------------------------------- |
| `final_destination?`           | Si la station peut être une destination finale (1 = oui) |
| `gross_potential`              | Attractivité brute de la station                         |
| `net_potential`                | Potentiel normalisé de la station                        |
| `nb_clients_waiting`           | Nombre de clients en attente                             |
| `clients_station_waiting_net`  | Ratio des clients en attente par rapport au max          |
| `nb_clients_picked_up_station` | Total de clients embarqués à la station                  |
| `nb_clients_droped`            | Nombre de clients déposés                                |
| `bus_line`                     | Ligne de bus à laquelle la station appartient            |
| `frequentation`                | Fréquence de passage des véhicules                       |
| `linked?`                      | Booléen pour indiquer si la station est connectée        |

---

## 🧑‍💻 Auteur

Ce script a été conçu pour simuler et analyser des réseaux de transport urbain à partir de données géographiques SIG.

---


