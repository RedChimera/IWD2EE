BEGIN ~USCONTAC~

IF WEIGHT #2 ~NumTimesTalkedTo(0)~ THEN BEGIN 0
  SAY ~State your question, summoner.~
  IF ~Global("CHAPTER","GLOBAL",0)
!Global("Phaen_Loses_It","GLOBAL",1)
GlobalLT("Expose_Phaen_Quest","GLOBAL",2)~ THEN REPLY ~How did the goblins get in the docks?~ GOTO Prologue1
END

IF ~~ THEN BEGIN Prologue1
  SAY ~A mage named Phaen teleported the goblins into the docks.~
  IF ~~ THEN EXIT
END