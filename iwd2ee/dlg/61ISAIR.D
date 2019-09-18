BEGIN ~61ISAIR~

IF WEIGHT #0 ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY #29432
  IF ~~ THEN EXTERN ~60MADAE~ 0
END

IF ~~ THEN BEGIN 1
  SAY #29434
  IF ~~ THEN REPLY #29435 GOTO 2
  IF ~~ THEN REPLY #29436 GOTO 3
  IF ~~ THEN REPLY #29437 GOTO 3
  IF ~~ THEN REPLY #29438 EXTERN ~60MADAE~ 1
  IF ~~ THEN REPLY #29439 EXTERN ~60MADAE~ 2
  IF ~  ClassEx(Protagonist,FIGHTER)
~ THEN REPLY #29440 GOTO 4
  IF ~  ClassEx(Protagonist,BARBARIAN)
~ THEN REPLY #29440 GOTO 4
  IF ~  ClassEx(Protagonist,DRUID)
~ THEN REPLY #29441 EXTERN ~60MADAE~ 2
  IF ~  ClassEx(Protagonist,RANGER)
~ THEN REPLY #29441 EXTERN ~60MADAE~ 2
  IF ~  ClassEx(Protagonist,PALADIN)
~ THEN REPLY #29442 EXTERN ~60MADAE~ 3
  IF ~  ClassEx(Protagonist,CLERIC)
Alignment(Protagonist,MASK_GOOD)
~ THEN REPLY #29443 EXTERN ~60MADAE~ 3
  IF ~  ClassEx(Protagonist,THIEF)
~ THEN REPLY #29444 GOTO 5
  IF ~  ClassEx(Protagonist,BARD)
~ THEN REPLY #29445 GOTO 6
  IF ~  ClassEx(Protagonist,MAGE)
~ THEN REPLY #29446 GOTO 7
  IF ~  Kit(Protagonist,CLERIC_SELUNE)
~ THEN REPLY #29447 EXTERN ~60MADAE~ 4
  IF ~  Kit(Protagonist,CLERIC_TEMPUS)
~ THEN REPLY #29448 GOTO 8
  IF ~  Kit(Protagonist,CLERIC_BANE)
~ THEN REPLY #29449 EXTERN ~60MADAE~ 5
  IF ~  ClassEx(Protagonist,MONK)
~ THEN REPLY #29451 EXTERN ~60MADAE~ 6
  IF ~~ THEN REPLY #29453 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()
~ EXIT
END

IF ~~ THEN BEGIN 2
  SAY #29454
  IF ~~ THEN REPLY #29455 EXTERN ~60MADAE~ 7
  IF ~~ THEN REPLY #29456 EXTERN ~60MADAE~ 8
  IF ~~ THEN REPLY #29457 GOTO 10
  IF ~~ THEN REPLY #29458 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 17
END

IF ~~ THEN BEGIN 3
  SAY #29459
  IF ~~ THEN REPLY #29460 EXTERN ~60MADAE~ 7
  IF ~~ THEN REPLY #29461 EXTERN ~60MADAE~ 7
  IF ~~ THEN REPLY #29462 EXTERN ~60MADAE~ 10
  IF ~~ THEN REPLY #29458 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 17
END

IF ~~ THEN BEGIN 4
  SAY #29463
  IF ~~ THEN REPLY #29455 EXTERN ~60MADAE~ 7
  IF ~~ THEN REPLY #29456 EXTERN ~60MADAE~ 8
  IF ~~ THEN REPLY #29457 GOTO 10
  IF ~~ THEN REPLY #29458 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 17
END

IF ~~ THEN BEGIN 5
  SAY #29464
  IF ~~ THEN REPLY #29455 EXTERN ~60MADAE~ 7
  IF ~~ THEN REPLY #29456 EXTERN ~60MADAE~ 8
  IF ~~ THEN REPLY #29457 GOTO 10
  IF ~~ THEN REPLY #29458 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 17
END

IF ~~ THEN BEGIN 6
  SAY #29465
  IF ~~ THEN REPLY #29466 EXTERN ~60MADAE~ 8
  IF ~~ THEN REPLY #29467 EXTERN ~60MADAE~ 9
  IF ~~ THEN REPLY #29468 EXTERN ~60MADAE~ 10
  IF ~~ THEN REPLY #29458 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 17
END

IF ~~ THEN BEGIN 7
  SAY #29469
  IF ~~ THEN REPLY #29470 GOTO 11
  IF ~~ THEN REPLY ~I have.  The whole process has actually been quite fascinating.  It was quite satisfying to tear it apart.~ + MageIntimidateStart
  IF ~~ THEN REPLY #29471 GOTO 11
  IF ~~ THEN REPLY #29458 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 17
END

