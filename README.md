Voici le contenu du `README.md` en **pur Markdown** (sans encadré), prêt à être copié dans un fichier :

````markdown
# 🗺️ NetLogo - Réseau de Stations depuis Shapefile (GIS)

Ce projet NetLogo construit et analyse un **réseau de stations** à partir d’un fichier **shapefile (.shp)** contenant des lignes (comme des routes ou lignes de bus). Il permet de créer un graphe spatial, de le simplifier, et d’en exporter les données.

---

## 📦 Fonctionnalités principales

- Chargement de shapefiles via l’extension `gis`
- Extraction et dé-duplication des sommets
- Création de nœuds (`stations`) et liens (`links`)
- Simplification topologique par angle
- Export des stations et des liens au format CSV

---

## 🧩 Extensions NetLogo utilisées

- [`gis`](https://ccl.northwestern.edu/netlogo/docs/gis.html) : pour manipuler des fichiers géographiques
- `table` : pour gérer les associations entre coordonnées et agents

---

## ⚙️ Utilisation

### 1. Charger le fichier shapefile

```netlogo
create-network-from-shp-file "data/ligne_bus"
````

### 2. Simplifier le réseau

```netlogo
simplify-by-angle 0.2
```

### 3. Exporter les données

```netlogo
export-csv-line-vertices-info "exports/stations.csv" "data/ligne_bus"
export-turtles-coords-and-degrees "exports/nodes.csv"
export-vertices-as-points "exports/points.csv" "data/ligne_bus"
```

---

## 🐢 Structure des agents `stations`

| Variable                       | Description                                               |
| ------------------------------ | --------------------------------------------------------- |
| `final_destination?`           | Est-ce une station de destination finale (1 ou 0)         |
| `gross_potential`              | Potentiel brut d’attractivité                             |
| `net_potential`                | Potentiel net par rapport à la station la plus attractive |
| `nb_clients_waiting`           | Nombre de clients en attente                              |
| `clients_station_waiting_net`  | Ratio clients/max\_clients                                |
| `nb_clients_picked_up_station` | Clients embarqués                                         |
| `nb_clients_droped`            | Clients déposés                                           |
| `bus_line`                     | Ligne de bus associée (0 : aucune)                        |
| `frequentation`                | Fréquence de passage                                      |
| `linked?`                      | Connectée à d’autres stations ?                           |

---

## 📁 Structure des exports

### `stations.csv`

* ID de la ligne
* NATURE (type de ligne)
* Nombre de sommets
* Pour chaque sommet : Turtle ID, degré, coordonnées (x, y)

### `nodes.csv`

* ID turtle
* Coordonnées (x, y)
* Degré (nombre de connexions)

### `points.csv`

* ID ligne
* Coordonnées des sommets

---

## 📐 Calculs géométriques

Le script utilise :

* Produit scalaire pour calculer l’angle entre deux segments
* Distance entre points
* Rapport d’angle pour la simplification du graphe

---

## 📝 Requis

* NetLogo (version 6.2+ recommandée)
* Un fichier `.shp` et `.prj` valides
* Propriétés `"ID"` et `"NATURE"` dans le shapefile (utilisées pour l'export)

---

## 📌 Exemple complet

```netlogo
create-network-from-shp-file "data/ligne_bus"
simplify-by-angle 0.25
delete-station-degre-one
export-csv-line-vertices-info "exports/stations.csv" "data/ligne_bus"
```

---

## 🛠️ Auteur

Ce projet a été développé pour l’analyse et la modélisation de réseaux de transport à partir de données SIG (Shapefile).

---

## 📃 Licence

À définir (MIT, GPL, etc.)

```

Souhaite-tu aussi un fichier `.gitignore` pour NetLogo ?
```
