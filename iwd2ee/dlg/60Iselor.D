BEGIN ~60ISELOR~

IF WEIGHT #0 ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY #29277
  IF ~~ THEN REPLY #29278 DO ~SetGlobal("Know_Iselore","GLOBAL",1)
SetGlobal("Know_Crossroads","GLOBAL",1)~ GOTO 1
  IF ~~ THEN REPLY #29279 DO ~SetGlobal("Know_Iselore","GLOBAL",1)~ GOTO 5
  IF ~~ THEN REPLY #29280 DO ~SetGlobal("Know_Iselore","GLOBAL",1)~ GOTO 6
  IF ~~ THEN REPLY #29281 DO ~SetGlobal("Know_Iselore","GLOBAL",1)~ GOTO 36
  IF ~~ THEN REPLY #29282 DO ~SetGlobal("Know_Iselore","GLOBAL",1)~ GOTO 39
  IF ~~ THEN REPLY #41125 DO ~SetGlobal("Know_Iselore","GLOBAL",1)StartStore("60Iselor", Protagonist)~ EXIT
  IF ~~ THEN REPLY #29283 DO ~SetGlobal("Know_Iselore","GLOBAL",1)~ EXIT
END

IF ~~ THEN BEGIN 1
  SAY #29284
  IF ~~ THEN REPLY #29285 GOTO 2
END

IF ~~ THEN BEGIN 2
  SAY #29286
  IF ~~ THEN REPLY #29287 GOTO 3
END

IF ~~ THEN BEGIN 3
  SAY #29288
  IF ~~ THEN REPLY #29289 GOTO 4
END

IF ~~ THEN BEGIN 4
  SAY #29290
  IF ~  Global("Know_Crossroads","GLOBAL",1)
GlobalLT("Crossroads_Quest","GLOBAL",2)
~ THEN REPLY #29291 GOTO 40
  IF ~~ THEN REPLY #29292 DO ~SetGlobal("Crossroads_Quest","GLOBAL",1)~ GOTO 41
  IF ~~ THEN REPLY #29279 GOTO 5
  IF ~~ THEN REPLY #29280 GOTO 6
  IF ~  Global("60Twins_Story","GLOBAL",1)
~ THEN REPLY #29293 GOTO 11
  IF ~  Global("60Twins_Story","GLOBAL",2)
~ THEN REPLY #29294 GOTO 15
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29295 GOTO 19
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29296 GOTO 22
  IF ~  Global("60Twins_Story","GLOBAL",4)
~ THEN REPLY #29297 GOTO 26
  IF ~  Global("60Twins_Story","GLOBAL",5)
~ THEN REPLY #29298 GOTO 31
  IF ~~ THEN REPLY #29281 GOTO 36
  IF ~  GlobalLT("Crossroads_Quest","GLOBAL",2)
~ THEN REPLY #29282 GOTO 39
  IF ~  !GlobalLT("Crossroads_Quest","GLOBAL",2)
~ THEN REPLY #34634 GOTO 48
  IF ~~ THEN REPLY #41126 DO ~StartStore("60Iselor", Protagonist)~ EXIT
  IF ~~ THEN REPLY #29283 EXIT
END

IF ~~ THEN BEGIN 5
  SAY #29299
  IF ~  Global("Know_Crossroads","GLOBAL",1)
GlobalLT("Crossroads_Quest","GLOBAL",2)
~ THEN REPLY #29291 GOTO 40
  IF ~  Global("Crossroads_Quest","GLOBAL",0)
~ THEN REPLY #29292 DO ~SetGlobal("Crossroads_Quest","GLOBAL",1)~ GOTO 41
  IF ~  GlobalLT("Crossroads_Quest","GLOBAL",2)
~ THEN REPLY #29278 GOTO 1
  IF ~~ THEN REPLY #29280 GOTO 6
  IF ~  Global("60Twins_Story","GLOBAL",1)
