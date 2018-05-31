BEGIN ~41SHERI~

IF ~  NumberOfTimesTalkedTo(0)
!GlobalGT("41PartyPrisonEntry","GLOBAL",1)
~ THEN BEGIN 0
  SAY #23973
  IF ~  Global("FomoriansJoinLegion","GLOBAL",1)
~ THEN REPLY #23974 DO ~SetGlobal("41MentionedGoublika","GLOBAL",1)~ GOTO 19
  IF ~~ THEN REPLY #23975 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41MentionedName","GLOBAL",1)~ JOURNAL #23970 GOTO 1
  IF ~~ THEN REPLY #23976 DO ~SetGlobal("41MentionedRace", "GLOBAL", 1)~ GOTO 2
  IF ~~ THEN REPLY #23977 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41PaintingPhrase6", "GLOBAL", 1)~ GOTO 7
  IF ~~ THEN REPLY #23980 DO ~SetGlobal("41MentionedAurilites", "GLOBAL", 1)~ GOTO 9
  IF ~  BitGlobal("40YurstFlags","GLOBAL",32,AND)
~ THEN REPLY #23981 DO ~SetGlobal("41MentionedYurst", "GLOBAL", 1)~ GOTO 10
END

IF ~~ THEN BEGIN 1
  SAY #23982
  IF ~  Global("41ExplainedLegion","GLOBAL",0)
Or(4)
Race(Protagonist,HALF_ELF)
Race(Protagonist,HALFORC)
SubRace(Protagonist,HUMAN_AASIMAR)
SubRace(Protagonist,HUMAN_TIEFLING)
~ THEN REPLY #23983 DO ~SetGlobal("41ExplainedLegion", "GLOBAL", 1)~ JOURNAL #23971 GOTO 5
  IF ~  Global("41ExplainedLegion","GLOBAL",0)
!Race(Protagonist,HALF_ELF)
!Race(Protagonist,HALFORC)
!SubRace(Protagonist,HUMAN_AASIMAR)
!SubRace(Protagonist,HUMAN_TIEFLING)
~ THEN REPLY #23983 DO ~SetGlobal("41ExplainedLegion", "GLOBAL", 1)~ JOURNAL #23971 GOTO 6
  IF ~  Global("41ExplainedLegion","GLOBAL",1)
Or(4)
Race(Protagonist,HALF_ELF)
Race(Protagonist,HALFORC)
SubRace(Protagonist,HUMAN_AASIMAR)
SubRace(Protagonist,HUMAN_TIEFLING)
~ THEN REPLY #39942 GOTO 5
  IF ~  Global("41ExplainedLegion","GLOBAL",1)
!Race(Protagonist,HALF_ELF)
!Race(Protagonist,HALFORC)
!SubRace(Protagonist,HUMAN_AASIMAR)
!SubRace(Protagonist,HUMAN_TIEFLING)
~ THEN REPLY #39942 GOTO 6
  IF ~  Global("FomoriansJoinLegion","GLOBAL",1)
Global("41MentionedGoublika","GLOBAL",0)
~ THEN REPLY #23974 DO ~SetGlobal("41MentionedGoublika","GLOBAL",1)~ GOTO 19
  IF ~  Global("41MentionedGoublika","GLOBAL",1)
~ THEN REPLY #39948 GOTO 19
  IF ~  Global("41MentionedRace","GLOBAL",0)
~ THEN REPLY #23976 DO ~SetGlobal("41MentionedRace", "GLOBAL", 1)~ GOTO 2
  IF ~  Global("41MentionedRace","GLOBAL",1)
~ THEN REPLY #39963 GOTO 2
  IF ~  Global("41PaintingPhrase6","GLOBAL",0)
~ THEN REPLY #23977 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41PaintingPhrase6", "GLOBAL", 1)~ GOTO 7
  IF ~  Global("41PaintingPhrase6","GLOBAL",1)
~ THEN REPLY #39976 GOTO 7
  IF ~  Global("41MentionedAurilites","GLOBAL",0)
~ THEN REPLY #23980 DO ~SetGlobal("41MentionedAurilites", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("41MentionedAurilites","GLOBAL",1)
~ THEN REPLY #39991 GOTO 9
  IF ~  Global("41MentionedLegion","GLOBAL",1)
Global("41ExplainedLegion","GLOBAL",1)
Global("41MentionedLeaders","GLOBAL",1)
~ THEN REPLY #23985 GOTO 18
END

IF ~~ THEN BEGIN 2
  SAY #23986
  IF ~  Global("41MentionedHumanity","GLOBAL",0)
Or(4)
Race(Protagonist,HALF_ELF)
Race(Protagonist,HALFORC)
SubRace(Protagonist,HUMAN_AASIMAR)
SubRace(Protagonist,HUMAN_TIEFLING)
~ THEN REPLY #23987 DO ~SetGlobal("41MentionedHumanity","GLOBAL",1)~ GOTO 3
  IF ~  Global("41MentionedHumanity","GLOBAL",0)
