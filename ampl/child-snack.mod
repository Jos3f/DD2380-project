# Model for the child-snack planning problem

### PARAMETERS ###

param nr_children;
param nr_places;
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

var pos_tray{i in 1..nr_trays, t in 1..T} integer >= 1; # Array of tray postitions

var on_tray{i in 1..nr_trays, t in 1..T} integer >= 0; # Matrix for each tray, number of sandwiches
var on_tray_non_gluten{i in 1..nr_trays, t in 1..T} integer >= 0; # Matrix for each tray, number of gluten free sandwiches

var bread{t in 1..T} integer >= 0; # stock of bread
var bread_non_gluten{t in 1..T} integer >= 0; # stock of non gluten bread

var content_non_gluten{t in 1..T} integer >= 0; # stock of content
var content{t in 1..T} integer >= 0; # stock of gluten free content

var sandwich_in_kitchen{t in 1..T} integer >= 0; # Sandwiches in kitchen
var sandwich_in_kitchen_non_gluten{t in 1..T} integer >= 0; # Gluten free sandwiches in kitchen

var satisfaction_children{c in 1..nr_children, t in 1..T} binary; # Array of children that have been served, where 1 indicates served and 0 hungry.


# Actions made by the chefs. 1 indicates that the action is being made at a specific time step
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

#Goal state, which is to serve all children
subject to TotalSatisfaction:
exists{t in 1..T} (sum{c in 1..nr_children} (satisfaction_children[c,t]) = nr_children and t = tstar);

# Number of actions each time step should be one at max
subject to OneAction {t in 1..T-1}:
make_sandwich[t] + make_sandwich_non_gluten[t] + put_on_tray[t]
+ put_on_tray_non_gluten[t] + move_tray[t] + serve[t]
+ serve_non_gluten[t] <= 1;


### INITIAL CONDITIONS ###
subject to InitialTrayPos {i in 1..nr_trays}:
pos_tray[i, 1] = 1; # All trays in kitchen

subject to InitialOnTrays {i in 1..nr_trays}:
on_tray[i, 1] = 0; # Nothing on trays
subject to InitialOnNonGlutenTrays {i in 1..nr_trays}:
on_tray_non_gluten[i, 1] = 0; # Nothing on non-gluten trays

# Bread init
subject to InitialBread:
bread[1] = init_b;
subject to InitialBreadNonGluten:
bread_non_gluten[1] = init_b_non_gluten;

# content init
subject to InitialContent :
content[1] = init_content;
subject to InitialContentNonGluten :
content_non_gluten[1] = init_content_non_gluten;

# No sandwiches in kitchen in the starting step
subject to InitialSandwichInKitchen :
sandwich_in_kitchen[1] = 0;
subject to InitialSandwichInKitchenNonGluten :
sandwich_in_kitchen_non_gluten[1] = 0;

# All children are hungry
subject to InitialSatisfactionChildren {i in 1..nr_children}:
satisfaction_children[i, 1] = 0;


### CONSTRAINTS Continued... ###

## Make sandwiches and handle ingredients ##

# Can't make sandwich without any bread or content in kitchen
subject to DontMakeSandwichWithoutBread {t in 1..T-1}: 
bread[t] = 0 or content[t] = 0 ==>
make_sandwich[t] = 0 and make_sandwich_non_gluten[t] = 0;

# Use normal bread for normal sandwich if we have bread with gluten left
subject to MakingSandwichExcessiveBread {t in 1..T-1}: # Making a sandwich 
make_sandwich[t] = 1 and bread[t] - bread_non_gluten[t] > 0 ==> 
bread[t+1] = bread[t] - 1 and bread_non_gluten[t+1] = bread_non_gluten[t];

# Use gluten free bread for normal sandwich if we do not have any bread with gluten remaining
subject to MakingSandwichOnlyGlutenBread {t in 1..T-1}:
make_sandwich[t] = 1 and bread[t] - bread_non_gluten[t] = 0 and bread[t] > 0 ==> 
bread[t+1] = bread[t] - 1 and bread_non_gluten[t+1] = bread_non_gluten[t] - 1;