IF ~~ THEN BEGIN 8
  SAY #29472
  IF ~~ THEN REPLY #29473 EXTERN ~60MADAE~ 11
  IF ~~ THEN REPLY #29474 EXTERN ~60MADAE~ 8
  IF ~~ THEN REPLY #29475 GOTO 11
  IF ~~ THEN REPLY #29458 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 17
END

IF ~~ THEN BEGIN 9
  SAY #29476
  IF ~~ THEN REPLY #29477 GOTO 11
  IF ~~ THEN REPLY #29478 GOTO 11
  IF ~~ THEN REPLY #29458 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 17
END

IF ~~ THEN BEGIN 10
  SAY #29479
  IF ~~ THEN REPLY #29480 GOTO 15
  IF ~~ THEN REPLY #29481 GOTO 16
  IF ~  SubRace(Protagonist,HUMAN_AASIMAR)
~ THEN REPLY #29482 GOTO 16
  IF ~  SubRace(Protagonist,HUMAN_TIEFLING)
~ THEN REPLY #29482 GOTO 16
  IF ~~ THEN REPLY #29458 DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 17
END

IF ~~ THEN BEGIN 11
  SAY #29483
  IF ~~ THEN EXTERN ~60MADAE~ 14
END

IF ~~ THEN BEGIN 12
  SAY #29484
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN 13
  SAY #29485
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN 14
  SAY #29486
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN 15
  SAY #29487
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN 16
  SAY #29488
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN 17
  SAY #29489
  IF ~~ THEN EXTERN ~60MADAE~ 15
END

IF ~~ THEN BEGIN 18
  SAY #29490
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN 19
  SAY #29491
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF WEIGHT #6 ~  NumTimesTalkedToGT(0)
GlobalLT("Final_Battle_Progress","GLOBAL",1)
~ THEN BEGIN 20
  SAY #29492
  IF ~~ THEN DO ~SetGlobal("Final_Battle_Progress","GLOBAL",1)~ EXTERN ~60MADAE~ 18
END

IF WEIGHT #5 ~  NumTimesTalkedToGT(0)
Global("Final_Battle_Progress","GLOBAL",1)
!Global("Pool_Tainted","GLOBAL",1)
~ THEN BEGIN 21
  SAY #29493
  IF ~~ THEN DO ~SetGlobal("Final_Battle_Progress","GLOBAL",2)~ EXTERN ~60MADAE~ 19
END

IF ~~ THEN BEGIN 22
  SAY #29494
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF WEIGHT #4 ~  NumTimesTalkedToGT(0)
Global("Final_Battle_Progress","GLOBAL",1)
Global("Pool_Tainted","GLOBAL",1)
~ THEN BEGIN 23
  SAY #29495
  IF ~~ THEN DO ~SetGlobal("Final_Battle_Progress","GLOBAL",2)~ EXTERN ~60MADAE~ 20
END

IF ~~ THEN BEGIN 24
  SAY #29496
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF WEIGHT #3 ~  NumTimesTalkedToGT(0)
Global("Final_Battle_Progress","GLOBAL",2)
~ THEN BEGIN 25
  SAY #29497
  IF ~~ THEN DO ~SetGlobal("Final_Battle_Progress","GLOBAL",3)~ EXTERN ~60MADAE~ 21
END

IF WEIGHT #2 ~  NumTimesTalkedToGT(0)
Global("Final_Battle_Progress","GLOBAL",3)
~ THEN BEGIN 26
  SAY #29498
  IF ~~ THEN EXTERN ~64ORRICK~ 68
END

IF ~~ THEN BEGIN 27
  SAY #29499
  IF ~~ THEN EXTERN ~60MADAE~ 23
END

IF WEIGHT #1 ~  NumTimesTalkedToGT(0)
Global("Ready_To_Retreat","GLOBAL",0)
~ THEN BEGIN 28
  SAY #32053
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN MageIntimidateStart
SAY ~A mythal is not something you tear apart.  It's considerably more resilient than that.  What exactly have you been up to?~
+ ~CheckSkillGT(Protagonist,23,Knowledge_Arcana)~ + ~Many things.  Some of the enchantments on the surrounding structures are quite brilliant--I assume that's the work of the Researcher faction of Thay--but they suffer from a weak legacy.  All of the component parts of the more brilliant structures are built upon a set of very outdated and poorly constructed dweomers.  I would venture that the project began long before you attracted any truly talented mages?~ + SuccessfulMageIntimidate1
+ ~~ + ~Many things.  With a system this large, there are all kinds of vulnerabilities to exploit.  All I had to do was find a loose thread and pull it until it came apart.~ + FailedMageIntimidate
END

