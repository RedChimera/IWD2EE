BEGIN ~11DEIRD~

IF WEIGHT #2 ~  Global("Know_Deirdre","GLOBAL",0)
~ THEN BEGIN 0
  SAY #15718
  IF ~  Global("Arrow_Quest","GLOBAL",2)
~ THEN REPLY #15719 DO ~SetGlobal("Know_Deirdre", "GLOBAL", 1)~ GOTO 13
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",0)
~ THEN REPLY #15720 DO ~SetGlobal("Know_Deirdre", "GLOBAL", 1)
SetGlobal("Deirdre_Goblins", "GLOBAL", 1)~ GOTO 1
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
~ THEN REPLY #15721 DO ~SetGlobal("Know_Deirdre", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
~ THEN REPLY #15722 DO ~SetGlobal("Know_Deirdre", "GLOBAL", 1)~ GOTO 10
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
~ THEN REPLY #15723 DO ~SetGlobal("Know_Deirdre", "GLOBAL", 1)~ EXIT
END

IF ~~ THEN BEGIN 1
  SAY #15725
  IF ~~ THEN GOTO 2
END

IF ~~ THEN BEGIN 2
  SAY #15727
  IF ~  Global("Know_Ulbrec","GLOBAL",0)
~ THEN REPLY #15728 GOTO 3
  IF ~  Global("Know_Ulbrec","GLOBAL",1)
~ THEN REPLY #15729 GOTO 4
END

IF ~~ THEN BEGIN 3
  SAY #15730
  IF ~~ THEN REPLY #15731 GOTO 5
  IF ~~ THEN REPLY #15732 EXIT
END

IF ~~ THEN BEGIN 4
  SAY #15733
  IF ~~ THEN REPLY #15732 EXIT
END

IF ~~ THEN BEGIN 5
  SAY #15734
  IF ~~ THEN REPLY #15735 EXIT
END

IF WEIGHT #3 ~  GlobalGT("Know_Deirdre","GLOBAL",0)
Global("Deirdre_Goblins","GLOBAL",1)
~ THEN BEGIN 6
  SAY #15736
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",0)
~ THEN REPLY #15737 EXIT
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
~ THEN REPLY #15738 DO ~SetGlobal("Deirdre_Goblins", "GLOBAL", 2)~ GOTO 7
END

IF ~~ THEN BEGIN 7
  SAY #15739
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
~ THEN REPLY #15721 GOTO 9
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
~ THEN REPLY #15740 GOTO 10
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
~ THEN REPLY #15723 EXIT
END

IF WEIGHT #4 ~  GlobalGT("Know_Deirdre","GLOBAL",0)
Global("Goblin_Palisade_Quest","GLOBAL",0)
~ THEN BEGIN 8
  SAY #15741
  IF ~  Global("Arrow_Quest","GLOBAL",2)
~ THEN REPLY #15719 DO ~SetGlobal("Know_Deirdre", "GLOBAL", 1)~ GOTO 13
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #15721 GOTO 9
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #15742 GOTO 9
  IF ~  Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #15740 GOTO 10
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #15743 DO ~StartStore("11Deird", Protagonist)~ EXIT
  IF ~~ THEN REPLY #15723 EXIT
END

IF ~~ THEN BEGIN 9
  SAY #16396
  IF ~  Global("Arrow_Quest","GLOBAL",2)
~ THEN REPLY #16425 DO ~SetGlobal("Know_Deirdre", "GLOBAL", 1)~ GOTO 13
  IF ~~ THEN REPLY #18632 GOTO 11
  IF ~  Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #24294 GOTO 10
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #24295 DO ~StartStore("11Deird", Protagonist)~ EXIT
  IF ~~ THEN REPLY #15723 EXIT
END

IF ~~ THEN BEGIN 10
  SAY #24296
  IF ~~ THEN REPLY #24297 DO ~SetGlobal("Know_Deirdre_Store", "GLOBAL", 1)
StartStore("11Deird", Protagonist)~ EXIT
  IF ~~ THEN REPLY #24298 DO ~SetGlobal("Know_Deirdre_Store", "GLOBAL", 1)~ EXIT
END

IF ~~ THEN BEGIN 11
  SAY #27445
  IF ~~ THEN GOTO 12
