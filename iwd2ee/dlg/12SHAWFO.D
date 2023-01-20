BEGIN ~12SHAWFO~

IF ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY #10797
  IF ~~ THEN REPLY #10799 GOTO 1
  IF ~~ THEN REPLY #10800 DO ~GiveItemCreate("Misc07", Protagonist, 250, 0, 0)~ GOTO 2
END

IF ~~ THEN BEGIN 1
  SAY #10801
  IF ~~ THEN DO ~GiveItemCreate("Misc07", Protagonist, 250, 0, 0)~ GOTO 2
END

IF ~~ THEN BEGIN 2
  SAY #10804
  IF ~~ THEN GOTO 4
END

IF ~~ THEN BEGIN 3
  SAY #10812
  IF ~  Global("10Swift_Dead","GLOBAL",0)
~ THEN REPLY #10813 DO ~SetGlobal("Goblins_Attack_Palisade", "GLOBAL", 1)
StartCutSceneMode()
StartCutScene("12cWar2")~ EXIT
  IF ~  Global("10Swift_Dead","GLOBAL",1)
~ THEN REPLY #10813 DO ~SetGlobal("Goblins_Attack_Palisade", "GLOBAL", 1)
StartCutSceneMode()
StartCutScene("12cWar0")~ EXIT
END

IF ~~ THEN BEGIN 4
  SAY #10814
  IF ~~ THEN GOTO 46
END

IF ~~ THEN BEGIN 5
  SAY #10815
  IF ~~ THEN REPLY #10816 GOTO 6
END

IF ~~ THEN BEGIN 6
  SAY @6004
  IF ~~ THEN REPLY @6005 GOTO 7
  IF ~~ THEN REPLY @6006 GOTO ShawfordTransition
END

IF ~~ THEN BEGIN 7
  SAY #10819
  IF ~~ THEN JOURNAL #800 GOTO 8
END

IF ~~ THEN BEGIN 8
  SAY #10820
  IF ~~ THEN REPLY #10821 DO ~SetGlobal("Lumber_Quest", "GLOBAL", 1)~ EXIT
END

IF ~  GlobalGT("Lumber_Quest","GLOBAL",0)
Global("Arrow_Quest","GLOBAL",0)
~ THEN BEGIN 9
  SAY #10822
  IF ~  GlobalGT("Crane_Wheel","GLOBAL",0)
Global("Lumber_Quest_Aborted","GLOBAL",0)
~ THEN REPLY #11302 DO ~AddXpVar("Level_2_Average",10785)
~ JOURNAL #802 GOTO 12
  IF ~  Global("Lumber_Quest_Aborted","GLOBAL",1)
~ THEN REPLY #11303 DO ~AddXpVar("Level_2_Easy",10794)
~ JOURNAL #10779 GOTO 11
  IF ~  Global("Know_Olap","GLOBAL",0)
~ THEN REPLY #11304 GOTO 10
  IF ~  Global("Crane_Wheel","GLOBAL",0)
Global("Lumber_Quest_Aborted","GLOBAL",0)
~ THEN REPLY #11305 EXIT
END

IF ~~ THEN BEGIN 10
  SAY #11306
  IF ~~ THEN REPLY #10821 EXIT
END

IF ~~ THEN BEGIN 11
  SAY #11307
  IF ~~ THEN GOTO 13
END

IF ~~ THEN BEGIN 12
  SAY #11310
  IF ~~ THEN GOTO 13
END

IF ~~ THEN BEGIN 13
  SAY #11318
  IF ~~ THEN DO ~SetGlobal("Arrow_Quest", "GLOBAL", 1)~ GOTO 14
END

IF ~~ THEN BEGIN 14
  SAY #11389
  IF ~~ THEN REPLY #11390 GOTO 15
  IF ~~ THEN REPLY #11394 EXIT
END

IF ~~ THEN BEGIN 15
  SAY #11395
  IF ~~ THEN REPLY #11397 EXIT
END