IF ~~ THEN BEGIN SuccessfulMageIntimidate1
SAY ~As a matter of fact, the work began before we reached an agreement with Thay.  But don't assume the project was done without considering the particulars--we are familiar with the underlying structures.  The Red Wizards made a point of reinforcing and correcting for the old dweomers.  I myself helped craft some of the over-architecture and provide some of the processing loops for the energy channels.  Cedrin Zil and Orrick even expanded the output centers to collect more information about the original mythal's channeling process.~
+ ~CheckSkillGT(Protagonist,12,Bluff)~ + ~You should have rebuilt it from scratch when the Red Wizards got involved.  I counted seven fatal errors just from a localized review on the second floor.  Four of them wouldn't show for years, and one of them would induce a sluggish but exponential decay over the course of several weeks, but two of them were so unstable I could break them just by reorganizing the fields and exposing some wires to a few low-intensity sonic vibrations.~ + SuccessfulMageIntimidate2
+ ~~ + ~I sabotaged the processing loops to destabilize the flow of energy.  You left some key vulnerabilities in them.  I even re-rigged the output centers so you wouldn't be able to figure out what was going on.~ + FailedMageIntimidate
END

IF ~~ THEN BEGIN SuccessfulMageIntimidate2
SAY ~And why should I believe that some bookish mercenary from Luskan was able to find a flaw in a system that over a dozen of Thay's top researchers have been working on for months?~
+ ~CheckSkillGT(Protagonist,11,Intimidate)~ + ~Because, Isair, being the idiot you are, you attempted to manipulate the currents on your own and then foolishly *overwrote* your changes, erasing precious information that Thay *needed* to understand the architecture.  You thought that because your cambion blood gave you magical power, you could *understand* the magic involved, but you failed to do the proper research beforehand--and then erased your own edits without documenting them.  I made the same mistake in an experiment years ago.  And once I considered the possibility that you overestimated your own abilities, it only took a few hours to find proof of your over-writes.~ + SuccessfulMageIntimidate3
+ ~~ + ~Sometimes an outsider has the best perspective.  You all have been working on this project so long that you couldn't see it with fresh eyes.  I was new to the mythal--I could see what you couldn't.~ + FailedMageIntimidate
END

IF ~~ THEN BEGIN SuccessfulMageIntimidate3
SAY ~I... I am not some uneducated sorcerer who works magic without research!  I have poured as many years into my sorcerery as any wizard.~
+ ~~ + ~Perhaps you did.  But I only needed you to make that mistake *once* for me to capitalize on it.  Now that I've disrupted the underlying architecture, the misfeeds are going to disintegrate the mythal in a rapid death spiral.  And, since you've foolishly tied your own essence into the mythal, it's going to absorb you the moment it begins to fail.  You only have a few hours left before the whole tower falls.  Or rather--(snaps fingers)--a couple minutes.~ + MythalTriggerMageIntimidate
END

IF ~~ THEN BEGIN FailedMageIntimidate
SAY ~You're telling me that you sabotaged an entire mythal all on your own?  Without being detected?~
+ ~~ + ~Why, are you impressed?~ + FailedMageIntimidateFight
+ ~~ + ~You'd be surprised at the kinds of things I can do.~ + FailedMageIntimidateFight
END

IF ~~ THEN BEGIN NoArmyIntimidateI
SAY ~Years of labor went into this Legion.  We have expanded our alliances, our connections, and our coffers far beyond the Ten Towns.  We started from nothing, but today we are the greatest force in the region.  We have already accomplished all of those things.  As for enslavement... well, slaves already rebuilt the Severed Hand, didn't they?~
+ ~CheckSkillGT(Protagonist,15,Bluff)~ + ~You overestimate the strength of your connections.  Guthma despised Sherincal and the Legion--until we came along, he planned on destroying the Legion once he was done with Targos.  None of your allies has any real allegiance to the Legion or its goals.  Your *allies* are nothing more than opportunists taking advantage of the chaos you generate.  The moment they feel their interests are threatened, they will abandon the Legion without a second thought.~ + SuccessfulNoArmyIntimidate1
+ ~~ + ~How long do you think that's going to last, Isair?  We have all of the Ten Towns on our side.  Your friends aren't going to stick around when things get rough.~ + FailedNoArmyIntimidate
END

IF ~~ THEN BEGIN FailedNoArmyIntimidate
SAY ~Rough?  You have no idea what Madae and I have already been through, mercenary.  We have fought everywhere from the streets of Luskan to the Abyss and the Nine Hells.~
+ ~~ + ~It's not just you and Madae, Isair.  I speak of the weakness of the Legion itself.~ + FailedNoArmyIntimidateFight
END

