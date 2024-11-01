extensions [palette csv]
__includes [ "bimodality.nls" ]

globals
[
  unit-colours
  unit-list

  n-agents

  k-list
  k-gen-list
  k-ind-list

  next-social-learn

  k-bimodal
]

patches-own
[
  resource-type
]

turtles-own
[
  k-a
  k-b
  age
  lineage
  generation
  credibility
  encounter-rate-a


  unit
  visited-patches
]

to setup

  ca
  reset-ticks
  setup-plots

  set n-agents (n-units * n-agents-per-unit)

  set unit-list n-values n-units [ i -> i + 1]

  set unit-colours palette:scheme-colors "Qualitative" "Dark2" max list 3 n-units

  if n-units <= 2
  [
    ifelse n-units = 1
    [set unit-colours (butlast (butlast unit-colours)) ]
    [set unit-colours (butlast unit-colours) ]
  ]

  ask n-of (n-p-a * count patches) patches
  [
    set resource-type "a"
    set pcolor 97
  ]

  ask patches with [resource-type != "a"]
  [
    set resource-type "b"
    set pcolor 17
  ]

  set next-social-learn ticks + social-learn-freq

  crt n-agents [
    set size 2
    set lineage who
    set k-a random-normal 50 10
    set k-b random-normal 50 10
    set age 1
    set generation 1
    set credibility abs random-normal 50 10
    set visited-patches []
    set unit one-of unit-list
    set color item (unit - 1) unit-colours
    setxy random-pxcor random-pycor
  ]

  set k-bimodal agent-k-bimodal

  ask turtles [
    create-links-with other turtles with [unit = [unit] of myself]
  ]

  ask links [hide-link]
end


to step
  ask turtles
  [
    ;; age
    set age age + 1
    ;; move
    move-to-patch

    ;; learn
    update-knowledge
    if spatial-learn? [spatial-learn]
    if social-learn? [social-learn]

    ;; time-based erosion of knowledge
    if resource-type = "b" [set k-a k-a - (k-erosion * k-a)]
    if resource-type = "a" [set k-b k-b - (k-erosion * k-b)]

    ;; die and pass on knowledge
    intergen-dynamics
  ]

  if knowledge-loss? and ticks > start-loss  [ k-lsp-change ]
  update-k-list
  update-k-gen-list

  set k-bimodal agent-k-bimodal
  if store-individuals? [ update-k-ind-list ]

  tick
end

to update-knowledge

  ;; update knowledge from location
    if resource-type = "a"
    [
      set k-a k-a + (delta-k 0.1 k-a 100)
      set encounter-rate-a encounter-rate-a + 1
    ]

    if resource-type = "b"
    [
      set k-b k-b + (delta-k 0.1 k-b 100)
    ]
end

;; spatial learning is based on other agents within some geographic nhb
to spatial-learn

    ;; myself is the turtle asked in the go who is updating their knowledge
  let other-a 0
  let other-b 0
  let candidates-a no-turtles
  let candidates-b no-turtles
  let candidates other turtles in-radius spatial-nhb

  ifelse cognitive-proximity? [
      set candidates-a candidates with [
        ([k-a] of myself - k-a < cognitive-distance-thresh) and ([k-a] of myself - k-a > 0) ]

      set candidates-b candidates with [
        ([k-b] of myself - k-b < cognitive-distance-thresh) and ([k-b] of myself - k-b > 0) ]
  ]
  [
      set candidates-a candidates
      set candidates-b candidates
  ]


  if transfer-function = "max"
  [
    if any? candidates-a
    [
      let X max-one-of candidates-a [k-a]
      ifelse credibility-test?
      [if random-float 100 < [credibility] of X [ set other-a [k-a] of X ]]
      [set other-a [k-a] of X ]

    ]

    if any? candidates-b
    [
      let X max-one-of candidates-b [k-b]
      ifelse credibility-test?
      [if random-float 100 < [credibility] of X [ set other-b [k-b] of X ]]
      [set other-b [k-b] of X ]
    ]
  ]

  if transfer-function = "median"
  [
    if any? candidates-a [ set other-a median [k-a] of candidates-a ]
    if any? candidates-b  [ set other-b median [k-b] of candidates-b ]
  ]

  if transfer-function = "random"
    [
    if any? candidates-a
    [
      let X one-of candidates-a
      ifelse credibility-test?
        [if random-float 100 < [credibility] of X [ set other-a [k-a] of X ]]
      [set other-a [k-a] of X ]

    ]

    if any? candidates-b
    [
      let X one-of candidates-b
        ifelse credibility-test?
        [if random-float 100 < [credibility] of X [ set other-b [k-b] of X ]]
        [set other-b [k-b] of X ]
    ]

  ]

    ;; this assumes you can only learn...
    if other-a > k-a [set k-a min (list (k-a + ((other-a - k-a) * transfer-fraction)) 100)]
    if other-b > k-b [set k-b min (list (k-b + ((other-b - k-b) * transfer-fraction)) 100)]

    if k-a > 100 [set k-a 100]
    if k-b > 100 [set k-b 100]



