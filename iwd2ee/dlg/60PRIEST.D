BEGIN ~60PRIEST~

IF WEIGHT #1 ~  Global("Ritual_RitualState","GLOBAL",1)
~ THEN BEGIN 0
  SAY #32528
  IF ~  !ClassEx(Protagonist,PALADIN)
~ THEN REPLY #32529 EXIT
  IF ~~ THEN REPLY #32530 GOTO 1
  IF ~~ THEN REPLY #32531 GOTO 1
  IF ~~ THEN REPLY #32532 DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 1
  SAY #32533
  IF ~~ THEN REPLY #32534 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32535 DO ~Enemy()~ EXIT
END

IF WEIGHT #0 ~  !Global("6051_Wearing_Robes","GLOBAL",6)
!Global("US_OJAIHA_DIPLOMACY","GLOBAL",1)
~ THEN BEGIN 2
  SAY #32536
  IF ~~ THEN REPLY #32534 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32535 DO ~Enemy()~ EXIT
END

IF WEIGHT #2 ~  !Global("Ritual_RitualState","GLOBAL",1)
~ THEN BEGIN 3
  SAY #32537
  IF ~  !ClassEx(Protagonist,PALADIN)
CheckStatGT(Protagonist,12,CHR)
~ THEN REPLY #32538 GOTO 5
  IF ~  !ClassEx(Protagonist,PALADIN)
CheckStatLT(Protagonist,13,CHR)
~ THEN REPLY #32539 GOTO 5
  IF ~~ THEN REPLY #32540 GOTO 4
  IF ~~ THEN REPLY #32541 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32578 EXIT
END

IF ~~ THEN BEGIN 4
  SAY #32579
  IF ~~ THEN REPLY #32534 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32535 DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 5
  SAY #32580
  IF ~  !ClassEx(Protagonist,PALADIN)
~ THEN REPLY #32581 GOTO 6
  IF ~  !ClassEx(Protagonist,PALADIN)
CheckStatGT(Protagonist,12,CHR)
~ THEN REPLY #32582 GOTO 8
  IF ~  !ClassEx(Protagonist,PALADIN)
CheckStatLT(Protagonist,13,CHR)
~ THEN REPLY #32583 GOTO 8
  IF ~~ THEN REPLY #32540 GOTO 4
  IF ~~ THEN REPLY #32541 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32584 EXIT
END

IF ~~ THEN BEGIN 6
  SAY #32585
  IF ~~ THEN REPLY #32586 GOTO 7
  IF ~  !ClassEx(Protagonist,PALADIN)
CheckStatGT(Protagonist,12,CHR)
~ THEN REPLY #32587 GOTO 8
  IF ~  !ClassEx(Protagonist,PALADIN)
CheckStatLT(Protagonist,13,CHR)
~ THEN REPLY #32583 GOTO 8
  IF ~~ THEN REPLY #32540 GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32588 GOTO 11
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32589 GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41250 GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32590 GOTO 16
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32591 GOTO 14
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32592 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32526 GOTO 18
  IF ~~ THEN REPLY #32593 GOTO 4
  IF ~~ THEN REPLY #32541 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32584 EXIT
END

IF ~~ THEN BEGIN 7
  SAY #32594
  IF ~  !ClassEx(Protagonist,PALADIN)
CheckStatGT(Protagonist,12,CHR)
~ THEN REPLY #32587 GOTO 8
  IF ~  !ClassEx(Protagonist,PALADIN)
CheckStatLT(Protagonist,13,CHR)
~ THEN REPLY #32583 GOTO 8
  IF ~~ THEN REPLY #32540 GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32588 GOTO 11
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32589 GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41251 GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32590 GOTO 16
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32591 GOTO 14
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32592 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32526 GOTO 18
  IF ~~ THEN REPLY #32593 GOTO 4
  IF ~~ THEN REPLY #32541 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32595 EXIT
END

IF ~~ THEN BEGIN 8
  SAY #32596
  IF ~~ THEN REPLY #32597 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 9
  IF ~~ THEN REPLY #32540 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32588 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 11
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32589 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41251 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32590 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 16
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32591 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 14
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32592 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)
SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32526 GOTO 18
  IF ~~ THEN REPLY #32598 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)
Enemy()~ EXIT
  IF ~~ THEN REPLY #32599 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ EXIT
END

IF ~~ THEN BEGIN 9
  SAY #32600
  IF ~  !ClassEx(Protagonist,PALADIN)
~ THEN REPLY #32601 GOTO 10
  IF ~~ THEN REPLY #32540 GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32588 GOTO 11
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32589 GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41251 GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32590 GOTO 16
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32591 GOTO 14
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32592 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32526 GOTO 18
  IF ~~ THEN REPLY #32598 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32599 EXIT
END

IF ~~ THEN BEGIN 10
  SAY #32602
  IF ~~ THEN REPLY #32603 GOTO 11
  IF ~~ THEN REPLY #32540 GOTO 4
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32589 GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41251 GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32590 GOTO 16
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32591 GOTO 14
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32592 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32526 GOTO 18
  IF ~~ THEN REPLY #32598 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32604 EXIT
END

IF ~~ THEN BEGIN 11
  SAY #32605
  IF ~~ THEN REPLY #32606 DO ~SetGlobal("60Know_Cabal", "GLOBAL", 1)~ GOTO 12
END

IF ~~ THEN BEGIN 12
  SAY #32607
  IF ~~ THEN REPLY #32540 GOTO 4
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32589 GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41251 GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32590 GOTO 16
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32591 GOTO 14
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32592 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32526 GOTO 18
  IF ~~ THEN REPLY #32598 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32609 EXIT
END