# Use normal content for normal sandwich if we have content with gluten left
subject to MakingSandwichExcessiveContent {t in 1..T-1}:
make_sandwich[t] = 1 and content[t] - content_non_gluten[t] > 0 ==> 
content[t+1] = content[t] - 1 and content_non_gluten[t+1] = content_non_gluten[t];

# Use gluten free content for normal sandwich if we do not have any content with gluten remaining
subject to MakingSandwichOnlyGlutenContent {t in 1..T-1}:
make_sandwich[t] = 1 and content[t] - content_non_gluten[t] = 0 ==> 
content[t+1] = content[t] - 1 and content_non_gluten[t+1] = content_non_gluten[t] - 1;

# Making sadwich with only non gluten ingredients
subject to MakingSandwichNonGluten {t in 1..T-1}:
make_sandwich[t] = 1 and 
bread[t] - bread_non_gluten[t] = 0 and content[t] - content_non_gluten[t] = 0 ==> 
sandwich_in_kitchen[t+1] = sandwich_in_kitchen[t] + 1 and sandwich_in_kitchen_non_gluten[t+1] = sandwich_in_kitchen_non_gluten[t] + 1;

# Making sandwich with at least one gluten ingredient will make gluten sandwich 
subject to MakingSandwichWithGluten {t in 1..T-1}:
make_sandwich[t] = 1 and 
bread[t] - bread_non_gluten[t] > 0 or content[t] - content_non_gluten[t] > 0 ==> 
sandwich_in_kitchen[t+1] = sandwich_in_kitchen[t] + 1 and sandwich_in_kitchen_non_gluten[t+1] = sandwich_in_kitchen_non_gluten[t];

# If we are not making any sandwiches, bread and content stock has to remain unchanged
subject to NotMakingAnySandwichHandleIngredients {t in 1..T-1}:
make_sandwich[t] = 0 and make_sandwich_non_gluten[t] = 0 ==> 
bread[t+1] = bread[t] and bread_non_gluten[t+1] = bread_non_gluten[t] and
content[t+1] = content[t] and content_non_gluten[t+1] = content_non_gluten[t];

# Sandwich stock in kitchen is only unchanged when we not put on tray or make any sanwiches
subject to SandwichStockUnchanged {t in 1..T-1}:
make_sandwich[t] = 0 and make_sandwich_non_gluten[t] = 0 and put_on_tray[t] = 0 and put_on_tray_non_gluten[t] = 0 ==>
sandwich_in_kitchen[t+1] = sandwich_in_kitchen[t] and sandwich_in_kitchen_non_gluten[t+1] = sandwich_in_kitchen_non_gluten[t];

# Make non-gluten sandwiches, has to use gluten free content
subject to MakingNonGlutenSandwich {t in 1..T-1}:
make_sandwich_non_gluten[t] = 1 ==> 
bread[t+1] = bread[t] - 1 and bread_non_gluten[t+1] = bread_non_gluten[t] - 1 and
content[t+1] = content[t] - 1 and content_non_gluten[t+1] = content_non_gluten[t] - 1 and
sandwich_in_kitchen[t+1] = sandwich_in_kitchen[t] + 1 and sandwich_in_kitchen_non_gluten[t+1] = sandwich_in_kitchen_non_gluten[t] + 1;


## Transferring sandwiches from kitchen to tray ##

# Can not put sandwich on a tray if we do not have any sandwiches
subject to MustHaveSandwichToPutOnTray{t in 1..T-1}:
sandwich_in_kitchen[t] = 0 ==>
put_on_tray[t] = 0;

# The stock of all trays has to remain unchanged if we do not put any sandwiches on a tray or serve a child from a tray
subject to CantIncreaseTrayWithoutAction{i in 1..nr_trays, t in 1..T-1}:
put_on_tray[t] = 0 and put_on_tray_non_gluten[t] = 0 and serve[t] = 0 and serve_non_gluten[t] = 0 ==>
on_tray[i, t+1] = on_tray[i, t] and on_tray_non_gluten[i, t+1] = on_tray_non_gluten[i, t]; 

