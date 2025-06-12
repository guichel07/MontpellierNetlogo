;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; breeds
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

breed [vehicles vehicle]
breed [stations station]
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
  total_nb_clients_created  ; number of clients created during the simulation (= patterns * nb-clients)
  total_nb_clients_created_bus_line  ; number of clients created during the simulation, with a final_destination station of the bus line
  client_station_rate  ; number of stations with some clients waiting a vehicle, divided by the total number of stations
  clients_alive
  mean_clients_waiting
  max_nb_clients_droped
  max_gross_potential_buses
  max_gross_potential
  max_clients_station_waiting   ; maximum number of clients waiting on a station
  ;max_walking_distance
  mean_client_station_rate
  mean_distance_travelled_clients
  mean_max_clients_station_waiting
  mean_mean_occupation_rate
  mean_mean_occupation_rate_buses
  mean_mean_occupation_rate_all
  mean_pick_up_rate   ; mean of the pick up rate of vehicles
  mean_pick_up_rate_buses ; mean of the pick up rate of buses
  mean_pick_up_rate_vehicles ; mean of the pick up rate of vehicles
  mean_occupation_rate
  mean_occupation_rate_buses
  mean_vpk   ; mean of the vpk of vehicles
  mean-pick-rate
  mean_vpk_buses  ; mean of the vpk of buses
  mean_vpk_vehicles ; mean of the vpk of vehicles
  mean_clients_alive
  mean_mean_clients_waiting
  mean_mean_distance_travelled_clients
  mean_mean_waiting_time_clients
  mean_waiting_time_clients
  list_stations_clients_waiting    ; list of stations with some clients waiting a vehicle
  path_bus_line_1    ; list of stations of the bus line 1
  path_bus_line_2    ; list of stations of the bus line 2
  nb_stations    ; number of stations
  nb_destinations
  contrainte-distance
  nb_destination_manhattan
  max_distance_links
  shp_network
  servincing_rate  ; (total_nb_clients_final_destination / total_nb_clients_created) * 100
  servincing_rate_bus_line  ; (total_nb_clients_final_destination / total_nb_clients_created_bus_line) * 100
  sum_clients_alive
  sum_max_clients_station_waiting
  sum_mean_clients_waiting
  sum_mean_distance_travelled_clients
  sum_mean_waiting_time_clients
  sum_nb_stations_picked_up_clients
  sum_client_station_rate
  sum_clients_waiting
  sum_mean_occupation_rate
  sum_mean_occupation_rate_buses
  sum_waiting_time_clients
  file_name
  nb_bus_line    ; number of active bus line
  final_destination_push
  time
  plot_patterns
  hybrid_state ; model curently in operation
  vehicle_atractivity_facteur
  date-time

  ;variabls from network model
  CANDIDATE_O
  CONECT.D
  CONECT.O
  DISTANCE_STATION_MANHATTAN
  THICK?
  NB-ROAD
  ROAD-DATASET
  ROAD_THICKNESS
  STATIONS_SIZE
  TOWN-DATASET
  ZONE-COLOR
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
vpk ; ((total_nb_clients_picked_up * 5) / distance_travelled)
occupation_rate_vehicle ; (nb_clients_picked_up / capacity_occupation) * 100
distance_travelled    ; distance travelled during the simulation
push
s1
s2
s3
next_link_neighbors
last_node
next_link_neighbors_push
count_last_node
count_last_node_push
route
waiting
model; 1=potential 2=cooperation 3=random 4=distance 5=modulobus 6=clandos 7=act
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
vpk ; ((total_nb_clients_picked_up * 20) / (distance_travelled * 2))
direction ; direction of the bus (0 or 1) according to the order of the stations on the bus line
position_station_bus_line_1    ; position of the current station on the bus line 1
position_station_bus_line_2    ; position of the current station on the bus line 2
occupation_rate_vehicle ; (nb_clients_picked_up / capacity_occupation) * 100
bus_line??    ; id bus line of the bus
]

stations-own
[
  final_destination? ; indicate if the station could be a final_destination for clients or not (0=not et 1=yes)
  gross_potential  ; gross potential of attractivity of the station : number of clients picked up at the station + number of clients droped + frequentation of vehicles
  net_potential  ; net potential of attractivity of the station : gross_potential / potential of the most attractive station
  net_nb_clients_droped
  nb_clients_waiting  ; number of clients waiting at the station
  clients_station_waiting_net   ; nb_clients_waiting / max_clients_station_waiting
  nb_clients_picked_up_station  ; total number of clients picked up at the station
  nb_clients_droped  ; number of clients droped at the station
  bus_line ; 0 = the station not belongs to a bus line, 1 = the station belongs to the bus line 1, etc...
  frequentation ; number of passages of vehicles
  serving_taxi    ; list of vehicles which will serve the stop
  targeted
  pop-density

  ;variabls from network model
  LINKED?
]

clients-own
[
  final_destination  ; final_destination final of the client (by using a transportation service)
  station_to_wait  ; station where the client will wait a transportation service
  bus_line?   ; indicate if the final final_destination of the client belongs to a bus line
  direction-bus_line ; indicate in wich direction the client have to go on the bus line (0 or 1)
  vehicle?  ; indicate if the client is in a vehicle (1) or not (0)
  list_vehicles_serving_destination
  push_of_vehicle
  waiting_time
  distance_travelled_clients
  zone-client
]

links-own
[
  gross_traffic  ; vehicle frequentation of the axe
  net_traffic  ; vehicle frequentation of the axe / max vehicle frequentation of axes
  link_bus_line ;
]