IF ~~ THEN BEGIN SuccessfulNoArmyIntimidate1
SAY ~You mercenaries have been trudging through the wilderness for weeks--Your grasp of current events is weak, to say the least.  We've already established new contacts and new projects with everyone from Thay to the Cabal of Dragonkin to Iyachtu Xvim himself.  The Severed Hand itself is the result of numerous organizations working in concert.  Would "opportunists" have dedicated their own resources to the Legion's success?~
+ ~CheckSkillGT(Protagonist,17,Intimidate)~ + ~Why would opportunists tell you any different?  It's in their best interests to tell you they're on your side.  But look at it from their point of view--the goblin horde is broken.  The Aurilites are broken.  The driders are broken.  Dragon's Eye is broken.  Even the Severed Hand is breaking apart.  Your allies keep ending up getting destroyed... and the survivors have noticed.  We've been waltzing around the Severed Hand because none of your allies care enough about your security to properly monitor the halls.  Why would they stick out their necks for your sake?  You *want* to believe that everyone is on your side, but the truth is, no one in this world really cares about the freaks and half-breeds of this world--not even the *other* freaks and half-breeds.~ + SuccessfulNoArmyIntimidate2
+ ~~ + ~It's not enough.  The Ten Towns have allies to the south.  When the other nations get involved, the Legion of the Chimera is doomed.~ + FailedNoArmyIntimidate
END

IF ~~ THEN BEGIN SuccessfulNoArmyIntimidate2
SAY ~You mercenaries have no understanding of the trials we've gone through!  You have no idea what we've overcome!  You have no concept of the passion, the frustration--no, the FURY of the rejects of your "civilization!"  Entire nations of people are crying out for a world of their own, a home of their own!  We ARE that home!  We ARE that nation!  The Legion of the Chimera is not just a band of half-breeds running scared from humankind--we are a DREAM!  A dream of safety, of sovereignty, of *freedom* for the people your kind has oppressed for centuries!~
+ ~CheckSkillGT(Protagonist,21,Intimidate)~ + ~Passion and emotion don't win wars, Isair.  Wars are won by muscle and power.  Your "dream" is just a concept; armies are the reality.  A few petty mercenaries was enough to turn your forces against each other and ruin their efforts, and we are just a fraction of the army you think you can destroy.  Even after all your efforts, the Ten Towns remain standing, and even if you subdued them, the southern nations would come together and crush you before you can spread any further.~ + SuccessfulNoArmyIntimidate3
+ ~~ + ~A dream isn't good enough, Isair.  You'll need a lot more than big ideas to win a war.~ + FailedNoArmyIntimidate
END

IF ~~ THEN BEGIN SuccessfulNoArmyIntimidate3
SAY ~Is that your view of justice, mercenary?  Might makes right, the strong rule the weak?  We do not ACCEPT that "justice!"  We do not accept the oppression of the majority!  We have a new goal, a new order, a new world to right the wrongs of the past!  You are but the guardian of an unjust order--you do not even *attempt* to justify the actions of your kind!~
+ ~~ + ~I do not have to, Isair.  Your empire is already collapsing.  The Legion was built on your own personal dreams, and everyone else has just been eating at your table until they get their fill.  You can scream all you want, but your passions are meaningless in this world.  They always have been.  Everything you've built is falling.  Everyone is leaving.  And no one cares.~ + MythalTriggerNoArmyIntimidate
END

