BEGIN ~30ENNELI~

IF WEIGHT #1 ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY #16076
  IF ~~ THEN REPLY #16077 DO ~SetGlobal("Know_Ennelia","GLOBAL", 1)~ GOTO 1
  IF ~~ THEN REPLY #16078 DO ~SetGlobal("Know_Ennelia","GLOBAL", 1)~ GOTO 28
END

IF ~~ THEN BEGIN 1
  SAY #16081
  IF ~~ THEN REPLY #16082 GOTO 2
  IF ~~ THEN REPLY #16084 GOTO 25
END

IF ~~ THEN BEGIN 2
  SAY #16085
  IF ~~ THEN GOTO 3
END

IF ~~ THEN BEGIN 3
  SAY #16087
  IF ~~ THEN GOTO 4
END

IF ~~ THEN BEGIN 4
  SAY #16088
  IF ~~ THEN GOTO 5
END

IF ~~ THEN BEGIN 5
  SAY #17015
  IF ~~ THEN GOTO 6
END

IF ~~ THEN BEGIN 6
  SAY #17016
  IF ~~ THEN REPLY #24453 DO ~SetGlobal("Know_Ennelia","GLOBAL", 2)~ JOURNAL #16061 GOTO 8
  IF ~~ THEN REPLY #24454 DO ~SetGlobal("Know_Ennelia", "GLOBAL", 2)
SetGlobal("30Enneli_Hate","GLOBAL", 1)~ JOURNAL #16063 GOTO 7
END

IF ~~ THEN BEGIN 7
  SAY #25142
  IF ~~ THEN REPLY #25143 GOTO 9
  IF ~~ THEN REPLY #25597 GOTO 24
  IF ~~ THEN REPLY #25598 GOTO 25
END

IF ~~ THEN BEGIN 8
  SAY #25599
  IF ~~ THEN REPLY #28012 GOTO 9
  IF ~~ THEN REPLY #28013 GOTO 25
END

IF ~~ THEN BEGIN 9
  SAY #28014
  IF ~~ THEN REPLY #28187 GOTO 10
  IF ~~ THEN REPLY #28188 GOTO 12
  IF ~  Global("30enneli_bquest","GLOBAL",0)
~ THEN REPLY #28189 GOTO 14
  IF ~  Global("30enneli_bquest","GLOBAL",1)
~ THEN REPLY #28190 GOTO 33
  IF ~~ THEN REPLY #28191 GOTO 18
  IF ~  Global("30Enneli_Hate","GLOBAL",0)
~ THEN REPLY #28192 GOTO 20
  IF ~  Global("30Enneli_Hate","GLOBAL",1)
~ THEN REPLY #28192 GOTO 26
  IF ~  Global("30Enneli_Healed","GLOBAL",0)
~ THEN REPLY #28193 GOTO 21
  IF ~~ THEN REPLY #28194 GOTO 25
END

IF ~~ THEN BEGIN 10
  SAY #28195
  IF ~~ THEN GOTO 11
END

IF ~~ THEN BEGIN 11
  SAY #28196
  IF ~~ THEN REPLY #28197 GOTO 9
  IF ~~ THEN REPLY #28198 GOTO 25
END

IF ~~ THEN BEGIN 12
  SAY #28199
  IF ~~ THEN GOTO 13
END

IF ~~ THEN BEGIN 13
  SAY #28200
  IF ~~ THEN REPLY #28201 JOURNAL #16064 GOTO 9
  IF ~~ THEN REPLY #28198 JOURNAL #16064 GOTO 25
END

IF ~~ THEN BEGIN 14
  SAY #28331
  IF ~~ THEN GOTO 15
END

IF ~~ THEN BEGIN 15
  SAY #28332
  IF ~~ THEN REPLY #28333 DO ~SetGlobal("30Enneli_BQuest","GLOBAL", 1)~ JOURNAL #16065 GOTO 16
  IF ~~ THEN REPLY #28334 GOTO 17
END

IF ~~ THEN BEGIN 16
  SAY #28335
  IF ~  Global("30Enneli_BQuest","GLOBAL",1)
~ THEN REPLY #28336 GOTO 9
  IF ~~ THEN REPLY #28337 GOTO 25
END

IF ~~ THEN BEGIN 17
  SAY #28338
  IF ~~ THEN REPLY #28339 DO ~SetGlobal("30Enneli_BQuest","GLOBAL", 1)~ JOURNAL #16065 GOTO 16
  IF ~  Global("Fortress_Quest","GLOBAL",1)
~ THEN REPLY #28361 EXIT
  IF ~  Global("30Enneli_Hate","GLOBAL",0)
!Global("Fortress_Quest","GLOBAL",1)
~ THEN REPLY #28362 DO ~SetGlobal("30Enneli_Hate","GLOBAL", 1)~ GOTO 7
  IF ~  Global("30Enneli_Hate","GLOBAL",1)
~ THEN REPLY #28363 GOTO 24
END

IF ~~ THEN BEGIN 18
  SAY #28370
  IF ~~ THEN GOTO 19
END