~ THEN REPLY #29293 GOTO 11
  IF ~  Global("60Twins_Story","GLOBAL",2)
~ THEN REPLY #29294 GOTO 15
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29295 GOTO 19
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29296 GOTO 22
  IF ~  Global("60Twins_Story","GLOBAL",4)
~ THEN REPLY #29297 GOTO 26
  IF ~  Global("60Twins_Story","GLOBAL",5)
~ THEN REPLY #29298 GOTO 31
  IF ~~ THEN REPLY #29281 GOTO 36
  IF ~  GlobalLT("Crossroads_Quest","GLOBAL",2)
~ THEN REPLY #29282 GOTO 39
  IF ~  !GlobalLT("Crossroads_Quest","GLOBAL",2)
~ THEN REPLY #34635 GOTO 48
  IF ~~ THEN REPLY #41127 DO ~StartStore("60Iselor", Protagonist)~ EXIT
  IF ~~ THEN REPLY #29283 EXIT
END

IF ~~ THEN BEGIN 6
  SAY #29300
  IF ~  GlobalGT("60Twins_Story","GLOBAL",0)
~ THEN REPLY #29301 GOTO 7
  IF ~  Global("60Twins_Story","GLOBAL",0)
~ THEN REPLY #33538 DO ~SetGlobal("60Twins_Story","GLOBAL",1)~ GOTO 7
END

IF ~~ THEN BEGIN 7
  SAY #29302
  IF ~~ THEN GOTO 8
END

IF ~~ THEN BEGIN 8
  SAY #29304
  IF ~~ THEN GOTO 9
END

IF ~~ THEN BEGIN 9
  SAY #29305
  IF ~~ THEN GOTO 10
END

IF ~~ THEN BEGIN 10
  SAY #29306
  IF ~~ THEN REPLY #29307 GOTO 11
  IF ~~ THEN REPLY #29308 GOTO 43
END

IF ~~ THEN BEGIN 11
  SAY #29309
  IF ~~ THEN GOTO 12
END

IF ~~ THEN BEGIN 12
  SAY #29310
  IF ~~ THEN GOTO 13
END

IF ~~ THEN BEGIN 13
  SAY #29311
  IF ~  GlobalLT("60Twins_Story","GLOBAL",2)
~ THEN REPLY #35598 DO ~SetGlobal("60Twins_Story","GLOBAL",2)~ GOTO 14
  IF ~  GlobalGT("60Twins_Story","GLOBAL",1)
~ THEN REPLY #35599 GOTO 14
END

IF ~~ THEN BEGIN 14
  SAY #29312
  IF ~~ THEN REPLY #29294 GOTO 15
  IF ~~ THEN REPLY #29308 GOTO 43
END

IF ~~ THEN BEGIN 15
  SAY #29313
  IF ~~ THEN GOTO 16
END

IF ~~ THEN BEGIN 16
  SAY #29314
  IF ~~ THEN GOTO 17
END

IF ~~ THEN BEGIN 17
  SAY #29315
  IF ~  GlobalLT("60Twins_Story","GLOBAL",3)
~ THEN REPLY #35600 DO ~SetGlobal("60Twins_Story","GLOBAL",3)~ GOTO 18
  IF ~  GlobalGT("60Twins_Story","GLOBAL",2)
~ THEN REPLY #35601 GOTO 18
END

IF ~~ THEN BEGIN 18
  SAY #29316
  IF ~~ THEN REPLY #29295 GOTO 19
  IF ~~ THEN REPLY #29317 GOTO 22
  IF ~~ THEN REPLY #29308 GOTO 43
END

IF ~~ THEN BEGIN 19
  SAY #29318
  IF ~~ THEN GOTO 20
END

IF ~~ THEN BEGIN 20
  SAY #29319
  IF ~~ THEN GOTO 21
END

