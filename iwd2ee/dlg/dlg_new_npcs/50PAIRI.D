BEGIN ~50PAIRI~

IF WEIGHT #1 ~  NumberOfTimesTalkedTo(0)
CheckStatGT(Protagonist,15,CHR)
Race(Protagonist,HALF_ELF)
Gender(Protagonist,MALE)
~ THEN BEGIN 0
  SAY #13991
  IF ~~ THEN REPLY #13992 GOTO 3
  IF ~~ THEN REPLY #13993 DO ~SetGlobal("50Pairi", "GLOBAL", 1)~ GOTO 6
  IF ~  Class(Protagonist,SORCERER)
~ THEN REPLY #13994 GOTO 10
  IF ~  !Class(Protagonist,SORCERER)
~ THEN REPLY #13994 EXIT
END

IF WEIGHT #2 ~  NumberOfTimesTalkedTo(0)
Race(Protagonist,HALF_ELF)
~ THEN BEGIN 1
  SAY #13996
  IF ~  GlobalGT("50Hunter_Know","GLOBAL",0)
~ THEN REPLY #13997 DO ~SetGlobal("50PairiQ", "GLOBAL", 1)~ GOTO 4
  IF ~~ THEN REPLY #13998 GOTO 3
  IF ~  Class(Protagonist,SORCERER)
~ THEN REPLY #14135 GOTO 10
  IF ~  !Class(Protagonist,SORCERER)
~ THEN REPLY #14135 EXIT
END

IF WEIGHT #3 ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 2
  SAY #14136
  IF ~  GlobalGT("50Hunter_Know","GLOBAL",0)
~ THEN REPLY #14137 DO ~SetGlobal("50PairiQ", "GLOBAL", 1)~ GOTO 4
  IF ~~ THEN REPLY #14138 GOTO 3
  IF ~  Class(Protagonist,SORCERER)
~ THEN REPLY #14135 GOTO 10
  IF ~  !Class(Protagonist,SORCERER)
~ THEN REPLY #14135 EXIT
END

IF ~~ THEN BEGIN 3
  SAY #14139
  IF ~  CheckStatGT(Protagonist,15,CHR)
Race(Protagonist,HALF_ELF)
Gender(Protagonist,MALE)
Global("50Pairi","GLOBAL",0)
~ THEN REPLY #14140 DO ~SetGlobal("50Pairi", "GLOBAL", 1)~ GOTO 6
  IF ~  CheckStatGT(Protagonist,15,CHR)
Race(Protagonist,HALF_ELF)
Gender(Protagonist,MALE)
Global("50Pairi","GLOBAL",1)
~ THEN REPLY #14140 GOTO 17
  IF ~  GlobalGT("50Hunter_Know","GLOBAL",0)
Global("50PairiQ","GLOBAL",0)
~ THEN REPLY #14137 DO ~SetGlobal("50PairiQ", "GLOBAL", 1)~ GOTO 4
  IF ~  GlobalGT("AR5002_Visited","Global",0)
Global("50Venla_Children","Global",1)
~ THEN REPLY #34341 GOTO 19
  IF ~  Global("50Tahvo_Wight","Global",1)
Global("50Wight_Horn","GLOBAL",0)
~ THEN REPLY #37897 GOTO 19
  IF ~  Global("50Wight_Horn","GLOBAL",1)
~ THEN REPLY #37898 JOURNAL #37610 GOTO 21
  IF ~  GlobalGT("AR5010_Visited","Global",0)
!Global("50Suoma_Help","Global",5)
Global("50Carynara_Help","Global",0)
~ THEN REPLY #37899 JOURNAL #38160 GOTO 20
  IF ~~ THEN REPLY #392 GOTO 5
  IF ~  Class(Protagonist,SORCERER)
Global("50Sorcery","GLOBAL",0)
~ THEN REPLY #14142 DO ~SetGlobal("50Sorcery", "GLOBAL", 1)~ GOTO 10
  IF ~  Class(Protagonist,SORCERER)
GlobalGT("50Sorcery","GLOBAL",0)
~ THEN REPLY #14142 EXIT
  IF ~  !Class(Protagonist,SORCERER)
~ THEN REPLY #14142 EXIT
END

