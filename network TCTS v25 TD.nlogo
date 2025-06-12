;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Extension
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

extensions [GIS]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; breeds
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

breed [vehicles vehicle]
breed [stations station] ; stop
breed [clients client]
breed [buses bus]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

globals
[
  list_final_destinations  ; list with the identifiant of each final_destination station
  list_vehicles  ; list with the identifiant of each vehicle
  list-buses; list with the identifiant of each bus
  patterns  ; number of patterns simulated
  total_nb_clients_final_destination   ; number of clients arrived at final_destination
  total_nb_clients_created  ; number of clients created during the simulation (= patterns * nb_clients)
  total_nb_clients_created_bus_line  ; number of clients created during the simulation, with a final_destination station of the bus line
  servincing_rate  ; (total_nb_clients_final_destination / total_nb_clients_created) * 100
  servincing_rate_bus_line  ; (total_nb_clients_final_destination / total_nb_clients_created_bus_line) * 100
  client_station_rate  ; number of stations with some clients waiting a vehicle, divided by the total number of stations
  mean_pick_up_rate   ; mean of the pick up rate of vehicles
  mean_vpk   ; mean of the gains of vehicles
  list_stations_clients_waiting    ; list of stations with some clients waiting a vehicle
  path_bus_line_1    ; list of stations of the bus line 1
  path_bus_line_2    ; list of stations of the bus line 2
  path_bus_line_3    ; list of stations of the bus line 3
  shp_network
  conect.O
  conect.D
  candidate_O
  file_name
  nb_bus_line    ; number of active bus line
  date-time
  town-dataset
  road-dataset
  nb-road
]

vehicles-own
[
current_node  ; station where is the vehicle at the t time
next_node  ; next station reached by the vehicle (at t+1)
state   ; Variable allows the sequencing of vehicle's processes
nb_clients_picked_up  ; number of clients in the vehicle at the t time
selected_clients  ; clients with the same final_destination of the vehicle, picked up at t+1
my_clients  ; list of clients in the vehicule at the t time
final_destination_vehicle ; station final_destination of the vehicle when it is occupied by one or more clients
nb_stations_crossed  ; number of stations crossed by the vehicle during the simulation
nb_stations_picked_up_clients  ; number of stations where the vehicle had picked up clients
pick_up_rate  ; (nb_stations_picked_up_clients / nb_stations_crossed)*100
total_nb_clients_picked_up    ; total number of clients picked up during the simulation
vpk ; ((total_nb_clients_picked_up * 10) - distance_travelled)
occupation_rate_vehicle ; (nb_clients_picked_up / capacity_occupation) * 100
distance_travelled    ; distance travelled during the simulation
]

buses-own
[
current_node  ; station where is the vehicle at the t time
next_node  ; next station reached by the vehicle (at t+1)
state   ; Variable allows the sequencing of bus's processes
nb_clients_picked_up  ; number of clients in the bus at the t time
selected_clients  ; clients with the same final_destination of the bus, picked up at t+1
my_clients  ; list of clients in the bus at the t time
clients_to_drop    ; clients to drop at the current station
nb_stations_crossed  ; number of stations crossed by the bus during the simulation
nb_stations_picked_up_clients  ; number of stations where the bus had picked up clients
pick_up_rate  ; (nb_stations_picked_up_clients / nb_stations_crossed)*100
distance_travelled    ; distance travelled during the simulation
total_nb_clients_picked_up    ; total number of clients picked up during the simulation
vpk ; ((total_nb_clients_picked_up * 10) - distance_travelled)
direction ; direction of the bus (0 or 1) according to the order of the stations on the bus line
position_station_bus_line_1    ; position of the current station on the bus line 1
position_station_bus_line_2    ; position of the current station on the bus line 2
position_station_bus_line_3    ; position of the current station on the bus line 3
occupation_rate_bus ; (nb_clients_picked_up / capacity_occupation) * 100
]

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

clients-own
[
final_destination  ; final_destination final of the client (by using a transportation service)
station_to_wait  ; station where the client will wait a transportation service
bus_line?   ; indicate if the final final_destination of the client belongs to a bus line
direction-bus_line ; indicate in wich direction the client have to go on the bus line (0 or 1)
vehicle?  ; indicate if the client is in a vehicle (1) or not (0)
]

links-own
[
gross_traffic  ; vehicle frequentation of the axe
net_traffic  ; vehicle frequentation of the axe / max vehicle frequentation of axes
]

patches-own
[
  town?
  road?
]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; total initialisation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to total.initialisation
  ca
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GIS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to initialisation-gis
  set town-dataset gis:load-dataset "town.shp"
  set road-dataset gis:load-dataset "road.shp"
  gis:set-world-envelope (gis:envelope-union-of (gis:envelope-of town-dataset))
  ask patches
  [
    set town? false
    set road? false
  ]
