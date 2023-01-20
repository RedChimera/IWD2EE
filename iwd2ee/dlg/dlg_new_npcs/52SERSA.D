BEGIN ~52SERSA~

IF ~  True()
~ THEN BEGIN 0
  SAY #9959
  IF ~  NumberOfTimesTalkedTo(0)
!Global("52Sersa_Train","GLOBAL",2)
~ THEN REPLY #9960 GOTO 1
  IF ~  NumTimesTalkedToGT(0)
!Global("52Sersa_Train","GLOBAL",2)
~ THEN REPLY #9961 GOTO 8
  IF ~  Global("52Sersa_Train","GLOBAL",2)
~ THEN REPLY #9961 GOTO 10
  IF ~~ THEN REPLY #9962 EXIT
END

IF ~~ THEN BEGIN 1
  SAY #9963
  IF ~~ THEN REPLY #9964 DO ~StartStore("52Sersa", Protagonist)~ EXIT
  IF ~~ THEN REPLY #9965 GOTO 2
  IF ~~ THEN REPLY #9966 EXIT
END

IF ~~ THEN BEGIN 2
  SAY #9967
  IF ~  GlobalLT("52Sersa_Train","GLOBAL",2)
~ THEN REPLY #9968 DO ~StartStore("52Sersa", Protagonist)~ EXIT
  IF ~  Global("52Sersa_Train","GLOBAL",2)
~ THEN REPLY #9968 GOTO 7
  IF ~  Global("52Sersa_Train","GLOBAL",0)
~ THEN REPLY #9969 DO ~SetGlobal("52Sersa_Train", "GLOBAL", 1)~ JOURNAL #9955 GOTO 3
  IF ~~ THEN REPLY #9970 EXIT
END

IF ~~ THEN BEGIN 3
  SAY #9971
  IF ~  CheckStatGT(Protagonist,9,CLASSLEVELMONK)
CheckStatLT(Protagonist,15,WIS)
~ THEN REPLY #9972 GOTO 4
  IF ~  CheckStatGT(Protagonist,0,CLASSLEVELMONK)
CheckStatLT(Protagonist,10,CLASSLEVELMONK)
CheckStatGT(Protagonist,14,WIS)
~ THEN REPLY #9973 GOTO 4
  IF ~  CheckStatGT(Protagonist,0,CLASSLEVELMONK)
CheckStatLT(Protagonist,10,CLASSLEVELMONK)
CheckStatLT(Protagonist,15,WIS)
~ THEN REPLY #9972 GOTO 4
  IF ~  CheckStatGT(Protagonist,9,CLASSLEVELMONK)
CheckStatGT(Protagonist,14,WIS)
~ THEN REPLY #9974 DO ~AddXpVar("Level_11_Easy",9958)
SetGlobal("52Sersa_Train", "GLOBAL", 2)
FadeToColor([0.0],0)
FadeFromColor([0.0],0)~ JOURNAL #9956 GOTO 6
  IF ~~ THEN REPLY #9975 GOTO 5
  IF ~~ THEN REPLY #9976 DO ~StartStore("52Sersa", Protagonist)~ EXIT
  IF ~~ THEN REPLY #9970 EXIT
END

IF ~~ THEN BEGIN 4
  SAY #9977
  IF ~~ THEN REPLY #9975 GOTO 5
  IF ~~ THEN REPLY #9964 DO ~StartStore("52Sersa", Protagonist)~ EXIT
  IF ~~ THEN REPLY #9978 EXIT
END

IF ~~ THEN BEGIN 5
  SAY #9979
  IF ~~ THEN REPLY #9964 DO ~StartStore("52Sersa", Protagonist)~ EXIT
  IF ~~ THEN REPLY #9978 EXIT
END

IF ~~ THEN BEGIN 6
  SAY #9980
  IF ~~ THEN REPLY #9981 GOTO 7
  IF ~~ THEN REPLY #9978 EXIT
  IF ~!NumInParty(6)~ THEN REPLY @40153 GOTO SersaJoinMonk1
END