IF ~~ THEN BEGIN 4
  SAY #14143
  IF ~  CheckStatGT(Protagonist,15,CHR)
Race(Protagonist,HALF_ELF)
Gender(Protagonist,MALE)
Global("50Pairi","GLOBAL",0)
~ THEN REPLY #14148 DO ~SetGlobal("50Pairi", "GLOBAL", 1)~ GOTO 6
  IF ~  CheckStatGT(Protagonist,15,CHR)
Race(Protagonist,HALF_ELF)
Gender(Protagonist,MALE)
Global("50Pairi","GLOBAL",1)
~ THEN REPLY #14148 GOTO 17
  IF ~~ THEN REPLY #36931 GOTO 5
  IF ~  Class(Protagonist,SORCERER)
Global("50Sorcery","GLOBAL",0)
~ THEN REPLY #14160 DO ~SetGlobal("50Sorcery", "GLOBAL", 1)~ GOTO 10
  IF ~  Class(Protagonist,SORCERER)
GlobalGT("50Sorcery","GLOBAL",0)
~ THEN REPLY #14160 EXIT
  IF ~  !Class(Protagonist,SORCERER)
~ THEN REPLY #14160 EXIT
END

IF ~~ THEN BEGIN 5
  SAY #14163
  IF ~  CheckStatGT(Protagonist,15,CHR)
Race(Protagonist,HALF_ELF)
Gender(Protagonist,MALE)
Global("50Pairi","GLOBAL",0)
~ THEN REPLY #14164 DO ~SetGlobal("50Pairi", "GLOBAL", 1)~ GOTO 6
  IF ~  CheckStatGT(Protagonist,15,CHR)
Race(Protagonist,HALF_ELF)
Gender(Protagonist,MALE)
Global("50Pairi","GLOBAL",1)
~ THEN REPLY #14164 GOTO 17
  IF ~  GlobalGT("50Hunter_Know","GLOBAL",0)
Global("50PairiQ","GLOBAL",0)
~ THEN REPLY #14165 DO ~SetGlobal("50PairiQ", "GLOBAL", 1)~ GOTO 4
  IF ~~ THEN REPLY #36931 GOTO 3
  IF ~  Class(Protagonist,SORCERER)
Global("50Sorcery","GLOBAL",0)
~ THEN REPLY #14160 DO ~SetGlobal("50Sorcery", "GLOBAL", 1)~ GOTO 10
  IF ~  Class(Protagonist,SORCERER)
GlobalGT("50Sorcery","GLOBAL",0)
~ THEN REPLY #14160 EXIT
  IF ~  !Class(Protagonist,SORCERER)
~ THEN REPLY #14160 EXIT
  IF ~!NumInParty(6)
Global("50Sorcery", "GLOBAL", 2)~ THEN REPLY ~Actually, I was wondering if you would be willing to join our group.  We have room for a budding sorceress.~ GOTO PairiJoin1
END

IF ~~ THEN BEGIN 6
  SAY #14166
  IF ~~ THEN REPLY #14170 DO ~SetGlobal("50Pairi", "GLOBAL", 2)~ GOTO 7
  IF ~~ THEN REPLY #14185 DO ~SetGlobal("50Pairi", "GLOBAL", 2)~ GOTO 7
  IF ~~ THEN REPLY #14186 GOTO 8
  IF ~~ THEN REPLY #14187 GOTO 9
  IF ~!NumInParty(6)
Global("50Sorcery", "GLOBAL", 2)~ THEN REPLY ~Why wait?  We have room for another sorcerer in our group.  You could come along with us.~ GOTO PairiJoin1
END

IF ~~ THEN BEGIN 7
  SAY #14188
  IF ~  GlobalGT("50Hunter_Know","GLOBAL",0)
Global("50PairiQ","GLOBAL",0)
~ THEN REPLY #14189 DO ~SetGlobal("50PairiQ", "GLOBAL", 1)~ GOTO 4
  IF ~~ THEN REPLY #14138 GOTO 3
  IF ~  Class(Protagonist,SORCERER)
Global("50Sorcery","GLOBAL",0)
~ THEN REPLY #14190 DO ~SetGlobal("50Sorcery", "GLOBAL", 1)~ GOTO 10
  IF ~  Class(Protagonist,SORCERER)
