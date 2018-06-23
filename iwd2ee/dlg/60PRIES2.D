BEGIN ~60PRIES2~

IF ~~ THEN BEGIN 0
  SAY #32432
  IF ~~ THEN REPLY #32433 EXIT
END

IF ~~ THEN BEGIN 1
  SAY #32432
  IF ~~ THEN REPLY #32433 EXIT
END

IF ~  !Global("6051_Wearing_Robes","GLOBAL",6)
!Global("US_OJAIHA_DIPLOMACY","GLOBAL",1)
~ THEN BEGIN 2
  SAY #32434
  IF ~~ THEN REPLY #32435 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32436 DO ~Enemy()~ EXIT
END

IF ~  True()
~ THEN BEGIN 3
  SAY #32437
  IF ~  !ClassEx(Protagonist,PALADIN)
CheckStatGT(Protagonist,12,CHR)
~ THEN REPLY #32438 GOTO 5
  IF ~  !ClassEx(Protagonist,PALADIN)
CheckStatLT(Protagonist,13,CHR)
~ THEN REPLY #32439 GOTO 5
  IF ~~ THEN REPLY #32440 GOTO 4
  IF ~~ THEN REPLY #32441 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32442 EXIT
END

IF ~~ THEN BEGIN 4
  SAY #32443
  IF ~~ THEN REPLY #32435 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32436 DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 5
  SAY #32444
  IF ~  !ClassEx(Protagonist,PALADIN)
~ THEN REPLY #32465 GOTO 6
  IF ~  !ClassEx(Protagonist,PALADIN)
CheckStatGT(Protagonist,12,CHR)
~ THEN REPLY #32478 GOTO 8
  IF ~  !ClassEx(Protagonist,PALADIN)
CheckStatLT(Protagonist,13,CHR)
~ THEN REPLY #32479 GOTO 8
  IF ~~ THEN REPLY #32440 GOTO 4
  IF ~~ THEN REPLY #32441 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32480 EXIT
END

IF ~~ THEN BEGIN 6
  SAY #32481
  IF ~~ THEN REPLY #32482 GOTO 7
  IF ~  !ClassEx(Protagonist,PALADIN)
CheckStatGT(Protagonist,12,CHR)
~ THEN REPLY #32483 GOTO 8
  IF ~  !ClassEx(Protagonist,PALADIN)
CheckStatLT(Protagonist,13,CHR)
~ THEN REPLY #32479 GOTO 8
  IF ~~ THEN REPLY #32440 GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32484 GOTO 11
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32485 GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41274 GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32486 GOTO 16
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32487 GOTO 14
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32488 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32430 GOTO 18
  IF ~~ THEN REPLY #32489 GOTO 4
  IF ~~ THEN REPLY #32441 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32480 EXIT
END

IF ~~ THEN BEGIN 7
  SAY #32490
  IF ~  !ClassEx(Protagonist,PALADIN)
CheckStatGT(Protagonist,12,CHR)
~ THEN REPLY #32483 GOTO 8
  IF ~  !ClassEx(Protagonist,PALADIN)
CheckStatLT(Protagonist,13,CHR)
~ THEN REPLY #32479 GOTO 8
  IF ~~ THEN REPLY #32440 GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32484 GOTO 11
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32485 GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41274 GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32486 GOTO 16
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32487 GOTO 14
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32488 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32430 GOTO 18
  IF ~~ THEN REPLY #32489 GOTO 4
  IF ~~ THEN REPLY #32441 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32491 EXIT
END

IF ~~ THEN BEGIN 8
  SAY #32492
  IF ~~ THEN REPLY #32493 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 9
  IF ~~ THEN REPLY #32440 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32484 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 11
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32485 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41274 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32486 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 16
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32487 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 14
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32488 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)
SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32430 GOTO 18
  IF ~~ THEN REPLY #32494 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)
Enemy()~ EXIT
  IF ~~ THEN REPLY #32495 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ EXIT
END

IF ~~ THEN BEGIN 9
  SAY #32496
  IF ~  !ClassEx(Protagonist,PALADIN)
~ THEN REPLY #32497 GOTO 10
  IF ~~ THEN REPLY #32440 GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32484 GOTO 11
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32485 GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41274 GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32486 GOTO 16
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32487 GOTO 14
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32488 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32430 GOTO 18
  IF ~~ THEN REPLY #32494 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32495 EXIT
END

IF ~~ THEN BEGIN 10
  SAY #32498
  IF ~~ THEN REPLY #32499 GOTO 11
  IF ~~ THEN REPLY #32440 GOTO 4
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32485 GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41274 GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32486 GOTO 16
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32487 GOTO 14
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32488 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32430 GOTO 18
  IF ~~ THEN REPLY #32494 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32500 EXIT
END

IF ~~ THEN BEGIN 11
  SAY #32501
  IF ~~ THEN REPLY #32502 DO ~SetGlobal("60Know_Cabal", "GLOBAL", 1)~ GOTO 12
END