# Decrease stock of sandwitches in kitchen if we put a sandwich on a tray
subject to MustDecreaseKitchenAfterPutOnTray{t in 1..T-1}:
put_on_tray[t] = 1 and sandwich_in_kitchen[t] - sandwich_in_kitchen_non_gluten[t] > 0 ==>
sandwich_in_kitchen[t+1] = sandwich_in_kitchen[t] - 1 and
sandwich_in_kitchen_non_gluten[t+1] = sandwich_in_kitchen_non_gluten[t];

# Decrease stock of gluten free sandwitch if we want to put a sandwich on a tray but have no normal sandwiches left  
subject to MustDecreaseForceNonGlutenKitchenAfterPutOnTray{t in 1..T-1}:
put_on_tray[t] = 1 and sandwich_in_kitchen[t] - sandwich_in_kitchen_non_gluten[t] = 0 ==>
sandwich_in_kitchen_non_gluten[t+1] = sandwich_in_kitchen_non_gluten[t] - 1 and
sandwich_in_kitchen[t+1] = sandwich_in_kitchen[t] - 1;

# Decrease stock of gluten free sandwiches if we put a gluten free sandwich on the tray
subject to MustDecreaseNonGlutenKitchenAfterPutOnTray{t in 1..T-1}:
put_on_tray_non_gluten[t] = 1 ==>
sandwich_in_kitchen_non_gluten[t+1] = sandwich_in_kitchen_non_gluten[t] - 1 and
sandwich_in_kitchen[t+1] = sandwich_in_kitchen[t] - 1;

# Tray stock can only increase one step +-
subject to TraysCannotIncreaseMoreThanOneStep {i in 1..nr_trays, t in 1..T-1}:
put_on_tray[t] = 1 or put_on_tray_non_gluten[t] = 1 ==>
on_tray[i, t+1] - on_tray[i, t] <= 1 and on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] <= 1;

# Only one tray should be changed since we can only put a sandwich on one tray
subject to PutOnlyOnOneTrayExcessiveSandwich {t in 1..T-1}:
put_on_tray[t] = 1 and sandwich_in_kitchen[t] - sandwich_in_kitchen_non_gluten[t] > 0 ==>
(sum{i in 1..nr_trays} (on_tray[i, t+1] - on_tray[i, t]) = 1);

# Kitchen stock can only decreae if we put on tray +-
subject to SandwichInKitchenCannotChangeMoreThanOneStep {t in 1..T-1}:
put_on_tray[t] = 1 or put_on_tray_non_gluten[t] = 1 ==>
sandwich_in_kitchen_non_gluten[t+1] - sandwich_in_kitchen_non_gluten[t] <= 0 and
sandwich_in_kitchen[t+1] - sandwich_in_kitchen[t] <= 0;

# Tray stock can only increase one step. Case where we take a normal sandwich.
subject to PutOnOneTrayExcessiveSandwich {i in 1..nr_trays, t in 1..T-1}:
put_on_tray[t] = 1 and sandwich_in_kitchen[t] - sandwich_in_kitchen_non_gluten[t] > 0 ==> 
on_tray[i, t+1] - on_tray[i, t] >= 0 and on_tray[i, t+1] - on_tray[i, t] <= 1 and # Put max 1 sandwich on a tray
on_tray_non_gluten[i, t+1] = on_tray_non_gluten[i, t]; 

# Tray stock increase on max 1. Case where we only have gluten free sandwiches left +-
subject to PutOnOneTrayOnlyGlutenSandwich {i in 1..nr_trays, t in 1..T-1}:
put_on_tray[t] = 1 and sandwich_in_kitchen[t] - sandwich_in_kitchen_non_gluten[t] = 0 ==> 
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] >= 0 and 
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] <= 1;

