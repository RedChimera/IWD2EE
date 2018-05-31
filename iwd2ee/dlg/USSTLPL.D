BEGIN ~USSTLPL~

IF WEIGHT #0 ~  NumTimesTalkedTo(0)
~ THEN BEGIN 2
  SAY ~So much for Izbelah's ambitions--and our alliance with the Legion. Let's see if the volcano does destroy Dragon's Eye. I think I'll find a good place to watch.~
  IF ~~ EXIT
END

IF WEIGHT #0 ~  NumTimesTalkedToGT(0)
~ THEN BEGIN 3
  SAY ~Are you still here? Get out of my way!~
  IF ~~ EXIT
END

IF ~~ THEN BEGIN 0
  SAY ~Why is this OUR problem? It's not our fault they settled atop a volcano!~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPP~ 0
END

IF ~~ THEN BEGIN 1
  SAY ~How do we know this Temporal Stasis spell will even work?~
  IF ~~ THEN REPLY ~~ EXTERN ~USSTLPV~ 0
END
