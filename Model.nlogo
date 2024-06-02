globals
[
  total_infected           ;; The total number of people who got infected during the process.
  normal_users
  application_users
  total_deaths
  cured_count              ;; People cured
  application_count
  normal_die_count         ;; Death count of people not using app
  app_die_count            ;; Death count of people using app
  normal_cure_count        ;; done
  app_cure_count           ;; done
  normal_infected_count    ;; done
  app_infected_count       ;; done
]

turtles-own
[
  infected?                 ;; If true, the agent is infectious
  cured?                    ;; If true, the agent has been cured and cannot be infected again.
  strategy?                 ;; If true, the agent is using the social-distancing technology.
  isolate?                  ;; If true, the agent will self-quarantine
  isolation-tick            ;; isolation-tick ; The agent will cure after 14 days of isolation.
  number                    ;; Variable for randomizing the potential curing and unisolating.
]

;;setup the simulation.
to setup
  clear-all
  setup-people
  reset-ticks
end

;;creates 3 groups of agents: those using the strategy, those not using strategy, and those initially infected.
to setup-people
  set application_users initial_app_users * total_population / 100
  create-turtles application_users [
    set shape "person"
    set size 1
    set color blue
    setxy random-xcor random-ycor
    set cured? false
    set strategy? true
    set isolate? false
    set infected? false
    create-link-with one-of other turtles
  ]
  set normal_users total_population - application_users
  create-turtles normal_users [
    set shape "person"
    set size 1
    set color white
    setxy random-xcor random-ycor
    set cured? false
    set strategy? false
    set isolate? false
    set infected? false
  ]
  set total_population normal_users + application_users
  let initially_infected_count total_population * Initial-Infected / 100      ;; Calculate the number of turtles to be initially infected
  repeat initially_infected_count                                             ;; Assign initially infected turtles randomly among all turtles
  [
    let turtle-to-infect one-of turtles
    ask turtle-to-infect [
      set infected? true
      set color yellow
    ]
  ]
end

to go
  if any? turtles [
    ;;limit set if all agents are infected, cured, or dead.
    ask turtles [
    if all? turtles [(cured? or not infected?)] [
      stop
    ]]

    if all? turtles [(not infected? and not isolate?)] [
      stop
    ]

    ;;procedure for agents not isolated.
    ask turtles
    [if not isolate?
      [ move ]]

    ;;procedure for cured agents to move out of isolation and back into world.
    ask turtles
     [if cured?
        [move]]

    ;;procedure for infected agents using strategy.
    ask turtles
      [if infected? and strategy?
        [isolate-application]]

    ;;procedure for infected agents using strategy.
    ask turtles
      [ if infected? and not strategy?
           [ isolate-nonusers ] ]

    ask turtles
    [if cured?
      [unisolate]]

    ask turtles
     [ let infected-neighbors count other turtles with [infected?] in-radius 0.2
      if infected-neighbors > 0 [
       set infected? true
       set color yellow
       set cured? false
       ifelse strategy? [ set app_infected_count app_infected_count + 1
         ][ set normal_infected_count normal_infected_count + 1
        ]
       set total_infected total_infected + 1
      ]
    ]
  ]
  tick
end

to isolate-nonusers
    ifelse random-float 100 < 60 [
      ifelse random-float 100 < 90 [
        set isolate? true
        quarantine
        if New_App_User = true [new_users]
        set application_count count turtles with [strategy?]
      ] [
        death
      ]
    ] [
      ifelse random-float 100 < 80 [
        quarantine
        if New_App_User = true [new_users]
        set application_count count turtles with [strategy?]
      ]
      [
        death
      ]
    ]
end

;;isolate procedure.
to isolate-application
  ifelse random-float 100 < 95 [
    set isolate? true
    quarantine
  ] [
    death
  ]
end

to quarantine
    set color red
    set isolation-tick isolation-tick + 1
    move-to patch-here
    set number random 50
    if isolation-tick >= number [cure]
end

to cure
  set cured? true
  set infected? false
  set cured_count cured_count + 1
  ifelse strategy? [ set app_cure_count app_cure_count + 1
    ][ set normal_cure_count normal_cure_count + 1
    ]
  if cured? [unisolate]
end

to death
  ifelse strategy? [ set app_die_count app_die_count + 1
    ][ set normal_die_count normal_die_count + 1
    ]
   set total_deaths total_deaths + 1
  die
end