end

to import.town
   ask patches gis:intersecting town-dataset
  [
    set town? true
  ]
end

to import.road
  ask patches with [town?] gis:intersecting road-dataset
;  ask patches gis:intersecting road-dataset
  [
    set road? true
    set pcolor 4
  ]
end

to create.station.gis
  set nb-road count patches with [pcolor = 4]
  ask n-of (nb-road / 4) patches with [pcolor = 4]
  [
    sprout-stations 1
    [
      set size 0.5
      set color 45
      set shape "circle"
    ]
  ]
end

to connect.stations.gis ; Creer le reseau (liens entre les stations) en fonction d'une distance choisie par l'utilisateur (slider "max_distance_links")
  ask stations
  [
   ;create-links-with stations in-radius 1 with [who != [who] of myself]
    create-links-with stations with [distance myself = 3]
      [
        set color 9
        set thickness 0.1
      ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; random network
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to create.random.network
  __clear-all-and-reset-ticks
  set path_bus_line_1 []
  set path_bus_line_2 []
  create.stations.final.destination
  connect.station
end


to connect.station ;
  ask stations
  [
    create-links-with stations in-radius max_distance_connexion with [who != [who] of myself]
      [
        set color white
        set thickness 0.02
      ]
  ]
end


to create.stations.final.destination ;
  create-stations nb_stations
  [
    setxy random-xcor random-ycor
    set color green
    set size 1
    set shape "circle"
  ]
  ask n-of nb_destinations stations
  [
    set final_destination? 1
    set color red
    set size 3
    set shape "flag"
  ]
  set list_final_destinations [who] of stations with [ final_destination? = 1]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; manhattan network
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



to create.manhattan.network
  __clear-all-and-reset-ticks
  create.stations.destination.manhattan
  connect.stations.manhattan
  set path_bus_line_1 []
  set path_bus_line_2 []
end


to create.stations.destination.manhattan ; Creer un nombre de stations et de marches grace a des sliders
  let xnoeudcor 0
  let ynoeudcor 0

  while [ xnoeudcor <= max-pxcor ]
  [
    while [ynoeudcor <= max-pycor ]
    [


      create-stations 1
      [
        setxy xnoeudcor ynoeudcor
        set color green
        set size 1
        set shape "circle"
      ]
     set ynoeudcor ynoeudcor + distance_station_manhattan
   ]
  set xnoeudcor xnoeudcor + distance_station_manhattan
  set ynoeudcor 0
  ]

  ask n-of nb_destination_manhattan stations
  [
    set final_destination? 1
    set color red
    set size 3
    set shape "flag"
  ]
  set list_final_destinations [who] of stations with [ final_destination? = 1]
end

to connect.stations.manhattan ; Creer le reseau (liens entre les stations) en fonction d'une distance choisie par l'utilisateur (slider "max_distance_links")
  ask stations
  [
    create-links-with stations in-radius distance_station_manhattan with [who != [who] of myself]
      [
        set color 9
        set thickness 0.02
      ]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; import network file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to import.shp.network
 set shp_network gis:load-dataset file_name
 gis:set-world-envelope gis:envelope-of shp_network
 gis:set-drawing-color white
 gis:draw shp_network 0.5
end

to import.picture
  import-drawing file_name
end





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; draw network
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to create.destination
  ask patches with [pcolor = red]
  [
    sprout-stations 1
    [
      set final_destination? 1
      set size 3
      set color red
      set shape "flag"
    ]
    set pcolor black
  ]
  set list_final_destinations [who] of stations with [ final_destination? = 1]
end

to create.station
  ask patches with [pcolor = green]
  [
    sprout-stations 1
    [
      set size 3
      set color green
      set shape "circle"
    ]
    set pcolor 0
  ]
end

to apply.destination
  ask stations with [final_destination? = 1]
  [
    set size 3
    set color red
    set shape "flag"
  ]
end

to apply.station
  ask stations with [final_destination? = 0]
  [
    set size 3
    set color green
    set shape "circle"
  ]
end

to apply.road
  ask links
  [
    set thickness road_thickness
    set color road_color
  ]
end

to draw.stations
  if mouse-down?
  [
    ask patch mouse-xcor mouse-ycor
    [
      set pcolor green
      ask neighbors [set pcolor 0]
    ]
  ]
end

to draw.destination
  if mouse-down?
  [
    ask patch mouse-xcor mouse-ycor
    [
      set pcolor red
      ;ask neighbors [set pcolor 0]
    ]
  ]
end

to delete.patch
  if mouse-down?
  [
      ask patch mouse-xcor mouse-ycor
    [
      set pcolor black
    ]
  ]
end


to delete.stations
  if mouse-down?
  [
    let target-station min-one-of stations [distancexy mouse-xcor mouse-ycor]
    if [distancexy mouse-xcor mouse-ycor] of target-station < 1
    [
      ask target-station [die]
    ]
  ]
end

to clean.stations
  if mouse-down?
  [
    let target-station min-one-of stations [distancexy mouse-xcor mouse-ycor]
    if [distancexy mouse-xcor mouse-ycor] of target-station < 10
    [
      ask target-station [die]
    ]
  ]
end



to connect.stations.manual ; Creer le reseau (liens entre les stations) en fonction d'une distance choisie par l'utilisateur (slider "max_distance_links")
  if mouse-down?
  [
    while [mouse-down?]
    [
      set candidate_O min-one-of turtles [distancexy mouse-xcor mouse-ycor]
      if [distancexy mouse-xcor mouse-ycor] of candidate_O < 2
      [
        set conect.O candidate_O
        watch conect.O
      ]
      set conect.D min-one-of turtles [distancexy mouse-xcor mouse-ycor]
      while [([distancexy mouse-xcor mouse-ycor] of conect.D > 0.5) and (conect.D = conect.O)]
      [
        set conect.D min-one-of turtles [distancexy mouse-xcor mouse-ycor]
      ]
      watch conect.D
      ]
    if is-turtle? conect.O
    [
      ask conect.O
      [
        create-link-with conect.D
        [
          set color road_color
          set thickness road_thickness
        ]
        set linked? 1
      ]
    set conect.O 0
    set conect.D 0
    reset-perspective
    ]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; draw zone clients
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to draw.zone.clients
  if mouse-down?
  [
    ask patch mouse-xcor mouse-ycor
    [
      set pcolor zone-color
      if thick? [ask neighbors [set pcolor zone-color]]
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; erase zone clients
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to erase.zone.clients
  if mouse-down?
  [
    ask patch mouse-xcor mouse-ycor
    [
      set pcolor black
      if thick? [ask neighbors [set pcolor black]]
    ]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; draw sea
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to draw.sea
  if mouse-down?
  [
    ask patch mouse-xcor mouse-ycor
    [
      set pcolor 85
      if thick? [ask neighbors [set pcolor 85]]
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; draw nature
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to draw.nature
  if mouse-down?
  [
    ask patch mouse-xcor mouse-ycor
    [
      set pcolor 59
      if thick? [ask neighbors [set pcolor 59]]
    ]
  ]
end

to export.world
  set date-time date-and-time
  set date-time replace-item 2 date-time "."
  set date-time replace-item 5 date-time "."
  export-world (word date-time "-world.csv")
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; bus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to confirm.bus.line
  set path_bus_line_1 reverse path_bus_line_1
  user-message (word "stations of the bus line 1 are " path_bus_line_1)
  set nb_bus_line 1
  if not empty? path_bus_line_2
[
  set path_bus_line_2 reverse path_bus_line_2
  user-message (word "stations of the bus line 2 are " path_bus_line_2)
  set nb_bus_line (nb_bus_line + 1)

    if not empty? path_bus_line_3
    [
      set path_bus_line_3 reverse path_bus_line_3
      user-message (word "stations of the bus line 3 are " path_bus_line_3)
      set nb_bus_line (nb_bus_line + 1)
    ]
  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
222
15
820
656
-1
-1
2.1
1
10
1
1
1
0
0
0
1
0
280
0
300
0
0
1
ticks
30.0

BUTTON
829
101
939
134
import a shp file
import.shp.network
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
833
267
923
300
create station
create.station
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
873
387
983
420
NIL
delete.stations
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
55
30
177
63
NIL
total.initialisation
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
832
225
922
258
NIL
draw.stations
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
887
351
977
384
NIL
delete.patch
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
828
434
974
467
NIL
connect.stations.manual
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
827
477
915
522
NIL
conect.O
17
1
11

MONITOR
937
478
1023
523
NIL
conect.D
17
1
11

BUTTON
55
70
170
103
delete all stations
ask stations [die]
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
939
225
1054
258
NIL
draw.destination
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
939
268
1054
301
create destination
create.destination\n;ask patches [set pcolor black]
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
1100
223
1216
256
NIL
draw.zone.clients
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
943
101
1073
134
import an image file
import.picture
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
38
465
198
498
NIL
create.manhattan.network
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
38
545
213
578
nb_destination_manhattan
nb_destination_manhattan
1
100
30.0
2
1
NIL
HORIZONTAL

BUTTON
35
259
197
292
NIL
create.random.network
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
35
300
200
333
nb_stations
nb_stations
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
35
335
200
368
nb_destinations
nb_destinations
0
100
40.0
1
1
NIL
HORIZONTAL

SLIDER
35
374
200
407
max_distance_links
max_distance_links
0
100
100.0
1
1
NIL
HORIZONTAL

TEXTBOX
40
423
209
461
MANHATTAN NETWORK
15
0.0
1

TEXTBOX
869
193
1019
212
DRAW NETWORK
15
0.0
1

TEXTBOX
51
232
201
251
RANDOM NETWORK
15
0.0
1

TEXTBOX
25
5
220
43
TOTAL INITIALISATION
15
0.0
1

SLIDER
38
509
213
542
distance_station_manhattan
distance_station_manhattan
0
20
12.0
2
1
NIL
HORIZONTAL

BUTTON
75
704
157
737
Bus line 1
set path_bus_line_1 fput read-from-string user-input \"Enter bus line\" path_bus_line_1\nask station item 0 path_bus_line_1 [set bus_line 1]\nif length path_bus_line_1 > 1 [ask link item 0 path_bus_line_1 item 1 path_bus_line_1 [set thickness 2 set color yellow]]
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
68
618
173
651
Confirm bus line
confirm.bus.line
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
48
593
221
613
DEFINE THE BUS LINE
15
0.0
1

BUTTON
76
658
166
691
Clear bus line
set path_bus_line_1 []\nset path_bus_line_2 []\nset path_bus_line_3 []\nask links [set thickness 0.02 set color white]\nask stations [set bus_line 0]
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
1526
205
1601
238
create city
ask patches with [pcolor = 36] [sprout 1 [set shape \"house\" set size 1.2 set color 36]]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
1105
193
1201
212
DRAW ZONE
15
0.0
1

BUTTON
63
107
155
140
delete zone
ask patches [set pcolor black]\nask turtles with [shape = \"house\"] [die]
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
847
61
1064
94
enter the file name to be imported
set file_name user-input \"enter the file name\"
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
887
141
989
174
NIL
clear-drawing
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
75
739
157
772
Bus line 2
set path_bus_line_2 fput read-from-string user-input \"Enter bus line\" path_bus_line_2\nask station item 0 path_bus_line_2 [set bus_line (bus_line + 2)]\nif length path_bus_line_2 > 1 [ask link item 0 path_bus_line_2 item 1 path_bus_line_2 [set thickness 2 set color cyan]]
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
1104
431
1229
464
NIL
erase.zone.clients
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1103
348
1195
381
NIL
draw.sea
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1103
388
1215
421
NIL
draw.nature
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
932
664
1279
728
 SAVE (export.world)
export.world
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
1418
80
1530
113
NIL
initialisation-gis
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
1374
122
1471
155
NIL
import.town
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
1478
122
1570
155
NIL
import.road
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
1478
162
1603
195
NIL
connect.stations.gis
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
1374
162
1474
195
NIL
create.station.gis
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
1458
50
1608
68
GIS
15
0.0
1

TEXTBOX
889
27
1039
45
IMPORT FONT
15
0.0
1

SLIDER
1100
268
1225
301
zone-color
zone-color
10
20
16.0
1
1
NIL
HORIZONTAL

SWITCH
1100
308
1203
341
thick?
thick?
0
1
-1000

TEXTBOX
1438
24
1507
44
in progress
11
0.0
1

SLIDER
830
535
935
568
road_thickness
road_thickness
0
20
1.0
1
1
NIL
HORIZONTAL

BUTTON
830
615
917
650
Apply road thickness
apply.road
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
975
535
1080
568
stations_size
stations_size
0
20
0.0
1
1
NIL
HORIZONTAL

BUTTON
976
577
1068
612
Apply station's size
ask stations [set size stations_size]
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
73
776
158
809
Bus line 3
set path_bus_line_3 fput read-from-string user-input \"Enter bus line\" path_bus_line_3\nask station item 0 path_bus_line_3 [set bus_line (bus_line + 3)]\nif length path_bus_line_3 > 1 [ask link item 0 path_bus_line_3 item 1 path_bus_line_3 [set thickness 2 set color red]]
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
943
311
1055
345
NIL
apply.destination
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
833
308
927
342
NIL
apply.station
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
830
574
937
607
road_color
road_color
5
135
85.0
10
1
NIL
HORIZONTAL

SLIDER
979
435
1071
468
max_distance_connexion
max_distance_connexion
1
100
26.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## V3

rajout de la creation d'un réseau de Manathan
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
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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
1
@#$#@#$#@
