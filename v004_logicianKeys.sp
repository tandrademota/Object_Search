#const numSteps = 3.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 sorts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#place = {office, main_library, aux_library}.

#robot = {rob0}.

#target_obj = {backpack, keys}.

#ref_obj = {desk1,backpack, wardrobe1, dinnertable}.

#preposition = {on, in, under}.

#object = #target_obj + #ref_obj.

#thing = #object + #robot.

#boolean = {true, false}.

#step = 0..numSteps.


%% Fluents

#inertial_fluent = loc(#thing, #place) + relation(#object, #preposition, #ref_obj) + verified(#robot, #target_obj, #ref_obj) + found(#robot, #target_obj).

#fluent = #inertial_fluent.

#action = move(#robot, #place) + search(#robot, #target_obj, #place) + open(#robot, #ref_obj).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 predicates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

val(#fluent, #boolean, #step).
is_defined(#fluent).

occurs(#action, #step).

obs(#fluent, #boolean, #step).
hpd(#action, #step).

success().
goal(#step).
something_happened(#step).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 rules
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%
%% State Constraints
%%%%%%%%%%%%%%%%%%%%%

%% If an object is in one location, it cannot be in another
val(loc(O, L1), false, I) :- val(loc(O, L2), true, I), L1!=L2.

%% The Target Object has the same location as the Reference if they maintain a spatial relation
val(loc(TO, L), true, I) :- val(loc(RO, L), true, I), val(relation(TO, Prep, RO), true, I).



%%%%%%%%%%%%%%%%
%% Causal Laws
%%%%%%%%%%%%%%%%

%% Moving changes location to target place
val(loc(R, P), true, I+1) :- occurs(move(R, P), I).

%% Searching for an object in the location where the reference is changes its status to verified
val(verified(R, TO, RO), true, I+1) :- occurs(search(R, TO, L), I), val(loc(RO,L),true,I).


%% If the preposition "in" relates target and reference, the latter will be opened to find the former, given that it was verified... 
val(found(R, TO), true, I+1) :- occurs(open(R, RO), I), val(verified(R, TO, RO), true, I), val(relation(TO,in,RO),true,I).


%%%%%%%%%%%%%%%
%% CR rules
%%%%%%%%%%%%%%%

%% ...however, if preposition "in" is not involved or if the agent finds the target during the search action, the reference have not and/or can not be opened. 
val(found(R, TO), true, I+1) :+ occurs(search(R, TO,L), I), val(loc(TO,L),true,I).



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Executability Conditioms
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% The robot does not move to a location if it is already there
-occurs(move(R, L), I) :- val(loc(R, L), true, I).

%% The robot cannot search for an object in a location if it believes that itself or the object are in a different location
-occurs(search(R, TO, P1), I) :- val(loc(R, P2), true, I), P1!=P2.
-occurs(search(R, TO, P1), I) :- val(loc(TO, P2), true, I), P1!=P2.

%% Cannot have two actions happening concurrently
-occurs(A2, I) :- occurs(A1, I), A1 != A2.



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inertia Axioms and CWA
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% General Inertia Axiom
val(F, Y, I+1) :- #inertial_fluent(F),
             	  val(F, Y, I),
                  not -val(F, Y, I+1).

%% CWA for Actions
-occurs(A, I) :- not occurs(A, I).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Reality check + obs rules
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Reality check axioms
:- obs(F, true, I), val(F, false, I).
:- obs(F, false, I), val(F, true, I).

%% Observations set values of fluents, and thus define fluents
val(F, Y, 0) :- obs(F, Y, 0).
is_defined(F) :- val(F,true,0).

-obs(F, V2, I) :- obs(F, V1, I), V1!=V2.

%% Take what actually happened into account
occurs(A,I) :- hpd(A,I).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Rules for val function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-val(F, V2, I) :- val(F, V1, I), V1!=V2.

val(F, false, 0) :- not is_defined(F).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Goal and Planning Module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

success :- goal(I), I <= numSteps.

%% Failure is not an option
:- not success.

%% Persevere, i.e., cannot stop executing actions, until goal achieved
occurs(A, I) | -occurs(A, I) :- not goal(I).

something_happened(I) :- occurs(A, I).

:- not goal(I), not something_happened(I).


goal(I) :- val(found(rob0, keys), true, I).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

obs(loc(rob0, office), true, 0).

obs(relation(keys,in,backpack),true,0).

obs(relation(backpack,on,desk1),true,0).

obs(loc(desk1, main_library), true, 0).

%obs(found(rob0, keys), true, 2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
occurs.