end

to social-learn

  if ticks - next-social-learn = 0
  [
    let other-a 0
    let other-b 0
    let candidates-a no-turtles
    let candidates-b no-turtles
    ;; learn from others in social network
    if social-learn?
    [

      ;; myself is the turtle asked in the go who is updating their knowledge
      let candidates link-neighbors

      ifelse cognitive-proximity? [
        set candidates-a candidates with [
          ([k-a] of myself - k-a < cognitive-distance-thresh) and ([k-a] of myself - k-a > 0) ]

        set candidates-b candidates with [
          ([k-b] of myself - k-b < cognitive-distance-thresh) and ([k-b] of myself - k-b > 0) ]
      ]
      [
        set candidates-a candidates
        set candidates-b candidates
      ]


      if transfer-function = "max"
      [
        if any? candidates-a
        [
          let X max-one-of candidates-a [k-a]
          ifelse credibility-test?
          [if random-float 100 < [credibility] of X [ set other-a [k-a] of X ]]
          [set other-a [k-a] of X ]

        ]

        if any? candidates-b
        [
          let X max-one-of candidates-b [k-b]
          ifelse credibility-test?
          [if random-float 100 < [credibility] of X [ set other-b [k-b] of X ]]
          [set other-b [k-b] of X ]
        ]
      ]

      if transfer-function = "median"
      [

        if any? candidates-a [ set other-a median [k-a] of candidates-a]
        if any? candidates-b [ set other-b median [k-b] of candidates-b]
      ]

      if transfer-function = "random"
      [
        if any? candidates-a
        [
          let X one-of candidates-a
          ifelse credibility-test?
          [if random-float 100 < [credibility] of X [ set other-a [k-a] of X ]]
          [set other-a [k-a] of X ]

        ]

        if any? candidates-b
        [
          let X one-of candidates-b
          ifelse credibility-test?
          [if random-float 100 < [credibility] of X [ set other-b [k-b] of X ]]
          [set other-a [k-b] of X ]
        ]

      ]

      ;; this assumes you can only learn...
      if other-a > k-a [set k-a min (list (k-a + ((other-a - k-a) * transfer-fraction)) 100)]
      if other-b > k-b [set k-b min (list (k-b + ((other-b - k-b) * transfer-fraction)) 100)]
    ]

    set next-social-learn ticks + social-learn-freq
  ]

end


to intergen-dynamics
      ;; inter-gen dynamics
   if age > 10 and random-float 1 < (1 / 10)
   [
     let parent-k-a k-a
     let parent-k-b k-b
     let parent-unit unit
     let parent-gen generation
    let parent-lineage lineage

      hatch 1 [
        set age 0
        set k-a parent-k-a * (parent-transfer + random-float (1 - parent-transfer));; random-normal k-a (parent-a * 0.1)
        set k-b parent-k-b * (parent-transfer + random-float (1 - parent-transfer));;random-normal k-b (parent-b * 0.1)
        set generation parent-gen + 1
        set lineage parent-lineage
        set credibility max (list 0 (credibility + random-normal 0 5))
        set encounter-rate-a 0
        set visited-patches []
        create-links-with other turtles with [unit = [unit] of myself]
        set color item (unit - 1) unit-colours
        ask links [hide-link]
      if random-float 1 < defect-unit [set unit one-of ( filter [ s -> s != parent-unit ] unit-list ) ]
     ]

      die

    ]
end

to k-lsp-change

  if any? patches with [resource-type = "a"] and ticks > start-loss and ticks < end-loss
  [
    let npa count patches with [resource-type = "a"]
    let N (random-poisson rate-loss)

    if N > npa [ set N Npa]

    ask n-of N patches with [resource-type = "a"]
    [
      set resource-type "b"
      set pcolor 17
    ]
  ]

  if (ticks > start-return and ticks < end-return) and (count patches with [resource-type = "a"] < (n-p-a * count patches))
  [
    let N (random-poisson rate-return)

    ask n-of N patches with [resource-type = "b"]
    [
      set resource-type "a"
      set pcolor 97
    ]
  ]

end

to move-to-patch

   ;; memory to avoid back-tracking
   set visited-patches lput patch-here visited-patches

   if length visited-patches > memory-length [
     set visited-patches but-first visited-patches
   ]
   let X visited-patches ;; hack!

   let candidate-nhb neighbors with [member? self X = false]

  ;; random move
  if not know-move?
  [
    move-to one-of candidate-nhb
  ]

   ;; move preferentially to resource type with most knowledge
  if know-move?
  [
   ifelse (k-a * res-a-preference) > k-b
   [
    ifelse any? candidate-nhb with [resource-type = "a"] and random-float 100 <= k-a
      [ move-to one-of candidate-nhb with [resource-type = "a"] ]
     [ move-to one-of candidate-nhb ]
   ]

   [
     ifelse any? candidate-nhb with [resource-type = "b"] and random-float 100 <= k-b
       [ move-to one-of candidate-nhb with [resource-type = "b"] ]
    [ move-to one-of candidate-nhb ]
  ]
  ]
