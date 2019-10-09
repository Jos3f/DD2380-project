

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

var pos_tray{i in 1..nr_trays, t in 1..T} integer >= 1;

var on_tray{i in 1..nr_trays, t in 1..T} integer >= 0;
var on_tray_non_gluten{i in 1..nr_trays, t in 1..T} integer >= 0;

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


#Goal state
subject to TotalSatisfaction:
exists{t in 1..T} (sum{c in 1..nr_children} (satisfaction_children[c,t]) = nr_children and t = tstar);
#exists{t in 1..T} on_tray_non_gluten[1, t] = 2 and pos_tray[1, t] = 2
#and t = tstar;

# Max one action each time step
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
on_tray_non_gluten[i, 1] = 0; # Nothing on non-gluten trays

subject to InitialBread:
bread[1] = init_b;
subject to InitialBreadNonGluten:
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
# Handle ingredients

subject to DontMakeSandwichWithoutBread {t in 1..T-1}:
bread[t] = 0 or content[t] = 0 ==>
make_sandwich[t] = 0 and make_sandwich_non_gluten[t] = 0;

subject to MakingSandwichExcessiveBread {t in 1..T-1}:
make_sandwich[t] = 1 and bread[t] - bread_non_gluten[t] > 0 ==> 
bread[t+1] = bread[t] - 1 and bread_non_gluten[t+1] = bread_non_gluten[t];

subject to MakingSandwichOnlyGlutenBread {t in 1..T-1}:
make_sandwich[t] = 1 and bread[t] - bread_non_gluten[t] = 0 and bread[t] > 0 ==> 
bread[t+1] = bread[t] - 1 and bread_non_gluten[t+1] = bread_non_gluten[t] - 1;

subject to MakingSandwichExcessiveContent {t in 1..T-1}:
make_sandwich[t] = 1 and content[t] - content_non_gluten[t] > 0 ==> 
content[t+1] = content[t] - 1 and content_non_gluten[t+1] = content_non_gluten[t];

subject to MakingSandwichOnlyGlutenContent {t in 1..T-1}:
make_sandwich[t] = 1 and content[t] - content_non_gluten[t] = 0 ==> 
content[t+1] = content[t] - 1 and content_non_gluten[t+1] = content_non_gluten[t] - 1;

#Handle sandwiches output
subject to MakingSandwichNonGluten {t in 1..T-1}:
make_sandwich[t] = 1 and 
bread[t] - bread_non_gluten[t] = 0 and content[t] - content_non_gluten[t] = 0 ==> 
sandwich_in_kitchen[t+1] = sandwich_in_kitchen[t] + 1 and sandwich_in_kitchen_non_gluten[t+1] = sandwich_in_kitchen_non_gluten[t] + 1;

subject to MakingSandwichWithGluten {t in 1..T-1}:
make_sandwich[t] = 1 and 
bread[t] - bread_non_gluten[t] > 0 or content[t] - content_non_gluten[t] > 0 ==> 
sandwich_in_kitchen[t+1] = sandwich_in_kitchen[t] + 1 and sandwich_in_kitchen_non_gluten[t+1] = sandwich_in_kitchen_non_gluten[t];

subject to NotMakingAnySandwichHandleIngredients {t in 1..T-1}:
make_sandwich[t] = 0 and make_sandwich_non_gluten[t] = 0 ==> 
bread[t+1] = bread[t] and bread_non_gluten[t+1] = bread_non_gluten[t] and
content[t+1] = content[t] and content_non_gluten[t+1] = content_non_gluten[t];

##Sandwich stock is only unchanged when we not put on tray or make any sanwiches
subject to SandwichStockUnchanged {t in 1..T-1}:
make_sandwich[t] = 0 and make_sandwich_non_gluten[t] = 0 and put_on_tray[t] = 0 and put_on_tray_non_gluten[t] = 0 ==>
sandwich_in_kitchen[t+1] = sandwich_in_kitchen[t] and sandwich_in_kitchen_non_gluten[t+1] = sandwich_in_kitchen_non_gluten[t];


