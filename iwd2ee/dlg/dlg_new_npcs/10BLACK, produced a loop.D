BEGIN ~10BLACK~

IF WEIGHT #2 ~  NumberOfTimesTalkedTo(0)
Global("Know_Iron_Collar","GLOBAL",0)
Gender(Protagonist,MALE)
~ THEN BEGIN 0
  SAY #1508
  IF ~~ THEN EXTERN ~10KICKSH~ 4
END

IF WEIGHT #3 ~  NumberOfTimesTalkedTo(0)
Global("Know_Iron_Collar","GLOBAL",0)
~ THEN BEGIN 1
  SAY #1508
  IF ~~ THEN EXTERN ~10KICKSH~ 5
END

IF WEIGHT #1 ~  NumberOfTimesTalkedTo(0)
Global("Know_Iron_Collar","GLOBAL",0)
!Race(Protagonist,ELF)
!Race(Protagonist,HALF_ELF)
!Race(Protagonist,HALFORC)
!Race(Protagonist,HUMAN)
~ THEN BEGIN 2
  SAY #1508
  IF ~~ THEN EXTERN ~10KICKSH~ 6
END

IF ~~ THEN BEGIN 3
  SAY #1511
  IF ~  Global("Palisade_Iron_Collar_Quest","GLOBAL",1)
Global("Know_Iron_Collar","GLOBAL",0)
~ THEN REPLY #1512 GOTO 14
  IF ~  Global("Palisade_Iron_Collar_Quest","GLOBAL",1)
Global("Know_Iron_Collar","GLOBAL",1)
~ THEN REPLY #28027 GOTO 14
  IF ~  Global("Iron_Collar_Quest","GLOBAL",1)
Global("Brogan_Quest","GLOBAL",0)
Global("Dock_Goblin_Quest","GLOBAL",0)
~ THEN REPLY #1513 GOTO 4
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",0)
~ THEN REPLY #1514 GOTO 4
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
~ THEN REPLY #1515 GOTO 4
  IF ~~ THEN REPLY #1516 GOTO 5
END

IF ~~ THEN BEGIN 4
  SAY #1517
  IF ~~ THEN EXTERN ~10BLANC~ 4
END

IF ~~ THEN BEGIN 5
  SAY #1518
  IF ~~ THEN EXTERN ~10BLANC~ 4
END

IF ~~ THEN BEGIN 6
  SAY #1519
  IF ~  Global("Palisade_Iron_Collar_Quest","GLOBAL",1)
~ THEN REPLY #1520 GOTO 14
  IF ~  Global("Iron_Collar_Quest","GLOBAL",1)
Global("Brogan_Quest","GLOBAL",0)
Global("Dock_Goblin_Quest","GLOBAL",0)
~ THEN REPLY #1521 GOTO 7
  IF ~~ THEN REPLY #1522 GOTO 8
  IF ~~ THEN REPLY #1523 EXTERN ~10KICKSH~ 12
  IF ~~ THEN REPLY #1524 DO ~FaceSavedLocation(Myself)~ EXIT
END

IF ~~ THEN BEGIN 7
  SAY #1525
  IF ~~ THEN DO ~SetGlobal("Iron_Collar_Quest", "GLOBAL", 2)~ EXTERN ~10KICKSH~ 9
END

IF ~~ THEN BEGIN 8
  SAY #1526
  IF ~~ THEN EXTERN ~10BLANC~ 6
END

IF ~~ THEN BEGIN 9
  SAY #1527
  IF ~  Global("Palisade_Iron_Collar_Quest","GLOBAL",1)
~ THEN REPLY #1520 GOTO 14
  IF ~  Global("Iron_Collar_Quest","GLOBAL",1)
Global("Brogan_Quest","GLOBAL",0)
Global("Dock_Goblin_Quest","GLOBAL",0)
~ THEN REPLY #1521 GOTO 7
  IF ~~ THEN REPLY #1529 DO ~SetGlobal("Know_Phaen_Cormyr", "GLOBAL", 1)~ JOURNAL #1505 EXTERN ~10KICKSH~ 10
  IF ~~ THEN REPLY #1530 DO ~FaceSavedLocation(Myself)~ EXIT
END

IF ~~ THEN BEGIN 10
  SAY #1531
  IF ~~ THEN EXTERN ~10KICKSH~ 11
END

IF ~~ THEN BEGIN 11
  SAY #1532
  IF ~  Global("Palisade_Iron_Collar_Quest","GLOBAL",1)
~ THEN REPLY #1520 GOTO 14
  IF ~  Global("Iron_Collar_Quest","GLOBAL",1)
Global("Brogan_Quest","GLOBAL",0)
Global("Dock_Goblin_Quest","GLOBAL",0)
~ THEN REPLY #1521 GOTO 7
  IF ~~ THEN REPLY #1530 DO ~FaceSavedLocation(Myself)~ EXIT
END

IF ~~ THEN BEGIN 12
  SAY #1533
  IF ~  Global("Palisade_Iron_Collar_Quest","GLOBAL",1)
~ THEN REPLY #1520 GOTO 14
  IF ~  Global("Iron_Collar_Quest","GLOBAL",1)
Global("Brogan_Quest","GLOBAL",0)
Global("Dock_Goblin_Quest","GLOBAL",0)
~ THEN REPLY #1521 GOTO 7
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",0)
~ THEN REPLY #1514 GOTO 4
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
~ THEN REPLY #1515 GOTO 4
  IF ~~ THEN REPLY #1522 GOTO 8
  IF ~~ THEN REPLY #1530 DO ~FaceSavedLocation(Myself)~ EXIT