end

to update-k-list

  if ticks = 0 [
    set k-list []
    let h1 (map [i -> (word "n.unit" i)] unit-list)
    let h2 (map [i -> (word "ka.unit" i)] unit-list)
    let h3 (map [i -> (word "kb.unit" i)] unit-list)
    let h4 (map [i -> (word "ka.var.unit" i)] unit-list)
    let h5 (map [i -> (word "ka.range.unit" i)] unit-list)
    let h6 (map [i -> (word "ka.lt50.unit" i)] unit-list)
    let h7 (map [i -> (word "ka.lt5.unit" i)] unit-list)

    set k-list lput (sentence "rep" "ticks" "fraction.a" h1 h2 h3 h4 h5 h6 h7 "bimodal.a" "bimodal.b") k-list
  ]

  let fraction-a (count patches with [resource-type = "a"]) / (count patches)

  let n-unit (map [i -> count turtles with [unit = i]] unit-list)
  let ka-unit (map [i -> mean [k-a] of turtles with [unit = i]] unit-list)
  let kb-unit (map [i -> mean [k-b] of turtles with [unit = i]] unit-list)
  let ka-var (map [i -> variance [k-a] of turtles with [unit = i]] unit-list)
  let ka-range (map [i -> ((max [k-a] of turtles with [unit = i]) - (min [k-a] of turtles with [unit = i]))] unit-list)


  let ka-lt50  (map [i -> count turtles with [unit = i and k-a < 50]] unit-list)
  let ka-lt5  (map [i -> count turtles with [unit = i and k-a < 5]] unit-list)

  set k-list lput (sentence behaviorspace-run-number ticks fraction-a n-unit ka-unit kb-unit ka-var ka-range ka-lt50 ka-lt5 (item 0 k-bimodal) (item 1 k-bimodal)) k-list
end


to update-k-gen-list

  if ticks = 0 [
    set k-gen-list []
    set k-gen-list lput (sentence "rep" "tick" "fraction.a" "gen" "unit" "n" "ka" "kb" "ka.var" "ka.range" "ka.lt50" "ka.lt5" "bimodal.a" "bimodal.b") k-gen-list
  ]

  let gen-list sort remove-duplicates [generation] of turtles
  let ka-var-unit 0 ;; define here so can catch n = 1 cases

  ;; for each unit in each generation get n, k-a, and k-b
  ;; need nested as lists may not be the same length

  let fraction-a (count patches with [resource-type = "a"]) / (count patches)

  (foreach unit-list [ u ->
    foreach gen-list [ g ->
      if any? turtles with [unit = u and generation = g]
      [
        let n-unit count turtles with [unit = u and generation = g]
        let ka-unit mean [k-a] of turtles with [unit = u and generation = g]
        let kb-unit mean [k-b] of turtles with [unit = u and generation = g]
        if n-unit > 1 [ set ka-var-unit variance [k-a] of turtles with [unit = u and generation = g] ]
        let ka-range-unit (max [k-a] of turtles with [unit = u and generation = g]) - (min [k-a] of turtles with [unit = u and generation = g])

        let ka-lt50-unit count turtles with [unit = u and generation = g and k-a < 50]
        let ka-lt5-unit count turtles with [unit = u and generation = g and k-a < 5]

        set k-gen-list lput (sentence behaviorspace-run-number ticks fraction-a g u n-unit ka-unit kb-unit ka-var-unit ka-range-unit ka-lt50-unit ka-lt5-unit (item 0 k-bimodal) (item 1 k-bimodal))  k-gen-list
      ]
    ]
  ])

end

to update-k-ind-list

  if ticks = 0 [
    set k-ind-list []

    set k-ind-list lput (sentence "rep" "tick" "fraction.a" "gen" "age" "unit" "lineage" "who" "ka" "kb") k-ind-list
  ]

  let fraction-a (count patches with [resource-type = "a"]) / (count patches)
  ask turtles
  [
    set k-ind-list lput (sentence behaviorspace-run-number ticks fraction-a generation age unit lineage who k-a k-b) k-ind-list
  ]

end

to write-csv
  csv:to-file (word csv-file-name "_time_" behaviorspace-run-number ".csv") k-list
  csv:to-file (word csv-file-name "_gen_" behaviorspace-run-number ".csv")  k-gen-list

  if store-individuals? [ csv:to-file (word csv-file-name "_inds_" behaviorspace-run-number ".csv")  k-ind-list ]
end

to-report delta-k [r N K]
  report r * N * (1 - N / K)
end


to-report k-range [a-set]
  report max [k-a] of a-set - min [k-a] of a-set
end


