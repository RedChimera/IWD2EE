BEGIN ~50SUOMA~

IF WEIGHT #2 ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY #2715
  IF ~  Global("50Nym","Global",0)
~ THEN REPLY #2716 DO ~SetGlobal("50Suoma", "GLOBAL", 1)~ GOTO 2
  IF ~  Global("50Suoma_Help","Global",0)
Global("Limha_Dead","Global",0)
~ THEN REPLY #2717 DO ~SetGlobal("50Suoma", "GLOBAL", 1)~ GOTO 17
  IF ~  Global("50Suoma_Help","Global",0)
Global("Limha_Dead","Global",1)
~ THEN REPLY #2717 DO ~SetGlobal("50Suoma", "GLOBAL", 1)~ GOTO 27
  IF ~~ THEN REPLY #2718 DO ~SetGlobal("50Suoma", "GLOBAL", 1)~ GOTO 15
  IF ~  GlobalGT("50Nym","Global",0)
~ THEN REPLY #2719 DO ~SetGlobal("50Suoma", "GLOBAL", 1)~ GOTO 3
  IF ~  GlobalGT("AR5010_Visited","Global",0)
Global("50Suoma_Help","Global",0)
~ THEN REPLY #2720 DO ~SetGlobal("50Suoma", "GLOBAL", 1)~ GOTO 4
  IF ~  PartyHasItem("50GenFWR")
~ THEN REPLY #2721 DO ~SetGlobal("50Suoma", "GLOBAL", 1)
AddXpVar("Level_9_Easy",2714)
TakePartyItemAll("50GenFWR")
DestroyItem("50GenFWR")~ JOURNAL #2710 GOTO 14
  IF ~~ THEN REPLY #2722 DO ~SetGlobal("50Suoma", "GLOBAL", 1)
StartStore("50Suoma", Protagonist)~ EXIT
  IF ~~ THEN REPLY #2723 DO ~SetGlobal("50Suoma", "GLOBAL", 1)~ EXIT
END

IF ~~ THEN BEGIN 1
  SAY #2724
  IF ~  Global("50Suoma_Help","Global",0)
Global("Limha_Dead","Global",0)
~ THEN REPLY #2725 GOTO 17
  IF ~  Global("50Suoma_Help","Global",0)
!Global("Limha_Dead","Global",0)
~ THEN REPLY #2725 GOTO 27
  IF ~~ THEN REPLY #2718 GOTO 15
  IF ~  GlobalGT("50Nym","Global",0)
~ THEN REPLY #2719 GOTO 3
  IF ~  GlobalGT("AR5010_Visited","Global",0)
Global("50Suoma_Help","Global",0)
~ THEN REPLY #2720 GOTO 4
  IF ~  PartyHasItem("50GenFWR")
~ THEN REPLY #2721 DO ~AddXpVar("Level_9_Easy",2714)
TakePartyItemAll("50GenFWR")
DestroyItem("50GenFWR")~ JOURNAL #2710 GOTO 14
  IF ~~ THEN REPLY #2722 DO ~StartStore("50Suoma", Protagonist)~ EXIT
  IF ~~ THEN REPLY #2726 EXIT
END

IF ~~ THEN BEGIN 2
  SAY #2727
  IF ~  Global("50Suoma_Help","Global",0)
Global("Limha_Dead","Global",0)
~ THEN REPLY #2725 GOTO 17
  IF ~  Global("50Suoma_Help","Global",0)
!Global("Limha_Dead","Global",0)
~ THEN REPLY #2725 GOTO 27
  IF ~~ THEN REPLY #2718 GOTO 15
  IF ~  GlobalGT("AR5010_Visited","Global",0)
Global("50Suoma_Help","Global",0)
~ THEN REPLY #2720 GOTO 4
  IF ~  PartyHasItem("50GenFWR")
~ THEN REPLY #2721 DO ~AddXpVar("Level_9_Easy",2714)
TakePartyItemAll("50GenFWR")
DestroyItem("50GenFWR")~ JOURNAL #2710 GOTO 14
  IF ~~ THEN REPLY #2722 DO ~StartStore("50Suoma", Protagonist)~ EXIT
  IF ~~ THEN REPLY #2728 EXIT
END

