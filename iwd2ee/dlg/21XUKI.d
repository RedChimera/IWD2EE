BEGIN ~21XUKI~

IF ~  True()
~ THEN BEGIN 0
  SAY #36498
  IF ~~ THEN REPLY #36499 GOTO 1
  IF ~~ THEN REPLY #36500 GOTO 14
  IF ~  CheckSkillGT(Protagonist,3,Diplomacy)
~ THEN REPLY #36501 DO ~AddXpVar("Level_4_Easy",36495)
~ JOURNAL #36490 GOTO 16
  IF ~  CheckSkillLT(Protagonist,4,Diplomacy)
CheckSkillGT(Protagonist,3,Bluff)
~ THEN REPLY #36502 DO ~AddXpVar("Level_4_Easy",36495)
~ JOURNAL #36490 GOTO 16
  IF ~~ THEN REPLY #36503 DO ~AddXpVar("Level_4_Easy",36495)
Enemy()~ JOURNAL #36490 EXIT
END

IF ~~ THEN BEGIN 1
  SAY #36504
  IF ~~ THEN REPLY #36505 GOTO 2
  IF ~~ THEN REPLY #36506 GOTO 2
  IF ~  CheckSkillGT(Protagonist,3,Diplomacy)
~ THEN REPLY #36501 DO ~AddXpVar("Level_4_Easy",36495)
~ JOURNAL #36490 GOTO 16
  IF ~CheckSkillGT(Protagonist,6,Intimidate)~ THEN REPLY @6011 GOTO IntimidateXuki
  IF ~  CheckSkillLT(Protagonist,4,Diplomacy)
CheckSkillGT(Protagonist,3,Bluff)
~ THEN REPLY #36507 DO ~AddXpVar("Level_4_Easy",36495)
~ JOURNAL #36490 GOTO 16
  IF ~~ THEN REPLY #36503 DO ~AddXpVar("Level_4_Easy",36495)
Enemy()~ JOURNAL #36490 EXIT
END

IF ~~ THEN BEGIN 2
  SAY #36508
  IF ~~ THEN REPLY #36509 GOTO 3
  IF ~  CheckSkillGT(Protagonist,3,Diplomacy)
~ THEN REPLY #36501 DO ~AddXpVar("Level_4_Easy",36495)
~ JOURNAL #36490 GOTO 16
  IF ~  CheckSkillLT(Protagonist,4,Diplomacy)
CheckSkillGT(Protagonist,3,Bluff)
~ THEN REPLY #36510 DO ~AddXpVar("Level_4_Easy",36495)
~ JOURNAL #36490 GOTO 16
  IF ~~ THEN REPLY #36503 DO ~AddXpVar("Level_4_Easy",36495)
Enemy()~ JOURNAL #36490 EXIT
END

IF ~~ THEN BEGIN 3
  SAY #36511
  IF ~~ THEN REPLY #36512 GOTO 4
  IF ~~ THEN REPLY #36513 GOTO 5
  IF ~  ClassEx(Protagonist,CLERIC)
~ THEN REPLY #36514 GOTO 11
  IF ~  ClassEx(Protagonist,THIEF)
~ THEN REPLY #36515 GOTO 11
  IF ~  ClassEx(Protagonist,DRUID)
~ THEN REPLY #36516 GOTO 11
  IF ~  ClassEx(Protagonist,FIGHTER)
~ THEN REPLY #36517 GOTO 11
  IF ~  ClassEx(Protagonist,PALADIN)
~ THEN REPLY #36518 GOTO 11
  IF ~  CheckSkillGT(Protagonist,3,Diplomacy)
~ THEN REPLY #36501 DO ~AddXpVar("Level_4_Easy",36495)
~ JOURNAL #36490 GOTO 16
  IF ~  CheckSkillLT(Protagonist,4,Diplomacy)
CheckSkillGT(Protagonist,3,Bluff)
~ THEN REPLY #36510 DO ~AddXpVar("Level_4_Easy",36495)
~ JOURNAL #36490 GOTO 16
  IF ~~ THEN REPLY #36503 DO ~AddXpVar("Level_4_Easy",36495)
Enemy()~ JOURNAL #36490 EXIT
END

IF ~~ THEN BEGIN 4
  SAY #36519
  IF ~~ THEN REPLY #36520 GOTO 11
  IF ~  ClassEx(Protagonist,CLERIC)
~ THEN REPLY #36514 GOTO 11
  IF ~  ClassEx(Protagonist,THIEF)
~ THEN REPLY #36515 GOTO 11
  IF ~  ClassEx(Protagonist,DRUID)
~ THEN REPLY #36516 GOTO 11
  IF ~  ClassEx(Protagonist,FIGHTER)
~ THEN REPLY #36517 GOTO 11
  IF ~  ClassEx(Protagonist,PALADIN)