# Make non-gluten sandwiches
subject to MakingNonGlutenSandwich {t in 1..T-1}:
make_sandwich_non_gluten[t] = 1 ==> 
bread[t+1] = bread[t] - 1 and bread_non_gluten[t+1] = bread_non_gluten[t] - 1 and
content[t+1] = content[t] - 1 and content_non_gluten[t+1] = content_non_gluten[t] - 1 and
sandwich_in_kitchen[t+1] = sandwich_in_kitchen[t] + 1 and sandwich_in_kitchen_non_gluten[t+1] = sandwich_in_kitchen_non_gluten[t] + 1;

#subject to NotMakingNonGlutenSandwich {t in 1..T-1}:
#make_sandwich_in_kitchen_non_gluten[t] = 0 ==> 
#bread[t+1] = bread[t] and bread_non_gluten[t+1] = bread_non_gluten[t] and
#content[t+1] = content[t] and content_non_gluten[t+1] = content_non_gluten[t] and
#sandwich_in_kitchen[t+1] = sandwich_in_kitchen[t] and sandwich_in_kitchen_non_gluten[t+1] = sandwich_in_kitchen_non_gluten[t];


# Put sandwich on tray
subject to MustHaveSandwichToPutOnTray{t in 1..T-1}:
sandwich_in_kitchen[t] = 0 ==>
put_on_tray[t] = 0;

subject to CantIncreaseTrayWithoutAction{i in 1..nr_trays, t in 1..T-1}:
put_on_tray[t] = 0 and put_on_tray_non_gluten[t] = 0 and serve[t] = 0 and serve_non_gluten[t] = 0 ==>
on_tray[i, t+1] = on_tray[i, t] and on_tray_non_gluten[i, t+1] = on_tray_non_gluten[i, t]; 


subject to MustDecreaseForceNonGlutenKitchenAfterPutOnTray{t in 1..T-1}:
put_on_tray[t] = 1 and sandwich_in_kitchen[t] - sandwich_in_kitchen_non_gluten[t] = 0 ==>
sandwich_in_kitchen_non_gluten[t+1] = sandwich_in_kitchen_non_gluten[t] - 1 and
sandwich_in_kitchen[t+1] = sandwich_in_kitchen[t] - 1;



subject to MustDecreaseKitchenAfterPutOnTray{t in 1..T-1}:
put_on_tray[t] = 1 and sandwich_in_kitchen[t] - sandwich_in_kitchen_non_gluten[t] > 0 ==>
sandwich_in_kitchen[t+1] = sandwich_in_kitchen[t] - 1 and
sandwich_in_kitchen_non_gluten[t+1] = sandwich_in_kitchen_non_gluten[t];

subject to MustDecreaseNonGlutenKitchenAfterPutOnTray{t in 1..T-1}:
put_on_tray_non_gluten[t] = 1 ==>
sandwich_in_kitchen_non_gluten[t+1] = sandwich_in_kitchen_non_gluten[t] - 1 and
sandwich_in_kitchen[t+1] = sandwich_in_kitchen[t] - 1;


subject to TraysCannotIncreaseMoreThanOneStep {i in 1..nr_trays, t in 1..T-1}:
put_on_tray[t] = 1 or put_on_tray_non_gluten[t] = 1 ==>
on_tray[i, t+1] - on_tray[i, t] <= 1 and on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] <= 1;

subject to SandwichInKitchenCannotChangeMoreThanOneStep {t in 1..T-1}:
put_on_tray[t] = 1 or put_on_tray_non_gluten[t] = 1 ==>
sandwich_in_kitchen_non_gluten[t+1] - sandwich_in_kitchen_non_gluten[t] <= 0 and
sandwich_in_kitchen[t+1] - sandwich_in_kitchen[t] <= 0;


subject to PutOnOneTrayExcessiveSandwich {i in 1..nr_trays, t in 1..T-1}:
put_on_tray[t] = 1 and sandwich_in_kitchen[t] - sandwich_in_kitchen_non_gluten[t] > 0 ==> 
on_tray[i, t+1] - on_tray[i, t] >= 0 and on_tray[i, t+1] - on_tray[i, t] <= 1 and # Put max 1 sandwich on a tray
on_tray_non_gluten[i, t+1] = on_tray_non_gluten[i, t]; 

subject to PutOnlyOnOneTrayExcessiveSandwich {t in 1..T-1}:
put_on_tray[t] = 1 and sandwich_in_kitchen[t] - sandwich_in_kitchen_non_gluten[t] > 0 ==>
(sum{i in 1..nr_trays} (on_tray[i, t+1] - on_tray[i, t]) = 1);
#exists{i in 1..nr_trays} (abs(pos_tray[i,t+1] - pos_tray[i,t]) != 0 and forall {j in 1..nr_trays diff {i}} (abs(pos_tray[j,t+1]-pos_tray[j,t]) = 0));1] - on_tray[i, t])) = 1;

