BEGIN ~41XHAAN~

IF WEIGHT #0 ~Global("US_Xhaan_Promise","GLOBAL",1)
Global("US_Xhaan_Promise_Join","GLOBAL",1)~ THEN BEGIN XhaanJoin1
  SAY @40104
  IF ~!NumInParty(6)~ THEN REPLY @40105 DO ~SetGlobal("US_Xhaan_Joined", "GLOBAL", 1)
ApplySpellRES("USXHAAC",Myself)~ EXIT
  IF ~NumInParty(6)~ THEN REPLY @40106 GOTO XhaanJoin1Refuse
END

IF ~~ THEN BEGIN XhaanJoin1Refuse
  SAY @40107
  IF ~~ THEN REPLY @40108 EXIT
END

IF ~~ THEN BEGIN XhaanAsk1
  SAY @40109
  IF ~!NumInParty(6)~ THEN REPLY @40110 DO ~SetGlobal("US_Xhaan_Promise_Join","GLOBAL",1)~ GOTO XhaanAskJoin
  IF ~~ THEN REPLY @40111 GOTO XhaanAskGold
  IF ~~ THEN REPLY @40112 GOTO XhaanAskXP
END

IF ~~ THEN BEGIN XhaanAskJoin
  SAY @40113
  IF ~GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
~ THEN REPLY @40114 GOTO XhaanJoin1
  IF ~~ THEN REPLY @40115 DO ~SetGlobal("US_Xhaan_Promise","GLOBAL",1)~ EXIT
END

IF ~~ THEN BEGIN XhaanAskGold
  SAY @40116
  IF ~GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
~ THEN REPLY @40114 GOTO XhaanTrick1
  IF ~~ THEN REPLY @40115 DO ~SetGlobal("US_Xhaan_Promise","GLOBAL",1)~ EXIT
END

IF ~~ THEN BEGIN XhaanAskXP
  SAY @40117
  IF ~GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
~ THEN REPLY @40114 GOTO XhaanTrick1
  IF ~~ THEN REPLY @40115 DO ~SetGlobal("US_Xhaan_Promise","GLOBAL",1)~ EXIT
END

IF ~~ THEN BEGIN XhaanTrick1
  SAY #33359
  IF ~~ THEN REPLY @40118 GOTO XhaanTrick2
END

IF ~~ THEN BEGIN XhaanTrick2
  SAY @40119
  IF ~~ THEN REPLY @40120 DO ~AddXpVar("Level_8_Hard",31586)
SetGlobal("41XhaanMindQuest", "GLOBAL", 4)
Enemy()~ EXIT
  IF ~~ THEN REPLY @40121 DO ~AddXpVar("Level_8_Hard",31586)
SetGlobal("41XhaanMindQuest", "GLOBAL", 3)~ EXIT
END


IF WEIGHT #3 ~  Global("CagedFury_dead","GLOBAL",0)
Or(6)
HPPercentLT(Player1,100)
HPPercentLT(Player2,100)
HPPercentLT(Player3,100)
HPPercentLT(Player4,100)
HPPercentLT(Player5,100)
HPPercentLT(Player6,100)
~ THEN BEGIN 0
  SAY #31587
  IF ~~ THEN REPLY #33301 GOTO 1
  IF ~~ THEN REPLY #33302 GOTO 4
  IF ~  Global("41XhaanPlayerKnowsLock","GLOBAL",1)
OpenState("AR4101_Door13",FALSE)
OpenState("AR4101_Door14",FALSE)
OpenState("AR4101_Door15",FALSE)
~ THEN REPLY #33303 DO ~SetGlobal("41PlayerSawDais", "GLOBAL", 1)~ JOURNAL #33680 GOTO 13
  IF ~  Or(3)
CheckStatGT(Protagonist,12,INT)
SubRace(Protagonist,HUMAN_TIEFLING)
SubRace(Protagonist,HUMAN_AASIMAR)
~ THEN REPLY #33304 GOTO 5
  IF ~  CheckStatLT(Protagonist,13,INT)
!SubRace(Protagonist,HUMAN_TIEFLING)
!SubRace(Protagonist,HUMAN_AASIMAR)
~ THEN REPLY #33305 GOTO 5
  IF ~  ClassEx(Protagonist,PALADIN)
~ THEN REPLY #33306 GOTO 5
  IF ~~ THEN REPLY #33317 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #33319 EXIT
END

IF ~~ THEN BEGIN 1
  SAY #33321
  IF ~  !Global("41XhaanMindQuest","GLOBAL",0)
~ THEN REPLY #33322 GOTO 2
  IF ~  Global("41XhaanMindQuest","GLOBAL",0)
