BEGIN ~51HARSHO~

IF ~  True()
~ THEN BEGIN 0
  SAY #9333 //You arrive at last,  <CHARNAME>.  Allow me to introduce myself... I am Harshom.
  IF ~~ THEN JOURNAL #9327 GOTO 1
END

IF ~~ THEN BEGIN 1
  SAY #9510 //I've come a long way from Luskan to kill you - you should be honored.  Not many attract the attention of the Hosttower, and fewer still merit the dispatch of a mage of my caliber to obliterate them.
  IF ~~ THEN REPLY #9511 GOTO 2 //How do you know my name?
  IF ~Global("USKYOSTI_HARSHOM", "Global", 1)~ THEN REPLY #9512 JOURNAL #9328 GOTO 4 //"How did you find me?" I have added a variable referring to the Leevi and Carita quest to prevent the player from asking a question whose answer would only make sense if the Leevi and Carita questline was complete. The variable is set in Kurttu's dialogue, 50KURTTU.dlg.
  IF ~  Gender(Protagonist,MALE)
~ THEN REPLY #9513 GOTO 10 //The Hosttower?
  IF ~  !Gender(Protagonist,MALE)
~ THEN REPLY #9513 GOTO 11 //The Hosttower?
  IF ~CheckSkillGT(Protagonist, 20, Spellcraft)
!Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~CheckSkillGT(Protagonist, 10, Spellcraft)
Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~~ THEN REPLY #9514 DO ~Enemy()~ EXIT //Enough boasting, Harshom - it's time to fight.
END

IF ~~ THEN BEGIN 2
  SAY #9515 //Why, I was given your name and description when I was sent to slay you.  Poor little Phaen should have finished off you meddling upstarts in Targos, but alas - such is the result of the Hosttower's sending a boy to do a man's job.
  IF ~  GlobalGT("Know_Phaen","GLOBAL",0)
~ THEN REPLY #9516 JOURNAL #9329 GOTO 3 //You knew Phaen?
  IF ~Global("USKYOSTI_HARSHOM", "Global", 1)~ THEN REPLY #9512 JOURNAL #9328 GOTO 4
  IF ~  Gender(Protagonist,MALE)
~ THEN REPLY #9513 GOTO 10
  IF ~  !Gender(Protagonist,MALE)
~ THEN REPLY #9513 GOTO 11
  IF ~ClassEx(Protagonist,MAGE)
CheckSkillGT(Protagonist, 20, Spellcraft)
!Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~ClassEx(Protagonist,MAGE)
CheckSkillGT(Protagonist, 10, Spellcraft)
Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~~ THEN REPLY #9514 DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 3
  SAY #9517 //Yes, indeed - a silly, ragged fellow who made a better servant than apprentice.  You seem to have grown in power since little Phaen's final report from Targos, but no matter - you're clearly no threat to me.
  IF ~Global("USKYOSTI_HARSHOM", "Global", 1)~ THEN REPLY #9512 JOURNAL #9328 GOTO 4
  IF ~  Gender(Protagonist,MALE)
~ THEN REPLY #9518 GOTO 10 //What's the Hosttower?
  IF ~  !Gender(Protagonist,MALE)
~ THEN REPLY #9518 GOTO 11 //What's the Hosttower?
  IF ~ClassEx(Protagonist,MAGE)
CheckSkillGT(Protagonist, 20, Spellcraft)
!Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~ClassEx(Protagonist,MAGE)
CheckSkillGT(Protagonist, 10, Spellcraft)
Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~~ THEN REPLY #9514 DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 4
  SAY #9519 //Oh-ho-ho, too easily!
  IF ~~ THEN GOTO 5
END

IF ~~ THEN BEGIN 5
  SAY #9520 //Normally, my huntsmen would have taken weeks to find you in this miserable mountain wilderness, but they had the fortune of encountering some enemies of yours.  You seem to collect them in droves, you know...
  IF ~~ THEN REPLY #9521 GOTO 6 //Go on...
  IF ~ClassEx(Protagonist,MAGE)
CheckSkillGT(Protagonist, 20, Spellcraft)
!Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~ClassEx(Protagonist,MAGE)
CheckSkillGT(Protagonist, 10, Spellcraft)
Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~~ THEN REPLY #9514 DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 6
  SAY #9522 //In any case, t'was a couple - Leevi, I believe, was the man's name, and Carita the woman's.  Poor wretches... I fed them to my war-bears for their trouble.
  IF ~~ THEN REPLY #9523 GOTO 7 //War-bears?!
  IF ~~ THEN REPLY #9511 GOTO 2
  IF ~  Gender(Protagonist,MALE)
~ THEN REPLY #9518 GOTO 10
  IF ~  !Gender(Protagonist,MALE)
~ THEN REPLY #9518 GOTO 11
  IF ~ClassEx(Protagonist,MAGE)
CheckSkillGT(Protagonist, 20, Spellcraft)
!Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~ClassEx(Protagonist,MAGE)
CheckSkillGT(Protagonist, 10, Spellcraft)
Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~~ THEN REPLY #9514 DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 7
  SAY #9524 //Ha, ha, ha!  Yes... they do not call me The Beastlord Harshom for my prowess with women alone, you know...
  IF ~~ THEN GOTO 8
END

IF ~~ THEN BEGIN 8
  SAY #9525 //My pets can dispatch armored knights with ease, and bear collars that bind them to me alone... waste not your common charms on them, should you know such petty magic.
  IF ~~ THEN REPLY #9526 GOTO 9 //Yes, but... "war-bears?"
  IF ~~ THEN REPLY #9527 GOTO 12 //They "bear" collars?
  IF ~~ THEN REPLY #9511 GOTO 2
  IF ~  Gender(Protagonist,MALE)
