BEGIN ~USGEOFP~

IF ~!InParty(Myself)
GlobalLT("Palisade_Iron_Collar_Quest","GLOBAL",3)~ THEN BEGIN 0
  SAY @40192
  IF ~!NumInParty(6)~ THEN REPLY @40193 DO ~JoinParty()~ EXIT
  IF ~~ THEN REPLY @40194 DO ~SetGlobal("US_Geoffrey_Convinced_To_Join","GLOBAL",0)
EscapeArea()~ EXIT
END

IF ~!InParty(Myself)
GlobalGT("Palisade_Iron_Collar_Quest","GLOBAL",2)~ THEN BEGIN 1
  SAY @40195
  IF ~!NumInParty(6)~ THEN REPLY @40196 DO ~JoinParty()~ EXIT
  IF ~~ THEN REPLY @40197 EXIT
  IF ~~ THEN REPLY @40198 DO ~EscapeArea()~ EXIT
END