IF ~~ THEN BEGIN QuestionMotivesStartI1A
SAY ~Even if we did settle on some remote island, our "safety" would not last long.  When our nation became prosperous and strong, humanity would see profit in our destruction and send pirates and thieves to eat us alive until we were weak enough to conquer.  We cannot survive by relying on humanity's goodwill.~
+ ~CheckSkillGT(Protagonist,11,Diplomacy)~ + ~I would question your reasoning.  You're saying that the Legion wouldn't be strong enough to survive as an independent island even if it had decades to build up its strength--yet you also say that the Legion *is* strong enough to conquer the Ten Towns now, *without* the benefit of thirty years of safety in independence.~ EXTERN ~60MADAE~ SuccessfulQuestionMotivesM1A
+ ~~ + ~You underestimate humankind's capacity for tolerance.  Humanity would have no reason to object to your presence if you were simply a neighboring nation.~ EXTERN ~60MADAE~ FailedQuestionMotivesM1A
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI1A
SAY ~I can't begin to imagine, sister.~
+ ~~ + ~Look, I have no opinions either way on the half-breeds of the world.  If you want to have your own nation, that's fine with me.  But when you want to establish that nation on the ashes of *mine,* then it becomes a problem.  If the Legion is destroyed, that solves our problem, but a war costs the Ten Towns blood and treasure.  If the Legion makes its home somewhere safe, that also solves our problem, but doesn't cost us anything.~ + SuccessfulQuestionMotivesI1B
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI1B
SAY ~Your concern is truly touching, mercenary.~
+ ~~ + ~Think about it, Isair.  A war takes blood and treasure away from the Legion as well.  Why waste your resources trying to burn the Ten Towns when you could use them to build a new nation elsewhere?  After all, that's what you did with the Severed Hand, isn't it?  Instead of conquering an existing city to make your headquarters, you renovated a dead one.  Look at it now--this is a successful and safe home that didn't require pushing out the occupants.~ EXTERN ~60MADAE~ SuccessfulQuestionMotivesM1B
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI1C
SAY ~We should not.  And we will not.~
+ ~~ + ~You can't very well tell me that making the Severed Hand your headquarters was a bad choice.  It's a fine place that you acquired without conquest.  How many resources have you lost by failing to take the Ten Towns?  How many resources have you *gained* by taking the Severed Hand?~ GOTO SuccessfulQuestionMotivesI1D
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI1D
SAY ~The Severed Hand is not enough.  We cannot house the Legion in a single tower.  We need a homeland.~
+ ~~ + ~Then find one.  You have diviners and researchers at your disposal; you can easily establish your nation in a place safe from humanity.  All you have to do is find one.~ EXTERN ~60MADAE~ SuccessfulQuestionMotivesM1C
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI1E
SAY ~We do not need your "help," mercenary.  The Legion is already on the rise.  The Ten Towns are already falling.  Why would we give up a war we're already winning?~
+ ~~ + ~Because you don't *need* to win the war, Isair.  All you need to do is establish a nation and then defend it.  Extract a few concessions, gather your resources, and move somewhere safe.  Don't risk the fate of your Legion by basing its survival on the Ten Towns' destruction.~ GOTO FailedQuestionMotivesI1B
+ ~CheckSkillGT(Protagonist,25,Diplomacy)~ + ~I'm not here to deride your efforts, Isair.  But the very fact that I stand here, alive and fully armed, in your own citadel, despite everything you've done to bring me down, is proof enough that the Legion is not winning the war.  Nobody is winning this war.  Everyone is losing.  Now, I'm not saying we can all get along, or that the Ten Towns and the Legion can live in peace side by side.  I'm not a fool.  But the Ten Towns, the Legion, and the world as a whole all stand to benefit if the Legion becomes an independent nation somewhere on Faerun.  It could be a sanctuary for all the people rejected by the rest of civilization.~ EXTERN ~60MADAE~ SuccessfulQuestionMotivesM1D
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI1F
SAY ~Yes... If only it were that simple.~
+ ~~ + ~Is it really that complicated?  All you need to do is take your people to a safer place.~ GOTO SuccessfulQuestionMotivesI1G
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI1G
  SAY ~We would be surrendering all of the gains we've made in Icewind Dale.  It took years for us to...~
  IF ~~ THEN REPLY ~Go on.~ GOTO MythalTriggerQuestionMotives1A
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI2A
SAY ~The Legion of the Chimera is the only hope for our people.  No one else cares if they live or die--the Ten Towns *never* gave any thought to our welfare until the Legion arose.~
  IF ~CheckSkillGT(Protagonist,9,Bluff)~ THEN REPLY ~You didn't answer my question. What have you done for the freaks and half-breeds of the north?  I walk the halls of your headquarters and I do not see oppressed people with hope in their eyes or passion in their words.  All I see are rich and powerful people from the various rich and powerful organizations that you've been courting.  It looks no different from any court in Cormyr or Calimshan--just another place where the wealthy make alliances with other wealthy people to keep themselves in power.~ GOTO SuccessfulQuestionMotivesI2B
  IF ~CheckSkillLT(Protagonist,9,Bluff)~ THEN REPLY ~As far as I can tell, the Legion doesn't care, either.  What have you done for the freaks and half-breeds of the north?~ GOTO FailedQuestionMotivesI2B
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI2B
SAY ~Our alliances are necessary to keep the Legion strong.  One does not build an empire on hopes and dreams alone.  The Legion makes allies just like any other nation.~
  IF ~~ THEN REPLY ~And like any other nation, do its leaders have no ambitions beyond enriching themselves?~ EXTERN ~60MADAE~ SuccessfulQuestionMotivesM2C
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI2D
SAY ~Incredible--this mercenary thwarts our progress for weeks on end without even understanding the Legion's purpose, and now he's demanding that we answer his questions.~
  IF ~~ THEN REPLY ~I'm not saying you have to answer my question.  I'm asking if you even *can.*  Can you actually name a single thing you've done for these people?  Or is this entire Legion just about gathering power for yourself?~ GOTO SuccessfulQuestionMotivesI2F
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI2E
SAY ~Incredible--this mercenary thwarts our progress for weeks on end without even understanding the Legion's purpose, and now she's demanding that we answer her questions.~
  IF ~~ THEN REPLY ~I'm not saying you have to answer my question.  I'm asking if you even *can.*  Can you actually name a single thing you've done for these people?  Or is this entire Legion just about gathering power for yourself?~ GOTO SuccessfulQuestionMotivesI2F
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI2F
SAY ~This world is run by those with power.  You act as though forging the Legion was a selfish act, but the Legion needs to be strong.~
  IF ~~ THEN REPLY ~What about you, Madae?  Have you done anything for the dispossessed of the world since creating the Legion?~ EXTERN ~60MADAE~ QuestionMotivesStartM2D
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI2G
SAY ~This is getting repetitive.  Would it be all right if I killed them now?~
  IF ~~ THEN REPLY ~Answer my question, Isair.  If you're more than just some sniveling cambion freak-~ GOTO SuccessfulQuestionMotivesI2H
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI2H
SAY ~A cambion freak?!  This is exactly what we've been fighting all these years!  Bigotry!  Ignorance!  The savage cruelty of the "civilized" world!~
  IF ~~ THEN REPLY ~Oh, how hard it must be to be Isair and Madae, living in splendor atop their tower!  Is there no end to their suffering?~ GOTO SuccessfulQuestionMotivesI2I
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI2I
SAY ~You have no idea what we've been through, mercenary!  You have no idea what we've had to overcome!~
  IF ~~ THEN REPLY ~Then enlighten me.  What's so hard about being Isair and Madae?~ GOTO MythalTriggerQuestionMotives2A
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3A
SAY ~They had no choice but to accept your help.  Would they have treated you the same if they were not under attack?~
  IF ~SubRace(Protagonist,ELF_DROW)~ THEN REPLY ~You seem to have trouble understanding this.  Is it so hard to fathom?  Sure, a few people gave me suspicious looks when they first saw me, but once they knew I wasn't their enemy, no one gave me any trouble.~ GOTO SuccessfulQuestionMotivesI3B
  IF ~Race(Protagonist,HALFORC)~ THEN REPLY ~They did treat me the same when they were not under attack.  When the attack was over, I wandered around town and no one harassed me.  They didn't turn on me when the goblins were gone.~ GOTO SuccessfulQuestionMotivesI3B
  IF ~SubRace(Protagonist,HUMAN_TIEFLING)~ THEN REPLY ~Targos is not the only place I've been, Isair.  I've been around plenty of other humans, and I have yet to be burned at the stake.~ GOTO SuccessfulQuestionMotivesI3B
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3B
SAY ~Then you are an unusual case.  My sister and I did not receive such a warm welcome.  The first time humans laid eyes on *us,* they tried to murder us.~
  IF ~Global("US_EGENIA_PART", "GLOBAL", 1)~ THEN REPLY ~I'm familiar with the story.  The humans did not attack you for your appearance alone--they attacked you because you were standing over the corpse of a human woman.~ EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3C
  IF ~~ THEN REPLY ~Not everyone has the same story, Isair.  If all of us had the same experience as you, there wouldn't be nearly as many of us.~ GOTO FailedQuestionMotives3B
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3C
SAY ~Explaining would have been pointless.  They never would have listened.~
  IF ~~ THEN REPLY ~They were never given a chance to.  You fought back and killed them.  After that, I'm sure there was no going home.  But haven't you thought about what might have been?  You had a good life with Mother Egenia, a *human.*  Ilmadia might have taken her own life rather than raise you, but Egenia was different.~ EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3D
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3D
SAY ~Wh-what?~
  IF ~~ THEN REPLY ~I met your mother's spirit in her home near Kuldahar.  Iselore and Nathaniel pointed me in the right direction.  Mother Egenia never did find out what happened to you.  She dwelled there as a ghost, waiting for you to return for years.~ EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3E
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3E
SAY ~Is she still not at rest?  Even now?~
  IF ~~ THEN REPLY ~We put her to rest.  We told her what happened at her funeral... the altercation with the villagers.~ EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3F
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3F
SAY ~I... I don't understand.  "Our final stand?"  What does that mean?~
  IF ~~ THEN REPLY ~Not *your* final stand, Isair.  She was speaking of ours.~ GOTO SuccessfulQuestionMotivesI3G
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3G
SAY ~Your final stand?  Here?  Now?~
  IF ~~ THEN REPLY ~I think she expected this to end in violence.~ GOTO SuccessfulQuestionMotivesI3H
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3H
SAY ~Hm.  For a moment, I almost believed you.  But this is just a ploy.~
  IF ~~ THEN REPLY ~A ploy?~ GOTO SuccessfulQuestionMotivesI3HH
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3HH
SAY ~You come to us with a tale of *our* mother telling *you* to stand strong against us.  Her own children.  No--you're just trying to shake us.~
  IF ~~ THEN REPLY ~I don't think she wanted us to kill you, Isair.  Quite the opposite.~ EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3G
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3I
SAY ~I don't understand.  Why...~
  IF ~~ THEN REPLY ~I think Mother Egenia just wanted us to talk to you.~ EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3H
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3J
SAY ~I...~
  IF ~~ THEN EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3I
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3K
SAY ~Heh...~
  IF ~~ THEN GOTO SuccessfulQuestionMotivesI3L
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3L
SAY ~How long has it been, Madae?  How long have we been away from home?~
  IF ~~ THEN EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3J
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3M
SAY ~Maybe we should go back sometime.  It might be nice.~
  IF ~~ THEN EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3JJ
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3N
SAY ~So then... What now?~
  IF ~~ THEN REPLY ~I'm not sure.  I don't think this conversation is over yet... But I don't think it has to end today.  Maybe another time?~ GOTO SuccessfulQuestionMotivesI3O
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesI3O
SAY ~Yes.  Another time, I think.  Then we can...Agh! What--ack!--what was that?~
  IF ~~ THEN EXTERN ~60MADAE~ SuccessfulQuestionMotivesM3K
