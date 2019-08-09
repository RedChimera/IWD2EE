BEGIN ~10REIG~

IF WEIGHT #5 ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY #12659
  IF ~  !SubRace(Protagonist,ELF_DROW)
~ THEN REPLY #12660 DO ~SetGlobal("Reig_Quest", "GLOBAL", 1)~ GOTO 1
  IF ~  !SubRace(Protagonist,ELF_DROW)
~ THEN REPLY #12661 DO ~SetGlobal("Reig_Quest", "GLOBAL", 1)~ GOTO 2
  IF ~  SubRace(Protagonist,ELF_DROW)
~ THEN REPLY #12660 DO ~SetGlobal("Reig_Quest", "GLOBAL", 1)~ EXTERN ~10JON~ 5
  IF ~  SubRace(Protagonist,ELF_DROW)
~ THEN REPLY #12661 DO ~SetGlobal("Reig_Quest", "GLOBAL", 1)~ EXTERN ~10JON~ 5
END

IF ~~ THEN BEGIN 1
  SAY #12674
  IF ~~ THEN REPLY #12675 GOTO 4
  IF ~~ THEN REPLY #12676 GOTO 9
  IF ~~ THEN REPLY #20745 GOTO 3
END

IF ~~ THEN BEGIN 2
  SAY #20747
  IF ~~ THEN REPLY #12675 DO ~SetGlobal("Know_Arm", "GLOBAL", 1)~ GOTO 4
  IF ~~ THEN REPLY #12676 DO ~SetGlobal("Know_Arm", "GLOBAL", 1)~ GOTO 9
END

IF ~~ THEN BEGIN 3
  SAY #20748
  IF ~~ THEN REPLY #12675 DO ~SetGlobal("Know_Arm", "GLOBAL", 1)~ GOTO 4
  IF ~~ THEN REPLY #12676 DO ~SetGlobal("Know_Arm", "GLOBAL", 1)~ GOTO 9
END

IF ~~ THEN BEGIN 4
  SAY #20749
  IF ~~ THEN DO ~SetCriticalPathObject("Reig",FALSE)~ EXTERN ~10JON~ 2
END

IF ~~ THEN BEGIN 5
  SAY #20751
  IF ~~ THEN DO ~GiveItemCreate("00Swds01", Protagonist, 0, 0, 0)~ GOTO 6
END

IF ~~ THEN BEGIN 6
  SAY #20752
  IF ~  CheckSkillGT(Protagonist,0,Diplomacy)
~ THEN REPLY #20753 DO ~GiveItem("00Leat01", Protagonist)~ GOTO 22
  IF ~  CheckSkillLT(Protagonist,1,Diplomacy)
CheckStatGT(Protagonist,11,INT)
~ THEN REPLY #20753 DO ~GiveItem("00Leat01", Protagonist)~ GOTO 22
  IF ~  Global("Know_Goblin_Reig","GLOBAL",0)
~ THEN REPLY #20754 GOTO 7
  IF ~  Global("Know_Arm","GLOBAL",0)
~ THEN REPLY #20745 GOTO 11
  IF ~  Global("Know_Arm","GLOBAL",1)
~ THEN REPLY #20755 GOTO 12
END

IF ~~ THEN BEGIN 7
  SAY #20756
  IF ~~ THEN GOTO 8
END

IF ~~ THEN BEGIN 8
  SAY #20757
  IF ~~ THEN REPLY #20745 GOTO 11
END

IF ~~ THEN BEGIN 9
  SAY #20756
  IF ~~ THEN GOTO 10
END

IF ~~ THEN BEGIN 10
  SAY #20758
  IF ~~ THEN REPLY #12675 DO ~SetGlobal("Know_Goblin_Reig", "GLOBAL", 1)~ GOTO 4
END

IF ~~ THEN BEGIN 11
  SAY #20760
  IF ~~ THEN REPLY #20755 JOURNAL #1476 GOTO 12
END

IF ~~ THEN BEGIN 12
  SAY #20761
  IF ~  Kit(Protagonist,CLERIC_ILMATER)
~ THEN REPLY #38715 GOTO 14
  IF ~  Kit(Protagonist,CLERIC_LATHANDER)
~ THEN REPLY #38716 GOTO 14
  IF ~  Kit(Protagonist,CLERIC_SELUNE)
~ THEN REPLY #38717 GOTO 14
  IF ~  Kit(Protagonist,CLERIC_HELM)
~ THEN REPLY #38719 GOTO 14
  IF ~  Kit(Protagonist,CLERIC_OGHMA)
~ THEN REPLY #38720 GOTO 14
  IF ~  Kit(Protagonist,CLERIC_TEMPUS)
~ THEN REPLY #38722 GOTO 14
  IF ~  Kit(Protagonist,CLERIC_BANE)
~ THEN REPLY #38723 GOTO 14
  IF ~  Kit(Protagonist,CLERIC_MASK)