GlobalGT("50Sorcery","GLOBAL",0)
~ THEN REPLY #14190 EXIT
  IF ~  !Class(Protagonist,SORCERER)
~ THEN REPLY #14190 EXIT
END

IF ~~ THEN BEGIN 8
  SAY #14191
  IF ~  GlobalGT("50Hunter_Know","GLOBAL",0)
Global("50PairiQ","GLOBAL",0)
~ THEN REPLY #14189 DO ~SetGlobal("50PairiQ", "GLOBAL", 1)~ GOTO 4
  IF ~~ THEN REPLY #14138 GOTO 3
  IF ~  Class(Protagonist,SORCERER)
Global("50Sorcery","GLOBAL",0)
~ THEN REPLY #14190 DO ~SetGlobal("50Sorcery", "GLOBAL", 1)~ GOTO 10
  IF ~  Class(Protagonist,SORCERER)
GlobalGT("50Sorcery","GLOBAL",0)
~ THEN REPLY #14190 EXIT
  IF ~  !Class(Protagonist,SORCERER)
~ THEN REPLY #14190 EXIT
END

IF ~~ THEN BEGIN 9
  SAY #14192
  IF ~  GlobalGT("50Hunter_Know","GLOBAL",0)
Global("50PairiQ","GLOBAL",0)
~ THEN REPLY #14189 DO ~SetGlobal("50PairiQ", "GLOBAL", 1)~ GOTO 4
  IF ~~ THEN REPLY #14138 GOTO 3
  IF ~  Class(Protagonist,SORCERER)
Global("50Sorcery","GLOBAL",0)
~ THEN REPLY #14190 DO ~SetGlobal("50Sorcery", "GLOBAL", 1)~ GOTO 10
  IF ~  Class(Protagonist,SORCERER)
GlobalGT("50Sorcery","GLOBAL",0)
~ THEN REPLY #14190 EXIT
  IF ~  !Class(Protagonist,SORCERER)
~ THEN REPLY #14190 EXIT
  IF ~!NumInParty(6)
Global("50Sorcery", "GLOBAL", 2)~ THEN REPLY ~If you want to learn more about magic, we have room for another sorcerer in our group.  You could come along with us.~ GOTO PairiJoin1
END

IF ~~ THEN BEGIN 10
  SAY #14193
  IF ~  CheckStatLT(Protagonist,9,CLASSLEVELSORCERER)
~ THEN REPLY #14194 DO ~SetGlobal("50Sorcery", "GLOBAL", 0)~ GOTO 11
  IF ~  CheckStatGT(Protagonist,8,CLASSLEVELSORCERER)
~ THEN REPLY #14195 GOTO 12
  IF ~~ THEN REPLY #14196 GOTO 11
  IF ~~ THEN REPLY #14197 DO ~SetGlobal("50Sorcery", "GLOBAL", 0)~ EXIT
END

IF ~~ THEN BEGIN 11
  SAY #14198
  IF ~  GlobalGT("50Hunter_Know","GLOBAL",0)
Global("50PairiQ","GLOBAL",0)
~ THEN REPLY #14189 DO ~SetGlobal("50PairiQ", "GLOBAL", 1)~ GOTO 4
  IF ~~ THEN REPLY #14138 GOTO 3
  IF ~~ THEN REPLY #14190 EXIT
END

IF ~~ THEN BEGIN 12
  SAY #14199
  IF ~~ THEN REPLY #14200 DO ~AddXpVar("Level_9_Easy",13990)
SetGlobal("50Sorcery", "GLOBAL", 2)
FadeToColor([0.0],0)
FadeFromColor([0.0],0)~ JOURNAL #13923 GOTO 13
END

IF ~~ THEN BEGIN 13
  SAY #14201
  IF ~  CheckStatGT(Protagonist,15,CHR)
Race(Protagonist,HALF_ELF)
Gender(Protagonist,MALE)
Global("50Pairi","GLOBAL",0)
~ THEN REPLY #14202 DO ~SetGlobal("50Pairi", "GLOBAL", 1)~ GOTO 6
  IF ~  CheckStatGT(Protagonist,15,CHR)