IF ~~ THEN BEGIN 3
  SAY #2729
  IF ~  Global("50Suoma_Help","Global",0)
Global("Limha_Dead","Global",0)
~ THEN REPLY #2725 GOTO 17
  IF ~  Global("50Suoma_Help","Global",0)
!Global("Limha_Dead","Global",0)
~ THEN REPLY #2725 GOTO 27
  IF ~~ THEN REPLY #2718 GOTO 15
  IF ~  GlobalGT("AR5010_Visited","Global",0)
Global("50Suoma_Help","Global",0)
~ THEN REPLY #2720 GOTO 4
  IF ~  PartyHasItem("50GenFWR")
~ THEN REPLY #2721 DO ~AddXpVar("Level_9_Easy",2714)
TakePartyItemAll("50GenFWR")
DestroyItem("50GenFWR")~ JOURNAL #2710 GOTO 14
  IF ~~ THEN REPLY #2722 DO ~StartStore("50Suoma", Protagonist)~ EXIT
  IF ~~ THEN REPLY #2728 EXIT
END

IF ~~ THEN BEGIN 4
  SAY #2731
  IF ~~ THEN REPLY #2732 GOTO 5
  IF ~~ THEN REPLY #2733 GOTO 6
  IF ~~ THEN REPLY #2734 GOTO 1
  IF ~~ THEN REPLY #2735 EXIT
END

IF ~~ THEN BEGIN 5
  SAY #2736
  IF ~~ THEN REPLY #2733 GOTO 6
  IF ~~ THEN REPLY #2734 GOTO 1
  IF ~~ THEN REPLY #2735 EXIT
END

IF ~~ THEN BEGIN 6
  SAY #2737
  IF ~~ THEN REPLY #2738 GOTO 7
  IF ~~ THEN REPLY #2734 GOTO 1
  IF ~~ THEN REPLY #2735 EXIT
END

IF ~~ THEN BEGIN 7
  SAY #2739
  IF ~~ THEN REPLY #2740 DO ~SetGlobal("50Suoma_Help", "Global", 1)~ JOURNAL #2703 GOTO 8
  IF ~!Alignment(Protagonist,MASK_GOOD)~ THEN REPLY @6117 GOTO SuomaIntimidate1
  IF ~~ THEN REPLY #2741 EXIT
END

IF ~~ THEN BEGIN 8
  SAY #2742
  IF ~  GlobalGT("50Venla_Children","Global",1)
~ THEN REPLY #2743 DO ~SetGlobal("50Suoma_Help", "Global", 2)~ JOURNAL #2704 GOTO 9
  IF ~~ THEN REPLY #2744 GOTO 1
  IF ~~ THEN REPLY #2745 EXIT
END

IF ~~ THEN BEGIN 9
  SAY #2746
  IF ~  GlobalGT("50Tahvo_Wight","Global",1)
~ THEN REPLY #2747 DO ~SetGlobal("50Suoma_Help", "Global", 3)~ JOURNAL #2705 GOTO 10
  IF ~!ClassEx(Protagonist,PALADIN)
!GlobalGT("50Tahvo_Wight","Global",1)
~ THEN REPLY @6118 GOTO SuomaDiplomacy1
  IF ~~ THEN REPLY #2744 GOTO 1
  IF ~~ THEN REPLY #2745 EXIT
END

IF ~~ THEN BEGIN 10
  SAY #2748
  IF ~  GlobalGT("50Kurttu_Ghost","Global",1)
~ THEN REPLY #2749 DO ~AddXpVar("Level_9_Hard",2713)
SetGlobal("50Suoma_Help", "Global", 4)~ JOURNAL #2706 GOTO 11
  IF ~~ THEN REPLY #2744 GOTO 1
  IF ~~ THEN REPLY #2745 EXIT
END

IF ~~ THEN BEGIN 11
  SAY #2750
  IF ~~ THEN REPLY #2751 DO ~SetGlobal("50Suoma_Help", "Global", 5)
SetGlobal("50Twins_Attack", "Global", 1)~ JOURNAL #2707 GOTO 12
  IF ~~ THEN REPLY #2752 DO ~SetGlobal("50Suoma_Help", "Global", 5)