!Race(Protagonist,HALF_ELF)
!Race(Protagonist,HALFORC)
!SubRace(Protagonist,HUMAN_AASIMAR)
!SubRace(Protagonist,HUMAN_TIEFLING)
~ THEN REPLY #23987 DO ~SetGlobal("41MentionedHumanity","GLOBAL",1)~ GOTO 4
  IF ~  Global("FomoriansJoinLegion","GLOBAL",1)
Global("41MentionedGoublika","GLOBAL",0)
~ THEN REPLY #23974 DO ~SetGlobal("41MentionedGoublika","GLOBAL",1)~ GOTO 19
  IF ~  Global("41MentionedGoublika","GLOBAL",1)
~ THEN REPLY #39948 GOTO 19
  IF ~  Global("41MentionedHumanity","GLOBAL",1)
Or(4)
Race(Protagonist,HALF_ELF)
Race(Protagonist,HALFORC)
SubRace(Protagonist,HUMAN_AASIMAR)
SubRace(Protagonist,HUMAN_TIEFLING)
~ THEN REPLY #40025 GOTO 3
  IF ~  Global("41MentionedHumanity","GLOBAL",1)
!Race(Protagonist,HALF_ELF)
!Race(Protagonist,HALFORC)
!SubRace(Protagonist,HUMAN_AASIMAR)
!SubRace(Protagonist,HUMAN_TIEFLING)
~ THEN REPLY #40025 GOTO 4
  IF ~  !Global("FomoriansJoinLegion","GLOBAL",1)
Global("Goublika_dead","GLOBAL",0)
Global("40GoublikaHunts","GLOBAL",1)
~ THEN REPLY #23988 DO ~SetGlobal("SoarsmanEscapeArea", "MYAREA", 1)~ GOTO 11
  IF ~  Global("41MentionedName","GLOBAL",0)
~ THEN REPLY #23975 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41MentionedName","GLOBAL",1)~ JOURNAL #23970 GOTO 1
  IF ~  Global("41MentionedName","GLOBAL",1)
~ THEN REPLY #18831 GOTO 1
  IF ~  Global("41PaintingPhrase6","GLOBAL",0)
~ THEN REPLY #23977 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41PaintingPhrase6", "GLOBAL", 1)~ GOTO 7
  IF ~  Global("41PaintingPhrase6","GLOBAL",1)
~ THEN REPLY #39976 GOTO 7
  IF ~  Global("41MentionedAurilites","GLOBAL",0)
~ THEN REPLY #23980 DO ~SetGlobal("41MentionedAurilites", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("41MentionedAurilites","GLOBAL",1)
~ THEN REPLY #39991 GOTO 9
  IF ~  BitGlobal("40YurstFlags","GLOBAL",32,AND)
Global("41MentionedYurst","GLOBAL",0)
~ THEN REPLY #23989 DO ~SetGlobal("41MentionedYurst", "GLOBAL", 1)~ GOTO 10
  IF ~  Global("41MentionedLegion","GLOBAL",1)
Global("41ExplainedLegion","GLOBAL",1)
Global("41MentionedLeaders","GLOBAL",1)
~ THEN REPLY #23985 GOTO 18
END

IF ~~ THEN BEGIN 3
  SAY #23990
  IF ~~ THEN REPLY #23991 GOTO 12
  IF ~  Global("41MentionedNecromancers","GLOBAL",0)
~ THEN REPLY #23992 DO ~SetGlobal("41MentionedNecromancers", "GLOBAL", 1)~ GOTO 13
  IF ~  Global("FomoriansJoinLegion","GLOBAL",1)
Global("41MentionedGoublika","GLOBAL",0)
~ THEN REPLY #23974 DO ~SetGlobal("41MentionedGoublika","GLOBAL",1)~ GOTO 19
  IF ~  Global("41MentionedGoublika","GLOBAL",1)
~ THEN REPLY #39948 GOTO 19
  IF ~  Global("41MentionedName","GLOBAL",1)
~ THEN REPLY #18831 GOTO 1
  IF ~  Global("41MentionedName","GLOBAL",0)
~ THEN REPLY #23975 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41MentionedName","GLOBAL",1)~ JOURNAL #23970 GOTO 1
  IF ~  Global("41PaintingPhrase6","GLOBAL",0)
~ THEN REPLY #23977 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41PaintingPhrase6", "GLOBAL", 1)~ GOTO 7
  IF ~  Global("41PaintingPhrase6","GLOBAL",1)
~ THEN REPLY #39976 GOTO 7
  IF ~  Global("41MentionedAurilites","GLOBAL",0)
