BEGIN ~20TORAK~

IF WEIGHT #6 ~  NumberOfTimesTalkedTo(0)
Race(Protagonist,HUMAN)
~ THEN BEGIN 0
  SAY #36212
  IF ~~ THEN REPLY #36213 GOTO 1
  IF ~~ THEN REPLY #36214 GOTO 4
  IF ~~ THEN REPLY #36215 GOTO 5
END

IF ~~ THEN BEGIN 1
  SAY #36216
  IF ~~ THEN REPLY #36217 JOURNAL #36210 GOTO 2
  IF ~  !ClassEx(Protagonist,PALADIN)
~ THEN REPLY #36218 JOURNAL #36210 GOTO 3
END

IF ~~ THEN BEGIN 2
  SAY #36219
  IF ~~ THEN REPLY #36220 DO ~SetGlobal("SR_Torak_Talk","GLOBAL", 1)
StartCutscene("20cTora1")~ EXIT
END

IF ~~ THEN BEGIN 3
  SAY #36221
  IF ~~ THEN REPLY #36220 DO ~SetGlobal("SR_Torak_Talk","GLOBAL", 1)
StartCutsceneMode()
StartCutscene("20cTora1")~ EXIT
END

IF ~~ THEN BEGIN 4
  SAY #36222
  IF ~~ THEN REPLY #36220 DO ~SetGlobal("SR_Torak_Talk","GLOBAL", 1)
StartCutsceneMode()
StartCutscene("20cTora1")
~ EXIT
END

IF ~~ THEN BEGIN 5
  SAY #36223
  IF ~~ THEN REPLY #36220 DO ~SetGlobal("SR_Torak_Talk","GLOBAL", 1)
StartCutsceneMode()
StartCutscene("20cTora1")
~ EXIT
END

IF WEIGHT #7 ~  NumberOfTimesTalkedTo(0)
Race(Protagonist,DWARF)
~ THEN BEGIN 6
  SAY #36224
  IF ~~ THEN REPLY #36213 GOTO 1
  IF ~~ THEN REPLY #36214 GOTO 4
  IF ~~ THEN REPLY #36215 GOTO 5
END

IF WEIGHT #12 ~  NumberOfTimesTalkedTo(0)
Race(Protagonist,ELF)
~ THEN BEGIN 7
  SAY #36225
  IF ~~ THEN REPLY #36213 GOTO 1
  IF ~~ THEN REPLY #36214 GOTO 4
  IF ~~ THEN REPLY #36215 GOTO 5
END

IF WEIGHT #9 ~  NumberOfTimesTalkedTo(0)
Race(Protagonist,GNOME)
~ THEN BEGIN 8
  SAY #36226
  IF ~~ THEN REPLY #36213 GOTO 1
  IF ~~ THEN REPLY #36214 GOTO 4
  IF ~~ THEN REPLY #36215 GOTO 5
END

IF WEIGHT #10 ~  NumberOfTimesTalkedTo(0)
Race(Protagonist,HALF_ELF)
~ THEN BEGIN 9
  SAY #36227
  IF ~~ THEN REPLY #36213 GOTO 1
  IF ~~ THEN REPLY #36214 GOTO 4
  IF ~~ THEN REPLY #36215 GOTO 5
END

IF WEIGHT #11 ~  NumberOfTimesTalkedTo(0)
Race(Protagonist,HALFLING)
~ THEN BEGIN 10
  SAY #36228
  IF ~~ THEN REPLY #36213 GOTO 1
  IF ~~ THEN REPLY #36214 GOTO 4
  IF ~~ THEN REPLY #36215 GOTO 5
END

IF WEIGHT #8 ~  NumberOfTimesTalkedTo(0)
SubRace(Protagonist,ELF_DROW)
~ THEN BEGIN 11
  SAY #36229
  IF ~~ THEN REPLY #36213 GOTO 1
  IF ~~ THEN REPLY #36214 GOTO 4
  IF ~~ THEN REPLY #36215 GOTO 5
END

IF WEIGHT #13 ~  NumberOfTimesTalkedTo(0)
Gender(Protagonist,MALE)
Race(Protagonist,HALFORC)
~ THEN BEGIN 12
  SAY #36230
  IF ~~ THEN REPLY #36231 JOURNAL #36210 GOTO 13
  IF ~~ THEN REPLY #36232 GOTO 14
  IF ~~ THEN REPLY #36233 GOTO 15
END

IF ~~ THEN BEGIN 13
  SAY #36234
  IF ~~ THEN REPLY #36232 GOTO 14
  IF ~~ THEN REPLY #36235 GOTO 15
END

IF ~~ THEN BEGIN 14
  SAY #36236
  IF ~~ THEN REPLY #36235 GOTO 15
END

IF ~~ THEN BEGIN 15
  SAY #36237
  IF ~~ THEN REPLY #36238 DO ~SetGlobal("SR_Torak_Talk","GLOBAL", 1)
StartCutsceneMode()
StartCutscene("20cTora1")~ EXIT
END

IF WEIGHT #14 ~  NumberOfTimesTalkedTo(0)
Race(Protagonist,HALFORC)
Gender(Protagonist,FEMALE)
~ THEN BEGIN 16
  SAY #36239
  IF ~~ THEN REPLY #36231 JOURNAL #36210 GOTO 17
  IF ~~ THEN REPLY #36232 GOTO 18
  IF ~~ THEN REPLY #36233 GOTO 19
END

IF ~~ THEN BEGIN 17
  SAY #36234
  IF ~~ THEN REPLY #36232 GOTO 18
  IF ~~ THEN REPLY #36235 GOTO 19
END

IF ~~ THEN BEGIN 18
  SAY #36240
  IF ~~ THEN REPLY #36235 GOTO 19
