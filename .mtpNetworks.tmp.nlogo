;; je fais appel à l'extension GIS pour gerer les fichiers gis
extensions [gis table]


breed [stations station]


;; je declare  une variable global pour le jeu de donnes

globals [my-features my-unique-vertices my-turtle-table]

stations-own
[
  final_destination? ; indicate if the station could be a final_destination for clients or not (0=not et 1=yes)
  gross_potential  ; gross potential of attractivity of the station
  net_potential  ; net potential of attractivity of the station : gross_potential / potential of the most attractive station
  nb_clients_waiting  ; number of clients waiting at the station
  clients_station_waiting_net   ; nb_clients_waiting / max_clients_station_waiting
  nb_clients_picked_up_station  ; total number of clients picked up at the station
  nb_clients_droped  ; number of clients droped at the station
  bus_line ; 0 = the station not belongs to a bus line, 1 = the station belongs to the bus line 1, etc...
  frequentation ; number of times that a vehicle crosses the station
  linked?
]


;;  Reinitatliser

to setup

  ;; Réinitialisation complète de l'environnement
  clear-all      ; Efface tout (agents, plots, etc.)
  reset-ticks    ; Remet le compteur à 0

  ;; Réinitialisation spécifique des variables globales GIS
  set my-features []

  set my-unique-vertices []

  set my-turtle-table []

end




;;La fonction si set les valeur de my-dataset et my-features

to-report get-features-from-dataset [path]

  let features []

  let path-shp word path ".shp"

  let path-prj word path ".prj"

  if ( not file-exists? path-shp) or ( not file-exists? path-prj) [

     let paths (word (word path-shp "  et   " ) path-prj)

     print word "Verifiez l'un des deux paths :> " paths


  ]
  carefully [

    gis:load-coordinate-system path-prj

    let dataset gis:load-dataset path-shp

    gis:set-world-envelope gis:envelope-of dataset

    set features gis:feature-list-of dataset

    print word "Nbrs-features :> " length features



  ]

  [
    print (word "ERREUR : " error-message)

  ]

  report features
end

;; Je vais à partir de features extraire les points des lignes et supprimer les doublons et retourne la liste unique

to-report extract-vertex-from-features [features]

  let my-list []

  foreach features [ ?1 ->

    let feature ?1

    foreach  gis:vertex-lists-of feature [ ??1 ->

      let vertex-list ??1

      foreach vertex-list [ ???1 ->

        let loc gis:location-of ???1

        if not empty? loc [
          set my-list fput (list (item 0 loc) (item 1 loc)) my-list
        ]

      ]

    ]

  ]

  let my-list-unique remove-duplicates my-list

  print word "list avec doublons :> " length my-list
  print word "list sans doublons :> " length my-list-unique

  report my-list-unique

end

;; la fonction permet dans un premier temps creer des turtles et à la fin retourner un table de turtles

to-report get-create-turtles-from-coords [coords]

  let turtle-table table:make

  create-stations length coords [

    set final_destination? 0

    set shape "circle"

    set color green

    set size 0.3

    let coord item who coords

    let x item 0 coord

    let y item 1 coord

    setxy x y

    let key stable-key x y

    table:put turtle-table key self
  ]

  let all-stations turtles with [breed = stations]

  ask n-of (length coords / 2) all-stations
  [
    set final_destination? 1
    set shape "flag"
    set color red

  ]

  report turtle-table
end

to-report stable-key [x y]
  report (word x "," y)
end

;;
to create-links [turtle-table features]

  foreach features [ ?1 ->

    let vertex-lists gis:vertex-lists-of ?1

    foreach vertex-lists [ ??1 ->
      let vertices ??1

      ;; Utilise une boucle par index plutôt que `n-values` pour la clarté
      let i 0
      while [i < length vertices - 1] [
        let v1 item i vertices
        let v2 item (i + 1) vertices

        let loc1 gis:location-of v1
        let loc2 gis:location-of v2

        if (loc1 != [] and loc2 != []) [
          let x1 item 0 loc1
          let y1 item 1 loc1
          let x2 item 0 loc2
          let y2 item 1 loc2

          let key1 stable-key x1 y1
          let key2 stable-key x2 y2

          if (table:has-key? turtle-table key1 and table:has-key? turtle-table key2) [
            ask table:get turtle-table key1 [
              create-link-with table:get turtle-table key2
            ]
          ]
        ]

        set i i + 1
      ]
    ]
  ]
end


to create-network-from-shp-file [path]

  setup

  ;; je charge les features

  set my-features get-features-from-dataset path

  ;;Extraire les sommets de facon uniques

  set my-unique-vertices extract-vertex-from-features my-features

  ;; à partir de my-unique-vertices je cree des turtles puis je stocke las turtles dans my-turtle-list

  set my-turtle-table get-create-turtles-from-coords my-unique-vertices


  ;;je cree les link entre les turtles

  create-links my-turtle-table my-features