~ THEN REPLY #33323 DO ~SetGlobal("41XhaanGaveName", "GLOBAL", 1)
SetGlobal("41XhaanMindQuest", "GLOBAL", 1)~ GOTO 2
  IF ~~ THEN REPLY #33324 GOTO 6
  IF ~~ THEN REPLY #33327 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #33319 EXIT
END

IF ~~ THEN BEGIN 2
  SAY #33328
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
!Global("US_Xhaan_Promise","GLOBAL",1)
~ THEN REPLY #33329 DO ~AddXpVar("Level_8_Hard",31586)
SetGlobal("41XhaanMindQuest", "GLOBAL", 3)~ JOURNAL #31585 GOTO 9
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
Global("US_Xhaan_Promise","GLOBAL",1)
Global("US_Xhaan_Promise_Join","GLOBAL",1)
~ THEN REPLY @40102 GOTO XhaanJoin1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
Global("US_Xhaan_Promise","GLOBAL",1)
!Global("US_Xhaan_Promise_Join","GLOBAL",1)
~ THEN REPLY @40102 GOTO XhaanTrick1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
!ClassEx(Protagonist,PALADIN)
!Global("US_Xhaan_Promise","GLOBAL",1)
Or(2)
CheckStatGT(Protagonist,15,INT)
CheckSkillGT(Protagonist,8,Diplomacy)
~ THEN REPLY @40101 GOTO XhaanAsk1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",2)
!Global("CagedFury_dead","GLOBAL",1)
~ THEN REPLY #33330 DO ~SetGlobal("41XhaanMindQuest", "GLOBAL", 2)~ JOURNAL #31584 GOTO 7
  IF ~  Or(2)
CheckStatGT(Protagonist,16,INT)
Kit(Protagonist,CLERIC_TALOS)
~ THEN REPLY #33331 DO ~SetGlobal("41PlayerKnowsTempestName", "GLOBAL", 1)~ GOTO 12
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",2)
!SubRace(Protagonist,HUMAN_AASIMAR)
~ THEN REPLY #33332 GOTO 3
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",2)
SubRace(Protagonist,HUMAN_AASIMAR)
~ THEN REPLY #37959 GOTO 15
  IF ~~ THEN REPLY #33333 GOTO 6
  IF ~~ THEN REPLY #33334 EXIT
END

IF ~~ THEN BEGIN 3
  SAY #33335
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
!Global("US_Xhaan_Promise","GLOBAL",1)
~ THEN REPLY #33329 DO ~AddXpVar("Level_8_Hard",31586)
SetGlobal("41XhaanMindQuest", "GLOBAL", 3)~ JOURNAL #31585 GOTO 9
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
Global("US_Xhaan_Promise","GLOBAL",1)
Global("US_Xhaan_Promise_Join","GLOBAL",1)
~ THEN REPLY @40102 GOTO XhaanJoin1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
Global("US_Xhaan_Promise","GLOBAL",1)
!Global("US_Xhaan_Promise_Join","GLOBAL",1)
~ THEN REPLY @40102 GOTO XhaanTrick1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
!ClassEx(Protagonist,PALADIN)
!Global("US_Xhaan_Promise","GLOBAL",1)
Or(2)
CheckStatGT(Protagonist,15,INT)
CheckSkillGT(Protagonist,8,Diplomacy)
~ THEN REPLY @40101 GOTO XhaanAsk1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",2)
!Global("CagedFury_dead","GLOBAL",1)
~ THEN REPLY #33336 DO ~SetGlobal("41XhaanMindQuest", "GLOBAL", 2)~ JOURNAL #31584 GOTO 7
  IF ~~ THEN REPLY #33302 GOTO 4
  IF ~~ THEN REPLY #33334 EXIT
END

IF ~~ THEN BEGIN 4
  SAY #33337
  IF ~  !Global("41XhaanMindQuest","GLOBAL",0)
~ THEN REPLY #33338 GOTO 2
  IF ~  Global("41XhaanMindQuest","GLOBAL",0)
~ THEN REPLY #33341 DO ~SetGlobal("41XhaanGaveName", "GLOBAL", 1)
SetGlobal("41XhaanMindQuest", "GLOBAL", 1)~ GOTO 2
  IF ~~ THEN REPLY #33342 DO ~SetGlobal("41PlayerSawDais", "GLOBAL", 1)~ JOURNAL #33680 GOTO 13
  IF ~~ THEN REPLY #33343 GOTO 1
  IF ~~ THEN REPLY #33334 EXIT
END

IF ~~ THEN BEGIN 5
  SAY #33345
  IF ~~ THEN REPLY #33302 GOTO 4
  IF ~~ THEN REPLY #33334 EXIT
END

