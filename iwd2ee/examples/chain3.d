// CHAIN3 example, as used in the 
// Improved Ilyich Dialogue

// ILY1 = Zhivago
// ILY2 = Ilyich
// ILY3 = Karamazov
// ILY4 = Rasputin
// ILY5 = Neophyte Glabrezu

BEGIN ILY1 // blank files
BEGIN ILY3
BEGIN ILY4

BEGIN ILY2

IF ~NumTimesTalkedTo(0)~ THEN BEGIN s0
  SAY "Hello, I'm going to kill you."
  IF ~~ THEN REPLY "Ok, let's fight!" 
    DO ~SetGlobal("IlyichFight","GLOBAL",1)~ EXIT
  IF ~~ THEN REPLY "Talk to me first." GOTO s1
END

IF ~~ THEN BEGIN s_bye
  SAY "Ok, we're done talking, let's fight!" 
  IF ~~ THEN DO ~SetGlobal("IlyichFight","GLOBAL",1)~ EXIT
END

CHAIN3 ILY2 s1
   "Very well, blah blah."
== ILY1 IF ~!Dead("ily1") PartyHasItem("staf02")~ THEN 
    "Boss, they have the staff!"
== ILY2 IF ~!Dead("ily1") PartyHasItem("staf02")~ THEN 
    "I know, Ily1!"
== ILY2 "Yada yada."
== ILY3 IF ~!Dead("ily3") PartyHasItem("sw1h05")~ THEN 
    "Boss, they have the sword!" 
== ILY2 IF ~!Dead("ily3") PartyHasItem("sw1h05")~ THEN
    "I know, Ily3!" 
== ILY2 "Blather, blather."
== ILY4 IF ~!Dead("ily4") IsValidForPartyDialog("Yoshimo")~ THEN
    "Boss, they have Yoshimo!"
== YOSHJ IF ~!Dead("ily4") IsValidForPartyDialog("Yoshimo")~ THEN
    "I am Yoshimo, feared by all."
== ILY2 IF ~!Dead("ily4") IsValidForPartyDialog("Yoshimo")~ THEN
    "I know they have Yoshimo, Ily4."
== ILY2 "Mumble mumble."
== ILY1 IF ~!Dead("ily1") PartyHasItem("dagg02")~ THEN 
    "Boss, they have the +1 dagger!"
== ILY2 IF ~!Dead("ily1") PartyHasItem("dagg02")~ THEN 
    "I can see the dagger, Ily1."
== MINSCJ IF ~IsValidForPartyDialog("Minsc")~ THEN
    "I am Minsc, I shall smite you!"
== ILY2 IF ~IsValidForPartyDialog("Minsc")~ THEN 
    "OK, I'm afraid."
== MINSCJ IF ~IsValidForPartyDialog("Minsc")~ THEN
    "You should be: I have a rodent."
== ILY2 IF ~IsValidForPartyDialog("Minsc")~ THEN
    "Yes, you do have a rodent."
== ILY2 "Continuing on ..."
== JAHEIRAJ IF ~IsValidForPartyDialog("Jaheira")~ THEN
    "I'm an uptight but well-developed character."
== ILY2 IF ~IsValidForPartyDialog("Jaheira")~ THEN
    "Go moan over Khalid and leave me alone!"
END ily2 s_bye