~ THEN REPLY #23980 DO ~SetGlobal("41MentionedAurilites", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("41MentionedAurilites","GLOBAL",1)
~ THEN REPLY #39991 GOTO 9
  IF ~  Global("41MentionedLegion","GLOBAL",1)
Global("41ExplainedLegion","GLOBAL",1)
Global("41MentionedLeaders","GLOBAL",1)
~ THEN REPLY #23985 GOTO 18
END

IF ~~ THEN BEGIN 4
  SAY #23993
  IF ~~ THEN REPLY #23994 GOTO 12
  IF ~  Global("41MentionedNecromancers","GLOBAL",0)
~ THEN REPLY #23992 DO ~SetGlobal("41MentionedNecromancers", "GLOBAL", 1)~ GOTO 13
  IF ~  Global("FomoriansJoinLegion","GLOBAL",1)
Global("41MentionedGoublika","GLOBAL",0)
~ THEN REPLY #23974 DO ~SetGlobal("41MentionedGoublika","GLOBAL",1)~ GOTO 19
  IF ~  Global("41MentionedGoublika","GLOBAL",1)
~ THEN REPLY #39948 GOTO 19
  IF ~  Global("41MentionedName","GLOBAL",1)
~ THEN REPLY #18831 GOTO 1
  IF ~  Global("41MentionedName","GLOBAL",0)
~ THEN REPLY #23975 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41MentionedName","GLOBAL",1)~ JOURNAL #23970 GOTO 1
  IF ~  Global("41PaintingPhrase6","GLOBAL",0)
~ THEN REPLY #23977 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41PaintingPhrase6", "GLOBAL", 1)~ GOTO 7
  IF ~  Global("41PaintingPhrase6","GLOBAL",1)
~ THEN REPLY #39976 GOTO 7
  IF ~  Global("41MentionedAurilites","GLOBAL",0)
~ THEN REPLY #23980 DO ~SetGlobal("41MentionedAurilites", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("41MentionedAurilites","GLOBAL",1)
~ THEN REPLY #39991 GOTO 9
  IF ~  Global("41MentionedLegion","GLOBAL",1)
Global("41ExplainedLegion","GLOBAL",1)
Global("41MentionedLeaders","GLOBAL",1)
~ THEN REPLY #23985 GOTO 18
END

IF ~~ THEN BEGIN 5
  SAY #23995
  IF ~  Global("41MentionedLeaders","GLOBAL",0)
~ THEN REPLY #23996 DO ~SetGlobal("41MentionedLeaders", "GLOBAL", 1)~ JOURNAL #23972 GOTO 14
  IF ~  Global("41MentionedLeaders","GLOBAL",1)
~ THEN REPLY #40022 GOTO 14
  IF ~  Global("FomoriansJoinLegion","GLOBAL",1)
Global("41MentionedGoublika","GLOBAL",0)
~ THEN REPLY #23974 DO ~SetGlobal("41MentionedGoublika","GLOBAL",1)~ GOTO 19
  IF ~  Global("41MentionedGoublika","GLOBAL",1)
~ THEN REPLY #39948 GOTO 19
  IF ~  !Global("FomoriansJoinLegion","GLOBAL",1)
Global("Goublika_dead","GLOBAL",0)
Global("40GoublikaAbuses","GLOBAL",1)
~ THEN REPLY #23997 DO ~SetGlobal("SoarsmanEscapeArea", "MYAREA", 1)~ GOTO 11
  IF ~  Global("41MentionedName","GLOBAL",0)
~ THEN REPLY #23975 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41MentionedName","GLOBAL",1)~ JOURNAL #23970 GOTO 1
  IF ~  Global("41MentionedName","GLOBAL",1)
~ THEN REPLY #18831 GOTO 1
  IF ~  Global("41MentionedRace","GLOBAL",0)
~ THEN REPLY #23976 DO ~SetGlobal("41MentionedRace", "GLOBAL", 1)~ GOTO 2
  IF ~  Global("41MentionedRace","GLOBAL",1)
~ THEN REPLY #39963 GOTO 2
  IF ~  Global("41PaintingPhrase6","GLOBAL",0)
~ THEN REPLY #23977 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41PaintingPhrase6", "GLOBAL", 1)~ GOTO 7
  IF ~  Global("41PaintingPhrase6","GLOBAL",1)
~ THEN REPLY #39976 GOTO 7
  IF ~  Global("41MentionedAurilites","GLOBAL",0)
~ THEN REPLY #23980 DO ~SetGlobal("41MentionedAurilites", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("41MentionedAurilites","GLOBAL",1)
~ THEN REPLY #39991 GOTO 9
  IF ~  Global("41MentionedLegion","GLOBAL",1)
Global("41ExplainedLegion","GLOBAL",1)
Global("41MentionedLeaders","GLOBAL",1)
~ THEN REPLY #23985 GOTO 18
END