IF ~~ THEN BEGIN 21
  SAY #29320
  IF ~~ THEN GOTO 22
END

IF ~~ THEN BEGIN 22
  SAY #29321
  IF ~~ THEN GOTO 23
END

IF ~~ THEN BEGIN 23
  SAY #29322
  IF ~~ THEN GOTO 24
END

IF ~~ THEN BEGIN 24
  SAY #29323
  IF ~  GlobalLT("60Twins_Story","GLOBAL",4)
~ THEN REPLY #35602 DO ~SetGlobal("60Twins_Story","GLOBAL",4)
SetGlobal("US_EGENIA_PART","GLOBAL",1)~ GOTO 25
  IF ~  GlobalGT("60Twins_Story","GLOBAL",3)
~ THEN REPLY #35603 GOTO 25
END

IF ~~ THEN BEGIN 25
  SAY #29324
  IF ~~ THEN REPLY #29297 GOTO 26
  IF ~~ THEN REPLY #29308 GOTO 43
END

IF ~~ THEN BEGIN 26
  SAY #29325
  IF ~~ THEN GOTO 27
END

IF ~~ THEN BEGIN 27
  SAY #29326
  IF ~~ THEN GOTO 28
END

IF ~~ THEN BEGIN 28
  SAY #29327
  IF ~~ THEN GOTO 29
END

IF ~~ THEN BEGIN 29
  SAY #29328
  IF ~  GlobalLT("60Twins_Story","GLOBAL",5)
~ THEN REPLY #35604 DO ~SetGlobal("60Twins_Story","GLOBAL",5)~ GOTO 30
  IF ~  GlobalGT("60Twins_Story","GLOBAL",4)
~ THEN REPLY #35605 GOTO 30
END

IF ~~ THEN BEGIN 30
  SAY #29329
  IF ~~ THEN REPLY #29298 GOTO 31
  IF ~~ THEN REPLY #29308 GOTO 43
END

IF ~~ THEN BEGIN 31
  SAY #29330
  IF ~  GlobalLT("60Twins_Story","GLOBAL",6)
~ THEN REPLY #35606 DO ~SetGlobal("60Twins_Story","GLOBAL",6)~ GOTO 32
  IF ~  GlobalGT("60Twins_Story","GLOBAL",5)
~ THEN REPLY #35607 GOTO 32
END

IF ~~ THEN BEGIN 32
  SAY #29331
  IF ~~ THEN GOTO 33
END

IF ~~ THEN BEGIN 33
  SAY #29332
  IF ~~ THEN GOTO 34
END

IF ~~ THEN BEGIN 34
  SAY #29333
  IF ~~ THEN GOTO 35
END

IF ~~ THEN BEGIN 35
  SAY #29334
  IF ~  Global("Know_Crossroads","GLOBAL",1)
GlobalLT("Crossroads_Quest","GLOBAL",2)
~ THEN REPLY #29278 DO ~SetGlobal("Know_Crossroads","GLOBAL",1)~ GOTO 1
  IF ~  Global("Crossroads_Quest","GLOBAL",0)
~ THEN REPLY #29292 DO ~SetGlobal("Crossroads_Quest","GLOBAL",1)~ GOTO 41
  IF ~~ THEN REPLY #29279 GOTO 5
  IF ~~ THEN REPLY #29280 GOTO 6
  IF ~  Global("60Twins_Story","GLOBAL",1)
~ THEN REPLY #29293 GOTO 11
  IF ~  Global("60Twins_Story","GLOBAL",2)
~ THEN REPLY #29294 GOTO 15
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29295 GOTO 19
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29296 GOTO 22
  IF ~  Global("60Twins_Story","GLOBAL",4)
~ THEN REPLY #29297 GOTO 26
  IF ~  Global("60Twins_Story","GLOBAL",5)
~ THEN REPLY #29298 GOTO 31
  IF ~~ THEN REPLY #29281 GOTO 36
  IF ~  GlobalLT("Crossroads_Quest","GLOBAL",2)
