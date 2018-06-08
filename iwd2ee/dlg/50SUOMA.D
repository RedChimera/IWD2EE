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
  IF ~!Alignment(Protagonist,NEUTRAL_GOOD)
!Alignment(Protagonist,LAWFUL_GOOD)~ THEN REPLY ~Aid the village?  No, no, no; I'm not here to save any little villages.  I'm just passing through.  I have places to go and things to do.~ GOTO SuomaIntimidate1
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
~ THEN REPLY ~Wait, we had a deal--we would help you find the children and you would tell us how to get through the Fell Wood.~ GOTO SuomaDiplomacy1
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
  IF ~~ THEN REPLY ~Very strange.~ GOTO 18
  IF ~  Global("50Nym","Global",0)
~ THEN REPLY #2773 GOTO 2
  IF ~~ THEN REPLY #2774 GOTO 1
  IF ~~ THEN REPLY #2775 EXIT
END

IF ~~ THEN BEGIN 18
  SAY ~Yes... and this is why I wished to speak with you.  If you intend to continue traveling eastwards, you must pass through the haunted Fell Wood.  The trail to the Cold Marshes beyond the forest is difficult to find... in this village, I alone know the way.~
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

IF WEIGHT #0 ~See([ENEMY], FALSE)~ THEN BEGIN 28
  SAY #38162
  IF ~~ THEN REPLY #399 EXIT
END

IF ~~ THEN BEGIN SuomaIntimidate1
  SAY ~I am certain you are here to help us, whether you knew it or not.  Forgive me, but I cannot give you your answers just yet.  I must ask that you speak with Venla the Healer, first - she will tell you what must be done.  Please help us, and we shall help you in turn.~
  IF ~  GlobalGT("50Venla_Children","Global",1)
~ THEN REPLY #2743 DO ~SetGlobal("50Suoma_Help", "Global", 2)~ JOURNAL #2704 GOTO 9
  IF ~~ THEN REPLY ~Very well.  I will go speak with Venla.~ DO ~SetGlobal("50Suoma_Help", "Global", 1)~ JOURNAL #2703 EXIT
  IF ~~ THEN REPLY ~I see.  I have other questions.~ DO ~SetGlobal("50Suoma_Help", "Global", 1)~ JOURNAL #2703 GOTO 1
  IF ~Alignment(Protagonist,MASK_EVIL)
CheckSkillGT(Protagonist,13,Intimidate)~ THEN REPLY ~I don't think you understood me.  I don't care about your dreams--I'm not running errands for some old barbarian crone.  If you know how to get through these woods, then you will *tell* me how to get through these woods.~ DO ~SetGlobal("USSUOMA_SKIP", "Global", 1)~ GOTO SuomaIntimidate2
  IF ~!Alignment(Protagonist,MASK_EVIL)
CheckSkillGT(Protagonist,13,Intimidate)
CheckSkillGT(Protagonist,5,Bluff)~ THEN REPLY ~I don't think you understood me.  I don't care about your visions--I'm not running errands for some old hag.  If you know how to get through these woods, then you will *tell* me how to get through these woods.~ DO ~SetGlobal("USSUOMA_SKIP", "Global", 1)~ GOTO SuomaIntimidate2
END

IF ~~ THEN BEGIN SuomaIntimidate2
  SAY ~I must insist.  Our village is in need, and we cannot solve these problems on our own.~
  IF ~~ THEN REPLY ~Fine.  If you're that stubborn, I'll go speak with Venla.~ DO ~SetGlobal("50Suoma_Help", "Global", 1)~ JOURNAL #2703 EXIT
  IF ~~ THEN REPLY ~Listen, you barbarian crone--if you don't tell us the way through the woods, you're going to have much bigger problems than a missing bucket or a rabid wolf.  I saw your scrawny band of hunters on the way here, and I don't think any of them is going to stop us if we draw steel on this village.  You can tell us the path through the woods now, or you can tell us when we're carving up your people.~ GOTO SuomaIntimidate3
END

