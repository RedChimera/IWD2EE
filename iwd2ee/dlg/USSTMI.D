BEGIN ~USSTMI~

IF ~~ THEN BEGIN 0
  SAY ~Of course I was, Majrash. Never underestimate a diviner.~
  IF ~~ THEN EXTERN ~USSTMA~ 1
END

IF ~~ THEN BEGIN 1
  SAY ~Kill the adventurers first, I think. Then we deal with the gnomes and the airship.~
  IF ~~ THEN REPLY ~Another two fools rush to their deaths...~ DO ~Enemy()
~ EXIT
  IF ~~ THEN REPLY ~Who exactly are you people?~ EXTERN ~USSTMA~ 2
END

IF ~~ THEN BEGIN 2
  SAY ~I am Mirabel. Diviner and destroyer.~
  IF ~~ THEN EXTERN ~USSTMA~ 3
END

IF ~~ THEN BEGIN 3
  SAY ~They pay very well. And we deserve every coin.~
  IF ~~ THEN REPLY ~How well do they pay?~ EXTERN ~USSTMA~ 4
  IF ~~ THEN REPLY ~The Legion picked you? Let's see if they made the right call.~ DO ~Enemy()
~ EXIT
END

IF ~~ THEN BEGIN 4
  SAY ~Or we could kill you and take your gold. And then get our reward anyway.~
  IF ~CheckSkillGT(Protagonist,20,Intimidate)~ THEN REPLY ~Or I could take that pretty face of yours and grind it against the rock until the screaming stopped.~ EXTERN ~USSTMA~ 6
  IF ~CheckSkillGT(Protagonist,15,Diplomacy)
PartyGoldLT(40000)
~ THEN REPLY ~If you left without a fight, the risk to yourself is minimized. Doesn't it make more sense to part ways?~ GOTO 6
  IF ~CheckSkillGT(Protagonist,15,Diplomacy)
PartyGoldGT(40000)
PartyGoldLT(80000)
~ THEN REPLY ~If you left without a fight, the risk to yourself is minimized. Doesn't it make more sense to part ways?~ GOTO 7
  IF ~CheckSkillGT(Protagonist,15,Diplomacy)
PartyGoldGT(80000)
PartyGoldLT(120000)
~ THEN REPLY ~If you left without a fight, the risk to yourself is minimized. Doesn't it make more sense to part ways?~ GOTO 8
  IF ~~ THEN REPLY ~I hate when they think of that.~ DO ~Enemy()
~ EXIT
END

IF ~~ THEN BEGIN 5
  SAY ~20,000 gold is a good price for doing nothing.~
  IF ~~ THEN REPLY ~Hmph. It is indeed.~ EXTERN ~USSTMA~ 5
END

IF ~~ THEN BEGIN 6
  SAY ~Oh, I think you can afford much more than that. What about 30,000? I would enjoy that much more than 20,000.~
  IF ~~ THEN REPLY ~30,000? That's ridiculous!~ GOTO 6B
  IF ~~ THEN REPLY ~Very well. 30,000 it is.~ EXTERN ~USSTMA~ 7
  IF ~~ THEN REPLY ~Are you insane? I'd rather be assassinated.~ DO ~Enemy()
~ EXIT
END

IF ~~ THEN BEGIN 6B
  SAY ~Ridiculous? I think it's a brilliant idea.~
  IF ~~ THEN REPLY ~Fine! 30,000 gold.~ EXTERN ~USSTMA~ 7
  IF ~~ THEN REPLY ~I'm not going to stand here and be extorted. ~ DO ~Enemy()
~ EXIT
END

IF ~~ THEN BEGIN 7
  SAY ~Oh, I think you can afford much more than that. What about 40,000? I would enjoy that much more than 20,000.~
  IF ~~ THEN REPLY ~40,000? That's ridiculous!~ GOTO 7B
  IF ~~ THEN REPLY ~Very well. 40,000 it is.~ EXTERN ~USSTMA~ 8
  IF ~~ THEN REPLY ~Are you insane? I'd rather be assassinated.~ DO ~Enemy()
~ EXIT
END

IF ~~ THEN BEGIN 7B
  SAY ~Ridiculous? I think it's a brilliant idea.~
  IF ~~ THEN REPLY ~Fine! 40,000 gold.~ EXTERN ~USSTMA~ 8
  IF ~~ THEN REPLY ~I'm not going to stand here and be extorted. ~ DO ~Enemy()
~ EXIT
END

IF ~~ THEN BEGIN 8
  SAY ~Oh, I think you can afford much more than that. What about 50,000? I would enjoy that much more than 20,000.~
  IF ~~ THEN REPLY ~50,000? That's ridiculous!~ GOTO 8B
  IF ~~ THEN REPLY ~Very well. 50,000 it is.~ EXTERN ~USSTMA~ 9
  IF ~~ THEN REPLY ~Are you insane? I'd rather be assassinated.~ DO ~Enemy()
~ EXIT
END

IF ~~ THEN BEGIN 8B
  SAY ~Ridiculous? I think it's a brilliant idea.~
  IF ~~ THEN REPLY ~Fine! 50,000 gold.~ EXTERN ~USSTMA~ 9
  IF ~~ THEN REPLY ~I'm not going to stand here and be extorted. ~ DO ~Enemy()
~ EXIT
END