to-report agent-k-bimodal

  let ba bimodality-coeff ([k-a] of turtles) TRUE
  let bb bimodality-coeff ([k-b] of turtles) TRUE

  report (list ba bb)

end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
618
419
-1
-1
8.0
1
10
1
1
1
0
1
1
1
0
49
0
49
1
1
1
ticks
30.0

SLIDER
23
198
195
231
n-p-a
n-p-a
0
1
0.5
.01
1
NIL
HORIZONTAL

BUTTON
9
32
72
65
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
75
32
138
65
NIL
step
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
700
21
900
171
Mean knowledge
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
"ka" 1.0 0 -13345367 true "" "if ticks > 0 [ plot mean [k-a] of turtles ]"
"kb" 1.0 0 -2674135 true "" "if ticks > 0 [ plot mean [k-b] of turtles ]"

PLOT
906
326
1106
476
Knowledge landscape
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
"default" 1.0 0 -16777216 true "" "plot count patches with [resource-type = \"a\"] / count patches"

PLOT
903
20
1103
170
Knowledge 'a' distribution
NIL
NIL
0.0
100.0
0.0
10.0
false
false
" set-histogram-num-bars 20\n set-plot-y-range 0 (n-units * n-agents-per-unit)\n" ""
PENS
"default" 0.05 1 -16777216 true "" "histogram [k-a] of turtles"

SLIDER
16
534
188
567
k-erosion
k-erosion
0
.2
0.015
.005
1
NIL
HORIZONTAL

SLIDER
213
428
385
461
start-loss
start-loss
0
500
110.0
10
1
NIL
HORIZONTAL

PLOT
700
173
900
323
Encounter rate (a)
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
"mean-a" 1.0 0 -16777216 true "" "if ticks > 0 [plot mean [encounter-rate-a] of turtles]"
"pen-1" 1.0 0 -7500403 true "" "if ticks > 0 [plot min [encounter-rate-a] of turtles]"
"pen-2" 1.0 0 -7500403 true "" "if ticks > 0 [plot max [encounter-rate-a] of turtles]"

PLOT
904
173
1104
323
Knowledge 'a' vs generation
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
"default" 1.0 2 -16777216 true "" "ask turtles [plotxy generation k-a]"

SLIDER
22
344
194
377
memory-length
memory-length
0
20
5.0
1
1
NIL
HORIZONTAL

SWITCH
40
381
169
414
spatial-learn?
spatial-learn?
0
1
-1000

SWITCH
39
418
170
451
social-learn?
social-learn?
0
1
-1000

SLIDER
22
274
194
307
n-units
n-units
1
5
3.0
1
1
NIL
HORIZONTAL

SLIDER
23
236
195
269
n-agents-per-unit
n-agents-per-unit
10
200
40.0
10
1
NIL
HORIZONTAL

SWITCH
39
453
170
486
know-move?
know-move?
1
1
-1000

SLIDER
213
465
385
498
end-loss
end-loss
0
1000
350.0
10
1
NIL
HORIZONTAL

SLIDER
213
499
385
532
rate-loss
rate-loss
0
10
9.0
1
1
NIL
HORIZONTAL

SLIDER
387
499
559
532
rate-return
rate-return
0
10
5.0
1
1
NIL
HORIZONTAL

SWITCH
562
458
708
491
knowledge-loss?
knowledge-loss?
0
1
-1000

SLIDER
386
428
558
461
start-return
start-return
0
1000
650.0
10
1
NIL
HORIZONTAL

SLIDER
387
465
559
498
end-return
end-return
0
2500
850.0
50
1
NIL
HORIZONTAL

MONITOR
754
423
860
468
Mean generation
mean [generation] of turtles
0
1
11

MONITOR
753
327
860
372
Mean k-a
mean [k-a] of turtles
3
1
11

SLIDER
16
570
188
603
transfer-fraction
transfer-fraction
0
.5
0.5
.05
1
NIL
HORIZONTAL

SLIDER
16
605
188
638
parent-transfer
parent-transfer
0
1
0.85
.025
1
NIL
HORIZONTAL

CHOOSER
212
550
350
595
transfer-function
transfer-function
"max" "median" "random"
0

SLIDER
22
309
194
342
defect-unit
defect-unit
0
1
0.0
.01
1
NIL
HORIZONTAL

SWITCH
572
544
723
577
store-individuals?
store-individuals?
1
1
-1000

INPUTBOX
509
581
752
641
csv-file-name
hysteresis
1
0
String

BUTTON
140
32
203
65
go
step
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
25
107
197
140
max-generations
max-generations
0
100
64.0
1
1
NIL
HORIZONTAL

BUTTON
29
72
194
105
run gens
while [min [generation] of turtles < max-generations] [ step ]
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
753
376
860
421
Mean k-b
mean [k-b] of turtles
3
1
11