IF ~~ THEN BEGIN 6
  SAY #33346
  IF ~~ THEN REPLY #33302 GOTO 4
  IF ~~ THEN REPLY #33334 EXIT
END

IF ~~ THEN BEGIN 7
  SAY #33347
  IF ~~ THEN REPLY #33348 DO ~SetGlobal("41XhaanMindQuest", "GLOBAL", 2)~ EXIT
END

IF WEIGHT #2 ~  Global("41XhaanMindQuest","GLOBAL",2)
~ THEN BEGIN 8
  SAY #33351
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
!Global("US_Xhaan_Promise","GLOBAL",1)
~ THEN REPLY #33352 DO ~AddXpVar("Level_8_Hard",31586)
SetGlobal("41XhaanMindQuest", "GLOBAL", 3)~ JOURNAL #31585 GOTO 9
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
Global("US_Xhaan_Promise","GLOBAL",1)
Global("US_Xhaan_Promise_Join","GLOBAL",1)
~ THEN REPLY @40103 DO ~AddXpVar("Level_8_Hard",31586)
SetGlobal("41XhaanMindQuest", "GLOBAL", 3)~ JOURNAL #31585 GOTO XhaanJoin1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
Global("US_Xhaan_Promise","GLOBAL",1)
!Global("US_Xhaan_Promise_Join","GLOBAL",1)
~ THEN REPLY @40102 GOTO XhaanTrick1
  IF ~  Global("41XhaanPlayerKnowsLock","GLOBAL",1)
OpenState("AR4101_Door13",FALSE)
OpenState("AR4101_Door14",FALSE)
OpenState("AR4101_Door15",FALSE)
~ THEN REPLY #33303 DO ~SetGlobal("41PlayerSawDais", "GLOBAL", 1)~ JOURNAL #33680 GOTO 13
  IF ~~ THEN REPLY #33302 GOTO 4
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",2)
!SubRace(Protagonist,HUMAN_AASIMAR)
~ THEN REPLY #33332 GOTO 3
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",2)
SubRace(Protagonist,HUMAN_AASIMAR)
~ THEN REPLY #37959 GOTO 15
  IF ~~ THEN REPLY #33354 GOTO 1
  IF ~~ THEN REPLY #33356 EXIT
END

IF WEIGHT #1 ~  Global("41XhaanMindQuest","GLOBAL",3)
~ THEN BEGIN 9
  SAY #33359
  IF ~  Global("41XhaanPlayerKnowsLock","GLOBAL",1)
OpenState("AR4101_Door13",FALSE)
OpenState("AR4101_Door14",FALSE)
OpenState("AR4101_Door15",FALSE)
~ THEN REPLY #33360 DO ~SetGlobal("41PlayerSawDais", "GLOBAL", 1)~ JOURNAL #33680 GOTO 13
  IF ~~ THEN REPLY #33348 EXIT
END

IF WEIGHT #4 ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 10
  SAY #33361
  IF ~~ THEN REPLY #33440 GOTO 6
  IF ~~ THEN REPLY #33302 GOTO 4
  IF ~  Global("41XhaanPlayerKnowsLock","GLOBAL",1)
OpenState("AR4101_Door13",FALSE)
OpenState("AR4101_Door14",FALSE)
OpenState("AR4101_Door15",FALSE)
~ THEN REPLY #33303 DO ~SetGlobal("41PlayerSawDais", "GLOBAL", 1)~ JOURNAL #33680 GOTO 13
  IF ~  Or(3)
CheckStatGT(Protagonist,12,INT)
SubRace(Protagonist,HUMAN_TIEFLING)
SubRace(Protagonist,HUMAN_AASIMAR)
~ THEN REPLY #33441 GOTO 5
  IF ~  CheckStatLT(Protagonist,13,INT)
!SubRace(Protagonist,HUMAN_TIEFLING)
!SubRace(Protagonist,HUMAN_AASIMAR)
~ THEN REPLY #33442 GOTO 5
  IF ~  ClassEx(Protagonist,PALADIN)
~ THEN REPLY #33443 GOTO 5
  IF ~~ THEN REPLY #33444 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #33319 EXIT
END

IF WEIGHT #5 ~  NumTimesTalkedToGT(0)
~ THEN BEGIN 11
  SAY #33445
  IF ~~ THEN REPLY #33446 GOTO 4
  IF ~  Global("41XhaanPlayerKnowsLock","GLOBAL",1)
OpenState("AR4101_Door13",FALSE)
OpenState("AR4101_Door14",FALSE)
OpenState("AR4101_Door15",FALSE)
~ THEN REPLY #33303 DO ~SetGlobal("41PlayerSawDais", "GLOBAL", 1)~ JOURNAL #33680 GOTO 13
  IF ~~ THEN REPLY #33447 EXIT