END

IF ~~ THEN BEGIN 19
  SAY #36241
  IF ~~ THEN REPLY #36238 DO ~SetGlobal("SR_Torak_Talk","GLOBAL", 1)
StartCutsceneMode()
StartCutscene("20cTora1")
~ EXIT
END

IF WEIGHT #15 ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 20
  SAY #36242
  IF ~~ THEN REPLY #36213 GOTO 1
  IF ~~ THEN REPLY #36214 GOTO 4
  IF ~~ THEN REPLY #36215 GOTO 5
END

IF WEIGHT #5 ~  Global("SR_Torak_Talk","GLOBAL",1)
~ THEN BEGIN 21
  SAY #36243
  IF ~~ THEN REPLY #36244 DO ~SetGlobal("SR_Torak_Talk","GLOBAL", 2)
StartCutsceneMode()
StartCutscene("20cTora2")
~ EXIT
END

IF WEIGHT #4 ~  Global("SR_Torak_Talk","GLOBAL",2)
~ THEN BEGIN 22
  SAY #36245
  IF ~~ THEN REPLY #36246 DO ~SetGlobal("SR_Torak_Talk","GLOBAL", 3)
StartCutsceneMode()
StartCutscene("20cTora3")
~ JOURNAL #36210 EXIT
END

IF WEIGHT #3 ~  Global("SR_Torak_Talk","GLOBAL",3)
~ THEN BEGIN 23
  SAY #36247
  IF ~~ THEN REPLY #36248 DO ~SetGlobal("SR_Torak_Talk","GLOBAL", 4)
StartCutsceneMode()
StartCutscene("20cTora4")
~ JOURNAL #36211 EXIT
END

IF WEIGHT #2 ~  Global("SR_Torak_Talk","GLOBAL",4)
~ THEN BEGIN 24
  SAY #36249
  IF ~~ THEN DO ~SetGlobal("SR_Torak_Talk","GLOBAL", 5)
StartCutSceneMode()
StartCutscene("20c2001")~ EXIT
END

IF WEIGHT #1 ~  Global("SR_Torak_Talk","GLOBAL",5)
~ THEN BEGIN 25
  SAY #36251
  IF ~  !GlobalGT("SR_Rescue_Villagers","GLOBAL",3)
!ClassEx(Protagonist,PALADIN)
~ THEN REPLY #36252 GOTO 26
  IF ~  !GlobalGT("SR_Rescue_Villagers","GLOBAL",3)
~ THEN REPLY #36253 GOTO 27
  IF ~  GlobalGT("SR_Rescue_Villagers","GLOBAL",3)
~ THEN REPLY #36254 GOTO 28
  IF ~  GlobalGT("SR_Rescue_Villagers","GLOBAL",3)
!ClassEx(Protagonist,PALADIN)
~ THEN REPLY #36255 GOTO 29
END

IF ~~ THEN BEGIN 26
  SAY #36256
  IF ~~ THEN REPLY #36257 DO ~Enemy()
SetGlobal("SR_Villagers_Dead","GLOBAL", 1)~ EXIT
  IF ~CheckSkillGT(Protagonist,7,Intimidate)~ THEN REPLY ~I have a better idea.  Broken Tusk Clan!  Torak has sent *scores* of your brothers to their deaths because he was too afraid to face us himself!  Is this the orc you want as your leader?~ GOTO TorakIntimidate
END

IF ~~ THEN BEGIN 27
  SAY #36258
  IF ~~ THEN REPLY #36259 DO ~SetGlobal("SR_Accepted_Threat","GLOBAL", 1)
StartCutSceneMode()
StartCutScene("20cTjump")~ EXIT
END

IF ~~ THEN BEGIN 28
  SAY #36260
  IF ~~ THEN REPLY #36257 DO ~Enemy()~ EXIT
  IF ~CheckSkillGT(Protagonist,7,Intimidate)~ THEN REPLY ~I have a better idea.  Broken Tusk Clan!  Torak has sent *scores* of your brothers to their deaths because he was too afraid to face us himself!  Is this the orc you want as your leader?~ GOTO TorakIntimidate
END

IF ~~ THEN BEGIN 29
  SAY #36261
  IF ~~ THEN REPLY #36257 DO ~Enemy()~ EXIT
  IF ~CheckSkillGT(Protagonist,7,Intimidate)~ THEN REPLY ~I have a better idea.  Broken Tusk Clan!  Torak has sent *scores* of your brothers to their deaths because he was too afraid to face us himself!  Is this the orc you want as your leader?~ GOTO TorakIntimidate
END

IF WEIGHT #0 ~  Global("SR_Accepted_Threat","GLOBAL",1)
~ THEN BEGIN 30
  SAY #36262
  IF ~  !GlobalGT("SR_Rescue_Villagers","GLOBAL",3)
~ THEN REPLY #36542 DO ~Enemy()
SetGlobal("SR_Villagers_Dead","GLOBAL", 1)~ EXIT
  IF ~  GlobalGT("SR_Rescue_Villagers","GLOBAL",3)
~ THEN REPLY #36254 GOTO 28
  IF ~  GlobalGT("SR_Rescue_Villagers","GLOBAL",3)
!ClassEx(Protagonist,PALADIN)
~ THEN REPLY #36255 GOTO 29
END

IF ~~ THEN BEGIN TorakIntimidate
  SAY ~What? Bro-broken Tusk Clan! Slay them! Slay them all!~
  IF ~~ THEN REPLY ~Whoever wants him gone is no enemy of ours.  We're only here to collect one head.  But whoever wants to defend him is welcome to try!~ DO ~Enemy() SetGlobal("RUNTORG","GLOBAL",1)~ EXIT
END