PLOT
1158
24
1358
174
Mean knowledge (unit 1)
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
"ka" 1.0 0 -14070903 true "" "if ticks > 0 [ plot mean [k-a] of turtles with [unit = 1 ] ]"
"kb" 1.0 0 -2674135 true "" "if ticks > 0 [ plot mean [k-b] of turtles with [unit = 1] ]"

PLOT
1158
180
1358
330
Mean knowledge (unit 2)
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
"default" 1.0 0 -13345367 true "" "if ticks > 0 [ plot mean [k-a] of turtles with [unit = 2] ]"
"pen-1" 1.0 0 -2674135 true "" "if ticks > 0 [ plot mean [k-b] of turtles with [unit = 2] ]"

PLOT
1158
336
1358
486
Mean knowledge (unit 3)
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
"default" 1.0 0 -13345367 true "" "if ticks > 0 [ plot mean [k-a] of turtles with [unit = 3] ]"
"pen-1" 1.0 0 -2674135 true "" "if ticks > 0 [ plot mean [k-b] of turtles with [unit = 3] ]"

SLIDER
212
604
384
637
res-a-preference
res-a-preference
.5
1.5
1.0
.01
1
NIL
HORIZONTAL

PLOT
1383
25
1583
175
Knowledge thresholds (unit 1)
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
"default" 1.0 0 -955883 true "" "if ticks > 0 [ plot count turtles with [unit = 1 and k-a < 50 ] ]"
"pen-1" 1.0 0 -5825686 true "" "if ticks > 0 [ plot count turtles with [unit = 1 and k-a < 5 ] ]"

PLOT
1384
180
1584
330
Knowledge thresholds (unit 2)
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
"default" 1.0 0 -955883 true "" "if ticks > 0 [ plot count turtles with [unit = 2 and k-a < 50 ] ]"
"pen-1" 1.0 0 -5825686 true "" "if ticks > 0 [ plot count turtles with [unit = 2 and k-a < 5 ] ]"

PLOT
1383
334
1583
484
Knowledge thresholds (unit 3)
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
"default" 1.0 0 -2674135 true "" "if ticks > 0 [ plot count turtles with [unit = 3 and k-a < 50 ] ]"
"pen-1" 1.0 0 -5825686 true "" "if ticks > 0 [ plot count turtles with [unit = 3 and k-a < 5 ] ]"

TEXTBOX
626
19
776
51
k-a = blue\nk-b = red
13
0.0
1

SLIDER
17
646
189
679
spatial-nhb
spatial-nhb
0
5
1.0
.5
1
NIL
HORIZONTAL

SWITCH
40
489
188
522
cognitive-proximity?
cognitive-proximity?
1
1
-1000

SLIDER
213
646
384
679
cognitive-distance-thresh
cognitive-distance-thresh
0
100
30.0
5
1
NIL
HORIZONTAL

SWITCH
31
692
171
725
credibility-test?
credibility-test?
1
1
-1000

TEXTBOX
1396
491
1593
521
Orange - number agents with lt 50 k-a\nRed - number agents with lt 5 k-a\n
11
0.0
1

SLIDER
213
683
385
716
social-learn-freq
social-learn-freq
1
10
1.0
1
1
NIL
HORIZONTAL

MONITOR
671
329
736
374
Bimodal a
item 0 k-bimodal
3
1
11

MONITOR
672
381
737
426
Bimodal b
item 1 k-bimodal
3
1
11

TEXTBOX
655
432
761
458
B > 5/9 - bimodality
10
0.0
1

@#$#@#$#@
## WHAT IS IT?

This model is concerned with the conditions under which biocultural hysteresis (Lyver et al. 2019) might form.

## HOW IT WORKS

**Landscape**   
The landscape is comprised of a grid with two types of patches (a and b) representing sources of different knowledge - this could be places where a species or geographic feature are present. They are not inherently positive or negative, just different.  The initial amount of type a is controlled by the `n-p-a` slider.  Using the `*-loss` and `*-return` sliders it is possible to devise scenarios where type a transitions to type b, representing loss of access to "knowledge" (short hand for erosion of a knowledge-belief-practice complex) of a (e.g., local species loss, restriction of access).

**Agents**    
Agents (the triangles) belong to units (i.e., a social network) denoted by the triangle's colour; the user can specify the number of units (so if there is one all agents are members of the same unit).  Agents are distribued evenly across units.  Agents move through the landscape and as they do so their knowledge of how to 'use' each of the two resource types changes,s represented as a value 0-100.  

The knowledge updating happens in three ways:       
1. *Encounter* - at each time step each agent updates its knowledge of the resource in the current  patch following a logistic curve. There is a small loss of knowledge of the other resource type, controlled by `k-erosion`.    
2. *Spatial learning* - if `spatial-learning?` is on then if there are other agents in the patch then each agent will gain share-fraction of the difference between it and the most knowledgable agent for both resource types.    
3.*Network learning* - if `network-learning?` is on then each agent will gain `share-fraction` of the difference between it and another agent in its social network (unit) for both resource types; this occurs irrespective of location.  Agents can learn from the most knowledgable agent in the network, a random agent in the network, or via the median knowledge across the network. This is set by the `transfer-function` option.    

