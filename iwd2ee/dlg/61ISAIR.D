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
  IF ~  Or(2)
  ClassEx(Protagonist,MAGE)
  ClassEx(Protagonist,SORCERER)
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
  IF ~~ THEN REPLY @6232 + MageIntimidateStart
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
SAY @6233
+ ~CheckSkillGT(Protagonist,23,Knowledge_Arcana)~ + @6234 + SuccessfulMageIntimidate1
+ ~~ + @6235 + FailedMageIntimidate
END

IF ~~ THEN BEGIN SuccessfulMageIntimidate1
SAY @6236
+ ~CheckSkillGT(Protagonist,12,Bluff)~ + @6237 + SuccessfulMageIntimidate2
+ ~~ + @6238 + FailedMageIntimidate
END

IF ~~ THEN BEGIN SuccessfulMageIntimidate2
SAY @6239
+ ~CheckSkillGT(Protagonist,11,Intimidate)~ + @6240 + SuccessfulMageIntimidate3
+ ~~ + @6241 + FailedMageIntimidate
END

IF ~~ THEN BEGIN SuccessfulMageIntimidate3
SAY @6242
+ ~~ + @6243 + MythalTriggerMageIntimidate
END

IF ~~ THEN BEGIN FailedMageIntimidate
SAY @6244
+ ~~ + @6245 + FailedMageIntimidateFight
+ ~~ + @6246 + FailedMageIntimidateFight
END

IF ~~ THEN BEGIN NoArmyIntimidateI
SAY @6247
+ ~CheckSkillGT(Protagonist,15,Bluff)~ + @6248 + SuccessfulNoArmyIntimidate1
+ ~~ + @6249 + FailedNoArmyIntimidate
END

IF ~~ THEN BEGIN FailedNoArmyIntimidate
SAY @6250
+ ~~ + @6251 + FailedNoArmyIntimidateFight
END

IF ~~ THEN BEGIN SuccessfulNoArmyIntimidate1
SAY @6252
+ ~CheckSkillGT(Protagonist,17,Intimidate)~ + @6253 + SuccessfulNoArmyIntimidate2
+ ~~ + @6254 + FailedNoArmyIntimidate
END

IF ~~ THEN BEGIN SuccessfulNoArmyIntimidate2
SAY @6255
+ ~CheckSkillGT(Protagonist,21,Intimidate)~ + @6256 + SuccessfulNoArmyIntimidate3
+ ~~ + @6257 + FailedNoArmyIntimidate
END

IF ~~ THEN BEGIN SuccessfulNoArmyIntimidate3
SAY @6258
+ ~~ + @6259 + MythalTriggerNoArmyIntimidate
END

