# Floortile problem
# 1 robot, 1D

### PARAMETERS ###

param nr_children;
param child_pos{i in 1..nr_children};
param health_status{i in 1..nr_children};

param init_b;
param init_b_non_gluten;

param init_content;
param init_content_non_gluten;

param nr_trays;

param T;

 ### VARIABLES ###

var tstar integer >=1; # time needed for serving all children

var pos_tray{i in 1..nr_trays, t in 1..T} integer;

var on_tray{i in 1..nr_trays, t in 1..T} integer;
var on_tray_non_gluten{i in 1..nr_trays, t in 1..T} integer;

var bread{t in 1..T} integer >= 0; # stock of bread
var bread_non_gluten{t in 1..T} integer >= 0; # stock of non gluten bread

var content_non_gluten{t in 1..T} integer >= 0;
var content{t in 1..T} integer >= 0;

var sandwich_in_kitchen{t in 1..T} integer >= 0;
var sandwich_in_kitchen_non_gluten{t in 1..T} integer >= 0;

var satisfaction_children{c in 1..nr_children, t in 1..T} binary;




# Actions of the robot, 1 = doing this action
var make_sandwich{t in 1..T-1} binary;
var make_sandwich_non_gluten{t in 1..T-1} binary;
var put_on_tray{t in 1..T-1} binary;
var put_on_tray_non_gluten{t in 1..T-1} binary;
var move_tray{t in 1..T-1} binary;
var serve{t in 1..T-1} binary;
var serve_non_gluten{t in 1..T-1} binary;


### OBJECTIVE ###

minimize objective: tstar;

### CONSTRAINTS ###

# FIXA
#subject to BoardComplete:
#exists{t in 1..T} (sum{i in 1..n} cell[i,t] = n and t = tstar);

subject to OneAction {t in 1..T-1}:
make_sandwich[t] + make_sandwich_non_gluten[t] + put_on_tray[t]
+ put_on_tray_non_gluten[t] + move_tray[t] + serve[t]
+ serve_non_gluten[t] <= 1;


# Initial conditions
subject to InitialTrayPos {i in 1..nr_trays}:
pos_tray[i, 1] = 1; # All trays in kitchen

subject to InitialOnTrays {i in 1..nr_trays}:
on_tray[i, 1] = 0; # Nothing on trays
subject to InitialOnNonGlutenTrays {i in 1..nr_trays}:
on_non_gluten_tray[i, 1] = 0; # Nothing on trays

subject to InitialBread :
bread[1] = init_b;
subject to InitialBreadNonGluten :
bread_non_gluten[1] = init_b_non_gluten;

subject to InitialContent :
content[1] = init_content;
subject to InitialContentNonGluten :
content_non_gluten[1] = init_content_non_gluten;

subject to InitialSandwichInKitchen :
sandwich_in_kitchen[1] = 0;
subject to InitialSandwichInKitchenNonGluten :
sandwich_in_kitchen_non_gluten[1] = 0;

subject to InitialSatisfactionChildren {i in 1..nr_children}:
satisfaction_children[i, 1] = 0;


# Make sandwiches
subject to MakingSandwichExcessiveBread {t in 1..T-1}:
make_sandwich[t] = 1 and bread[t] - bread_non_gluten[t] > 0 ==> 
bread[t+1] = bread[t] - 1 and bread_non_gluten[t+1] = bread_non_gluten[t];

subject to MakingSandwichOnlyGlutenBread {t in 1..T-1}:
make_sandwich[t] = 1 and bread[t] - bread_non_gluten[t] = 0 ==> 
bread[t+1] = bread[t] - 1 and bread_non_gluten[t+1] = bread_non_gluten[t] - 1;

subject to MakingSandwichExcessiveContent {t in 1..T-1}:
make_sandwich[t] = 1 and content[t] - content_non_gluten[t] > 0 ==> 
content[t+1] = content[t] - 1 and content_non_gluten[t+1] = content_non_gluten[t];

subject to MakingSandwichOnlyGlutenContent {t in 1..T-1}:
make_sandwich[t] = 1 and content[t] - content_non_gluten[t] = 0 ==> 
content[t+1] = content[t] - 1 and content_non_gluten[t+1] = content_non_gluten[t] - 1;