SetGlobal("50Twins_Attack", "Global", 1)~ JOURNAL #2707 GOTO 12
  IF ~  !ClassEx(Protagonist,PALADIN)
!Class(Protagonist,MONK)
!Alignment(Protagonist,LAWFUL_GOOD)
~ THEN REPLY #2753 DO ~SetGlobal("50Suoma_Help", "Global", 5)
SetGlobal("50Twins_Attack", "Global", 1)~ JOURNAL #2707 GOTO 12
  IF ~~ THEN REPLY #2754 EXIT
END

IF ~~ THEN BEGIN 12
  SAY #2755
  IF ~~ THEN REPLY #2756 DO ~SetCriticalPathObject(Myself, FALSE)~ GOTO 13
END

IF ~~ THEN BEGIN 13
  SAY #2758
  IF ~~ THEN REPLY #2759 GOTO 26
  IF ~  PartyHasItem("50GenFWR")
~ THEN REPLY #2721 GOTO 26
  IF ~~ THEN REPLY #2761 GOTO 26
END

IF ~~ THEN BEGIN 14
  SAY #2762
  IF ~~ THEN REPLY #2763 GOTO 1
  IF ~~ THEN REPLY #2764 EXIT
  IF ~~ THEN REPLY #2745 EXIT
END

IF ~~ THEN BEGIN 15
  SAY #2765
  IF ~~ THEN REPLY #2766 GOTO 16
  IF ~~ THEN REPLY #2734 GOTO 1
  IF ~~ THEN REPLY #2767 EXIT
END

IF ~~ THEN BEGIN 16
  SAY #2768
  IF ~~ THEN REPLY #2769 GOTO 1
  IF ~~ THEN REPLY #2770 EXIT
END

IF ~~ THEN BEGIN 17
  SAY #2771
  IF ~~ THEN REPLY @6147 GOTO 18
  IF ~  Global("50Nym","Global",0)
~ THEN REPLY #2773 GOTO 2
  IF ~~ THEN REPLY #2774 GOTO 1
  IF ~~ THEN REPLY #2775 EXIT
END

IF ~~ THEN BEGIN 18
  SAY @6119
  IF ~~ THEN REPLY #2732 GOTO 5
  IF ~~ THEN REPLY #2733 GOTO 6
  IF ~~ THEN REPLY #2734 GOTO 1
  IF ~~ THEN REPLY #2735 EXIT
END

IF WEIGHT #5 ~  Global("50Suoma_Help","GLOBAL",1)
~ THEN BEGIN 19
  SAY #2777
  IF ~  GlobalGT("50Venla_Children","Global",1)
~ THEN REPLY #2778 DO ~SetGlobal("50Suoma_Help", "Global", 2)~ JOURNAL #2704 GOTO 9
  IF ~~ THEN REPLY #2779 GOTO 1
  IF ~~ THEN REPLY #2780 EXIT
END

IF WEIGHT #6 ~  Global("50Suoma_Help","GLOBAL",2)
~ THEN BEGIN 20
  SAY #2781
  IF ~  GlobalGT("50Tahvo_Wight","Global",1)
~ THEN REPLY #2782 DO ~SetGlobal("50Suoma_Help", "Global", 3)~ JOURNAL #2705 GOTO 10
  IF ~~ THEN REPLY #2779 GOTO 1
  IF ~~ THEN REPLY #2780 EXIT
END

IF WEIGHT #7 ~  Global("50Suoma_Help","GLOBAL",3)
~ THEN BEGIN 21
  SAY #2783
  IF ~  GlobalGT("50Kurttu_Ghost","Global",1)
~ THEN REPLY #2749 DO ~AddXpVar("Level_9_Hard",2713)
SetGlobal("50Suoma_Help", "Global", 4)~ JOURNAL #2706 GOTO 11
  IF ~~ THEN REPLY #2779 GOTO 1
  IF ~~ THEN REPLY #2780 EXIT
END

IF WEIGHT #4 ~  Global("50Suoma_Help","GLOBAL",0)
~ THEN BEGIN 22
  SAY #2784
  IF ~  Global("50Nym","Global",0)
~ THEN REPLY #2785 GOTO 2
  IF ~  Global("50Suoma_Help","Global",0)
