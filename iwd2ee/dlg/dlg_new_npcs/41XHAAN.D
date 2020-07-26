BEGIN ~41XHAAN~

IF WEIGHT #0 ~Global("US_Xhaan_Promise","GLOBAL",1)
Global("US_Xhaan_Promise_Join","GLOBAL",1)~ THEN BEGIN XhaanJoin1
  SAY ~Thankfully, a disease has been purged from my mind, like ice inside a blazing inferno.  You have lived up to your end of the bargain, mortal, and I shall live up to mine.  I shall help you bring down this Legion.~
  IF ~!NumInParty(6)~ THEN REPLY ~I knew you would.  Shall we?~ DO ~SetGlobal("US_Xhaan_Joined", "GLOBAL", 1)
ApplySpellRES("USXHAAC",Myself)~ EXIT
  IF ~NumInParty(6)~ THEN REPLY ~We no longer have room for you in our group, devil.  Take your freedom and go.~ GOTO XhaanJoin1Refuse
END

IF ~~ THEN BEGIN XhaanJoin1Refuse
  SAY ~Very well.  Good luck, mortal -- you may well need it.~
  IF ~~ THEN REPLY ~Farewell, Xhaan.~ EXIT
END

IF ~~ THEN BEGIN XhaanAsk1
  SAY ~I can offer many things, mortal.  What is it that you want?~
  IF ~!NumInParty(6)~ THEN REPLY ~An ally.  If I set you free, then you will join me and help me defeat the Legion of the Chimera.~ DO ~SetGlobal("US_Xhaan_Promise_Join","GLOBAL",1)~ GOTO XhaanAskJoin
  IF ~~ THEN REPLY ~Gold.  That is the price of your freedom.~ GOTO XhaanAskGold
  IF ~~ THEN REPLY ~Power.  I will trade your freedom for a portion of your life force.~ GOTO XhaanAskXP
END

IF ~~ THEN BEGIN XhaanAskJoin
  SAY ~The Legion is responsible for our imprisonment.  I would gladly aid in their destruction.  I agree to your terms.~
  IF ~GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
~ THEN REPLY ~It is done, then.  I have already banished Aeij-Kllenzr't - Caged Fury.  He was the spirit of a tempest bound to an altar downstairs.~ GOTO XhaanJoin1
  IF ~~ THEN REPLY ~Excellent.  I will return when the task is done.~ DO ~SetGlobal("US_Xhaan_Promise","GLOBAL",1)~ EXIT
END

IF ~~ THEN BEGIN XhaanAskGold
  SAY ~Mortals are ever predictable.  With my freedom, I could grant this wish -- a thousand gold pieces, in the local coin.~
  IF ~GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
~ THEN REPLY ~It is done, then.  I have already banished Aeij-Kllenzr't - Caged Fury.  He was the spirit of a tempest bound to an altar downstairs.~ GOTO XhaanGold1
  IF ~~ THEN REPLY ~Excellent.  I will return when the task is done.~ DO ~SetGlobal("US_Xhaan_Promise","GLOBAL",1)~ EXIT
END

IF ~~ THEN BEGIN XhaanAskXP
  SAY ~Of all things, an adventurer can appreciate the allure of power.  With my freedom, I could grant this wish -- a portion of my life force, transferred from my being to yours.~
  IF ~GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
~ THEN REPLY ~It is done, then.  I have already banished Aeij-Kllenzr't - Caged Fury.  He was the spirit of a tempest bound to an altar downstairs.~ GOTO XhaanXP1
  IF ~~ THEN REPLY ~Excellent.  I will return when the task is done.~ DO ~SetGlobal("US_Xhaan_Promise","GLOBAL",1)~ EXIT
END

IF ~~ THEN BEGIN XhaanGold1
  SAY ~Thankfully, a disease has been purged from my mind, like ice inside a blazing inferno.  It's time to awaken the spawns of the Hells, so I must bid you farewell.~
  IF ~~ THEN REPLY ~What of my reward?~ GOTO XhaanGold2
END

