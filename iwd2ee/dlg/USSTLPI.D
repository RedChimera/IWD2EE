BEGIN ~USSTLPI~

IF WEIGHT #0 ~  NumTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY @6198
  IF ~~ THEN EXTERN ~USSTLPL~ 0
END

IF ~~ THEN BEGIN 1
  SAY @6204
  IF ~~ THEN EXTERN ~USSTLPP~ 1
END

IF ~~ THEN BEGIN 2
  SAY @6206
  IF ~~ THEN EXTERN ~USSTLPJ~ 1
END

IF ~~ THEN BEGIN 3
  SAY @6209
  IF ~~ THEN EXTERN ~USSTLPP~ 2
END

IF ~~ THEN BEGIN 4
  SAY @6211
  IF ~~ THEN JOURNAL #36025 EXTERN ~USSTLPP~ 3
END

IF ~~ THEN BEGIN 5
  SAY @6213
  IF ~~ THEN DO ~
Enemy()
~ JOURNAL #36025 EXIT
END
