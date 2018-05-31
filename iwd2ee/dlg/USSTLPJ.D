BEGIN ~USSTLPJ~

IF ~~ THEN BEGIN 0
  SAY ~We have not had time to review the spell ourselves. Our diviner will be here tomorrow and then-~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPI~ 1
END

IF ~~ THEN BEGIN 1
  SAY ~Izbelah, this... Oh. We seem to have visitors. Excuse me, who are you?~
  IF ~~ THEN REPLY ~We're here for the sorceress. We can't let you cast that spell, Izbelah.~ EXTERN ~USSTLPI~ 3
END