IF ~~ THEN BEGIN 7
  SAY #9982
  IF ~~ THEN REPLY #9983 DO ~FadeToColor([0.0],0)
FadeFromColor([0.0],0)
RestParty()~ EXIT
  IF ~~ THEN REPLY #9984 DO ~FadeToColor([0.0],0)
FadeFromColor([0.0],0)
RestUntilHealed()~ EXIT
  IF ~~ THEN REPLY #9966 EXIT
END

IF ~~ THEN BEGIN 8
  SAY #9985
  IF ~  Global("52Sersa_Train","GLOBAL",1)
CheckStatGT(Protagonist,9,CLASSLEVELMONK)
CheckStatGT(Protagonist,14,WIS)
~ THEN REPLY #9986 DO ~AddXpVar("Level_11_Easy",9958)
SetGlobal("52Sersa_Train", "GLOBAL", 2)
FadeToColor([0.0],0)
FadeFromColor([0.0],0)~ JOURNAL #9956 GOTO 6
  IF ~  Global("52Sersa_Train","GLOBAL",1)
Global("52Svaltid_Sersa","GLOBAL",1)
~ THEN REPLY #9988 DO ~AddXpVar("Level_11_Easy",9958)
SetGlobal("52Sersa_Train", "GLOBAL", 2)~ JOURNAL #9957 GOTO 9
  IF ~~ THEN REPLY #9964 DO ~StartStore("52Sersa", Protagonist)~ EXIT
  IF ~~ THEN REPLY #9965 GOTO 2
  IF ~~ THEN REPLY #9966 EXIT
END

IF ~~ THEN BEGIN 9
  SAY #9989
  IF ~~ THEN REPLY #9981 GOTO 7
  IF ~~ THEN REPLY #9978 EXIT
  IF ~CheckSkillGT(Protagonist,9,Diplomacy)
!NumInParty(6)
!Global("US_Sersa_Says_No", "GLOBAL", 1)~ THEN REPLY @40153 GOTO SersaJoinSvaltid1
END

IF ~~ THEN BEGIN 10
  SAY #9991
  IF ~~ THEN REPLY #9981 GOTO 7
  IF ~~ THEN REPLY #9965 GOTO 2
  IF ~~ THEN REPLY #9966 EXIT
END

IF ~~ THEN BEGIN SersaJoinSvaltid1
  SAY @40155
  IF ~~ THEN REPLY @40156 GOTO SersaJoinSvaltid2
END

IF ~~ THEN BEGIN SersaJoinSvaltid2
  SAY @40157
  IF ~CheckStatGT(Protagonist,6,CHR)~ THEN REPLY @40158 GOTO SersaJoinSvaltid3
  IF ~!CheckStatGT(Protagonist,6,CHR)~ THEN REPLY @40158 GOTO SersaJoinSvaltidFailed
  IF ~CheckStatGT(Protagonist,17,CHR)~ THEN REPLY @40159 GOTO SersaJoinSvaltid3
  IF ~!CheckStatGT(Protagonist,17,CHR)~ THEN REPLY @40159 GOTO SersaJoinSvaltidFailed
  IF ~CheckStatGT(Protagonist,8,CHR)~ THEN REPLY @40160 GOTO SersaJoinSvaltid3
  IF ~!CheckStatGT(Protagonist,8,CHR)~ THEN REPLY @40160 GOTO SersaJoinSvaltidFailed
  IF ~CheckStatGT(Protagonist,22,CHR)
!ClassEx(Protagonist, Paladin)~ THEN REPLY @40161 GOTO SersaJoinMonk3Alternate
  IF ~!CheckStatGT(Protagonist,22,CHR)
!ClassEx(Protagonist, Paladin)~ THEN REPLY @40161 GOTO SersaJoinSvaltidFailed
  IF ~CheckStatGT(Protagonist,16,CHR)
!ClassEx(Protagonist, Paladin)~ THEN REPLY @40162 GOTO SersaJoinMonk3Alternate
  IF ~!CheckStatGT(Protagonist,16,CHR)
