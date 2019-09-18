BEGIN ~60MADAE~

IF ~~ THEN BEGIN 0
  SAY #29361
  IF ~~ THEN EXTERN ~61ISAIR~ 1
END

IF ~~ THEN BEGIN 1
  SAY #29363
  IF ~~ THEN REPLY #29364 EXTERN ~61ISAIR~ 11
  IF ~~ THEN REPLY #29365 EXTERN ~61ISAIR~ 11
  IF ~~ THEN REPLY ~Unification?  Solidarity?  Enslavement?  From what I've seen, the Legion isn't strong enough to achieve any of those things.~ GOTO NoArmyIntimidateM
  IF ~~ THEN REPLY #29367 GOTO 17
END

IF ~~ THEN BEGIN 2
  SAY #29368
  IF ~~ THEN REPLY #29369 EXTERN ~61ISAIR~ 12
  IF ~~ THEN REPLY #29370 EXTERN ~61ISAIR~ 12
  IF ~~ THEN REPLY #29371 EXTERN ~61ISAIR~ 12
  IF ~~ THEN REPLY #29367 GOTO 17
END

IF ~~ THEN BEGIN 3
  SAY #29372
  IF ~~ THEN REPLY #29373 EXTERN ~61ISAIR~ 12
  IF ~~ THEN REPLY #29374 EXTERN ~61ISAIR~ 12
  IF ~~ THEN REPLY #29375 GOTO 13
  IF ~~ THEN REPLY #29367 GOTO 17
END

IF ~~ THEN BEGIN 4
  SAY #29376
  IF ~~ THEN REPLY #29377 GOTO 13
  IF ~~ THEN REPLY #29378 GOTO 13
  IF ~~ THEN REPLY #29379 GOTO 13
  IF ~~ THEN REPLY #29367 GOTO 17
END

IF ~~ THEN BEGIN 5
  SAY #29380
  IF ~~ THEN REPLY #29381 GOTO 13
  IF ~~ THEN REPLY #29382 GOTO 13
  IF ~~ THEN REPLY #29383 GOTO 13
  IF ~~ THEN REPLY #29367 GOTO 17
END

IF ~~ THEN BEGIN 6
  SAY #29384
  IF ~~ THEN REPLY #29385 EXTERN ~61ISAIR~ 14
  IF ~~ THEN REPLY #29386 GOTO 13
  IF ~~ THEN REPLY #29387 GOTO 13
  IF ~~ THEN REPLY #29367 GOTO 17
END

IF ~~ THEN BEGIN 7
  SAY #29388
  IF ~~ THEN REPLY ~Unification?  Solidarity?  Enslavement?  From what I've seen, the Legion isn't strong enough to achieve any of those things.~ GOTO NoArmyIntimidateM
  IF ~~ THEN REPLY #29390 GOTO 13
  IF ~~ THEN REPLY #29391 GOTO 13
  IF ~~ THEN REPLY #29367 GOTO 17
  IF ~~ THEN REPLY ~What does destroying Targos and the Ten Towns have to do with uniting the half-breeds of the world?~ GOTO QuestionMotivesStartM
END

IF ~~ THEN BEGIN 8
  SAY #29392
  IF ~~ THEN REPLY #29389 EXTERN ~61ISAIR~ 11
  IF ~~ THEN REPLY #29390 GOTO 13
  IF ~~ THEN REPLY #29391 GOTO 13
  IF ~~ THEN REPLY #29367 GOTO 17
END

IF ~~ THEN BEGIN 9
  SAY #29393
  IF ~~ THEN REPLY #29394 EXTERN ~61ISAIR~ 15
  IF ~~ THEN REPLY #29395 EXTERN ~61ISAIR~ 16
  IF ~  SubRace(Protagonist,HUMAN_AASIMAR)
~ THEN REPLY #29396 EXTERN ~61ISAIR~ 16
  IF ~  SubRace(Protagonist,HUMAN_TIEFLING)
~ THEN REPLY #29396 EXTERN ~61ISAIR~ 16
  IF ~~ THEN REPLY #29367 GOTO 17