end

to-report produit-scalaire [a b c]

  let bax ([xcor] of a - [xcor] of b)

  let bay ([ycor] of a - [ycor] of b)

  let bcx ([xcor] of c - [xcor] of b)

  let bcy ([ycor] of c - [ycor] of b)

  let scal (bax * bcx + bay * bcy)

  report scal

end

to-report distances [a b c]

  let ba [distance b] of a

  let bc [distance b] of c

  let ac [distance c] of a

  if ( ba = 0 or bc = 0) [

    report (list 0 0 0)
  ]
  report (list ba bc ac)

end

to-report angle-between-and-rapport [ba bc scal]

  let ratio  (scal / (ba * bc))

  let safe-ratio max list -1 (min list 1 ratio)

  report acos safe-ratio
end

to simplify-by-angle [limite]

  ask stations with [count my-links = 2] [

    let voisins sort link-neighbors

    if (length voisins = 2) [

    let voisinA item 0 voisins

    let voisinC item 1 voisins


    let scalaire produit-scalaire voisinA self voisinC

    let distances-list distances voisinA self voisinC

    let ba item 0 distances-list

    let bc item 1 distances-list

    let angle angle-between-and-rapport ba bc scalaire

    if (angle > limite or (ba / bc > 1 or bc / ba > 1)) [

      ask voisinA [
       create-link-with voisinC
      ]

      ask self [
         set color white

      ]

      ask my-links [die]
    ]

    ]
  ]
  delete-station-degre-one
end

to delete-station-degre-one

  ask stations with [count my-links = 0] [
   die
  ]
end




to export-csv-line-vertices-info [file path]


  create-network-from-shp-file path


  ;; Ouverture du fichier de sortie

  let max-sommets 0

  foreach my-features [ ?1 ->

    let feature ?1

    let total 0
    foreach gis:vertex-lists-of feature [ ??1 ->

      set total total + length ??1
    ]
    if total > max-sommets [ set max-sommets total ]
  ]

  print word  "max-sommets :> " max-sommets

  if file-exists? file [

      file-close

      file-delete file

  ]

  file-open file

  ;; En-tête du fichier CSV
  let header "ID,NATURE,nbrs-sommets"

  let i 1

  while [i <= max-sommets] [

    set header word header (word "," "Turtle-ID" i "," "degre" ",x" i ",y" i)

    set i i + 1
  ]

  print header

  file-print header


  ;; Parcours de chaque feature
  foreach my-features [ ?1 ->

    let feature ?1

    let ID gis:property-value feature "ID"

    let NATURE gis:property-value feature "NATURE"

    let vertex-lists gis:vertex-lists-of feature

    let nbrs-sommets 0

    let string ""

    foreach vertex-lists [ ??1 ->

      let vertices ??1

      set nbrs-sommets length vertices

      foreach vertices [ ???1 ->

      let vertex ???1

      let loc gis:location-of vertex

      if( loc != [] )[

        let key stable-key item 0 loc item 1 loc

        if (table:has-key? my-turtle-table key) [

            let trl table:get my-turtle-table key

            ask trl [

              set string (word string "," who "," count link-neighbors "," xcor "," ycor )


            ]
        ]
      ]


      ]

      file-print (word ID "," NATURE "," word nbrs-sommets string)
    ]
  ]

  file-close

  setup
end

@#$#@#$#@
GRAPHICS-WINDOW
210
10
1063
864
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-32
32
-32
32
0
0
1
ticks
30.0

BUTTON
9
33
72
66
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
9
83
248
116
create-network-from-shp-extractMap
create-network-from-shp-file \"extractMap/extractMap\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
8
136
246
169
create-network-from-shp--middleMap
create-network-from-shp-file \"middleMap/middleMap\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
9
189
226
222
create-network-from-shp-FullMap
create-network-from-shp-file \"FullMap/FullMap\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
5
512
287
545
export-csv-nbrs-sommets-by-lines-middleMap
export-csv-line-vertices-info \"nbrs-sommets-par_lignes-middleMap.csv\" \"middleMap/middleMap\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
6
549
272
582
export-csv-nbrs-sommets-by-lines-FullMap
export-csv-line-vertices-info \"nbrs-sommets-par_lignes-FullMap.csv\" \"FullMap/FullMap\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
6
474
294
507
export-csv-nbrs-sommets-by-lines-extractMap
export-csv-line-vertices-info \"nbrs-sommets-par_lignes-extractMap.csv\" \"extractMap/extractMap\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1154
33
1298
66
NIL
simplify-by-angle 30
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