~ THEN REPLY #38724 GOTO 14
  IF ~  Kit(Protagonist,CLERIC_TALOS)
~ THEN REPLY #38725 GOTO 14
  IF ~  ClassEx(Protagonist,DRUID)
~ THEN REPLY #20765 GOTO 14
  IF ~  ClassEx(Protagonist,PALADIN)
~ THEN REPLY #20766 GOTO 14
  IF ~  PartyHasItem("00Potn04")
~ THEN REPLY #20767 DO ~AddXpVar("Level_1_Average",1484)
TakePartyItemNum("00Potn04", 1)
DestroyItem("00Potn04")
SetGlobal("Reig_Quest", "GLOBAL", 2)~ JOURNAL #1477 GOTO 18
  IF ~~ THEN REPLY #20768 GOTO 13
END

IF ~~ THEN BEGIN 13
  SAY #20813
  IF ~~ THEN REPLY #20815 EXIT
END

IF ~~ THEN BEGIN 14
  SAY #20816
  IF ~  !Alignment(Protagonist,MASK_EVIL)
~ THEN REPLY #20817 EXIT
  IF ~  Alignment(Protagonist,MASK_EVIL)
~ THEN REPLY #20818 EXIT
END

IF WEIGHT #4 ~  Global("Reig_Quest","GLOBAL",1)
~ THEN BEGIN 15
  SAY #20819
  IF ~  Kit(Protagonist,CLERIC_ILMATER)
~ THEN REPLY #38726 GOTO 14
  IF ~  Kit(Protagonist,CLERIC_LATHANDER)
~ THEN REPLY #38727 GOTO 14
  IF ~  Kit(Protagonist,CLERIC_SELUNE)
~ THEN REPLY #38728 GOTO 14
  IF ~  Kit(Protagonist,CLERIC_HELM)
~ THEN REPLY #38729 GOTO 14
  IF ~  Kit(Protagonist,CLERIC_OGHMA)
~ THEN REPLY #38730 GOTO 14
  IF ~  Kit(Protagonist,CLERIC_TEMPUS)
~ THEN REPLY #38731 GOTO 14
  IF ~  Kit(Protagonist,CLERIC_BANE)
~ THEN REPLY #38732 GOTO 14
  IF ~  Kit(Protagonist,CLERIC_MASK)
~ THEN REPLY #38733 GOTO 14
  IF ~  Kit(Protagonist,CLERIC_TALOS)
~ THEN REPLY #38734 GOTO 14
  IF ~  ClassEx(Protagonist,DRUID)
~ THEN REPLY #20821 GOTO 14
  IF ~  ClassEx(Protagonist,PALADIN)
~ THEN REPLY #20766 GOTO 14
  IF ~  PartyHasItem("00Potn04")
~ THEN REPLY #20823 DO ~AddXpVar("Level_1_Average",1484)
TakePartyItemNum("00Potn04", 1)
DestroyItem("00Potn04")
SetGlobal("Reig_Quest", "GLOBAL", 2)~ JOURNAL #1477 GOTO 18
  IF ~~ THEN REPLY #20831 GOTO 27
  IF ~~ THEN REPLY #20832 EXIT
END

IF WEIGHT #2 ~  HPGT(Myself,3)
Global("Reig_Quest","GLOBAL",1)
Global("Reig_Heal_Priest","GLOBAL",0)
~ THEN BEGIN 16
  SAY #20833
  IF ~  Global("Reig_Heal_Priest","GLOBAL",0)
~ THEN REPLY #20834 DO ~AddXpVar("Level_1_Easy",1483)
SetGlobal("Reig_Heal_Priest", "GLOBAL", 1)~ JOURNAL #1478 GOTO 17
  IF ~  Global("Reig_Heal_Priest","GLOBAL",1)
~ THEN REPLY #20834 DO ~AddXpVar("Level_1_Easy",1483)
~ JOURNAL #1478 GOTO 17
END

IF WEIGHT #3 ~  Global("Reig_Quest","GLOBAL",1)
Global("Reig_Heal_Priest","GLOBAL",1)
~ THEN BEGIN 17
  SAY #20835
  IF ~  PartyHasItem("00Potn04")
~ THEN REPLY #20823 DO ~AddXpVar("Level_1_Average",1484)
TakePartyItemNum("00Potn04", 1)
DestroyItem("00Potn04")
SetGlobal("Reig_Quest", "GLOBAL", 2)~ JOURNAL #1477 GOTO 18
  IF ~~ THEN REPLY #20831 GOTO 27
  IF ~~ THEN REPLY #20817 EXIT
END

IF ~~ THEN BEGIN 18
  SAY #20837
  IF ~~ THEN GOTO 19
END

