BEGIN ~20NEWVRK~

IF ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY #36265
  IF ~  ClassEx(Protagonist,FIGHTER)
~ THEN REPLY #36267 GOTO 2
  IF ~  ClassEx(Protagonist,THIEF)
~ THEN REPLY #36269 GOTO 2
  IF ~  ClassEx(Protagonist,CLERIC)
~ THEN REPLY #36270 GOTO 2
  IF ~  ClassEx(Protagonist,DRUID)
~ THEN REPLY #36271 GOTO 2
  IF ~  ClassEx(Protagonist,PALADIN)
~ THEN REPLY #36272 GOTO 2
  IF ~  ClassEx(Protagonist,MAGE_ALL)
~ THEN REPLY #36268 GOTO 2
  IF ~~ THEN REPLY #36266 GOTO 1
  IF ~~ THEN REPLY #36273 GOTO 8
END

IF ~~ THEN BEGIN 1
  SAY #36274
  IF ~  Global("SR_Recover_Blade","GLOBAL",3)
~ THEN REPLY #36275 GOTO 3
  IF ~~ THEN REPLY #36276 GOTO 7
END

IF ~~ THEN BEGIN 2
  SAY #36277
  IF ~  Global("SR_Recover_Blade","GLOBAL",3)
~ THEN REPLY #36275 GOTO 3
  IF ~~ THEN REPLY #36276 GOTO 7
END

IF ~~ THEN BEGIN 3
  SAY #36278
  IF ~~ THEN REPLY #36279 DO ~AddXpVar("Level_3_Easy",36264)~ JOURNAL #36263 GOTO 4
  IF ~~ THEN REPLY #36276 GOTO 7
END

IF ~~ THEN BEGIN 4
  SAY #36280
  IF ~  Gender(Protagonist,MALE)
~ THEN REPLY #36281 GOTO 5
  IF ~  Gender(Protagonist,FEMALE)
~ THEN REPLY #36281 GOTO 6
END

IF ~~ THEN BEGIN 5
  SAY #36282
  IF ~~ THEN REPLY #36283 GOTO 7
  IF ~Global("US_Emma_Joined", "GLOBAL", 0)
  !ClassEx(Protagonist, Paladin)~ THEN REPLY @40042 GOTO VrekJoin1
END

IF ~~ THEN BEGIN 6
  SAY #36284
  IF ~~ THEN REPLY #36283 GOTO 7
  IF ~Global("US_Emma_Joined", "GLOBAL", 0)
  !ClassEx(Protagonist, Paladin)~ THEN REPLY @40042 GOTO VrekJoin1
END

IF ~~ THEN BEGIN 7
  SAY #36285
  IF ~~ THEN REPLY #36286 DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 8
  SAY #36287
  IF ~  ClassEx(Protagonist,FIGHTER)
~ THEN REPLY #36267 GOTO 2
  IF ~  ClassEx(Protagonist,MAGE_ALL)
~ THEN REPLY #36268 GOTO 2
  IF ~  ClassEx(Protagonist,THIEF)
~ THEN REPLY #36269 GOTO 2
  IF ~  ClassEx(Protagonist,CLERIC)
~ THEN REPLY #36270 GOTO 2
  IF ~  ClassEx(Protagonist,DRUID)
~ THEN REPLY #36271 GOTO 2
  IF ~  ClassEx(Protagonist,PALADIN)
~ THEN REPLY #36272 GOTO 2
  IF ~~ THEN REPLY #36266 GOTO 1
END

IF ~~ THEN BEGIN VrekJoin1
  SAY @40043
  IF ~~ THEN REPLY @40044 GOTO VrekJoinSee
  IF ~CheckSkillGT(Protagonist,4,Intimidate)~ THEN REPLY @40045 GOTO VrekJoinThreat
END

IF ~~ THEN BEGIN VrekJoinSee
  SAY @40046
  IF ~~ THEN REPLY @40047 GOTO 7
  IF ~!NumInParty(6)~ THEN REPLY @40048 GOTO VrekJoin2
  IF ~CheckSkillGT(Protagonist,4,Intimidate)~ THEN REPLY @40049 GOTO VrekJoinThreat
