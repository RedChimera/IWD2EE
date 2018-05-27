BEGIN ~USSTLPI~

IF ~~ THEN BEGIN 0
  SAY ~Abandon our ancestral home? Allow centuries of labor to go up in flames?~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPJ~ 1
END

IF ~~ THEN BEGIN 1
  SAY ~Lord Pyros, you said you have no wish to put my people in danger. Do you also have no wish to make us into refugees?~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPL~ 0
END

IF ~~ THEN BEGIN 2
  SAY ~We can't wait that long! All of Dragon's Eye is about to be engulfed in lava!~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPP~ 2
END

IF ~~ THEN BEGIN 3
  SAY ~I don't care about the risks! The alternative is destruction!~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPJ~ 3
END

IF ~~ THEN BEGIN 4
  SAY ~How did you get through Dragon's Eye? You... Wait. Are these your people, Lord Pyros?~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPP~ 4
END

IF ~~ THEN BEGIN 5
  SAY ~You sent these mercenaries after me, didn't you? You've been working with the Legion's enemies! You're not worried about the spell--you WANTED the volcano to destroy Dragon's Eye!~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPP~ 5
END

IF ~~ THEN BEGIN 6
  SAY ~Enough interruptions! Enough sabotage! Venomin, to my side!~
  IF ~~ THEN REPLY ~~ DO ~
Enemy()
~ EXIT
END