IF ~~ THEN BEGIN 19
  SAY #28371
  IF ~~ THEN REPLY #28372 JOURNAL #16066 GOTO 9
  IF ~~ THEN REPLY #28490 JOURNAL #16066 GOTO 25
END

IF ~~ THEN BEGIN 20
  SAY #28491
  IF ~~ THEN REPLY #28492 DO ~FadeToColor([0.0],0)
FadeFromColor([0.0],0)
RestParty()
~ EXIT
  IF ~~ THEN REPLY #28493 DO ~FadeToColor([0.0],0)
FadeFromColor([0.0],0)
RestUntilHealed()~ EXIT
  IF ~~ THEN REPLY #28494 GOTO 9
  IF ~~ THEN REPLY #28198 GOTO 25
END

IF ~~ THEN BEGIN 21
  SAY #28495
  IF ~~ THEN REPLY #28728 GOTO 9
  IF ~  PartyHasItem("00potn04")
~ THEN REPLY #28729 DO ~AddXpVar("Level_5_Easy",16072)
TakePartyItemNum("00potn04", 1)
UseItem("00potn04",Myself)
SetGlobal("30Enneli_Healed","GLOBAL", 2)~ JOURNAL #16067 GOTO 29
  IF ~  PartyHasItem("00potn03")
~ THEN REPLY #28730 DO ~AddXpVar("Level_5_Easy",16072)
TakePartyItemNum("00potn03", 1)
UseItem("00potn03",Myself)
SetGlobal("30Enneli_Healed","GLOBAL", 2)~ JOURNAL #16067 GOTO 29
  IF ~  PartyHasItem("00potn05")
~ THEN REPLY #29042 DO ~AddXpVar("Level_5_Easy",16072)
TakePartyItemNum("00potn05", 1)
UseItem("00potn05",Myself)
SetGlobal("30Enneli_Healed","GLOBAL", 2)~ JOURNAL #16067 GOTO 29
  IF ~~ THEN REPLY #28198 GOTO 25
END

IF WEIGHT #8 ~  Global("30Enneli_Healed","GLOBAL",1)
~ THEN BEGIN 22
  SAY #29043
  IF ~~ THEN REPLY #29044 DO ~AddXpVar("Level_5_Easy",16072)
SetGlobal("30Enneli_Healed","GLOBAL", 2)~ GOTO 9
  IF ~~ THEN REPLY #30730 DO ~AddXpVar("Level_5_Easy",16072)
SetGlobal("30Enneli_Healed","GLOBAL", 2)~ GOTO 25
END

IF WEIGHT #9 ~  !Global("30Enneli_Healed","GLOBAL",2)
!Global("30Enneli_Healed","GLOBAL",1)
~ THEN BEGIN 23
  SAY #30731
  IF ~~ THEN REPLY #32040 GOTO 9
  IF ~  PartyHasItem("00potn04")
~ THEN REPLY #28729 DO ~AddXpVar("Level_5_Easy",16072)
TakePartyItemNum("00potn04", 1)
UseItem("00potn04",Myself)
SetGlobal("30Enneli_Healed","GLOBAL", 2)~ JOURNAL #16067 GOTO 29
  IF ~  PartyHasItem("00potn03")
~ THEN REPLY #28730 DO ~AddXpVar("Level_5_Easy",16072)
TakePartyItemNum("00potn03", 1)
UseItem("00potn03",Myself)
SetGlobal("30Enneli_Healed","GLOBAL", 2)~ JOURNAL #16067 GOTO 29
  IF ~  PartyHasItem("00potn05")
~ THEN REPLY #29042 DO ~AddXpVar("Level_5_Easy",16072)
TakePartyItemNum("00potn05", 1)
UseItem("00potn05",Myself)
SetGlobal("30Enneli_Healed","GLOBAL", 2)~ JOURNAL #16067 GOTO 29
  IF ~~ THEN REPLY #32041 GOTO 25
END

IF ~~ THEN BEGIN 24
  SAY #32042
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 25
  SAY #32043
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 26
  SAY #32256
  IF ~~ THEN REPLY #28197 GOTO 9
  IF ~~ THEN REPLY #32257 GOTO 25
END

IF WEIGHT #7 ~  Global("30Enneli_Healed","GLOBAL",2)
~ THEN BEGIN 27
  SAY #32258
  IF ~~ THEN REPLY #32259 GOTO 9
  IF ~~ THEN REPLY #30730 GOTO 25
END

IF ~~ THEN BEGIN 28
  SAY #32260
  IF ~~ THEN REPLY #16082 GOTO 2
  IF ~~ THEN REPLY #16084 GOTO 25
  IF ~~ THEN REPLY #32261 GOTO 24
END

IF ~~ THEN BEGIN 29
  SAY #32262
  IF ~~ THEN REPLY #28197 GOTO 9
  IF ~~ THEN REPLY #32263 GOTO 25
END

