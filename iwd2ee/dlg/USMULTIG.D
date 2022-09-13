BEGIN ~USMULTIG~

IF ~!InParty(Myself)
~ THEN BEGIN 1
  SAY ~Do you require my services once again?~
  IF ~!NumInParty(6)~ THEN REPLY ~Yes, please rejoin the party.~ DO ~JoinParty()~ EXIT
  IF ~~ THEN REPLY ~Not at this time.~ EXIT
END