IF ~  GlobalGT("Arrow_Quest","GLOBAL",0)
Global("Dead_Goblin_Quest","GLOBAL",0)
~ THEN BEGIN 16
  SAY #11398
  IF ~  Global("Arrow_Quest","GLOBAL",1)
~ THEN REPLY #11401 GOTO 15
  IF ~  Global("Arrow_Quest","GLOBAL",3)
~ THEN REPLY #11405 DO ~AddXpVar("Level_2_Average",10785)
~ JOURNAL #10780 GOTO 17
  IF ~  Global("Arrow_Quest","GLOBAL",4)
~ THEN REPLY #11408 DO ~AddXpVar("Level_2_Average",10785)
~ JOURNAL #10780 GOTO 17
  IF ~  GlobalLT("Arrow_Quest","GLOBAL",3)
~ THEN REPLY #11412 EXIT
END

IF ~~ THEN BEGIN 17
  SAY #11413
  IF ~~ THEN GOTO 18
END

IF ~~ THEN BEGIN 18
  SAY #11414
  IF ~  !Global("Koluhm_Dead","GLOBAL",1)
Global("Know_Koluhm","GLOBAL",0)
~ THEN REPLY #11415 DO ~SetGlobal("Dead_Goblin_Quest", "GLOBAL", 1)~ GOTO 19
  IF ~  !Global("Koluhm_Dead","GLOBAL",1)
GlobalGT("Know_Koluhm","GLOBAL",0)
~ THEN REPLY #11420 DO ~SetGlobal("Dead_Goblin_Quest", "GLOBAL", 1)~ GOTO 19
  IF ~  Global("Koluhm_Dead","GLOBAL",1)
~ THEN REPLY #11421 DO ~SetGlobal("Dead_Goblin_Quest", "GLOBAL", 1)~ JOURNAL #10781 GOTO 26
  IF ~  Global("Koluhm_Dead","GLOBAL",1)
~ THEN REPLY #11422 DO ~SetGlobal("Dead_Goblin_Quest", "GLOBAL", 1)~ JOURNAL #10781 GOTO 26
END

IF ~~ THEN BEGIN 19
  SAY #11423
  IF ~~ THEN JOURNAL #10780 GOTO 20
END

IF ~~ THEN BEGIN 20
  SAY #11424
  IF ~  Global("Know_Koluhm","GLOBAL",0)
~ THEN REPLY #11425 GOTO 21
  IF ~  Global("Know_Koluhm","GLOBAL",1)
~ THEN REPLY #11426 EXIT
END

IF ~~ THEN BEGIN 21
  SAY #11427
  IF ~~ THEN REPLY #11428 EXIT
END

IF ~  GlobalGT("Dead_Goblin_Quest","GLOBAL",0)
Global("Palisade_Iron_Collar_Quest","GLOBAL",0)
~ THEN BEGIN 22
  SAY #11429
  IF ~  Global("Koluhm_Dead","GLOBAL",1)
GlobalLT("Dead_Goblin_Quest","GLOBAL",2)
~ THEN REPLY #11430 JOURNAL #10781 GOTO 26
  IF ~  Global("Koluhm_Dead","GLOBAL",1)
GlobalLT("Dead_Goblin_Quest","GLOBAL",2)
~ THEN REPLY #11422 JOURNAL #10781 GOTO 26
  IF ~  Global("Dead_Goblin_Quest","GLOBAL",2)
~ THEN REPLY #11431 DO ~AddXpVar("Level_2_Easy",10785)
SetGlobal("Dead_Goblin_Quest", "GLOBAL", 6)~ JOURNAL #10782 GOTO 25
  IF ~  Global("Dead_Goblin_Quest","GLOBAL",5)
~ THEN REPLY #11432 DO ~AddXpVar("Level_2_Easy",10785)
SetGlobal("Dead_Goblin_Quest", "GLOBAL", 6)~ JOURNAL #10782 GOTO 24
  IF ~  Global("Dead_Goblin_Quest","GLOBAL",4)
