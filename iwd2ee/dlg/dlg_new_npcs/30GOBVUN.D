BEGIN ~30GOBVUN~

IF WEIGHT #1 ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY #13930
  IF ~~ THEN REPLY #13931 DO ~Enemy()~ EXIT
  IF ~  CheckSkillGT(Protagonist,6,Diplomacy)
~ THEN REPLY #13932 GOTO 1
  IF ~  CheckSkillLT(Protagonist,6,Intimidate)
~ THEN REPLY #13933 GOTO 8
  IF ~  CheckSkillGT(Protagonist,7,Intimidate)
~ THEN REPLY @40072 GOTO 9
END

IF WEIGHT #2 ~  NumTimesTalkedToGT(0)
~ THEN BEGIN 1
  SAY #13934
  IF ~~ THEN REPLY #13935 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #13936 GOTO 2
  IF ~~ THEN REPLY #13937 GOTO 8
END

IF ~~ THEN BEGIN 2
  SAY @40073
  IF ~~ THEN REPLY @40074 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #13940 GOTO 3
  IF ~~ THEN REPLY #13941 GOTO 8
END

IF ~~ THEN BEGIN 3
  SAY #13942
  IF ~~ THEN REPLY @40075 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #13944 GOTO 4
  IF ~~ THEN REPLY #13945 GOTO 10
END

IF ~~ THEN BEGIN 4
  SAY #13946
  IF ~~ THEN REPLY #13947 DO ~Enemy()~ EXIT
  IF ~  CheckSkillGT(Protagonist,6,Diplomacy)
~ THEN REPLY #13948 GOTO 5
  IF ~~ THEN REPLY #13949 GOTO 8
END

IF ~~ THEN BEGIN 5
  SAY #13950
  IF ~~ THEN REPLY #13951 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY @40076 GOTO 6
  IF ~~ THEN REPLY #13953 GOTO 8
END

IF ~~ THEN BEGIN 6
  SAY #13960
  IF ~~ THEN REPLY #13961 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #13983 GOTO 7
  IF ~!NumInParty(6)
!ClassEx(Protagonist, Paladin)~ THEN REPLY @40077 GOTO VunargJoin1
  IF ~~ THEN REPLY #13984 GOTO 8
END

IF WEIGHT #0 ~  False()
~ THEN BEGIN 7
  SAY #13985
  IF ~~ THEN REPLY #13987 DO ~AddXpVar("Level_5_Average",13928)
SetGlobal("30gobVun_leave", "GLOBAL", 1)
StartCutSceneMode()
StartCutScene("30cVunLv")~ JOURNAL #13925 EXIT
END

IF ~~ THEN BEGIN 8
  SAY #28364
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 9
  SAY @40078
  IF ~~ THEN REPLY #37967 DO ~AddXpVar("Level_5_Hard",13928)
SetGlobal("30gobVun_leave", "GLOBAL", 1)
StartCutSceneMode()
StartCutScene("30cVunLv")~ JOURNAL #37968 EXIT
END

IF ~~ THEN BEGIN 10
  SAY ~They don't.  Let me show you.~
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN VunargJoin1
  SAY @40079
  IF ~CheckSkillGT(Protagonist,4,Intimidate)~ THEN REPLY @40080 GOTO VunargJoin2
  IF ~!CheckSkillGT(Protagonist,4,Intimidate)~ THEN REPLY @40081 GOTO VunargJoinFailed
END

IF ~~ THEN BEGIN VunargJoinFailed
  SAY @40082
  IF ~~ THEN REPLY #13961 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #13983 GOTO 7
END

IF ~~ THEN BEGIN VunargJoin2
  SAY @40083
  IF ~~ THEN REPLY @40084 GOTO VunargJoin3
  IF ~~ THEN REPLY @40085 GOTO VunargJoin3
END

IF ~~ THEN BEGIN VunargJoin3
  SAY @40086
  IF ~~ THEN REPLY @40087 GOTO VunargJoin4
END

IF ~~ THEN BEGIN VunargJoin4
  SAY @40088
  IF ~~ THEN REPLY @40089 GOTO VunargJoin5
  IF ~~ THEN REPLY @40090 GOTO VunargJoin5
  IF ~~ THEN REPLY @40091 GOTO VunargJoin5
END

IF ~~ THEN BEGIN VunargJoin5
  SAY @40092
  IF ~~ THEN DO ~FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)~ GOTO VunargJoin6
END

IF ~~ THEN BEGIN VunargJoin6
  SAY @40093
  IF ~~ THEN REPLY @40094 GOTO VunargJoin7
  IF ~~ THEN REPLY @40095 GOTO VunargJoin7
  IF ~~ THEN REPLY @40096 GOTO VunargJoin7
END

IF ~~ THEN BEGIN VunargJoin7
  SAY @40097
  IF ~~ THEN REPLY @40098 GOTO VunargJoin8
END

IF ~~ THEN BEGIN VunargJoin8
  SAY @40099
  IF ~~ THEN REPLY @40100 DO ~SetGlobal("US_Vunarg_Joined", "GLOBAL", 1)
ApplySpellRES("USVUNAC",Myself)~ EXIT
END
