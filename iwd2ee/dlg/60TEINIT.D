BEGIN ~60TEINIT~

IF WEIGHT #1 ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY #33122
  IF ~~ THEN REPLY #33123 GOTO 1
  IF ~~ THEN REPLY #33124 DO ~SetGlobal("60Know_Cabal", "GLOBAL", 1)~ GOTO 2
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #33125 GOTO 11
  IF ~~ THEN REPLY #33126 GOTO 3
  IF ~~ THEN REPLY #33127 EXIT
END

IF ~~ THEN BEGIN 1
  SAY #33128
  IF ~  !Global("60Know_Black_Flower","GLOBAL",1)
CheckStatGT(Protagonist,11,INT)
~ THEN REPLY #33129 DO ~SetGlobal("60Know_Black_Flower","GLOBAL",1)~ GOTO 4
  IF ~~ THEN REPLY #33130 GOTO 5
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #33131 GOTO 11
  IF ~~ THEN REPLY #33132 GOTO 6
  IF ~~ THEN REPLY #33133 EXIT
END

IF ~~ THEN BEGIN 2
  SAY #33134
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #33135 GOTO 11
  IF ~~ THEN REPLY #33136 GOTO 7
  IF ~~ THEN REPLY #33139 GOTO 8
  IF ~~ THEN REPLY #33132 GOTO 6
  IF ~~ THEN REPLY #33133 EXIT
END

IF ~~ THEN BEGIN 3
  SAY #33140
  IF ~~ THEN REPLY #33141 DO ~SetGlobal("60Know_Cabal", "GLOBAL", 1)~ GOTO 2
  IF ~~ THEN REPLY #33127 EXIT
END

IF ~~ THEN BEGIN 4
  SAY #33142
  IF ~~ THEN REPLY #33141 DO ~SetGlobal("60Know_Cabal", "GLOBAL", 1)~ GOTO 2
  IF ~~ THEN REPLY #33130 GOTO 5
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #33131 GOTO 11
  IF ~~ THEN REPLY #33126 GOTO 3
  IF ~~ THEN REPLY #33127 EXIT
END

IF ~~ THEN BEGIN 5
  SAY #33143
  IF ~  !Global("60Know_Black_Flower","GLOBAL",1)
CheckStatGT(Protagonist,11,INT)
~ THEN REPLY #33129 DO ~SetGlobal("60Know_Black_Flower","GLOBAL",1)~ GOTO 4
  IF ~~ THEN REPLY #33141 DO ~SetGlobal("60Know_Cabal", "GLOBAL", 1)~ GOTO 2
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #33131 GOTO 11
  IF ~~ THEN REPLY #33126 GOTO 3
  IF ~~ THEN REPLY #33133 EXIT
END

IF ~~ THEN BEGIN 6
  SAY #33144
  IF ~~ THEN REPLY #33141 DO ~SetGlobal("60Know_Cabal", "GLOBAL", 1)~ GOTO 2
  IF ~  !Global("60Know_Black_Flower","GLOBAL",1)
CheckStatGT(Protagonist,11,INT)
~ THEN REPLY #33129 DO ~SetGlobal("60Know_Black_Flower","GLOBAL",1)~ GOTO 4
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #33131 GOTO 11
  IF ~~ THEN REPLY #33126 GOTO 3
  IF ~~ THEN REPLY #33127 EXIT
END

IF ~~ THEN BEGIN 7
  SAY #33145
  IF ~  !Global("60Know_Black_Flower","GLOBAL",1)
CheckStatGT(Protagonist,11,INT)
~ THEN REPLY #33129 DO ~SetGlobal("60Know_Black_Flower","GLOBAL",1)~ GOTO 4
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #33131 GOTO 11
  IF ~~ THEN REPLY #33126 GOTO 3
  IF ~~ THEN REPLY #33133 EXIT
END

IF ~~ THEN BEGIN 8
  SAY #33148
  IF ~~ THEN REPLY #33136 GOTO 7
  IF ~  !Global("60Know_Black_Flower","GLOBAL",1)
CheckStatGT(Protagonist,11,INT)
~ THEN REPLY #33129 DO ~SetGlobal("60Know_Black_Flower","GLOBAL",1)~ GOTO 4
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #33131 GOTO 11
  IF ~~ THEN REPLY #33132 GOTO 6
  IF ~~ THEN REPLY #33133 EXIT
END

IF WEIGHT #2 ~  NumTimesTalkedToGT(0)
~ THEN BEGIN 9
  SAY #41294
  IF ~~ THEN REPLY #41295 GOTO 1
  IF ~~ THEN REPLY #33141 DO ~SetGlobal("60Know_Cabal", "GLOBAL", 1)~ GOTO 2
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #33135 GOTO 11
  IF ~~ THEN REPLY #33126 GOTO 3
  IF ~~ THEN REPLY #33127 EXIT
END

IF WEIGHT #0 ~  !Global("6051_Wearing_Robes","GLOBAL",6)
!Global("US_OJAIHA_DIPLOMACY","GLOBAL",1)
~ THEN BEGIN 10
  SAY #41296
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 11
  SAY #41298
  IF ~~ THEN REPLY #41299 DO ~SetGlobal("60Know_Cabal", "GLOBAL", 1)~ GOTO 2
  IF ~~ THEN REPLY #33126 GOTO 3
  IF ~~ THEN REPLY #41300 GOTO 6
  IF ~~ THEN REPLY #41301 EXIT
END
