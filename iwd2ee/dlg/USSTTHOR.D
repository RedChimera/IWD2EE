BEGIN ~USSTTHOR~

IF WEIGHT #0 ~  NumTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY ~You finally arrive. No matter. Izbelah might have failed, but I shall not.~
  IF ~~ THEN REPLY ~Who are you?~ GOTO 1
END

IF ~~ THEN BEGIN 1
  SAY ~I? I am Thorasskus, High Priest of the Great Serpent. I am your death. You should not have come here, adventurer--I will not sssuffer anyone to interfere with Izbelah's work.~
  IF ~~ THEN REPLY ~I'm not here to interfere with anyone's work--I don't care what you yuan-ti are up to. I'm just trying to get to the Fields of Slaughter.~ GOTO 5
  IF ~~ THEN REPLY ~Work? What work?~ GOTO 2
  IF ~~ THEN REPLY ~You're not the first to stand in my way. You'll die like all the others.~ DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 2
  SAY ~Sssaving our people. Mere days ago, I received a vision from Sseth warning me of a volcanic eruption that would consssume all of Dragon's Eye. Izbelah has designed a Temporal Stasis ssspell to halt the flow of lava and contain the eruption. She and Venomin are inssside the volcano negotiating a deal with Lord Pyros in the chamber below. I am here to deal with you.~
  IF ~~ THEN REPLY ~Wait, I'm not here to interfere with anyone's work--I'm just trying to get to the Fields of Slaughter. You snake people can do whatever you want; I'm not getting in the way.~ GOTO 5
  IF ~~ THEN REPLY ~Who is Lord Pyros?~ GOTO 3
  IF ~~ THEN REPLY ~So, if we stop Izbelah from casting the spell, we can wipe out all the yuan-ti in Dragon's Eye?~ GOTO 4
END

IF ~~ THEN BEGIN 3
  SAY ~Lord Pyros is the ruler of the lava chamber beneath Dragon's Eye. The ssspell must be cast in his domain--we need his consssent to perform it.~
  IF ~~ THEN REPLY ~That's fine with me. I don't care what you yuan-ti are up to. I'm just trying to get to the Fields of Slaughter.~ GOTO 5
  IF ~~ THEN REPLY ~So, if we stop Izbelah from casting the spell, all our enemies in Dragon's Eye go up in flames?~ GOTO 4
END

IF ~~ THEN BEGIN 4
  SAY ~Yes. If I wasn't here to stop you.~
  IF ~~ THEN REPLY ~~ DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 5
  SAY ~I find thisss difficult to believe. You are the adventurers from Targos, are you not? You're here to wipe us out. You're the ones who killed Cedra and our forces at the attack on Kuldahar.~
  IF ~~ THEN REPLY ~It's not our fault that you snakes are so easy to kill.~ GOTO 6
  IF ~CheckSkillLT(Protagonist,3,Knowledge_Arcana)
!ClassEx(Protagonist, Barbarian)~ THEN REPLY ~No. We're barbarians of Tempus, making our way south. We took shelter in Dragon's Eye because it was warm.~ GOTO 7
  IF ~CheckSkillGT(Protagonist,3,Knowledge_Arcana)
!ClassEx(Protagonist, Barbarian)~ THEN REPLY ~No. We're barbarians of Tempos, making our way south. We took shelter in Dragon's Eye because it was warm.~ GOTO 8
  IF ~CheckSkillGT(Protagonist,3,Knowledge_Arcana)
ClassEx(Protagonist, Barbarian)~ THEN REPLY ~No. We're barbarians of Tempos, making our way south. We took shelter in Dragon's Eye because it was warm.~ GOTO 8
  IF ~CheckSkillLT(Protagonist,3,Knowledge_Arcana)
ClassEx(Protagonist, Barbarian)~ THEN REPLY ~No. We're barbarians of Tempos, making our way south. We took shelter in Dragon's Eye because it was warm.~ GOTO 8
  IF ~CheckSkillGT(Protagonist,13,Bluff)~ THEN REPLY ~Kuldahar is still standing?~ GOTO 15
END

IF ~~ THEN BEGIN 6
  SAY ~You'll regret those words, warmblood!~
  IF ~~ THEN REPLY ~~ DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 7
  SAY ~The barbarians do not worship Tempus, adventurers--they worship *Tempos.* I am not falling for sssuch an obvious lie.~
  IF ~~ THEN REPLY ~~ DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 8
  SAY ~If you are barbarian nomads, why did you come ssso deep into Dragon's Eye?~
  IF ~CheckSkillGT(Protagonist,7,Wilderness_Lore)~ THEN REPLY ~Caverns this deep usually have a rare type of fungi we've been looking for. One of our number has fallen ill from a fight with a ghoul, and that fungus is the only thing that could heal him. Do you have any?~ GOTO 10
  IF ~CheckSkillLT(Protagonist,7,Wilderness_Lore)~ THEN REPLY ~It was cold near the entrance. It's warmer down here.~ GOTO 9
END

IF ~~ THEN BEGIN 9
  SAY ~I find that unlikely.~
  IF ~~ THEN REPLY ~~ DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 10
  SAY ~How did you get past Grishum?~
  IF ~~ THEN REPLY ~Who?~ GOTO 11
END

IF ~~ THEN BEGIN 11
  SAY ~High Commander Grishum. He was guarding the entrance to the lower levels.~
  IF ~~ THEN REPLY ~I assume he's dead. There are a lot of corpses higher up. So, do you have the fungus?~ GOTO 12
END

IF ~~ THEN BEGIN 12
  SAY ~Where are they now?~
  IF ~~ THEN REPLY ~I don't know. I heard iron clanking a moment ago. Maybe that was them? Do you have the fungus or not?~ GOTO 13
END

IF ~~ THEN BEGIN 13
  SAY ~They're fighting the golems? Perfect! I'll strike while they're dissstracted.~
  IF ~~ THEN REPLY ~What about the fungus? Do you have it?~ GOTO 14
END

IF ~~ THEN BEGIN 14
  SAY ~Find it in the lab on the upper level!~
  IF ~~ THEN REPLY ~~ DO ~AddExperienceParty(10000)
StartCutScene("USSTTHOR")~ EXIT
END

IF ~~ THEN BEGIN 15
  SAY ~Yes. Kuldahar pushed back our forces and the Legion's.~
  IF ~~ THEN REPLY ~Oh. That changes things.~ GOTO 16
END

IF ~~ THEN BEGIN 16
  SAY ~What are you talking about?~
  IF ~~ THEN REPLY ~I thought Kuldahar was doomed. I ran away when the fighting started, and I hoped that maybe I could sneak through here.~ GOTO 17
END

IF ~~ THEN BEGIN 17
  SAY ~Sneaking? How did you get past Grishum?~
  IF ~~ THEN REPLY ~Who?~ GOTO 18
END

IF ~~ THEN BEGIN 18
  SAY ~High Commander Grishum. He was guarding the entrance to the lower levels.~
  IF ~~ THEN REPLY ~Uh... I think he's dead? There were a lot of corpses by that big snake statue thing.~ GOTO 19
END

IF ~~ THEN BEGIN 19
  SAY ~Ssso they're already here...~
  IF ~~ THEN REPLY ~Wait, you're going to go fight the adventurers?~ GOTO 20
END

IF ~~ THEN BEGIN 20
  SAY ~What? Yes. They-~
  IF ~~ THEN REPLY ~Well, I'm not sticking around for that!~ ~AddExperienceParty(10000)~ DO ~StartCutScene("USSTTHOR")~ EXIT
END
