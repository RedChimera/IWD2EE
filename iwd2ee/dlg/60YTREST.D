BEGIN ~60YTREST~

IF WEIGHT #1 ~  NumberOfTimesTalkedTo(0)
RandomNum(4,1)
~ THEN BEGIN 0
  SAY #33019
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #33020 GOTO 11
  IF ~~ THEN REPLY #33021 GOTO 4
  IF ~~ THEN REPLY #33022 GOTO 5
  IF ~~ THEN REPLY #33023 GOTO 6
  IF ~~ THEN REPLY #33024 GOTO 7
  IF ~~ THEN REPLY #33025 GOTO 8
  IF ~~ THEN REPLY #33026 EXIT
END

IF WEIGHT #2 ~  NumberOfTimesTalkedTo(0)
RandomNum(4,2)
~ THEN BEGIN 1
  SAY #33027
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #33020 GOTO 11
  IF ~~ THEN REPLY #33021 GOTO 4
  IF ~~ THEN REPLY #33022 GOTO 5
  IF ~~ THEN REPLY #33023 GOTO 6
  IF ~~ THEN REPLY #33024 GOTO 7
  IF ~~ THEN REPLY #33025 GOTO 8
  IF ~~ THEN REPLY #33026 EXIT
END

IF WEIGHT #3 ~  NumberOfTimesTalkedTo(0)
RandomNum(4,3)
~ THEN BEGIN 2
  SAY #33028
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #33020 GOTO 11
  IF ~~ THEN REPLY #33021 GOTO 4
  IF ~~ THEN REPLY #33022 GOTO 5
  IF ~~ THEN REPLY #33023 GOTO 6
  IF ~~ THEN REPLY #33024 GOTO 7
  IF ~~ THEN REPLY #33025 GOTO 8
  IF ~~ THEN REPLY #33026 EXIT
END

IF WEIGHT #4 ~  NumberOfTimesTalkedTo(0)
RandomNum(4,4)
~ THEN BEGIN 3
  SAY #33029
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #33020 GOTO 11
  IF ~~ THEN REPLY #33021 GOTO 4
  IF ~~ THEN REPLY #33022 GOTO 5
  IF ~~ THEN REPLY #33023 GOTO 6
  IF ~~ THEN REPLY #33024 GOTO 7
  IF ~~ THEN REPLY #33025 GOTO 8
  IF ~~ THEN REPLY #33026 EXIT
END

IF ~~ THEN BEGIN 4
  SAY #33030
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #33020 GOTO 11
  IF ~~ THEN REPLY #33022 GOTO 5
  IF ~~ THEN REPLY #33023 GOTO 6
  IF ~~ THEN REPLY #33024 GOTO 7
  IF ~~ THEN REPLY #33025 GOTO 8
  IF ~~ THEN REPLY #33026 EXIT
END

IF ~~ THEN BEGIN 5
  SAY #33031
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #33020 GOTO 11
  IF ~~ THEN REPLY #33021 GOTO 4
  IF ~~ THEN REPLY #33023 GOTO 6
  IF ~~ THEN REPLY #33024 GOTO 7
  IF ~~ THEN REPLY #33025 GOTO 8
  IF ~~ THEN REPLY #33026 EXIT
END

IF ~~ THEN BEGIN 6
  SAY #33032
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #33020 GOTO 11
  IF ~~ THEN REPLY #33021 GOTO 4
  IF ~~ THEN REPLY #33022 GOTO 5
  IF ~~ THEN REPLY #33024 GOTO 7
  IF ~~ THEN REPLY #33025 GOTO 8
  IF ~~ THEN REPLY #33026 EXIT
END

IF ~~ THEN BEGIN 7
  SAY #41232
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #33020 GOTO 11
  IF ~~ THEN REPLY #33021 GOTO 4
  IF ~~ THEN REPLY #33022 GOTO 5
  IF ~~ THEN REPLY #33023 GOTO 6
  IF ~~ THEN REPLY #33025 GOTO 8
  IF ~~ THEN REPLY #33026 EXIT
END

IF ~~ THEN BEGIN 8
  SAY #41233
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #33020 GOTO 11
  IF ~~ THEN REPLY #33021 GOTO 4
  IF ~~ THEN REPLY #33022 GOTO 5
  IF ~~ THEN REPLY #33023 GOTO 6
  IF ~~ THEN REPLY #33024 GOTO 7
  IF ~~ THEN REPLY #33026 EXIT
END

IF WEIGHT #5 ~  NumTimesTalkedToGT(0)
~ THEN BEGIN 9
  SAY #41234
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #33020 GOTO 11
  IF ~~ THEN REPLY #33021 GOTO 4
  IF ~~ THEN REPLY #33022 GOTO 5
  IF ~~ THEN REPLY #33023 GOTO 6
  IF ~~ THEN REPLY #33024 GOTO 7
  IF ~~ THEN REPLY #33025 GOTO 8
  IF ~~ THEN REPLY #33026 EXIT
END

IF WEIGHT #0 ~  !Global("6051_Wearing_Robes","GLOBAL",6)
!Global("US_OJAIHA_DIPLOMACY","GLOBAL",1)
~ THEN BEGIN 10
  SAY #41235
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 11
  SAY #41237
  IF ~~ THEN REPLY #33021 GOTO 4
  IF ~~ THEN REPLY #33022 GOTO 5
  IF ~~ THEN REPLY #33023 GOTO 6
  IF ~~ THEN REPLY #33024 GOTO 7
  IF ~~ THEN REPLY #33025 GOTO 8
  IF ~~ THEN REPLY #33026 EXIT
END
