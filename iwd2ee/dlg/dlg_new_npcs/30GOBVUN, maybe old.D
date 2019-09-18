BEGIN ~30GOBVUN~

IF WEIGHT #1 ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY #13930
  IF ~~ THEN REPLY #13931 DO ~Enemy()~ EXIT
  IF ~  CheckSkillGT(Protagonist,6,Diplomacy)
~ THEN REPLY #13932 GOTO 1
  IF ~  CheckSkillLT(Protagonist,6,Intimidate)
~ THEN REPLY #13933 GOTO 8
  IF ~  CheckSkillGT(Protagonist,7,Intimidate)
~ THEN REPLY ~I want you gone, just like all the other goblins.  You can leave without a fight or you can join the corpses I've left scattered behind me.~ GOTO 9
END

IF WEIGHT #2 ~  NumTimesTalkedToGT(0)
~ THEN BEGIN 1
  SAY #13934
  IF ~~ THEN REPLY #13935 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #13936 GOTO 2
  IF ~~ THEN REPLY #13937 GOTO 8
END

IF ~~ THEN BEGIN 2
  SAY ~Yes.   Don't look so surprised, just because I'm a goblin doesn't mean I don't think.  I am Vunarg, the chief of the Vunarg Clan, and I have responsibility to them.  We must eat and hunt and war.  Here we have none of those things.  Well, none yet; we wait for now.~
  IF ~~ THEN REPLY #13939 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #13940 GOTO 3
  IF ~~ THEN REPLY #13941 GOTO 8
END

IF ~~ THEN BEGIN 3
  SAY #13942
  IF ~~ THEN REPLY #13943 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #13944 GOTO 4
  IF ~~ THEN REPLY #13945 GOTO 8
END

IF ~~ THEN BEGIN 4
  SAY #13946
  IF ~~ THEN REPLY #13947 DO ~Enemy()~ EXIT
  IF ~  CheckSkillGT(Protagonist,6,Diplomacy)
~ THEN REPLY #13948 GOTO 5
  IF ~~ THEN REPLY #13949 GOTO 8
END

IF ~~ THEN BEGIN 5
  SAY #13950
  IF ~~ THEN REPLY #13951 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY ~Yes.  We're going to take this horde down.  We're already halfway through.~ GOTO 6
  IF ~~ THEN REPLY #13953 GOTO 8
END

IF ~~ THEN BEGIN 6
  SAY #13960
  IF ~~ THEN REPLY #13961 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #13983 GOTO 7
  IF ~!NumInParty(6)
!ClassEx(Protagonist, Paladin)~ THEN REPLY ~If you came here to shed blood and earn gold, why not join the winning team?  You clearly don't owe any loyalty to the horde, the horde has no loyalty to you, and I have no objection to working with a goblin.~ GOTO VunargJoin1
  IF ~~ THEN REPLY #13984 GOTO 8
END

IF WEIGHT #0 ~  False()
~ THEN BEGIN 7
  SAY #13985
  IF ~~ THEN REPLY #13987 DO ~AddXpVar("Level_5_Average",13928)
SetGlobal("30gobVun_leave", "GLOBAL", 1)
StartCutSceneMode()
StartCutScene("30cVunLv")~ JOURNAL #13925 EXIT
END

IF ~~ THEN BEGIN 8
  SAY #28364
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 9
  SAY ~Heh.  In any other situation, I'd chop you apart.  But I've been considering leaving this place for a long time now.  I'll let you wrestle with the orcs and the bugbears -- my people would be happier elsewhere, anyway.  Farewell, townie scum.~
  IF ~~ THEN REPLY #37967 DO ~AddXpVar("Level_5_Hard",13928)
SetGlobal("30gobVun_leave", "GLOBAL", 1)
StartCutSceneMode()
StartCutScene("30cVunLv")~ JOURNAL #37968 EXIT
END

IF ~~ THEN BEGIN 10
  SAY ~They don't.  Let me show you.~
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN VunargJoin1
  SAY ~The winning team?  You really believe you can bring down the horde?~
  IF ~CheckSkillGT(Protagonist,4,Intimidate)~ THEN REPLY ~The horde is strong.  But it's not as strong as us.  How do you think we got this far without dying?~ GOTO VunargJoin2
  IF ~!CheckSkillGT(Protagonist,4,Intimidate)~ THEN REPLY ~The horde isn't as strong as it seems.  We've already gotten this far.~ GOTO VunargJoinFailed
