BEGIN ~50HGHOST~

IF WEIGHT #4 ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY #8426
  IF ~~ THEN JOURNAL #8419 GOTO 1
END

IF ~~ THEN BEGIN 1
  SAY #8428
  IF ~~ THEN REPLY #8429 JOURNAL #8420 GOTO 2
END

IF ~~ THEN BEGIN 2
  SAY #8430
  IF ~~ THEN GOTO 3
END

IF ~~ THEN BEGIN 3
  SAY #8431
  IF ~~ THEN GOTO 4
END

IF ~~ THEN BEGIN 4
  SAY #8432
  IF ~~ THEN GOTO 5
END

IF ~~ THEN BEGIN 5
  SAY #8433
  IF ~~ THEN REPLY #8434 GOTO 6
END

IF ~~ THEN BEGIN 6
  SAY #8436
  IF ~  Class(Protagonist,BARD)
~ THEN REPLY #8437 GOTO 7
  IF ~  CheckStatGT(Protagonist,14,INT)
CheckStatGT(Protagonist,14,WIS)
!Class(Protagonist,BARD)
~ THEN REPLY #8437 GOTO 7
  IF ~~ THEN REPLY #8438 GOTO 8
END

IF ~~ THEN BEGIN 7
  SAY #8439
  IF ~  Global("50Kurttu_Ghost","Global",1)
Global("50HGhost","Global",0)
~ THEN REPLY #8440 DO ~SetGlobal("50HGhost", "Global", 1)~ JOURNAL #8421 GOTO 9
  IF ~!Global("USFELLWOOD_Skip","Global",1)
Or(6)
Kit(Player1, Mage_Diviner)
Kit(Player2, Mage_Diviner)
Kit(Player3, Mage_Diviner)
Kit(Player4, Mage_Diviner)
Kit(Player5, Mage_Diviner)
Kit(Player6, Mage_Diviner)
~ THEN REPLY @6060 GOTO FellWoodSkip
  IF ~!Global("USFELLWOOD_Skip","Global",1)
Or(6)
CheckSkillGT(Player1, 21, Wilderness_Lore)
CheckSkillGT(Player2, 21, Wilderness_Lore)
CheckSkillGT(Player3, 21, Wilderness_Lore)
CheckSkillGT(Player4, 21, Wilderness_Lore)
CheckSkillGT(Player5, 21, Wilderness_Lore)
CheckSkillGT(Player6, 21, Wilderness_Lore)
~ THEN REPLY @6061 GOTO FellWoodSkip
  IF ~!Global("USFELLWOOD_Skip","Global",1)
Or(6)
CheckSkillGT(Player1, 21, Search)
CheckSkillGT(Player2, 21, Search)
CheckSkillGT(Player3, 21, Search)
CheckSkillGT(Player4, 21, Search)
CheckSkillGT(Player5, 21, Search)
CheckSkillGT(Player6, 21, Search)
~ THEN REPLY @6062 GOTO FellWoodSkip
  IF ~Global("USSUOMA_SKIP","Global",1)~ THEN REPLY @6063 GOTO FellWoodSkip2
  IF ~~ THEN REPLY #8446 EXIT
END

IF ~~ THEN BEGIN 8
  SAY #8447
  IF ~  Global("50Kurttu_Ghost","Global",1)
Global("50HGhost","Global",0)
~ THEN REPLY #8440 DO ~SetGlobal("50HGhost", "Global", 1)~ JOURNAL #8421 GOTO 9
  IF ~~ THEN REPLY #8446 EXIT
END

IF ~~ THEN BEGIN 9
  SAY #8448
  IF ~~ THEN REPLY #8449 GOTO 8
  IF ~~ THEN REPLY #8450 EXIT
END

IF WEIGHT #5 ~  True()
~ THEN BEGIN 10
  SAY #8451
  IF ~  Global("50Kurttu_Ghost","Global",1)
Global("50HGhost","Global",0)
~ THEN REPLY #8440 DO ~SetGlobal("50HGhost", "Global", 1)~ JOURNAL #8421 GOTO 9
  IF ~~ THEN REPLY #8446 EXIT
END

IF WEIGHT #3 ~  Global("50HGhost","GLOBAL",1)
~ THEN BEGIN 11
  SAY #8452
  IF ~~ THEN REPLY #8453 EXIT
END

IF WEIGHT #2 ~  GlobalGT("50WIL_Dead","GLOBAL",2)
~ THEN BEGIN 12
  SAY #8454
  IF ~~ THEN DO ~GiveItemCreate("50GENFWR", Protagonist, 0, 0, 0)~ JOURNAL #31887 GOTO 16
END

IF WEIGHT #1 ~  Global("50HGhost","GLOBAL",2)
~ THEN BEGIN 13
  SAY #8457
  IF ~  Global("50Kurttu_Ghost","Global",1)
Global("50Kyosti","Global",0)
~ THEN REPLY #8440 DO ~SetGlobal("50Kyosti", "Global", 1)~ JOURNAL #8422 GOTO 14
  IF ~~ THEN REPLY #24532 EXIT
END

IF ~~ THEN BEGIN 14
  SAY #24533
  IF ~~ THEN REPLY #8446 EXIT
END

IF WEIGHT #0 ~  Global("50Kyosti","GLOBAL",1)
~ THEN BEGIN 15
  SAY #25674
  IF ~~ THEN REPLY #8450 EXIT
END

IF ~~ THEN BEGIN 16
  SAY #31885
  IF ~  Global("50Kurttu_Ghost","Global",1)
Global("50Kyosti","Global",0)
~ THEN REPLY #8455 DO ~AddXpVar("Level_9_Easy",8424)
SetGlobal("50HGhost", "Global", 2)
SetGlobal("50Kyosti", "Global", 1)~ JOURNAL #8422 GOTO 14
  IF ~~ THEN REPLY #8456 DO ~AddXpVar("Level_9_Easy",8424)
SetGlobal("50HGhost", "Global", 2)~ EXIT
END

IF ~~ THEN BEGIN FellWoodSkip
  SAY @6064
  IF ~~ THEN REPLY #8450 DO ~SetGlobal("USFELLWOOD_SKIP","Global",1)~ EXIT
END

IF ~~ THEN BEGIN FellWoodSkip2
  SAY @6064
  IF ~~ THEN REPLY #8450 EXIT
END
