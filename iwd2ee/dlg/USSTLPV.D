BEGIN ~USSTLPV~

IF WEIGHT #0 ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY ~I'm afraid we are out of options. We simply have no other means of preventing the eruption. A Temporal Stasis spell is the only way to contain the process.~
  IF ~~ THEN EXTERN ~USSTLPP~ 0
END

IF ~~ THEN BEGIN 1
  SAY ~I have no reason to doubt you, my Lord.~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPJ~ 0
END

IF ~~ THEN BEGIN 2
  SAY ~Izbelah's research has been reviewed very carefully. It will work as intended.~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPJ~ 2
END
