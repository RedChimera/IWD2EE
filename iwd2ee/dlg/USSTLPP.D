BEGIN ~USSTLPP~

IF ~~ THEN BEGIN 0
  SAY ~I assure you, I would never suffer the volcano to erupt beneath Dragon's Eye. I have no wish to put thy people in danger.~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPV~ 1
END

IF ~~ THEN BEGIN 1
  SAY ~Cool thy anger, my friend... We do not wish to see our allies lose their homes, either, High Sorceress. We shall do whatever we can, but thy spell gives us pause.~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPL~ 1
END

IF ~~ THEN BEGIN 2
  SAY ~If there is even a single mistake, the result could be catastrophic... The spell could permanently stop time, or worse.~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPI~ 3
END

IF ~~ THEN BEGIN 3
  SAY ~You know these people, High Sorceress?~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPI~ 4
END

IF ~~ THEN BEGIN 4
  SAY ~I confess that I do not understand your question.~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPI~ 5
END

IF ~~ THEN BEGIN 5
  SAY ~Izbelah! You wound me! I would never dare break our trust.~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPI~ 6
END