~ THEN REPLY #11434 DO ~AddXpVar("Level_2_Average",10785)
SetGlobal("Dead_Goblin_Quest", "GLOBAL", 6)~ JOURNAL #10782 GOTO 24
  IF ~  Global("Dead_Goblin_Quest","GLOBAL",3)
~ THEN REPLY #11435 GOTO 23
  IF ~  Global("Dead_Goblin_Quest","GLOBAL",1)
~ THEN REPLY #11436 EXIT
END

IF ~~ THEN BEGIN 23
  SAY #11437
  IF ~~ THEN REPLY #11439 DO ~AddXpVar("Level_2_Hard",10795)
SetGlobal("Dead_Goblin_Quest", "GLOBAL", 6)~ JOURNAL #10782 GOTO 24
END

IF ~~ THEN BEGIN 24
  SAY #11440
  IF ~  Global("Know_Iron_Collar","GLOBAL",0)
Global("Black_Geoffrey_Dead","GLOBAL",0)
~ THEN REPLY #11441 GOTO 27
  IF ~  Global("Know_Iron_Collar","GLOBAL",1)
Global("Black_Geoffrey_Dead","GLOBAL",0)
~ THEN REPLY #11442 GOTO 28
  IF ~  Global("Black_Geoffrey_Dead","GLOBAL",1)
Global("Koluhm_Dead","GLOBAL",1)
~ THEN REPLY #11443 DO ~SetGlobal("Palisade_Iron_Collar_Quest", "GLOBAL", 3)~ GOTO 31
  IF ~  Global("Black_Geoffrey_Dead","GLOBAL",1)
Global("Koluhm_Dead","GLOBAL",0)
~ THEN REPLY #11444 DO ~SetGlobal("Palisade_Iron_Collar_Quest", "GLOBAL", 3)~ GOTO 31
END

IF ~~ THEN BEGIN 25
  SAY #11445
  IF ~  Global("Know_Iron_Collar","GLOBAL",0)
Global("Black_Geoffrey_Dead","GLOBAL",0)
~ THEN REPLY #11441 GOTO 27
  IF ~  Global("Know_Iron_Collar","GLOBAL",1)
Global("Black_Geoffrey_Dead","GLOBAL",0)
~ THEN REPLY #11442 GOTO 28
  IF ~  Global("Black_Geoffrey_Dead","GLOBAL",1)
Global("Koluhm_Dead","GLOBAL",1)
~ THEN REPLY #11443 DO ~SetGlobal("Palisade_Iron_Collar_Quest", "GLOBAL", 3)~ GOTO 31
  IF ~  Global("Black_Geoffrey_Dead","GLOBAL",1)
Global("Koluhm_Dead","GLOBAL",0)
~ THEN REPLY #11444 DO ~SetGlobal("Palisade_Iron_Collar_Quest", "GLOBAL", 3)~ GOTO 31
END

IF ~~ THEN BEGIN 26
  SAY #11446
  IF ~  Global("Know_Iron_Collar","GLOBAL",0)
Global("Black_Geoffrey_Dead","GLOBAL",0)
~ THEN REPLY #11441 GOTO 27
  IF ~  Global("Know_Iron_Collar","GLOBAL",1)
Global("Black_Geoffrey_Dead","GLOBAL",0)
~ THEN REPLY #11442 GOTO 28
  IF ~  Global("Black_Geoffrey_Dead","GLOBAL",1)
Global("Koluhm_Dead","GLOBAL",1)
~ THEN REPLY #11443 DO ~SetGlobal("Palisade_Iron_Collar_Quest", "GLOBAL", 3)~ GOTO 31
  IF ~  Global("Black_Geoffrey_Dead","GLOBAL",1)
Global("Koluhm_Dead","GLOBAL",0)
~ THEN REPLY #11444 DO ~SetGlobal("Palisade_Iron_Collar_Quest", "GLOBAL", 3)~ GOTO 31
END