END

IF ~~ THEN BEGIN 12
  SAY #33448
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
!Global("US_Xhaan_Promise","GLOBAL",1)
~ THEN REPLY #33329 DO ~AddXpVar("Level_8_Hard",31586)
SetGlobal("41XhaanMindQuest", "GLOBAL", 3)~ JOURNAL #31585 GOTO 9
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
Global("US_Xhaan_Promise","GLOBAL",1)
Global("US_Xhaan_Promise_Join","GLOBAL",1)
~ THEN REPLY @40102 GOTO XhaanJoin1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
Global("US_Xhaan_Promise","GLOBAL",1)
!Global("US_Xhaan_Promise_Join","GLOBAL",1)
~ THEN REPLY @40102 GOTO XhaanTrick1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
!ClassEx(Protagonist,PALADIN)
!Global("US_Xhaan_Promise","GLOBAL",1)
Or(2)
CheckStatGT(Protagonist,15,INT)
CheckSkillGT(Protagonist,8,Diplomacy)
~ THEN REPLY @40101 GOTO XhaanAsk1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",2)
!Global("CagedFury_dead","GLOBAL",1)
~ THEN REPLY #33330 DO ~SetGlobal("41XhaanMindQuest", "GLOBAL", 2)~ JOURNAL #31584 GOTO 7
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",2)
!SubRace(Protagonist,HUMAN_AASIMAR)
~ THEN REPLY #33332 GOTO 3
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",2)
SubRace(Protagonist,HUMAN_AASIMAR)
~ THEN REPLY #37959 GOTO 15
  IF ~~ THEN REPLY #33449 EXIT
END

IF ~~ THEN BEGIN 13
  SAY #33450
  IF ~~ THEN REPLY #33343 GOTO 1
  IF ~~ THEN REPLY #33451 JOURNAL #33681 GOTO 14
  IF ~Global("Lysara_dead","GLOBAL",0)
CheckSkillGT(Protagonist,4,Diplomacy)
See([ENEMY.MONSTER.TANARI][0.0.10000.10000],0)~ THEN REPLY #39560 GOTO 1
  IF ~Global("Lysara_dead","GLOBAL",0)
CheckSkillGT(Protagonist,4,Diplomacy)
!See([ENEMY.MONSTER.TANARI][0.0.10000.10000],0)~ THEN REPLY #39560 DO ~FadeToColor([0.0],0)
Unlock("AR4101_Door13")
Unlock("AR4101_Door14")
Unlock("AR4101_Door15")
OpenDoor("AR4101_Door13")
OpenDoor("AR4101_Door14")
OpenDoor("AR4101_Door15")
RestParty()
RestParty()
RestParty()
ApplySpell("02_White_Abishai_01",2096)
ApplySpell("02_White_Abishai_02",2096)
ApplySpell("02_White_Abishai_03",2096)
ApplySpell("02_White_Abishai_04",2096)
ApplySpell("02_White_Abishai_05",2096)
FadeFromColor([0.0],0)~ EXIT
  IF ~~ THEN REPLY #33334 EXIT
END

IF ~~ THEN BEGIN 14
  SAY #33452
  IF ~~ THEN GOTO 4
END

IF ~~ THEN BEGIN 15
  SAY #37954
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
!Global("US_Xhaan_Promise","GLOBAL",1)
~ THEN REPLY #33329 DO ~AddXpVar("Level_8_Hard",31586)
SetGlobal("41XhaanMindQuest", "GLOBAL", 3)~ JOURNAL #31585 GOTO 9
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
Global("US_Xhaan_Promise","GLOBAL",1)
Global("US_Xhaan_Promise_Join","GLOBAL",1)
~ THEN REPLY @40102 GOTO XhaanJoin1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
Global("US_Xhaan_Promise","GLOBAL",1)
!Global("US_Xhaan_Promise_Join","GLOBAL",1)
~ THEN REPLY @40102 GOTO XhaanTrick1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
!ClassEx(Protagonist,PALADIN)
!Global("US_Xhaan_Promise","GLOBAL",1)
Or(2)
CheckStatGT(Protagonist,15,INT)
CheckSkillGT(Protagonist,8,Diplomacy)
~ THEN REPLY @40101 GOTO XhaanAsk1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",2)
!Global("CagedFury_dead","GLOBAL",1)
~ THEN REPLY #33336 DO ~SetGlobal("41XhaanMindQuest", "GLOBAL", 2)~ JOURNAL #31584 GOTO 7
  IF ~~ THEN REPLY #23977 GOTO 4
  IF ~~ THEN REPLY #37960 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #36113 EXIT
END
