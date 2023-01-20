BEGIN ~USSERSP~

IF WEIGHT #0 ~!InParty(Myself)
GlobalLT("CHAPTER","GLOBAL",5)
Or(2)
  CurrentAreaIs(Myself,5201)
  CurrentAreaIs(Myself,5202)~ THEN BEGIN 0
  SAY @40228
  IF ~!NumInParty(6)~ THEN REPLY @40231 DO ~JoinParty()~ EXIT
  IF ~~ THEN REPLY @40232 EXIT
END

IF ~!InParty(Myself)
GlobalLT("CHAPTER","GLOBAL",5)~ THEN BEGIN 1
  SAY @40229
  IF ~!NumInParty(6)~ THEN REPLY @40231 DO ~JoinParty()~ EXIT
  IF ~~ THEN REPLY @40233 EXIT
  IF ~~ THEN REPLY @40234 DO ~EscapeArea()~ EXIT
END

IF ~!InParty(Myself)
GlobalGT("CHAPTER","GLOBAL",4)~ THEN BEGIN 2
  SAY @40230
  IF ~!NumInParty(6)~ THEN REPLY @40231 DO ~JoinParty()~ EXIT
  IF ~~ THEN REPLY @40233 EXIT
  IF ~~ THEN REPLY @40234 DO ~EscapeArea()~ EXIT
END