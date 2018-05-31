BEGIN ~53ELDER~

IF ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY #22279
  IF ~~ THEN REPLY #22280 GOTO 1
  IF ~~ THEN REPLY #22284 GOTO 4
  IF ~  Alignment(Protagonist,MASK_GOOD)
~ THEN REPLY #22281 DO ~Enemy()~ JOURNAL #22278 GOTO 2
  IF ~  Or(2)
ClassEx(Protagonist,DRUID)
ClassEx(Protagonist,RANGER)
~ THEN REPLY #22282 DO ~Enemy()~ JOURNAL #22278 GOTO 3
  IF ~~ THEN REPLY #22285 DO ~Enemy()~ JOURNAL #22278 GOTO 5
END

IF ~~ THEN BEGIN 1
  SAY #22286
  IF ~~ THEN REPLY #22284 GOTO 4
  IF ~  Alignment(Protagonist,MASK_GOOD)
~ THEN REPLY #22281 DO ~Enemy()~ JOURNAL #22278 GOTO 2
  IF ~  Or(2)
ClassEx(Protagonist,DRUID)
ClassEx(Protagonist,RANGER)
~ THEN REPLY #22282 DO ~Enemy()~ JOURNAL #22278 GOTO 3
  IF ~~ THEN REPLY #22285 DO ~Enemy()~ JOURNAL #22278 GOTO 5
END

IF ~~ THEN BEGIN 2
  SAY #22287
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 3
  SAY #22289
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 4
  SAY ~-- We find that difficult to accept.  Whether you came here seeking trouble or not, you have found it.  Farewell, humans. --~
  IF ~  CheckSkillLT(Protagonist,12,Intimidate)
~ THEN DO ~Enemy()~ JOURNAL #22278 EXIT
  IF ~  CheckSkillGT(Protagonist,11,Intimidate)
~ THEN REPLY #422 DO ~SetGlobal("53ElderB_Permission", "GLOBAL", 1)~ GOTO 10
  IF ~  CheckSkillGT(Protagonist,11,Intimidate)
~ THEN REPLY #38552 DO ~Enemy()~ JOURNAL #22278 EXIT
END

IF ~~ THEN BEGIN 5
  SAY #22291
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 6
  SAY #22292
  IF ~~ THEN EXTERN ~53ABDOSH~ 1
END

IF ~~ THEN BEGIN 7
  SAY #22298
  IF ~~ THEN EXTERN ~53ABDOSH~ 2
END

IF ~~ THEN BEGIN 8
  SAY #22299
  IF ~~ THEN EXTERN ~53ZEPH~ 2
END

IF ~  True()
~ THEN BEGIN 9
  SAY #38551
  IF ~~ THEN DO ~Enemy()~ JOURNAL #22278 EXIT
END

IF ~~ THEN BEGIN 10
  SAY ~ -- It would be unnecessary to waste effort removing a pest that would just as soon leave on its own. The gates you seek lie to the northeast.  Go there *now* - do not tarry or wander about our citadel - and do not return.  --~
  IF ~~ THEN EXIT
END