END

IF ~~ THEN BEGIN 10
  SAY #29397
  IF ~~ THEN REPLY #29394 EXTERN ~61ISAIR~ 15
  IF ~~ THEN REPLY #29395 EXTERN ~61ISAIR~ 16
  IF ~  SubRace(Protagonist,HUMAN_AASIMAR)
~ THEN REPLY #29396 EXTERN ~61ISAIR~ 16
  IF ~  SubRace(Protagonist,HUMAN_TIEFLING)
~ THEN REPLY #29396 EXTERN ~61ISAIR~ 16
  IF ~~ THEN REPLY #29367 GOTO 17
END

IF ~~ THEN BEGIN 11
  SAY #29398
  IF ~~ THEN REPLY #29394 EXTERN ~61ISAIR~ 15
  IF ~~ THEN REPLY #29395 EXTERN ~61ISAIR~ 16
  IF ~  SubRace(Protagonist,HUMAN_AASIMAR)
~ THEN REPLY #29396 EXTERN ~61ISAIR~ 16
  IF ~  SubRace(Protagonist,HUMAN_TIEFLING)
~ THEN REPLY #29396 EXTERN ~61ISAIR~ 16
  IF ~~ THEN REPLY #29367 GOTO 17
END

IF ~~ THEN BEGIN 12
  SAY #29399
  IF ~~ THEN EXTERN ~61ISAIR~ 19
END

IF ~~ THEN BEGIN 13
  SAY #29400
  IF ~~ THEN EXTERN ~61ISAIR~ 19
END

IF ~~ THEN BEGIN 14
  SAY #29401
  IF ~~ THEN EXTERN ~61ISAIR~ 17
END

IF ~~ THEN BEGIN 15
  SAY #29402
  IF ~~ THEN EXTERN ~61ISAIR~ 18
END

IF ~~ THEN BEGIN 16
  SAY #29403
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 17
  SAY #29404
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 18
  SAY #29405
  IF ~~ THEN DO ~StartCutSceneMode()
StartCutScene("63cFB02")~ EXIT
END

IF ~~ THEN BEGIN 19
  SAY #29406
  IF ~~ THEN EXTERN ~61ISAIR~ 22
END

IF ~~ THEN BEGIN 20
  SAY #29407
  IF ~~ THEN EXTERN ~61ISAIR~ 24
END

IF ~~ THEN BEGIN 21
  SAY #29408
  IF ~~ THEN EXTERN ~64ORRICK~ 67
END

IF ~~ THEN BEGIN 22
  SAY #29409
  IF ~~ THEN EXTERN ~64ORRICK~ 69
END

IF ~~ THEN BEGIN 23
  SAY #29410
  IF ~~ THEN EXTERN ~64ORRICK~ 70
END

IF ~~ THEN BEGIN 24
  SAY #29411
  IF ~~ THEN GOTO 25
END

IF ~~ THEN BEGIN 25
  SAY #29412
  IF ~~ THEN EXTERN ~60ISELOR~ 51
END

IF ~~ THEN BEGIN 26
  SAY #29413
  IF ~~ THEN EXTERN ~60ISELOR~ 52
END

IF ~~ THEN BEGIN 27
  SAY #29414
  IF ~~ THEN GOTO 28
END

IF ~~ THEN BEGIN 28
  SAY #29415
  IF ~~ THEN DO ~SetGlobal("60Party_Entered","GLOBAL",1)
StartCutsceneMode()
StartCutscene("60CCMI2")~ EXIT
END

IF ~  Global("60Party_Entered","GLOBAL",1)
~ THEN BEGIN 29
  SAY #29416
  IF ~~ THEN REPLY #29417 GOTO 30
  IF ~~ THEN REPLY #29418 GOTO 31
  IF ~~ THEN REPLY #29419 GOTO 32
  IF ~~ THEN REPLY #29420 GOTO 33
END

IF ~~ THEN BEGIN 30
  SAY #29421
  IF ~~ THEN EXTERN ~60ISELOR~ 53
END

