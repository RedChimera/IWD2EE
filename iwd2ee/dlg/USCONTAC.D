BEGIN ~USCONTAC~

IF WEIGHT #2 ~NumTimesTalkedTo(0)~ THEN BEGIN 0
  SAY ~State your question, summoner.~
  IF ~Global("CHAPTER","GLOBAL",0)
!Global("Phaen_Loses_It","GLOBAL",1)
GlobalLT("Expose_Phaen_Quest","GLOBAL",2)~ THEN REPLY ~How did the goblins get in the docks?~ GOTO PrologueA
  IF ~Global("CHAPTER","GLOBAL",2)
Or(3)
  PartyHasItem("41KEYCT")
  PartyHasItem("41KEYLT")
  PartyHasItem("41KEYOT")~ THEN REPLY ~Which locks do the high priestesses' temple keys unlock?~ GOTO Chapter2E
  IF ~Global("CHAPTER","GLOBAL",2)
Global("41NateFindSourceQuest","GLOBAL",3)
Global("41FakeAltarDestroyed","GLOBAL",0)
Global("CagedFury_dead","GLOBAL",0)~ THEN REPLY ~How do we destroy the altar to Auril in the Ice Temple?~ GOTO Chapter2F
  IF ~GlobalGT("41NickHelp","GLOBAL",1)
GlobalLT("41NickHelp","GLOBAL",5)~ THEN REPLY ~For what is Nickademus planning to call in our favor?~ GOTO Chapter2K
END
  IF ~Global("CHAPTER","GLOBAL",2)
Global("41PlayerSawPainting","GLOBAL",1)~ THEN REPLY ~What possible teleportation destinations are there via the painting in the Ice Temple, and which phrases are used to activate each one?~ GOTO Chapter2M
  IF ~Global("CHAPTER","GLOBAL",2)
Global("41PlayerSawGameRoom","GLOBAL",1)~ THEN REPLY ~What factors determine the power of the monsters one faces in the Battle Square?~ GOTO Chapter2N
END


IF ~~ THEN BEGIN PrologueA
  SAY ~A mage named Phaen teleported the goblins into the docks.~
  IF ~~ THEN DO ~SetGlobal("US_Divined_Phaen","GLOBAL",1)~ EXIT
END

IF ~~ THEN BEGIN Chapter2K
  SAY ~Nickademus plans to summon many demons and devils and then incapacitate them permanently via Imprisonment spells, preventing them from corrupting any more souls. He will summon you in case the fiends break loose of his control before he can imprison them.~
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN Chapter2M
  SAY ~"Death to Kuldahar and all who defy the will of the Cold Goddess!"
- Teleports you to the normal bottom of these stairs.

"Andora?"
- Teleports you to Andora.

"Lysan."
- Teleports you to the altar on the bottom floor.

"Auril, shower me with strength!"
- Teleports you to the Battle Square.

"Bedroom."
- Teleports you into the bedroom of the mage Nickademus.~
  IF ~~ THEN DO ~SetGlobal("41SaidPainting1","GLOBAL",1)
SetGlobal("40OdeaExplainedAndora","GLOBAL",1)
SetGlobal("41SaidPainting2","GLOBAL",1)
SetGlobal("41SaidPainting3","GLOBAL",1)
SetGlobal("41SaidPainting5","GLOBAL",1)~ GOTO Chapter2M2
END

IF ~~ THEN BEGIN Chapter2M2
  SAY ~"From the Sea of Moving Ice to the High Forest, from the highest peak in the Spine of the World Mountains, to the deepest, most volcanic bowels of the earth, the Legion of the Chimera will purge this land of those enemies who sought to deny the sovereignty of our nation!"
- Teleports you to a cave that houses white abishai.

"In Auril's name, from winter's veil, my claw tears through the frozen air...  Neither your might, nor earthly means, will save you from your death's despair."
- Teleports you into the temple's main treasury.~
  IF ~~ THEN DO ~SetGlobal("41PaintingPhrase6","GLOBAL",1)
SetGlobal("41SaidPainting4","GLOBAL",1)~ GOTO Chapter2M3
END

IF ~~ THEN BEGIN Chapter2M3
  SAY ~Saying any other phrase causes the stairs to teleport you to a random location.~
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN Chapter2N
  SAY ~The primary determinant of the monsters' power is the rank you selected. However, there are two other factors that influence it as well. The first is your level of experience. If you are extremely powerful, the monsters you face will be somewhat stronger for the same rank.~
  IF ~~ THEN GOTO Chapter2N2
END

IF ~~ THEN BEGIN Chapter2N2
  SAY ~The other factor is the square you select. Choosing one of the edge squares pits you against weaker monsters. Picking a corner square makes you fight stronger monsters. The center square generates the strongest monsters.~
  IF ~~ THEN EXIT
END