;;unisolate the agent.
to unisolate
  set isolate? false
  set color green
  ;;return the patch color to black.
  move
end

;;restricting the entering  in isolated areas.
to move
  let front-patches patches in-cone 3 60
  if front-patches = yellow [set heading heading - 180]
  rt random-float 360
  fd 1
end

to new_users
  set strategy? true
  let candidate other turtles with [not strategy?]
  let potential-links candidate with [not link-neighbor? myself]  ;; Exclude self-links
  if any? potential-links [
    create-link-with one-of potential-links
  ]
end
;;reporting percentage infected.
to-report %infected
  ifelse any? turtles
    [ report (count turtles with [infected?] / count turtles) * 100 ]
    [ report 0 ]
end
@#$#@#$#@
GRAPHICS-WINDOW
375
113
1004
743
-1
-1
18.82
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
days
30.0

SLIDER
56
201
304
234
initial_app_users
initial_app_users
5
100
20.0
5
1
%
HORIZONTAL

BUTTON
56
113
135
166
NIL
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
232
115
301
168
NIL
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

BUTTON
143
114
227
166
go forever
go
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
1146
221
1266
282
Total Infected
total_infected
2
1
15

MONITOR
1029
222
1134
283
Cured agent
cured_count
17
1
15

SLIDER
58
246
306
279
Initial-Infected
Initial-Infected
0
100
50.0
5
1
%
HORIZONTAL

SLIDER
56
291
305
324
total_population
total_population
0
400
150.0
20
1
NIL
HORIZONTAL

MONITOR
50
411
160
472
Total Deaths
total_deaths
2
1
15

PLOT
55
517
338
729
Application
Days
People
0.0
5.0
0.0
5.0
true
true
"" ""
PENS
"application_count " 1.0 0 -2674135 true "" "plot application_count"
"Deaths" 1.0 0 -14070903 true "" "plot app_die_count"
"cure" 1.0 0 -7500403 true "" "plot app_cure_count"

MONITOR
1219
124
1355
185
App user deaths
app_die_count
2
1
15

MONITOR
1287
218
1425
279
Non-user deaths
normal_die_count
2
1
15

MONITOR
191
411
331
472
Application Count
application_count
1
1
15

MONITOR
1061
124
1197
185
Total Population
total_population
2
1
15

SWITCH
120
350
248
383
New_App_User
New_App_User
0
1
-1000

PLOT
1031
516
1432
748
Cure Count
NIL
NIL
0.0
5.0
0.0
5.0
true
true
"" ""
PENS
"total_infected" 1.0 0 -7500403 true "" "plot cured_count"
"normal_cure_count " 1.0 0 -2674135 true "" "plot normal_cure_count"
"app_cure_count " 1.0 0 -10649926 true "" "plot app_cure_count"

PLOT
1028
303
1430
504
Die Counts
NIL
NIL
0.0
5.0
0.0
5.0
true
true
"" ""
PENS
"total_deaths" 1.0 0 -16777216 true "" "plot total_deaths"
"normal_die_count" 1.0 0 -5509967 true "" "plot normal_die_count"
"app_die_Count" 1.0 0 -5825686 true "" "plot app_die_Count"