IF ~~ THEN BEGIN 31
  SAY #29424
  IF ~~ THEN EXTERN ~60ISELOR~ 53
END

IF ~~ THEN BEGIN 32
  SAY #29425
  IF ~~ THEN EXTERN ~60ISELOR~ 53
END

IF ~~ THEN BEGIN 33
  SAY #29426
  IF ~~ THEN EXTERN ~60ISELOR~ 53
END

IF ~~ THEN BEGIN 34
  SAY #29427
  IF ~~ THEN DO ~Enemy()
StartCutsceneMode()
StartCutscene("60CCMI3")~ EXIT
END

IF ~~ THEN BEGIN 35
  SAY #32053
  IF ~~ THEN EXIT
END


IF ~~ THEN BEGIN NoArmyIntimidateM
SAY ~Look around you, mercenary.  We already hold the Severed Hand.  You are surrounded by the strongest forces in all of Icewind Dale--as well as allies from outside the Material Plane.~
  IF ~~ THEN EXTERN ~61ISAIR~ NoArmyIntimidateI
END

IF ~~ THEN BEGIN QuestionMotivesStartM
SAY ~There can be no peace for our kind as long as your "civilization" stands.  Humanity has been subjugating the half-breeds of Faerun for as long as history has existed.  We learned long ago that humanity would never tolerate "peaceful coexistence" with us--we must knock them from their perch and take the throne for ourselves.~
  IF ~~ THEN REPLY ~But why settle here?  Humanity already controls this territory.  Yet there are numerous other places where the Legion and its kin could take shelter.  There are unsettled lands in Chult, islands across the sea where great expanses of water would form a wall against humankind--you could even travel to Zakhara and make your home there.  This is the worst place you could choose to settle your people.~ GOTO QuestionMotivesStartM1A
  IF ~~ THEN REPLY ~In other words, you're just trying to replace one injustice with another.~ GOTO QuestionMotivesStartM2A
  IF ~SubRace(Protagonist,ELF_DROW)~ THEN REPLY ~I am a drow myself, and I could not disagree with you more.~ GOTO QuestionMotivesStartM3A
  IF ~Race(Protagonist,HALFORC)~ THEN REPLY ~I myself am a half-orc, and I couldn't disagree with you more.~ GOTO QuestionMotivesStartM3A
  IF ~SubRace(Protagonist,HUMAN_TIEFLING)~ THEN REPLY ~I am a tiefling--from a human's perspective, nothing more than a cousin of a cambion--and I could not disagree with you more.~ GOTO QuestionMotivesStartM3A
END

IF ~~ THEN BEGIN QuestionMotivesStartM1A
SAY ~You're suggesting we resign ourselves to the lands that humankind doesn't want.  Living as poor outcastes in an abandoned wasteland is not the life we seek.  We have every right to Icewind Dale and Faerun as a whole; we were born here.~
  IF ~~ THEN EXTERN ~61ISAIR~ QuestionMotivesStartI1A
END

IF ~~ THEN BEGIN QuestionMotivesStartM2A
SAY ~Injustice?  That's how you describe the liberation of all the oppressed peoples of the world?~
  IF ~~ THEN REPLY ~I fail to see what you've done for the "oppressed peoples of the world."  All you've done is wage war against those who are different from you and forge alliances with the most evil and oppressive forces you could find.~ GOTO QuestionMotivesStartM2B
END

IF ~~ THEN BEGIN QuestionMotivesStartM2B
SAY ~Of course you would think that.  You fight for Targos.  All you're here to do is defend the bigots of the world because they're on your side.  But that age is coming to an end.  All of you are coming to an end.~
  IF ~CheckSkillGT(Protagonist,21,Diplomacy)~ THEN REPLY ~I see no difference between you and the other bigots of the world.  What have you really done for the dispossessed of Faerun?  Have you given them food, clothing, shelter?  Are they any richer or any safer because of the Legion?~ EXTERN ~61ISAIR~ SuccessfulQuestionMotivesI2A
  IF ~~ THEN REPLY ~I'm not here to defend bigots.  I'm here to defend the Ten Towns!~ EXTERN ~61ISAIR~ FailedQuestionMotivesI2A
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesM2C
SAY ~Say what you will about our methods.  The results speak for themselves.  We are stronger now than we've ever been.~
  IF ~Gender(Protagonist,MALE)~ THEN REPLY ~You still haven't answered my question--what have you *done* for the people you're supposedly protecting?~ EXTERN ~61ISAIR~ SuccessfulQuestionMotivesI2D
  IF ~!Gender(Protagonist,MALE)~ THEN REPLY ~You still haven't answered my question--what have you *done* for the people you're supposedly protecting?~ EXTERN ~61ISAIR~ SuccessfulQuestionMotivesI2E