~ THEN REPLY #29282 GOTO 39
  IF ~  !GlobalLT("Crossroads_Quest","GLOBAL",2)
~ THEN REPLY #34636 GOTO 48
  IF ~~ THEN REPLY #41128 DO ~StartStore("60Iselor", Protagonist)~ EXIT
  IF ~~ THEN REPLY #29283 EXIT
END

IF ~~ THEN BEGIN 36
  SAY #29335
  IF ~~ THEN GOTO 37
END

IF ~~ THEN BEGIN 37
  SAY #29336
  IF ~~ THEN REPLY #29337 GOTO 38
END

IF ~~ THEN BEGIN 38
  SAY #29338
  IF ~  Global("Know_Crossroads","GLOBAL",1)
GlobalLT("Crossroads_Quest","GLOBAL",2)
~ THEN REPLY #29278 DO ~SetGlobal("Know_Crossroads","GLOBAL",1)~ GOTO 1
  IF ~  Global("Crossroads_Quest","GLOBAL",0)
~ THEN REPLY #29292 DO ~SetGlobal("Crossroads_Quest","GLOBAL",1)~ GOTO 41
  IF ~~ THEN REPLY #29279 GOTO 5
  IF ~~ THEN REPLY #29280 GOTO 6
  IF ~  Global("60Twins_Story","GLOBAL",1)
~ THEN REPLY #29293 GOTO 11
  IF ~  Global("60Twins_Story","GLOBAL",2)
~ THEN REPLY #29294 GOTO 15
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29295 GOTO 19
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29296 GOTO 22
  IF ~  Global("60Twins_Story","GLOBAL",4)
~ THEN REPLY #29297 GOTO 26
  IF ~  Global("60Twins_Story","GLOBAL",5)
~ THEN REPLY #29298 GOTO 31
  IF ~~ THEN REPLY #29281 GOTO 36
  IF ~  GlobalLT("Crossroads_Quest","GLOBAL",2)
~ THEN REPLY #29282 GOTO 39
  IF ~  !GlobalLT("Crossroads_Quest","GLOBAL",2)
~ THEN REPLY #34637 GOTO 48
  IF ~~ THEN REPLY #41129 DO ~StartStore("60Iselor", Protagonist)~ EXIT
  IF ~~ THEN REPLY #29283 EXIT
END

IF ~~ THEN BEGIN 39
  SAY #29339
  IF ~~ THEN REPLY #29292 DO ~SetGlobal("Crossroads_Quest","GLOBAL",1)~ GOTO 41
  IF ~~ THEN REPLY #29279 GOTO 5
  IF ~~ THEN REPLY #29280 GOTO 6
  IF ~  Global("60Twins_Story","GLOBAL",1)
~ THEN REPLY #29293 GOTO 11
  IF ~  Global("60Twins_Story","GLOBAL",2)
~ THEN REPLY #29294 GOTO 15
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29295 GOTO 19
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29296 GOTO 22
  IF ~  Global("60Twins_Story","GLOBAL",4)
~ THEN REPLY #29297 GOTO 26
  IF ~  Global("60Twins_Story","GLOBAL",5)
~ THEN REPLY #29298 GOTO 31
  IF ~~ THEN REPLY #29281 GOTO 36
  IF ~~ THEN REPLY #41130 DO ~StartStore("60Iselor", Protagonist)~ EXIT
  IF ~~ THEN REPLY #29283 EXIT
END

IF ~~ THEN BEGIN 40
  SAY #29340
  IF ~~ THEN REPLY #29292 DO ~SetGlobal("Crossroads_Quest","GLOBAL",1)~ GOTO 41
  IF ~~ THEN REPLY #29279 GOTO 5
  IF ~~ THEN REPLY #29280 GOTO 6
  IF ~  Global("60Twins_Story","GLOBAL",1)