END

IF WEIGHT #4 ~  True()
~ THEN BEGIN 13
  SAY #1534
  IF ~  Global("Palisade_Iron_Collar_Quest","GLOBAL",1)
Global("Know_Iron_Collar","GLOBAL",0)
~ THEN REPLY #1512 GOTO 14
  IF ~  Global("Palisade_Iron_Collar_Quest","GLOBAL",1)
Global("Know_Iron_Collar","GLOBAL",1)
~ THEN REPLY #28028 GOTO 14
  IF ~  Global("Iron_Collar_Quest","GLOBAL",1)
Global("Brogan_Quest","GLOBAL",0)
Global("Dock_Goblin_Quest","GLOBAL",0)
~ THEN REPLY #1521 GOTO 7
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",0)
~ THEN REPLY #1514 GOTO 4
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
~ THEN REPLY #1515 GOTO 4
  IF ~~ THEN REPLY #1522 GOTO 8
  IF ~~ THEN REPLY #1523 EXTERN ~10KICKSH~ 12
  IF ~~ THEN REPLY #1530 DO ~FaceSavedLocation(Myself)~ EXIT
END

IF ~~ THEN BEGIN 14
  SAY #1535
  IF ~~ THEN EXTERN ~10KICKSH~ 13
END

IF ~~ THEN BEGIN 15
  SAY #1536
  IF ~~ THEN GOTO 16
END

IF ~~ THEN BEGIN 16
  SAY #1537
  IF ~~ THEN EXTERN ~10BLANC~ 8
END

IF ~~ THEN BEGIN 17
  SAY #1539
  IF ~~ THEN REPLY #1540 GOTO 18
  IF ~  CheckSkillGT(Protagonist,0,Diplomacy)
~ THEN REPLY #1541 EXTERN ~10KICKSH~ 14
  IF ~  CheckSkillGT(Protagonist,0,Intimidate)
GlobalGT("Phaen_Loses_It","GLOBAL",0)
~ THEN REPLY #28152 GOTO 23
  IF ~~ THEN REPLY #28313 DO ~AddXpVar("Level_2_Easy",11503)
SetCreatureAreaFlag("Black_Geoffrey",NO_TALK,TRUE)SetCreatureAreaFlag("Blanchard",NO_TALK,TRUE)SetCreatureAreaFlag("Kickshaw",NO_TALK,TRUE)
Enemy()~ JOURNAL #37697 EXIT
END

IF ~~ THEN BEGIN 18
  SAY #1542
  IF ~~ THEN DO ~SetCreatureAreaFlag("Black_Geoffrey",NO_TALK,TRUE)SetCreatureAreaFlag("Blanchard",NO_TALK,TRUE)SetCreatureAreaFlag("Kickshaw",NO_TALK,TRUE)
Enemy()~ EXIT
END

IF ~~ THEN BEGIN 19
  SAY #1543
  IF ~~ THEN EXTERN ~10BLANC~ 11
END

IF ~~ THEN BEGIN 20
  SAY #1544
  IF ~~ THEN DO ~AddXpVar("Level_2_Average",1507)
~ JOURNAL #1506 GOTO 21
END

IF ~~ THEN BEGIN 21
  SAY #1545
  IF ~~ THEN REPLY #1546 DO ~SetGlobal("Palisade_Iron_Collar_Quest", "GLOBAL", 2)
FaceSavedLocation(Myself)~ EXIT
  IF ~!NumInParty(6)~ THEN REPLY ~That's not good enough.  Shawford won't be satisfied unless he sees at least one of you in person.  Follow us up to the palisade.~ DO ~SetGlobal("Palisade_Iron_Collar_Quest", "GLOBAL", 2)
FaceSavedLocation(Myself)~ GOTO GeoffreyJoinParty1
END

IF WEIGHT #0 ~  Global("Palisade_Iron_Collar_Quest","GLOBAL",2)
~ THEN BEGIN 22
  SAY #1547
  IF ~~ THEN REPLY #1546 DO ~FaceSavedLocation(Myself)~ EXIT
END

IF ~~ THEN BEGIN 23
  SAY #28146
  IF ~~ THEN REPLY #28160 EXTERN ~10KICKSH~ 18
END

IF ~~ THEN BEGIN 24
  SAY #28147
  IF ~~ THEN REPLY #28150 DO ~AddXpVar("Level_2_Average",1507)~ JOURNAL #28151 GOTO 25
END

IF ~~ THEN BEGIN 25
  SAY #28148
  IF ~~ THEN REPLY #28149 DO ~SetGlobal("Palisade_Iron_Collar_Quest", "GLOBAL", 2)FaceSavedLocation(Myself)~ EXIT
END

IF ~~ THEN BEGIN GeoffreyJoinParty1
  SAY ~By the *hells* -- Fine!  Let's just get this over with.~
  IF ~~ THEN REPLY ~That's the spirit!~ DO ~JoinParty()
SetGlobal("US_Geoffrey_Convinced_To_Join","GLOBAL",1)
  IF ~~ THEN REPLY ~Good. We need all the men we can get.~ DO ~JoinParty()
SetGlobal("US_Geoffrey_Convinced_To_Join","GLOBAL",1)
END