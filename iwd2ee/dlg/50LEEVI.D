BEGIN ~50LEEVI~

IF WEIGHT #1 ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY #6424
  IF ~~ THEN REPLY #6425 GOTO 1
  IF ~~ THEN REPLY #6426 GOTO 1
END

IF ~~ THEN BEGIN 1
  SAY #6427
  IF ~  GlobalGT("50Leevi","Global",0)
~ THEN REPLY #6428 GOTO 3
  IF ~~ THEN REPLY #6429 GOTO 2
  IF ~~ THEN REPLY #6430 EXIT
END

IF ~~ THEN BEGIN 2
  SAY #6431
  IF ~  GlobalGT("50Leevi","Global",0)
~ THEN REPLY #6432 GOTO 3
  IF ~  Global("50Leevi","Global",2)
~ THEN REPLY #6433 DO ~SetGlobal("50Leevi", "Global", 3)~ GOTO 7
  IF ~  !Global("50Leevi","Global",2)
~ THEN REPLY #6433 EXIT
END

IF ~~ THEN BEGIN 3
  SAY #6434
  IF ~~ THEN REPLY #6435 GOTO 4
  IF ~  GlobalLT("50Leevi","Global",2)
~ THEN REPLY #6436 DO ~SetGlobal("50Leevi", "Global", 2)~ GOTO 6
  IF ~  GlobalGT("50Leevi","Global",1)
~ THEN REPLY #6436 GOTO 6
  IF ~~ THEN REPLY #6437 GOTO 2
  IF ~  Global("50Leevi","Global",2)
~ THEN REPLY #6433 DO ~SetGlobal("50Leevi", "Global", 3)~ GOTO 7
  IF ~  !Global("50Leevi","Global",2)
~ THEN REPLY #6433 EXIT
END

IF ~~ THEN BEGIN 4
  SAY #6438
  IF ~~ THEN REPLY #6439 GOTO 5
  IF ~  GlobalLT("50Leevi","Global",2)
~ THEN REPLY #6440 DO ~SetGlobal("50Leevi", "Global", 2)~ GOTO 6
  IF ~  GlobalGT("50Leevi","Global",1)
~ THEN REPLY #6440 GOTO 6
  IF ~~ THEN REPLY #6441 GOTO 2
  IF ~  Global("50Leevi","Global",2)
~ THEN REPLY #6442 DO ~SetGlobal("50Leevi", "Global", 3)~ GOTO 7
  IF ~  !Global("50Leevi","Global",2)
~ THEN REPLY #6442 EXIT
END

IF ~~ THEN BEGIN 5
  SAY #6443
  IF ~  GlobalLT("50Leevi","Global",2)
~ THEN REPLY #6436 DO ~SetGlobal("50Leevi", "Global", 2)~ GOTO 6
  IF ~  GlobalGT("50Leevi","Global",1)
~ THEN REPLY #6436 GOTO 6
  IF ~~ THEN REPLY #6429 GOTO 2
  IF ~  Global("50Leevi","Global",2)
~ THEN REPLY #6444 DO ~SetGlobal("50Leevi", "Global", 3)~ GOTO 7
  IF ~  !Global("50Leevi","Global",2)
~ THEN REPLY #6444 EXIT
END

IF ~~ THEN BEGIN 6
  SAY #6445
  IF ~~ THEN REPLY #6446 GOTO 4
  IF ~~ THEN REPLY #6437 GOTO 2
  IF ~  Global("50Leevi","Global",2)
~ THEN REPLY #6433 DO ~SetGlobal("50Leevi", "Global", 3)~ GOTO 7
  IF ~  !Global("50Leevi","Global",2)
~ THEN REPLY #6433 EXIT
END

IF ~~ THEN BEGIN 7
  SAY #6447
  IF ~~ THEN EXIT
END

IF WEIGHT #2 ~  True()
~ THEN BEGIN 8
  SAY #6450
  IF ~  GlobalGT("50Leevi","Global",0)
~ THEN REPLY #6428 GOTO 3
  IF ~~ THEN REPLY #6429 GOTO 2
  IF ~  Global("50Leevi","Global",2)
~ THEN REPLY #24534 DO ~SetGlobal("50Leevi", "Global", 3)~ GOTO 7
  IF ~  !Global("50Leevi","Global",2)
~ THEN REPLY #24534 EXIT
END

IF WEIGHT #0 ~See([ENEMY], FALSE)~ THEN BEGIN 9
  SAY #37856
  IF ~~ THEN EXIT
END
