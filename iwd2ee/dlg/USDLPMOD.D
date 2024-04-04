APPEND ~12SHAWFO~
IF WEIGHT #0 ~!Global("31bugGut_Dead","GLOBAL",1)
Global("USGUTHMA_FRIEND","GLOBAL",1)~ THEN BEGIN USShawfordGuthmaDiplomacy1
  SAY @6403
  IF ~Global("S_R_1","GLOBAL",0)
Global("S_R_2","GLOBAL",0)
Global("S_R_3","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY @6404 DO ~SetGlobal("S_R_1", "GLOBAL", 1)
SetGlobal("S_R_2", "GLOBAL", 1)
SetGlobal("S_R_3", "GLOBAL", 1)
GiveItemCreate("Misc07", Protagonist, 10000, 0, 0)~ GOTO 37
  IF ~Global("S_R_1","GLOBAL",1)
Global("S_R_2","GLOBAL",0)
Global("S_R_3","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)~ THEN REPLY @6404 DO ~SetGlobal("S_R_2", "GLOBAL", 1)
SetGlobal("S_R_3", "GLOBAL", 1)
GiveItemCreate("Misc07", Protagonist, 9000, 0, 0)~ GOTO 37
  IF ~Global("S_R_1","GLOBAL",1)
Global("S_R_2","GLOBAL",1)
Global("S_R_3","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)~ THEN REPLY @6404 DO ~SetGlobal("S_R_3", "GLOBAL", 1)
GiveItemCreate("Misc07", Protagonist, 6000, 0, 0)~ GOTO 37
  IF ~Global("S_R_1","GLOBAL",0)
Global("S_R_2","GLOBAL",0)
Global("S_R_3","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)~ THEN REPLY @6405 DO ~SetGlobal("S_R_1", "GLOBAL", 1)
SetGlobal("S_R_2", "GLOBAL", 1)
SetGlobal("S_R_3", "GLOBAL", 1)
GiveItemCreate("Misc07", Protagonist, 10000, 0, 0)~ GOTO 37
  IF ~Global("S_R_1","GLOBAL",1)
Global("S_R_2","GLOBAL",0)
Global("S_R_3","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)~ THEN REPLY @6405 DO ~SetGlobal("S_R_2", "GLOBAL", 1)
SetGlobal("S_R_3", "GLOBAL", 1)
GiveItemCreate("Misc07", Protagonist, 9000, 0, 0)~ GOTO 37
  IF ~Global("S_R_1","GLOBAL",1)
Global("S_R_2","GLOBAL",1)
Global("S_R_3","GLOBAL",0)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)~ THEN REPLY @6405 DO ~SetGlobal("S_R_3", "GLOBAL", 1)
GiveItemCreate("Misc07", Protagonist, 6000, 0, 0)~ GOTO 37
  IF ~~ THEN REPLY #36715 EXIT
END
END