Race(Protagonist,HALF_ELF)
Gender(Protagonist,MALE)
Global("50Pairi","GLOBAL",1)
~ THEN REPLY #14202 GOTO 17
  IF ~  GlobalGT("50Hunter_Know","GLOBAL",0)
Global("50PairiQ","GLOBAL",0)
~ THEN REPLY #14165 DO ~SetGlobal("50PairiQ", "GLOBAL", 1)~ GOTO 4
  IF ~~ THEN REPLY #14138 GOTO 3
  IF ~!NumInParty(6)
Global("50Sorcery", "GLOBAL", 2)~ THEN REPLY ~If you want to learn more, we have room for another sorcerer on our travels.  You could join us, if you want.~ GOTO PairiJoin1
  IF ~~ THEN REPLY #14203 EXIT
END

IF WEIGHT #4 ~  NumTimesTalkedToGT(0)
CheckStatGT(Protagonist,15,CHR)
Race(Protagonist,HALF_ELF)
Gender(Protagonist,MALE)
Global("50Pairi","GLOBAL",0)
~ THEN BEGIN 14
  SAY #14204
  IF ~  CheckStatGT(Protagonist,15,CHR)
Race(Protagonist,HALF_ELF)
Gender(Protagonist,MALE)
Global("50Pairi","GLOBAL",0)
~ THEN REPLY #14205 DO ~SetGlobal("50Pairi", "GLOBAL", 1)~ GOTO 6
  IF ~  GlobalGT("50Hunter_Know","GLOBAL",0)
Global("50PairiQ","GLOBAL",0)
~ THEN REPLY #14165 DO ~SetGlobal("50PairiQ", "GLOBAL", 1)~ GOTO 4
  IF ~~ THEN REPLY #14138 GOTO 3
  IF ~  Class(Protagonist,SORCERER)
Global("50Sorcery","GLOBAL",0)
~ THEN REPLY #14206 DO ~SetGlobal("50Sorcery", "GLOBAL", 1)~ GOTO 10
  IF ~  Class(Protagonist,SORCERER)
GlobalGT("50Sorcery","GLOBAL",0)
~ THEN REPLY #14206 EXIT
  IF ~  !Class(Protagonist,SORCERER)
~ THEN REPLY #14206 EXIT
END

IF WEIGHT #5 ~  CheckStatGT(Protagonist,15,CHR)
Race(Protagonist,HALF_ELF)
Gender(Protagonist,MALE)
Global("50Pairi","GLOBAL",1)
~ THEN BEGIN 15
  SAY #14207
  IF ~  CheckStatGT(Protagonist,15,CHR)
Race(Protagonist,HALF_ELF)
Gender(Protagonist,MALE)
~ THEN REPLY #14208 GOTO 17
  IF ~  GlobalGT("50Hunter_Know","GLOBAL",0)
Global("50PairiQ","GLOBAL",0)
~ THEN REPLY #14189 DO ~SetGlobal("50PairiQ", "GLOBAL", 1)~ GOTO 4
  IF ~~ THEN REPLY #14138 GOTO 3
  IF ~  Class(Protagonist,SORCERER)
Global("50Sorcery","GLOBAL",0)
~ THEN REPLY #14206 DO ~SetGlobal("50Sorcery", "GLOBAL", 1)~ GOTO 10
  IF ~  Class(Protagonist,SORCERER)
GlobalGT("50Sorcery","GLOBAL",0)
~ THEN REPLY #14206 EXIT
  IF ~  !Class(Protagonist,SORCERER)
~ THEN REPLY #14206 EXIT
END

IF WEIGHT #6 ~  True()
~ THEN BEGIN 16
  SAY #14212
  IF ~  GlobalGT("50Hunter_Know","GLOBAL",0)
Global("50PairiQ","GLOBAL",0)
~ THEN REPLY #14189 DO ~SetGlobal("50PairiQ", "GLOBAL", 1)~ GOTO 4
  IF ~~ THEN REPLY #14138 GOTO 3
  IF ~  Class(Protagonist,SORCERER)
Global("50Sorcery","GLOBAL",0)
~ THEN REPLY #24531 DO ~SetGlobal("50Sorcery", "GLOBAL", 1)~ GOTO 10
  IF ~  Class(Protagonist,SORCERER)