subject to PutOnOneTrayOnlyGlutenSandwich {i in 1..nr_trays, t in 1..T-1}:
put_on_tray[t] = 1 and sandwich_in_kitchen[t] - sandwich_in_kitchen_non_gluten[t] = 0 ==> 
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] >= 0 and 
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] <= 1;

subject to PutOnlyOnOneTrayOnlyGlutenSandwich {t in 1..T-1}:
put_on_tray[t] = 1 and sandwich_in_kitchen[t] - sandwich_in_kitchen_non_gluten[t] = 0 ==>
(sum{i in 1..nr_trays} (on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t])) = 1;

subject to IncreaseTotalTrayWhenIncreasingNonGlutenTray {i in 1..nr_trays, t in 1..T-1}:
#put_on_tray[t] = 1 and on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i,t] > 0 ==>
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i,t] > 0 ==>
on_tray[i, t+1] - on_tray[i, t] = 1; 

subject to DontIncreaseTotalTrayWhenNotIncreasingNonGlutenTray {i in 1..nr_trays, t in 1..T-1}:
#put_on_tray[t] = 1 and on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i,t] = 0 ==>
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i,t] = 1 ==>
on_tray[i, t+1] - on_tray[i, t] = 1 and 
forall {j in 1..nr_trays diff {i}} (on_tray[j,t+1] = on_tray[j,t]);

#All onTrays Unchanged case
subject to NotPuttingOnAnyTrayAndNotServingAnything {i in 1..nr_trays, t in 1..T-1}:
put_on_tray[t] = 0 and put_on_tray_non_gluten[t] = 0 and serve[t] = 0 and serve_non_gluten[t] = 0 ==> 
on_tray[i, t+1] - on_tray[i, t] = 0 and 
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] = 0;


subject to MustHaveNonGlutenSandwichToPutOnTray{t in 1..T-1}:
sandwich_in_kitchen_non_gluten[t] = 0 ==>
put_on_tray_non_gluten[t] = 0;

# Put non-gluten sandwich on tray
subject to PutOnTrayNonGluten {i in 1..nr_trays, t in 1..T-1}:
put_on_tray_non_gluten[t] = 1 and sandwich_in_kitchen_non_gluten[t] > 0 ==> 
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] >= 0 and 
on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] <= 1;

subject to PutOnTrayNonGlutenOnlyOnOneTray {t in 1..T-1}:
put_on_tray_non_gluten[t] = 1 ==>
(sum{i in 1..nr_trays} (on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t])) = 1;


#Tray must be in kitchen to put on it
subject to PutOnTrayOnlyInKitchen {i in 1..nr_trays, t in 1..T-1}:
(put_on_tray[t] = 1 or put_on_tray_non_gluten[t] = 1) and on_tray[i,t+1]-on_tray[i,t] > 0 ==>
pos_tray[i,t] = 1; #1 is kitchen



#Covered by IncreaseTotalTrayWhenIncreasingNonGlutenTray
#subject to PutOnTrayNonGlutenIncreaseTotalTrayWhenIncreasingNonGlutenTray {i in 1..nr_trays, t in 1..T-1}:
#put_on_tray_non_gluten[t] = 1 and on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i,t] > 0 ==>
#on_tray[i, t+1] - on_tray[i, t] = 1; 

#Covered by DontIncreaseTotalTrayWhenNotIncreasingNonGlutenTray
#subject to PutOnTrayNonGlutenDontIncreaseTotalTrayWhenNotIncreasingNonGlutenTray {i in 1..nr_trays, t in 1..T-1}:
#put_on_tray_non_gluten[t] = 1 and on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i,t] = 0 ==>
#on_tray[i, t+1] - on_tray[i, t] = 0;


#covered by NotPuttingOnAnyTrayAndNotServingAnything
#subject to PutOnTrayNonGlutenNotPuttingOnTray {i in 1..nr_trays, t in 1..T-1}:
#put_on_tray_non_gluten[t] = 0 ==> on_tray[i, t+1] - on_tray[i, t] = 0 and 
#on_tray_non_gluten[i, t+1] - on_tray_non_gluten[i, t] = 0;


