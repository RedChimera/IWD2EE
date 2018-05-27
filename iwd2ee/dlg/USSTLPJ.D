BEGIN ~USSTLPJ~

IF ~~ THEN BEGIN 0
  SAY ~Perhaps we could organize an evacuation of sorts. We could-~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPI~ 0
END

IF ~~ THEN BEGIN 1
  SAY ~Not everything would be lost. There is still time for everyone to move their belongings. All of your research would remain intact. And there is room in Kuldahar.~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPI~ 1
END

IF ~~ THEN BEGIN 2
  SAY ~We have not had time to review the spell ourselves. Our diviner will be here tomorrow and then-~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPI~ 2
END

IF ~~ THEN BEGIN 3
  SAY ~Izbelah, this... Oh. We seem to have visitors. Excuse me, who are you?~
  IF ~~ THEN REPLY ~We're here for the sorceress. We can't let you cast that spell, Izbelah.~ EXTERN ~USSTLPP~ 3
END
