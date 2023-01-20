BEGIN ~50THVARA~

IF ~Global("US_Bluff_Thvara","GLOBAL",0)
~ THEN BEGIN 0
  SAY #6573
  IF ~!GlobalGT("USIWGIVEXP","GLOBAL",0)~ THEN EXTERN ~50GNTFO~ 0
  IF ~GlobalGT("USIWGIVEXP","GLOBAL",0)~ THEN EXTERN ~50GNTFO~ 1
END

IF ~~ THEN BEGIN 1
  SAY @6148
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
  IF ~CheckSkillGT(Protagonist,7,Bluff)~ THEN REPLY @6149 EXTERN ~50GNTFO~ 5
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
  SAY @6150
  IF ~~ THEN REPLY @6151 GOTO 6
END

IF ~~ THEN BEGIN 6
  SAY @6152
  IF ~~ THEN REPLY @6153 GOTO 7
END

IF ~~ THEN BEGIN 7
  SAY @6154
  IF ~~ THEN REPLY @6155 GOTO 8
END

IF ~~ THEN BEGIN 8
  SAY @6156
  IF ~~ THEN REPLY @6157 GOTO 9
END

IF ~~ THEN BEGIN 9
  SAY @6158
  IF ~~ THEN DO ~AddExperienceParty(2500) SetGlobal("US_Bluff_Thvara","GLOBAL",1)~ EXIT
END

