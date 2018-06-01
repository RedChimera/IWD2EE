BEGIN ~53ABDOSH~

IF ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY #22169
  IF ~~ THEN DO ~Enemy()~ EXTERN ~53ELDER~ 6
END

IF ~~ THEN BEGIN 1
  SAY #22171
  IF ~~ THEN DO ~Enemy()~ EXTERN ~53ELDER~ 7
END

IF ~~ THEN BEGIN 2
  SAY #22172
  IF ~  CheckSkillGT(Protagonist,11,Intimidate)
~ THEN REPLY #422 DO ~SetGlobal("53ElderB_Permission", "GLOBAL", 1)~ EXTERN ~53ELDER~ 10
  IF ~~ THEN REPLY ~So be it.~ DO ~Enemy()~ EXIT
END

IF ~  NumberOfTimesTalkedToGT(0)
~ THEN BEGIN 3
  SAY ~There is nothing more to say.  Leave quickly.~
  IF ~~ EXIT
END
