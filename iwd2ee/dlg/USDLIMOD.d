APPEND ~60CONLA2~
IF ~~ THEN BEGIN USConlanGuardianScales1
  SAY @19913
  IF ~PartyGoldGT(4999)~ THEN REPLY @19914 DO ~TakePartyGold(5000)
TakePartyItem("USGENGUA")
DestroyItem("USGENGUA")
FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)
GiveItemCreate("USRTHF15",Protagonist,1,1,1)~ GOTO USConlanGuardianScales2
  IF ~~ THEN REPLY @19915 EXIT
END
END

APPEND ~60CONLA2~
IF ~~ THEN BEGIN USConlanGuardianScales2
  SAY @19916
  IF ~~ THEN REPLY #28980 DO ~StartStore("60Sheemi",Protagonist)~ EXIT
  IF ~~ THEN REPLY #444 EXIT
END
END

EXTEND_TOP ~60CONLA2~ 20 IF ~PartyHasItem("USGENGUA")~ THEN REPLY @19912 DO ~~ GOTO USConlanGuardianScales1 END
EXTEND_TOP ~60CONLA2~ 31 IF ~PartyHasItem("USGENGUA")~ THEN REPLY @19912 DO ~~ GOTO USConlanGuardianScales1 END