IF WEIGHT #3 ~  Global("31BugGut_Dead","GLOBAL",1)
Global("Fortress_Quest","GLOBAL",1)
!Global("30Enneli_Nodes","GLOBAL",1)
GlobalLT("30Enneli_BQuest","GLOBAL",2)
~ THEN BEGIN 30
  SAY #32264
  IF ~~ THEN DO ~SetGlobal("30Enneli_Nodes","GLOBAL", 1)~ JOURNAL #16069 GOTO 31
END

IF WEIGHT #4 ~  Global("31BugGut_Dead","GLOBAL",1)
Global("Fortress_Quest","GLOBAL",1)
Global("30Enneli_Nodes","GLOBAL",1)
GlobalLT("30Enneli_BQuest","GLOBAL",2)
!Global("USGUTHMA_FRIEND","GLOBAL",1)
~ THEN BEGIN 31
  SAY #32265
  IF ~  Global("30enneli_bquest","GLOBAL",0)
Global("31brasto_dead","GLOBAL",0)
~ THEN REPLY #32266 GOTO 14
  IF ~  !Global("31brasto_dead","GLOBAL",1)
~ THEN REPLY #32558 GOTO 25
  IF ~  !GlobalGT("30brasto_escape","GLOBAL",0)
Global("31brasto_dead","GLOBAL",1)
~ THEN REPLY #32559 GOTO 32
  IF ~  GlobalGT("30brasto_escape","GLOBAL",0)
GlobalLT("30brasto_escape","GLOBAL",4)
~ THEN REPLY #32562 GOTO 32
  IF ~  GlobalGT("30brasto_escape","GLOBAL",0)
GlobalLT("30brasto_escape","GLOBAL",4)
!Global("31brasto_dead","GLOBAL",1)
~ THEN REPLY #32563 GOTO 25
  IF ~  GlobalGT("30brasto_escape","GLOBAL",4)
Global("31brasto_dead","GLOBAL",1)
~ THEN REPLY #33201 GOTO 32
  IF ~  Global("30enneli_bquest","GLOBAL",1)
~ THEN REPLY #33416 GOTO 25
END

IF ~~ THEN BEGIN 32
  SAY #33417
  IF ~  !GlobalGT("30brasto_escape","GLOBAL",0)
Global("31brasto_dead","GLOBAL",1)
~ THEN REPLY #33418 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #33419 DO ~SetGlobal("30Enneli_Nodes","GLOBAL", 2)
SetGlobal("Braston_Ennelia_Leave", "GLOBAL", 1)~ EXIT
END

IF ~~ THEN BEGIN 33
  SAY #33420
  IF ~~ THEN REPLY #28197 GOTO 9
  IF ~~ THEN REPLY #33421 GOTO 25
END

IF WEIGHT #6 ~  Global("31BugGut_Dead","GLOBAL",1)
Global("Fortress_Quest","GLOBAL",1)
GlobalGT("30Enneli_BQuest","GLOBAL",1)
~ THEN BEGIN 34
  SAY #32264
  IF ~~ THEN JOURNAL #16069 GOTO 35
END

IF WEIGHT #5 ~  Global("Fortress_Quest","GLOBAL",1)
Global("30Enneli_Nodes","GLOBAL",1)
GlobalGT("30Enneli_BQuest","GLOBAL",1)
~ THEN BEGIN 35
  SAY #33422
  IF ~~ THEN REPLY #33475 DO ~AddXpVar("Level_6_Hard",16073)
SetGlobal("30Enneli_Nodes","GLOBAL", 2)
GiveItemCreate("RMIW_02", Protagonist, 1,1,0)
SetGlobal("Braston_Ennelia_Leave", "GLOBAL", 1)~ JOURNAL #16068 EXIT
END

IF WEIGHT #2 ~  Global("Braston_Ennelia_Leave","GLOBAL",1)
~ THEN BEGIN 36
  SAY #33476
  IF ~~ THEN EXIT
END

IF WEIGHT #0 ~Global("USGUTHMA_FRIEND","GLOBAL",1)
~ THEN BEGIN 37
  SAY @6018
  IF ~~ THEN REPLY @6019 GOTO 38
END

IF ~~ THEN BEGIN 38
  SAY @6028
  IF ~~ THEN REPLY @6020 GOTO 39
END

IF ~~ THEN BEGIN 39
  SAY @6021
  IF ~~ THEN REPLY @6022 GOTO 40
END

IF ~~ THEN BEGIN 40
  SAY @6023
  IF ~!Global("31brasto_dead", "GLOBAL", 1)~ THEN REPLY @6024 GOTO 41
  IF ~Global("31brasto_dead", "GLOBAL", 1)~ THEN REPLY @6025 GOTO 42
END

IF ~~ THEN BEGIN 41
  SAY @6026
  IF ~~ THEN REPLY #1487 DO ~SetGlobal("30Enneli_Nodes","GLOBAL", 2)
SetGlobal("Braston_Ennelia_Leave", "GLOBAL", 1)~ EXIT
END

IF ~~ THEN BEGIN 42
  SAY @6027
  IF ~~ THEN REPLY #1487 DO ~SetGlobal("30Enneli_Nodes","GLOBAL", 2)
SetGlobal("Braston_Ennelia_Leave", "GLOBAL", 1)~ EXIT
END