At each time-step, agents move to a neighbouring patch that is not in their memory (the most recently visited `memory-length` patches).  This movement can be at random, or if 'know-move?' is on then they will preferentially move to one of the neighbors with the type they are most knowledgable about (the `know-move?` switch) potentially weighted in favour of one of the twp resources (via the `res-a-preference` parameter).

Agents live around ten ticks before dying.  On death their offspring inherit their knowledge (based on a Guassian distribution) and also their location, social network (with *p = 1 - `defect`*), otherwise they join another social network at random), etc., but not their patch visit memory. 


## HOW TO USE IT

Hopefully self-explanatory!


## THINGS TO NOTICE

Depending on how learning and knowledge transfer operate there are various outcomes, framed here as knowledge of the use of resource 'a':
1. Under null conditions of random movement and no social/spatial learning, the knowledge of resources stabilises at a level determined by their relative abundance in the landscape.  
2. In the absence of change in access to resource 'a', social and spatial learning lead to stable conditions but knowledge is slight higher
3. Preferential movement to the resource type an agent is most knowledgable about leads to bifurcating conditions where some agents have high knowledge of 'a' and others have limited knowledge (there is a postive feedback-drive lock-in effect).  This can be stailised by social but not spatial learning.  

If there are periods where access to resource 'a' is lost then the system may quickly bounce back if it is restored, it may return but at a lower level, or it may fail to return altogether.  Which of these dynamics occurs is a function of whether or not there is preferential movement, how social learning operates (who do agents learn from), and how much knowledge is transferred between generations. 

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

Things to do (notes to GP):
- spatial structure in resource and movement of agents
- agent heterogeneity: who holds knowledge, propensity to learn, credibility of other agents., etc.
- multiple resource types
- ...  


