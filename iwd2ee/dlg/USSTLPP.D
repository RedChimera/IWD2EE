BEGIN ~USSTLPP~

IF WEIGHT #0 ~Global("Izbelah1_dead","GLOBAL",1)~ THEN BEGIN 5
  SAY @6214
  IF ~~ THEN GOTO 6
END

IF ~~ THEN BEGIN 6
  SAY @6215
  IF ~~ THEN DO ~SetGlobal("US_Pyros_End_Talk","GLOBAL",1)~ EXIT
END

IF ~~ THEN BEGIN 0
  SAY @6200
  IF ~~ THEN EXTERN ~USSTLPL~ 1
END

IF ~~ THEN BEGIN 1
  SAY @6205
  IF ~~ THEN EXTERN ~USSTLPI~ 2
END

IF ~~ THEN BEGIN 2
  SAY @6210
  IF ~~ THEN EXTERN ~USSTLPI~ 4
END

IF ~~ THEN BEGIN 3
  SAY @6212
  IF ~~ THEN EXTERN ~USSTLPI~ 5
END