END

IF ~~ THEN BEGIN QuestionMotivesStartM2C
SAY ~Say what you will about our methods.  The results speak for themselves.  We are stronger now than we've ever been.~
  IF ~~ THEN REPLY ~You still haven't answered my question--what have you *done* for the people you're supposedly protecting?~ EXTERN ~61ISAIR~ SuccessfulQuestionMotivesI2D
END

IF ~~ THEN BEGIN QuestionMotivesStartM2D
SAY ~Isair, I'm getting tired of these grandstanding mercenaries.~
  IF ~~ THEN REPLY ~You can't do it!  You can't name a single thing you've done!  The Legion of the Chimera isn't about liberating anyone--the Legion is just a sham to make yourself stronger.~ EXTERN ~61ISAIR~ SuccessfulQuestionMotivesI2G
END

IF ~~ THEN BEGIN QuestionMotivesStartM3A
SAY ~Then I would question your intelligence.  Only a fool would fail to realize how humanity truly feels about your existence.~
  IF ~~ THEN REPLY ~It's true I've experienced some bigotry because of my race, but that hardly represents what humanity is really like.~ GOTO FailedQuestionMotivesRaceAny
  IF ~SubRace(Protagonist,ELF_DROW)
CheckSkillGT(Protagonist,9,Bluff)~ THEN REPLY ~Madae, I am the hero of Targos.  When I arrived on the docks, they did not turn me away or attack me on sight.  They welcomed me, despite the color of my skin.~ GOTO SuccessfulQuestionMotivesM3B
  IF ~Race(Protagonist,HALFORC)
CheckSkillGT(Protagonist,8,Bluff)~ THEN REPLY ~Madae, I am the hero of Targos.  When I arrived on the docks, they did not attack me, even though they had already fought many orcs before me.  They welcomed me, despite the color of my skin.~ GOTO SuccessfulQuestionMotivesM3B
  IF ~SubRace(Protagonist,HUMAN_TIEFLING)
CheckSkillGT(Protagonist,6,Bluff)~ THEN REPLY ~Madae, I am the hero of Targos.  They did not reject me for my heritage; they embraced me for my skills.~ GOTO SuccessfulQuestionMotivesM3B
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesM3B
SAY ~I know what happened when you arrived in Targos.  You reached Targos in the middle of a goblin invasion.  They let you fight for them out of desperation.~
  IF ~~ THEN EXTERN ~61ISAIR~ SuccessfulQuestionMotivesI3A
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesM3C
SAY ~We were burying our foster mother, mercenary.  I was performing the rites when those villagers attacked.~
  IF ~Global("US_EGENIA_FULL", "GLOBAL", 1)