~ THEN REPLY #36518 GOTO 11
  IF ~  CheckSkillGT(Protagonist,3,Diplomacy)
~ THEN REPLY #36501 DO ~AddXpVar("Level_4_Easy",36495)
~ JOURNAL #36490 GOTO 16
  IF ~  CheckSkillLT(Protagonist,4,Diplomacy)
CheckSkillGT(Protagonist,3,Bluff)
~ THEN REPLY #36510 DO ~AddXpVar("Level_4_Easy",36495)
~ JOURNAL #36490 GOTO 16
  IF ~~ THEN REPLY #36503 DO ~AddXpVar("Level_4_Easy",36495)
Enemy()~ JOURNAL #36490 EXIT
END

IF ~~ THEN BEGIN 5
  SAY #36521
  IF ~~ THEN REPLY #36522 GOTO 6
  IF ~  CheckStatGT(Protagonist,11,WIS)
~ THEN REPLY #36523 GOTO 15
END

IF ~~ THEN BEGIN 6
  SAY #36524
  IF ~~ THEN REPLY #36525 GOTO 7
  IF ~~ THEN REPLY #36526 GOTO 7
  IF ~~ THEN REPLY #36527 GOTO 8
  IF ~~ THEN REPLY #36528 DO ~AddXpVar("Level_4_Easy",36495)
Enemy()~ JOURNAL #36490 EXIT
END

IF ~~ THEN BEGIN 7
  SAY #36537
  IF ~~ THEN REPLY #36539 GOTO 10
END

IF ~~ THEN BEGIN 8
  SAY #36540
  IF ~~ THEN REPLY #36541 GOTO 9
END

IF ~~ THEN BEGIN 9
  SAY #36543
  IF ~~ THEN REPLY #39743 GOTO 10
END

IF ~~ THEN BEGIN 10
  SAY #40919
  IF ~~ THEN REPLY #40920 DO ~AddXpVar("Level_4_Average",36496)
Enemy()
SetGlobal("SR_Kill_Bridge","GLOBAL",1)~ JOURNAL #36491 EXIT
END

IF ~~ THEN BEGIN 11
  SAY #40921
  IF ~~ THEN REPLY #36522 GOTO 12
  IF ~  CheckStatGT(Protagonist,11,WIS)
~ THEN REPLY #36523 GOTO 15
END

IF ~~ THEN BEGIN 12
  SAY #40922
  IF ~~ THEN REPLY #40923 GOTO 13
END

IF ~~ THEN BEGIN 13
  SAY #40924
  IF ~~ THEN REPLY #40925 DO ~AddXpVar("Level_4_Average",36496)
Enemy()
SetGlobal("SR_Kill_Bridge","GLOBAL",1)~ JOURNAL #36491 EXIT
END

IF ~~ THEN BEGIN 14
  SAY #40926
  IF ~~ THEN REPLY #36499 GOTO 1
  IF ~  CheckSkillGT(Protagonist,3,Diplomacy)
~ THEN REPLY #36501 DO ~AddXpVar("Level_4_Easy",36495)
~ JOURNAL #36490 GOTO 16
  IF ~  CheckSkillLT(Protagonist,4,Diplomacy)
CheckSkillGT(Protagonist,3,Bluff)
~ THEN REPLY #36502 DO ~AddXpVar("Level_4_Easy",36495)
~ JOURNAL #36490 GOTO 16
  IF ~~ THEN REPLY #36503 DO ~AddXpVar("Level_4_Easy",36495)
Enemy()~ JOURNAL #36490 EXIT
END

IF ~~ THEN BEGIN 15
  SAY #40927
  IF ~~ THEN REPLY #40928 DO ~AddXpVar("Level_4_Hard",36497)
~ JOURNAL #36494 GOTO 16
END

IF ~~ THEN BEGIN 16
  SAY #40929
  IF ~~ THEN REPLY #40930 DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN IntimidateXuki
  SAY @6012
  IF ~~ THEN REPLY @6013 GOTO IntimidateXuki2
END

IF ~~ THEN BEGIN IntimidateXuki2
  SAY @6014
  IF ~~ THEN REPLY @6015 GOTO IntimidateXuki3
END

IF ~~ THEN BEGIN IntimidateXuki3
  SAY @6016
  IF ~~ THEN REPLY @6017 DO ~AddExperienceParty(2500)
GiveItemCreate("Misc07",Protagonist,100,0,0)
GiveItemCreate("00ROBE04",Protagonist,0,0,0)
GiveItemCreate("00BOOT09",Protagonist,0,0,0)
GiveItemCreate("00DAGG91",Protagonist,0,0,0)
GiveItemCreate("SPWI112Z",Protagonist,1,0,0)
GiveItemCreate("00HBGA01",Protagonist,0,0,0)
StartCutScene("USSTXUKI")
~ EXIT
END