Global("Limha_Dead","Global",0)
~ THEN REPLY #2786 GOTO 17
  IF ~  Global("50Suoma_Help","Global",0)
!Global("Limha_Dead","Global",0)
~ THEN REPLY #2786 GOTO 27
  IF ~~ THEN REPLY #2718 GOTO 15
  IF ~  GlobalGT("50Nym","Global",0)
~ THEN REPLY #2719 GOTO 3
  IF ~  GlobalGT("AR5010_Visited","Global",0)
Global("50Suoma_Help","Global",0)
~ THEN REPLY #2720 GOTO 4
  IF ~  PartyHasItem("50GenFWR")
~ THEN REPLY #2721 DO ~AddXpVar("Level_9_Easy",2714)
TakePartyItemAll("50GenFWR")
DestroyItem("50GenFWR")~ JOURNAL #2710 GOTO 14
  IF ~~ THEN REPLY #2722 DO ~StartStore("50Suoma", Protagonist)~ EXIT
  IF ~~ THEN REPLY #2730 EXIT
END

IF WEIGHT #8 ~  True()
~ THEN BEGIN 23
  SAY #8458
  IF ~  GlobalLT("50Suoma_Help","Global",5)
~ THEN REPLY #2752 DO ~SetGlobal("50Suoma_Help", "Global", 5)
SetGlobal("50Twins_Attack", "Global", 1)~ JOURNAL #2707 GOTO 12
  IF ~~ THEN REPLY #2718 GOTO 15
  IF ~  GlobalGT("50Nym","Global",0)
~ THEN REPLY #2719 GOTO 3
  IF ~  PartyHasItem("50GenFWR")
~ THEN REPLY #2721 DO ~AddXpVar("Level_9_Easy",2714)
TakePartyItemAll("50GenFWR")
DestroyItem("50GenFWR")~ JOURNAL #2710 GOTO 14
  IF ~~ THEN REPLY #2722 DO ~StartStore("50Suoma", Protagonist)~ EXIT
  IF ~~ THEN REPLY #8459 EXIT
END

IF WEIGHT #1 ~  Global("50Twins_Attack","Global",2)
~ THEN BEGIN 24
  SAY #8460
  IF ~~ THEN REPLY #16626 DO ~SetGlobal("50Twins_Attack", "Global", 3)~ GOTO 25
  IF ~~ THEN REPLY #16634 DO ~SetGlobal("50Twins_Attack", "Global", 3)~ GOTO 25
  IF ~~ THEN REPLY #2718 DO ~SetGlobal("50Twins_Attack", "Global", 3)~ GOTO 15
  IF ~  GlobalGT("50Nym","Global",0)
~ THEN REPLY #2719 DO ~SetGlobal("50Twins_Attack", "Global", 3)~ GOTO 3
  IF ~  PartyHasItem("50GenFWR")
~ THEN REPLY #2721 DO ~AddXpVar("Level_9_Easy",2714)
TakePartyItemAll("50GenFWR")
DestroyItem("50GenFWR")~ JOURNAL #2710 GOTO 14
  IF ~~ THEN REPLY #2722 DO ~StartStore("50Suoma", Protagonist)~ EXIT
  IF ~~ THEN REPLY #2745 DO ~SetGlobal("50Twins_Attack", "Global", 3)~ EXIT
END

IF ~~ THEN BEGIN 25
  SAY #16635
  IF ~~ THEN REPLY #2718 GOTO 15
  IF ~  GlobalGT("50Nym","Global",0)
~ THEN REPLY #2719 GOTO 3
  IF ~  PartyHasItem("50GenFWR")
~ THEN REPLY #2721 DO ~AddXpVar("Level_9_Easy",2714)
TakePartyItemAll("50GenFWR")
DestroyItem("50GenFWR")~ JOURNAL #2710 GOTO 14
  IF ~~ THEN REPLY #2722 DO ~StartStore("50Suoma", Protagonist)~ EXIT
  IF ~~ THEN REPLY #2745 EXIT
END

IF ~~ THEN BEGIN 26
  SAY #18309
  IF ~~ THEN DO ~StartCutSceneMode()
StartCutScene("50cTwin0")~ EXIT
END