TEXTBOX
269
40
1249
102
SPREAD OF VIRUS MODEL FOR COVID 19
50
95.0
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
<experiments>
  <experiment name="Strategy and deaths (App users vary)" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>count turtles with [strategy?]</metric>
    <metric>total_deaths</metric>
    <enumeratedValueSet variable="Initial-Infected">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Total_Population">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Application_Users">
      <value value="0"/>
      <value value="15"/>
      <value value="30"/>
      <value value="45"/>
      <value value="60"/>
      <value value="75"/>
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="app vs normal die count" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>count turtles</metric>
    <metric>normal_die_count</metric>
    <metric>app_die_count</metric>
    <enumeratedValueSet variable="Initial-Infected">
      <value value="0"/>
      <value value="20"/>
      <value value="40"/>
      <value value="60"/>
      <value value="80"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Total_Population">
      <value value="100"/>
      <value value="300"/>
      <value value="500"/>
      <value value="700"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Inital_Application_Users">
      <value value="0"/>
      <value value="20"/>
      <value value="40"/>
      <value value="60"/>
      <value value="80"/>
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>total_infected</metric>
    <metric>normal_users</metric>
    <metric>total_deaths</metric>
    <metric>application_count</metric>
    <metric>normal_die_count</metric>
    <metric>app_die_count</metric>
    <metric>cured_count</metric>
    <metric>normal_cure_count</metric>
    <metric>app_cure_count</metric>
    <metric>normal_infected_count</metric>
    <metric>app_infected_count</metric>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="Initial-Infected">
      <value value="20"/>
      <value value="40"/>
      <value value="60"/>
      <value value="80"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal_users">
      <value value="50"/>
      <value value="100"/>
      <value value="150"/>
      <value value="200"/>
      <value value="250"/>
      <value value="300"/>
      <value value="350"/>
      <value value="400"/>
      <value value="450"/>
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="application_users">
      <value value="10"/>
      <value value="50"/>
      <value value="100"/>
      <value value="150"/>
      <value value="200"/>
      <value value="250"/>
      <value value="300"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="initial infected changed" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>total_infected</metric>
    <metric>normal_users</metric>
    <metric>total_deaths</metric>
    <metric>application_count</metric>
    <metric>normal_die_count</metric>
    <metric>app_die_count</metric>
    <metric>cured_count</metric>
    <metric>normal_cure_count</metric>
    <metric>app_cure_count</metric>
    <metric>normal_infected_count</metric>
    <metric>app_infected_count</metric>
    <metric>total_population</metric>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="Initial-Infected">
      <value value="20"/>
      <value value="40"/>
      <value value="60"/>
      <value value="80"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal_users">
      <value value="350"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="application_users">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="app user" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>total_infected</metric>
    <metric>normal_users</metric>
    <metric>total_deaths</metric>
    <metric>application_count</metric>
    <metric>normal_die_count</metric>
    <metric>app_die_count</metric>
    <metric>cured_count</metric>
    <metric>normal_cure_count</metric>
    <metric>app_cure_count</metric>
    <metric>normal_infected_count</metric>
    <metric>app_infected_count</metric>
    <metric>total_population</metric>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="Initial-Infected">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal_users">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="application_users">
      <value value="30"/>
      <value value="60"/>
      <value value="90"/>
      <value value="120"/>
      <value value="150"/>
      <value value="180"/>
      <value value="210"/>
      <value value="240"/>
      <value value="270"/>
      <value value="300"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="app and initial infected" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>total_infected</metric>
    <metric>normal_users</metric>
    <metric>total_deaths</metric>
    <metric>application_count</metric>
    <metric>normal_die_count</metric>
    <metric>app_die_count</metric>
    <metric>cured_count</metric>
    <metric>normal_cure_count</metric>
    <metric>app_cure_count</metric>
    <metric>normal_infected_count</metric>
    <metric>app_infected_count</metric>
    <metric>total_population</metric>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="Initial-Infected">
      <value value="20"/>
      <value value="40"/>
      <value value="60"/>
      <value value="80"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="normal_users">
      <value value="450"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="application_users">
      <value value="50"/>
      <value value="100"/>
      <value value="150"/>
      <value value="200"/>
      <value value="250"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Based on initial infected" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>total_infected</metric>
    <metric>normal_users</metric>
    <metric>total_deaths</metric>
    <metric>application_count</metric>
    <metric>normal_die_count</metric>
    <metric>app_die_count</metric>
    <metric>cured_count</metric>
    <metric>normal_cure_count</metric>
    <metric>app_cure_count</metric>
    <metric>normal_infected_count</metric>
    <metric>app_infected_count</metric>
    <metric>total_population</metric>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="Initial-Infected">
      <value value="20"/>
      <value value="40"/>
      <value value="60"/>
      <value value="80"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="New_App_User">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_app_users">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total_population">
      <value value="250"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="all variation" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>total_infected</metric>
    <metric>normal_users</metric>
    <metric>total_deaths</metric>
    <metric>application_count</metric>
    <metric>normal_die_count</metric>
    <metric>app_die_count</metric>
    <metric>cured_count</metric>
    <metric>normal_cure_count</metric>
    <metric>app_cure_count</metric>
    <metric>normal_infected_count</metric>
    <metric>app_infected_count</metric>
    <enumeratedValueSet variable="Initial-Infected">
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
      <value value="90"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="New_App_User">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_app_users">
      <value value="0"/>
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
      <value value="90"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total_population">
      <value value="50"/>
      <value value="100"/>
      <value value="150"/>
      <value value="200"/>
      <value value="250"/>
      <value value="300"/>
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