END

IF ~~ THEN BEGIN FailedMageIntimidateFight
  SAY ~No, that doesn't make sense.  The Red Wizards have reviewed the mythal's structure dozens of times; they would have detected any flaws in the enchantments.  This is a waste of time.  Would it be all right if I killed them now, sister?~
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN FailedQuestionMotivesFight
  SAY ~Enough of this stupidity.  There is no point in debating ethics with a band of mercenaries.  Would it be all right if I killed them now, sister?~
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN FailedQuestionMotivesI1A
  SAY ~I doubt they are really so naive.  I would say "disingenuous."  Would it be all right if I killed them now, sister?~
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN FailedQuestionMotivesI1B
  SAY ~... No.  No, this is pointless.~
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ FailedQuestionMotivesM1B
END

IF ~~ THEN BEGIN FailedQuestionMotivesI2A
  SAY ~You act as if there were any difference.  Would it be all right if I killed them now, sister?~
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN FailedQuestionMotivesI2B
  SAY ~I'm getting tired of this.  Would it be all right if I killed them now, sister?~
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN FailedQuestionMotivesRaceAnyI
  SAY ~Gullible people who serve their own oppressors.  Would it be all right if I killed them now, sister?~
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN FailedQuestionMotives3B
  SAY ~If the humans treated us as equals, then there would be many more of us.  Madae and I have seen just how deep intolerance runs in human society.  You just refuse to see it.  Would it be all right if I killed them now, sister?~
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN FailedQuestionMotives3C
  SAY ~That was all it took.  One brief glance without context, and they already knew everything they cared to know.  Madae and I have seen just how deep intolerance runs in human society, and there is no justification for it, no matter how much you want to excuse it.  Would it be all right if I killed them now, sister?~
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN FailedNoArmyIntimidateFight 
  SAY ~Enough of this stupidity.  The Ten Towns are broken.  The Legion has domain over the Severed Hand, and it is only a matter of time before the Ten Towns fall.  Would it be all right if I killed them now, sister?~
  IF ~~ THEN DO ~SetGlobal("Ready_To_Retreat","GLOBAL",0)
