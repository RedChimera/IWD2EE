/* Interjection Demonstration */

INTERJECT BODHI 5 SolaIJ1
== SOLA IF ~IsValidForPartyDialogue("Sola")~ THEN ~Sola says X.~
== BODHI IF ~IsValidForPartyDialogue("Sola")~ THEN ~Bodhi replies Y.~
END BODHI 5

// Has the same effect as:
/*
EXTEND_BOTTOM BODHI 5
  IF ~Global("SolaIJ1","GLOBAL",0)
      IsValidForPartyDialogue("Sola")~ THEN 
      DO ~SetGlobal("SolaIJ1","GLOBAL",1)~ EXTERN ~SOLA~ sola_chain
END

APPEND SOLA
  IF ~~ THEN BEGIN sola_chain_1
    SAY ~Sola says X.~
    IF ~~ THEN EXTERN BODHI 5
    IF ~IsValidForPartyDialogue("Sola")~ THEN EXTERN BODHI sola_chain_2
  END
END

APPEND BODHI
  IF ~~ THEN BEGIN sola_chain_2
    SAY ~Bodhi replies Y.~
    IF ~~ THEN EXTERN BODHI 5
  END
END
*/