# Move tray
subject to MoveOnlyOneTray {t in 1..T-1}:
move_tray[t] = 1 ==> 
exists{i in 1..nr_trays} (abs(pos_tray[i,t+1] - pos_tray[i,t]) != 0 and 
forall {j in 1..nr_trays diff {i}} (abs(pos_tray[j,t+1] - pos_tray[j,t]) = 0));

subject to NotMoveAnyTray {i in 1..nr_trays, t in 1..T-1}:
move_tray[t] = 0 ==> pos_tray[i,t+1] - pos_tray[i,t] = 0;

subject to MoveValidPlaces {i in 1..nr_trays, t in 1..T-1}:
move_tray[t] = 1 ==> pos_tray[i, t+1] <= nr_places;



# Serve 
subject to ServeSandwich {t in 1..T-1}:
serve[t] = 1 ==>
exists{i in 1..nr_trays, c in 1..nr_children} (on_tray[i,t+1] = on_tray[i,t] - 1  and child_pos[c] = pos_tray[i,t] and 
satisfaction_children[c,t+1] = satisfaction_children[c,t] + 1 and health_status[c] = 0 # only serve this to nonallergic children
and forall {j in 1..nr_trays diff {i}} (on_tray[j,t+1] = on_tray[j,t]) #only reduce one tray
and forall {c2 in 1..nr_children diff {c}} (satisfaction_children[c2,t+1] = satisfaction_children[c2,t])); #only feed one child   


subject to ReduceSandwichOnTrayExcessiveSandwich {i in 1..nr_trays, t in 1..T-1}:
serve[t] = 1 and on_tray[i,t] - on_tray_non_gluten[i,t] > 0 ==> 
on_tray_non_gluten[i,t+1] = on_tray_non_gluten[i,t];

subject to ReduceSandwichOnTrayOnlyGlutenSandwich {i in 1..nr_trays, t in 1..T-1}:
serve[t] = 1 and on_tray[i,t] - on_tray_non_gluten[i,t] = 0 and on_tray[i,t+1] - on_tray[i,t] = -1 ==> 
on_tray_non_gluten[i,t+1] = on_tray_non_gluten[i,t] - 1;

subject to ConstantSandwichOnOthersTrayOnlyGlutenSandwich {i in 1..nr_trays, t in 1..T-1}:
serve[t] = 1 and on_tray[i,t+1] - on_tray[i,t] = 0 ==> 
on_tray_non_gluten[i,t+1] = on_tray_non_gluten[i,t];


#Children satisfaction constant when not serving anything
subject to NotServingAnything {t in 1..T-1}:
serve[t] = 0 and serve_non_gluten[t] = 0 ==>
forall {c in 1..nr_children} (satisfaction_children[c,t+1] = satisfaction_children[c,t]);


subject to ServeNonGlutenSandwich {t in 1..T-1}:
serve_non_gluten[t] = 1 ==>
exists{i in 1..nr_trays, c in 1..nr_children} (on_tray_non_gluten[i,t+1] - on_tray_non_gluten[i,t] = -1  and child_pos[c] = pos_tray[i,t] and 
satisfaction_children[c,t+1] = satisfaction_children[c,t] + 1 and health_status[c] = 1 # only serve this to allergic children
and forall {j in 1..nr_trays diff {i}} (on_tray_non_gluten[j,t+1] = on_tray_non_gluten[j,t]) #only reduce one tray
and forall {c2 in 1..nr_children diff {c}} (satisfaction_children[c2,t+1] = satisfaction_children[c2,t])); #only feed one child

subject to DecreaseOnTrayWhenDecreaseOnTrayNonGluten {i in 1..nr_trays, t in 1..T-1}:
(serve_non_gluten[t] = 1) and (on_tray_non_gluten[i,t+1] - on_tray_non_gluten[i,t] = -1) ==>
on_tray[i,t+1] - on_tray[i,t] = -1;

subject to ConstantSandwichOnOthersTrayNonGlutenSandwich {i in 1..nr_trays, t in 1..T-1}:
serve_non_gluten[t] = 1 and on_tray_non_gluten[i,t+1] - on_tray_non_gluten[i,t] = 0 ==> 
on_tray[i,t+1] = on_tray[i,t];