IF ~~ THEN BEGIN 27
  SAY #11447
  IF ~~ THEN GOTO 28
END

IF ~~ THEN BEGIN 28
  SAY #11448
  IF ~~ THEN REPLY #11449 GOTO 29
  IF ~~ THEN REPLY #11450 GOTO 29
END

IF ~~ THEN BEGIN 29
  SAY #11451
  IF ~~ THEN REPLY #11452 DO ~SetGlobal("Palisade_Iron_Collar_Quest", "GLOBAL", 1)~ GOTO 30
  IF ~~ THEN REPLY #11453 DO ~SetGlobal("Palisade_Iron_Collar_Quest", "GLOBAL", 1)~ GOTO 45
END

IF ~~ THEN BEGIN 30
  SAY #11454
  IF ~~ THEN REPLY #11453 GOTO 45
END

IF ~~ THEN BEGIN 31
  SAY #11455
  IF ~  Global("10Swift_Dead","GLOBAL",0)
~ THEN REPLY #10813 DO ~SetGlobal("Goblins_Attack_Palisade", "GLOBAL", 1)
StartCutSceneMode()
StartCutScene("12cWar2")~ EXIT
  IF ~  Global("10Swift_Dead","GLOBAL",1)
~ THEN REPLY #10813 DO ~SetGlobal("Goblins_Attack_Palisade", "GLOBAL", 1)
StartCutSceneMode()
StartCutScene("12cWar0")~ EXIT
END

IF ~  GlobalGT("Palisade_Iron_Collar_Quest","GLOBAL",0)
GlobalLT("Palisade_Iron_Collar_Quest","GLOBAL",3)
~ THEN BEGIN 32
  SAY #11456
  IF ~  Global("Black_Geoffrey_Dead","GLOBAL",1)
~ THEN REPLY #11556 DO ~AddXpVar("Level_2_Average",10785)
SetGlobal("Palisade_Iron_Collar_Quest", "GLOBAL", 4)~ JOURNAL #10783 GOTO 31
  IF ~  Global("Palisade_Iron_Collar_Quest","GLOBAL",2)
Global("Black_Geoffrey_Dead","GLOBAL",1)
~ THEN REPLY #11557 DO ~AddXpVar("Level_2_Average",10785)
SetGlobal("Palisade_Iron_Collar_Quest", "GLOBAL", 3)~ JOURNAL #10783 GOTO 31
  IF ~  Global("Palisade_Iron_Collar_Quest","GLOBAL",2)
Global("Black_Geoffrey_Dead","GLOBAL",0)
~ THEN REPLY #11559 DO ~AddXpVar("Level_2_Hard",10796)
SetGlobal("Palisade_Iron_Collar_Quest", "GLOBAL", 3)
SetGlobal("IC_Good", "GLOBAL", 1)~ JOURNAL #10784 GOTO 3
  IF ~  Global("Black_Geoffrey_Dead","GLOBAL",0)
GlobalLT("Palisade_Iron_Collar_Quest","GLOBAL",2)
~ THEN REPLY #11560 GOTO 30
  IF ~  Global("Black_Geoffrey_Dead","GLOBAL",0)
GlobalLT("Palisade_Iron_Collar_Quest","GLOBAL",2)
~ THEN REPLY #11561 GOTO 45
END

IF ~  GlobalGT("Palisade_Iron_Collar_Quest","GLOBAL",2)
Global("Shawford_Has_No_Pants","GLOBAL",0)
Global("Shaengarne_Quest","GLOBAL",0)
~ THEN BEGIN 33
  SAY #29512
  IF ~~ THEN GOTO 34
END

