BEGIN ~20NEWVRK~

IF ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY #36265
  IF ~  ClassEx(Protagonist,FIGHTER)
~ THEN REPLY #36267 GOTO 2
  IF ~  ClassEx(Protagonist,THIEF)
~ THEN REPLY #36269 GOTO 2
  IF ~  ClassEx(Protagonist,CLERIC)
~ THEN REPLY #36270 GOTO 2
  IF ~  ClassEx(Protagonist,DRUID)
~ THEN REPLY #36271 GOTO 2
  IF ~  ClassEx(Protagonist,PALADIN)
~ THEN REPLY #36272 GOTO 2
  IF ~  ClassEx(Protagonist,MAGE_ALL)
~ THEN REPLY #36268 GOTO 2
  IF ~~ THEN REPLY #36266 GOTO 1
  IF ~~ THEN REPLY #36273 GOTO 8
END

IF ~~ THEN BEGIN 1
  SAY #36274
  IF ~  Global("SR_Recover_Blade","GLOBAL",3)
~ THEN REPLY #36275 GOTO 3
  IF ~~ THEN REPLY #36276 GOTO 7
END

IF ~~ THEN BEGIN 2
  SAY #36277
  IF ~  Global("SR_Recover_Blade","GLOBAL",3)
~ THEN REPLY #36275 GOTO 3
  IF ~~ THEN REPLY #36276 GOTO 7
END

IF ~~ THEN BEGIN 3
  SAY #36278
  IF ~~ THEN REPLY #36279 DO ~AddXpVar("Level_3_Easy",36264)~ JOURNAL #36263 GOTO 4
  IF ~~ THEN REPLY #36276 GOTO 7
END

IF ~~ THEN BEGIN 4
  SAY #36280
  IF ~  Gender(Protagonist,MALE)
~ THEN REPLY #36281 GOTO 5
  IF ~  Gender(Protagonist,FEMALE)
~ THEN REPLY #36281 GOTO 6
END

IF ~~ THEN BEGIN 5
  SAY #36282
  IF ~~ THEN REPLY #36283 GOTO 7
  IF ~!ClassEx(Protagonist, Paladin)~ THEN REPLY ~That's quite clever, Vrek.  You've created your own little kingdom, set up a food supply, removed an important threat... You're a very intelligent troll.~ GOTO VrekJoin1
END

IF ~~ THEN BEGIN 6
  SAY #36284
  IF ~~ THEN REPLY #36283 GOTO 7
  IF ~!ClassEx(Protagonist, Paladin)~ THEN REPLY ~That's quite clever, Vrek.  You've created your own little kingdom, set up a food supply, removed an important threat... You're a very intelligent troll.~ GOTO VrekJoin1
END

IF ~~ THEN BEGIN 7
  SAY #36285
  IF ~~ THEN REPLY #36286 DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 8
  SAY #36287
  IF ~  ClassEx(Protagonist,FIGHTER)
~ THEN REPLY #36267 GOTO 2
  IF ~  ClassEx(Protagonist,MAGE_ALL)
~ THEN REPLY #36268 GOTO 2
  IF ~  ClassEx(Protagonist,THIEF)
~ THEN REPLY #36269 GOTO 2
  IF ~  ClassEx(Protagonist,CLERIC)
~ THEN REPLY #36270 GOTO 2
  IF ~  ClassEx(Protagonist,DRUID)
~ THEN REPLY #36271 GOTO 2
  IF ~  ClassEx(Protagonist,PALADIN)
~ THEN REPLY #36272 GOTO 2
  IF ~~ THEN REPLY #36266 GOTO 1
END

IF ~~ THEN BEGIN VrekJoin1
  SAY ~Vrek think often.  Vrek see things orc not see.  Orc not know things Vrek know.~
  IF ~~ THEN REPLY ~What do you see that the orcs don't?~ GOTO VrekJoinSee
  IF ~CheckSkillGT(Protagonist,4,Intimidate)~ THEN REPLY ~Emma isn't the only one with a magical weapon.  There are weapons like hers all across Faerun -- what if another human comes by with a magic sword?~ GOTO VrekJoinThreat
END

IF ~~ THEN BEGIN VrekJoinSee
  SAY ~Orc not have plan.  Only Vrek have plan.  Vrek put together pieces.  Now Vrek control orc and human and world.~
  IF ~~ THEN REPLY ~Not anymore, Vrek.  I'm breaking up this little "kingdom" of yours.~ GOTO 7
  IF ~!NumInParty(6)~ THEN REPLY ~The world has a lot more to offer than a few humans.  You don't have any higher ambitions?  Gold, power, an army?  An intelligent troll could do much more than this.~ GOTO VrekJoin2
  IF ~CheckSkillGT(Protagonist,4,Intimidate)~ THEN REPLY ~You don't control the whole world just yet.  Emma's sword is not the only one that can hurt you.~ GOTO VrekJoinThreat
END

IF ~~ THEN BEGIN VrekJoin2
  SAY ~Vrek not eat gold.  Vrek eat meat.  Human meat best.~
  IF ~Global("SR_Villagers_Dead","GLOBAL",1)~ THEN REPLY ~Your humans are already gone.  The orcs killed them when I intruded on the camp.~ GOTO VrekJoinHumansDead
  IF ~GlobalGT("SR_Rescue_Villagers","GLOBAL",3)~ THEN REPLY ~Your humans are already gone.  I killed their orc guards and set them free.~ GOTO VrekJoinHumansSaved
  IF ~!GlobalGT("SR_Rescue_Villagers","GLOBAL",3)
!Global("SR_Villagers_Dead","GLOBAL",1)~ THEN REPLY ~I can't let you keep doing this, Vrek.~ GOTO 7
END