IF ~~ THEN BEGIN 6
  SAY #23999
  IF ~  Global("41MentionedLeaders","GLOBAL",0)
~ THEN REPLY #23996 DO ~SetGlobal("41MentionedLeaders", "GLOBAL", 1)~ JOURNAL #23972 GOTO 14
  IF ~  Global("41MentionedLeaders","GLOBAL",1)
~ THEN REPLY #40022 GOTO 14
  IF ~  Global("FomoriansJoinLegion","GLOBAL",1)
Global("41MentionedGoublika","GLOBAL",0)
~ THEN REPLY #23974 DO ~SetGlobal("41MentionedGoublika","GLOBAL",1)~ GOTO 19
  IF ~  Global("41MentionedGoublika","GLOBAL",1)
~ THEN REPLY #39948 GOTO 19
  IF ~  !Global("FomoriansJoinLegion","GLOBAL",1)
Global("Goublika_dead","GLOBAL",0)
Global("40GoublikaAbuses","GLOBAL",1)
~ THEN REPLY #24000 DO ~SetGlobal("SoarsmanEscapeArea", "MYAREA", 1)~ GOTO 11
  IF ~  Global("41MentionedName","GLOBAL",0)
~ THEN REPLY #23975 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41MentionedName","GLOBAL",1)~ JOURNAL #23970 GOTO 1
  IF ~  Global("41MentionedName","GLOBAL",1)
~ THEN REPLY #18831 GOTO 1
  IF ~  Global("41MentionedRace","GLOBAL",0)
~ THEN REPLY #23976 DO ~SetGlobal("41MentionedRace", "GLOBAL", 1)~ GOTO 2
  IF ~  Global("41MentionedRace","GLOBAL",1)
~ THEN REPLY #39963 GOTO 2
  IF ~  Global("41PaintingPhrase6","GLOBAL",0)
~ THEN REPLY #23977 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41PaintingPhrase6", "GLOBAL", 1)~ GOTO 7
  IF ~  Global("41PaintingPhrase6","GLOBAL",1)
~ THEN REPLY #39976 GOTO 7
  IF ~  Global("41MentionedAurilites","GLOBAL",0)
~ THEN REPLY #23980 DO ~SetGlobal("41MentionedAurilites", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("41MentionedAurilites","GLOBAL",1)
~ THEN REPLY #39991 GOTO 9
  IF ~  Global("41MentionedLegion","GLOBAL",1)
Global("41ExplainedLegion","GLOBAL",1)
Global("41MentionedLeaders","GLOBAL",1)
~ THEN REPLY #23985 GOTO 18
END

IF ~~ THEN BEGIN 7
  SAY #24001
  IF ~  Global("41ExplainedLegion","GLOBAL",0)
Or(4)
Race(Protagonist,HALF_ELF)
Race(Protagonist,HALFORC)
SubRace(Protagonist,HUMAN_AASIMAR)
SubRace(Protagonist,HUMAN_TIEFLING)
~ THEN REPLY #23983 DO ~SetGlobal("41ExplainedLegion", "GLOBAL", 1)~ JOURNAL #23971 GOTO 5
  IF ~  Global("41ExplainedLegion","GLOBAL",0)
!Race(Protagonist,HALF_ELF)
!Race(Protagonist,HALFORC)
!SubRace(Protagonist,HUMAN_AASIMAR)
!SubRace(Protagonist,HUMAN_TIEFLING)
~ THEN REPLY #23983 DO ~SetGlobal("41ExplainedLegion", "GLOBAL", 1)~ JOURNAL #23971 GOTO 6
  IF ~  Global("41ExplainedLegion","GLOBAL",1)
Or(4)
Race(Protagonist,HALF_ELF)
Race(Protagonist,HALFORC)
SubRace(Protagonist,HUMAN_AASIMAR)
SubRace(Protagonist,HUMAN_TIEFLING)
~ THEN REPLY #39942 GOTO 5
  IF ~  Global("41ExplainedLegion","GLOBAL",1)
!Race(Protagonist,HALF_ELF)
!Race(Protagonist,HALFORC)
!SubRace(Protagonist,HUMAN_AASIMAR)
!SubRace(Protagonist,HUMAN_TIEFLING)
~ THEN REPLY #39942 GOTO 6
  IF ~  Global("FomoriansJoinLegion","GLOBAL",1)
Global("41MentionedGoublika","GLOBAL",0)
~ THEN REPLY #23974 DO ~SetGlobal("41MentionedGoublika","GLOBAL",1)~ GOTO 19
  IF ~  Global("41MentionedGoublika","GLOBAL",1)
~ THEN REPLY #39948 GOTO 19
  IF ~  Global("41MentionedName","GLOBAL",0)