CheckSkillGT(Protagonist,9,Diplomacy)~ THEN REPLY ~I know.  Mother Egenia, a priestess of Ilmater.  Your former god, Madae, before your mother passed away.~ GOTO SuccessfulQuestionMotivesM3CC
  IF ~~ THEN REPLY ~Can you blame them?  They had no idea what happened.  For all they knew, you had killed her.~ EXTERN ~61ISAIR~ FailedQuestionMotives3C
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesM3CC
SAY ~Former god, yes.  Ilmater would have had us surrender our lives and let the villagers kill us for no reason.  I do not see the wisdom in that choice.~
  IF ~~ THEN REPLY ~Ilmater would not have had you surrender.  He would have had you run away and find another time to explain what had happened.~ EXTERN ~61ISAIR~ SuccessfulQuestionMotivesI3C
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesM3D
SAY ~Mother was different, yes.  But I do not appreciate being lectured by some random mercenary who never even met her!~
  IF ~~ THEN REPLY ~I did meet her, Madae.~ EXTERN ~61ISAIR~ SuccessfulQuestionMotivesI3D
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesM3E
SAY ~She was still there?  After we left?~
  IF ~~ THEN REPLY ~She was afraid something terrible had happened to you.  She couldn't rest until she found out where you had gone.~ EXTERN ~61ISAIR~ SuccessfulQuestionMotivesI3E
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesM3F
SAY ~What did she say?~
  IF ~~ THEN REPLY ~"Be strong when you make your final stand, and you shall prevail."~ EXTERN ~61ISAIR~ SuccessfulQuestionMotivesI3F
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesM3G
SAY ~What do you mean?~
  IF ~~ THEN REPLY ~Well, she was a priestess of Ilmater, Madae.  The god of martyrdom--those who stand strong in the face of violence.~ EXTERN ~61ISAIR~ SuccessfulQuestionMotivesI3I
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesM3H
SAY ~Talk to us?~
  IF ~~ THEN REPLY ~Maybe that's the only reason I'm really here.~ EXTERN ~61ISAIR~ SuccessfulQuestionMotivesI3J
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesM3I
SAY ~I don't understand.  Why would...~
  IF ~~ THEN EXTERN ~61ISAIR~ SuccessfulQuestionMotivesI3K
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesM3J
SAY ~A... a long time, Isair.  A very long time.~
  IF ~~ THEN EXTERN ~61ISAIR~ SuccessfulQuestionMotivesI3M
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesM3JJ
SAY ~Yes.  I think it would be.~
  IF ~~ THEN EXTERN ~61ISAIR~ SuccessfulQuestionMotivesI3N
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesM3K
SAY ~Isair? I... urgh...~
  IF ~~ THEN EXTERN ~61ISAIR~ MythalTriggerQuestionMotives3A
END

IF ~~ THEN BEGIN FailedQuestionMotivesRaceAny
SAY ~We've met those like you before.  Gullible people who refuse to notice the dagger pressed against their throat.~
  IF ~~ THEN EXTERN ~61ISAIR~ FailedQuestionMotivesRaceAnyI
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesM1A
SAY ~Why is this mercenary lecturing us on where to make our homes?~
  IF ~~ THEN EXTERN ~61ISAIR~ SuccessfulQuestionMotivesI1A
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesM1B
SAY ~Before we came here, the Severed Hand was in ruins and populated only by violent spirits.  Why should we have to resign ourselves to living in humanity's graveyards?~
IF ~~ THEN EXTERN ~61ISAIR~ SuccessfulQuestionMotivesI1C
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesM1C
SAY ~And why would we take your advice, mercenary?  You've been sabotaging our efforts for weeks.~
IF ~~ THEN REPLY ~I would have given you the same advice a long time ago, if I had had the chance.  This is the first time I've actually been able to speak with you.  I've been thinking about this conversation since I first heard your names.  I'm not here to destroy the Legion; I'm here to keep the Ten Towns safe.  If that means giving the Legion a new home, it makes no difference to me.~ EXTERN ~61ISAIR~ SuccessfulQuestionMotivesI1E
END

IF ~~ THEN BEGIN SuccessfulQuestionMotivesM1D
SAY ~... If only it were that simple.~
IF ~~ THEN EXTERN ~61ISAIR~ SuccessfulQuestionMotivesI1F
END

IF ~~ THEN BEGIN FailedQuestionMotivesM1A
SAY ~A naive mercenary.  I've never heard of such a thing.~
  IF ~~ THEN EXTERN ~61ISAIR~ FailedQuestionMotivesI1A
END

IF ~~ THEN BEGIN FailedQuestionMotivesM1B
  SAY ~I couldn't agree more.  Let's put an end to this.  Farewell, mercenaries.~
  IF ~~ THEN DO ~Enemy()~ EXIT
END