IF ~~ THEN BEGIN 27
  SAY #35536
  IF ~~ THEN REPLY #2772 GOTO 18
  IF ~  Global("50Nym","Global",0)
~ THEN REPLY #2773 GOTO 2
  IF ~~ THEN REPLY #2774 GOTO 1
  IF ~~ THEN REPLY #2775 EXIT
END

IF WEIGHT #0 ~See([ENEMY], 0)~ THEN BEGIN 28
  SAY #38162
  IF ~~ THEN REPLY #399 EXIT
END

IF ~~ THEN BEGIN SuomaIntimidate1
  SAY @6120
  IF ~  GlobalGT("50Venla_Children","Global",1)
~ THEN REPLY #2743 DO ~SetGlobal("50Suoma_Help", "Global", 2)~ JOURNAL #2704 GOTO 9
  IF ~~ THEN REPLY @6123 DO ~SetGlobal("50Suoma_Help", "Global", 1)~ JOURNAL #2703 EXIT
  IF ~~ THEN REPLY @6124 DO ~SetGlobal("50Suoma_Help", "Global", 1)~ JOURNAL #2703 GOTO 1
  IF ~!Alignment(Protagonist,MASK_EVIL)
CheckSkillGT(Protagonist,13,Intimidate)~ THEN REPLY @6121 DO ~SetGlobal("USSUOMA_SKIP", "Global", 1)~ GOTO SuomaIntimidate2
  IF ~Alignment(Protagonist,MASK_EVIL)
CheckSkillGT(Protagonist,13,Intimidate)~ THEN REPLY @6122 DO ~SetGlobal("USSUOMA_SKIP", "Global", 1)~ GOTO SuomaIntimidate2
END

IF ~~ THEN BEGIN SuomaIntimidate2
  SAY @6125
  IF ~~ THEN REPLY @6126 DO ~SetGlobal("50Suoma_Help", "Global", 1)~ JOURNAL #2703 EXIT
  IF ~Alignment(Protagonist,MASK_EVIL)~ THEN REPLY @6127 GOTO SuomaIntimidate3
END

IF ~~ THEN BEGIN SuomaIntimidate3
  SAY @6128
  IF ~~ THEN REPLY @6129 DO ~SetCriticalPathObject(Myself, FALSE)
SetGlobal("USSUOMA_SCARED", "Global", 1)
~ EXIT
END

IF ~~ THEN BEGIN SuomaDiplomacy1
  SAY @6130
  IF ~~ THEN REPLY @6131 GOTO SuomaDiplomacy2
  IF ~CheckSkillGT(Protagonist,8,Diplomacy)~ THEN REPLY @6132 GOTO SuomaDiplomacy4
  IF ~~ THEN REPLY @6133 EXIT
END

IF ~~ THEN BEGIN SuomaDiplomacy2
  SAY @6134
  IF ~CheckSkillGT(Protagonist,10,Diplomacy)~ THEN REPLY @6135 GOTO SuomaDiplomacy3
  IF ~CheckSkillGT(Protagonist,8,Diplomacy)~ THEN REPLY @6136 GOTO SuomaDiplomacy3
  IF ~~ THEN REPLY @6137 EXIT
END

IF ~~ THEN BEGIN SuomaDiplomacy3
  SAY @6138
  IF ~~ THEN REPLY @6139 GOTO SuomaDiplomacy4
  IF ~~ THEN REPLY @6140 GOTO SuomaDiplomacy4
END

IF ~~ THEN BEGIN SuomaDiplomacy4
  SAY @6141
  IF ~~ THEN REPLY @6142 DO ~SetCriticalPathObject(Myself, FALSE)
SetGlobal("USSUOMA_SKIP", "Global", 1)
SetGlobal("USSUOMA_HELPED", "Global", 1)
SetGlobal("50Suoma_Help","GLOBAL",5)
~ EXIT
END

IF WEIGHT #3 ~Global("USSUOMA_SCARED", "Global", 1)~ THEN BEGIN SuomaScared
  SAY @6143
  IF ~~ THEN REPLY @6144 GOTO SuomaScared2
  IF ~~ THEN REPLY @6145 EXIT
END

IF ~~ THEN BEGIN SuomaScared2
  SAY @6146
  IF ~~ THEN REPLY #21892 EXIT
END