IF ~~ THEN BEGIN 34
  SAY #29513
  IF ~  Global("S_R_1","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36676 DO ~SetGlobal("S_R_1", "GLOBAL", 1)GiveItemCreate("Misc07", Protagonist, 1000, 0, 0)~ GOTO 37
  IF ~  Global("S_R_1","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36677 DO ~SetGlobal("S_R_1", "GLOBAL", 1)GiveItemCreate("Misc07", Protagonist, 1000, 0, 0)~ GOTO 37
  IF ~~ THEN REPLY #29514 DO ~SetGlobal("Shawford_Has_No_Pants", "GLOBAL", 1)~ EXIT
END

IF ~  GlobalGT("Palisade_Iron_Collar_Quest","GLOBAL",2)
Global("Shawford_Has_No_Pants","GLOBAL",1)
Global("Shaengarne_Quest","GLOBAL",0)
~ THEN BEGIN 35
  SAY #29516
  IF ~  Global("S_R_1","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36676 DO ~SetGlobal("S_R_1", "GLOBAL", 1)GiveItemCreate("Misc07", Protagonist, 1000, 0, 0)~ GOTO 37
  IF ~  Global("S_R_1","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36677 DO ~SetGlobal("S_R_1", "GLOBAL", 1)GiveItemCreate("Misc07", Protagonist, 1000, 0, 0)~ GOTO 37
  IF ~~ THEN REPLY #29514 EXIT
END

IF ~  Global("Shaengarne_Quest","GLOBAL",1)
~ THEN BEGIN 36
  SAY #36678
  IF ~  Global("S_R_1","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36691 DO ~SetGlobal("S_R_1", "GLOBAL", 1)GiveItemCreate("Misc07", Protagonist, 1000, 0, 0)~ GOTO 37
  IF ~  Global("S_R_1","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36692 DO ~SetGlobal("S_R_1", "GLOBAL", 1)GiveItemCreate("Misc07", Protagonist, 1000, 0, 0)~ GOTO 37
  IF ~~ THEN REPLY #36693 EXIT
END

IF ~~ THEN BEGIN 37
  SAY #36679
  IF ~  Global("SC_Speech","GLOBAL",0)
~ THEN REPLY #36694 DO ~SetGlobal("SC_Speech", "GLOBAL", 1)~ GOTO 38
  IF ~  Global("SC_Speech","GLOBAL",1)
~ THEN REPLY #36695 EXIT
  IF ~  Global("SC_Speech","GLOBAL",0)
~ THEN REPLY #36696 DO ~SetGlobal("SC_Speech", "GLOBAL", 1)~ GOTO 38
  IF ~  Global("SC_Speech","GLOBAL",1)
~ THEN REPLY #36696 EXIT
END

IF ~~ THEN BEGIN 38
  SAY #36680
  IF ~~ THEN GOTO 39
END

IF ~~ THEN BEGIN 39
  SAY #36682
  IF ~~ THEN GOTO 40
END

IF ~~ THEN BEGIN 40
  SAY #36683
  IF ~~ THEN GOTO 41
END

IF ~~ THEN BEGIN 41
  SAY #36684
  IF ~~ THEN REPLY #36698 GOTO 42
  IF ~~ THEN REPLY #36699 GOTO 42
  IF ~~ THEN REPLY #36700 GOTO 42
  IF ~~ THEN REPLY #36701 GOTO 42
END

IF ~~ THEN BEGIN 42
  SAY #36685
  IF ~~ THEN REPLY #36702 EXIT
END

IF ~  GlobalGT("Shaengarne_Quest","GLOBAL",1)
Global("Shaengarne_Bridge_Cleared","GLOBAL",1)
Global("31bugGut_Dead","GLOBAL",0)
~ THEN BEGIN 43
  SAY #36687
  IF ~  Global("S_R_1","GLOBAL",1)
Global("S_R_2","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36703 DO ~SetGlobal("S_R_2", "GLOBAL", 1)GiveItemCreate("Misc07", Protagonist, 3000, 0, 0)~ GOTO 37
  IF ~  Global("S_R_1","GLOBAL",0)
Global("S_R_2","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36706 DO ~SetGlobal("S_R_1", "GLOBAL", 1)SetGlobal("S_R_2", "GLOBAL", 1)GiveItemCreate("Misc07", Protagonist, 4000, 0, 0)~ GOTO 37
  IF ~  Global("S_R_1","GLOBAL",1)
Global("S_R_2","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36705 DO ~SetGlobal("S_R_2", "GLOBAL", 1)GiveItemCreate("Misc07", Protagonist, 3000, 0, 0)~ GOTO 37
  IF ~  Global("S_R_1","GLOBAL",0)
Global("S_R_2","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36707 DO ~SetGlobal("S_R_1", "GLOBAL", 1)SetGlobal("S_R_2", "GLOBAL", 1)GiveItemCreate("Misc07", Protagonist, 4000, 0, 0)~ GOTO 37
  IF ~~ THEN REPLY #36708 EXIT
END

IF ~  Global("31bugGut_Dead","GLOBAL",1)
~ THEN BEGIN 44
  SAY #36688
  IF ~  Global("S_R_1","GLOBAL",0)
Global("S_R_2","GLOBAL",0)
Global("S_R_3","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36709 DO ~SetGlobal("S_R_1", "GLOBAL", 1)
SetGlobal("S_R_2", "GLOBAL", 1)SetGlobal("S_R_3", "GLOBAL", 1)GiveItemCreate("Misc07", Protagonist, 10000, 0, 0)~ GOTO 37
  IF ~  Global("S_R_1","GLOBAL",1)
Global("S_R_2","GLOBAL",0)
Global("S_R_3","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36709 DO ~SetGlobal("S_R_2", "GLOBAL", 1)SetGlobal("S_R_3", "GLOBAL", 1)GiveItemCreate("Misc07", Protagonist, 9000, 0, 0)~ GOTO 37
  IF ~  Global("S_R_1","GLOBAL",1)
Global("S_R_2","GLOBAL",1)
Global("S_R_3","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36709 DO ~SetGlobal("S_R_3", "GLOBAL", 1)GiveItemCreate("Misc07", Protagonist, 6000, 0, 0)~ GOTO 37
  IF ~  Global("S_R_1","GLOBAL",0)
Global("S_R_2","GLOBAL",0)
Global("S_R_3","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36712 DO ~SetGlobal("S_R_1", "GLOBAL", 1)
SetGlobal("S_R_2", "GLOBAL", 1)SetGlobal("S_R_3", "GLOBAL", 1)GiveItemCreate("Misc07", Protagonist, 10000, 0, 0)~ GOTO 37
  IF ~  Global("S_R_1","GLOBAL",1)
Global("S_R_2","GLOBAL",0)
Global("S_R_3","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36712 DO ~SetGlobal("S_R_2", "GLOBAL", 1)SetGlobal("S_R_3", "GLOBAL", 1)GiveItemCreate("Misc07", Protagonist, 9000, 0, 0)~ GOTO 37
  IF ~  Global("S_R_1","GLOBAL",1)
Global("S_R_2","GLOBAL",1)
Global("S_R_3","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36712 DO ~SetGlobal("S_R_3", "GLOBAL", 1)GiveItemCreate("Misc07", Protagonist, 6000, 0, 0)~ GOTO 37
  IF ~~ THEN REPLY #36715 EXIT
END

IF ~~ THEN BEGIN 45
  SAY #40139
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 46
  SAY #40140
  IF ~~ THEN GOTO 5
END

IF ~~ THEN BEGIN ShawfordTransition
  SAY @6007
  IF ~  Global("10Swift_Dead","GLOBAL",0)
~ THEN REPLY #10813 DO ~AddexperienceParty(5400)
SetGlobal("Goblins_Attack_Palisade", "GLOBAL", 1)
StartCutSceneMode()
StartCutScene("12cWar2")~ EXIT
  IF ~  Global("10Swift_Dead","GLOBAL",1)
~ THEN REPLY #10813 DO ~AddexperienceParty(5400)
SetGlobal("Goblins_Attack_Palisade", "GLOBAL", 1)
StartCutSceneMode()
StartCutScene("12cWar0")~ EXIT
END