IF ~~ THEN BEGIN 12
  SAY #32503
  IF ~~ THEN REPLY #32440 GOTO 4
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32485 GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41274 GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32486 GOTO 16
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32487 GOTO 14
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32488 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32430 GOTO 18
  IF ~~ THEN REPLY #32494 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32505 EXIT
END

IF ~~ THEN BEGIN 13
  SAY #32506
  IF ~~ THEN REPLY #32440 GOTO 4
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32485 GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41274 GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32486 GOTO 16
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32487 GOTO 14
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32488 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32430 GOTO 18
  IF ~~ THEN REPLY #32494 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32507 EXIT
END

IF ~~ THEN BEGIN 14
  SAY #32508
  IF ~~ THEN REPLY #32509 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ JOURNAL #32431 GOTO 15
  IF ~~ THEN REPLY #32440 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32510 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 11
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32485 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41274 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32486 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 16
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32488 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)
SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32430 GOTO 18
  IF ~~ THEN REPLY #32494 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)Enemy()~ EXIT
  IF ~~ THEN REPLY #32511 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ EXIT
END

IF ~~ THEN BEGIN 15
  SAY #32512
  IF ~  !ClassEx(Protagonist,PALADIN)
~ THEN REPLY #32513 GOTO 4
  IF ~~ THEN REPLY #32440 GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32510 GOTO 11
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32485 GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41274 GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32486 GOTO 16
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32488 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32430 GOTO 18
  IF ~~ THEN REPLY #32494 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32511 EXIT
END

IF ~~ THEN BEGIN 16
  SAY #32514
  IF ~~ THEN REPLY #32515 DO ~SetGlobal("60Know_Guardian", "GLOBAL", 1)
SetGlobal("60Know_Portal_Weakness", "GLOBAL", 1)~ JOURNAL #32426 GOTO 17
  IF ~~ THEN REPLY #32440 DO ~SetGlobal("60Know_Guardian", "GLOBAL", 1)~ GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32510 DO ~SetGlobal("60Know_Guardian", "GLOBAL", 1)~ GOTO 11
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32487 DO ~SetGlobal("60Know_Guardian", "GLOBAL", 1)~ GOTO 14
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41274 DO ~SetGlobal("60Know_Guardian", "GLOBAL", 1)~ GOTO 20
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32488 DO ~SetGlobal("60Know_Guardian", "GLOBAL", 1)
SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32430 GOTO 18
  IF ~~ THEN REPLY #32494 DO ~SetGlobal("60Know_Guardian", "GLOBAL", 1)
Enemy()~ EXIT
  IF ~~ THEN REPLY #32511 DO ~SetGlobal("60Know_Guardian", "GLOBAL", 1)~ EXIT
END

IF ~~ THEN BEGIN 17
  SAY #32516
  IF ~  Global("60Know_Jez","GLOBAL",0)
~ THEN REPLY #32517 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 1)~ JOURNAL #32430 GOTO 18
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32488 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 1)~ JOURNAL #32430 GOTO 18
  IF ~~ THEN REPLY #32518 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ GOTO 19
  IF ~~ THEN REPLY #32519 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32510 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ GOTO 11
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32487 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ GOTO 14
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41274 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ GOTO 20
  IF ~~ THEN REPLY #32520 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ GOTO 4
  IF ~~ THEN REPLY #32511 DO ~SetGlobal("60Know_Guardian", "GLOBAL", 1)~ EXIT
END

IF ~~ THEN BEGIN 18
  SAY #32521
  IF ~  Global("60Know_Jez_Detour","GLOBAL",1)
~ THEN REPLY #32522 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 0)~ GOTO 19
  IF ~  Global("60Know_Jez_Detour","GLOBAL",1)
~ THEN REPLY #32519 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 0)~ GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32510 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 0)~ GOTO 11
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32485 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 0)~ GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41274 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)SetGlobal("60Know_Jez_Detour", "GLOBAL", 0)~ GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32486 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 0)~ GOTO 16
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32487 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 0)~ GOTO 14
  IF ~~ THEN REPLY #32523 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 0)
Enemy()~ EXIT
  IF ~~ THEN REPLY #32511 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 0)~ EXIT
END

IF ~~ THEN BEGIN 19
  SAY #32524
  IF ~~ THEN REPLY #32519 GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32510 GOTO 11
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32485 GOTO 16
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32487 GOTO 14
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41274 GOTO 20
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32488 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32430 GOTO 18
  IF ~~ THEN REPLY #32520 GOTO 4
  IF ~~ THEN REPLY #32511 EXIT
END

IF ~~ THEN BEGIN 20
  SAY #41263
  IF ~~ THEN REPLY #41265 JOURNAL #41241 GOTO 21
END

IF ~~ THEN BEGIN 21
  SAY #41264
  IF ~~ THEN REPLY #41266 GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #41267 GOTO 11
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #41268 GOTO 16
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #41269 GOTO 16
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #41270 GOTO 14
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #41271 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32282 GOTO 18
  IF ~~ THEN REPLY #41272 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #41273 EXIT
END