IF ~~ THEN BEGIN XhaanGold2
  SAY ~I promised you nothing, mortal -- I merely said I had the *power* to grant your request.  But I am grateful, so here is a parting gift, along with my thanks.  Do with it what you will.~
  IF ~~ THEN REPLY ~Very well.  A fair trade nonetheless.~ DO ~AddXpVar("Level_8_Hard",31586)
SetGlobal("41XhaanMindQuest", "GLOBAL", 3)
GiveItemCreate("Misc07",Protagonist,250,0,0)~ EXIT
  IF ~~ THEN REPLY ~I should have expected no less from a devil.  Take your freedom and begone.~ DO ~AddXpVar("Level_8_Hard",31586)
SetGlobal("41XhaanMindQuest", "GLOBAL", 3)
GiveItemCreate("Misc07",Protagonist,250,0,0)~ EXIT
END

IF ~~ THEN BEGIN XhaanXP1
  SAY ~Thankfully, a disease has been purged from my mind, like ice inside a blazing inferno.  It's time to awaken the spawns of the Hells, so I must bid you farewell.~
  IF ~~ THEN REPLY ~What of my reward?~ GOTO XhaanGold2
END

IF ~~ THEN BEGIN XhaanXP2
  SAY ~I promised you nothing, mortal -- I merely said I had the *power* to grant your request.  But I am grateful, so here is a parting gift, along with my thanks.  Do with it what you will.~
  IF ~~ THEN REPLY ~Very well.  A fair trade nonetheless.~ DO ~AddXpVar("Level_8_Hard",31586)
SetGlobal("41XhaanMindQuest", "GLOBAL", 3)
GiveItemCreate("Misc07",Protagonist,250,0,0)~ EXIT
  IF ~~ THEN REPLY ~I should have expected no less from a devil.  Take your freedom and begone.~ DO ~AddXpVar("Level_8_Hard",31586)
SetGlobal("41XhaanMindQuest", "GLOBAL", 3)
GiveItemCreate("Misc07",Protagonist,250,0,0)~ EXIT
END

IF ~~ THEN BEGIN XhaanTrick1
  SAY ~Thankfully, a disease has been purged from my mind, like ice inside a blazing inferno.  It's time to awaken the spawns of the Hells, so I must bid you farewell.~
  IF ~~ THEN REPLY ~What of my reward?~ GOTO XhaanTrick2
END

IF ~~ THEN BEGIN XhaanTrick2
  SAY ~I promised you nothing, mortal -- I merely said I had the *power* to grant your request.  But I am nonetheless grateful, so here is a parting gift, along with my thanks.  Do with it what you will.~
  IF ~~ THEN REPLY ~Very well, devil.  A fair trade.~ DO ~AddXpVar("Level_8_Hard",31586)
SetGlobal("41XhaanMindQuest", "GLOBAL", 3)
GiveItemCreate("Misc07",Protagonist,250,0,0)~ EXIT
  IF ~~ THEN REPLY ~I should have expected no less from a devil.  Take your freedom and begone.~ DO ~AddXpVar("Level_8_Hard",31586)