subject to MakingSandwichNonGluten {t in 1..T-1}:
make_sandwich[t] = 1 and 
bread[t] - bread_non_gluten[t] = 0 and content[t] - content_non_gluten[t] = 0 ==> 
sandwich[t+1] = sandwich[t] + 1 and sandwich_non_gluten[t+1] = sandwich_non_gluten[t] + 1;

subject to MakingSandwichNonGluten {t in 1..T-1}:
make_sandwich[t] = 1 and 
bread[t] - bread_non_gluten[t] > 0 or content[t] - content_non_gluten[t] > 0 ==> 
sandwich[t+1] = sandwich[t] + 1 and sandwich_non_gluten[t+1] = sandwich_non_gluten[t];

subject to NotMakingSandwich {t in 1..T-1}:
make_sandwich[t] = 0 ==> 
bread[t+1] = bread[t] and bread_non_gluten[t+1] = bread_non_gluten[t] and
content[t+1] = content[t] and content_non_gluten[t+1] = content_non_gluten[t] and
sandwich[t+1] = sandwich[t] and sandwich_non_gluten[t+1] = sandwich_non_gluten[t];


# Make non-gluten sandwiches
subject to MakingNonGlutenSandwich {t in 1..T-1}:
make_sandwich_non_gluten[t] = 1 ==> 
bread[t+1] = bread[t] - 1 and bread_non_gluten[t+1] = bread_non_gluten[t] - 1 and
content[t+1] = content[t] - 1 and content_non_gluten[t+1] = content_non_gluten[t] - 1 and
sandwich[t+1] = sandwich[t] + 1 and sandwich_non_gluten[t+1] = sandwich_non_gluten[t] + 1;

subject to NotMakingNonGlutenSandwich {t in 1..T-1}:
make_sandwich_non_gluten[t] = 0 ==> 
bread[t+1] = bread[t] and bread_non_gluten[t+1] = bread_non_gluten[t] and
content[t+1] = content[t] and content_non_gluten[t+1] = content_non_gluten[t] and
sandwich[t+1] = sandwich[t] and sandwich_non_gluten[t+1] = sandwich_non_gluten[t];


# Put sandwich on tray
subject to PutOnOneTrayExcessiveSandwich {i in 1..nr_trays, t in 1..T}:
put_on_tray[t] = 1 and sandwich[t+1] - sandwich_non_gluten[t] > 0 ==> 
on_tray[i, t+1] - on_tray[i, t] >= 0 and on_tray[i, t+1] - on_tray[i, t] <= 1 and # Put max 1 sandwich on a tray
on_tray_non_gluten[i, t+1] = on_tray_non_gluten[i, t]; 

subject to PutOnlyOnOneTrayExcessiveSandwich {t in 1..T}:
put_on_tray[t] = 1 and sandwich[t+1] - sandwich_non_gluten[t] > 0 ==>
sum{i in 1..nr_trays} on_tray[i, t+1] - on_tray[i, t] = 1;

subject to PutOnOneTrayOnlyGlutenSandwich {i in 1..nr_trays, t in 1..T}:
put_on_tray[t] = 1 and sandwich[t+1] - sandwich_non_gluten[t] = 0 ==> 
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] >= 0 and 
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] <= 1;

subject to PutOnlyOnOneTrayOnlyGlutenSandwich {t in 1..T}:
put_on_tray[t] = 1 and sandwich[t+1] - sandwich_non_gluten[t] = 0 ==>
sum{i in 1..nr_trays} on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] = 1;

subject to IncreaseTotalTrayWhenIncreasingNonGlutenTray {i in 1..nr_trays, t in 1..T}:
put_on_tray[t] = 1 and on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i,t] > 0 ==>
on_tray[i, t+1] - on_tray[i, t] = 1; 

subject to DontIncreaseTotalTrayWhenNotIncreasingNonGlutenTray {i in 1..nr_trays, t in 1..T}:
put_on_tray[t] = 1 and on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i,t] = 0 ==>
on_tray[i, t+1] - on_tray[i, t] = 0;

