BEGIN ~50KURTTU~

IF WEIGHT #1 ~  NumberOfTimesTalkedTo(0)
!Race(Protagonist,ELF)
!Race(Protagonist,DWARF)
!Race(Protagonist,GNOME)
~ THEN BEGIN 0
  SAY #4741
  IF ~  Global("50Suoma_Help","Global",3)
~ THEN REPLY #4742 DO ~SetGlobal("50Kurttu_Ghost", "Global", 1)~ JOURNAL #4733 GOTO 2
  IF ~~ THEN REPLY #37932 GOTO 12
  IF ~~ THEN REPLY #4743 GOTO 6
  IF ~~ THEN REPLY #4746 EXIT
END

IF WEIGHT #2 ~  NumberOfTimesTalkedTo(0)
!Race(Protagonist,HUMAN)
!Race(Protagonist,0)
!Race(Protagonist,HALF_ELF)
!Race(Protagonist,HALFORC)
~ THEN BEGIN 1
  SAY #4747
  IF ~  Global("50Suoma_Help","Global",3)
~ THEN REPLY #4742 DO ~SetGlobal("50Kurttu_Ghost", "Global", 1)~ JOURNAL #4733 GOTO 2
  IF ~~ THEN REPLY #37932 GOTO 12
  IF ~~ THEN REPLY #4743 GOTO 6
  IF ~~ THEN REPLY #4746 EXIT
END

IF ~~ THEN BEGIN 2
  SAY #4748
  IF ~~ THEN REPLY #4750 JOURNAL #4735 GOTO 3
  IF ~~ THEN REPLY #4833 JOURNAL #4737 GOTO 4
  IF ~~ THEN REPLY #37932 GOTO 12
  IF ~~ THEN REPLY #4834 GOTO 6
  IF ~~ THEN REPLY #4836 EXIT
END

IF ~~ THEN BEGIN 3
  SAY #4838
  IF ~~ THEN REPLY #4833 JOURNAL #4737 GOTO 4
  IF ~~ THEN REPLY #37932 GOTO 12
  IF ~~ THEN REPLY #4834 GOTO 6
  IF ~~ THEN REPLY #4836 EXIT
END

IF ~~ THEN BEGIN 4
  SAY #4840
  IF ~  Global("50Leevi","Global",0)
~ THEN REPLY #4841 DO ~SetGlobal("50Leevi", "Global", 1)~ JOURNAL #4738 GOTO 5
  IF ~  GlobalGT("50Leevi","Global",0)
~ THEN REPLY #4841 GOTO 5
  IF ~~ THEN REPLY #4750 JOURNAL #4735 GOTO 3
  IF ~~ THEN REPLY #37932 GOTO 12
  IF ~~ THEN REPLY #4834 GOTO 6
  IF ~~ THEN REPLY #4836 EXIT
END

IF ~~ THEN BEGIN 5
  SAY #4850
  IF ~~ THEN REPLY #4750 JOURNAL #4735 GOTO 3
  IF ~~ THEN REPLY #4834 GOTO 6
  IF ~~ THEN REPLY #37932 GOTO 12
  IF ~~ THEN REPLY #4836 EXIT
END

IF ~~ THEN BEGIN 6
  SAY #4997
  IF ~  Global("50Suoma_Help","Global",3)
Global("50Kurttu_Ghost","Global",0)
~ THEN REPLY #4742 DO ~SetGlobal("50Kurttu_Ghost", "Global", 1)~ JOURNAL #4733 GOTO 2
  IF ~  GlobalLT("50Kyosti","GLOBAL",2)
Global("50Kurttu_Ghost","Global",1)
~ THEN REPLY #4750 JOURNAL #4735 GOTO 3
  IF ~  GlobalLT("50Kyosti","GLOBAL",2)
Global("50Kurttu_Ghost","Global",1)
~ THEN REPLY #4833 JOURNAL #4737 GOTO 4
  IF ~~ THEN REPLY #348 GOTO 12
  IF ~~ THEN REPLY #4999 EXIT
END

IF ~~ THEN BEGIN 7
  SAY #5000
  IF ~~ THEN REPLY #5001 EXIT
  IF ~~ THEN REPLY #5003 EXIT
  IF ~~ THEN REPLY #4999 EXIT
END

IF WEIGHT #3 ~  NumTimesTalkedToGT(0)
Global("50Kurttu_Ghost","GLOBAL",1)
~ THEN BEGIN 8
  SAY #5005
  IF ~  Global("50Kyosti","GLOBAL",2)
