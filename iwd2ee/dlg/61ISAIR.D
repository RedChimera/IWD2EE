BEGIN ~61ISAIR~

IF WEIGHT #0 ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY #29432
  IF ~~ THEN EXTERN ~60MADAE~ 0
END

IF ~~ THEN BEGIN 1
  SAY #29434
  IF ~~ THEN REPLY #29435 GOTO 2
  IF ~~ THEN REPLY #29436 GOTO 3
  IF ~~ THEN REPLY #29437 GOTO 3
  IF ~~ THEN REPLY #29438 EXTERN ~60MADAE~ 1
  IF ~~ THEN REPLY #29439 EXTERN ~60MADAE~ 2
  IF ~  ClassEx(Protagonist,FIGHTER)
~ THEN REPLY #29440 GOTO 4
  IF ~  ClassEx(Protagonist,BARBARIAN)
~ THEN REPLY #29440 GOTO 4
  IF ~  ClassEx(Protagonist,DRUID)
~ THEN REPLY #29441 EXTERN ~60MADAE~ 2
  IF ~  ClassEx(Protagonist,RANGER)
~ THEN REPLY #29441 EXTERN ~60MADAE~ 2
  IF ~  ClassEx(Protagonist,PALADIN)
~ THEN REPLY #29442 EXTERN ~60MADAE~ 3
  IF ~  ClassEx(Protagonist,CLERIC)
Alignment(Protagonist,MASK_GOOD)
~ THEN REPLY #29443 EXTERN ~60MADAE~ 3
  IF ~  ClassEx(Protagonist,THIEF)
~ THEN REPLY #29444 GOTO 5
  IF ~  ClassEx(Protagonist,BARD)
~ THEN REPLY #29445 GOTO 6
  IF ~  ClassEx(Protagonist,MAGE)
~ THEN REPLY #29446 GOTO 7
  IF ~  Kit(Protagonist,CLERIC_SELUNE)
~ THEN REPLY #29447 EXTERN ~60MADAE~ 4
  IF ~  Kit(Protagonist,CLERIC_TEMPUS)
~ THEN REPLY #29448 GOTO 8
  IF ~  Kit(Protagonist,CLERIC_BANE)
~ THEN REPLY #29449 EXTERN ~60MADAE~ 5
  IF ~  ClassEx(Protagonist,MONK)
~ THEN REPLY #29451 EXTERN ~60MADAE~ 6
  IF ~~ THEN REPLY #29453 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()
~ EXIT
END

IF ~~ THEN BEGIN 2
  SAY #29454
  IF ~~ THEN REPLY #29455 EXTERN ~60MADAE~ 7
  IF ~~ THEN REPLY #29456 EXTERN ~60MADAE~ 8
  IF ~~ THEN REPLY #29457 GOTO 10
  IF ~~ THEN REPLY #29458 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 17
END

IF ~~ THEN BEGIN 3
  SAY #29459
  IF ~~ THEN REPLY #29460 EXTERN ~60MADAE~ 7
  IF ~~ THEN REPLY #29461 EXTERN ~60MADAE~ 7
  IF ~~ THEN REPLY #29462 EXTERN ~60MADAE~ 10
  IF ~~ THEN REPLY #29458 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 17
END

IF ~~ THEN BEGIN 4
  SAY #29463
  IF ~~ THEN REPLY #29455 EXTERN ~60MADAE~ 7
  IF ~~ THEN REPLY #29456 EXTERN ~60MADAE~ 8
  IF ~~ THEN REPLY #29457 GOTO 10
  IF ~~ THEN REPLY #29458 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 17
END

IF ~~ THEN BEGIN 5
  SAY #29464
  IF ~~ THEN REPLY #29455 EXTERN ~60MADAE~ 7
  IF ~~ THEN REPLY #29456 EXTERN ~60MADAE~ 8
  IF ~~ THEN REPLY #29457 GOTO 10
  IF ~~ THEN REPLY #29458 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 17
END

IF ~~ THEN BEGIN 6
  SAY #29465
  IF ~~ THEN REPLY #29466 EXTERN ~60MADAE~ 8
  IF ~~ THEN REPLY #29467 EXTERN ~60MADAE~ 9
  IF ~~ THEN REPLY #29468 EXTERN ~60MADAE~ 10
  IF ~~ THEN REPLY #29458 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 17
END

IF ~~ THEN BEGIN 7
  SAY #29469
  IF ~~ THEN REPLY #29470 GOTO 11
  IF ~~ THEN REPLY ~the player says something about their investigation of the mythal~ + MageIntimidateStart
  IF ~~ THEN REPLY #29471 GOTO 11
  IF ~~ THEN REPLY #29458 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 17
END

IF ~~ THEN BEGIN 8
  SAY #29472
  IF ~~ THEN REPLY #29473 EXTERN ~60MADAE~ 11
  IF ~~ THEN REPLY #29474 EXTERN ~60MADAE~ 8
  IF ~~ THEN REPLY #29475 GOTO 11
  IF ~~ THEN REPLY #29458 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 17
END