~ THEN REPLY #29293 GOTO 11
  IF ~  Global("60Twins_Story","GLOBAL",2)
~ THEN REPLY #29294 GOTO 15
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29295 GOTO 19
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29296 GOTO 22
  IF ~  Global("60Twins_Story","GLOBAL",4)
~ THEN REPLY #29297 GOTO 26
  IF ~  Global("60Twins_Story","GLOBAL",5)
~ THEN REPLY #29298 GOTO 31
  IF ~~ THEN REPLY #29281 GOTO 36
  IF ~~ THEN REPLY #41131 DO ~StartStore("60Iselor", Protagonist)~ EXIT
  IF ~~ THEN REPLY #29283 EXIT
END

IF ~~ THEN BEGIN 41
  SAY #29341
  IF ~~ THEN REPLY #29342 JOURNAL #29273 GOTO 42
END

IF ~~ THEN BEGIN 42
  SAY #29343
  IF ~~ THEN REPLY #29279 GOTO 5
  IF ~~ THEN REPLY #29280 GOTO 6
  IF ~  Global("60Twins_Story","GLOBAL",1)
~ THEN REPLY #29293 GOTO 11
  IF ~  Global("60Twins_Story","GLOBAL",2)
~ THEN REPLY #29294 GOTO 15
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29295 GOTO 19
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29296 GOTO 22
  IF ~  Global("60Twins_Story","GLOBAL",4)
~ THEN REPLY #29297 GOTO 26
  IF ~  Global("60Twins_Story","GLOBAL",5)
~ THEN REPLY #29298 GOTO 31
  IF ~~ THEN REPLY #29281 GOTO 36
  IF ~~ THEN REPLY #41132 DO ~StartStore("60Iselor", Protagonist)~ EXIT
  IF ~~ THEN REPLY #29283 EXIT
END

IF ~~ THEN BEGIN 43
  SAY #29344
  IF ~  GlobalLT("Know_Crossroads","GLOBAL",1)
~ THEN REPLY #29278 DO ~SetGlobal("Know_Crossroads","GLOBAL",1)~ GOTO 1
  IF ~  GlobalLT("Crossroads_Quest","GLOBAL",1)
~ THEN REPLY #29292 DO ~SetGlobal("Crossroads_Quest","GLOBAL",1)~ GOTO 41
  IF ~~ THEN REPLY #29279 GOTO 5
  IF ~~ THEN REPLY #29280 GOTO 6
  IF ~  Global("60Twins_Story","GLOBAL",1)
~ THEN REPLY #29293 GOTO 11
  IF ~  Global("60Twins_Story","GLOBAL",2)
~ THEN REPLY #29294 GOTO 15
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29295 GOTO 19
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29296 GOTO 22
  IF ~  Global("60Twins_Story","GLOBAL",4)
~ THEN REPLY #29297 GOTO 26
  IF ~  Global("60Twins_Story","GLOBAL",5)
~ THEN REPLY #29298 GOTO 31
  IF ~~ THEN REPLY #29281 GOTO 36
  IF ~  !Global("AR6100_Revealed","GLOBAL",1)
~ THEN REPLY #29282 GOTO 39
  IF ~  Global("AR6100_Revealed","GLOBAL",1)
~ THEN REPLY #29282 GOTO 48
  IF ~~ THEN REPLY #41133 DO ~StartStore("60Iselor", Protagonist)~ EXIT
  IF ~~ THEN REPLY #29283 EXIT
END

IF WEIGHT #3 ~  NumTimesTalkedToGT(0)
Global("Crossroads_Quest","GLOBAL",0)
~ THEN BEGIN 44
  SAY #29345
  IF ~~ THEN REPLY #29278 DO ~SetGlobal("Know_Crossroads","GLOBAL",1)~ GOTO 1
  IF ~~ THEN REPLY #29292 DO ~SetGlobal("Crossroads_Quest","GLOBAL",1)~ GOTO 41
  IF ~~ THEN REPLY #29279 GOTO 5
  IF ~~ THEN REPLY #29280 GOTO 6
  IF ~  Global("60Twins_Story","GLOBAL",1)
