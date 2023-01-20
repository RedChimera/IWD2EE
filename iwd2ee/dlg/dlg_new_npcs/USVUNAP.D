BEGIN ~USVUNAP~

IF ~!InParty(Myself)
GlobalLT("CHAPTER","GLOBAL",2)~ THEN BEGIN 0
  SAY @40209
  IF ~!NumInParty(6)~ THEN REPLY @40210 DO ~JoinParty()~ EXIT
  IF ~~ THEN REPLY @40211 DO ~DestroySelf()~ EXIT
  IF ~~ THEN REPLY @40212 DO ~DestroySelf()~ EXIT
  IF ~~ THEN REPLY @40213 DO ~Enemy()~ EXIT
END

IF ~!InParty(Myself)
GlobalGT("CHAPTER","GLOBAL",1)~ THEN BEGIN 1
  SAY @40214
  IF ~!NumInParty(6)~ THEN REPLY @40215 DO ~JoinParty()~ EXIT
  IF ~~ THEN REPLY @40216 DO ~Enemy()~ EXIT
END