IF ~~ THEN BEGIN 9
  SAY #29476
  IF ~~ THEN REPLY #29477 GOTO 11
  IF ~~ THEN REPLY #29478 GOTO 11
  IF ~~ THEN REPLY #29458 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 17
END

IF ~~ THEN BEGIN 10
  SAY #29479
  IF ~~ THEN REPLY #29480 GOTO 15
  IF ~~ THEN REPLY #29481 GOTO 16
  IF ~  SubRace(Protagonist,HUMAN_AASIMAR)
~ THEN REPLY #29482 GOTO 16
  IF ~  SubRace(Protagonist,HUMAN_TIEFLING)
~ THEN REPLY #29482 GOTO 16
  IF ~~ THEN REPLY #29458 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 17
END

IF ~~ THEN BEGIN 11
  SAY #29483
  IF ~~ THEN EXTERN ~60MADAE~ 14
END

IF ~~ THEN BEGIN 12
  SAY #29484
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN 13
  SAY #29485
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN 14
  SAY #29486
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN 15
  SAY #29487
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN 16
  SAY #29488
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN 17
  SAY #29489
  IF ~~ THEN EXTERN ~60MADAE~ 15
END

IF ~~ THEN BEGIN 18
  SAY #29490
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN 19
  SAY #29491
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF WEIGHT #6 ~  NumTimesTalkedToGT(0)
GlobalLT("Final_Battle_Progress","GLOBAL",1)
~ THEN BEGIN 20
  SAY #29492
  IF ~~ THEN DO ~SetGlobal("Final_Battle_Progress","GLOBAL",1)~ EXTERN ~60MADAE~ 18
END

IF WEIGHT #5 ~  NumTimesTalkedToGT(0)
Global("Final_Battle_Progress","GLOBAL",1)
!Global("Pool_Tainted","GLOBAL",1)
~ THEN BEGIN 21
  SAY #29493
  IF ~~ THEN DO ~SetGlobal("Final_Battle_Progress","GLOBAL",2)~ EXTERN ~60MADAE~ 19
END

IF ~~ THEN BEGIN 22
  SAY #29494
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF WEIGHT #4 ~  NumTimesTalkedToGT(0)
Global("Final_Battle_Progress","GLOBAL",1)
Global("Pool_Tainted","GLOBAL",1)
~ THEN BEGIN 23
  SAY #29495
  IF ~~ THEN DO ~SetGlobal("Final_Battle_Progress","GLOBAL",2)~ EXTERN ~60MADAE~ 20
END

IF ~~ THEN BEGIN 24
  SAY #29496
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF WEIGHT #3 ~  NumTimesTalkedToGT(0)
Global("Final_Battle_Progress","GLOBAL",2)
~ THEN BEGIN 25
  SAY #29497
  IF ~~ THEN DO ~SetGlobal("Final_Battle_Progress","GLOBAL",3)~ EXTERN ~60MADAE~ 21
END

IF WEIGHT #2 ~  NumTimesTalkedToGT(0)
Global("Final_Battle_Progress","GLOBAL",3)
~ THEN BEGIN 26
  SAY #29498
  IF ~~ THEN EXTERN ~64ORRICK~ 68
END

IF ~~ THEN BEGIN 27
  SAY #29499
  IF ~~ THEN EXTERN ~60MADAE~ 23
END

IF WEIGHT #1 ~  NumTimesTalkedToGT(0)
Global("Ready_To_Retreat","GLOBAL",0)
~ THEN BEGIN 28
  SAY #32053
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN MageIntimidateStart
SAY ~isair says something about the mythal~
+ ~CheckSkillGT(Protagonist,30,Knowledge_Arcana)~ + ~the player says something intimidating about the mythal dying~ + SuccessfulMageIntimidate1
+ ~CheckSkillLT(Protagonist,30,Knowledge_Arcana)~ + ~the player says something unconvincing~ + FailedMageIntimidate
END

IF ~~ THEN BEGIN SuccessfulMageIntimidate1
SAY ~isair says something about the mythal~
+ ~CheckSkillGT(Protagonist,25,Bluff)~ + ~another thing about the mythal dying~ + SuccessfulMageIntimidate2
+ ~CheckSkillLT(Protagonist,25,Bluff)~ + ~something unconvincing about the mythal dying~ + FailedMageIntimidate
END

IF ~~ THEN BEGIN SuccessfulMageIntimidate2
SAY ~isair says something about the mythal~
+ ~CheckSkillGT(Protagonist,20,Intimidate)~ + ~another thing about the mythal dying~ + SuccessfulMageIntimidate3
+ ~CheckSkillLT(Protagonist,20,Intimidate)~ + ~something unconvincing about the mythal dying~ + FailedMageIntimidate
END

IF ~~ THEN BEGIN SuccessfulMageIntimidate3
SAY ~isair says something about the mythal~
+ ~~ + ~the player announces the collapse of the mythal~ + MythalTriggerMageIntimidate
END

IF ~~ THEN BEGIN FailedMageIntimidate
SAY ~isair is unconvinced about the mythal~
+ ~~ + ~the player says something~ + FailedMageIntimidateFight
END