Enemy()~ EXTERN ~60MADAE~ 16
END

IF ~~ THEN BEGIN MythalTriggerMageIntimidate
  SAY ~That's impossible.  That's impossible!  I... Agh! What--ack!--what was that?~
  IF ~~ THEN REPLY ~I just finished my spell.  I won.~ GOTO MythalTriggerMageIntimidate2
END

IF ~~ THEN BEGIN MythalTriggerMageIntimidate2
  SAY ~Madae... what was that?  What's happening to me?~
  IF ~~ THEN DO ~SetGlobal("Final_Battle_Progress","GLOBAL",3)~ EXTERN ~60MADAE~ 21
END

IF ~~ THEN BEGIN MythalTriggerQuestionMotives1A
  SAY ~I just... Agh! What--ack!--what was that?~
  IF ~~ THEN REPLY ~Isair?  Are you all right?~ GOTO MythalTriggerQuestionMotives1B
END

IF ~~ THEN BEGIN MythalTriggerQuestionMotives1B
  SAY ~Madae... what was that?  What's happening to me?~
  IF ~~ THEN DO ~SetGlobal("Final_Battle_Progress","GLOBAL",3)~ EXTERN ~60MADAE~ 21
END

IF ~~ THEN BEGIN MythalTriggerQuestionMotives2A
  SAY ~We've been fighting the same war since the day we were born.  Maiden Ilmadia, our... I... Agh! What--ack!--what was that?~
  IF ~~ THEN REPLY ~A very short story, apparently.~ GOTO MythalTriggerQuestionMotives2B
  IF ~~ THEN REPLY ~What was what?~ GOTO MythalTriggerQuestionMotives2B
END

IF ~~ THEN BEGIN MythalTriggerQuestionMotives2B
  SAY ~Madae... what was that?  What's happening to me?~
  IF ~~ THEN DO ~SetGlobal("Final_Battle_Progress","GLOBAL",3)~ EXTERN ~60MADAE~ 21
END

IF ~~ THEN BEGIN MythalTriggerQuestionMotives3A
  SAY ~Madae... what was that?  What's happening to me?~
  IF ~~ THEN REPLY ~Isair?  What's wrong?~ DO ~SetGlobal("Final_Battle_Progress","GLOBAL",3)~ EXTERN ~60MADAE~ 21
END