END

IF ~~ THEN BEGIN 12
  SAY #27446
  IF ~  Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #15740 GOTO 10
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #15743 DO ~StartStore("11Deird", Protagonist)~ EXIT
  IF ~~ THEN REPLY #27636 EXIT
END

IF ~~ THEN BEGIN 13
  SAY #27638
  IF ~~ THEN REPLY #27639 GOTO 14
  IF ~~ THEN REPLY #27640 GOTO 27
END

IF ~~ THEN BEGIN 14
  SAY #27641
  IF ~  CheckSkillGT(Protagonist,0,Intimidate)
~ THEN REPLY #27642 GOTO 20
  IF ~  CheckSkillGT(Protagonist,0,Bluff)
!ClassEx(Protagonist,PALADIN)
~ THEN REPLY #27643 GOTO 16
  IF ~~ THEN REPLY #27644 GOTO 15
END

IF ~~ THEN BEGIN 15
  SAY #27645
  IF ~~ THEN REPLY #27646 GOTO 21
  IF ~  CheckSkillGT(Protagonist,0,Intimidate)
~ THEN REPLY #27647 GOTO 20
  IF ~  CheckSkillGT(Protagonist,0,Bluff)
!ClassEx(Protagonist,PALADIN)
~ THEN REPLY #27648 GOTO 16
END

IF ~~ THEN BEGIN 16
  SAY #27649
  IF ~  CheckSkillGT(Protagonist,0,Bluff)
!ClassEx(Protagonist,PALADIN)
~ THEN REPLY #27650 GOTO 17
  IF ~  CheckSkillGT(Protagonist,0,Intimidate)
~ THEN REPLY #27647 GOTO 20
  IF ~~ THEN REPLY #27644 GOTO 15
END

IF ~~ THEN BEGIN 17
  SAY #27651
  IF ~  CheckSkillGT(Protagonist,0,Bluff)
!ClassEx(Protagonist,PALADIN)
~ THEN REPLY #27652 GOTO 18
  IF ~  CheckSkillGT(Protagonist,0,Intimidate)
~ THEN REPLY #27647 GOTO 20
  IF ~~ THEN REPLY #27644 GOTO 15
END

IF ~~ THEN BEGIN 18
  SAY #27653
  IF ~~ THEN REPLY #27654 DO ~AddXpVar("Level_2_Average",15717)
SetGlobal("Arrow_Quest", "GLOBAL", 3)
SetGlobal("Deirdre_Screwed", "GLOBAL", 1)~ JOURNAL #15712 GOTO 19
END

IF ~~ THEN BEGIN 19
  SAY #27655
  IF ~  Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #27656 GOTO 10
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #27657 DO ~StartStore("11Deird", Protagonist)~ EXIT
  IF ~~ THEN REPLY #27658 EXIT
END

IF ~~ THEN BEGIN 20
  SAY #27659
  IF ~~ THEN REPLY #27660 DO ~AddXpVar("Level_2_Average",15717)
SetGlobal("Arrow_Quest", "GLOBAL", 3)~ JOURNAL #15713 GOTO 19
  IF ~  CheckSkillGT(Protagonist,0,Bluff)
!ClassEx(Protagonist,PALADIN)
~ THEN REPLY #27648 GOTO 16
  IF ~~ THEN REPLY #27644 GOTO 15
END

IF ~~ THEN BEGIN 21
  SAY #27661
  IF ~~ THEN REPLY #27662 GOTO 22
END

IF ~~ THEN BEGIN 22
  SAY #27663
  IF ~  CheckStatLT(Protagonist,10,INT)
~ THEN REPLY #27664 GOTO 23
  IF ~  CheckStatGT(Protagonist,9,INT)
~ THEN REPLY #27665 GOTO 23
END

IF ~~ THEN BEGIN 23
  SAY #27886
  IF ~  PartyGoldGT(49)
~ THEN REPLY #27887 GOTO 24
  IF ~  PartyGoldLT(51)