!ClassEx(Protagonist, Paladin)~ THEN REPLY @40162 GOTO SersaJoinSvaltidFailed
  IF ~CheckStatGT(Protagonist,5,CHR)~ THEN REPLY @40163 GOTO SersaJoinSvaltid3
  IF ~!CheckStatGT(Protagonist,5,CHR)~ THEN REPLY @40163 GOTO SersaJoinSvaltidFailed
  IF ~CheckStatGT(Protagonist,24,CHR)~ THEN REPLY @40164 GOTO SersaJoinMonk3Alternate
  IF ~!CheckStatGT(Protagonist,24,CHR)~ THEN REPLY @40164 GOTO SersaJoinSvaltidFailed
  IF ~CheckStatGT(Protagonist,10,CHR)~ THEN REPLY @40165 GOTO SersaJoinSvaltid3
  IF ~!CheckStatGT(Protagonist,10,CHR)~ THEN REPLY @40165 GOTO SersaJoinSvaltidFailed
  IF ~CheckStatGT(Protagonist,21,CHR)~ THEN REPLY @40166 GOTO SersaJoinMonk3Alternate
  IF ~!CheckStatGT(Protagonist,21,CHR)~ THEN REPLY @40166 GOTO SersaJoinSvaltidFailed
END

IF ~~ THEN BEGIN SersaJoinSvaltidFailed
  SAY @40167
  IF ~~ THEN REPLY @40168 DO ~SetGlobal("US_Sersa_Says_No", "GLOBAL", 1)~ EXIT
END

IF ~~ THEN BEGIN SersaJoinSvaltid3
  SAY @40169
  IF ~Global("52Exile","GLOBAL",0)~ THEN REPLY @40170 DO ~FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)
RestUntilHealed()~ GOTO SersaJoinMonk4Salisam
  IF ~Global("52Exile","GLOBAL",1)~ THEN REPLY @40170 DO ~FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)
RestUntilHealed()~ GOTO SersaJoinMonk4Aruma
END

IF ~~ THEN BEGIN SersaJoinMonk1
  SAY @40155
  IF ~~ THEN REPLY @40171 GOTO SersaJoinMonk2
END

IF ~~ THEN BEGIN SersaJoinMonk2
  SAY @40172
  IF ~~ THEN REPLY @40158 GOTO SersaJoinMonk3
  IF ~~ THEN REPLY @40159 GOTO SersaJoinMonk3
  IF ~~ THEN REPLY @40160  GOTO SersaJoinMonk3
  IF ~~ THEN REPLY @40163 GOTO SersaJoinMonk3
END

IF ~~ THEN BEGIN SersaJoinMonk3
  SAY @40173
  IF ~Global("52Exile","GLOBAL",0)~ THEN REPLY @40170 DO ~FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)
RestUntilHealed()~ GOTO SersaJoinMonk4Salisam
  IF ~Global("52Exile","GLOBAL",1)~ THEN REPLY @40170 DO ~FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)
RestUntilHealed()~ GOTO SersaJoinMonk4Aruma
END

IF ~~ THEN BEGIN SersaJoinMonk3Alternate
  SAY @40174
  IF ~Global("52Exile","GLOBAL",0)~ THEN REPLY @40170 DO ~FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)
RestUntilHealed()~ GOTO SersaJoinMonk4Salisam
  IF ~Global("52Exile","GLOBAL",1)~ THEN REPLY @40170 DO ~FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)
RestUntilHealed()~ GOTO SersaJoinMonk4Aruma
END

IF ~~ THEN BEGIN SersaJoinMonk4Salisam
  SAY @40175
  IF ~~ THEN REPLY @40177 DO ~SetGlobal("US_Sersa_Joined", "GLOBAL", 1)
ApplySpellRES("USSERSC",Myself)~ EXIT
END

IF ~~ THEN BEGIN SersaJoinMonk4Aruma
  SAY @40176
  IF ~~ THEN REPLY @40177 DO ~SetGlobal("US_Sersa_Joined", "GLOBAL", 1)
ApplySpellRES("USSERSC",Myself)~ EXIT
END