patches-own
[
  ;variabls from network model
  TOWN?
  ROAD?
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initialisation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to create.clients.station ; create un nombre de clients grace a un slider r�partis al�atoirement dans l'espace
  ifelse zone? = true
  [
    ask stations
    [
      set pop-density ([pcolor] of patch-here)
    ]
    create-clients nb_clients
        [
      set color white
      set shape "person"
      set size 0.6
      set list_vehicles_serving_destination []
      set push_of_vehicle []
    ]
    set total_nb_clients_created total_nb_clients_created + nb_clients
    ask n-of (round (nb_clients * 38 / 100)) clients with [zone-client = 0]
    [
      set zone-client 1
      move-to one-of stations with [pop-density = 1]
    ]
    ask n-of (round (nb_clients * 21 / 100)) clients with [zone-client = 0]
    [
      set zone-client 2
      move-to one-of stations with [pop-density = 2]
    ]
    ask n-of (round (nb_clients * 14 / 100)) clients with [zone-client = 0]
    [
      set zone-client 3
      move-to one-of stations with [pop-density = 3]
    ]
    ask n-of (round (nb_clients * 10 / 100)) clients with [zone-client = 0]
    [
      set zone-client 4
      move-to one-of stations with [pop-density = 4]
    ]
    ask n-of (round (nb_clients * 7 / 100)) clients with [zone-client = 0]
    [
      set zone-client 5
      move-to one-of stations with [pop-density = 5]
    ]
    ask n-of (round (nb_clients * 5 / 100)) clients with [zone-client = 0]
    [
      set zone-client 6
      move-to one-of stations with [pop-density = 6]
    ]
  ]
  [
    create-clients nb_clients
        [
      move-to one-of stations
      set color white
      set shape "person"
      set size 0.6
      set list_vehicles_serving_destination []
      set push_of_vehicle []
    ]
    set total_nb_clients_created total_nb_clients_created + nb_clients
  ]
end


to create.clients ; create un nombre de clients grace a un slider r�partis al�atoirement dans l'espace
  ask n-of (nb_clients / 2) patches with [pcolor != 85 and pcolor != 52 ]
  [
    sprout-clients 1
    [
      set color white
      set shape "person"
      set size 0.6
      set list_vehicles_serving_destination []
      set push_of_vehicle []
    ]
  set total_nb_clients_created total_nb_clients_created + 1
  ]
end


to create.clients.zone ; create un nombre de clients grace a un slider r�partis al�atoirement dans l'espace

  ask n-of nb_clients patches with [pcolor = 36]
  [
    sprout-clients 1
    [
      set color white
      set shape "person"
      set size 0.6
      set list_vehicles_serving_destination []
      set push_of_vehicle []
    ]
  set total_nb_clients_created total_nb_clients_created + 1
  ]
end


to estimate.stations.potential ; Definir l'attractivite de chaque station a l'initialisation
  ask stations
  [
    set gross_potential count clients with [distance myself <= attraction_radius_stations]
  ]
    let maxpotentiel max [gross_potential] of stations
    ask stations
  [
    set net_potential (gross_potential / (maxpotentiel + 0.001))
    set size (5 * net_potential)
  ]
end

to update.stations.potential  ; Mise a jour de l'attractivite des stations au cours de la simulation
  set max_gross_potential max [gross_potential] of stations
  set max_gross_potential_buses max [gross_potential] of stations
  set max_clients_station_waiting max [nb_clients_waiting] of stations
  set max_nb_clients_droped max [nb_clients_droped] of stations
  ask stations
  [
    ifelse model_choice = "bus"
    [
      ask stations with [bus_line = 0]
      [
        set clients_station_waiting_net ((nb_clients_waiting) / (max_clients_station_waiting + 1))
        set size (5 * clients_station_waiting_net + 2)
      ]
      ask stations with [bus_line > 0]
      [
        set net_potential (gross_potential / (max_gross_potential_buses + 1))
        set size (5 * net_potential)
        set net_nb_clients_droped (nb_clients_droped / (max_nb_clients_droped + 1))
;        set color scale-color red net_nb_clients_droped 0 1
      ]
    ]
    [
      set net_potential (gross_potential / (max_gross_potential + 0.001) + 1)
      set size (3 * net_potential)
    ]
  ]
end

to update.draw.traffic  ; Mise a jour de l'attractivite des liens au cours de la simulation
  let maxtraffic max [gross_traffic] of links
  ask links
  [
    set net_traffic gross_traffic / maxtraffic ^ 0.9
  ]
end


to create.vehicles  ; create des vehicles (grace a un slider) se situant aleatoirement sur des stations

  create-vehicles nb_vehicles
  [
    set current_node one-of stations
    move-to current_node
    set next_node one-of [link-neighbors] of current_node
    let ns next_node
    ask current_node
       [ ask link-with ns [ set gross_traffic (gross_traffic + 1)]]
    set shape "van top"
    set size 2.5
    set color yellow
    set state 1
    set my_clients []
    set selected_clients []
    set count_last_node 0
    set occupation_rate_vehicle 0
    set distance_travelled 1
    set total_nb_clients_picked_up 0
    set nb_clients_picked_up 0
    set nb_stations_crossed (nb_stations_crossed + 1)
    set nb_stations_picked_up_clients 0
    set push []
    set next_link_neighbors []
    set route []
    set waiting 0

    ifelse model_choice = "potential"
      [set model 1]
    [ifelse model_choice = "cooperation"
      [set model 2]
      [ifelse model_choice = "random"
        [set model 3]
        [ifelse model_choice = "distance"
          [set model 4]
          [ifelse model_choice = "modulobus" or model_choice = "mixte formal"
            [set model 5]
            [ifelse model_choice = "clandos"
              [set model 6]
              [if model_choice = "act"
                [set model 7]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
  set list_vehicles [who] of vehicles
end

to create.vehicles.mixte.informal  ; create des vehicles (grace a un slider) se situant aleatoirement sur des stations

  create-vehicles nb_vehicles
  [
    set current_node one-of stations
    move-to current_node
    set next_node one-of [link-neighbors] of current_node
    let ns next_node
    ask current_node
       [ ask link-with ns [ set gross_traffic (gross_traffic + 1)]]
    set shape "van top"
    set size 2.5
    set color yellow
    set state 1
    set my_clients []
    set selected_clients []
    set count_last_node 0
    set occupation_rate_vehicle 0
    set distance_travelled 1
    set total_nb_clients_picked_up 0
    set nb_clients_picked_up 0
    set nb_stations_crossed (nb_stations_crossed + 1)
    set nb_stations_picked_up_clients 0
    set push []
    set next_link_neighbors []
    set route []
    set waiting 0
    set model 2
  ]
  create-vehicles nb_vehicles
  [
    set current_node one-of stations
    move-to current_node
    set next_node one-of [link-neighbors] of current_node
    let ns next_node
    ask current_node
       [ ask link-with ns [ set gross_traffic (gross_traffic + 1)]]
    set shape "van top"
    set size 2.5
    set color grey
    set state 1
    set my_clients []
    set selected_clients []
    set count_last_node 0
    set occupation_rate_vehicle 0
    set distance_travelled 1
    set total_nb_clients_picked_up 0
    set nb_clients_picked_up 0
    set nb_stations_crossed (nb_stations_crossed + 1)
    set nb_stations_picked_up_clients 0
    set push []
    set next_link_neighbors []
    set route []
    set waiting 0
    set model 6
  ]
  set list_vehicles [who] of vehicles
end


to create.vehicles.mixte.flexible  ; create des vehicles (grace a un slider) se situant aleatoirement sur des stations

  create-vehicles nb_vehicles
  [
    set current_node one-of stations
    move-to current_node
    set next_node one-of [link-neighbors] of current_node
    let ns next_node
    ask current_node
       [ ask link-with ns [ set gross_traffic (gross_traffic + 1)]]
    set shape "van top"
    set size 2.5
    set color yellow
    set state 1
    set my_clients []
    set selected_clients []
    set count_last_node 0
    set occupation_rate_vehicle 0
    set distance_travelled 1
    set total_nb_clients_picked_up 0
    set nb_clients_picked_up 0
    set nb_stations_crossed (nb_stations_crossed + 1)
    set nb_stations_picked_up_clients 0
    set push []
    set next_link_neighbors []
    set route []
    set waiting 0
    set model 2
  ]
  create-vehicles nb_vehicles
  [
    set current_node one-of stations
    move-to current_node
    set next_node one-of [link-neighbors] of current_node
    let ns next_node
    ask current_node
       [ ask link-with ns [ set gross_traffic (gross_traffic + 1)]]
    set shape "van top"
    set size 2.5
    set color red
    set state 1
    set my_clients []
    set selected_clients []
    set count_last_node 0
    set occupation_rate_vehicle 0
    set distance_travelled 1
    set total_nb_clients_picked_up 0
    set nb_clients_picked_up 0
    set nb_stations_crossed (nb_stations_crossed + 1)
    set nb_stations_picked_up_clients 0
    set push []
    set next_link_neighbors []
    set route []
    set waiting 0
    set model 5
  ]
  set list_vehicles [who] of vehicles
end


to create.vehicles.mixte.all  ; create des vehicles (grace a un slider) se situant aleatoirement sur des stations

  create-vehicles nb_vehicles
  [
    set current_node one-of stations
    move-to current_node
    set next_node one-of [link-neighbors] of current_node
    let ns next_node
    ask current_node
       [ ask link-with ns [ set gross_traffic (gross_traffic + 1)]]
    set shape "van top"
    set size 2.5
    set color grey
    set state 1
    set my_clients []
    set selected_clients []
    set count_last_node 0
    set occupation_rate_vehicle 0
    set distance_travelled 1
    set total_nb_clients_picked_up 0
    set nb_clients_picked_up 0
    set nb_stations_crossed (nb_stations_crossed + 1)
    set nb_stations_picked_up_clients 0
    set push []
    set next_link_neighbors []
    set route []
    set waiting 0
    set model 6
  ]
  create-vehicles nb_vehicles
  [
    set current_node one-of stations
    move-to current_node
    set next_node one-of [link-neighbors] of current_node
    let ns next_node
    ask current_node
       [ ask link-with ns [ set gross_traffic (gross_traffic + 1)]]
    set shape "van top"
    set size 2.5
    set color red
    set state 1
    set my_clients []
    set selected_clients []
    set count_last_node 0
    set occupation_rate_vehicle 0
    set distance_travelled 1
    set total_nb_clients_picked_up 0
    set nb_clients_picked_up 0
    set nb_stations_crossed (nb_stations_crossed + 1)
    set nb_stations_picked_up_clients 0
    set push []
    set next_link_neighbors []
    set route []
    set waiting 0
    set model 5
  ]
  create-vehicles nb_vehicles
  [
    set current_node one-of stations
    move-to current_node
    set next_node one-of [link-neighbors] of current_node
    let ns next_node
    ask current_node
       [ ask link-with ns [ set gross_traffic (gross_traffic + 1)]]
    set shape "van top"
    set size 2.5
    set color yellow
    set state 1
    set my_clients []
    set selected_clients []
    set count_last_node 0
    set occupation_rate_vehicle 0
    set distance_travelled 1
    set total_nb_clients_picked_up 0
    set nb_clients_picked_up 0
    set nb_stations_crossed (nb_stations_crossed + 1)
    set nb_stations_picked_up_clients 0
    set push []
    set next_link_neighbors []
    set route []
    set waiting 0
    set model 2
  ]
  set list_vehicles [who] of vehicles
end



to create.vehicles.mixte.frsn  ; create des vehicles (grace a un slider) se situant aleatoirement sur des stations

  create-vehicles nb_vehicles
  [
    set current_node one-of stations
    move-to current_node
    set next_node one-of [link-neighbors] of current_node
    let ns next_node
    ask current_node
       [ ask link-with ns [ set gross_traffic (gross_traffic + 1)]]
    set shape "van top"
    set size 2.5
    set color grey
    set state 1
    set my_clients []
    set selected_clients []
    set count_last_node 0
    set occupation_rate_vehicle 0
    set distance_travelled 1
    set total_nb_clients_picked_up 0
    set nb_clients_picked_up 0
    set nb_stations_crossed (nb_stations_crossed + 1)
    set nb_stations_picked_up_clients 0
    set push []
    set next_link_neighbors []
    set route []
    set waiting 0
    set model 6
  ]
  create-vehicles nb_vehicles
  [
    set current_node one-of stations
    move-to current_node
    set next_node one-of [link-neighbors] of current_node
    let ns next_node
    ask current_node
       [ ask link-with ns [ set gross_traffic (gross_traffic + 1)]]
    set shape "van top"
    set size 2.5
    set color red
    set state 1
    set my_clients []
    set selected_clients []
    set count_last_node 0
    set occupation_rate_vehicle 0
    set distance_travelled 1
    set total_nb_clients_picked_up 0
    set nb_clients_picked_up 0
    set nb_stations_crossed (nb_stations_crossed + 1)
    set nb_stations_picked_up_clients 0
    set push []
    set next_link_neighbors []
    set route []
    set waiting 0
    set model 5
  ]
  set list_vehicles [who] of vehicles
end

to count.clients.waiting ; Compter le nombre de voyageurs a chaque station
  ask stations
  [
    set nb_clients_waiting count clients-here
  ]
end


 to initialisation.agents
  ask vehicles [die]
  ask buses [die]
  ask clients [die]
  clear-output
  clear-all-plots
  clear-drawing
  set nb_stations count stations
  set total_nb_clients_created_bus_line 0
  set max_nb_clients_droped 0
  set max_gross_potential 0
  set max_clients_station_waiting 0
  set mean_distance_travelled_clients 0
  set mean_pick_up_rate 0
  set mean-pick-rate 0
  set mean_max_clients_station_waiting 0
  set mean_pick_up_rate_buses 0
  set mean_pick_up_rate_vehicles 0
  set mean_vpk 0
  set mean_vpk_buses  0
  set mean_vpk_vehicles 0
  set mean_mean_occupation_rate 0
  set mean_mean_distance_travelled_clients 0
  set list_stations_clients_waiting []
  set client_station_rate 0
  set sum_client_station_rate 0
  set mean_client_station_rate 0
  set sum_nb_stations_picked_up_clients 0
  set mean_clients_waiting 0
  set mean_max_clients_station_waiting 0
  set sum_mean_clients_waiting 0
  set sum_mean_distance_travelled_clients 0
  set sum_mean_waiting_time_clients 0
  set sum_max_clients_station_waiting 0
  set sum_clients_waiting 0
  set mean_mean_clients_waiting 0
  set sum_waiting_time_clients 0
  set sum_mean_occupation_rate 0
  set clients_alive  0
  set sum_clients_alive  0
  set mean_clients_alive  0
  set vehicle_atractivity_facteur 0
  set mean_mean_occupation_rate_buses 0
  set mean_mean_occupation_rate_all 0
  set mean_occupation_rate_buses 0
  set sum_mean_occupation_rate_buses 0
  ask stations
    [
      set shape "circle"
      set color green
      set frequentation 0
      set gross_potential 0
      set net_potential 0
      set nb_clients_waiting 0
      set nb_clients_picked_up_station 0
      set nb_clients_droped 0
      set serving_taxi []
      set targeted 0
    ]
  ask stations with [final_destination? = 1]
  [
    set color red
    set shape "flag"
  ]
  ask links
    [
    set thickness 0.05
    set color 9.9
    set gross_traffic 0
    set net_traffic 0
    ]
  ask links with [link_bus_line = 1]
    [
    set thickness 1
    set color 105
    set gross_traffic 0
    set net_traffic 0
    ]
  set patterns 0
  set plot_patterns 1
  set total_nb_clients_final_destination 0
  set total_nb_clients_created 0
  reset-ticks
  set time 0
  create.clients.station
  ifelse model_choice = "bus"
    [
;      ask stations with [bus_line > 0]
;      [
;        set color orange
;        set shape "flag"
;      ]
      create.buses.first.bus.line.1
      create.buses.last.bus.line.1
      if nb_bus_line = 2
        [
          create.buses.first.bus.line.2
          create.buses.last.bus.line.2
        ]
    ]
    [
      ifelse model_choice = "mixte informal"
      [create.vehicles.mixte.informal]
      [ifelse model_choice = "mixte flexible"
        [create.vehicles.mixte.flexible]
        [ifelse (model_choice = "mixte formal" or model_choice = "mixte rigid" or model_choice = "mixte taxi bus")
          [
;            ask stations with [bus_line > 0]
;;            [
;;              set color orange
;;              set shape "flag"
;;            ]
            create.buses.first.bus.line.1
            create.buses.last.bus.line.1
            if nb_bus_line = 2
            [
              create.buses.first.bus.line.2
              create.buses.last.bus.line.2
            ]
            create.vehicles
          ]
          [ifelse model_choice = "mixte frsn"
            [create.vehicles.mixte.frsn]
            [ifelse model_choice = "mixte all"
              [create.vehicles.mixte.all]
              [create.vehicles]
            ]
          ]
        ]
      ]
    ]

  estimate.stations.potential
  update.stations.potential
  set list_stations_clients_waiting []
  choose.clients.final.destination
;  if write-clients? = true
;  [
;    if file-exists? "clients.txt" [ file-delete "clients.txt" ]
;    export.clients
;  ]
  set patterns 1
  ask vehicles [set state 3]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GO général
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  if ticks = 1 [reset-timer]
  ifelse model_choice = "potential"
      [go.potential]
  [ifelse model_choice = "random"
    [go.random]
    [ifelse model_choice = "distance"
      [go.distance]
      [ifelse model_choice = "bus"
        [go.bus]
        [ifelse model_choice = "cooperation"
          [go.cooperate]
          [ifelse model_choice = "modulobus"
            [go.modulobus]
            [ifelse model_choice = "clandos"
              [go.clandos]
              [ifelse model_choice = "hybrid"
                [go.hybrid]
                [ifelse model_choice = "mixte informal"
                  [go.mixte.informal]
                  [ifelse model_choice = "mixte formal"
                    [go.mixte.formal]
                    [ifelse model_choice = "mixte flexible"
                      [go.mixte.flexible]
                      [ifelse model_choice = "mixte rigid"
                        [go.mixte.rigid]
                        [ifelse model_choice = "mixte frsn"
                          [go.mixte.frsn]
                          [ifelse model_choice = "mixte taxi bus"
                            [go.mixte.taxibus]
                            [ifelse model_choice = "mixte all"
                              [go.mixte.all]
                              [go.act]
                            ]
                          ]
                        ]
                      ]
                    ]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
end









;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generic code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



to choose.clients.final.destination
  ask clients
  [
     if final_destination = 0
     [
       ifelse (model_choice = "bus" or model_choice = "mixte formal" or model_choice = "mixte rigid" or model_choice = "mixte taxi bus")
       [
         set final_destination one-of stations with [ final_destination? = 1]
         if [bus_line] of final_destination = 3
         [
           let nearest_station min-one-of stations with [ bus_line = 1 or bus_line = 2] [distance myself]
           let closest_bus_line [bus_line] of nearest_station
           set bus_line? closest_bus_line
           set station_to_wait nearest_station
           set total_nb_clients_created_bus_line total_nb_clients_created_bus_line + 1
         ]
         if [bus_line] of final_destination = 1
         [
           set bus_line? 1
           set total_nb_clients_created_bus_line total_nb_clients_created_bus_line + 1
           set station_to_wait max-one-of stations with [ bus_line = 1] [ gross_potential / (distance myself ^ 3 + 0.1) ]
           let id_station_to_wait [who] of station_to_wait
           let position_station_to_wait position id_station_to_wait path_bus_line_1
           let id_final_destination [who] of final_destination
           let position_id_final_destination position id_final_destination path_bus_line_1
           ifelse position_id_final_destination > position_station_to_wait
           [set direction-bus_line 0]
           [set direction-bus_line 1]
         ]
         if [bus_line] of final_destination = 2
         [
           set bus_line? 2
           set total_nb_clients_created_bus_line total_nb_clients_created_bus_line + 1
           set station_to_wait max-one-of stations with [ bus_line = 2] [ gross_potential / (distance myself ^ 3 + 0.1) ]
           let id_station_to_wait_noeud [who] of station_to_wait
           let position-station_to_wait-list position id_station_to_wait_noeud path_bus_line_2
           let id_station_to_wait_marche [who] of final_destination
           let position-finale_final_destination-list position id_station_to_wait_marche path_bus_line_2
           ifelse position-finale_final_destination-list > position-station_to_wait-list
           [set direction-bus_line 0]
           [set direction-bus_line 1]
         ]
         if [bus_line] of final_destination = 0
         [
           set station_to_wait max-one-of stations with [distance myself < max_walking_distance] [ gross_potential / (distance myself ^ 3 + 0.1) ]
         ]
       ]
       [
         set final_destination one-of stations with [ final_destination? = 1]
         ;set station_to_wait max-one-of stations with [distance myself < max_walking_distance] [ gross_potential / (distance myself ^ 3 + 0.1) ]
       ]
     ]
  ]
end


to move.clients ;
  ask clients [ set waiting_time waiting_time + 1 ]
  ask clients with [vehicle? = 0]
  [
    face station_to_wait
    ifelse distance station_to_wait >= moving_speed + 1
      [fd moving_speed ]
      [if distance station_to_wait > 0
        [
          move-to station_to_wait
          if station_to_wait = final_destination
            [
              set total_nb_clients_created (total_nb_clients_created - 1)
              die
            ]
        ]
      ]
  ]
end


to circulate  ; Deplacement du vehicle optimis� en selon els diff�rents principes
  set heading towards next_node
  if length my_clients > 0
    [
      ask clients with [vehicle? = [who] of myself]
        [
          set heading [heading] of myself
        ]
    ]
  ifelse distance next_node > moving_speed * speed_factor + 0.1
  [
    fd moving_speed * speed_factor
    if length my_clients > 0
      [
        ask clients with [vehicle? = [who] of myself]
          [
            fd moving_speed * speed_factor
            set distance_travelled_clients  distance_travelled_clients + 1
          ]
      ]
  ]
  [
    move-to next_node
    ifelse next_node = final_destination_vehicle
      [ set state 2 ]
      [
        if length my_clients > 0
          [
            ask clients with [vehicle? = [who] of myself]
              [
                move-to [next_node] of myself
              ]
           ]
        set state 1
      ]
  ]
  set distance_travelled  distance_travelled + 1
end





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; modulobus model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go.modulobus
  if ticks = ((patterns * nb_ticks_patterns) - 1)
  [
    create.clients.station
    update.stations.potential
    choose.clients.final.destination
    set patterns (patterns + 1)
;    if write-clients? = true [export.clients]
  ]
  ask clients [ set waiting_time waiting_time + 1 ]
  choose.clients.station.modulobus
  move.clients
  count.clients.waiting
  go.vehicles.modulobus
  plotting
  draw.traffic
  update.draw.traffic
  tick
end

to choose.clients.station.modulobus
  ask clients with [vehicle? = 0]
  [
    if [targeted] of final_destination = 1
    [
      set list_vehicles_serving_destination [serving_taxi] of final_destination
      set list_vehicles_serving_destination sort-by [ [?1 ?2] -> [distance myself] of ?1 < [distance myself] of ?2 ] list_vehicles_serving_destination
      let vehicle_to_take first list_vehicles_serving_destination
      set push_of_vehicle [push] of vehicle_to_take
      set push_of_vehicle sort-by [ [?1 ?2] -> [distance myself] of ?1 < [distance myself] of ?2 ] push_of_vehicle
      let best_station_push first push_of_vehicle
      if [distance myself] of best_station_push < max_walking_distance
        [
          set station_to_wait best_station_push
        ]

    ]
  ]
end


to go.vehicles.modulobus  ; Sequence des procedures des vehicles
  ask vehicles with [model = 5]
  [
    ifelse state = 0
      [choose.station.modulobus]
      [ifelse state = 1
        [pick.up.clients.modulobus]
        [ifelse state = 2
          [drop.clients.modulobus]
          [circulate]
        ]
      ]
  ]
end

to choose.station.modulobus ; To choose the next stops of vehicles
  ifelse final_destination_vehicle = 0
    [
      let na current_node
      set current_node next_node
      set next_node one-of [link-neighbors] of current_node
      let ns next_node
      ask current_node
        [
          ask link-with ns [ set gross_traffic (gross_traffic + 1)]
          set frequentation frequentation + 1
        ]
    ]
    [
      let dest final_destination_vehicle
      set last_node current_node
      set current_node next_node
      set next_link_neighbors [link-neighbors] of current_node
      set next_link_neighbors sort-by [ [?1 ?2] -> [distance dest] of ?1 < [distance dest] of ?2 ] next_link_neighbors
      set next_node min-one-of [link-neighbors] of current_node [distance dest]
      while [next_node = last_node and length next_link_neighbors > 1]
          [
            set next_node one-of [link-neighbors] of current_node
          ]
      let ns next_node
      ask current_node
        [
          ask link-with ns [ set gross_traffic (gross_traffic + 1)]
          set frequentation frequentation + 1
          set gross_potential gross_potential + 1
        ]
    ]
  set nb_stations_crossed (nb_stations_crossed + 1)
  set state 3
end

to make.push.modulobus
  set s1 current_node
  set final_destination_push final_destination_vehicle
  set push fput final_destination_push push
  set s2 next_node
  set next_link_neighbors_push [link-neighbors] of s2
  set next_link_neighbors_push sort-by [ [?1 ?2] -> [distance final_destination_push] of ?1 < [distance final_destination_push] of ?2 ] next_link_neighbors_push
  set s3 min-one-of [link-neighbors] of s2 [distance final_destination_push]
  while [s3 = s1 and length next_link_neighbors_push > 1]
          [
            set s3 one-of [link-neighbors] of s2
          ]
  while [s3 != final_destination_push]
  [
    set push fput s3 push
    set s1 s2
    set s2 s3
    set next_link_neighbors_push [link-neighbors] of s2
    set next_link_neighbors_push sort-by [ [?1 ?2] -> [distance final_destination_push] of ?1 < [distance final_destination_push] of ?2 ] next_link_neighbors_push
    set s3 min-one-of [link-neighbors] of s2 [distance final_destination_push]
    while [s3 = s1 and length next_link_neighbors_push > 1]
          [
            set s3 one-of [link-neighbors] of s2
          ]
  ]
end


to pick.up.clients.modulobus  ;
  if any? clients-here with [vehicle? = 0]
    [
      let nb-clients-here [nb_clients_waiting] of next_node
      if length my_clients = 0
        [
          set final_destination_vehicle [final_destination] of one-of clients-here with [vehicle? = 0]
          make.push.modulobus
          ask final_destination_vehicle
          [
            set serving_taxi fput myself serving_taxi
            set targeted 1
          ]
        ]
      let dest-vehicle final_destination_vehicle
      let nb-clients-possible count clients-here with [vehicle? = 0 and final_destination = dest-vehicle]
      if nb-clients-possible > 0
      [
        let nb-clients-a-prendre min (list (capacity_occupation - nb_clients_picked_up) nb-clients-possible)
        if nb-clients-a-prendre = 1
        [ set selected_clients one-of clients-here with [vehicle? = 0 and final_destination = dest-vehicle ] ]
        if nb-clients-a-prendre > 1
        [ set selected_clients n-of nb-clients-a-prendre clients-here with [vehicle? = 0 and final_destination = dest-vehicle ] ]
        ask selected_clients
        [
          set vehicle? [who] of myself
          set color red
        ]
        set color orange
        set my_clients fput selected_clients my_clients
        set nb_clients_picked_up count clients with [vehicle? = [who] of myself ]
        ask next_node
        [
          set nb_clients_picked_up_station (nb_clients_picked_up_station + [nb_clients_picked_up] of myself)
          set gross_potential (gross_potential + ([nb_clients_picked_up] of myself) * vehicle_atractivity_facteur)
        ]
        set occupation_rate_vehicle ((nb_clients_picked_up / capacity_occupation) * 100)
        set total_nb_clients_picked_up total_nb_clients_picked_up + nb_clients_picked_up
        set vpk ((total_nb_clients_picked_up * 20) / distance_travelled)
        set nb_stations_picked_up_clients (nb_stations_picked_up_clients + 1)
        set pick_up_rate (nb_stations_picked_up_clients / nb_stations_crossed ) * 100
      ]
    ]
    set state 0
end


to drop.clients.modulobus  ;
  let n nb_clients_picked_up
  ask final_destination_vehicle
    [
    set nb_clients_droped nb_clients_droped + n
    set gross_potential (gross_potential + n)
    set total_nb_clients_final_destination total_nb_clients_final_destination + n
    set serving_taxi remove myself serving_taxi
    if empty? serving_taxi [set targeted 0]
    ]
  set nb_clients_picked_up 0
  set my_clients []
  set selected_clients []
  set push []
  ask clients with [vehicle? = [who] of myself]
    [die]
  set final_destination_vehicle 0
  set final_destination_push 0
  set s1 0
  set s2 0
  set s3 0
  set next_link_neighbors []
  set next_link_neighbors_push []
  set color yellow
  set state 1
end








;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; clandos model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go.clandos
  if ticks = ((patterns * nb_ticks_patterns) - 1)
  [
    create.clients.station
    update.stations.potential
    choose.clients.final.destination
    set patterns (patterns + 1)
;    if write-clients? = true [export.clients]
  ]
  ask clients [ set waiting_time waiting_time + 1 ]
  count.clients.waiting
  go.vehicles.clandos
  plotting
  draw.traffic
  update.draw.traffic
  tick
end


to go.vehicles.clandos  ; Sequence des procedures des vehicles
  ask vehicles with [model = 6]
  [
    ifelse state = 0
      [choose.station.clandos]
      [ifelse state = 1
        [pick.up.clients.clandos]
        [ifelse state = 2
          [drop.clients]
          [circulate.clandos]
        ]
      ]
  ]
end


to choose.station.clandos  ; Choisir le prochain noeud sur lequel va passer le vehicle
  ifelse final_destination_vehicle = 0
    [
      set last_node current_node
      set current_node next_node
      let ne min-one-of [link-neighbors] of current_node [gross_potential]
      set next_link_neighbors [link-neighbors] of current_node
      set next_link_neighbors sort-by [ [?1 ?2] -> [gross_potential] of ?1 < [gross_potential] of ?2 ] next_link_neighbors
      set next_node max-one-of [link-neighbors] of current_node [gross_potential]
      while [next_node = last_node and length next_link_neighbors > 1]
          [
            set next_node one-of [link-neighbors] of current_node
          ]
      let ns next_node
      ask current_node
        [
          ask link-with ns [ set gross_traffic (gross_traffic + 1)]
          set frequentation frequentation + 1
        ]
    ]
    [
      let dest final_destination_vehicle
      set last_node current_node
      set current_node next_node
      set next_link_neighbors [link-neighbors] of current_node
      set next_link_neighbors sort-by [ [?1 ?2] -> [distance dest] of ?1 < [distance dest] of ?2 ] next_link_neighbors
      set next_node min-one-of [link-neighbors] of current_node [distance dest]
      while [next_node = last_node and length next_link_neighbors > 1]
          [
            set next_node one-of [link-neighbors] of current_node
          ]
      let ns next_node
      ask current_node
        [
          ask link-with ns [ set gross_traffic (gross_traffic + 1)]
          set frequentation frequentation + 1
          set gross_potential gross_potential + 1
        ]
    ]
  set nb_stations_crossed (nb_stations_crossed + 1)
  set state 3
end



to pick.up.clients.clandos  ;
  ifelse any? clients-here with [vehicle? = 0]
    [
      let nb-clients-here [nb_clients_waiting] of next_node
      ifelse waiting = 0
      [
        if length my_clients = 0
        [ set final_destination_vehicle [final_destination] of one-of clients-here with [vehicle? = 0] ]
        let dest-vehicle final_destination_vehicle
        let nb-clients-possible count clients-here with [vehicle? = 0 and final_destination = dest-vehicle]
        if nb-clients-possible > 0
        [
          let nb-clients-a-prendre min (list (capacity_occupation - nb_clients_picked_up) nb-clients-possible)
          if nb-clients-a-prendre = 1
          [ set selected_clients one-of clients-here with [vehicle? = 0 and final_destination = dest-vehicle ] ]
          if nb-clients-a-prendre > 1
          [ set selected_clients n-of nb-clients-a-prendre clients-here with [vehicle? = 0 and final_destination = dest-vehicle ] ]
          ask selected_clients
          [
            set vehicle? [who] of myself
            set color red
          ]
          set color orange
          set my_clients fput selected_clients my_clients
          set nb_clients_picked_up count clients with [vehicle? = [who] of myself ]
          ask next_node
          [
            set nb_clients_picked_up_station (nb_clients_picked_up_station + [nb_clients_picked_up] of myself)
            set gross_potential (gross_potential + ([nb_clients_picked_up] of myself) * vehicle_atractivity_facteur)
          ]
          set occupation_rate_vehicle (nb_clients_picked_up / capacity_occupation) * 100
        ]
      ]
      [
        let dest-vehicle final_destination_vehicle
        let nb-clients-possible count clients-here with [vehicle? = 0 and final_destination = dest-vehicle]
        if nb-clients-possible < 1 and nb_clients_picked_up < 2
        [
          ask clients with [vehicle? = [who] of myself]
          [
            set vehicle? 0
            set color white
          ]
          set final_destination_vehicle [final_destination] of one-of clients-here with [vehicle? = 0]
        ]
        let dest-vehicle2 final_destination_vehicle
        let nb-clients-possible2 count clients-here with [vehicle? = 0 and final_destination = dest-vehicle2]
        if nb-clients-possible2 > 0
        [
          let nb-clients-a-prendre min (list (capacity_occupation - nb_clients_picked_up) nb-clients-possible2)
          if nb-clients-a-prendre = 1
          [ set selected_clients one-of clients-here with [vehicle? = 0 and final_destination = dest-vehicle2 ] ]
          if nb-clients-a-prendre > 1
          [ set selected_clients n-of nb-clients-a-prendre clients-here with [vehicle? = 0 and final_destination = dest-vehicle2 ] ]
          ask selected_clients
          [
            set vehicle? [who] of myself
            set color red
          ]
          set color orange
          set my_clients fput selected_clients my_clients
          set nb_clients_picked_up count clients with [vehicle? = [who] of myself ]
          ask next_node
          [
            set nb_clients_picked_up_station (nb_clients_picked_up_station + [nb_clients_picked_up] of myself)
            set gross_potential (gross_potential + ([nb_clients_picked_up] of myself) * vehicle_atractivity_facteur)
          ]
          set occupation_rate_vehicle ((nb_clients_picked_up / capacity_occupation) * 100)
        ]
      ]
      ifelse occupation_rate_vehicle > 50
        [
          set state 0
          set waiting 0
          ask next_node
          [
            set nb_clients_picked_up_station (nb_clients_picked_up_station + [nb_clients_picked_up] of myself)
            set gross_potential (gross_potential + ([nb_clients_picked_up] of myself) * vehicle_atractivity_facteur)
          ]
          set total_nb_clients_picked_up total_nb_clients_picked_up + nb_clients_picked_up
          set vpk ((total_nb_clients_picked_up * 20) / distance_travelled)
          set nb_stations_picked_up_clients (nb_stations_picked_up_clients + 1)
          set pick_up_rate (nb_stations_picked_up_clients / nb_stations_crossed ) * 100
        ]
        [
          set state 1
          set waiting 1
        ]
    ]
    [
      ifelse waiting = 0
      [set state 0]
      [set state 1]
    ]
end

to circulate.clandos  ; Deplacement du vehicle optimis� en selon els diff�rents principes
  set heading towards next_node
  if length my_clients > 0
    [
      ask clients with [vehicle? = [who] of myself]
        [
          set heading [heading] of myself
        ]
    ]
  ifelse distance next_node > moving_speed * speed_factor + 0.1
  [
    fd moving_speed * speed_factor
    if length my_clients > 0
      [
        ask clients with [vehicle? = [who] of myself]
          [
            fd moving_speed * speed_factor
          ]
         ask clients with [vehicle? = [who] of myself]
          [
            fd moving_speed * speed_factor
            set distance_travelled_clients  distance_travelled_clients + 1
          ]
      ]
  ]
  [
    move-to next_node
    ifelse next_node = final_destination_vehicle
      [ set state 2 ]
      [
        if length my_clients > 0
          [
            ask clients with [vehicle? = [who] of myself]
              [
                move-to [next_node] of myself
              ]
           ]
        set state 1
      ]
  ]
  set distance_travelled  distance_travelled + 1
end










;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; potential model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go.potential
  if ticks = ((patterns * nb_ticks_patterns) - 1)
  [
    create.clients.station
    update.stations.potential
    choose.clients.final.destination
    set patterns (patterns + 1)
;    if write-clients? = true [export.clients]
  ]
  ask clients [ set waiting_time waiting_time + 1 ]
  count.clients.waiting
  go.vehicles.potential
  plotting
  draw.traffic
  update.draw.traffic
  tick
end


to go.vehicles.potential  ; Sequence des procedures des vehicles
  ask vehicles with [model = 1]
  [
    ifelse state = 0
      [choose.station.potential]
      [ifelse state = 1
        [pick.up.clients]
        [ifelse state = 2
          [drop.clients]
          [circulate]
        ]
      ]
  ]
end


to choose.station.potential  ; Choisir le prochain noeud sur lequel va passer le vehicle
  ifelse final_destination_vehicle = 0
    [
      set last_node current_node
      set current_node next_node
      let ne min-one-of [link-neighbors] of current_node [gross_potential]
      set next_link_neighbors [link-neighbors] of current_node
      set next_link_neighbors sort-by [ [?1 ?2] -> [gross_potential] of ?1 < [gross_potential] of ?2 ] next_link_neighbors
      set next_node max-one-of [link-neighbors] of current_node [gross_potential]
      while [next_node = last_node and length next_link_neighbors > 1]
          [
            set next_node one-of [link-neighbors] of current_node
          ]
      let ns next_node
      ask current_node
        [
          ask link-with ns [ set gross_traffic (gross_traffic + 1)]
          set frequentation frequentation + 1
        ]
    ]
    [
      let dest final_destination_vehicle
      set last_node current_node
      set current_node next_node
      set next_link_neighbors [link-neighbors] of current_node
      set next_link_neighbors sort-by [ [?1 ?2] -> [distance dest] of ?1 < [distance dest] of ?2 ] next_link_neighbors
      set next_node min-one-of [link-neighbors] of current_node [distance dest]
      while [next_node = last_node and length next_link_neighbors > 1]
          [
            set next_node one-of [link-neighbors] of current_node
          ]
      let ns next_node
      ask current_node
        [
          ask link-with ns [ set gross_traffic (gross_traffic + 1)]
          set frequentation frequentation + 1
          set gross_potential gross_potential + 1
        ]
    ]
  set nb_stations_crossed (nb_stations_crossed + 1)
  set state 3
end









;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; distance model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go.distance
  if ticks = ((patterns * nb_ticks_patterns) - 1)
  [
    create.clients.station
    update.stations.potential
    choose.clients.final.destination
    set patterns (patterns + 1)
;    if write-clients? = true [export.clients]
  ]
  ask clients [ set waiting_time waiting_time + 1 ]
  count.clients.waiting
  go.vehicles.distance
  plotting
  draw.traffic
  update.draw.traffic
  tick
end

to go.vehicles.distance  ; Sequence des procedures des vehicles
  ask vehicles with [model = 4]
  [
    ifelse state = 0
      [choose.station.distance]
      [ifelse state = 1
        [pick.up.clients]
        [ifelse state = 2
          [drop.clients]
          [circulate]
        ]
      ]
  ]
end

to choose.station.distance  ; Choisir le prochain noeud sur lequel va passer le vehicle
  ifelse final_destination_vehicle = 0
    [
      let na current_node
      set current_node next_node
      let ne max-one-of [link-neighbors with [final_destination? = 0]] of current_node [distance myself]
      set next_node min-one-of [link-neighbors with [final_destination? = 0]] of current_node [ distance myself ]
      if next_node = na or next_node = ne
        [set next_node one-of [link-neighbors] of current_node]
      let ns next_node
      ask current_node
        [
          ask link-with ns [ set gross_traffic (gross_traffic + 1)]
          set frequentation frequentation + 1
        ]
    ]
    [
    let dest final_destination_vehicle
    set last_node current_node
    set current_node next_node
    set next_link_neighbors [link-neighbors] of current_node
    set next_link_neighbors sort-by [ [?1 ?2] -> [distance dest] of ?1 < [distance dest] of ?2 ] next_link_neighbors
    set next_node min-one-of [link-neighbors] of current_node [distance dest]
    while [next_node = last_node and length next_link_neighbors > 1]
        [ set next_node one-of [link-neighbors] of current_node ]

;      let na current_node
;      let dest final_destination_vehicle
;      set current_node next_node
;      set next_node min-one-of [link-neighbors] of current_node [distance dest]
;      while [next_node = na]
;          [
;            set next_node one-of [link-neighbors] of current_node
;          ]
      let ns next_node
      ask current_node
        [
          ask link-with ns [ set gross_traffic (gross_traffic + 1)]
          set frequentation frequentation + 1
          set gross_potential gross_potential + 1
        ]
    ]
  set nb_stations_crossed (nb_stations_crossed + 1)
  set state 3
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; random model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go.random
  if ticks = ((patterns * nb_ticks_patterns) - 1)
  [
    create.clients.station
    update.stations.potential
    choose.clients.final.destination
    set patterns (patterns + 1)
;    if write-clients? = true [export.clients]
  ]
  ask clients [ set waiting_time waiting_time + 1 ]
  count.clients.waiting
  go.vehicles.random
  plotting
  draw.traffic
  update.draw.traffic
  tick
end

to go.vehicles.random  ; Sequence des procedures des vehicles
  ask vehicles with [model = 3]
  [
    ifelse state = 0
      [choose.station.random]
      [ifelse state = 1
        [pick.up.clients]
        [ifelse state = 2
          [drop.clients]
          [circulate]
        ]
      ]
  ]
end

to choose.station.random  ; Choisir le prochain noeud sur lequel va passer le vehicle
  ifelse final_destination_vehicle = 0
    [
      set current_node next_node
      set next_node one-of [link-neighbors] of current_node
      let ns next_node
      ask current_node
        [
          ask link-with ns [ set gross_traffic (gross_traffic + 1)]
          set frequentation frequentation + 1
        ]
    ]
    [
     let dest final_destination_vehicle
      set last_node current_node
      set current_node next_node
      set next_link_neighbors [link-neighbors] of current_node
      set next_link_neighbors sort-by [ [?1 ?2] -> [distance dest] of ?1 < [distance dest] of ?2 ] next_link_neighbors
      set next_node min-one-of [link-neighbors] of current_node [distance dest]
      while [next_node = last_node and length next_link_neighbors > 1]
          [
            set next_node one-of [link-neighbors] of current_node
          ]
      let ns next_node
      ask current_node
        [
          ask link-with ns [ set gross_traffic (gross_traffic + 1)]
          set frequentation frequentation + 1
          set gross_potential gross_potential + 1
        ]
    ]
  set nb_stations_crossed (nb_stations_crossed + 1)
  set state 3
end




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ACT model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go.act
  if ticks = ((patterns * nb_ticks_patterns) - 1)
  [
    create.clients.station
    update.stations.potential
    choose.clients.final.destination
    set patterns (patterns + 1)
;    if write-clients? = true [export.clients]
  ]
  ask clients [ set waiting_time waiting_time + 1 ]
  count.clients.waiting
  communicate.act
  go.vehicles.act
  plotting
  draw.traffic
  update.draw.traffic
  tick
end


to go.vehicles.act  ; Sequence des procedures des vehicles
  ask vehicles with [model = 7]
  [
    ifelse state = 0
      [choose.station.act]
      [ifelse state = 1
        [pick.up.clients.act]
        [ifelse state = 2
          [drop.clients.act]
          [circulate]
        ]
      ]
  ]
end


to choose.station.act  ; Choisir le prochain noeud sur lequel va passer le vehicle
  ifelse final_destination_vehicle = 0
   [
        ifelse empty? list_stations_clients_waiting
        [
          set state 0
        ]
        [
          set list_stations_clients_waiting sort-by [ [?1 ?2] -> [distance myself] of ?1 < [distance myself] of ?2 ] list_stations_clients_waiting
          let station-a-desservir first list_stations_clients_waiting
          set last_node current_node
          set current_node next_node
          set next_link_neighbors [link-neighbors] of current_node
          set next_link_neighbors sort-by [ [?1 ?2] -> [distance station-a-desservir] of ?1 < [distance station-a-desservir] of ?2 ] next_link_neighbors
          set next_node min-one-of [link-neighbors] of current_node [distance station-a-desservir]
          while [next_node = last_node and length next_link_neighbors > 1]
          [
            set next_node one-of [link-neighbors] of current_node
          ]
          if next_node = station-a-desservir and final_destination_vehicle = 0 [set list_stations_clients_waiting remove-item 0 list_stations_clients_waiting]
          let ns next_node
          ask current_node
          [
            ask link-with ns [set gross_traffic (gross_traffic + 1)]
            set frequentation frequentation + 1
            set gross_potential gross_potential + 1
          ]
        set nb_stations_crossed (nb_stations_crossed + 1)
        set state 3
        ]
   ]
   [
     let dest final_destination_vehicle
     set last_node current_node
     set current_node next_node
     set next_link_neighbors [link-neighbors] of current_node
     set next_link_neighbors sort-by [ [?1 ?2] -> [distance dest] of ?1 < [distance dest] of ?2 ] next_link_neighbors
     set next_node min-one-of [link-neighbors] of current_node [distance dest]
     while [next_node = last_node and length next_link_neighbors > 1]
       [
         set next_node one-of [link-neighbors] of current_node
       ]
     let ns next_node
     ask current_node
    [
        ask link-with ns [ set gross_traffic (gross_traffic + 1)]
        set frequentation frequentation + 1
        set gross_potential gross_potential + 1
    ]
    set nb_stations_crossed (nb_stations_crossed + 1)
    set state 3
  ]
end

to communicate.act
  ask stations
  [
    ifelse nb_clients_waiting > 0
          [
            if not member? self list_stations_clients_waiting
            [
              set list_stations_clients_waiting fput self list_stations_clients_waiting
              set color blue
            ]
    ]
    [
      set list_stations_clients_waiting remove self list_stations_clients_waiting
      ifelse final_destination? = 0
      [ set color green]
      [ set color red]
    ]
  ]
end

to pick.up.clients.act  ; Choisir les clients et les embarquer
  ifelse any? clients-here with [vehicle? = 0]
    [
      let nb-clients-here [nb_clients_waiting] of next_node
      if length my_clients = 0
        [ set final_destination_vehicle [final_destination] of one-of clients-here with [vehicle? = 0] ]
      let dest-vehicle final_destination_vehicle
      let nb-clients-possibles count clients-here with [vehicle? = 0 and final_destination = dest-vehicle]
      if nb-clients-possibles > 0
      [
        let nb-clients-a-prendre min (list (capacity_occupation - nb_clients_picked_up) nb-clients-possibles)
        if nb-clients-a-prendre = 1
        [ set selected_clients one-of clients-here with [vehicle? = 0 and final_destination = dest-vehicle ] ]
        if nb-clients-a-prendre > 1
        [ set selected_clients n-of nb-clients-a-prendre clients-here with [vehicle? = 0 and final_destination = dest-vehicle ] ]
        ask selected_clients
        [
          set vehicle? [who] of myself
          set color red
        ]
        set color orange
        set my_clients fput selected_clients my_clients
        set nb_clients_picked_up count clients with [vehicle? = [who] of myself ]
        ask next_node
        [
          set nb_clients_picked_up_station (nb_clients_picked_up_station + [nb_clients_picked_up] of myself)
          set gross_potential (gross_potential + ([nb_clients_picked_up] of myself) * vehicle_atractivity_facteur)
          set nb_clients_waiting (nb-clients-here - [nb_clients_picked_up] of myself)
        ]
;        communicate
        set nb_stations_picked_up_clients (nb_stations_picked_up_clients + 1)
        set total_nb_clients_picked_up total_nb_clients_picked_up + nb_clients_picked_up
        set occupation_rate_vehicle (nb_clients_picked_up * 100 / capacity_occupation)
        set vpk ((total_nb_clients_picked_up * 100) / distance_travelled)
        set pick_up_rate (nb_stations_picked_up_clients / nb_stations_crossed ) * 100
      ]
      set state 0
    ]
    [
    set list_stations_clients_waiting remove next_node list_stations_clients_waiting
    ifelse [final_destination? = 0] of next_node
    [ ask next_node [set color green]]
    [ ask next_node [set color red]]
    set state 0
    ]
end

to drop.clients.act  ;
  let n nb_clients_picked_up
  ask final_destination_vehicle
    [
    set nb_clients_droped nb_clients_droped + n
;    set gross_potential (gross_potential + n)
    set total_nb_clients_final_destination total_nb_clients_final_destination + n
    ]
  set nb_clients_picked_up 0
  set my_clients []
  set selected_clients []
  ask clients with [vehicle? = [who] of myself]
    [die]
  set final_destination_vehicle 0
  set route []
  set color yellow
  set state 1
end


to communicate
  ifelse [nb_clients_waiting] of next_node > 0
        [
           if not member? next_node list_stations_clients_waiting
           [
           set list_stations_clients_waiting fput next_node list_stations_clients_waiting
           ask next_node [set color blue]
           ]
        ]
        [
          set list_stations_clients_waiting remove next_node list_stations_clients_waiting
          ifelse [final_destination? = 0] of next_node
          [ ask next_node [set color green]]
          [ ask next_node [set color red]]
          set state 0
        ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; cooperation model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go.cooperate
  if ticks = ((patterns * nb_ticks_patterns) - 1)
  [
    create.clients.station
    update.stations.potential
    choose.clients.final.destination
    set patterns (patterns + 1)
;    if write-clients? = true [export.clients]
  ]
  ask clients [ set waiting_time waiting_time + 1 ]
  count.clients.waiting
  go.vehicles.cooperation
  plotting
  draw.traffic
  update.draw.traffic
  tick
end

to go.vehicles.cooperation  ; Sequence des procedures des vehicles
  ask vehicles with [model = 2]
  [
    ifelse state = 0
      [choose.station.cooperation]
      [ifelse state = 1
        [pick.up.clients.cooperation]
        [ifelse state = 2
          [drop.clients]
          [circulate]
        ]
      ]
  ]
end


to choose.station.cooperation  ; Choisir le prochain noeud sur lequel va passer le vehicle
  ifelse final_destination_vehicle = 0
   [
        ifelse empty? list_stations_clients_waiting
        [
          set current_node next_node
          set next_node one-of [link-neighbors] of current_node
          let ns next_node
          ask current_node
          [
            ask link-with ns [ set gross_traffic (gross_traffic + 1)]
            set frequentation frequentation + 1
          ]
        ]
        [
          set list_stations_clients_waiting sort-by [ [?1 ?2] -> [distance myself] of ?1 < [distance myself] of ?2 ] list_stations_clients_waiting
          let station-a-desservir first list_stations_clients_waiting
          set last_node current_node
          set current_node next_node
          set next_link_neighbors [link-neighbors] of current_node
          set next_link_neighbors sort-by [ [?1 ?2] -> [distance station-a-desservir] of ?1 < [distance station-a-desservir] of ?2 ] next_link_neighbors
          set next_node min-one-of [link-neighbors] of current_node [distance station-a-desservir]
          while [next_node = last_node and length next_link_neighbors > 1]
          [
            set next_node one-of [link-neighbors] of current_node
          ]
          if next_node = station-a-desservir and final_destination_vehicle = 0 [ set list_stations_clients_waiting remove-item 0 list_stations_clients_waiting]
          let ns next_node
          ask current_node
          [
            ask link-with ns [ set gross_traffic (gross_traffic + 1)]
            set frequentation frequentation + 1
            set gross_potential gross_potential + 1
          ]
        ]
   ]
   [
     let dest final_destination_vehicle
     set last_node current_node
     set current_node next_node
     set next_link_neighbors [link-neighbors] of current_node
     set next_link_neighbors sort-by [ [?1 ?2] -> [distance dest] of ?1 < [distance dest] of ?2 ] next_link_neighbors
     set next_node min-one-of [link-neighbors] of current_node [distance dest]
     while [next_node = last_node and length next_link_neighbors > 1]
       [
         set next_node one-of [link-neighbors] of current_node
       ]
     let ns next_node
     ask current_node
       [
         ask link-with ns [ set gross_traffic (gross_traffic + 1)]
         set frequentation frequentation + 1
         set gross_potential gross_potential + 1
       ]
  ]
  set nb_stations_crossed (nb_stations_crossed + 1)
  set state 3
end

to cooperate
  ifelse [nb_clients_waiting] of next_node > 0
        [
           if not member? next_node list_stations_clients_waiting
           [
           set list_stations_clients_waiting fput next_node list_stations_clients_waiting
           ask next_node [set color blue]
           ]
        ]
        [
          set list_stations_clients_waiting remove next_node list_stations_clients_waiting
          ifelse [final_destination? = 0] of next_node
          [ ask next_node [set color green]]
          [ ask next_node [set color red]]
          set state 0
        ]
end



to pick.up.clients  ;
  if any? clients-here with [vehicle? = 0]
    [
      let nb-clients-here [nb_clients_waiting] of next_node
      if length my_clients = 0
        [ set final_destination_vehicle [final_destination] of one-of clients-here with [vehicle? = 0] ]
      let dest-vehicle final_destination_vehicle
      let nb-clients-possible count clients-here with [vehicle? = 0 and final_destination = dest-vehicle]
      if nb-clients-possible > 0
      [
        let nb-clients-a-prendre min (list (capacity_occupation - nb_clients_picked_up) nb-clients-possible)
        if nb-clients-a-prendre = 1
        [ set selected_clients one-of clients-here with [vehicle? = 0 and final_destination = dest-vehicle ] ]
        if nb-clients-a-prendre > 1
        [ set selected_clients n-of nb-clients-a-prendre clients-here with [vehicle? = 0 and final_destination = dest-vehicle ] ]
        ask selected_clients
        [
          set vehicle? [who] of myself
          set color red
        ]
        set color orange
        set my_clients fput selected_clients my_clients
        set nb_clients_picked_up count clients with [vehicle? = [who] of myself ]
        ask next_node
        [
          set nb_clients_picked_up_station (nb_clients_picked_up_station + [nb_clients_picked_up] of myself)
          set gross_potential (gross_potential + ([nb_clients_picked_up] of myself) * vehicle_atractivity_facteur)
        ]
        set occupation_rate_vehicle ((nb_clients_picked_up / capacity_occupation) * 100)
        set total_nb_clients_picked_up total_nb_clients_picked_up + nb_clients_picked_up
        set vpk ((total_nb_clients_picked_up * 100) / distance_travelled)
        set nb_stations_picked_up_clients (nb_stations_picked_up_clients + 1)
        set pick_up_rate (nb_stations_picked_up_clients / nb_stations_crossed ) * 100
      ]
    ]
    set state 0
end

to pick.up.clients.cooperation  ; Choisir les clients et les embarquer
  ifelse any? clients-here with [vehicle? = 0]
    [
      let nb-clients-here [nb_clients_waiting] of next_node
      if length my_clients = 0
        [ set final_destination_vehicle [final_destination] of one-of clients-here with [vehicle? = 0] ]
      let dest-vehicle final_destination_vehicle
      let nb-clients-possibles count clients-here with [vehicle? = 0 and final_destination = dest-vehicle]
      if nb-clients-possibles > 0
      [
        let nb-clients-a-prendre min (list (capacity_occupation - nb_clients_picked_up) nb-clients-possibles)
        if nb-clients-a-prendre = 1
        [ set selected_clients one-of clients-here with [vehicle? = 0 and final_destination = dest-vehicle ] ]
        if nb-clients-a-prendre > 1
        [ set selected_clients n-of nb-clients-a-prendre clients-here with [vehicle? = 0 and final_destination = dest-vehicle ] ]
        ask selected_clients
        [
          set vehicle? [who] of myself
          set color red
        ]
        set color orange
        set my_clients fput selected_clients my_clients
        set nb_clients_picked_up count clients with [vehicle? = [who] of myself ]
        ask next_node
        [
          set nb_clients_picked_up_station (nb_clients_picked_up_station + [nb_clients_picked_up] of myself)
          set gross_potential (gross_potential + ([nb_clients_picked_up] of myself) * vehicle_atractivity_facteur)
          set nb_clients_waiting (nb-clients-here - [nb_clients_picked_up] of myself)
        ]
        cooperate
        set nb_stations_picked_up_clients (nb_stations_picked_up_clients + 1)
        set total_nb_clients_picked_up total_nb_clients_picked_up + nb_clients_picked_up
        set occupation_rate_vehicle (nb_clients_picked_up * 100 / capacity_occupation)
        set vpk ((total_nb_clients_picked_up * 100) / distance_travelled)
        set pick_up_rate (nb_stations_picked_up_clients / nb_stations_crossed ) * 100
      ]
      set state 0
    ]
    [
    set list_stations_clients_waiting remove next_node list_stations_clients_waiting
    ifelse [final_destination? = 0] of next_node
    [ ask next_node [set color green]]
    [ ask next_node [set color red]]
    set state 0
    ]
end










;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; bus model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



to create.buses.first.bus.line.1  ; create des vehicles (grace a un slider) se situant aleatoirement sur des stations
  create-buses 1
  [
    set shape "bus"
    set size 4
    set color white
    set bus_line?? 1
    let first-station first path_bus_line_1
    set current_node station first-station
    set direction 0
    move-to current_node
    let id_station_current_node [who] of current_node
    set position_station_bus_line_2 100
    set position_station_bus_line_1 position id_station_current_node path_bus_line_1
    let id_station_next_node item (position_station_bus_line_1 + 1) path_bus_line_1
    set next_node station id_station_next_node
    set nb_stations_crossed (nb_stations_crossed + 1)
    let ns next_node
    ask current_node
       [ ask link-with ns [ set gross_traffic (gross_traffic + 1)]]
    set state 1
    set my_clients []
    set selected_clients []
    set occupation_rate_vehicle 0
  ]
  set list-buses [who] of buses
end

to create.buses.first.bus.line.2  ; create des vehicles (grace a un slider) se situant aleatoirement sur des stations
  create-buses 1
  [
    set shape "bus"
    set size 4
    set color white
    set bus_line?? 2
    let first-station first path_bus_line_2
    set current_node station first-station
    set direction 0
    move-to current_node
    let id_station_current_node [who] of current_node
    set position_station_bus_line_1 100
    set position_station_bus_line_2 position id_station_current_node path_bus_line_2
    let id_station_next_node item (position_station_bus_line_2 + 1) path_bus_line_2
    set next_node station id_station_next_node
    set nb_stations_crossed (nb_stations_crossed + 1)
    let ns next_node
    ask current_node
       [ ask link-with ns [ set gross_traffic (gross_traffic + 1)]]
    set state 1
    set my_clients []
    set selected_clients []
    set occupation_rate_vehicle 0
  ]
  set list-buses [who] of buses
end

to create.buses.last.bus.line.1  ; create des vehicles (grace a un slider) se situant aleatoirement sur des stations
  create-buses 1
  [
    set bus_line?? 1
    let last-station last path_bus_line_1
    set current_node station last-station
    set direction 1
    move-to current_node
    let id_station_current_node [who] of current_node
    set position_station_bus_line_2 100
    set position_station_bus_line_1 position id_station_current_node path_bus_line_1
    let id_station_next_node item (position_station_bus_line_1 - 1) path_bus_line_1
    set next_node station id_station_next_node
    set nb_stations_crossed (nb_stations_crossed + 1)
    let ns next_node
    ask current_node
       [ ask link-with ns [ set gross_traffic (gross_traffic + 1)]]
    set shape "bus"
    set size 4
    set color white
    set state 1
    set my_clients []
    set selected_clients []
    set occupation_rate_vehicle 0
  ]
  set list-buses [who] of buses
end

to create.buses.last.bus.line.2  ; create des vehicles (grace a un slider) se situant aleatoirement sur des stations
  create-buses 1
  [
    set bus_line?? 2
    let last-station last path_bus_line_2
    set current_node station last-station
    set direction 1
    move-to current_node
    let id_station_current_node [who] of current_node
    set position_station_bus_line_1 100
    set position_station_bus_line_2 position id_station_current_node path_bus_line_2
    let id_station_next_node item (position_station_bus_line_2 - 1) path_bus_line_2
    set next_node station id_station_next_node
    set nb_stations_crossed (nb_stations_crossed + 1)
    let ns next_node
    ask current_node
       [ ask link-with ns [ set gross_traffic (gross_traffic + 1)]]
    set shape "bus"
    set size 4
    set color white
    set state 1
    set my_clients []
    set selected_clients []
    set occupation_rate_vehicle 0
  ]
  set list-buses [who] of buses
end

to go.bus
  if ticks = ((patterns * nb_ticks_patterns) - 1)
  [
    create.clients.station
    update.stations.potential
    choose.clients.final.destination
    set patterns (patterns + 1)
;    if write-clients? = true [export.clients]
  ]
  ask clients [ set waiting_time waiting_time + 1 ]
  count.clients.waiting
  go.buses
  plotting
  tick
end


to go.buses  ;
  ask buses
  [
    ifelse state = 0
      [
        drop.clients.bus
        ifelse bus_line?? = 1
        [choose.station.bus.1]
        [choose.station.bus.2]
        pick.up.clients.bus
      ]
      [circulate.bus]
  ]
end


to choose.station.bus.1
  if position_station_bus_line_1 < 100
  [
    if [who] of next_node = last path_bus_line_1
    [set direction 1]
    if [who] of next_node = first path_bus_line_1
    [set direction 0]
    ifelse direction = 0
    [
      set current_node next_node
      let id_station_current_node [who] of next_node
      set position_station_bus_line_1 position id_station_current_node path_bus_line_1
      let id_station_next_node item (position_station_bus_line_1 + 1) path_bus_line_1
      set next_node station id_station_next_node
    ]
    [
      set current_node next_node
      let id_station_current_node [who] of next_node
      set position_station_bus_line_1 position id_station_current_node path_bus_line_1
      let id_station_next_node item (position_station_bus_line_1 - 1) path_bus_line_1
      set next_node station id_station_next_node
    ]
    let ns next_node
    ask current_node
    [
      ask link-with ns [ set gross_traffic (gross_traffic + 1)]
      set frequentation frequentation + 1
    ]
    set nb_stations_crossed (nb_stations_crossed + 1)
  ]
end

to choose.station.bus.2
  if position_station_bus_line_2 < 100
  [
    if [who] of next_node = last path_bus_line_2
    [set direction 1]
    if [who] of next_node = first path_bus_line_2
    [set direction 0]
    ifelse direction = 0
    [
      set current_node next_node
      let id_station_current_node [who] of next_node
      set position_station_bus_line_2 position id_station_current_node path_bus_line_2
      let id_station_next_node item (position_station_bus_line_2 + 1) path_bus_line_2
      set next_node station id_station_next_node
    ]
    [
      set current_node next_node
      let id_station_current_node [who] of next_node
      set position_station_bus_line_2 position id_station_current_node path_bus_line_2
      let id_station_next_node item (position_station_bus_line_2 - 1) path_bus_line_2
      set next_node station id_station_next_node
    ]
    let ns next_node
    ask current_node
    [
      ask link-with ns [ set gross_traffic (gross_traffic + 1)]
      set frequentation frequentation + 1
    ]
    set nb_stations_crossed (nb_stations_crossed + 1)
  ]
end

to pick.up.clients.bus ;
  if any? clients-here with [vehicle? = 0 and bus_line? = [bus_line??] of myself and direction-bus_line = [direction] of myself]
    [
      let nb-clients-here [nb_clients_waiting] of current_node
      let nb-clients-possibles count clients-here with [vehicle? = 0 and bus_line? = [bus_line??] of myself and direction-bus_line = [direction] of myself]
      if nb-clients-possibles > 0
      [
        let nb-clients-a-prendre min (list (capacity_occupation_buses - nb_clients_picked_up) nb-clients-possibles)
        if nb-clients-a-prendre > 0
        [
          if nb-clients-a-prendre = 1
          [ set selected_clients one-of clients-here with [vehicle? = 0 and bus_line? = [bus_line??] of myself and direction-bus_line = [direction] of myself]]
          if nb-clients-a-prendre > 1
          [ set selected_clients n-of nb-clients-a-prendre clients-here with [vehicle? = 0 and bus_line? = [bus_line??] of myself and direction-bus_line = [direction] of myself]]
          ask selected_clients
          [
            set vehicle? [who] of myself
            set color red
          ]
          set color orange
          set my_clients fput selected_clients my_clients
          set nb_clients_picked_up count clients with [vehicle? = [who] of myself ]
          ask current_node
          [
            set nb_clients_picked_up_station (nb_clients_picked_up_station + [nb_clients_picked_up] of myself)
            set gross_potential (gross_potential + ([nb_clients_picked_up] of myself) * vehicle_atractivity_facteur)
          ]
        set nb_stations_picked_up_clients (nb_stations_picked_up_clients + 1)
        set total_nb_clients_picked_up total_nb_clients_picked_up + nb_clients_picked_up
        set occupation_rate_vehicle (nb_clients_picked_up * 100 / capacity_occupation)
        set vpk ((total_nb_clients_picked_up * 100) / distance_travelled)
        set pick_up_rate (nb_stations_picked_up_clients / nb_stations_crossed ) * 100
        ]
      ]
    ]
  set state 1
end


to drop.clients  ;
  let n nb_clients_picked_up
  ask final_destination_vehicle
    [
    set nb_clients_droped nb_clients_droped + n
    set gross_potential (gross_potential + n)
    set total_nb_clients_final_destination total_nb_clients_final_destination + n
    ]
  set nb_clients_picked_up 0
  set my_clients []
  set selected_clients []
  ask clients with [vehicle? = [who] of myself]
    [die]
  set final_destination_vehicle 0
  set route []
  set color yellow
  set state 1
end

to drop.clients.bus  ;
  set clients_to_drop count clients with [vehicle? = [who] of myself and final_destination = [next_node] of myself]
  set nb_clients_picked_up nb_clients_picked_up - clients_to_drop
  set selected_clients []
  set my_clients []
  if occupation_rate_vehicle < 1 [set color white]
  set occupation_rate_vehicle (nb_clients_picked_up * 100 / capacity_occupation_buses)
  let n clients_to_drop
  ask next_node
    [
    set nb_clients_droped nb_clients_droped + n
    set gross_potential (gross_potential + n)
    set total_nb_clients_final_destination total_nb_clients_final_destination + n
    ]
  ask clients with [vehicle? = [who] of myself and final_destination = [next_node] of myself]
    [die]

end



to circulate.bus  ;
  set heading towards next_node
  if nb_clients_picked_up > 0
    [
      ask clients with [vehicle? = [who] of myself]
        [
          move-to myself
          set heading [heading] of myself
        ]
    ]
  ifelse distance next_node > 1
  [
    fd moving_speed * speed_factor_bus
    if length my_clients > 0
      [
        ask clients with [vehicle? = [who] of myself]
          [
            fd moving_speed * speed_factor_bus
            set distance_travelled_clients  distance_travelled_clients + 1
          ]
      ]
  ]
  [
    move-to next_node
    set state 0
  ]
  set distance_travelled  distance_travelled + 1
end







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; hybrid model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go.hybrid
  if ticks = (patterns * nb_ticks_patterns - 1)
  [
    ifelse zone? = true
    [
      create.clients.zone
      update.stations.potential
      choose.clients.final.destination
      set patterns (patterns + 1)
    ]
    [
      create.clients
      create.clients
      update.stations.potential
      choose.clients.final.destination
      set patterns (patterns + 1)
    ]
  ]
  ifelse (clients_alive < 800)
  [
     set hybrid_state 1
     ask stations
      [
        set targeted 0
        set serving_taxi []
      ]
     ask clients [ set list_vehicles_serving_destination []]
     set list_stations_clients_waiting []
     ask stations with [final_destination? = 0]
      [
        set color green
      ]
      ask stations with [final_destination? = 1]
      [
        set color red
      ]
    ask vehicles [set model 6]
    move.clients
    count.clients.waiting
    go.vehicles.clandos
    plotting
    draw.traffic
    update.draw.traffic
    tick
  ]
  [
    ifelse (clients_alive > 1400 or mean_waiting_time_clients > 6000)
    [
      set hybrid_state 3
      set list_stations_clients_waiting []
      ask stations with [final_destination? = 0]
      [
        set color green
      ]
      ask stations with [final_destination? = 1]
      [
        set color red
      ]
      choose.clients.station.modulobus
      move.clients
      count.clients.waiting
      ask vehicles [set model 5]
      go.vehicles.modulobus
      plotting
      draw.traffic
      update.draw.traffic
      tick
    ]
    [
      set hybrid_state 2
      ask stations
      [
        set targeted 0
        set serving_taxi []
      ]
      ask clients [ set list_vehicles_serving_destination []]
      ask vehicles [set model 2]
      move.clients
      count.clients.waiting
      go.vehicles.cooperation
      plotting
      draw.traffic
      update.draw.traffic
      tick
    ]
  ]
end










;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; mixte informal model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go.mixte.informal
  if ticks = ((patterns * nb_ticks_patterns) - 1)
  [
    ifelse zone? = true
    [
      create.clients.zone
      update.stations.potential
      choose.clients.final.destination
      set patterns (patterns + 1)
    ]
    [
      create.clients
      create.clients
      update.stations.potential
      choose.clients.final.destination
      set patterns (patterns + 1)
    ]
  ]
  move.clients
  count.clients.waiting
  go.vehicles.cooperation
  go.vehicles.clandos
  plotting
  draw.traffic
  update.draw.traffic
  tick
end











;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; mixte formal model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go.mixte.formal
  if ticks = ((patterns * nb_ticks_patterns) - 1)
  [
    ifelse zone? = true
    [
      create.clients.zone
      update.stations.potential
      choose.clients.final.destination
      set patterns (patterns + 1)
    ]
    [
      create.clients
      create.clients
      update.stations.potential
      choose.clients.final.destination
      set patterns (patterns + 1)
    ]
  ]
  choose.clients.station.modulobus
  move.clients
  count.clients.waiting
  go.buses
  go.vehicles.modulobus
  plotting
  draw.traffic
  update.draw.traffic
  tick
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; mixte all model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go.mixte.all
  if ticks = (patterns * nb_ticks_patterns - 1)
  [
    ifelse zone? = true
    [
      create.clients.zone
      update.stations.potential
      choose.clients.final.destination
      set patterns (patterns + 1)
    ]
    [
      create.clients
      create.clients
      update.stations.potential
      choose.clients.final.destination
      set patterns (patterns + 1)
    ]
  ]
  go.vehicles.clandos
  go.vehicles.cooperation
  choose.clients.station.modulobus
  move.clients
  count.clients.waiting
  go.vehicles.modulobus
  plotting
  draw.traffic
  update.draw.traffic
  tick
end






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; mixte flexible model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go.mixte.flexible
  if ticks = (patterns * nb_ticks_patterns - 1)
  [
    ifelse zone? = true
    [
      create.clients.zone
      update.stations.potential
      choose.clients.final.destination
      set patterns (patterns + 1)
    ]
    [
      create.clients
      create.clients
      update.stations.potential
      choose.clients.final.destination
      set patterns (patterns + 1)
    ]
  ]
    go.vehicles.cooperation
  choose.clients.station.modulobus
  move.clients
  count.clients.waiting
  go.vehicles.modulobus
  plotting
  draw.traffic
  update.draw.traffic
  tick
end




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; mixte rigid model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go.mixte.rigid
  if ticks = ((patterns * nb_ticks_patterns) - 1)
  [
    ifelse zone? = true
    [
      create.clients.zone
      update.stations.potential
      choose.clients.final.destination
      set patterns (patterns + 1)
    ]
    [
      create.clients
      create.clients
      update.stations.potential
      choose.clients.final.destination
      set patterns (patterns + 1)
    ]
  ]
  move.clients
  count.clients.waiting
  go.buses
  go.vehicles.clandos
  plotting
  draw.traffic
  update.draw.traffic
  tick
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; mixte taxi bus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go.mixte.taxibus
  if ticks = ((patterns * nb_ticks_patterns) - 1)
  [
    create.clients.station
    update.stations.potential
    choose.clients.final.destination
    set patterns (patterns + 1)
  ]
  ask clients [ set waiting_time waiting_time + 1 ]
  count.clients.waiting
  go.buses
  ;communicate.act
  go.vehicles.distance
  plotting
  draw.traffic
  update.draw.traffic
  tick
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; mixte frsn model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go.mixte.frsn
  if ticks = (patterns * nb_ticks_patterns - 1)
  [
    ifelse zone? = true
    [
      create.clients.zone
      update.stations.potential
      choose.clients.final.destination
      set patterns (patterns + 1)
    ]
    [
      create.clients
      create.clients
      update.stations.potential
      choose.clients.final.destination
      set patterns (patterns + 1)
    ]
  ]
  go.vehicles.clandos
  choose.clients.station.modulobus
  move.clients
  count.clients.waiting
  go.vehicles.modulobus
  plotting
  draw.traffic
  update.draw.traffic
  tick
end








;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Plots
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to draw.traffic  ; Trace des trajets en fonction du traffic
  ask links
  [
    set thickness 0.01
    set color 9.9
  ]
  ask links with [gross_traffic > 1]
  [
    set thickness 0.01 + net_traffic
    set color 135
  ]
end


to plotting  ; Tracer le graphique du nombre de clients deposes sur chaque marche

  set clients_alive count clients

  ;;;; PICK UP RATE

  set-current-plot "pick up rate"
  ifelse model_choice = "bus"
  [
    set mean_pick_up_rate_buses mean [pick_up_rate] of buses
    set-current-plot-pen "buses"
    plot mean_pick_up_rate_buses
  ]
  [
    ifelse (model_choice = "mixte formal" or model_choice = "mixte rigid")
    [
      set mean_pick_up_rate_buses mean [pick_up_rate] of buses
      set-current-plot-pen "buses"
      plot mean_pick_up_rate_buses
      set-current-plot-pen "mean all"
      plot mean [pick_up_rate] of vehicles
    ]
    [
      ifelse model_choice = "mixte informal"
      [
        set-current-plot-pen "cooperation"
        plot mean [pick_up_rate] of vehicles with [model = 2]
        set-current-plot-pen "clandos"
        plot mean [pick_up_rate] of vehicles with [model = 6]
        set-current-plot-pen "mean all"
        plot mean [pick_up_rate] of vehicles
      ]
      [
          ifelse model_choice = "mixte flexible"
          [
            set-current-plot-pen "cooperation"
            plot mean [pick_up_rate] of vehicles with [model = 2]
            set-current-plot-pen "modulobus"
            plot mean [pick_up_rate] of vehicles with [model = 5]
            set-current-plot-pen "mean all"
            plot mean [pick_up_rate] of vehicles
          ]
          [
            ifelse model_choice = "mixte frsn"
            [
              set-current-plot-pen "clandos"
              plot mean [pick_up_rate] of vehicles with [model = 6]
              set-current-plot-pen "modulobus"
              plot mean [pick_up_rate] of vehicles with [model = 5]
              set-current-plot-pen "mean all"
              plot mean [pick_up_rate] of vehicles
            ]
            [
              ifelse model_choice = "mixte taxi bus"
              [
                set mean_pick_up_rate_buses mean [pick_up_rate] of buses
                set-current-plot-pen "buses"
                plot mean_pick_up_rate_buses
                set mean_pick_up_rate_vehicles mean [pick_up_rate] of vehicles with [model = 4]
                set-current-plot-pen "distance"
                plot mean_pick_up_rate_vehicles
                set mean-pick-rate ((mean_pick_up_rate_vehicles + mean_pick_up_rate_buses) / 2)
                set-current-plot-pen "mean all"
                plot mean-pick-rate
              ]
              [
                set mean-pick-rate mean [pick_up_rate] of vehicles
                set-current-plot-pen "mean all"
                plot mean-pick-rate
              ]
            ]
          ]
      ]
    ]
  ]


  ;;;; vpk

  set-current-plot "vpk"
   ifelse model_choice = "bus"
  [
    set mean_vpk_buses mean [vpk] of buses
    set-current-plot-pen "buses"
    plot mean_vpk_buses
  ]
  [
    ifelse (model_choice = "mixte formal" or model_choice = "mixte rigid")
    [
      set mean_vpk_buses mean [vpk] of buses
      set-current-plot-pen "buses"
      plot mean_vpk_buses
      set-current-plot-pen "mean all"
      plot mean [pick_up_rate] of vehicles
    ]
    [
      ifelse model_choice = "mixte flexible"
      [
        set mean_vpk mean [vpk] of vehicles
        set-current-plot-pen "mean all"
        plot mean_vpk
        set-current-plot-pen "cooperation"
        plot mean [vpk] of vehicles with [model = 2]
        set-current-plot-pen "modulobus"
        plot mean [vpk] of vehicles with [model = 5]
      ]
      [
           ifelse model_choice = "mixte informal"
           [
             set mean_vpk mean [vpk] of vehicles
             set-current-plot-pen "mean all"
             plot mean_vpk
             set-current-plot-pen "cooperation"
             plot mean [vpk] of vehicles with [model = 2]
             set-current-plot-pen "clandos"
             plot mean [vpk] of vehicles with [model = 6]
           ]
           [
             ifelse model_choice = "mixte frsn"
             [
               set-current-plot-pen "mean all"
               plot mean [vpk] of vehicles
               set-current-plot-pen "modulobus"
               plot mean [vpk] of vehicles with [model = 5]
               set-current-plot-pen "clandos"
               plot mean [vpk] of vehicles with [model = 6]
             ]
             [
               ifelse model_choice = "mixte taxi bus"
               [
                 set mean_vpk_buses mean [vpk] of buses
                 set-current-plot-pen "buses"
                 plot mean_vpk_buses
                 set mean_vpk_vehicles mean [vpk] of vehicles with [model = 4]
                 set-current-plot-pen "distance"
                 plot mean_vpk_vehicles
                 set mean_vpk ((mean_vpk_vehicles + mean_vpk_buses) / 2)
                 set-current-plot-pen "mean all"
                 plot mean_vpk
               ]
               [
                 set mean_vpk mean [vpk] of vehicles
                 set-current-plot-pen "mean all"
                 plot mean_vpk
               ]
             ]
           ]
      ]
    ]
  ]

  set-current-plot "servicing rate"
  set servincing_rate (total_nb_clients_final_destination / total_nb_clients_created) * 100
  set-current-plot-pen "servincing rate" plot servincing_rate

  set-current-plot "stations with waiting clients"
  set client_station_rate ((count stations with [nb_clients_waiting > 0]) / nb_stations) * 100
  set sum_client_station_rate sum_client_station_rate + client_station_rate
  set mean_client_station_rate sum_client_station_rate / (ticks + 1)
  plot mean_client_station_rate

  set-current-plot "mean of clients wainting"
  set mean_clients_waiting mean [nb_clients_waiting] of stations
  set sum_mean_clients_waiting sum_mean_clients_waiting + mean_clients_waiting
  set mean_mean_clients_waiting sum_mean_clients_waiting / (ticks + 1)
  plot mean_mean_clients_waiting

  set-current-plot "mean waiting time clients"
  if clients_alive > 0
  [
    set mean_waiting_time_clients mean [waiting_time] of clients
    set sum_mean_waiting_time_clients sum_mean_waiting_time_clients + mean_waiting_time_clients
    set mean_mean_waiting_time_clients sum_mean_waiting_time_clients / (ticks + 1)
  ]
  plot mean_mean_waiting_time_clients

  set-current-plot "mean_distance_travelled_clients"
  if clients_alive > 0
  [
    set mean_distance_travelled_clients mean [distance_travelled_clients] of clients
    set sum_mean_distance_travelled_clients sum_mean_distance_travelled_clients + mean_distance_travelled_clients
    set mean_mean_distance_travelled_clients sum_mean_distance_travelled_clients / (ticks + 1)
  ]
  plot mean_mean_distance_travelled_clients

  set-current-plot "mean_max_clients_station_waiting"
  set sum_max_clients_station_waiting sum_max_clients_station_waiting + max_clients_station_waiting
  set mean_max_clients_station_waiting sum_max_clients_station_waiting / (ticks + 1)
  plot mean_max_clients_station_waiting

  if model_choice = "hybrid"
  [
    set-current-plot "hybrid_state"
    plot hybrid_state
  ]

  ;;; occupation rate

   ifelse model_choice = "bus"
  [
    set-current-plot "occupation rate 1"
    plot [occupation_rate_vehicle] of one-of buses with [bus_line?? = 1]

    set-current-plot "mean_occupation_rate"
    set mean_occupation_rate_buses mean [occupation_rate_vehicle] of buses
    set sum_mean_occupation_rate_buses sum_mean_occupation_rate_buses + mean_occupation_rate_buses
    set mean_mean_occupation_rate_buses sum_mean_occupation_rate_buses / (ticks + 1)
    set-current-plot-pen "buses"
    plot mean_mean_occupation_rate_buses
  ]
  [
    ifelse (model_choice = "mixte formal" or model_choice = "mixte rigid" or model_choice = "mixte taxi bus")
    [
      set-current-plot "occupation rate 1"
      plot [occupation_rate_vehicle] of one-of buses with [bus_line?? = 1]

      set-current-plot "mean_occupation_rate"
      set mean_occupation_rate_buses mean [occupation_rate_vehicle] of buses
      set sum_mean_occupation_rate_buses sum_mean_occupation_rate_buses + mean_occupation_rate_buses
      set mean_mean_occupation_rate_buses sum_mean_occupation_rate_buses / (ticks + 1)
      set-current-plot-pen "buses"
      plot mean_mean_occupation_rate_buses

      set-current-plot "mean_occupation_rate"
      set mean_occupation_rate mean [occupation_rate_vehicle] of vehicles
      set sum_mean_occupation_rate sum_mean_occupation_rate + mean_occupation_rate
      set mean_mean_occupation_rate sum_mean_occupation_rate / (ticks + 1)
      set-current-plot-pen "distance"
      plot mean_mean_occupation_rate
      set mean_mean_occupation_rate_all ((mean_mean_occupation_rate + mean_mean_occupation_rate_buses) / 2)
      set-current-plot-pen "mean all"
      plot mean_mean_occupation_rate_all
    ]
    [
      ifelse model_choice = "mixte informal"
      [
        set-current-plot "occupation rate 1"
        plot [occupation_rate_vehicle] of one-of vehicles with [model = 6]
        set-current-plot "occupation rate 2"
        plot [occupation_rate_vehicle] of one-of vehicles with [model = 2]
      ]
      [
        ifelse model_choice = "mixte frsn"
        [
          set-current-plot "occupation rate 1"
          plot [occupation_rate_vehicle] of one-of vehicles with [model = 6]
          set-current-plot "occupation rate 2"
          plot [occupation_rate_vehicle] of one-of vehicles with [model = 5]
        ]
        [
          ifelse model_choice = "mixte flexible"
          [
            set-current-plot "occupation rate 1"
            plot [occupation_rate_vehicle] of one-of vehicles with [model = 5]
            set-current-plot "occupation rate 2"
            plot [occupation_rate_vehicle] of one-of vehicles with [model = 2]
          ]
          [
            set-current-plot "occupation rate 1"
            if length list_vehicles > 1
            [
              plot [occupation_rate_vehicle] of (vehicle item 1 list_vehicles)
            ]
            set-current-plot "mean_occupation_rate"
            set mean_occupation_rate mean [occupation_rate_vehicle] of vehicles
            set sum_mean_occupation_rate sum_mean_occupation_rate + mean_occupation_rate
            set mean_mean_occupation_rate sum_mean_occupation_rate / (ticks + 1)
            plot mean_mean_occupation_rate
          ]
        ]
      ]
    ]
  ]
  set time timer
end


to export.clients
  file-open "clients.txt"
  file-print (word "Tick Number: " ticks)
  foreach sort clients [ t ->
    ask t [
      file-print (word self ": pxcor: " pxcor " pycor: " pycor " xcor destination: " [xcor] of final_destination " ycor destination: " [ycor] of final_destination )
    ]
  ]
  file-print ""  ;; blank line
  file-close
end

to export.data
  set date-time date-and-time
  set date-time replace-item 2 date-time "."
  set date-time replace-item 5 date-time "."
  export-world (word model_choice "-" date-time "-world.csv")
  export-interface (word model_choice "-" date-time "-interface.png")
  file-open (word model_choice "-" date-time "-indicators.csv")
  file-print (word "Tick Number: " ticks)
  file-print ("mean_vpk,mean_vpk_vehicles,mean_vpk_buses,mean-pick-rate,mean_pick_up_rate_vehicles,mean_pick_up_rate_buses,mean_occupation_rate_all,mean_occupation_rate_vehicles,mean_occupation_rate_buses,servincing rate,waiting clients station rate,mean_max_clients_station_waiting,mean of clients wainting,mean waiting time clients,mean_distance_travelled_clients")
  file-print (word mean_vpk","mean_vpk_vehicles","mean_vpk_buses","mean-pick-rate","mean_pick_up_rate_vehicles","mean_pick_up_rate_buses","mean_mean_occupation_rate_all","mean_mean_occupation_rate","mean_mean_occupation_rate_buses","servincing_rate","mean_client_station_rate","mean_max_clients_station_waiting","mean_mean_clients_waiting","mean_mean_waiting_time_clients","mean_mean_distance_travelled_clients)
  file-close
end
@#$#@#$#@
GRAPHICS-WINDOW
158
10
756
651
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
1
1
1
ticks
30.0

SLIDER
1257
810
1394
843
attraction_radius_stations
attraction_radius_stations
1
100
18.0
1
1
NIL
HORIZONTAL

SLIDER
1395
810
1530
843
moving_speed
moving_speed
0
0.1
0.05
0.001
1
NIL
HORIZONTAL

SLIDER
3
339
138
372
nb_vehicles
nb_vehicles
1
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
7
770
137
803
nb_clients
nb_clients
0
150
20.0
5
1
NIL
HORIZONTAL

SLIDER
3
373
137
406
speed_factor
speed_factor
15
30
20.0
5
1
NIL
HORIZONTAL

PLOT
1433
153
1611
303
pick up rate
NIL
NIL
0.0
1.0
0.0
100.0
true
false
"" ""
PENS
"mean all" 1.0 0 -16777216 true "" ""
"clandos" 1.0 0 -7500403 true "" ""
"cooperation" 1.0 0 -1184463 true "" ""
"potential" 1.0 0 -2674135 true "" ""
"buses" 1.0 0 -14070903 true "" ""
"act" 1.0 0 -955883 true "" ""
"random" 1.0 0 -6459832 true "" ""
"distance" 1.0 0 -10899396 true "" ""

MONITOR
1807
81
1871
126
traffic max
max [gross_traffic] of links
17
1
11

MONITOR
1808
129
1863
174
ticks
ticks
1
1
11

SLIDER
0
259
134
292
nb_ticks_patterns
nb_ticks_patterns
100
600
600.0
50
1
NIL
HORIZONTAL

BUTTON
2
30
135
63
NIL
initialisation.agents
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1430
379
1608
532
stations with waiting clients
NIL
NIL
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"waiting clients station rate" 1.0 0 -16777216 true "" ""

PLOT
1258
378
1430
529
servicing rate
NIL
NIL
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"servincing rate" 1.0 0 -16777216 true "" ""

PLOT
1261
30
1786
150
occupation rate 1
NIL
NIL
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"bus_line1" 1.0 1 -12895429 true "" ""

SWITCH
16
736
123
769
zone?
zone?
1
1
-1000

CHOOSER
1
136
135
181
model_choice
model_choice
"act" "potential" "cooperation" "random" "distance" "bus" "modulobus" "clandos" "hybrid" "mixte informal" "mixte formal" "mixte flexible" "mixte rigid" "mixte frsn" "mixte taxi bus" "mixte all"
3

BUTTON
3
185
78
218
Let's GO !
go\nif ticks = simulation_time \n  [\n  export.data\n  stop\n  ]
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
1380
530
1430
575
value
precision servincing_rate 1
2
1
11

PLOT
1260
153
1432
303
vpk
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"mean all" 1.0 0 -16777216 true "" ""
"cooperation" 1.0 0 -1184463 true "" ""
"clandos" 1.0 0 -4539718 true "" ""
"potential" 1.0 0 -2674135 true "" ""
"buses" 1.0 0 -13345367 true "" ""
"act" 1.0 0 -955883 true "" ""
"random" 1.0 0 -6459832 true "" ""
"distance" 1.0 0 -10899396 true "" ""

TEXTBOX
8
10
158
29
INITIALISATION
15
0.0
1

TEXTBOX
6
86
141
128
CHOOSE THE TRANSPORTATION SERVICE TO SIMULATE
12
0.0
1

TEXTBOX
41
320
167
339
VEHICLES
12
0.0
1

TEXTBOX
25
720
149
759
DEMANDE SIDE
12
0.0
1

PLOT
1260
608
1443
762
mean of clients wainting
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"clients waiting" 1.0 0 -16777216 true "" ""

MONITOR
1560
533
1610
578
value
mean_client_station_rate
1
1
11

MONITOR
1266
303
1323
348
mean
((mean_vpk_buses + mean_vpk_vehicles) / 2)
2
1
11

MONITOR
1449
302
1499
347
mean
((mean_pick_up_rate_buses + mean_pick_up_rate_vehicles) / 2)
1
1
11

MONITOR
1810
228
1898
273
Clients Created
total_nb_clients_created
0
1
11

MONITOR
1809
177
1870
222
nb clients
count clients
17
1
11

MONITOR
1741
533
1791
578
value
mean_max_clients_station_waiting
1
1
11

PLOT
1442
608
1618
762
mean waiting time clients
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"waiting time" 1.0 0 -16777216 true "" ""

SLIDER
3
407
137
440
capacity_occupation
capacity_occupation
4
20
6.0
1
1
NIL
HORIZONTAL

PLOT
1618
608
1792
763
mean_distance_travelled_clients
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

SLIDER
4
508
139
541
capacity_occupation_buses
capacity_occupation_buses
20
60
40.0
1
1
NIL
HORIZONTAL

SLIDER
4
476
138
509
speed_factor_bus
speed_factor_bus
5
30
10.0
5
1
NIL
HORIZONTAL

MONITOR
1324
303
1381
348
buses
mean [vpk] of buses
3
1
11

MONITOR
1499
302
1556
347
buses
mean [pick_up_rate] of buses
1
1
11

BUTTON
7
548
138
581
Launch more buses
create.buses.first.bus.line.1\ncreate.buses.last.bus.line.1\n;if not empty? path_bus_line_2\n ;   [\n  ;    create.buses.first.bus.line.2\n   ;   create.buses.last.bus.line.2\n    ;]
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
54
457
139
489
BUS
12
0.0
1

MONITOR
1381
303
1431
348
vehicles
mean [vpk] of vehicles with [ shape = \"van top\"]
2
1
11

MONITOR
1556
302
1613
347
vehicles
mean [pick_up_rate] of vehicles with [ shape = \"van top\"]
1
1
11

BUTTON
79
185
134
219
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1806
32
1872
77
Nb Stations
count stations
17
1
11

MONITOR
1811
278
1893
323
Clients arrived
total_nb_clients_final_destination
17
1
11

MONITOR
1391
762
1441
807
value
mean_mean_clients_waiting
2
1
11

MONITOR
1563
763
1618
808
value
mean_mean_waiting_time_clients
1
1
11

SLIDER
1
225
133
258
simulation_time
simulation_time
0
400000
30000.0
5000
1
NIL
HORIZONTAL

MONITOR
1741
764
1791
809
value
mean_mean_distance_travelled_clients
2
1
11

TEXTBOX
1265
12
1782
30
-------------------------------------------------------------Operator-------------------------------------------------------------
11
0.0
0

TEXTBOX
1261
592
1795
612
-------------------------------------------------------------Clients---------------------------------------------------------------
11
0.0
1

TEXTBOX
1257
363
1792
381
-------------------------------------------------------------Territory-------------------------------------------------------------
11
0.0
1

PLOT
1612
153
1788
303
mean_occupation_rate
NIL
NIL
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"mean all" 1.0 0 -16777216 true "" ""
"cooperation" 1.0 0 -1184463 true "" ""
"clandos" 1.0 0 -7500403 true "" ""
"potential" 1.0 0 -2674135 true "" ""
"act" 1.0 0 -955883 true "" ""
"buses" 1.0 0 -13345367 true "" ""
"random" 1.0 0 -6459832 true "" ""
"distance" 1.0 0 -10899396 true "" ""

MONITOR
1612
303
1669
348
mean
mean_mean_occupation_rate_all
1
1
11

PLOT
1610
378
1791
531
mean_max_clients_station_waiting
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

SLIDER
1530
811
1666
844
max_walking_distance
max_walking_distance
0
100
0.0
1
1
NIL
HORIZONTAL

BUTTON
13
587
133
620
Enter Bus Line 1
set path_bus_line_1 fput read-from-string user-input \"Enter bus line\" path_bus_line_1\nask station item 0 path_bus_line_1 [set bus_line 1]\nif length path_bus_line_1 > 1 [ask link item 0 path_bus_line_1 item 1 path_bus_line_1 [set thickness 2 set link_bus_line 1 set color 105]]
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
11
624
134
657
Confirm bus line 
 set path_bus_line_1 reverse path_bus_line_1\n user-message (word \"stations of the bus line 1 are \" path_bus_line_1)\n set nb_bus_line 1
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
16
660
125
693
Clear Bus Line
set path_bus_line_1 []\nask links [set thickness 0.02 set color white]\nask stations [set bus_line 0]\nask links [set link_bus_line 0]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1669
303
1726
348
buses
mean_mean_occupation_rate_buses
2
1
11

MONITOR
1726
303
1789
348
vehicles
mean_mean_occupation_rate
2
1
11

@#$#@#$#@
## MODELE COMPLET V1 07/06/2011

mod�le potentiel d'attractivit� v5

mod�le distance V2

mod�le al�atoire v2

mod�le coop�ration v3

## MODELE COMPLET V2 15/06/2011

mod�le potentiel d'attractivit� v5

mod�le distance V2

mod�le al�atoire v2

mod�le coop�ration v4

	- am�lioration : pour les taxis, lorsque le prochain noeud � desservir est une station marqu�e, elle est supprim�e de la liste des stations marqu�es. On �vite ainsi le d�placement de plusieurs taxis vers une meme station.
	- modifications : charger-clients-cooperation ; choix-noeud-cooperation

Interface

	- changement efficacit� moyenne pour taux-chargement-moyen

## MODELE COMPLET V3 21/06/2011

am�lioration de choix-noeud-coop�ration : les taxis ne bug plus entre deux stations (rajout du test noeud suivant et noeud pr�c�dent)

correction bug :
- cr�ation de villageois au lancement de la simulation
modifications : initialisation-agent, initialisation-totale, to go : if ticks = (jours * nb-ticks-jours - 1)

## MODELE COMPLET V4 29/06/2011

Correction de bug :
- les taxis embarquaient un client et allaient � une autre station au lieu de retrouner directement au march�
modification : Changement des �tats
- les taxis peuvent bloquer entre deux stations lorsqu'ils veulent retourner � un march� (d�pend de la forme du r�seau)
modification : Rajout de l'al�atoire dans le d�placement en attendant de trouver une meilleure solution

Changement du graphique du taux de remplissage :
Taux de remplissage moyen au lieu de median

## MODELE COMPLET V5 05/07/2011

rajout : g�n�ration de r�seau de manathan


## MODELE COMPLET V7

corrections Nico pour l'article V2CS


## MODELE COMPLET V8 et v9

modifications initialisation agents pour pouvoir simuler à partir du world créé sur le modèle genere-network v1

## MODELE COMPLET V10

optimisation de l'interface de simulation

## MODELE COMPLET V11

- il n'y a plus de marché. Il y a des statiosn verte d'ou les clients partent et des stations rouge d'ou les clients partent et arrivent

- à l'initialisation les clients choisissent leur station de destination aléatoirement

----------------
to choix-villageois-stations-marches  ; Definir la destination de la station et du marche de chaque villageois en fonction du potentiel de chacun
  ask villageois
  [
     if destination-marche = 0
     [
     set destination-marche one-of stations with [ marche? = 1 ]
     set destination-noeud max-one-of stations with [distance myself < distance-marcher-max] [ potentiel-brut / (distance myself) ]
     if distance destination-noeud > distance destination-marche
        [ set destination-noeud destination-marche ]
     ]
  ]
end

## MODELE COMPLET V13

choix-villageois-stations-marches-zone
rajout de la direction de la ligne de bus des client

choix-villageois-stations-marches-zone
rajout de la direction de la ligne de bus des clients
les clients choisissent une destination dans la zone
pour les clients ayant pour destination un arret de bus ils choisissent un arret de bus pour destination noeud

## MODELE COMPLET V31

ajout du modèle taxi clandos
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

bus
false
0
Polygon -7500403 true true 15 206 15 150 15 120 30 105 270 105 285 120 285 135 285 206 270 210 30 210
Rectangle -16777216 true false 36 126 231 159
Line -7500403 false 60 135 60 165
Line -7500403 false 60 120 60 165
Line -7500403 false 90 120 90 165
Line -7500403 false 120 120 120 165
Line -7500403 false 150 120 150 165
Line -7500403 false 180 120 180 165
Line -7500403 false 210 120 210 165
Line -7500403 false 240 135 240 165
Rectangle -16777216 true false 15 174 285 182
Circle -16777216 true false 48 187 42
Rectangle -16777216 true false 240 127 276 205
Circle -16777216 true false 195 187 42
Line -7500403 false 257 120 257 207

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

truck cab top
true
0
Rectangle -7500403 true true 70 45 227 120
Polygon -7500403 true true 150 8 118 10 96 17 90 30 75 135 75 195 90 210 150 210 210 210 225 195 225 135 209 30 201 17 179 10
Polygon -16777216 true false 94 135 118 119 184 119 204 134 193 141 110 141
Line -16777216 false 130 14 168 14
Line -16777216 false 130 18 168 18
Line -16777216 false 130 11 168 11
Line -16777216 false 185 29 194 112
Line -16777216 false 115 29 106 112
Line -16777216 false 195 225 210 240
Line -16777216 false 105 225 90 240
Polygon -16777216 true false 210 195 195 195 195 150 210 143
Polygon -16777216 false false 90 143 90 195 105 195 105 150 90 143
Polygon -16777216 true false 90 195 105 195 105 150 90 143
Line -7500403 true 210 180 195 180
Line -7500403 true 90 180 105 180
Line -16777216 false 212 44 213 124
Line -16777216 false 88 44 87 124
Line -16777216 false 223 130 193 112
Rectangle -7500403 true true 225 133 244 139
Rectangle -7500403 true true 56 133 75 139
Rectangle -7500403 true true 75 210 225 240
Rectangle -7500403 true true 75 240 225 345
Rectangle -16777216 true false 200 217 224 278
Rectangle -16777216 true false 76 217 100 278
Circle -16777216 false false 135 240 30
Line -16777216 false 77 130 107 112
Rectangle -16777216 false false 107 149 192 210
Rectangle -1 true false 180 9 203 17
Rectangle -1 true false 97 9 120 17

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

van side
false
0
Polygon -7500403 true true 26 147 18 125 36 61 161 61 177 67 195 90 242 97 262 110 273 129 260 149
Circle -16777216 true false 43 123 42
Circle -16777216 true false 194 124 42
Polygon -16777216 true false 45 68 37 95 183 96 169 69
Line -7500403 true 62 65 62 103
Line -7500403 true 115 68 120 100
Polygon -1 true false 271 127 258 126 257 114 261 109
Rectangle -16777216 true false 19 131 27 142

van top
true
0
Polygon -7500403 true true 90 117 71 134 228 133 210 117
Polygon -7500403 true true 150 8 118 10 96 17 85 30 84 264 89 282 105 293 149 294 192 293 209 282 215 265 214 31 201 17 179 10
Polygon -16777216 true false 94 129 105 120 195 120 204 128 180 150 120 150
Polygon -16777216 true false 90 270 105 255 105 150 90 135
Polygon -16777216 true false 101 279 120 286 180 286 198 281 195 270 105 270
Polygon -16777216 true false 210 270 195 255 195 150 210 135
Polygon -1 true false 201 16 201 26 179 20 179 10
Polygon -1 true false 99 16 99 26 121 20 121 10
Line -16777216 false 130 14 168 14
Line -16777216 false 130 18 168 18
Line -16777216 false 130 11 168 11
Line -16777216 false 185 29 194 112
Line -16777216 false 115 29 106 112
Line -7500403 false 210 180 195 180
Line -7500403 false 195 225 210 240
Line -7500403 false 105 225 90 240
Line -7500403 false 90 180 105 180

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
<experiments>
  <experiment name="world 1 go-distance" repetitions="1" runMetricsEveryStep="true">
    <go>go-distance</go>
    <timeLimit steps="40000"/>
    <metric>Taux-de-desserte</metric>
    <metric>taux-villageois-stations</metric>
    <metric>[nb-clients-embarques] of taxi 400</metric>
    <metric>[nb-clients-embarques] of taxi 401</metric>
    <metric>[nb-clients-embarques] of taxi 402</metric>
    <metric>[taux-chargement] of taxi 400</metric>
    <metric>[taux-chargement] of taxi 401</metric>
    <metric>[taux-chargement] of taxi 402</metric>
    <metric>[gains] of taxi 400</metric>
    <metric>[gains] of taxi 401</metric>
    <metric>[gains] of taxi 402</metric>
    <metric>[traffic-brut] of links</metric>
    <enumeratedValueSet variable="distance-marcher-max">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-ticks-jours">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rayon-attraction-stations">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nbmarches">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-stations">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-taxis">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="facteur-vitesse">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contrainte-distance">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacite-max-taxis">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-villageois">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vitesse-deplacement">
      <value value="0.06"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="world 1 go-potentiel" repetitions="1" runMetricsEveryStep="true">
    <go>go-potentiel</go>
    <timeLimit steps="40000"/>
    <metric>Taux-de-desserte</metric>
    <metric>taux-villageois-stations</metric>
    <metric>[nb-clients-embarques] of taxi 400</metric>
    <metric>[nb-clients-embarques] of taxi 401</metric>
    <metric>[nb-clients-embarques] of taxi 402</metric>
    <metric>[taux-chargement] of taxi 400</metric>
    <metric>[taux-chargement] of taxi 401</metric>
    <metric>[taux-chargement] of taxi 402</metric>
    <metric>[gains] of taxi 400</metric>
    <metric>[gains] of taxi 401</metric>
    <metric>[gains] of taxi 402</metric>
    <metric>[traffic-brut] of links</metric>
    <enumeratedValueSet variable="distance-marcher-max">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-ticks-jours">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rayon-attraction-stations">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nbmarches">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-stations">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-taxis">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="facteur-vitesse">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contrainte-distance">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacite-max-taxis">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-villageois">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vitesse-deplacement">
      <value value="0.06"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="world 1 go-aleatoire" repetitions="1" runMetricsEveryStep="true">
    <go>go-aleatoire</go>
    <timeLimit steps="40000"/>
    <metric>Taux-de-desserte</metric>
    <metric>taux-villageois-stations</metric>
    <metric>[nb-clients-embarques] of taxi 400</metric>
    <metric>[nb-clients-embarques] of taxi 401</metric>
    <metric>[nb-clients-embarques] of taxi 402</metric>
    <metric>[taux-chargement] of taxi 400</metric>
    <metric>[taux-chargement] of taxi 401</metric>
    <metric>[taux-chargement] of taxi 402</metric>
    <metric>[gains] of taxi 400</metric>
    <metric>[gains] of taxi 401</metric>
    <metric>[gains] of taxi 402</metric>
    <metric>[traffic-brut] of links</metric>
    <enumeratedValueSet variable="distance-marcher-max">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-ticks-jours">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rayon-attraction-stations">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nbmarches">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-stations">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-taxis">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="facteur-vitesse">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contrainte-distance">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacite-max-taxis">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-villageois">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vitesse-deplacement">
      <value value="0.06"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="world 1 go-cooperation" repetitions="1" runMetricsEveryStep="true">
    <go>go-cooperation</go>
    <timeLimit steps="40000"/>
    <metric>Taux-de-desserte</metric>
    <metric>taux-villageois-stations</metric>
    <metric>[nb-clients-embarques] of taxi 400</metric>
    <metric>[nb-clients-embarques] of taxi 401</metric>
    <metric>[nb-clients-embarques] of taxi 402</metric>
    <metric>[taux-chargement] of taxi 400</metric>
    <metric>[taux-chargement] of taxi 401</metric>
    <metric>[taux-chargement] of taxi 402</metric>
    <metric>[gains] of taxi 400</metric>
    <metric>[gains] of taxi 401</metric>
    <metric>[gains] of taxi 402</metric>
    <metric>[traffic-brut] of links</metric>
    <enumeratedValueSet variable="distance-marcher-max">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-ticks-jours">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rayon-attraction-stations">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nbmarches">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-stations">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-taxis">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="facteur-vitesse">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contrainte-distance">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacite-max-taxis">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-villageois">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vitesse-deplacement">
      <value value="0.06"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment world1" repetitions="1" runMetricsEveryStep="true">
    <setup>importWord1</setup>
    <go>go-cooperation</go>
    <timeLimit steps="15000"/>
    <metric>taux-de-desserte</metric>
    <metric>taux-villageois-stations</metric>
    <metric>nb-clients-embarquesByTaxi 0</metric>
    <metric>nb-clients-embarquesByTaxi 1</metric>
    <metric>nb-clients-embarquesByTaxi 2</metric>
    <enumeratedValueSet variable="distance-marcher-max">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contrainte-distance">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vitesse-deplacement">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nbtik">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-vill">
      <value value="5"/>
      <value value="10"/>
      <value value="20"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="facteur-vitesse">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-stations">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rayon-attraction-stations">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacite-max-taxis">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-taxis">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nbmarches">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="worldChooser">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-v2" repetitions="1" runMetricsEveryStep="true">
    <setup>importWord1</setup>
    <go>go-cooperation</go>
    <timeLimit steps="1000"/>
    <metric>taux-de-desserte</metric>
    <metric>taux-villageois-stations</metric>
    <metric>nb-clients-embarquesByTaxi 0</metric>
    <metric>nb-clients-embarquesByTaxi 1</metric>
    <metric>nb-clients-embarquesByTaxi 2</metric>
    <enumeratedValueSet variable="distance-marcher-max">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contrainte-distance">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vitesse-deplacement">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nbtik">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-vill">
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="facteur-vitesse">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-stations">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rayon-attraction-stations">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacite-max-taxis">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-taxis">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nbmarches">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="worldChooser">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="rayon-attraction-stations">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contrainte-distance">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-villageois">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-marcher-max">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-taxis">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-ticks-jours">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nbmarches">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nbtik">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="facteur-vitesse">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-vill">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vitesse-deplacement">
      <value value="0.06"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacite-max-taxis">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="worldChooser">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-stations">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="theo quant exp" repetitions="1" runMetricsEveryStep="true">
    <setup>initialisation.agents</setup>
    <go>go</go>
    <enumeratedValueSet variable="zone?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb_vehicles">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb_ticks_patterns">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving_speed">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacity_occupation">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb_ticks_plot_pattern">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max_walking_distance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb_clients">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="speed_factor">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attraction_radius_stations">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vehicle_atractivity_facteur">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="optimization-process">
      <value value="&quot;potential&quot;"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