IF ~~ THEN BEGIN 13
  SAY #32610
  IF ~~ THEN REPLY #32540 GOTO 4
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32589 GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41251 GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32590 GOTO 16
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32591 GOTO 14
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32592 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32526 GOTO 18
  IF ~~ THEN REPLY #32598 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32611 EXIT
END

IF ~~ THEN BEGIN 14
  SAY #32612
  IF ~~ THEN REPLY #32613 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ JOURNAL #32527 GOTO 15
  IF ~~ THEN REPLY #32540 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32614 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 11
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32589 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41251 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32590 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ GOTO 16
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32592 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)
SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32526 GOTO 18
  IF ~~ THEN REPLY #32598 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)Enemy()~ EXIT
  IF ~~ THEN REPLY #32615 DO ~SetGlobal("60Know_Heartless", "GLOBAL", 1)~ EXIT
END

IF ~~ THEN BEGIN 15
  SAY #32616
  IF ~  !ClassEx(Protagonist,PALADIN)
~ THEN REPLY #32617 GOTO 4
  IF ~~ THEN REPLY #32540 GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32614 GOTO 11
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32589 GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41251 GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32590 GOTO 16
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32592 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32526 GOTO 18
  IF ~~ THEN REPLY #32598 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #32615 EXIT
END

IF ~~ THEN BEGIN 16
  SAY #32618
  IF ~~ THEN REPLY #32619 DO ~SetGlobal("60Know_Guardian", "GLOBAL", 1)
SetGlobal("60Know_Portal_Weakness", "GLOBAL", 1)~ JOURNAL #32525 GOTO 17
  IF ~~ THEN REPLY #32540 DO ~SetGlobal("60Know_Guardian", "GLOBAL", 1)~ GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32614 DO ~SetGlobal("60Know_Guardian", "GLOBAL", 1)~ GOTO 11
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32591 DO ~SetGlobal("60Know_Guardian", "GLOBAL", 1)~ GOTO 14
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41251 DO ~SetGlobal("60Know_Guardian", "GLOBAL", 1)~ GOTO 20
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32592 DO ~SetGlobal("60Know_Guardian", "GLOBAL", 1)
SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32526 GOTO 18
  IF ~~ THEN REPLY #32598 DO ~SetGlobal("60Know_Guardian", "GLOBAL", 1)
Enemy()~ EXIT
  IF ~~ THEN REPLY #32615 DO ~SetGlobal("60Know_Guardian", "GLOBAL", 1)~ EXIT
END

IF ~~ THEN BEGIN 17
  SAY #32620
  IF ~  Global("60Know_Jez","GLOBAL",0)
~ THEN REPLY #32621 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 1)~ JOURNAL #32526 GOTO 18
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32592 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 1)~ JOURNAL #32526 GOTO 18
  IF ~~ THEN REPLY #32622 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ GOTO 19
  IF ~~ THEN REPLY #32623 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32614 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ GOTO 11
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32591 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ GOTO 14
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41251 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ GOTO 20
  IF ~~ THEN REPLY #32624 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ GOTO 4
  IF ~~ THEN REPLY #32615 DO ~SetGlobal("60Know_Guardian", "GLOBAL", 1)~ EXIT
END

IF ~~ THEN BEGIN 18
  SAY #32625
  IF ~  Global("60Know_Jez_Detour","GLOBAL",1)
~ THEN REPLY #32626 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 0)~ GOTO 19
  IF ~  Global("60Know_Jez_Detour","GLOBAL",1)
~ THEN REPLY #32623 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 0)~ GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32614 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 0)~ GOTO 11
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32589 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 0)~ GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41251 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)SetGlobal("60Know_Jez_Detour", "GLOBAL", 0)~ GOTO 20
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #32590 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 0)~ GOTO 16
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32591 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 0)~ GOTO 14
  IF ~~ THEN REPLY #32627 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 0)
Enemy()~ EXIT
  IF ~~ THEN REPLY #32615 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)
SetGlobal("60Know_Jez_Detour", "GLOBAL", 0)~ EXIT
END

IF ~~ THEN BEGIN 19
  SAY #32628
  IF ~~ THEN REPLY #32623 GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #32614 GOTO 11
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #32589 GOTO 16
  IF ~  Global("60Seen_Treasury_Door","GLOBAL",1)
~ THEN REPLY #41251 GOTO 20
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #32591 GOTO 14
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #32592 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32526 GOTO 18
  IF ~~ THEN REPLY #32624 GOTO 4
  IF ~~ THEN REPLY #32615 EXIT
END

IF ~~ THEN BEGIN 20
  SAY #41238
  IF ~~ THEN REPLY #41240 JOURNAL #41241 GOTO 21
END

IF ~~ THEN BEGIN 21
  SAY #41239
  IF ~~ THEN REPLY #41242 GOTO 4
  IF ~  Global("60Know_Cabal","GLOBAL",1)
~ THEN REPLY #41243 GOTO 11
  IF ~  Global("60Know_Guardian","GLOBAL",0)
~ THEN REPLY #41244 GOTO 16
  IF ~  Global("60Know_Guardian","GLOBAL",1)
~ THEN REPLY #41245 GOTO 16
  IF ~  Global("60Know_Heartless","GLOBAL",1)
~ THEN REPLY #41246 GOTO 14
  IF ~  Global("60Know_Jez","GLOBAL",1)
~ THEN REPLY #41247 DO ~SetGlobal("60Know_Jez", "GLOBAL", 1)~ JOURNAL #32282 GOTO 18
  IF ~~ THEN REPLY #41248 DO ~Enemy()~ EXIT
  IF ~~ THEN REPLY #41249 EXIT
END