# Only put sandwich on one tray. Case where only gluten free is left +--
subject to PutOnlyOnOneTrayOnlyGlutenSandwich {t in 1..T-1}:
put_on_tray[t] = 1 and sandwich_in_kitchen[t] - sandwich_in_kitchen_non_gluten[t] = 0 ==>
(sum{i in 1..nr_trays} (on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t])) = 1 and 
(sum{i in 1..nr_trays} (on_tray[i, t+1] - on_tray[i, t]) = 1); # +--

# Increase number of total sandwiches on tray when number of gluten free is increased. +-
subject to IncreaseTotalTrayWhenIncreasingNonGlutenTray {i in 1..nr_trays, t in 1..T-1}:
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i,t] > 0 ==>
on_tray[i, t+1] - on_tray[i, t] = 1; 

# Tray stock of other trays has to remain unchanged
subject to DontIncreaseTotalTrayWhenNotIncreasingNonGlutenTray {i in 1..nr_trays, t in 1..T-1}:
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i,t] = 1 ==>
on_tray[i, t+1] - on_tray[i, t] = 1 and 
forall {j in 1..nr_trays diff {i}} (on_tray[j,t+1] = on_tray[j,t]);

# Stock on all trays has to remain unchanged if we do not add sandwich to a tray or serve a child
subject to NotPuttingOnAnyTrayAndNotServingAnything {i in 1..nr_trays, t in 1..T-1}:
put_on_tray[t] = 0 and put_on_tray_non_gluten[t] = 0 and serve[t] = 0 and serve_non_gluten[t] = 0 ==> 
on_tray[i, t+1] - on_tray[i, t] = 0 and 
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] = 0;

# Can not put gluten free sandwich on a tray if we do not have any gluten free sandwiches +-
subject to MustHaveNonGlutenSandwichToPutOnTray{t in 1..T-1}:
sandwich_in_kitchen_non_gluten[t] = 0 ==>
put_on_tray_non_gluten[t] = 0;

# Put non-gluten sandwich on tray, only change one step max +-
subject to PutOnTrayNonGluten {i in 1..nr_trays, t in 1..T-1}:
put_on_tray_non_gluten[t] = 1 and sandwich_in_kitchen_non_gluten[t] > 0 ==> 
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] >= 0 and 
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] <= 1;

# Only change the stock of one tray +-
subject to PutOnTrayNonGlutenOnlyOnOneTray {t in 1..T-1}:
put_on_tray_non_gluten[t] = 1 ==>
(sum{i in 1..nr_trays} (on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t])) = 1 and
(sum{i in 1..nr_trays} (on_tray[i, t+1] - on_tray[i, t]) = 1); # +--

# Tray must be in kitchen to put a sandwich on it
subject to PutOnTrayOnlyInKitchen {i in 1..nr_trays, t in 1..T-1}:
(put_on_tray[t] = 1 or put_on_tray_non_gluten[t] = 1) and on_tray[i,t+1]-on_tray[i,t] > 0 ==>
pos_tray[i,t] = 1; #1 is kitchen

## Move tray ##

# Only move one tray at a time
subject to MoveOnlyOneTray {t in 1..T-1}:
move_tray[t] = 1 ==> 
exists{i in 1..nr_trays} (abs(pos_tray[i,t+1] - pos_tray[i,t]) != 0 and 
forall {j in 1..nr_trays diff {i}} (abs(pos_tray[j,t+1] - pos_tray[j,t]) = 0));

# All trays has to remain at their positions if we haven't moved any tray
subject to NotMoveAnyTray {i in 1..nr_trays, t in 1..T-1}:
move_tray[t] = 0 ==> pos_tray[i,t+1] - pos_tray[i,t] = 0;

# We can only move to valid places
subject to MoveValidPlaces {i in 1..nr_trays, t in 1..T-1}:
move_tray[t] = 1 ==> pos_tray[i, t+1] <= nr_places;


## Serve ##