~ THEN REPLY #27888 DO ~SetGlobal("Deirdre_Gold", "GLOBAL", 1)~ EXIT
  IF ~  PartyGoldLT(51)
Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #27889 DO ~SetGlobal("Deirdre_Gold", "GLOBAL", 1)~ GOTO 10
  IF ~  PartyGoldLT(51)
Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #27889 DO ~SetGlobal("Deirdre_Gold", "GLOBAL", 1)
StartStore("11Deird", Protagonist)~ EXIT
END

IF ~~ THEN BEGIN 24
  SAY #27890
  IF ~~ THEN REPLY #27891 DO ~AddXpVar("Level_2_Average",15717)
TakePartyGold(50)
GiveItemCreate("Misc07", "11Deird", 50, 0, 0)
SetGlobal("Arrow_Quest", "GLOBAL", 3)
SetGlobal("Deirdre_Gold", "GLOBAL", 0)~ JOURNAL #15714 GOTO 25
  IF ~~ THEN REPLY #27892 DO ~AddXpVar("Level_2_Average",15717)
TakePartyGold(50)
GiveItemCreate("Misc07", "11Deird", 50, 0, 0)
SetGlobal("Arrow_Quest", "GLOBAL", 3)
SetGlobal("Deirdre_Gold", "GLOBAL", 0)~ JOURNAL #15714 GOTO 25
END

IF ~~ THEN BEGIN 25
  SAY #27893
  IF ~  Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #27894 GOTO 10
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #27895 DO ~StartStore("11Deird", Protagonist)~ EXIT
  IF ~~ THEN REPLY #27896 EXIT
END

IF WEIGHT #1 ~  Global("Deirdre_Gold","GLOBAL",1)
~ THEN BEGIN 26
  SAY #27897
  IF ~  PartyGoldGT(49)
~ THEN REPLY #27898 GOTO 24
  IF ~  PartyGoldLT(51)
~ THEN REPLY #27888 DO ~SetGlobal("Deirdre_Gold", "GLOBAL", 1)~ EXIT
  IF ~  PartyGoldLT(51)
Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #27889 DO ~SetGlobal("Deirdre_Gold", "GLOBAL", 1)~ GOTO 10
  IF ~  PartyGoldLT(51)
Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #27889 DO ~SetGlobal("Deirdre_Gold", "GLOBAL", 1)
StartStore("11Deird", Protagonist)~ EXIT
END

IF ~~ THEN BEGIN 27
  SAY #27899
  IF ~  CheckSkillGT(Protagonist,0,Intimidate)
~ THEN REPLY #27642 GOTO 20
  IF ~  CheckSkillGT(Protagonist,0,Bluff)
!ClassEx(Protagonist,PALADIN)
~ THEN REPLY #27643 GOTO 16
  IF ~~ THEN REPLY #27644 GOTO 15
END

IF WEIGHT #0 ~  Global("Deirdre_Screwed","GLOBAL",1)
Global("Goblin_Palisade_Quest","GLOBAL",0)
~ THEN BEGIN 28
  SAY #27900
  IF ~~ THEN REPLY #27901 DO ~StartStore("11Deird", Protagonist)~ EXIT
  IF ~~ THEN REPLY #28002 EXIT
END

IF WEIGHT #5 ~  GlobalGT("Know_Deirdre","GLOBAL",0)
GlobalGT("Goblin_Palisade_Quest","GLOBAL",0)
Global("AR2000_Visited","GLOBAL",0)
~ THEN BEGIN 29
  SAY #28003
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #15721 GOTO 9
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #15742 GOTO 9
  IF ~  Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #15740 GOTO 10
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #15743 DO ~StartStore("11Deird", Protagonist)~ EXIT
  IF ~~ THEN REPLY #27636 EXIT
END

IF WEIGHT #6 ~  GlobalGT("Know_Deirdre","GLOBAL",0)
GlobalGT("Goblin_Palisade_Quest","GLOBAL",0)
Global("Fortress_Quest","GLOBAL",0)
~ THEN BEGIN 30
  SAY #28004
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #15721 GOTO 9
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #15742 GOTO 9
  IF ~  Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #28009 GOTO 10
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #28010 DO ~StartStore("11Deird", Protagonist)~ EXIT
  IF ~~ THEN REPLY #28011 EXIT
END

