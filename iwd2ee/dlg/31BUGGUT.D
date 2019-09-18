BEGIN ~31BUGGUT~

IF ~~ THEN BEGIN 0
  SAY #16988
  IF ~~ THEN EXTERN ~31SHERIN~ 1
END

IF ~~ THEN BEGIN 1
  SAY #16990
  IF ~~ THEN EXTERN ~31SHERIN~ 2
END

IF ~~ THEN BEGIN 2
  SAY #16991
  IF ~~ THEN EXTERN ~31SHERIN~ 3
END

IF ~~ THEN BEGIN 3
  SAY #16992
  IF ~~ THEN EXTERN ~31SHERIN~ 4
END

IF ~~ THEN BEGIN 4
  SAY #16993
  IF ~~ THEN EXTERN ~31SHERIN~ 5
END

IF ~  True()
~ THEN BEGIN 5
  SAY #16994
  IF ~~ THEN REPLY #17000 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #17001 GOTO 6
  IF ~~ THEN REPLY #17002 GOTO 8
END

IF ~~ THEN BEGIN 6
  SAY #17003
  IF ~~ THEN REPLY #17004 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #17005 GOTO 7
  IF ~~ THEN REPLY #17006 GOTO 9
  IF ~CheckSkillGT(Protagonist,8,Diplomacy)~ THEN REPLY ~And the Legion of the Chimera is next, correct?~ GOTO DiplomacyGuthma
END

IF ~~ THEN BEGIN 7
  SAY #17007
  IF ~~ THEN REPLY #17009 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #17010 GOTO 8
  IF ~~ THEN REPLY #17011 GOTO 10
END

IF ~~ THEN BEGIN 8
  SAY #17012
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 9
  SAY #17013
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 10
  SAY #17014
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN DiplomacyGuthma
  SAY ~WHAT? What did you hear?~
  IF ~~ THEN REPLY ~I heard you saying you planned on wiping out the Legion of the Chimera after Targos. That half-dragon woman from the Legion considers herself your superior?~ GOTO DiplomacyGuthma2
END

IF ~~ THEN BEGIN DiplomacyGuthma2
  SAY ~Sherincal dares to give ME orders! I am the leader of this horde! Why shouldn't I destroy them? What does this alliance do for my clan? The Legion makes demands and offers promises, but WE are the ones taking all the risks!~
  IF ~~ THEN REPLY ~Hm. We came here to kill the leader of the Legion. I thought that was you, but apparently Sherincal is our target.~ GOTO DiplomacyGuthma3
END

IF ~~ THEN BEGIN DiplomacyGuthma3
  SAY ~It doesn't matter. You snuck past my clan and broke into my chambers. I'll stake your corpse outside the gates!~
  IF ~CheckSkillGT(Protagonist,9,Diplomacy)~ THEN REPLY ~Why not just let us hunt down Sherincal? That's all we really came for. It'll save you the trouble of killing her yourself. Besides, we can kill her without affecting your alliance with the Legion. You could weaken the Legion without them even knowing you were responsible.~ GOTO DiplomacyGuthma4
  IF ~CheckSkillLT(Protagonist,9,Diplomacy)~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN DiplomacyGuthma4
  SAY ~You invade my fortress and now you're making DEMANDS? I am the LEADER of this army!~
  IF ~CheckSkillGT(Protagonist,10,Diplomacy)~ THEN REPLY ~We already made it all the way here. Obviously we're pretty strong. Would you rather lose men trying to kill us, or have us kill Sherincal for you? Sounds like a good opportunity to me.~ GOTO DiplomacyGuthma5
  IF ~CheckSkillLT(Protagonist,10,Diplomacy)~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN DiplomacyGuthma5
  SAY ~Hm... We've already suffered many losses because of the Legion. It's about time they paid the same price.~
  IF ~CheckSkillGT(Protagonist,8,Bluff)~ THEN REPLY ~You know, you could actually take advantage of Sherincal's impatience. She's clearly itching to take responsibility for this entire effort. If she's going to try to control your army, why not tell your men to disobey her commands and set her up for failure?~ GOTO DiplomacyGuthma6
  IF ~CheckSkillLT(Protagonist,8,Bluff)~ THEN REPLY ~Why are you trying to destroy Targos in the first place? Clearly the Legion is just going to try to sweep in and rake in all of the gains before your army can profit.~ GOTO DiplomacyGuthma7Failed