~ THEN REPLY #23975 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41MentionedName","GLOBAL",1)~ JOURNAL #23970 GOTO 1
  IF ~  Global("41MentionedName","GLOBAL",1)
~ THEN REPLY #18831 GOTO 1
  IF ~  Global("41MentionedRace","GLOBAL",0)
~ THEN REPLY #23976 DO ~SetGlobal("41MentionedRace", "GLOBAL", 1)~ GOTO 2
  IF ~  Global("41MentionedRace","GLOBAL",1)
~ THEN REPLY #39963 GOTO 2
  IF ~  Global("41MentionedAurilites","GLOBAL",0)
~ THEN REPLY #23980 DO ~SetGlobal("41MentionedAurilites", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("41MentionedAurilites","GLOBAL",1)
~ THEN REPLY #39991 GOTO 9
  IF ~  Global("41MentionedLegion","GLOBAL",1)
Global("41ExplainedLegion","GLOBAL",1)
Global("41MentionedLeaders","GLOBAL",1)
~ THEN REPLY #23985 GOTO 18
END

IF ~~ THEN BEGIN 8
  SAY #24004
  IF ~~ THEN DO ~ClearAllActions()
ApplySpell(Player1,2082)
ApplySpell(Player2,2082)
ApplySpell(Player3,2082)
ApplySpell(Player4,2082)
ApplySpell(Player5,2082)
ApplySpell(Player6,2082)
ApplySpell(Myself,CLERIC_HEAL)
SetNumTimesTalkedTo(0)
ChangeEnemyAlly(Myself,NEUTRAL)
StartCutSceneMode()
StartCutScene("41cPriso")~ EXIT
END

IF ~~ THEN BEGIN 9
  SAY #24007
  IF ~  Global("41MentionedLeaders","GLOBAL",0)
~ THEN REPLY #24008 DO ~SetGlobal("41MentionedLeaders", "GLOBAL", 1)~ JOURNAL #23972 GOTO 14
  IF ~  Global("41MentionedLeaders","GLOBAL",1)
~ THEN REPLY #40022 GOTO 14
  IF ~  Global("FomoriansJoinLegion","GLOBAL",1)
Global("41MentionedGoublika","GLOBAL",0)
~ THEN REPLY #23974 DO ~SetGlobal("41MentionedGoublika","GLOBAL",1)~ GOTO 19
  IF ~  Global("41MentionedGoublika","GLOBAL",1)
~ THEN REPLY #39948 GOTO 19
  IF ~  Global("41MentionedName","GLOBAL",0)
~ THEN REPLY #23975 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41MentionedName","GLOBAL",1)~ JOURNAL #23970 GOTO 1
  IF ~  Global("41MentionedName","GLOBAL",1)
~ THEN REPLY #18831 GOTO 1
  IF ~  Global("41MentionedRace","GLOBAL",0)
~ THEN REPLY #23976 DO ~SetGlobal("41MentionedRace", "GLOBAL", 1)~ GOTO 2
  IF ~  Global("41MentionedRace","GLOBAL",1)
~ THEN REPLY #39963 GOTO 2
  IF ~  Global("41PaintingPhrase6","GLOBAL",0)
~ THEN REPLY #23977 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41PaintingPhrase6", "GLOBAL", 1)~ GOTO 7
  IF ~  Global("41PaintingPhrase6","GLOBAL",1)
~ THEN REPLY #39976 GOTO 7
  IF ~  Global("41MentionedLegion","GLOBAL",1)
Global("41ExplainedLegion","GLOBAL",1)
Global("41MentionedLeaders","GLOBAL",1)
~ THEN REPLY #23985 GOTO 18
END

IF ~~ THEN BEGIN 10
  SAY #24009
  IF ~  Global("FomoriansJoinLegion","GLOBAL",1)
Global("41MentionedGoublika","GLOBAL",0)
~ THEN REPLY #23974 DO ~SetGlobal("41MentionedGoublika","GLOBAL",1)~ GOTO 19
  IF ~  Global("41MentionedGoublika","GLOBAL",1)
~ THEN REPLY #39948 GOTO 19
  IF ~  Global("41MentionedName","GLOBAL",1)
~ THEN REPLY #18831 GOTO 1
  IF ~  Global("41MentionedName","GLOBAL",0)
~ THEN REPLY #23975 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41MentionedName","GLOBAL",1)~ JOURNAL #23970 GOTO 1
  IF ~  Global("41MentionedRace","GLOBAL",0)
~ THEN REPLY #23976 DO ~SetGlobal("41MentionedRace", "GLOBAL", 1)~ GOTO 2
  IF ~  Global("41MentionedRace","GLOBAL",1)
~ THEN REPLY #39963 GOTO 2
  IF ~  Global("41PaintingPhrase6","GLOBAL",0)
~ THEN REPLY #23977 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41PaintingPhrase6", "GLOBAL", 1)~ GOTO 7
  IF ~  Global("41PaintingPhrase6","GLOBAL",1)
