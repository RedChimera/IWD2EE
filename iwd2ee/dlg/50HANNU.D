BEGIN ~50HANNU~

IF WEIGHT #2 ~  CurrentAreaIs(Myself,5000)
Global("50Hannu","GLOBAL",0)
~ THEN BEGIN 0
  SAY #8083
  IF ~~ THEN REPLY #8084 DO ~SetGlobal("50Hannu", "GLOBAL", 1)~ EXIT
END

IF WEIGHT #0 ~  NumberOfTimesTalkedTo(0)
CurrentAreaIs(Myself,5002)
~ THEN BEGIN 1
  SAY #8085
  IF ~~ THEN REPLY #8086 EXTERN ~50LIMHA~ 12
END

IF ~~ THEN BEGIN 2
  SAY #8087
  IF ~~ THEN GOTO 3
END

IF ~~ THEN BEGIN 3
  SAY #8090
  IF ~~ THEN REPLY #8093 EXTERN ~50LIMHA~ 13
END

IF ~~ THEN BEGIN 4
  SAY #8094
  IF ~~ THEN EXTERN ~50AGOG~ 6
END

IF ~~ THEN BEGIN 5
  SAY #8097
  IF ~~ THEN DO ~StartCutsceneMode()
StartCutScene("50cHann1")~ EXIT
END

IF WEIGHT #3 ~  True()
~ THEN BEGIN 6
  SAY #8098
  IF ~~ THEN REPLY #8084 EXIT
END

IF WEIGHT #1 ~  !CurrentAreaIs(Myself,5000)
~ THEN BEGIN 7
  SAY #8097
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 8
  SAY ~Wait!  Don't let her--ack!  Urk... *gurgle*...~
  IF ~~ THEN DO ~Kill(Myself)~ EXIT
END