~ THEN REPLY #5006 DO ~AddXpVar("Level_9_Average",4740)
SetGlobal("50Kurttu_Ghost", "Global", 2)
SetGlobal("USKYOSTI_HARSHOM", "Global", 1) // Normally, Harshom will say Leevi and Carita gave away the party's location, if the party asks how he found them. This variable is needed to STOP him from saying that unless the party actually exposed Leevi and Carita.
SetCriticalPathObject(Myself, FALSE)~ JOURNAL #4734 GOTO 7
  IF ~  GlobalLT("50Kyosti","GLOBAL",2)
~ THEN REPLY #5007 JOURNAL #4735 GOTO 3
  IF ~  GlobalLT("50Kyosti","GLOBAL",2)
~ THEN REPLY #5008 JOURNAL #4737 GOTO 4
  IF ~~ THEN REPLY #37938 GOTO 12
  IF ~  GlobalLT("50Kyosti","GLOBAL",2)
~ THEN REPLY #5009 GOTO 6
  IF ~~ THEN REPLY #5010 EXIT
END

IF WEIGHT #4 ~  True()
~ THEN BEGIN 9
  SAY #5011
  IF ~  Global("50Suoma_Help","Global",3)
Global("50Kurttu_Ghost","Global",0)
~ THEN REPLY #4742 DO ~SetGlobal("50Kurttu_Ghost", "Global", 1)~ JOURNAL #4733 GOTO 2
  IF ~~ THEN REPLY #37932 GOTO 12
  IF ~~ THEN REPLY #4743 GOTO 6
  IF ~~ THEN REPLY #6304 EXIT
END

IF ~~ THEN BEGIN 10
  SAY #34342
  IF ~  Global("50Kurttu_Ghost","GLOBAL",0)
Global("50Suoma_Help","Global",3)
Global("50Kurttu_Ghost","Global",0)
~ THEN REPLY #4742 DO ~SetGlobal("50Kurttu_Ghost", "Global", 1)~ JOURNAL #4733 GOTO 2
  IF ~~ THEN REPLY #348 GOTO 12
  IF ~~ THEN REPLY #4999 EXIT
END

IF WEIGHT #0 ~See([ENEMY], 0)~ THEN BEGIN 11
  SAY #37856
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 12
  SAY #37930
  IF ~  GlobalGT("AR5002_Visited","Global",0)
Global("50Venla_Children","Global",1)
~ THEN REPLY #34345 GOTO 10
  IF ~  Global("50Tahvo_Wight","Global",1)
Global("50Wight_Horn","GLOBAL",0)
~ THEN REPLY #37897 GOTO 13
  IF ~  Global("50Wight_Horn","GLOBAL",1)
~ THEN REPLY #37898 GOTO 13
  IF ~  GlobalGT("AR5010_Visited","Global",0)
!Global("50Suoma_Help","Global",5)
Global("50Carynara_Help","Global",0)
~ THEN REPLY #37899 GOTO 13
  IF ~  GlobalLT("50Kyosti","GLOBAL",2)
Global("50Kurttu_Ghost","Global",1)
~ THEN REPLY #4750 JOURNAL #4735 GOTO 3
  IF ~  GlobalLT("50Kyosti","GLOBAL",2)
Global("50Kurttu_Ghost","Global",1)
~ THEN REPLY #4833 JOURNAL #4737 GOTO 4
  IF ~~ THEN REPLY #4743 GOTO 6
  IF ~  Global("50Suoma_Help","Global",3)
Global("50Kurttu_Ghost","Global",0)
~ THEN REPLY #4742 DO ~SetGlobal("50Kurttu_Ghost", "Global", 1)~ JOURNAL #4733 GOTO 2
  IF ~~ THEN REPLY #4999 EXIT
END

IF ~~ THEN BEGIN 13
  SAY #37931
  IF ~~ THEN REPLY #348 GOTO 12
  IF ~  Global("50Kurttu_Ghost","GLOBAL",0)
Global("50Suoma_Help","Global",3)
Global("50Kurttu_Ghost","Global",0)
~ THEN REPLY #4742 DO ~SetGlobal("50Kurttu_Ghost", "Global", 1)~ JOURNAL #4733 GOTO 2
  IF ~~ THEN REPLY #4999 EXIT
END