SetGlobal("41XhaanMindQuest", "GLOBAL", 3)
GiveItemCreate("Misc07",Protagonist,250,0,0)~ EXIT
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
~ THEN REPLY ~We've already banished Aeij-Kllenzr't - Caged Fury.  He was the spirit of a tempest bound to an altar downstairs.~ GOTO XhaanJoin1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
Global("US_Xhaan_Promise","GLOBAL",1)
!Global("US_Xhaan_Promise_Join","GLOBAL",1)
~ THEN REPLY ~We've already banished Aeij-Kllenzr't - Caged Fury.  He was the spirit of a tempest bound to an altar downstairs.~ GOTO XhaanTrick1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
!ClassEx(Protagonist,PALADIN)
!Global("US_Xhaan_Promise","GLOBAL",1)
Or(2)
CheckStatGT(Protagonist,15,INT)
CheckSkillGT(Protagonist,8,Diplomacy)
~ THEN REPLY ~If you cannot leave until that voice is banished, perhaps we could make a deal.  What could you offer me in exchange for your freedom?~ GOTO XhaanAsk1
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
~ THEN REPLY ~We've already banished Aeij-Kllenzr't - Caged Fury.  He was the spirit of a tempest bound to an altar downstairs.~ GOTO XhaanJoin1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
Global("US_Xhaan_Promise","GLOBAL",1)
!Global("US_Xhaan_Promise_Join","GLOBAL",1)
~ THEN REPLY ~We've already banished Aeij-Kllenzr't - Caged Fury.  He was the spirit of a tempest bound to an altar downstairs.~ GOTO XhaanTrick1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
!ClassEx(Protagonist,PALADIN)
!Global("US_Xhaan_Promise","GLOBAL",1)
Or(2)
CheckStatGT(Protagonist,15,INT)
CheckSkillGT(Protagonist,8,Diplomacy)
~ THEN REPLY ~If you cannot leave until that voice is banished, perhaps we could make a deal.  What could you offer me in exchange for your freedom?~ GOTO XhaanAsk1
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
~ THEN REPLY ~Yes, we banished the spirit of the tempest bound to the altar below.~ DO ~AddXpVar("Level_8_Hard",31586)
SetGlobal("41XhaanMindQuest", "GLOBAL", 3)~ JOURNAL #31585 GOTO XhaanJoin1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
Global("US_Xhaan_Promise","GLOBAL",1)
!Global("US_Xhaan_Promise_Join","GLOBAL",1)
~ THEN REPLY ~We've already banished Aeij-Kllenzr't - Caged Fury.  He was the spirit of a tempest bound to an altar downstairs.~ GOTO XhaanTrick1
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
~ THEN REPLY ~We've already banished Aeij-Kllenzr't - Caged Fury.  He was the spirit of a tempest bound to an altar downstairs.~ GOTO XhaanJoin1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
Global("US_Xhaan_Promise","GLOBAL",1)
!Global("US_Xhaan_Promise_Join","GLOBAL",1)
~ THEN REPLY ~We've already banished Aeij-Kllenzr't - Caged Fury.  He was the spirit of a tempest bound to an altar downstairs.~ GOTO XhaanTrick1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
!ClassEx(Protagonist,PALADIN)
!Global("US_Xhaan_Promise","GLOBAL",1)
Or(2)
CheckStatGT(Protagonist,15,INT)
CheckSkillGT(Protagonist,8,Diplomacy)
~ THEN REPLY ~If you cannot leave until that voice is banished, perhaps we could make a deal.  What could you offer me in exchange for your freedom?~ GOTO XhaanAsk1
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
~ THEN REPLY ~We've already banished Aeij-Kllenzr't - Caged Fury.  He was the spirit of a tempest bound to an altar downstairs.~ GOTO XhaanJoin1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
Global("CagedFury_dead","GLOBAL",1)
Global("US_Xhaan_Promise","GLOBAL",1)
!Global("US_Xhaan_Promise_Join","GLOBAL",1)
~ THEN REPLY ~We've already banished Aeij-Kllenzr't - Caged Fury.  He was the spirit of a tempest bound to an altar downstairs.~ GOTO XhaanTrick1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",3)
!ClassEx(Protagonist,PALADIN)
!Global("US_Xhaan_Promise","GLOBAL",1)
Or(2)
CheckStatGT(Protagonist,15,INT)
CheckSkillGT(Protagonist,8,Diplomacy)
~ THEN REPLY ~If you cannot leave until that voice is banished, perhaps we could make a deal.  What could you offer me in exchange for your freedom?~ GOTO XhaanAsk1
  IF ~  GlobalLT("41XhaanMindQuest","GLOBAL",2)
!Global("CagedFury_dead","GLOBAL",1)
~ THEN REPLY #33336 DO ~SetGlobal("41XhaanMindQuest", "GLOBAL", 2)~ JOURNAL #31584 GOTO 7
  IF ~~ THEN REPLY #23977 GOTO 4
  IF ~~ THEN REPLY #37960 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #36113 EXIT
END