IF ~~ THEN BEGIN QuestionMotivesStartI1A
SAY @6260
+ ~CheckSkillGT(Protagonist,11,Diplomacy)~ + @6261 EXTERN ~60MADAE~ SuccessfulQuestionMotivesM1A
+ ~~ + @6262 EXTERN ~60MADAE~ FailedQuestionMotivesM1A
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI1A
SAY @6263
+ ~~ + @6264 + SuccessfulQuestionMotivesI1B
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI1B
SAY @6265
+ ~~ + @6266 EXTERN ~60MADAE~ SuccessfulQuestionMotivesM1B
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI1C
SAY @6267
+ ~~ + @6268 GOTO SuccessfulQuestionMotivesI1D
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI1D
SAY @6269
+ ~~ + @6270 EXTERN ~60MADAE~ SuccessfulQuestionMotivesM1C
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI1E
SAY @6271
+ ~~ + @6272 GOTO FailedQuestionMotivesI1B
+ ~CheckSkillGT(Protagonist,25,Diplomacy)~ + @6273 EXTERN ~60MADAE~ SuccessfulQuestionMotivesM1D
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI1F
SAY @6274
+ ~~ + @6275 GOTO SuccessfulQuestionMotivesI1G
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI1G
  SAY @6276
  IF ~~ THEN REPLY @6277 GOTO MythalTriggerQuestionMotives1A
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI2A
SAY @6278
  IF ~CheckSkillGT(Protagonist,9,Bluff)~ THEN REPLY @6279 GOTO SuccessfulQuestionMotivesI2B
  IF ~CheckSkillLT(Protagonist,10,Bluff)~ THEN REPLY @6280 GOTO FailedQuestionMotivesI2B
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI2B
SAY @6281
  IF ~~ THEN REPLY @6282 EXTERN ~60MADAE~ SuccessfulQuestionMotivesM2C
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI2D
SAY @6283
  IF ~~ THEN REPLY @6285 GOTO SuccessfulQuestionMotivesI2F
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI2E
SAY @6284
  IF ~~ THEN REPLY @6285 GOTO SuccessfulQuestionMotivesI2F
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI2F
SAY @6286
  IF ~~ THEN REPLY @6287 EXTERN ~60MADAE~ QuestionMotivesStartM2D
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI2G
SAY @6288
  IF ~~ THEN REPLY @6289 GOTO SuccessfulQuestionMotivesI2H
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI2H
SAY @6290
  IF ~~ THEN REPLY @6291 GOTO SuccessfulQuestionMotivesI2I
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI2I
SAY @6292
  IF ~~ THEN REPLY @6293 GOTO MythalTriggerQuestionMotives2A
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3A
SAY @6294
  IF ~SubRace(Protagonist,ELF_DROW)~ THEN REPLY @6295 GOTO SuccessfulQuestionMotivesI3B
  IF ~Race(Protagonist,HALFORC)~ THEN REPLY @6296 GOTO SuccessfulQuestionMotivesI3B
  IF ~SubRace(Protagonist,HUMAN_TIEFLING)~ THEN REPLY @6297 GOTO SuccessfulQuestionMotivesI3B
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3B
SAY @6298
  IF ~Global("US_EGENIA_PART", "GLOBAL", 1)~ THEN REPLY @6299 EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3C
  IF ~~ THEN REPLY @6300 GOTO FailedQuestionMotives3B
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3C
SAY @6301
  IF ~~ THEN REPLY @6302 EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3D
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3D
SAY @6303
  IF ~~ THEN REPLY @6304 EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3E
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3E
SAY @6305
  IF ~~ THEN REPLY @6306 EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3F
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3F
SAY @6307
  IF ~~ THEN REPLY @6308 GOTO SuccessfulQuestionMotivesI3G
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3G
SAY @6309
  IF ~~ THEN REPLY @6310 GOTO SuccessfulQuestionMotivesI3H
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3H
SAY @6311
  IF ~~ THEN REPLY @6312 GOTO SuccessfulQuestionMotivesI3HH
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3HH
SAY @6313
  IF ~~ THEN REPLY @6314 EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3G
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3I
SAY @6315
  IF ~~ THEN REPLY @6316 EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3H
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3J
SAY @6317
  IF ~~ THEN EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3I
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3K
SAY @6318
  IF ~~ THEN GOTO SuccessfulQuestionMotivesI3L
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3L
SAY @6319
  IF ~~ THEN EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3J
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3M
SAY @6320
  IF ~~ THEN EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3JJ
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3N
SAY @6321
  IF ~~ THEN REPLY @6322 GOTO SuccessfulQuestionMotivesI3O
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3O
SAY @6323
  IF ~~ THEN EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3K
END

IF ~~ THEN BEGIN FailedMageIntimidateFight
  SAY @6324
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN FailedQuestionMotivesFight
  SAY @6325
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN FailedQuestionMotivesI1A
  SAY @6326
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN FailedQuestionMotivesI1B
  SAY @6327
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ FailedQuestionMotivesM1B
END

IF ~~ THEN BEGIN FailedQuestionMotivesI2A
  SAY @6328
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN FailedQuestionMotivesI2B
  SAY @6329
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN FailedQuestionMotivesRaceAnyI
  SAY @6330
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN FailedQuestionMotives3B
  SAY @6331
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN FailedQuestionMotives3C
  SAY @6332
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN FailedNoArmyIntimidateFight 
  SAY @6333
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN MythalTriggerMageIntimidate
  SAY @6334
  IF ~~ THEN REPLY @6335 GOTO MythalTriggerMageIntimidate2
END

IF ~~ THEN BEGIN MythalTriggerMageIntimidate2
  SAY @6336
  IF ~~ THEN DO ~SetGlobal("Final_Battle_Progress","GLOBAL",3)~ EXTERN ~60MADAE~ 21
END

IF ~~ THEN BEGIN MythalTriggerQuestionMotives1A
  SAY @6337
  IF ~~ THEN REPLY @6338 GOTO MythalTriggerQuestionMotives1B
END

IF ~~ THEN BEGIN MythalTriggerQuestionMotives1B
  SAY @6339
  IF ~~ THEN DO ~SetGlobal("Final_Battle_Progress","GLOBAL",3)~ EXTERN ~60MADAE~ 21
END

IF ~~ THEN BEGIN MythalTriggerQuestionMotives2A
  SAY @6340
  IF ~~ THEN REPLY @6341 GOTO MythalTriggerQuestionMotives2B
  IF ~~ THEN REPLY @6342 GOTO MythalTriggerQuestionMotives2B
END

IF ~~ THEN BEGIN MythalTriggerQuestionMotives2B
  SAY @6343
  IF ~~ THEN DO ~SetGlobal("Final_Battle_Progress","GLOBAL",3)~ EXTERN ~60MADAE~ 21
END

IF ~~ THEN BEGIN MythalTriggerQuestionMotives3A
  SAY @6344
  IF ~~ THEN REPLY @6345 DO ~SetGlobal("Final_Battle_Progress","GLOBAL",3)~ EXTERN ~60MADAE~ 21
