BEGIN ~61IZBELA~

IF ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY ~Intruders, you are trespassing on this ground. Turn back or die!~
  IF ~~ THEN REPLY ~Who are you?~ GOTO 2
END

IF ~  NumTimesTalkedToGT(0)
~ THEN BEGIN 1
  SAY #25725
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 2
  SAY ~I am High Sorceress Izbelah, but that is neither here nor there. I have important business to attend to. I am in the middle of preparing a ritual and I can suffer no interruptions.~
  IF ~~ THEN REPLY ~Ritual? What kind of ritual?~ GOTO 3
END

IF ~~ THEN BEGIN 3
  SAY ~A ritual that must twist the very fabric of time itself. A ritual you warm-blood primates would never understand. Now leave!~
  IF ~~ THEN EXIT
END