IF WEIGHT #7 ~  GlobalGT("Know_Deirdre","GLOBAL",0)
GlobalGT("Goblin_Palisade_Quest","GLOBAL",0)
Global("31bugGut_Dead","GLOBAL",0)
Global("Fortress_Quest","GLOBAL",1)
~ THEN BEGIN 31
  SAY #28274
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #28275 GOTO 9
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #28276 GOTO 9
  IF ~  Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #28277 GOTO 10
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #28278 DO ~StartStore("11Deird", Protagonist)~ EXIT
  IF ~~ THEN REPLY #28279 GOTO 32
  IF ~~ THEN REPLY #15723 EXIT
END

IF ~~ THEN BEGIN 32
  SAY #28280
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #28281 GOTO 9
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #28282 GOTO 9
  IF ~  Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #28283 GOTO 10
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #28284 DO ~StartStore("11Deird", Protagonist)~ EXIT
  IF ~~ THEN REPLY #28445 EXIT
  IF ~~ THEN REPLY #28446 EXIT
END

IF WEIGHT #8 ~  GlobalGT("Know_Deirdre","GLOBAL",0)
GlobalGT("Goblin_Palisade_Quest","GLOBAL",0)
Global("31bugGut_Dead","GLOBAL",1)
Global("D_Congrats","GLOBAL",0)
~ THEN BEGIN 33
  SAY #28447
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #28448 DO ~SetGlobal("D_Congrats", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #28449 DO ~SetGlobal("D_Congrats", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #15740 DO ~SetGlobal("D_Congrats", "GLOBAL", 1)~ GOTO 10
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #30298 DO ~SetGlobal("D_Congrats", "GLOBAL", 1)
StartStore("11Deird", Protagonist)~ EXIT
  IF ~~ THEN REPLY #30299 DO ~SetGlobal("D_Congrats", "GLOBAL", 1)~ GOTO 32
  IF ~~ THEN REPLY #15723 DO ~SetGlobal("D_Congrats", "GLOBAL", 1)~ EXIT
END

IF WEIGHT #9 ~  GlobalGT("Know_Deirdre","GLOBAL",0)
GlobalGT("Goblin_Palisade_Quest","GLOBAL",0)
Global("31bugGut_Dead","GLOBAL",1)
Global("D_Congrats","GLOBAL",1)
~ THEN BEGIN 34
  SAY #30300
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #15721 GOTO 9
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #15742 GOTO 9
  IF ~  Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #15740 GOTO 10
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #30301 DO ~StartStore("11Deird", Protagonist)~ EXIT
  IF ~~ THEN REPLY #15723 EXIT
END

IF WEIGHT #10 ~  GlobalGT("Know_Deirdre","GLOBAL",0)
GlobalGT("Goblin_Palisade_Quest","GLOBAL",0)
Global("USGUTHMA_FRIEND","GLOBAL",1)
Global("D_Congrats","GLOBAL",0)
~ THEN BEGIN 35
  SAY @6000
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY @6001 DO ~SetGlobal("D_Congrats", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY @6002 DO ~SetGlobal("D_Congrats", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #15740 DO ~SetGlobal("D_Congrats", "GLOBAL", 1)~ GOTO 10
  IF ~~ THEN REPLY @6003 DO ~SetGlobal("D_Congrats", "GLOBAL", 1)~ GOTO 10
  IF ~~ THEN REPLY #15723 DO ~SetGlobal("D_Congrats", "GLOBAL", 1)~ EXIT
END

IF WEIGHT #11 ~  GlobalGT("Know_Deirdre","GLOBAL",0)
GlobalGT("Goblin_Palisade_Quest","GLOBAL",0)
Global("USGUTHMA_FRIEND","GLOBAL",1)
Global("D_Congrats","GLOBAL",1)
~ THEN BEGIN 36
  SAY #30300
  IF ~  Global("Dock_Goblin_Quest","GLOBAL",1)
Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #15721 GOTO 9
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #15742 GOTO 9
  IF ~  Global("Know_Deirdre_Store","GLOBAL",0)
~ THEN REPLY #15740 GOTO 10
  IF ~  Global("Know_Deirdre_Store","GLOBAL",1)
~ THEN REPLY #30301 DO ~StartStore("11Deird", Protagonist)~ EXIT
  IF ~~ THEN REPLY #15723 EXIT
END