~ THEN REPLY #29293 GOTO 11
  IF ~  Global("60Twins_Story","GLOBAL",2)
~ THEN REPLY #29294 GOTO 15
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29295 GOTO 19
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29296 GOTO 22
  IF ~  Global("60Twins_Story","GLOBAL",4)
~ THEN REPLY #29297 GOTO 26
  IF ~  Global("60Twins_Story","GLOBAL",5)
~ THEN REPLY #29298 GOTO 31
  IF ~~ THEN REPLY #29281 GOTO 36
  IF ~  GlobalLT("Crossroads_Quest","GLOBAL",2)
~ THEN REPLY #29282 GOTO 39
  IF ~  !GlobalLT("Crossroads_Quest","GLOBAL",2)
~ THEN REPLY #34638 GOTO 48
  IF ~~ THEN REPLY #41134 DO ~StartStore("60Iselor", Protagonist)~ EXIT
  IF ~~ THEN REPLY #29283 EXIT
END

IF WEIGHT #4 ~  NumTimesTalkedToGT(0)
Global("Crossroads_Quest","GLOBAL",1)
~ THEN BEGIN 45
  SAY #29346
  IF ~~ THEN REPLY #29278 DO ~SetGlobal("Know_Crossroads","GLOBAL",1)~ GOTO 1
  IF ~~ THEN REPLY #29292 DO ~SetGlobal("Crossroads_Quest","GLOBAL",1)~ GOTO 41
  IF ~~ THEN REPLY #29279 GOTO 5
  IF ~~ THEN REPLY #29280 GOTO 6
  IF ~  Global("60Twins_Story","GLOBAL",1)
~ THEN REPLY #29293 GOTO 11
  IF ~  Global("60Twins_Story","GLOBAL",2)
~ THEN REPLY #29294 GOTO 15
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29295 GOTO 19
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29296 GOTO 22
  IF ~  Global("60Twins_Story","GLOBAL",4)
~ THEN REPLY #29297 GOTO 26
  IF ~  Global("60Twins_Story","GLOBAL",5)
~ THEN REPLY #29298 GOTO 31
  IF ~~ THEN REPLY #29281 GOTO 36
  IF ~  GlobalLT("Crossroads_Quest","GLOBAL",2)
~ THEN REPLY #29282 GOTO 39
  IF ~  !GlobalLT("Crossroads_Quest","GLOBAL",2)
~ THEN REPLY #34639 GOTO 48
  IF ~~ THEN REPLY #41135 DO ~StartStore("60Iselor", Protagonist)~ EXIT
  IF ~~ THEN REPLY #29283 EXIT
END

IF WEIGHT #5 ~  NumTimesTalkedToGT(0)
Global("Crossroads_Quest","GLOBAL",2)
~ THEN BEGIN 46
  SAY #29347
  IF ~~ THEN REPLY #29348 DO ~AddXpVar("Level_12_Average",29275)
SetGlobal("Crossroads_Quest","GLOBAL",4)~ GOTO 48
  IF ~~ THEN REPLY #29349 DO ~AddXpVar("Level_12_Average",29275)
SetGlobal("Crossroads_Quest","GLOBAL",4)~ GOTO 48
END

IF WEIGHT #6 ~  NumTimesTalkedToGT(0)
Global("Crossroads_Quest","GLOBAL",3)
~ THEN BEGIN 47
  SAY #29350
  IF ~~ THEN REPLY #29351 DO ~AddXpVar("Level_12_Hard",29276)
SetGlobal("Crossroads_Quest","GLOBAL",4)~ GOTO 48
  IF ~~ THEN REPLY #29352 DO ~AddXpVar("Level_12_Hard",29276)