GlobalGT("50Sorcery","GLOBAL",0)
~ THEN REPLY #24531 EXIT
  IF ~  !Class(Protagonist,SORCERER)
~ THEN REPLY #24531 EXIT
END

IF ~~ THEN BEGIN 17
  SAY #24919
  IF ~  GlobalGT("50Hunter_Know","GLOBAL",0)
Global("50PairiQ","GLOBAL",0)
~ THEN REPLY #14137 DO ~SetGlobal("50PairiQ", "GLOBAL", 1)~ GOTO 4
  IF ~~ THEN REPLY #14138 GOTO 3
  IF ~  Class(Protagonist,SORCERER)
Global("50Sorcery","GLOBAL",0)
~ THEN REPLY #14190 DO ~SetGlobal("50Sorcery", "GLOBAL", 1)~ GOTO 10
  IF ~  Class(Protagonist,SORCERER)
GlobalGT("50Sorcery","GLOBAL",0)
~ THEN REPLY #14190 EXIT
  IF ~  !Class(Protagonist,SORCERER)
~ THEN REPLY #14190 EXIT
END

IF WEIGHT #0 ~See([ENEMY], 0)~ THEN BEGIN 18
  SAY #37856
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 19
  SAY #36929
  IF ~~ THEN REPLY #36931 GOTO 3
  IF ~  Class(Protagonist,SORCERER)
Global("50Sorcery","GLOBAL",0)
~ THEN REPLY #14160 DO ~SetGlobal("50Sorcery", "GLOBAL", 1)~ GOTO 10
  IF ~  Class(Protagonist,SORCERER)
GlobalGT("50Sorcery","GLOBAL",0)
~ THEN REPLY #14160 EXIT
  IF ~  !Class(Protagonist,SORCERER)
~ THEN REPLY #14160 EXIT
END

IF ~~ THEN BEGIN 20
  SAY #36930
  IF ~~ THEN REPLY #36931 GOTO 3
  IF ~  Class(Protagonist,SORCERER)
Global("50Sorcery","GLOBAL",0)
~ THEN REPLY #13994 DO ~SetGlobal("50Sorcery", "GLOBAL", 1)~ GOTO 10
  IF ~  Class(Protagonist,SORCERER)
GlobalGT("50Sorcery","GLOBAL",0)
~ THEN REPLY #13994 EXIT
  IF ~  !Class(Protagonist,SORCERER)
~ THEN REPLY #13994 EXIT
END

IF ~~ THEN BEGIN 21
  SAY #37901
  IF ~~ THEN REPLY #36931 GOTO 3
  IF ~  Class(Protagonist,SORCERER)
Global("50Sorcery","GLOBAL",0)
~ THEN REPLY #13994 DO ~SetGlobal("50Sorcery", "GLOBAL", 1)~ GOTO 10
  IF ~  Class(Protagonist,SORCERER)
GlobalGT("50Sorcery","GLOBAL",0)
~ THEN REPLY #13994 EXIT
  IF ~  !Class(Protagonist,SORCERER)
~ THEN REPLY #13994 EXIT
END

IF ~~ THEN BEGIN PairiJoin1
  SAY ~You would take me with you?  I don't know what to say -- this is so exciting!~
  IF ~~ THEN REPLY ~Just say yes.~ GOTO PairiJoin2
  IF ~~ THEN REPLY ~It could be dangerous.  You'd learn a lot, but you'd be taking a lot of risks, too.  Are you sure you're up to it?~ GOTO PairiJoin2
END

IF ~~ THEN BEGIN PairiJoin2
  SAY ~Yes!  Yes, I'll do it!  I can't wait to get started.  All the places we'll go, all the things we'll see...~
  IF ~~ THEN REPLY ~Welcome to the group, Pairi.  You're now one of the heroes of Targos.~ DO ~SetGlobal("US_Pairi_Joined", "GLOBAL", 1)
ApplySpellRES("USPAIRC",Myself)~ EXIT
  IF ~~ THEN REPLY ~Fall in line, Pairi.  We've got a long march ahead of us.~ DO ~SetGlobal("US_Pairi_Joined", "GLOBAL", 1)
ApplySpellRES("USPAIRC",Myself)~ EXIT
END