IF ~~ THEN BEGIN MythalTriggerNoArmyIntimidate
  SAY ~Collapsing?  This empire has only just begun!  We... I... Agh! What--ack!--what was that?~
  IF ~~ THEN REPLY ~You can already feel it, can't you?  Your empire is crumbling.~ GOTO MythalTriggerNoArmyIntimidate2
  IF ~~ THEN REPLY ~What was what?~ GOTO MythalTriggerNoArmyIntimidate2
END

IF ~~ THEN BEGIN MythalTriggerNoArmyIntimidate2
  SAY ~Madae... what was that?  What's happening to me?~
  IF ~~ THEN DO ~SetGlobal("StartCutscene_63cFB06","MYAREA",1)
SetGlobal("Final_Battle_Progress","GLOBAL",3)
SetGlobal("US_Final_Battle_Alternate","GLOBAL",1)
Unlock("AR6303_Door1")
SetGlobal("Activate_Trigger","MYAREA",1)
SetGlobal("StartCutscene_63cFB03","MYAREA",1)
HideCreature("Serak",FALSE)
HideCreature("Mourn",FALSE)
HideCreature("Zilvar",FALSE)
HideCreature("Tilzen",FALSE)
HideCreature("Phaen",FALSE)
HideCreature("Chimera",FALSE)
HideCreature("Buvai_deNaly",FALSE)
ActionOverride("Serak",DestroySelf())
ActionOverride("Mourn",DestroySelf())
ActionOverride("Zilvar",DestroySelf())
ActionOverride("Tilzen",DestroySelf())
ActionOverride("Phaen",DestroySelf())
ActionOverride("Chimera",DestroySelf())
ActionOverride("Buvai_deNaly",DestroySelf())
ActionOverride("Ormis_Dohor",DestroySelf())
ActionOverride("Monk_Sand",DestroySelf())
ActionOverride("Monk_Shadow",DestroySelf())
ActionOverride("Monk_Crystalline",DestroySelf())
ActionOverride("Isair",DestroySelf())
ActionOverride("Madae",DestroySelf())~ EXTERN ~60MADAE~ 21
END

IF ~~ THEN BEGIN ListOfCommands
  SAY ~This should not appear in-game.~
  IF ~~ THEN DO ~SetGlobal("Final_Battle_Progress","GLOBAL",3)
SetGlobal("StartCutscene_63cFB02","MYAREA",1)
SetGlobal("US_Final_Battle_Alternate","GLOBAL",1)
Unlock("AR6303_Door1")
SetGlobal("Activate_Trigger","MYAREA",1)
HideCreature("Serak",TRUE)
HideCreature("Mourn",TRUE)
HideCreature("Zilvar",TRUE)
HideCreature("Tilzen",TRUE)
HideCreature("Phaen",TRUE)
HideCreature("Chimera",TRUE)
HideCreature("Buvai_deNaly",TRUE)
ActionOverride("Serak",DestroySelf())
ActionOverride("Mourn",DestroySelf())
ActionOverride("Zilvar",DestroySelf())
ActionOverride("Tilzen",DestroySelf())
ActionOverride("Phaen",DestroySelf())
ActionOverride("Chimera",DestroySelf())
ActionOverride("Buvai_deNaly",DestroySelf())
SetGlobal("StartCutscene_63cFB06","MYAREA",1)
ActionOverride("Ormis_Dohor",DestroySelf())
ActionOverride("Monk_Sand",DestroySelf())
ActionOverride("Monk_Shadow",DestroySelf())
ActionOverride("Monk_Crystalline",DestroySelf())~ EXIT
END

IF ~~ THEN BEGIN ListOfCommands2
  SAY ~This should not appear in-game.~
  IF ~~ THEN DO ~SetGlobal("StartCutscene_63cFB06","MYAREA",1)
SetGlobal("Final_Battle_Progress","GLOBAL",3)
SetGlobal("US_Final_Battle_Alternate","GLOBAL",1)
Unlock("AR6303_Door1")
SetGlobal("Activate_Trigger","MYAREA",1)
SetGlobal("StartCutscene_63cFB03","MYAREA",1)
HideCreature("Serak",FALSE)
HideCreature("Mourn",FALSE)
HideCreature("Zilvar",FALSE)
HideCreature("Tilzen",FALSE)
HideCreature("Phaen",FALSE)
HideCreature("Chimera",FALSE)
HideCreature("Buvai_deNaly",FALSE)
ActionOverride("Serak",DestroySelf())
ActionOverride("Mourn",DestroySelf())
ActionOverride("Zilvar",DestroySelf())
ActionOverride("Tilzen",DestroySelf())
ActionOverride("Phaen",DestroySelf())
ActionOverride("Chimera",DestroySelf())
ActionOverride("Buvai_deNaly",DestroySelf())
ActionOverride("Ormis_Dohor",DestroySelf())
ActionOverride("Monk_Sand",DestroySelf())
ActionOverride("Monk_Shadow",DestroySelf())
ActionOverride("Monk_Crystalline",DestroySelf())~ EXIT
END
