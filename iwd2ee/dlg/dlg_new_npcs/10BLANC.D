BEGIN ~10BLANC~

IF WEIGHT #0 ~  Global("US_Geoffrey_Convinced_To_Join","GLOBAL",1)
~ THEN BEGIN BlanchardPikeBlankDialogue
  SAY ~Go bother someone else, stranger.  I've got more interesting people to talk to -- like myself, or better yet, nobody.~
  IF ~~ THEN EXIT
END

IF WEIGHT #3 ~  NumberOfTimesTalkedTo(0)
Global("Know_Iron_Collar","GLOBAL",0)
Gender(Protagonist,MALE)
~ THEN BEGIN 0
  SAY #11504
  IF ~~ THEN DO ~FaceSavedLocation(Myself)~ EXTERN ~10BLACK~ 0
END

IF WEIGHT #4 ~  NumberOfTimesTalkedTo(0)
Global("Know_Iron_Collar","GLOBAL",0)
~ THEN BEGIN 1
  SAY #11504
  IF ~~ THEN DO ~FaceSavedLocation(Myself)~ EXTERN ~10BLACK~ 1
END

IF WEIGHT #2 ~  NumberOfTimesTalkedTo(0)
Global("Know_Iron_Collar","GLOBAL",0)
!Race(Protagonist,ELF)
!Race(Protagonist,HALF_ELF)
!Race(Protagonist,HALFORC)
!Race(Protagonist,HUMAN)
~ THEN BEGIN 2
  SAY #11504
  IF ~~ THEN DO ~FaceSavedLocation(Myself)~ EXTERN ~10BLACK~ 2
END

IF WEIGHT #5 ~  True()
~ THEN BEGIN 3
  SAY #11506
  IF ~~ THEN DO ~FaceSavedLocation(Myself)~ EXIT
END

IF ~~ THEN BEGIN 4
  SAY #11507
  IF ~~ THEN DO ~SetGlobal("Know_Iron_Collar", "GLOBAL", 1)~ EXTERN ~10KICKSH~ 7
END

IF ~~ THEN BEGIN 5
  SAY #11508
  IF ~~ THEN DO ~FaceSavedLocation(Myself)~ EXIT
END

IF ~~ THEN BEGIN 6
  SAY #11509
  IF ~~ THEN EXTERN ~10BLACK~ 9
END

IF ~~ THEN BEGIN 7
  SAY #11510
  IF ~  Global("Palisade_Iron_Collar_Quest","GLOBAL",1)
~ THEN REPLY #11511 EXTERN ~10BLACK~ 14
  IF ~  Global("Iron_Collar_Quest","GLOBAL",1)
Global("Brogan_Quest","GLOBAL",0)
Global("Dock_Goblin_Quest","GLOBAL",0)
~ THEN REPLY #11512 EXTERN ~10BLACK~ 7
  IF ~~ THEN REPLY #11513 EXTERN ~10BLACK~ 10
  IF ~~ THEN REPLY #11514 DO ~FaceSavedLocation(Myself)~ EXIT
END

IF ~~ THEN BEGIN 8
  SAY #11515
  IF ~~ THEN REPLY #11516 DO ~AddXpVar("Level_2_Easy",11503)
~ JOURNAL #1548 EXTERN ~10BLACK~ 18
  IF ~  CheckSkillGT(Protagonist,0,Diplomacy)
~ THEN REPLY #11517 EXTERN ~10BLACK~ 17
  IF ~  CheckSkillGT(Protagonist,0,Intimidate)
GlobalGT("Phaen_Loses_It","GLOBAL",0)
~ THEN REPLY #28159 EXTERN ~10BLACK~ 23
  IF ~~ THEN REPLY #28318 DO ~AddXpVar("Level_2_Easy",11503)
SetCreatureAreaFlag("Black_Geoffrey",NO_TALK,TRUE)SetCreatureAreaFlag("Blanchard",NO_TALK,TRUE)SetCreatureAreaFlag("Kickshaw",NO_TALK,TRUE)
Enemy()~ JOURNAL #37697 EXIT
END

IF ~~ THEN BEGIN 9
  SAY #11518
  IF ~~ THEN EXTERN ~10KICKSH~ 15
END

IF ~~ THEN BEGIN 10
  SAY #11519
  IF ~~ THEN EXTERN ~10BLACK~ 19
END

IF ~~ THEN BEGIN 11
  SAY #11520
  IF ~~ THEN EXTERN ~10BLACK~ 20
END

IF WEIGHT #1 ~  Global("Palisade_Iron_Collar_Quest","GLOBAL",2)
~ THEN BEGIN 12
  SAY #11521
  IF ~~ THEN DO ~FaceSavedLocation(Myself)~ EXIT
END

IF ~~ THEN BEGIN 13
  SAY #28157
  IF ~~ THEN REPLY #28158 DO ~FaceSavedLocation(Myself)~ EXTERN ~10KICKSH~ 19
END
