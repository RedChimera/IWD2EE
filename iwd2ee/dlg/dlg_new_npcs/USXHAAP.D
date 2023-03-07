BEGIN ~USXHAAP~

IF ~!InParty(Myself)
~ THEN BEGIN 0
  SAY @40217
  IF ~!NumInParty(6)~ THEN REPLY @40218 DO ~JoinParty()~ EXIT
  IF ~~ THEN REPLY @40108 DO ~SetGlobal("US_Xhaan_Leave_Party_Forever","LOCALS",1)~ EXIT
  IF ~~ THEN REPLY @40219 DO ~SetGlobal("US_Xhaan_Leave_Party_Forever","LOCALS",1)~ EXIT
  IF ~~ THEN REPLY @40220 DO ~ChangeEnemyAlly(Myself,ENEMY)~ EXIT
END
