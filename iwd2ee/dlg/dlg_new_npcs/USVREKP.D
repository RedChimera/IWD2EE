BEGIN ~USVREKP~

IF ~!InParty(Myself)
~ THEN BEGIN 0
  SAY @40206
  IF ~!NumInParty(6)~ THEN REPLY @40207 DO ~JoinParty()~ EXIT
  IF ~~ THEN REPLY @40208 DO ~ChangeEnemyAlly(Myself,ENEMY)~ EXIT
END