END

IF ~~ THEN BEGIN MythalTriggerNoArmyIntimidate
  SAY @6346
  IF ~~ THEN REPLY @6347 GOTO MythalTriggerNoArmyIntimidate2
  IF ~~ THEN REPLY @6348 GOTO MythalTriggerNoArmyIntimidate2
END

IF ~~ THEN BEGIN MythalTriggerNoArmyIntimidate2
  SAY @6349
  IF ~~ THEN DO ~SetGlobal("StartCutscene_63cFB06","MYAREA",1)
SetGlobal("Final_Battle_Progress","GLOBAL",3)
SetGlobal("US_Final_Battle_Alternate","GLOBAL",1)
Unlock("AR6303_Door1")
SetGlobal("Activate_Trigger","MYAREA",1)
SetGlobal("StartCutscene_63cFB03","MYAREA",1)
HideCreature("Serak",FALSE)
HideCreature("Mourn",FALSE)
HideCreature("Zilvar",FALSE)
HideCreature("Tilzen",FALSE)
HideCreature("Phaen",FALSE)
HideCreature("Chimera",FALSE)
HideCreature("Buvai_deNaly",FALSE)
ActionOverride("Serak",DestroySelf())
ActionOverride("Mourn",DestroySelf())
ActionOverride("Zilvar",DestroySelf())
ActionOverride("Tilzen",DestroySelf())
ActionOverride("Phaen",DestroySelf())
ActionOverride("Chimera",DestroySelf())
ActionOverride("Buvai_deNaly",DestroySelf())
ActionOverride("Ormis_Dohor",DestroySelf())
ActionOverride("Monk_Sand",DestroySelf())
ActionOverride("Monk_Shadow",DestroySelf())
ActionOverride("Monk_Crystalline",DestroySelf())
ActionOverride("Isair",DestroySelf())
ActionOverride("Madae",DestroySelf())~ EXTERN ~60MADAE~ 21
END

IF ~~ THEN BEGIN ListOfCommands
  SAY ~This should not appear in-game.~
  IF ~~ THEN DO ~SetGlobal("Final_Battle_Progress","GLOBAL",3)
SetGlobal("StartCutscene_63cFB02","MYAREA",1)
SetGlobal("US_Final_Battle_Alternate","GLOBAL",1)
Unlock("AR6303_Door1")
SetGlobal("Activate_Trigger","MYAREA",1)
HideCreature("Serak",TRUE)
HideCreature("Mourn",TRUE)
HideCreature("Zilvar",TRUE)
HideCreature("Tilzen",TRUE)
HideCreature("Phaen",TRUE)
HideCreature("Chimera",TRUE)
HideCreature("Buvai_deNaly",TRUE)
ActionOverride("Serak",DestroySelf())
ActionOverride("Mourn",DestroySelf())
ActionOverride("Zilvar",DestroySelf())
ActionOverride("Tilzen",DestroySelf())
ActionOverride("Phaen",DestroySelf())
ActionOverride("Chimera",DestroySelf())
ActionOverride("Buvai_deNaly",DestroySelf())
SetGlobal("StartCutscene_63cFB06","MYAREA",1)
ActionOverride("Ormis_Dohor",DestroySelf())
ActionOverride("Monk_Sand",DestroySelf())
ActionOverride("Monk_Shadow",DestroySelf())
ActionOverride("Monk_Crystalline",DestroySelf())~ EXIT
END

IF ~~ THEN BEGIN ListOfCommands2
  SAY ~This should not appear in-game.~
  IF ~~ THEN DO ~SetGlobal("StartCutscene_63cFB06","MYAREA",1)
SetGlobal("Final_Battle_Progress","GLOBAL",3)
SetGlobal("US_Final_Battle_Alternate","GLOBAL",1)
Unlock("AR6303_Door1")
SetGlobal("Activate_Trigger","MYAREA",1)
SetGlobal("StartCutscene_63cFB03","MYAREA",1)
HideCreature("Serak",FALSE)
HideCreature("Mourn",FALSE)
HideCreature("Zilvar",FALSE)
HideCreature("Tilzen",FALSE)
HideCreature("Phaen",FALSE)
HideCreature("Chimera",FALSE)
HideCreature("Buvai_deNaly",FALSE)
ActionOverride("Serak",DestroySelf())
ActionOverride("Mourn",DestroySelf())
ActionOverride("Zilvar",DestroySelf())
ActionOverride("Tilzen",DestroySelf())
ActionOverride("Phaen",DestroySelf())
ActionOverride("Chimera",DestroySelf())
ActionOverride("Buvai_deNaly",DestroySelf())
ActionOverride("Ormis_Dohor",DestroySelf())
ActionOverride("Monk_Sand",DestroySelf())
ActionOverride("Monk_Shadow",DestroySelf())
ActionOverride("Monk_Crystalline",DestroySelf())~ EXIT
END