END

IF ~~ THEN BEGIN VrekJoin2
  SAY @40050
  IF ~Global("SR_Villagers_Dead","GLOBAL",1)~ THEN REPLY @40051 GOTO VrekJoinHumansDead
  IF ~GlobalGT("SR_Rescue_Villagers","GLOBAL",3)~ THEN REPLY @40052 GOTO VrekJoinHumansSaved
  IF ~!GlobalGT("SR_Rescue_Villagers","GLOBAL",3)
!Global("SR_Villagers_Dead","GLOBAL",1)~ THEN REPLY @40053 GOTO 7
END

IF ~~ THEN BEGIN VrekJoinHumansDead
  SAY @40054
  IF ~CheckSkillLT(Protagonist,6,Diplomacy)~ THEN REPLY @40056 GOTO VrekJoinFailedNoFood
  IF ~CheckSkillGT(Protagonist,5,Diplomacy)~ THEN REPLY @40056 GOTO VrekJoinSuccess1
END

IF ~~ THEN BEGIN VrekJoinHumansSaved
  SAY @40055
  IF ~CheckSkillLT(Protagonist,8,Diplomacy)~ THEN REPLY @40056 GOTO VrekJoinFailedNoFood
  IF ~CheckSkillGT(Protagonist,7,Diplomacy)~ THEN REPLY @40056 GOTO VrekJoinSuccess1
END

IF ~~ THEN BEGIN VrekJoinFailedNoFood
  SAY @40057
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN VrekJoinThreat
  SAY @40058
  IF ~~ THEN REPLY @40059 GOTO 7
  IF ~!NumInParty(6)
CheckSkillGT(Protagonist,5,Diplomacy)~ THEN REPLY @40060 GOTO VrekJoinThreat2
END

IF ~~ THEN BEGIN VrekJoinThreat2
  SAY @40061
  IF ~Race(Protagonist,Human)~ THEN REPLY @40062 GOTO VrekJoinThreat3
  IF ~!Race(Protagonist,Human)~ THEN REPLY @40063 GOTO VrekJoinThreat3
END

IF ~~ THEN BEGIN VrekJoinThreat3
  SAY @40064
  IF ~Global("SR_Villagers_Dead","GLOBAL",1)~ THEN REPLY @40051 GOTO VrekJoinThreat3HumansDead
  IF ~GlobalGT("SR_Rescue_Villagers","GLOBAL",3)~ THEN REPLY @40052 GOTO VrekJoinThreat3HumansSaved
  IF ~!GlobalGT("SR_Rescue_Villagers","GLOBAL",3)
!Global("SR_Villagers_Dead","GLOBAL",1)~ THEN REPLY @40065 GOTO 7
END

IF ~~ THEN BEGIN VrekJoinThreat3HumansDead
  SAY @40054
  IF ~CheckSkillLT(Protagonist,4,Diplomacy)~ THEN REPLY @40066 GOTO VrekJoinFailedNoFood
  IF ~CheckSkillGT(Protagonist,3,Diplomacy)~ THEN REPLY @40067 GOTO VrekJoinSuccess1
END

IF ~~ THEN BEGIN VrekJoinThreat3HumansSaved
  SAY @40055
  IF ~CheckSkillLT(Protagonist,6,Diplomacy)~ THEN REPLY @40066 GOTO VrekJoinFailedNoFood
  IF ~CheckSkillGT(Protagonist,5,Diplomacy)~ THEN REPLY @40067 GOTO VrekJoinSuccess1
END

IF ~~ THEN BEGIN VrekJoinSuccess1
  SAY @40068
  IF ~~ THEN REPLY @40069 GOTO VrekJoinSuccess2
END

IF ~~ THEN BEGIN VrekJoinSuccess2
  SAY @40070
  IF ~~ THEN REPLY @40071 DO ~SetGlobal("US_Vrek_Joined", "GLOBAL", 1)
SetGlobal("US_VREK_JOIN", "GLOBAL", 1)
ApplySpellRES("USVREKC",Myself)~ EXIT
END
