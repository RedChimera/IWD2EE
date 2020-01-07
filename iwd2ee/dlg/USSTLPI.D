BEGIN ~USSTLPI~

IF WEIGHT #0 ~  NumTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY ~Evacuate? Where? Kuldahar is still in human hands! You would have us abandon our homes and allow centuries of labor to go up in flames just so we can die on some other battlefield?~
  IF ~~ THEN EXTERN ~USSTLPL~ 0
END

IF ~~ THEN BEGIN 1
  SAY ~We can't wait that long! All of Dragon's Eye is about to be engulfed in lava!~
  IF ~~ THEN EXTERN ~USSTLPP~ 1
END

IF ~~ THEN BEGIN 2
  SAY ~I don't care about the risks! The alternative is destruction!~
  IF ~~ THEN EXTERN ~USSTLPJ~ 1
END

IF ~~ THEN BEGIN 3
  SAY ~How did you get through Dragon's Eye? You... Wait. Are these your people, Lord Pyros?~
  IF ~~ THEN EXTERN ~USSTLPP~ 3
END

IF ~~ THEN BEGIN 4
  SAY ~You sent these mercenaries after me, didn't you? You've been working with the Legion's enemies! You're not worried about the spell--you WANTED the volcano to destroy Dragon's Eye!~
  IF ~~ THEN JOURNAL #36025 EXTERN ~USSTLPP~ 4
END

IF ~~ THEN BEGIN 5
  SAY ~Enough interruptions! Enough sabotage! Venomin, to my side!~
  IF ~~ THEN DO ~
Enemy()
~ EXIT
END
