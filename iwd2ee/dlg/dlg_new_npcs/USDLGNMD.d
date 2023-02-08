

ADD_TRANS_TRIGGER ~12SHAWFO~ 32 ~!Global("US_Geoffrey_Convinced_To_Join","GLOBAL",1)~
EXTEND_BOTTOM ~12SHAWFO~ 32 IF ~  Global("Palisade_Iron_Collar_Quest","GLOBAL",2)
Global("Black_Geoffrey_Dead","GLOBAL",0)
Global("US_Geoffrey_Convinced_To_Join","GLOBAL",1)
~ THEN REPLY @40021 DO ~AddXpVar("Level_2_Hard",10796)
SetGlobal("Palisade_Iron_Collar_Quest", "GLOBAL", 3)
SetGlobal("IC_Good", "GLOBAL", 1)~ JOURNAL #10784 GOTO 3 END

ADD_TRANS_TRIGGER ~30ENNELI~ 6 ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVEIR)")~
EXTEND_BOTTOM ~30ENNELI~ 6 IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVEIR)")~
 THEN EXTERN ~USVEIRJ~ 14 END
 
EXTEND_BOTTOM ~30GOBPON~ 12 IF ~Global("US_Promise_Vrek_Eat_Pondmuk","GLOBAL",1)~
 THEN REPLY @40735 EXTERN ~USVREKJ~ 9 END
 
ADD_TRANS_TRIGGER ~50HADBRU~ 2 ~Or(2)
  !Global("INTERJECTUSXHAAJ1","GLOBAL",0)
  !IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USXHAA)")~
INTERJECT_COPY_TRANS2 ~50HADBRU~ 2 ~INTERJECTUSXHAAJ1~ 
 == ~USXHAAJ~ IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USXHAA)")~
 THEN @40883 END