IF WEIGHT #1 ~  Global("Reig_Quest","GLOBAL",2)
~ THEN BEGIN 19
  SAY #20838
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",0)
~ THEN REPLY #20831 GOTO 27
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",0)
~ THEN REPLY #20839 EXIT
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
~ THEN REPLY #20840 DO ~SetGlobal("Told_Reig", "GLOBAL", 1)~ JOURNAL #1479 GOTO 20
  IF ~!NumInParty(6)~ THEN REPLY ~We could use an extra hand, if your arm is all right.~ GOTO ReigJoinPartyGoblinsAlive
END

IF ~~ THEN BEGIN 20
  SAY #20867
  IF ~~ THEN REPLY #20887 EXIT
  IF ~!NumInParty(6)~ THEN REPLY ~Why not come with us?  We'll treat you to an ale -- if you hadn't warned us about the goblins, we might have gotten take by surprise.~ GOTO ReigJoinPartyGoblinsDead
END

IF WEIGHT #0 ~  Global("Told_Reig","GLOBAL",1)
~ THEN BEGIN 21
  SAY #20910
  IF ~~ THEN REPLY #20887 EXIT
END

IF ~~ THEN BEGIN 22
  SAY #20938
  IF ~  CheckSkillGT(Protagonist,2,Intimidate)
!Alignment(Protagonist,MASK_GOOD)
~ THEN REPLY #20956 GOTO 23
  IF ~  CheckSkillLT(Protagonist,3,Intimidate)
CheckStatGT(Protagonist,14,INT)
!Alignment(Protagonist,MASK_GOOD)
~ THEN REPLY #20956 GOTO 23
  IF ~  CheckSkillGT(Protagonist,2,Diplomacy)
!Alignment(Protagonist,MASK_EVIL)
~ THEN REPLY #21168 DO ~GiveItemCreate("00Leat01", Protagonist, 0, 0, 0)
GiveItemCreate("00Helm01", Protagonist, 0, 0, 0)
GiveItemCreate("00Dagg01", Protagonist, 0, 0, 0)
GiveItemCreate("00ax1h11", Protagonist, 0, 0, 0)~ GOTO 24
  IF ~  CheckSkillLT(Protagonist,3,Diplomacy)
CheckStatGT(Protagonist,14,INT)
!Alignment(Protagonist,MASK_EVIL)
~ THEN REPLY #21192 DO ~GiveItemCreate("00Leat01", Protagonist, 0, 0, 0)
GiveItemCreate("00Helm01", Protagonist, 0, 0, 0)
GiveItemCreate("00Dagg01", Protagonist, 0, 0, 0)
GiveItemCreate("00ax1h11", Protagonist, 0, 0, 0)~ GOTO 24
  IF ~~ THEN REPLY #21294 GOTO 7
  IF ~~ THEN REPLY #21295 GOTO 11
END

IF ~~ THEN BEGIN 23
  SAY #21296
  IF ~~ THEN REPLY #21297 DO ~GiveItemCreate("00Leat01", Protagonist, 0, 0, 0)
GiveItemCreate("00Helm01", Protagonist, 0, 0, 0)
GiveItemCreate("00Dagg01", Protagonist, 0, 0, 0)
GiveItemCreate("00ax1h11", Protagonist, 0, 0, 0)~ GOTO 24
END

IF ~~ THEN BEGIN 24
  SAY #21306
  IF ~~ THEN REPLY #21307 GOTO 7
  IF ~~ THEN REPLY #21309 GOTO 11
END

IF ~~ THEN BEGIN 25
  SAY #21315
  IF ~~ THEN GOTO 26
END

IF ~~ THEN BEGIN 26
  SAY #24046
  IF ~~ THEN REPLY #27907 GOTO 1
  IF ~~ THEN REPLY #27908 GOTO 2
END

IF ~~ THEN BEGIN 27
  SAY #27909
  IF ~~ THEN REPLY #27910 DO ~JoinParty()~ EXIT
END

IF ~~ THEN BEGIN ReigJoinPartyGoblinsAlive
  SAY ~Yes, I think I can fight.  I lost my spear, but at least I can move my arm again.  If we manage to put down those damn goblins, we should go report to Ulbrec in town.~
  IF ~~ THEN REPLY ~Very well.  Let's get moving.~ GOTO ReigJoinPartyGoblinsAlive2
END

IF ~~ THEN BEGIN ReigJoinPartyGoblinsAlive2
  SAY ~Keep an eye out for goblin archers if you don't want to end up like Brohn.  Stay close and stay quiet... The goblins have the advantage of numbers, and we can't afford to get surrounded.~
  IF ~~ THEN REPLY ~~ DO ~JoinParty()
SetGlobal("US_Reig_Joined", "GLOBAL", 1)~ EXIT
END

IF ~~ THEN BEGIN ReigJoinPartyGoblinsDead
  SAY ~My thanks, but the ale can wait.  Let's report to Ulbrec.  He needs to know what happened here.~
  IF ~~ THEN REPLY ~~ DO ~JoinParty()
SetGlobal("US_Reig_Joined", "GLOBAL", 1)~ EXIT
END