### References
Lyver PO, Timoti P, Davis T, Tylianakis JM 2019. Biocultural hysteresis inhibits adaptation to environmental change. _Trends in Ecology & Evolution_ __34__: 771–780.


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
  <experiment name="baseline-defect" repetitions="20" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>step</go>
    <postRun>write-csv</postRun>
    <exitCondition>not any? turtles with [generation &lt; max-generations]</exitCondition>
    <enumeratedValueSet variable="n-units">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-return">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-loss">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="k-erosion">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-return">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-function">
      <value value="&quot;max&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-return">
      <value value="1600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-agents">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-loss">
      <value value="350"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parent-transfer">
      <value value="0.85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-fraction">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-loss">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory-length">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="knowledge-loss?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="know-move?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="defect-unit" first="0" step="0.025" last="0.25"/>
    <enumeratedValueSet variable="n-p-a">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="csv-file-name">
      <value value="&quot;../../ms/data/sa-defect/sa_defect&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="calibrate" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>step</go>
    <postRun>write-csv</postRun>
    <exitCondition>not any? turtles with [generation &lt; max-generations]</exitCondition>
    <enumeratedValueSet variable="n-units">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-return">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-loss">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="k-erosion">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-return">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-function">
      <value value="&quot;max&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-return">
      <value value="1600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-agents-per-unit">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-loss">
      <value value="350"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parent-transfer">
      <value value="0.85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-fraction">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-loss">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory-length">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="knowledge-loss?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="know-move?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defect-unit">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="n-p-a" first="0.05" step="0.025" last="0.75"/>
    <enumeratedValueSet variable="csv-file-name">
      <value value="&quot;../../ms/data/calibrate/hysteresis_calibrate&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="one-run-all-agents" repetitions="1" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>step</go>
    <postRun>write-csv</postRun>
    <exitCondition>not any? turtles with [generation &lt; max-generations]</exitCondition>
    <enumeratedValueSet variable="n-units">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-return">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-loss">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="k-erosion">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-return">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-function">
      <value value="&quot;max&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-return">
      <value value="1600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-agents">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-loss">
      <value value="350"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parent-transfer">
      <value value="0.85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-fraction">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-loss">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory-length">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-learn?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="knowledge-loss?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-learn?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="know-move?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defect-unit">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-p-a">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="store-individuals?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="csv-file-name">
      <value value="&quot;../../ms/data/one-run/hysteresis_one&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="baseline-agents-units" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>step</go>
    <postRun>write-csv</postRun>
    <exitCondition>not any? turtles with [generation &lt; max-generations]</exitCondition>
    <enumeratedValueSet variable="n-units">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-return">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-loss">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="k-erosion">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-return">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-function">
      <value value="&quot;max&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-return">
      <value value="1600"/>
    </enumeratedValueSet>
    <steppedValueSet variable="n-agents-per-unit" first="10" step="10" last="50"/>
    <enumeratedValueSet variable="end-loss">
      <value value="350"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parent-transfer">
      <value value="0.85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-fraction">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-loss">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory-length">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="knowledge-loss?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="know-move?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defect-unit">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-p-a">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cognitive-proximity?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="csv-file-name">
      <value value="&quot;../../ms/data/baseline-nunits/baseline_nunits&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="null-one" repetitions="1" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>step</go>
    <postRun>write-csv</postRun>
    <exitCondition>not any? turtles with [generation &lt; max-generations]</exitCondition>
    <enumeratedValueSet variable="n-units">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-return">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-loss">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="k-erosion">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-return">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-function">
      <value value="&quot;max&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-return">
      <value value="1600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-agents">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-loss">
      <value value="350"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parent-transfer">
      <value value="0.85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-fraction">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-loss">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory-length">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-learn?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="knowledge-loss?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-learn?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="know-move?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defect-unit">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-p-a">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="csv-file-name">
      <value value="&quot;../output/data/hysteresis_baseline&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="amount-of-loss-return" repetitions="20" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>step</go>
    <postRun>write-csv</postRun>
    <exitCondition>not any? turtles with [generation &lt; max-generations]</exitCondition>
    <enumeratedValueSet variable="n-units">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="k-erosion">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-return">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-function">
      <value value="&quot;max&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-return">
      <value value="850"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-agents-per-unit">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-loss">
      <value value="350"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parent-transfer">
      <value value="0.85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-fraction">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-loss">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory-length">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="knowledge-loss?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="know-move?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defect-unit">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-p-a">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="csv-file-name">
      <value value="&quot;../../ms/data/amt-loss-return/hysteresis_amt&quot;"/>
    </enumeratedValueSet>
    <subExperiment>
      <enumeratedValueSet variable="rate-return">
        <value value="0"/>
        <value value="1"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="rate-loss">
        <value value="1"/>
      </enumeratedValueSet>
    </subExperiment>
    <subExperiment>
      <enumeratedValueSet variable="rate-return">
        <value value="0"/>
        <value value="2"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="rate-loss">
        <value value="2"/>
      </enumeratedValueSet>
    </subExperiment>
    <subExperiment>
      <enumeratedValueSet variable="rate-return">
        <value value="0"/>
        <value value="3"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="rate-loss">
        <value value="3"/>
      </enumeratedValueSet>
    </subExperiment>
    <subExperiment>
      <enumeratedValueSet variable="rate-return">
        <value value="0"/>
        <value value="4"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="rate-loss">
        <value value="4"/>
      </enumeratedValueSet>
    </subExperiment>
    <subExperiment>
      <enumeratedValueSet variable="rate-return">
        <value value="0"/>
        <value value="5"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="rate-loss">
        <value value="5"/>
      </enumeratedValueSet>
    </subExperiment>
  </experiment>
  <experiment name="rate-of-loss-return" repetitions="20" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>step</go>
    <postRun>write-csv</postRun>
    <exitCondition>not any? turtles with [generation &lt; max-generations]</exitCondition>
    <enumeratedValueSet variable="n-units">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-return">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="k-erosion">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-function">
      <value value="&quot;max&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-agents-per-unit">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-loss">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parent-transfer">
      <value value="0.85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-fraction">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory-length">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="knowledge-loss?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="know-move?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defect-unit">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-p-a">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="csv-file-name">
      <value value="&quot;../../ms/data/rate-loss-return/hysteresis_loss&quot;"/>
    </enumeratedValueSet>
    <subExperiment>
      <enumeratedValueSet variable="end-loss">
        <value value="150"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="rate-loss">
        <value value="5"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="start-return">
        <value value="600"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="end-return">
        <value value="650"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="rate-return">
        <value value="0"/>
        <value value="5"/>
      </enumeratedValueSet>
    </subExperiment>
    <subExperiment>
      <enumeratedValueSet variable="end-loss">
        <value value="200"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="rate-loss">
        <value value="4"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="start-return">
        <value value="650"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="end-return">
        <value value="750"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="rate-return">
        <value value="0"/>
        <value value="4"/>
      </enumeratedValueSet>
    </subExperiment>
    <subExperiment>
      <enumeratedValueSet variable="end-loss">
        <value value="300"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="rate-loss">
        <value value="2"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="start-return">
        <value value="750"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="end-return">
        <value value="950"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="rate-return">
        <value value="0"/>
        <value value="2"/>
      </enumeratedValueSet>
    </subExperiment>
    <subExperiment>
      <enumeratedValueSet variable="end-loss">
        <value value="350"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="rate-loss">
        <value value="1"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="start-return">
        <value value="800"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="end-return">
        <value value="1050"/>
      </enumeratedValueSet>
      <enumeratedValueSet variable="rate-return">
        <value value="0"/>
        <value value="1"/>
      </enumeratedValueSet>
    </subExperiment>
  </experiment>
  <experiment name="spatial-nhb-size" repetitions="20" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>step</go>
    <postRun>write-csv</postRun>
    <exitCondition>not any? turtles with [generation &lt; max-generations]</exitCondition>
    <enumeratedValueSet variable="n-units">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-return">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-loss">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="k-erosion">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-return">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-function">
      <value value="&quot;max&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-return">
      <value value="1600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-agents">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-loss">
      <value value="350"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parent-transfer">
      <value value="0.85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-fraction">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-loss">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory-length">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-nhb">
      <value value="1"/>
      <value value="1.5"/>
      <value value="2"/>
      <value value="2.85"/>
      <value value="3"/>
      <value value="4.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-learn?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="knowledge-loss?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="know-move?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defect-unit">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-p-a">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="csv-file-name">
      <value value="&quot;../../ms/data/sa-spatial-nhb/spatial_nhb_&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sa-parenttransfer" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>step</go>
    <postRun>write-csv</postRun>
    <exitCondition>not any? turtles with [generation &lt; max-generations]</exitCondition>
    <enumeratedValueSet variable="n-units">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-return">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-loss">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="k-erosion">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-return">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-function">
      <value value="&quot;max&quot;"/>
      <value value="&quot;median&quot;"/>
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-return">
      <value value="1600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-agents">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-loss">
      <value value="350"/>
    </enumeratedValueSet>
    <steppedValueSet variable="parent-transfer" first="0.5" step="0.1" last="1"/>
    <enumeratedValueSet variable="transfer-fraction">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-loss">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory-length">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="knowledge-loss?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="know-move?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defect-unit">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-p-a">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cognitive-proximity?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-nhb">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="csv-file-name">
      <value value="&quot;../../ms/data/sa-parenttransfer/parent_transfer&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sa-asymm" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>step</go>
    <postRun>write-csv</postRun>
    <exitCondition>not any? turtles with [generation &lt; max-generations]</exitCondition>
    <enumeratedValueSet variable="n-units">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-return">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-loss">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="k-erosion">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-return">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-function">
      <value value="&quot;max&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-return">
      <value value="1600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-agents">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-loss">
      <value value="350"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parent-transfer">
      <value value="0.85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-fraction">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-loss">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory-length">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="knowledge-loss?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="know-move?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defect-unit">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-p-a">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cognitive-proximity?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-nhb">
      <value value="1.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="res-a-preference" first="0.75" step="0.05" last="1.25"/>
    <enumeratedValueSet variable="csv-file-name">
      <value value="&quot;../../ms/data/sa-asymm/sa_asymm&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sa-cogproximity" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>step</go>
    <postRun>write-csv</postRun>
    <exitCondition>not any? turtles with [generation &lt; max-generations]</exitCondition>
    <enumeratedValueSet variable="n-units">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-return">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-loss">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="k-erosion">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-return">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-function">
      <value value="&quot;max&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-return">
      <value value="1600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-agents">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-loss">
      <value value="350"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parent-transfer">
      <value value="0.85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-fraction">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-loss">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory-length">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="knowledge-loss?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="know-move?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defect-unit">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-p-a">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cognitive-proximity?">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="cognitive-distance-thresh" first="10" step="10" last="90"/>
    <enumeratedValueSet variable="spatial-nhb">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="csv-file-name">
      <value value="&quot;../../ms/data/sa-cogproximity/sa_proximity&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sa-spatialtransfer" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>step</go>
    <postRun>write-csv</postRun>
    <exitCondition>not any? turtles with [generation &lt; max-generations]</exitCondition>
    <enumeratedValueSet variable="n-units">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-return">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-loss">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="k-erosion">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-return">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-function">
      <value value="&quot;max&quot;"/>
      <value value="&quot;median&quot;"/>
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-return">
      <value value="1600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-agents">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-loss">
      <value value="350"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parent-transfer">
      <value value="0.85"/>
    </enumeratedValueSet>
    <steppedValueSet variable="transfer-fraction" first="0.2" step="0.1" last="0.8"/>
    <enumeratedValueSet variable="start-loss">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory-length">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="knowledge-loss?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="know-move?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defect-unit">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-p-a">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cognitive-proximity?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-nhb">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="csv-file-name">
      <value value="&quot;../../ms/data/sa-spatialtransfer/spatial_transfer&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="baseline-control" repetitions="50" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>step</go>
    <postRun>write-csv</postRun>
    <exitCondition>not any? turtles with [generation &lt; max-generations]</exitCondition>
    <enumeratedValueSet variable="n-units">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-return">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rate-loss">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="k-erosion">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-return">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-function">
      <value value="&quot;max&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-return">
      <value value="1600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-agents-per-unit">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-loss">
      <value value="350"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="parent-transfer">
      <value value="0.85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-fraction">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-loss">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory-length">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="knowledge-loss?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-learn?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="know-move?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="defect-unit">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-p-a">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cognitive-proximity?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="csv-file-name">
      <value value="&quot;../../ms/data/control/control&quot;"/>
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