~ THEN REPLY #39976 GOTO 7
  IF ~  Global("41MentionedAurilites","GLOBAL",0)
~ THEN REPLY #23980 DO ~SetGlobal("41MentionedAurilites", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("41MentionedAurilites","GLOBAL",1)
~ THEN REPLY #39991 GOTO 9
  IF ~  Global("41MentionedLegion","GLOBAL",1)
Global("41ExplainedLegion","GLOBAL",1)
Global("41MentionedLeaders","GLOBAL",1)
~ THEN REPLY #23985 GOTO 18
END

IF ~~ THEN BEGIN 11
  SAY #24010
  IF ~  Global("FomoriansJoinLegion","GLOBAL",1)
Global("41MentionedGoublika","GLOBAL",0)
~ THEN REPLY #23974 DO ~SetGlobal("41MentionedGoublika","GLOBAL",1)~ GOTO 19
  IF ~  Global("41MentionedGoublika","GLOBAL",1)
~ THEN REPLY #39948 GOTO 19
  IF ~  Global("41MentionedName","GLOBAL",1)
~ THEN REPLY #18831 GOTO 1
  IF ~  Global("41MentionedName","GLOBAL",0)
~ THEN REPLY #23975 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41MentionedName","GLOBAL",1)~ JOURNAL #23970 GOTO 1
  IF ~  Global("41MentionedRace","GLOBAL",0)
~ THEN REPLY #23976 DO ~SetGlobal("41MentionedRace", "GLOBAL", 1)~ GOTO 2
  IF ~  Global("41MentionedRace","GLOBAL",1)
~ THEN REPLY #39963 GOTO 2
  IF ~  Global("41PaintingPhrase6","GLOBAL",0)
~ THEN REPLY #23977 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41PaintingPhrase6", "GLOBAL", 1)~ GOTO 7
  IF ~  Global("41PaintingPhrase6","GLOBAL",1)
~ THEN REPLY #39976 GOTO 7
  IF ~  Global("41MentionedAurilites","GLOBAL",0)
~ THEN REPLY #23980 DO ~SetGlobal("41MentionedAurilites", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("41MentionedAurilites","GLOBAL",1)
~ THEN REPLY #39991 GOTO 9
  IF ~  Global("41MentionedLegion","GLOBAL",1)
Global("41ExplainedLegion","GLOBAL",1)
Global("41MentionedLeaders","GLOBAL",1)
~ THEN REPLY #23985 GOTO 18
END

IF ~~ THEN BEGIN 12
  SAY #24011
  IF ~  Global("FomoriansJoinLegion","GLOBAL",1)
Global("41MentionedGoublika","GLOBAL",0)
~ THEN REPLY #23974 DO ~SetGlobal("41MentionedGoublika","GLOBAL",1)~ GOTO 19
  IF ~  Global("41MentionedGoublika","GLOBAL",1)
~ THEN REPLY #39948 GOTO 19
  IF ~  Global("41MentionedName","GLOBAL",1)
~ THEN REPLY #18831 GOTO 1
  IF ~  Global("41MentionedName","GLOBAL",0)
~ THEN REPLY #23975 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41MentionedName","GLOBAL",1)~ JOURNAL #23970 GOTO 1
  IF ~  Global("41MentionedRace","GLOBAL",0)
~ THEN REPLY #23976 DO ~SetGlobal("41MentionedRace", "GLOBAL", 1)~ GOTO 2
  IF ~  Global("41MentionedRace","GLOBAL",1)
~ THEN REPLY #39963 GOTO 2
  IF ~  Global("41PaintingPhrase6","GLOBAL",0)
~ THEN REPLY #23977 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41PaintingPhrase6", "GLOBAL", 1)~ GOTO 7
  IF ~  Global("41PaintingPhrase6","GLOBAL",1)
~ THEN REPLY #39976 GOTO 7
  IF ~  Global("41MentionedAurilites","GLOBAL",0)
~ THEN REPLY #23980 DO ~SetGlobal("41MentionedAurilites", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("41MentionedAurilites","GLOBAL",1)
~ THEN REPLY #39991 GOTO 9
  IF ~  Global("41MentionedLegion","GLOBAL",1)
Global("41ExplainedLegion","GLOBAL",1)
Global("41MentionedLeaders","GLOBAL",1)
~ THEN REPLY #23985 GOTO 18
END

IF ~~ THEN BEGIN 13
  SAY #24012
  IF ~  Global("FomoriansJoinLegion","GLOBAL",1)
Global("41MentionedGoublika","GLOBAL",0)
~ THEN REPLY #23974 DO ~SetGlobal("41MentionedGoublika","GLOBAL",1)~ GOTO 19
  IF ~  Global("41MentionedGoublika","GLOBAL",1)