SetGlobal("Crossroads_Quest","GLOBAL",4)~ GOTO 48
END

IF ~~ THEN BEGIN 48
  SAY ~As[mah-DAY] Madae made clear, the Legion advances its forces up through Dragon's Eye.  The eruptions years ago must have opened passageways through the mountain.  The base of the volcano sits on the edge of the Fields of Slaughter.  But the past few days, I've noticed a strange disturbance in the temporal field.  Someone in Dragon's Eye is performing a ritual of some sort... You should investigate the disturbance while you're there.  It may pose a serious threat.~
  IF ~~ THEN REPLY #29354 DO ~SetGlobal("AR6100_Revealed","GLOBAL",1)~ JOURNAL #29274 GOTO 43
  IF ~~ THEN REPLY #29355 DO ~SetGlobal("AR6100_Revealed","GLOBAL",1)~ JOURNAL #29274 EXIT
END

IF WEIGHT #7 ~  NumTimesTalkedToGT(0)
Global("Crossroads_Quest","GLOBAL",4)
~ THEN BEGIN 49
  SAY #29356
  IF ~  GlobalLT("Know_Crossroads","GLOBAL",1)
Global("AR6100_Revealed","GLOBAL",0)
~ THEN REPLY #29278 DO ~SetGlobal("Know_Crossroads","GLOBAL",1)~ GOTO 1
  IF ~  GlobalLT("Crossroads_Quest","GLOBAL",1)
~ THEN REPLY #29292 DO ~SetGlobal("Crossroads_Quest","GLOBAL",1)~ GOTO 41
  IF ~~ THEN REPLY #29279 GOTO 5
  IF ~~ THEN REPLY #29280 GOTO 6
  IF ~  Global("60Twins_Story","GLOBAL",1)
~ THEN REPLY #29293 GOTO 11
  IF ~  Global("60Twins_Story","GLOBAL",2)
~ THEN REPLY #29294 GOTO 15
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29295 GOTO 19
  IF ~  Global("60Twins_Story","GLOBAL",3)
~ THEN REPLY #29296 GOTO 22
  IF ~  Global("60Twins_Story","GLOBAL",4)
~ THEN REPLY #29297 GOTO 26
  IF ~  Global("60Twins_Story","GLOBAL",5)
~ THEN REPLY #29298 GOTO 31
  IF ~~ THEN REPLY #29281 GOTO 36
  IF ~  !Global("AR6100_Revealed","GLOBAL",1)
~ THEN REPLY #29282 GOTO 39
  IF ~  Global("AR6100_Revealed","GLOBAL",1)
~ THEN REPLY #29282 GOTO 48
  IF ~~ THEN REPLY #41136 DO ~StartStore("60Iselor", Protagonist)~ EXIT
  IF ~~ THEN REPLY #29283 EXIT
END

IF WEIGHT #2 ~  Global("Kuldahar_Start_Cutscene","GLOBAL",2)
~ THEN BEGIN 50
  SAY #29357
  IF ~~ THEN DO ~SetGlobal("Kuldahar_Start_Cutscene","GLOBAL",3)~ EXTERN ~60MADAE~ 24
END

IF ~~ THEN BEGIN 51
  SAY #29358
  IF ~~ THEN EXTERN ~60MADAE~ 26
END

IF ~~ THEN BEGIN 52
  SAY #29359
  IF ~~ THEN EXTERN ~60MADAE~ 27
END

IF ~~ THEN BEGIN 53
  SAY #29360
  IF ~~ THEN EXTERN ~60MADAE~ 34
END

IF WEIGHT #1 ~  Global("Kuldahar_Start_Cutscene","GLOBAL",3)
GlobalLT("6001_Fight","GLOBAL",2)
~ THEN BEGIN 54
  SAY #34766
  IF ~~ THEN EXIT
END