~ THEN REPLY #9518 GOTO 10
  IF ~  !Gender(Protagonist,MALE)
~ THEN REPLY #9518 GOTO 11
  IF ~ClassEx(Protagonist,MAGE)
CheckSkillGT(Protagonist, 20, Spellcraft)
!Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~ClassEx(Protagonist,MAGE)
CheckSkillGT(Protagonist, 10, Spellcraft)
Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~~ THEN REPLY #9514 DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 9
  SAY #9528 //Yes, well... t'was either that or "battle-cats."  The bears seemed somewhat more menacing.   But enough of your pathetic attempts at mockery, you scruffy plebeians.
  IF ~~ THEN REPLY #9529 GOTO 12 //And... they "bear" collars?
  IF ~~ THEN REPLY #9511 GOTO 2
  IF ~  Gender(Protagonist,MALE)
~ THEN REPLY #9518 GOTO 10
  IF ~  !Gender(Protagonist,MALE)
~ THEN REPLY #9518 GOTO 11
  IF ~ClassEx(Protagonist,MAGE)
CheckSkillGT(Protagonist, 20, Spellcraft)
!Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~ClassEx(Protagonist,MAGE)
CheckSkillGT(Protagonist, 10, Spellcraft)
Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~~ THEN REPLY #9514 DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 10
  SAY #9530 //Why, and here I'd thought you a Luskanite.  Surely you must know of the Hosttower of the Arcane Brotherhood, boy - that body of mages and merchants who *owns* the City of Luskan?  Well, 'tis of no consequence.
  IF ~~ THEN REPLY #9511 GOTO 2
  IF ~Global("USKYOSTI_HARSHOM", "Global", 1)~ THEN REPLY #9512 JOURNAL #9328 GOTO 4
  IF ~ClassEx(Protagonist,MAGE)
CheckSkillGT(Protagonist, 20, Spellcraft)
!Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~ClassEx(Protagonist,MAGE)
CheckSkillGT(Protagonist, 10, Spellcraft)
Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~~ THEN REPLY #9514 DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 11
  SAY #9531 //Why, and here I'd thought you a Luskanite.  Surely you must know of the Hosttower of the Arcane Brotherhood, girl - that body of mages and merchants who *owns* the City of Luskan?  Well, 'tis of no consequence.
  IF ~~ THEN REPLY #9511 GOTO 2
  IF ~Global("USKYOSTI_HARSHOM", "Global", 1)~ THEN REPLY #9512 JOURNAL #9328 GOTO 4
  IF ~ClassEx(Protagonist,MAGE)
CheckSkillGT(Protagonist, 20, Spellcraft)
!Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~ClassEx(Protagonist,MAGE)
CheckSkillGT(Protagonist, 10, Spellcraft)
Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~~ THEN REPLY #9514 DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 12
  SAY #9992 //What do you-?  Ah.  I assure you, the pun was unintentional.  And mark my words, filth - my beasts are no laughing matter.
  IF ~~ THEN REPLY #9526 GOTO 9
  IF ~~ THEN REPLY #9511 GOTO 2
  IF ~  Gender(Protagonist,MALE)
~ THEN REPLY #9518 GOTO 10
  IF ~  !Gender(Protagonist,MALE)
~ THEN REPLY #9518 GOTO 11
  IF ~ClassEx(Protagonist,MAGE)
CheckSkillGT(Protagonist, 20, Spellcraft)
!Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~ClassEx(Protagonist,MAGE)
CheckSkillGT(Protagonist, 10, Spellcraft)
Kit(Protagonist, Mage_Illusionist)~ THEN REPLY ~(Begin crafting glamer to make Harshom and his allies appear to be umber hulks)~ GOTO TrickHarshom // attempt to trick Harshom
  IF ~~ THEN REPLY #9514 DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN TrickHarshom
  SAY ~Wait... what was that? Gah! I thought we were done with these creatures! Everyone, focus! Don't be deceived!~
  IF ~CheckSkillGT(Protagonist, 5, Bluff)~ THEN REPLY ~(Distort the voices of Harshom's allies) Harshom! Harshom, which one is which? I can't tell the hulks from the bears!~ GOTO TrickHarshom2
  IF ~CheckSkillLT(Protagonist, 5, Bluff)~ THEN REPLY ~(Distort the voices of Harshom's allies) The umber hulks are attacking us again! They're right behind us!~ GOTO TrickHarshomFailed
END

IF ~~ THEN BEGIN TrickHarshomFailed
  SAY ~Spread out! Make sure... Wait. No, this is just an illusion! Everyone, there are no umber hulks! The enemy is right in front of us! Find the illusionist and kill them!~
  IF ~~ THEN REPLY ~~ DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN TrickHarshom2
  SAY ~By the hells, spread out! Don't look into their eyes! Focus on the--wait, where is everyone? Where are you?~
  IF ~~ THEN REPLY ~Help! Help me!~ DO ~Enemy()~ EXIT  // The DO section here needs to impose a confusion effect on Harshom and ideally also his allies.
  IF ~CheckSkillGT(Protagonist, 9, Bluff)~ THEN REPLY ~Open the door! Open the door! We need to get out of the tunnels!~ DO ~Enemy()~ EXIT  // The DO section here needs to impose a confusion effect on Harshom and ideally also his allies. This one also needs to open the door behind Harshom.
END
