

ADD_TRANS_TRIGGER ~12SHAWFO~ 32 ~!Global("US_Geoffrey_Convinced_To_Join","GLOBAL",1)~
EXTEND_BOTTOM ~12SHAWFO~ 32 IF ~  Global("Palisade_Iron_Collar_Quest","GLOBAL",2)
Global("Black_Geoffrey_Dead","GLOBAL",0)
Global("US_Geoffrey_Convinced_To_Join","GLOBAL",1)
~ THEN REPLY @40021 DO ~AddXpVar("Level_2_Hard",10796)
SetGlobal("Palisade_Iron_Collar_Quest", "GLOBAL", 3)
SetGlobal("IC_Good", "GLOBAL", 1)~ JOURNAL #10784 GOTO 3 END