END

IF ~~ THEN BEGIN VunargJoinFailed
  SAY ~You must be deluded, or at least foolishly brave.  But I doubt you can stop Guthma, and I'm not going to risk my life helping a half-witted townie fight for a dying cause.~
  IF ~~ THEN REPLY #13961 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #13983 GOTO 7
END

IF ~~ THEN BEGIN VunargJoin2
  SAY ~And you expect me to help you fight the horde when you're already hopelessly outnumbered?~
  IF ~~ THEN REPLY ~It's true that we're outnumbered.  But we're a lot *less* outnumbered than we were when we got here.~ GOTO VunargJoin3
  IF ~~ THEN REPLY ~Yes.  Would you rather fight us instead?  Because a lot of other goblins already made that mistake.~ GOTO VunargJoin3
END

IF ~~ THEN BEGIN VunargJoin3
  SAY ~What exactly are you offering me?  What happens if you manage to kill Guthma?~
  IF ~~ THEN REPLY ~You join the fight, you get a share of the gold.  Simple as that.~ GOTO VunargJoin4
END

IF ~~ THEN BEGIN VunargJoin4
  SAY ~What's to stop you from killing me after Guthma is dead?  Isn't Targos committed to killing every goblin in sight?~
  IF ~~ THEN REPLY ~Why kill an ally right after he's proven his worth to the group?  Why kill a goblin who's fighting on our side?~ GOTO VunargJoin5
  IF ~~ THEN REPLY ~We could carry you on a gilded palanquin into the streets of Targos shouting praises to your name and all goblinkind, and no one could dare tell us we were wrong to do it.  We're the heroes of Targos -- we saved the entire town from goblins, twice.  Who's going to question our judgment?~ GOTO VunargJoin5
  IF ~~ THEN REPLY ~Lord Ulbrec never said we *couldn't* make friends with goblins.~ GOTO VunargJoin5
END

IF ~~ THEN BEGIN VunargJoin5
  SAY ~Let me speak with my clan about this...~
  IF ~~ THEN DO ~FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)~ GOTO VunargJoin6
END

IF ~~ THEN BEGIN VunargJoin6
  SAY ~My clan is against it.  They have no interest in fighting to defend a human city.  However, I'm willing to help you take the fight to Guthma, for a share of the loot.  I know the horde is wealthy, and bringing back some of that gold will make my clan far stronger.~
  IF ~~ THEN REPLY ~One goblin is good enough.  Welcome to the team, Vunarg.~ GOTO VunargJoin7
  IF ~~ THEN REPLY ~I like your attitude.  Let's go kill some orcs.~ GOTO VunargJoin7
  IF ~~ THEN REPLY ~I don't like the idea of aiding a goblin clan, but the help is worth the price.~ GOTO VunargJoin7
END

IF ~~ THEN BEGIN VunargJoin7
  SAY ~We should be careful.  There's a trap under an archway leading to some tunnels higher up, and that area is much more heavily populated.  There aren't just goblins and orcs; they have ogres and trolls and orogs and even some spellcasters, as well as an otyugh, though that last one's locked up in a cage.  We can't get any farther unless we have two wardstones, one made of black stone and one of solid iron.  A hobgoblin has one; the orog chief has the other.  We need the stones to pass some wards leading upstairs.~
  IF ~~ THEN REPLY ~Good to know.~ GOTO VunargJoin8
END

IF ~~ THEN BEGIN VunargJoin8
  SAY ~Once we get up top, we'll be surrounded by orc archers, and it won't be long before the others join in.  Orcs, ice trolls, goblins, bugbears, orogs, shamans and witch doctors and goblin sorcerers, and even some hill giants with spears.  Be careful not to fall for the spellcasters' enchantments or we'll be overwhelmed.  I'm not familiar with Guthma's headquarters, but I have seen spellcasters head in and out, as well as clan leaders of every race.  Guthma himself is the largest of the bugbears, and he carries an enchanted morningstar, so we should give him a very wide berth if possible.~
  IF ~~ THEN REPLY ~I'm glad we got the warning before we ran into that.  Come on, let's go.~ DO ~JoinParty()
SetGlobal("US_Vunarg_Joined", "GLOBAL", 1)~ EXIT
END
