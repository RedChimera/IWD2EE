BEGIN ~50THVARA~

IF ~  True()
~ THEN BEGIN 0
  SAY #6573
  IF ~!GlobalGT("USIWGIVEXP","GLOBAL",0)~ THEN EXTERN ~50GNTFO~ 0
  IF ~GlobalGT("USIWGIVEXP","GLOBAL",0)~ THEN EXTERN ~50GNTFO~ 1
END

IF ~~ THEN BEGIN 1
  SAY ~Shut up, you lumbering cretin. Is this true, adventurer? Has the glacier fallen?~
  IF ~  Or(2)
ClassEx(Protagonist,PALADIN)
ClassEx(Protagonist,CLERIC)
~ THEN REPLY #37455 GOTO 2CannotLie
  IF ~  ClassEx(Protagonist,CLERIC)
Alignment(Protagonist,MASK_EVIL)
~ THEN REPLY #37456 GOTO 2CannotLie
  IF ~~ THEN REPLY #6580 GOTO 2CanLie
  IF ~  !Alignment(Protagonist,MASK_LAWFUL)
~ THEN REPLY #6581 GOTO 2CanLie
  IF ~  !ClassEx(Protagonist,PALADIN)
~ THEN REPLY #6582 EXTERN ~50GNTFO~ 4
  IF ~  !ClassEx(Protagonist,PALADIN)
~ THEN REPLY #6583 EXTERN ~50GNTFO~ 4
END

IF ~~ THEN BEGIN 2CanLie
  SAY #6584 //cathin sends me away, about to fight
  IF ~  Or(2)
ClassEx(Protagonist,PALADIN)
ClassEx(Protagonist,CLERIC)
~ THEN REPLY #37457 EXTERN ~50GNTFO~ 2
  IF ~CheckSkillGT(Protagonist,7,Bluff)~ THEN REPLY ~Wait, wait! We're not responsible for the glacier falling!~ EXTERN ~50GNTFO~ 5
  IF ~  ClassEx(Protagonist,CLERIC)
Alignment(Protagonist,MASK_EVIL)
~ THEN REPLY #37458 EXTERN ~50GNTFO~ 2
  IF ~~ THEN REPLY #6585 JOURNAL #6572 GOTO 3  ///////////
  IF ~~ THEN REPLY #6586 JOURNAL #6572 GOTO 3  ///////////
  IF ~~ THEN REPLY #6587 JOURNAL #6572 EXTERN ~50GNTFO~ 2
END

IF ~~ THEN BEGIN 2CannotLie
  SAY #6584 //cathin sends me away, about to fight
  IF ~  Or(2)
ClassEx(Protagonist,PALADIN)
ClassEx(Protagonist,CLERIC)
~ THEN REPLY #37457 EXTERN ~50GNTFO~ 2
  IF ~  ClassEx(Protagonist,CLERIC)
Alignment(Protagonist,MASK_EVIL)
~ THEN REPLY #37458 EXTERN ~50GNTFO~ 2
  IF ~~ THEN REPLY #6585 JOURNAL #6572 GOTO 3  ///////////
  IF ~~ THEN REPLY #6586 JOURNAL #6572 GOTO 3  ///////////
  IF ~~ THEN REPLY #6587 JOURNAL #6572 EXTERN ~50GNTFO~ 2
END

IF ~~ THEN BEGIN 3
  SAY #6588
  IF ~~ THEN EXTERN ~50GNTFO~ 2
END

IF ~~ THEN BEGIN 4
  SAY #6589
  IF ~  CheckSkillLT(Protagonist,8,Intimidate)
~ THEN DO ~Enemy()~ EXIT
  IF ~  CheckSkillGT(Protagonist,7,Intimidate)
~ THEN REPLY #37851 DO ~Enemy()~ EXTERN ~50GNTFO~ 3
  IF ~  CheckSkillGT(Protagonist,7,Intimidate)
~ THEN REPLY #37852 DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 5
  SAY ~I heard you, Brogrob. You need not tell me twice.~
  IF ~~ THEN REPLY ~Your giant is confusing us with our employers.  We're just here to carry supplies and cook meals and clean.  The heroes of Targos hired us to help them get through the Western pass.~ GOTO 6
END

IF ~~ THEN BEGIN 6
  SAY ~The "heroes of Targos?"~
  IF ~~ THEN REPLY ~They're the ones who saved Targos from the goblin hordes.  It's an incredible honor to work for them.  They came in on a boat from Luskan, fought off the goblin invasion, fought off *another* invasion, and then took the fight to the horde's own fortress!  If it weren't for them, we'd all be dead.~ GOTO 7
END

IF ~~ THEN BEGIN 7
  SAY ~If the "heroes of Targos" are your employers, why aren't you *with* them?~
  IF ~~ THEN REPLY ~We ran ahead to get away from the fighting.  When the ice wall collapsed, a bunch of Aurilite priests ran in to attack them.  It's amazing to see them fight--they were just butchering those Aurilites.  They were... wait.  Are you one of them?  Are *you* one of the Aurilites?~ GOTO 8
END

IF ~~ THEN BEGIN 8
  SAY ~What do you mean, "butchering" them?  What's happening at the wall?!~
  IF ~~ THEN REPLY ~I-I don't know!  I'm just h-here to carry b-bags!~ GOTO 9
END

IF ~~ THEN BEGIN 9
  SAY ~Damn it!  Get out of my way!  Everyone, hurry--we don't have much time!~
  IF ~~ THEN REPLY ~~ DO ~AddExperienceParty(2500) SetGlobal("BLFFTHV","GLOBAL",1)~ EXIT
END