~ THEN REPLY #39948 GOTO 19
  IF ~  Global("41MentionedName","GLOBAL",1)
~ THEN REPLY #18831 GOTO 1
  IF ~  Global("41MentionedName","GLOBAL",0)
~ THEN REPLY #23975 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41MentionedName","GLOBAL",1)~ JOURNAL #23970 GOTO 1
  IF ~  Global("41MentionedRace","GLOBAL",0)
~ THEN REPLY #23976 DO ~SetGlobal("41MentionedRace", "GLOBAL", 1)~ GOTO 2
  IF ~  Global("41MentionedRace","GLOBAL",1)
~ THEN REPLY #39963 GOTO 2
  IF ~  Global("41PaintingPhrase6","GLOBAL",0)
~ THEN REPLY #23977 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41PaintingPhrase6", "GLOBAL", 1)~ GOTO 7
  IF ~  Global("41PaintingPhrase6","GLOBAL",1)
~ THEN REPLY #39976 GOTO 7
  IF ~  Global("41MentionedAurilites","GLOBAL",0)
~ THEN REPLY #23980 DO ~SetGlobal("41MentionedAurilites", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("41MentionedAurilites","GLOBAL",1)
~ THEN REPLY #39991 GOTO 9
  IF ~  Global("41MentionedLegion","GLOBAL",1)
Global("41ExplainedLegion","GLOBAL",1)
Global("41MentionedLeaders","GLOBAL",1)
~ THEN REPLY #23985 GOTO 18
END

IF ~~ THEN BEGIN 14
  SAY #24013
  IF ~  Global("FomoriansJoinLegion","GLOBAL",1)
Global("41MentionedGoublika","GLOBAL",0)
~ THEN REPLY #23974 DO ~SetGlobal("41MentionedGoublika","GLOBAL",1)~ GOTO 19
  IF ~  Global("41MentionedGoublika","GLOBAL",1)
~ THEN REPLY #39948 GOTO 19
  IF ~  Global("41MentionedName","GLOBAL",1)
~ THEN REPLY #18831 GOTO 1
  IF ~  Global("41MentionedName","GLOBAL",0)
~ THEN REPLY #23975 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41MentionedName","GLOBAL",1)~ JOURNAL #23970 GOTO 1
  IF ~  Global("41MentionedRace","GLOBAL",0)
~ THEN REPLY #23976 DO ~SetGlobal("41MentionedRace", "GLOBAL", 1)~ GOTO 2
  IF ~  Global("41MentionedRace","GLOBAL",1)
~ THEN REPLY #39963 GOTO 2
  IF ~  Global("41PaintingPhrase6","GLOBAL",0)
~ THEN REPLY #23977 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41PaintingPhrase6", "GLOBAL", 1)~ GOTO 7
  IF ~  Global("41PaintingPhrase6","GLOBAL",1)
~ THEN REPLY #39976 GOTO 7
  IF ~  Global("41MentionedAurilites","GLOBAL",0)
~ THEN REPLY #23980 DO ~SetGlobal("41MentionedAurilites", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("41MentionedAurilites","GLOBAL",1)
~ THEN REPLY #39991 GOTO 9
  IF ~  Global("41MentionedLegion","GLOBAL",1)
Global("41ExplainedLegion","GLOBAL",1)
Global("41MentionedLeaders","GLOBAL",1)
~ THEN REPLY #23985 GOTO 18
END

IF ~  NumberOfTimesTalkedTo(0)
GlobalGT("41PartyPrisonEntry","GLOBAL",1)
~ THEN BEGIN 15
  SAY #24014
  IF ~~ THEN GOTO 18
END

IF ~  NumTimesTalkedToGT(0)
RandomNum(2,1)
~ THEN BEGIN 16
  SAY #24015
  IF ~  Global("FomoriansJoinLegion","GLOBAL",1)
Global("41MentionedGoublika","GLOBAL",0)
~ THEN REPLY #23974 DO ~SetGlobal("41MentionedGoublika","GLOBAL",1)~ GOTO 19
  IF ~  Global("41MentionedGoublika","GLOBAL",1)
~ THEN REPLY #39948 GOTO 19
  IF ~  Global("41MentionedName","GLOBAL",1)
~ THEN REPLY #18831 GOTO 1
  IF ~  Global("41MentionedName","GLOBAL",0)
~ THEN REPLY #23975 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41MentionedName","GLOBAL",1)~ JOURNAL #23970 GOTO 1
  IF ~  Global("41MentionedRace","GLOBAL",0)
~ THEN REPLY #23976 DO ~SetGlobal("41MentionedRace", "GLOBAL", 1)~ GOTO 2
  IF ~  Global("41MentionedRace","GLOBAL",1)
~ THEN REPLY #39963 GOTO 2
  IF ~  Global("41PaintingPhrase6","GLOBAL",0)
