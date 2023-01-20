BEGIN ~31BUGGUT~

IF ~~ THEN BEGIN 0
  SAY #16988
  IF ~~ THEN EXTERN ~31SHERIN~ 1
END

IF ~~ THEN BEGIN 1
  SAY #16990
  IF ~~ THEN EXTERN ~31SHERIN~ 2
END

IF ~~ THEN BEGIN 2
  SAY #16991
  IF ~~ THEN EXTERN ~31SHERIN~ 3
END

IF ~~ THEN BEGIN 3
  SAY #16992
  IF ~~ THEN EXTERN ~31SHERIN~ 4
END

IF ~~ THEN BEGIN 4
  SAY #16993
  IF ~~ THEN EXTERN ~31SHERIN~ 5
END

IF ~Global("USGUTHMA_FRIEND", "GLOBAL", 0)~ THEN BEGIN 5
  SAY #16994
  IF ~~ THEN REPLY #17000 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #17001 GOTO 6
  IF ~~ THEN REPLY #17002 GOTO 8
END

IF ~~ THEN BEGIN 6
  SAY #17003
  IF ~~ THEN REPLY #17004 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #17005 GOTO 7
  IF ~~ THEN REPLY #17006 GOTO 9
  IF ~CheckSkillGT(Protagonist,8,Diplomacy)~ THEN REPLY @6029 GOTO DiplomacyGuthma
END

IF ~~ THEN BEGIN 7
  SAY #17007
  IF ~~ THEN REPLY #17009 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #17010 GOTO 8
  IF ~~ THEN REPLY #17011 GOTO 10
END

IF ~~ THEN BEGIN 8
  SAY #17012
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 9
  SAY #17013
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 10
  SAY #17014
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN DiplomacyGuthma
  SAY @6030
  IF ~~ THEN REPLY @6031 GOTO DiplomacyGuthma2
END

IF ~~ THEN BEGIN DiplomacyGuthma2
  SAY @6032
  IF ~~ THEN REPLY @6033 GOTO DiplomacyGuthma3
END

IF ~~ THEN BEGIN DiplomacyGuthma3
  SAY @6034
  IF ~CheckSkillGT(Protagonist,9,Diplomacy)~ THEN REPLY @6035 GOTO DiplomacyGuthma4
  IF ~CheckSkillLT(Protagonist,10,Diplomacy)~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN DiplomacyGuthma4
  SAY @6036
  IF ~CheckSkillGT(Protagonist,10,Diplomacy)~ THEN REPLY @6037 GOTO DiplomacyGuthma5
  IF ~CheckSkillLT(Protagonist,11,Diplomacy)~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN DiplomacyGuthma5
  SAY @6038
  IF ~CheckSkillGT(Protagonist,8,Bluff)~ THEN REPLY @6039 GOTO DiplomacyGuthma6
  IF ~CheckSkillLT(Protagonist,9,Bluff)~ THEN REPLY @6040 GOTO DiplomacyGuthma7Failed
END

IF ~~ THEN BEGIN DiplomacyGuthma6
  SAY @6041
  IF ~~ THEN REPLY @6042 GOTO DiplomacyGuthma8
END

IF ~~ THEN BEGIN DiplomacyGuthma7Failed
  SAY @6043
  IF ~~ THEN REPLY @6044 DO ~Enemy()
~ EXIT
END

IF ~~ THEN BEGIN DiplomacyGuthma8
  SAY @6045
  IF ~~ THEN REPLY @6046 GOTO DiplomacyGuthma9
END

IF ~~ THEN BEGIN DiplomacyGuthma9
  SAY @6047
  IF ~~ THEN REPLY @6048 GOTO DiplomacyGuthma10
END

IF ~~ THEN BEGIN DiplomacyGuthma10
  SAY @6049
  IF ~~ THEN REPLY @6050 GOTO DiplomacyGuthma11
END

IF ~~ THEN BEGIN DiplomacyGuthma11
  SAY @6051
  IF ~!ClassEx(Protagonist,PALADIN)~ THEN REPLY @6052 DO ~AddExperienceParty(4175)
GiveItemCreate("Misc07",Protagonist,100,0,0)
SetGlobal("USGUTHMA_FRIEND", "GLOBAL", 1)
SetGlobal("Fortress_Quest","GLOBAL",1)
~ EXIT
  IF ~~ THEN REPLY @6053 GOTO DiplomacyGuthma12
END

IF ~~ THEN BEGIN DiplomacyGuthma12
  SAY #22378
  IF ~!ClassEx(Protagonist,PALADIN)~ THEN REPLY @6052 DO ~AddExperienceParty(4175)
SetGlobal("USGUTHMA_FRIEND", "GLOBAL", 1)
SetGlobal("Fortress_Quest","GLOBAL",1)
~ EXIT
  IF ~~ THEN REPLY @6054 GOTO DiplomacyGuthma13
END

IF ~~ THEN BEGIN DiplomacyGuthma13
  SAY @6055
  IF ~~ THEN DO ~Enemy()
~ EXIT
END