IF ~~ THEN BEGIN SuomaIntimidate3
  SAY ~I... I see.  No, you are not the wanderers I've been expecting.  Very well... if you leave our village in peace, then I will tell you.  There is a certain sort of monster in the Fell Wood, horrific abominations known as dark treants.  It is their warping influence that hides the true path to you.  Destroy them and the way will be clear.  You can find them to the southeast of the first clearing.~
  IF ~~ THEN REPLY ~This had better be the right path.  If I can't get through those woods on your directions, I'm coming back.~ DO ~SetCriticalPathObject(Myself, FALSE)
SetGlobal("USSUOMA_SCARED", "Global", 1)
~ EXIT
END

IF ~~ THEN BEGIN SuomaDiplomacy1
  SAY ~I understand, and we are grateful, but our troubles do not end with the missing children.  We also have a problem with a local wight.  Tahvo the Huntmaster can tell you more.~
  IF ~~ THEN REPLY ~Suoma, your village isn't my only priority here.  I am needed elsewhere.  I need you to tell me how to get through the Fell Woods.~ GOTO SuomaDiplomacy2
  IF ~~ THEN REPLY ~I saved your children and that's not enough for you?  I'm not interested in being the local hero; I'm just trying to get out of here.  Tell me how to get through the woods.~ GOTO SuomaDiplomacy2
  IF ~~ THEN REPLY ~Very well.  If your village still needs help, I'll go speak with this Tahvo.~ EXIT
END

IF ~~ THEN BEGIN SuomaDiplomacy2
  SAY ~I know you have other places to go, but first you are needed here.  Please... we do not have anywhere else to turn.~
  IF ~CheckSkillGT(Protagonist,10,Diplomacy)~ THEN REPLY ~Look, I would love to help, but we simply don't have any more time to waste.  I mean no offense, but we have higher priorities than the needs of just one village.  We have all of Icewind Dale to worry about.~ GOTO SuomaDiplomacy3
  IF ~CheckSkillGT(Protagonist,8,Diplomacy)~ THEN REPLY ~Then you're out of luck.  I'd rather take my chances in the woods than run errands all day.  I'm not going to stay here and wait for you to live up to your end of the bargain.~ GOTO SuomaDiplomacy3
  IF ~~ THEN REPLY ~Fine.  If it's really necessary, I'll go ask Tahvo about this wight.~ EXIT
END

IF ~~ THEN BEGIN SuomaDiplomacy3
  SAY ~I cannot show you the way forward until our needs are met.  I foresaw you helping us, and we have no one else to ask.~
  IF ~~ THEN REPLY ~We did help you.  Our work is done here.  Now it's time to move on.  We're on a mission from Targos, and we're not staying here and waiting for permission to do our job.  If you won't help us, then we'll find our own way.~ GOTO SuomaDiplomacy4
  IF ~~ THEN REPLY ~Sorry, but the answer is no.  If you don't tell how to get through the woods, we'll find a way without your help.~ GOTO SuomaDiplomacy4
END

IF ~~ THEN BEGIN SuomaDiplomacy4
  SAY ~Very well.  I appreciate what you've done for us, so I will tell you how to escape the woods.  There is a certain sort of monster in the Fell Wood, horrific abominations known as dark treants.  It is their warping influence that hides the true path to you.  Destroy them and the way will be clear.  You can find them to the southeast of the first clearing.~
  IF ~~ THEN REPLY ~Thank you, Suoma.~ DO ~SetCriticalPathObject(Myself, FALSE)
SetGlobal("USSUOMA_SKIP", "Global", 1)
SetGlobal("USSUOMA_HELPED", "Global", 1)
SetGlobal("50Suoma_Help","GLOBAL",5)
~ EXIT
END

IF WEIGHT #3 ~Global("USSUOMA_SCARED", "Global", 1)~ THEN BEGIN SuomaScared
  SAY ~It's you again...~
  IF ~~ THEN REPLY ~How do I get through the Fell Wood again?~ GOTO SuomaScared2
  IF ~~ THEN REPLY ~Just passing through.  Farewell.~ EXIT
END

IF ~~ THEN BEGIN SuomaScared2
  SAY ~You must find the dark treants and destroy them.  They are responsible for hiding the true path.  You can find them to the southeast of the first clearing.~
  IF ~~ THEN REPLY ~Thank you.~ EXIT
END