IF ~~ THEN BEGIN VrekJoinHumansDead
  SAY ~Orc kill human?  You ruin plan!  Vrek has no food!~
  IF ~CheckSkillLT(Protagonist,6,Diplomacy)~ THEN REPLY ~Maybe not.  But join my group and we'll have lots of meat for you every day.~ GOTO VrekJoinFailedNoFood
  IF ~CheckSkillGT(Protagonist,5,Diplomacy)~ THEN REPLY ~Maybe not.  But join my group and we'll have lots of meat for you every day.~ GOTO VrekJoinSuccess1
END

IF ~~ THEN BEGIN VrekJoinHumansSaved
  SAY ~You take human?  You ruin plan!  Vrek has no food!~
  IF ~CheckSkillLT(Protagonist,8,Diplomacy)~ THEN REPLY ~Maybe not.  But join my group and we'll have lots of meat for you every day.~ GOTO VrekJoinFailedNoFood
  IF ~CheckSkillGT(Protagonist,7,Diplomacy)~ THEN REPLY ~Maybe not.  But join my group and we'll have lots of meat for you every day.~ GOTO VrekJoinSuccess1
END

IF ~~ THEN BEGIN VrekJoinFailedNoFood
  SAY ~Vrek no join you.  You take Vrek's food.  Vrek kill you and eat!~
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN VrekJoinThreat
  SAY ~If new human come with new magic sword, Vrek will find -- take sword, no fear.~
  IF ~~ THEN REPLY ~That's not going to happen.  I'm ending this operation.~ GOTO 7
  IF ~!NumInParty(6)
CheckSkillGT(Protagonist,5,Diplomacy)~ THEN REPLY ~What if you don't see it coming?  What if the next blade is hidden?  You need other people to help you look for them.  People like us.~ GOTO VrekJoinThreat2
END

IF ~~ THEN BEGIN VrekJoinThreat2
  SAY ~Vrek no trust human.  Human hate Vrek.~
  IF ~Race(Protagonist,Human)~ THEN REPLY ~I need help fighting the goblin horde, and I'll take whatever help I can get, even from a troll.  If you help me kill the orcs at the bridge, I'll help you look out for magic weapons like Emma's... You can even get a share of our gold.~ GOTO VrekJoinThreat3
  IF ~!Race(Protagonist,Human)~ THEN REPLY ~I'm not a human, but I need help fighting the goblin horde, and I'll take whatever help I can get, even from a troll.  If you help me kill the orcs at the bridge, I'll help you look out for magic weapons like Emma's... You can even get a share of our gold.~ GOTO VrekJoinThreat3
END

IF ~~ THEN BEGIN VrekJoinThreat3
  SAY ~Vrek not eat gold.  Vrek already have food and healer blade.~
  IF ~Global("SR_Villagers_Dead","GLOBAL",1)~ THEN REPLY ~Your humans are already gone.  The orcs killed them when I intruded on the camp.~ GOTO VrekJoinThreat3HumansDead
  IF ~GlobalGT("SR_Rescue_Villagers","GLOBAL",3)~ THEN REPLY ~Your humans are already gone.  I killed their orc guards and set them free.~ GOTO VrekJoinThreat3HumansSaved
  IF ~!GlobalGT("SR_Rescue_Villagers","GLOBAL",3)
!Global("SR_Villagers_Dead","GLOBAL",1)~ THEN REPLY ~Then there's no reasoning with you.  Your reign ends here, Vrek.~ GOTO 7
END

IF ~~ THEN BEGIN VrekJoinThreat3HumansDead
  SAY ~Orc kill human?  You ruin plan!  Vrek has no food!~
  IF ~CheckSkillLT(Protagonist,4,Diplomacy)~ THEN REPLY ~Maybe not.  But I can offer you better.  Join my group and we'll have lots of meat for you every day.~ GOTO VrekJoinFailedNoFood
  IF ~CheckSkillGT(Protagonist,3,Diplomacy)~ THEN REPLY ~Maybe not.  But I can offer you better.  Join my group and we'll have lots of meat for you every day.  I wouldn't mind a troll on the team -- in fact, an intelligent troll would be very welcome.~ GOTO VrekJoinSuccess1
END

IF ~~ THEN BEGIN VrekJoinThreat3HumansSaved
  SAY ~You take human?  You ruin plan!  Vrek has no food!~
  IF ~CheckSkillLT(Protagonist,6,Diplomacy)~ THEN REPLY ~Maybe not.  But I can offer you better.  Join my group and we'll have lots of meat for you every day.~ GOTO VrekJoinFailedNoFood
  IF ~CheckSkillGT(Protagonist,5,Diplomacy)~ THEN REPLY ~Maybe not.  But I can offer you better.  Join my group and we'll have lots of meat for you every day.  I wouldn't mind a troll on the team -- in fact, an intelligent troll would be very welcome.~ GOTO VrekJoinSuccess1
END

IF ~~ THEN BEGIN VrekJoinSuccess1
  SAY ~You have gold?  Give Vrek meat?  Keep healer sword away?~
  IF ~~ THEN REPLY ~Come with us and you can have all the food you want and more.  All you have to do is help us kill the orcs near the bridge.  They don't have magic weapons; it should be easy for a troll.~ GOTO VrekJoinSuccess2
END

IF ~~ THEN BEGIN VrekJoinSuccess2
  SAY ~Vrek... Vrek say yes.  But if human give sword to healer, Vrek kill human.~
  IF ~~ THEN REPLY ~That's good enough for me.  Come along... we have orcs to slay.~ DO ~SetGlobal("US_Vrek_Joined", "GLOBAL", 1)
SetGlobal("US_VREK_JOIN", "GLOBAL", 1)
ApplySpellRES("USVREKC",Myself)~ EXIT
END
