BEGIN ~USSTLPP~

IF WEIGHT #0 ~Global("Izbelah1_dead","GLOBAL",1)~ THEN BEGIN 5
  SAY ~It grieves my heart to see a valued friend turn on me so... I will turn my attention to the eruption. It may still be possible to save Dragon's Eye.~
  IF ~~ THEN GOTO 6
END

IF ~~ THEN BEGIN 6
  SAY ~I know not who you are, but I suggest you leave this place. The Legion will not look kindly upon this incident. The entrance to the Fields of Slaughter lies just below the entrance to Dragon's Eye.~
  IF ~~ THEN DO ~SetGlobal("US_Pyros_End_Talk","GLOBAL",1)~ EXIT
END

IF ~~ THEN BEGIN 0
  SAY ~Cool thy anger, my friend... Venomin, Izbelah, I assure you I would never suffer an eruption to consume Dragon's Eye. We shall do whatever we can to help thy people, but... thy spell gives us pause.~
  IF ~~ THEN EXTERN ~USSTLPL~ 1
END

IF ~~ THEN BEGIN 1
  SAY ~If there is even a single mistake, the result could be catastrophic... The spell could permanently stop time, or worse.~
  IF ~~ THEN EXTERN ~USSTLPI~ 2
END

IF ~~ THEN BEGIN 2
  SAY ~You know these people, High Sorceress?~
  IF ~~ THEN EXTERN ~USSTLPI~ 3
END

IF ~~ THEN BEGIN 3
  SAY ~I confess that I do not understand your question.~
  IF ~~ THEN EXTERN ~USSTLPI~ 4
END

IF ~~ THEN BEGIN 4
  SAY ~Izbelah! You wound me! I would never dare break our trust.~
  IF ~~ THEN EXTERN ~USSTLPI~ 5
END