subject to NotPuttingOnTray {i in 1..nr_trays, t in 1..T}:
put_on_tray[t] = 0 ==> on_tray[i, t+1] - on_tray[i, t] = 0 and 
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] = 0;


# Put non-gluten sandwich on tray
subject to PutOnTrayNonGluten {i in 1..nr_trays, t in 1..T}:
put_on_tray_non_gluten[t] = 1 ==> 
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] >= 0 and 
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] <= 1;

subject to PutOnTrayNonGlutenOnlyOnOneTray {t in 1..T}:
put_on_tray_non_gluten[t] = 1 ==>
sum{i in 1..nr_trays} on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] = 1;

subject to PutOnTrayNonGlutenIncreaseTotalTrayWhenIncreasingNonGlutenTray {i in 1..nr_trays, t in 1..T}:
put_on_tray_non_gluten[t] = 1 and on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i,t] > 0 ==>
on_tray[i, t+1] - on_tray[i, t] = 1; 

subject to PutOnTrayNonGlutenDontIncreaseTotalTrayWhenNotIncreasingNonGlutenTray {i in 1..nr_trays, t in 1..T}:
put_on_tray_non_gluten[t] = 1 and on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i,t] = 0 ==>
on_tray[i, t+1] - on_tray[i, t] = 0;

subject to PutOnTrayNonGlutenNotPuttingOnTray {i in 1..nr_trays, t in 1..T}:
put_on_tray_non_gluten[t] = 0 ==> on_tray[i, t+1] - on_tray[i, t] = 0 and 
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] = 0;


# Move tray

# Serve 


subject to PaintingY0 {t in 1..T-1}:
paint[t] = 1 and y[t] = 0 ==> cell[1,t+1] = 1 + cell[1,t];
subject to PaintingY1 {t in 1..T-1}:
paint[t] = 1 and y[t] = 1 ==> cell[2,t+1] = 1 + cell[2,t];
subject to PaintingYn {t in 1..T-1}:
paint[t] = 1 and y[t] = n ==> cell[n-1,t+1] = 1 + cell[n-1,t];
subject to PaintingYinside {t in 1..T-1}:
paint[t] = 1 and y[t] >= 2 and y[t] <= n-1 ==>
exists{i in 2..n-1} (cell[i-1,t+1] + cell[i+1,t+1] = 1 + cell[i-1,t] + cell[i+1,t] and i = y[t]);
subject to PaintingOthersRemainTheSame {i in 1..n, t in 1..T-1}:
paint[t] = 1 and y[t] <> i-1 and y[t] <> i+1 ==> cell[i,t+1] = cell[i,t];
subject to NotPainting {i in 1..n, t in 1..T-1}:
paint[t] = 0 ==> cell[i,t+1] = cell[i,t];

# Position update
subject to Moving {t in 1..T-1}:
move[t] = 1 ==> abs(y[t+1] - y[t]) = 1;
subject to NotMovingY {t in 1..T-1}:
move[t] = 0 ==> y[t+1] = y[t];

# Color update
subject to Switching {t in 1..T-1}:
switch[t] = 1 ==> abs(color[t+1] - color[t]) = 1;
subject to NotSwitching {t in 1..T-1}:
switch[t] = 0 ==> color[t+1] = color[t];

# Stock update
subject to DecrementStock0 {t in 1..T-1}:
paint[t] = 1 and color[t] = 0 ==> stock0[t+1] = stock0[t] - 1 and stock1[t+1] = stock1[t];
subject to DecrementStock1 {t in 1..T-1}:
paint[t] = 1 and color[t] = 1 ==> stock1[t+1] = stock1[t] - 1 and stock0[t+1] = stock0[t];
subject to StockRemainsSame {t in 1..T-1}:
paint[t] = 0 ==> stock0[t+1] = stock0[t] and stock1[t+1] = stock1[t];

# Respect the pattern
subject to RespectPatternUp {t in 1..T-1}:
paint[t] = 1 and y[t] <= n-1 ==> exists{i in 0..n-1} (color[t] = pattern[i+1] and i = y[t]);
subject to RespectPatternDown {t in 1..T-1}:
paint[t] = 1 and y[t] = n ==> color[t] = pattern[n-1];