END

IF ~~ THEN BEGIN DiplomacyGuthma6
  SAY ~What are you talking about?~
  IF ~~ THEN REPLY ~The Legion is clearly interested enough in Targos to dedicate its own resources to destroying it. The only reason they've been working with you is because they'd rather risk your army than their own. Let Sherincal take command. Tell your men to sabotage her plans. Then the Legion will send in its own forces, and you can destroy them after they're weakened by the fight with Targos.~ GOTO DiplomacyGuthma8
END

IF ~~ THEN BEGIN DiplomacyGuthma7Failed
  SAY ~You're suggesting I let Targos STAND? That I give up all of our progress based on the words of a Targos soldier? You think I don't know what you're doing? I AM NOT SO EASILY FOOLED!~
  IF ~~ THEN REPLY ~So be it.~ DO ~Enemy()
~ EXIT
END

IF ~~ THEN BEGIN DiplomacyGuthma8
  SAY ~And why would you suggest this? You're a soldier of Targos, aren't you?~
  IF ~~ THEN REPLY ~I'm a mercenary. I only need Targos to stand long enough for me to get paid. By the time the Legion takes Targos, I'll be rich and far away.~ GOTO DiplomacyGuthma9
END

IF ~~ THEN BEGIN DiplomacyGuthma9
  SAY ~Hah! Very well, mercenary... I'll let the Legion spend its blood and treasure taking Targos. But make no mistake, the city is doomed. Even if they fail, I WILL crush Targos.~
  IF ~~ THEN REPLY ~That's fine with me. By the way, is there a ranger named Braston here? I was hoping to bring him home.~ GOTO DiplomacyGuthma10
END

IF ~~ THEN BEGIN DiplomacyGuthma10
  SAY ~The ranger? NO! The ranger has been spying on us! We will not let a man with that information leave this place alive.~
  IF ~~ THEN REPLY ~If you're going to let the Legion do all the work, Targos doesn't actually need that information anymore. Why would Targos try to attack the fortress when they can save their energy for fighting off the Legion? Besides, I get paid extra if I bring the ranger back alive.~ GOTO DiplomacyGuthma11
END

IF ~~ THEN BEGIN DiplomacyGuthma11
  SAY ~You can go, but the ranger stays here. I'm not letting a spy escape. If you're only here for gold, you'll take your reward here and leave him.~
  IF ~!ClassEx(Protagonist,PALADIN)~ THEN REPLY ~Very well. I'll tell his wife the bad news.~ DO ~AddExperienceParty(10000)
GiveItemCreate("Misc07",Protagonist,100,0,0)
SetGlobal("USGUTHMA_FRIEND", "GLOBAL", 1)
SetGlobal("Fortress_Quest","GLOBAL",1)
~ EXIT
  IF ~~ THEN REPLY ~I'm afraid I must insist on bringing him home. His wife is waiting for him.~ GOTO DiplomacyGuthma12
END

IF ~~ THEN BEGIN DiplomacyGuthma12
  SAY ~No.~
  IF ~!ClassEx(Protagonist,PALADIN)~ THEN REPLY ~Very well. I'll tell his wife the bad news.~ DO ~AddExperienceParty(10000)
SetGlobal("USGUTHMA_FRIEND", "GLOBAL", 1)
SetGlobal("Fortress_Quest","GLOBAL",1)
~ EXIT
  IF ~~ THEN REPLY ~That's not acceptable. I cannot leave without him.~ GOTO DiplomacyGuthma13
END

IF ~~ THEN BEGIN DiplomacyGuthma13
  SAY ~Then you're not here for gold! You're here to retrieve a spy, and I WILL NOT ALLOW IT!~
  IF ~~ THEN DO ~Enemy()
~ EXIT
END
