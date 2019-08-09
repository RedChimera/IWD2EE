BEGIN ~10KICKSH~

IF WEIGHT #0 ~  Global("US_Geoffrey_Convinced_To_Join","GLOBAL",1)
~ THEN BEGIN KickshawBlankDialogue
  SAY ~Hello again, stranger.  I hope you enjoy running around doing chores for Shawford, but you'll excuse me if I prefer to stay right here.~
  IF ~~ THEN REPLY ~~ EXIT
END

IF WEIGHT #3 ~  NumberOfTimesTalkedTo(0)
Global("Know_Iron_Collar","GLOBAL",0)
Gender(Protagonist,MALE)
~ THEN BEGIN 0
  SAY #11524
  IF ~~ THEN DO ~FaceSavedLocation(Myself)~ EXTERN ~10BLACK~ 0
END

IF WEIGHT #4 ~  NumberOfTimesTalkedTo(0)
Global("Know_Iron_Collar","GLOBAL",0)
~ THEN BEGIN 1
  SAY #11524
  IF ~~ THEN DO ~FaceSavedLocation(Myself)~ EXTERN ~10BLACK~ 1
END

IF WEIGHT #2 ~  NumberOfTimesTalkedTo(0)
Global("Know_Iron_Collar","GLOBAL",0)
!Race(Protagonist,ELF)
!Race(Protagonist,HALF_ELF)
!Race(Protagonist,HALFORC)
!Race(Protagonist,HUMAN)
~ THEN BEGIN 2
  SAY #11524
  IF ~~ THEN DO ~FaceSavedLocation(Myself)~ EXTERN ~10BLACK~ 2
END

IF WEIGHT #5 ~  True()
~ THEN BEGIN 3
  SAY #11526
  IF ~~ THEN DO ~FaceSavedLocation(Myself)~ EXIT
END

IF ~~ THEN BEGIN 4
  SAY #11527
  IF ~~ THEN EXTERN ~10BLACK~ 3
END

IF ~~ THEN BEGIN 5
  SAY #11528
  IF ~~ THEN EXTERN ~10BLACK~ 3
END

IF ~~ THEN BEGIN 6
  SAY #11529
  IF ~~ THEN EXTERN ~10BLACK~ 3
END

IF ~~ THEN BEGIN 7
  SAY #11530
  IF ~~ THEN GOTO 8
END

IF ~~ THEN BEGIN 8
  SAY #11531
  IF ~~ THEN EXTERN ~10BLACK~ 6
END

IF ~~ THEN BEGIN 9
  SAY #11532
  IF ~~ THEN EXTERN ~10BLANC~ 5
END

IF ~~ THEN BEGIN 10
  SAY #11533
  IF ~~ THEN EXTERN ~10BLANC~ 7
END

IF ~~ THEN BEGIN 11
  SAY #11534
  IF ~~ THEN EXTERN ~10BLACK~ 11
END

IF ~~ THEN BEGIN 12
  SAY #11535
  IF ~~ THEN EXTERN ~10BLACK~ 12
END

IF ~~ THEN BEGIN 13
  SAY #11536
  IF ~~ THEN EXTERN ~10BLACK~ 15
END

IF ~~ THEN BEGIN 14
  SAY #11537
  IF ~~ THEN REPLY #11538 DO ~AddXpVar("Level_2_Easy",11523)
~ JOURNAL #11522 EXTERN ~10BLACK~ 18
  IF ~  CheckSkillGT(Protagonist,0,Diplomacy)
~ THEN REPLY #11539 EXTERN ~10BLANC~ 9
  IF ~  CheckSkillGT(Protagonist,0,Intimidate)
GlobalGT("Phaen_Loses_It","GLOBAL",0)
~ THEN REPLY #28156 EXTERN ~10BLACK~ 23
  IF ~~ THEN REPLY #37770 DO ~AddXpVar("Level_2_Easy",11523)
SetCreatureAreaFlag("Black_Geoffrey",NO_TALK,TRUE)SetCreatureAreaFlag("Blanchard",NO_TALK,TRUE)SetCreatureAreaFlag("Kickshaw",NO_TALK,TRUE)
Enemy()~ JOURNAL #37771 EXIT
END

IF ~~ THEN BEGIN 15
  SAY #11546
  IF ~~ THEN REPLY #11548 DO ~AddXpVar("Level_2_Easy",11523)
~ JOURNAL #11522 EXTERN ~10BLACK~ 18
  IF ~  CheckStatLT(Protagonist,12,CHR)
CheckStatLT(Protagonist,18,STR)
~ THEN REPLY #11549 GOTO 16
  IF ~  CheckStatLT(Protagonist,12,CHR)
CheckStatGT(Protagonist,17,STR)
~ THEN REPLY #11549 GOTO 16
  IF ~  CheckSkillGT(Protagonist,0,Diplomacy)
~ THEN REPLY #11550 GOTO 16
  IF ~  CheckSkillGT(Protagonist,0,Intimidate)
GlobalGT("Phaen_Loses_It","GLOBAL",0)
~ THEN REPLY #28155 EXTERN ~10BLACK~ 23
  IF ~~ THEN REPLY #37772 DO ~AddXpVar("Level_2_Easy",11523)
SetCreatureAreaFlag("Black_Geoffrey",NO_TALK,TRUE)SetCreatureAreaFlag("Blanchard",NO_TALK,TRUE)SetCreatureAreaFlag("Kickshaw",NO_TALK,TRUE)
Enemy()~ JOURNAL #37771 EXIT
END

IF ~~ THEN BEGIN 16
  SAY #11551
  IF ~~ THEN EXTERN ~10BLANC~ 10
END

IF WEIGHT #1 ~  Global("Palisade_Iron_Collar_Quest","GLOBAL",2)
~ THEN BEGIN 17
  SAY #11552
  IF ~~ THEN DO ~FaceSavedLocation(Myself)~ EXIT
END

IF ~~ THEN BEGIN 18
  SAY #28153
  IF ~~ THEN EXTERN ~10BLANC~ 13
END

IF ~~ THEN BEGIN 19
  SAY #28154
  IF ~~ THEN DO ~FaceSavedLocation(Myself)~ EXTERN ~10BLACK~ 24
END