~ THEN REPLY #23977 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41PaintingPhrase6", "GLOBAL", 1)~ GOTO 7
  IF ~  Global("41PaintingPhrase6","GLOBAL",1)
~ THEN REPLY #39976 GOTO 7
  IF ~  Global("41MentionedAurilites","GLOBAL",0)
~ THEN REPLY #23980 DO ~SetGlobal("41MentionedAurilites", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("41MentionedAurilites","GLOBAL",1)
~ THEN REPLY #39991 GOTO 9
  IF ~  Global("41MentionedLegion","GLOBAL",1)
Global("41ExplainedLegion","GLOBAL",1)
Global("41MentionedLeaders","GLOBAL",1)
~ THEN REPLY #24017 EXIT
END

IF ~  NumTimesTalkedToGT(0)
RandomNum(2,2)
~ THEN BEGIN 17
  SAY #24018
  IF ~  Global("FomoriansJoinLegion","GLOBAL",1)
Global("41MentionedGoublika","GLOBAL",0)
~ THEN REPLY #23974 DO ~SetGlobal("41MentionedGoublika","GLOBAL",1)~ GOTO 19
  IF ~  Global("41MentionedGoublika","GLOBAL",1)
~ THEN REPLY #39948 GOTO 19
  IF ~  Global("41MentionedName","GLOBAL",1)
~ THEN REPLY #18831 GOTO 1
  IF ~  Global("41MentionedName","GLOBAL",0)
~ THEN REPLY #23975 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41MentionedName","GLOBAL",1)~ JOURNAL #23970 GOTO 1
  IF ~  Global("41MentionedRace","GLOBAL",0)
~ THEN REPLY #23976 DO ~SetGlobal("41MentionedRace", "GLOBAL", 1)~ GOTO 2
  IF ~  Global("41MentionedRace","GLOBAL",1)
~ THEN REPLY #39963 GOTO 2
  IF ~  Global("41PaintingPhrase6","GLOBAL",0)
~ THEN REPLY #23977 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41PaintingPhrase6", "GLOBAL", 1)~ GOTO 7
  IF ~  Global("41PaintingPhrase6","GLOBAL",1)
~ THEN REPLY #39976 GOTO 7
  IF ~  Global("41MentionedAurilites","GLOBAL",0)
~ THEN REPLY #23980 DO ~SetGlobal("41MentionedAurilites", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("41MentionedAurilites","GLOBAL",1)
~ THEN REPLY #39991 GOTO 9
  IF ~  Global("41MentionedLegion","GLOBAL",1)
Global("41ExplainedLegion","GLOBAL",1)
Global("41MentionedLeaders","GLOBAL",1)
~ THEN REPLY #24017 EXIT
END

IF ~~ THEN BEGIN 18
  SAY #24119
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 19
  SAY #30481
  IF ~~ THEN GOTO 20
END

IF ~~ THEN BEGIN 20
  SAY #31987
  IF ~  Global("41MentionedName","GLOBAL",0)
~ THEN REPLY #23975 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41MentionedName","GLOBAL",1)~ JOURNAL #23970 GOTO 1
  IF ~  Global("41MentionedName","GLOBAL",1)
~ THEN REPLY #18831 GOTO 1
  IF ~  Global("41MentionedRace","GLOBAL",0)
~ THEN REPLY #23976 DO ~SetGlobal("41MentionedRace", "GLOBAL", 1)~ GOTO 2
  IF ~  Global("41MentionedRace","GLOBAL",1)
~ THEN REPLY #39963 GOTO 2
  IF ~  Global("41PaintingPhrase6","GLOBAL",1)
~ THEN REPLY #39976 GOTO 7
  IF ~  Global("41PaintingPhrase6","GLOBAL",0)
~ THEN REPLY #23977 DO ~SetGlobal("41MentionedLegion", "GLOBAL", 1)
SetGlobal("41PaintingPhrase6", "GLOBAL", 1)~ GOTO 7
  IF ~  Global("41MentionedAurilites","GLOBAL",0)
~ THEN REPLY #23980 DO ~SetGlobal("41MentionedAurilites", "GLOBAL", 1)~ GOTO 9
  IF ~  Global("41MentionedAurilites","GLOBAL",1)
~ THEN REPLY #39991 GOTO 9
  IF ~  BitGlobal("40YurstFlags","GLOBAL",32,AND)
Global("41MentionedYurst","GLOBAL",0)
~ THEN REPLY #23981 DO ~SetGlobal("41MentionedYurst", "GLOBAL", 1)~ GOTO 10
  IF ~  Global("41MentionedLegion","GLOBAL",1)
Global("41ExplainedLegion","GLOBAL",1)
Global("41MentionedLeaders","GLOBAL",1)
~ THEN REPLY #23985 GOTO 18
END