IF ~~ THEN BEGIN NoArmyIntimidateI
SAY ~isair says their existing army is strong or something~
+ ~CheckSkillGT(Protagonist,20,Bluff)~ + ~the player says something convincing about the weakness of the legion~ + SuccessfulNoArmyIntimidate1
+ ~CheckSkillLT(Protagonist,20,Bluff)~ + ~the player says something unconvincing~ + FailedNoArmyIntimidate
END

IF ~~ THEN BEGIN FailedNoArmyIntimidate
SAY ~isair rebuts the argument~
+ ~~ + ~the player says something~ + FailedNoArmyIntimidateFight
END

IF ~~ THEN BEGIN SuccessfulNoArmyIntimidate1
SAY ~isair continues to disagree but admits some losses~
+ ~CheckSkillGT(Protagonist,25,Intimidate)~ + ~the player says something convincing about the party's or Ten Towns' strength~ + SuccessfulNoArmyIntimidate2
+ ~CheckSkillLT(Protagonist,25,Intimidate)~ + ~the player says something unconvincing~ + FailedNoArmyIntimidate
END

IF ~~ THEN BEGIN SuccessfulNoArmyIntimidate2
SAY ~isair is more discouraged~
+ ~CheckSkillGT(Protagonist,30,Intimidate)~ + ~the player continues to be convincing~ + SuccessfulNoArmyIntimidate3
+ ~CheckSkillLT(Protagonist,30,Intimidate)~ + ~the player says something unconvincing~ + FailedNoArmyIntimidate
END

IF ~~ THEN BEGIN SuccessfulNoArmyIntimidate3
SAY ~isair realizes they're in a bad position~
+ ~~ + ~the player says something~ + MythalTriggerNoArmyIntimidate
END

IF ~~ THEN BEGIN QuestionMotivesStartI
SAY ~isair defends their motives~
+ ~CheckSkillGT(Protagonist,30,Diplomacy)~ + ~the player says something convincing about ethics~ EXTERN ~60MADAE~ SuccessfulQuestionMotivesM
+ ~CheckSkillLT(Protagonist,30,Bluff)~ + ~the player says something unconvincing~ EXTERN ~60MADAE~ FailedQuestionMotivesM
END

IF ~~ THEN BEGIN FailedQuestionMotivesI
SAY ~isair is unconvinced and ready to fight~
+ ~~ + ~some player response~ + FailedQuestionMotivesFight
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI
SAY ~isair is hesitant as well~
+ ~~ + ~the player says something convincing~ + SuccessfulQuestionMotivesI2
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI2
SAY ~isair is hesitant again~
+ ~~ + ~the player says something convincing~ EXTERN ~60MADAE~ SuccessfulQuestionMotivesM2
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3
SAY ~isair is hesitant again~
+ ~~ + ~the player says something convincing~ + MythalTriggerQuestionMotives
END

IF ~~ THEN BEGIN FailedMageIntimidateFight
  SAY ~Enough of this stupidity. The Red Wizards have reviewed the mythal's structure dozens of times; they would have detected any flaws in the enchantments. This is a waste of time. Would it be all right if I killed them now, sister?~
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN FailedQuestionMotivesFight
  SAY ~Enough of this stupidity. There is no point in debating ethics with a band of mercenaries. Would it be all right if I killed them now, sister?~
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN FailedNoArmyIntimidateFight 
  SAY ~Enough of this stupidity. The Ten Towns are broken. The Legion has domain over the Severed Hand, and it is only a matter of time before the Ten Towns fall. Would it be all right if I killed them now, sister?~
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN MythalTriggerMageIntimidate
  SAY ~isair feels the mythal collapsing~
  IF ~~ THEN REPLY ~~ GOTO MythalTriggerMageIntimidate2
END

IF ~~ THEN BEGIN MythalTriggerMageIntimidate2
  SAY ~Madae... what was that?  What's happening to me?~
  IF ~~ THEN DO ~SetGlobal("Final_Battle_Progress","GLOBAL",3)~ EXTERN ~60MADAE~ 21
END

IF ~~ THEN BEGIN MythalTriggerQuestionMotives
  SAY ~isair feels the mythal collapsing~
  IF ~~ THEN REPLY ~~ GOTO MythalTriggerQuestionMotives2
END

IF ~~ THEN BEGIN MythalTriggerQuestionMotives2
  SAY ~Madae... what was that?  What's happening to me?~
  IF ~~ THEN DO ~SetGlobal("Final_Battle_Progress","GLOBAL",3)~ EXTERN ~60MADAE~ 21
END

IF ~~ THEN BEGIN MythalTriggerNoArmyIntimidate
  SAY ~isair feels the mythal collapsing~
  IF ~~ THEN REPLY ~~ GOTO MythalTriggerNoArmyIntimidate2
END

IF ~~ THEN BEGIN MythalTriggerNoArmyIntimidate2
  SAY ~Madae... what was that?  What's happening to me?~
  IF ~~ THEN DO ~SetGlobal("Final_Battle_Progress","GLOBAL",3)~ EXTERN ~60MADAE~ 21
END