# Serve a normal sandwitch to a healthy child
subject to ServeSandwich {t in 1..T-1}:
serve[t] = 1 ==>
exists{i in 1..nr_trays, c in 1..nr_children} (on_tray[i,t+1] = on_tray[i,t] - 1  and child_pos[c] = pos_tray[i,t] and # Tray and child are at the same table
satisfaction_children[c,t+1] = satisfaction_children[c,t] + 1 and health_status[c] = 0 # only serve this to nonallergic children and make child satisfied
and forall {j in 1..nr_trays diff {i}} (on_tray[j,t+1] = on_tray[j,t]) # only reduce one tray
and forall {c2 in 1..nr_children diff {c}} (satisfaction_children[c2,t+1] = satisfaction_children[c2,t])); # only feed one child   

# non gluten count has to remain unchanged for tray we served from if we had enough normal sandwiches and served a normal one  +-
subject to ReduceSandwichOnTrayExcessiveSandwich {i in 1..nr_trays, t in 1..T-1}:
serve[t] = 1 and on_tray[i,t] - on_tray_non_gluten[i,t] > 0 ==> 
on_tray_non_gluten[i,t+1] = on_tray_non_gluten[i,t];

# Had to serve gluten free sandwich to healthy child because no normal remaining +-
subject to ReduceSandwichOnTrayOnlyGlutenSandwich {i in 1..nr_trays, t in 1..T-1}:
serve[t] = 1 and on_tray[i,t] - on_tray_non_gluten[i,t] = 0 and on_tray[i,t+1] - on_tray[i,t] = -1 ==> 
on_tray_non_gluten[i,t+1] = on_tray_non_gluten[i,t] - 1;

# If we do not serve from a tray, leave their stock unchanged +-
subject to ConstantSandwichOnOthersTrayOnlyGlutenSandwich {i in 1..nr_trays, t in 1..T-1}:
serve[t] = 1 and on_tray[i,t+1] - on_tray[i,t] = 0 ==> 
on_tray_non_gluten[i,t+1] = on_tray_non_gluten[i,t];


# Children satisfaction constant when not serving anything
subject to NotServingAnything {t in 1..T-1}:
serve[t] = 0 and serve_non_gluten[t] = 0 ==>
forall {c in 1..nr_children} (satisfaction_children[c,t+1] = satisfaction_children[c,t]);

# Serve gluten free sandwich to allergic children +-
subject to ServeNonGlutenSandwich {t in 1..T-1}:
serve_non_gluten[t] = 1 ==>
exists{i in 1..nr_trays, c in 1..nr_children} (on_tray_non_gluten[i,t+1] - on_tray_non_gluten[i,t] = -1  and child_pos[c] = pos_tray[i,t] and # Tray and child are at the same table 
satisfaction_children[c,t+1] = satisfaction_children[c,t] + 1 and health_status[c] = 1 # only serve this to allergic children
and forall {j in 1..nr_trays diff {i}} (on_tray_non_gluten[j,t+1] = on_tray_non_gluten[j,t]) #only reduce one tray
and forall {c2 in 1..nr_children diff {c}} (satisfaction_children[c2,t+1] = satisfaction_children[c2,t])); #only feed one child

# Decrease tray stock for changed tray
subject to DecreaseOnTrayWhenDecreaseOnTrayNonGluten {i in 1..nr_trays, t in 1..T-1}:
(serve_non_gluten[t] = 1) and (on_tray_non_gluten[i,t+1] - on_tray_non_gluten[i,t] = -1) ==>
on_tray[i,t+1] - on_tray[i,t] = -1;

# Leave stock of other trays unchanged for trays that were not targeted in the serve of the gluten free sandwich
subject to ConstantSandwichOnOthersTrayNonGlutenSandwich {i in 1..nr_trays, t in 1..T-1}:
serve_non_gluten[t] = 1 and on_tray_non_gluten[i,t+1] - on_tray_non_gluten[i,t] = 0 ==> 
on_tray[i,t+1] = on_tray[i,t];


### END OF MODEL ###