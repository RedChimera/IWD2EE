
 ADD_TRANS_TRIGGER ~11KOLUHM~ 17 ~Or(2)
  !Global("INTERJECTUSVEIRJ1","GLOBAL",0)
  !IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVEIR)")~
INTERJECT_COPY_TRANS2 ~11KOLUHM~ 17 ~INTERJECTUSVEIRJ1~ 
 == ~11KOLUHM~ IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVEIR)")~
 THEN @41589
 == ~USVEIRJ~ @41590
 = @41591
 == ~11KOLUHM~ @41592 
 END

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
 
 ADD_TRANS_TRIGGER ~50LIMHA~ 14 ~Or(2)
  !Global("INTERJECTUSPAIRJ1","GLOBAL",0)
  !IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USPAIR)")~
INTERJECT_COPY_TRANS2 ~50LIMHA~ 14 ~INTERJECTUSPAIRJ1~ 
 == ~USPAIRJ~ IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USPAIR)")~
 THEN @41014 
 == ~50LIMHA~ @41015 
 END
 
 ADD_TRANS_TRIGGER ~51DARGAB~ 7 ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")~
EXTEND_BOTTOM ~51DARGAB~ 7 IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")~
 THEN EXTERN ~USEMMAJ~ 74 END

APPEND ~52ARUMA~
IF ~~ THEN BEGIN USArumaSersaQuestion
  SAY @41379
  COPY_TRANS ~52ARUMA~ 14
END
END

EXTEND_TOP ~52ARUMA~ 9 IF ~InParty("USSERS")~
 THEN REPLY @41378 GOTO USArumaSersaQuestion END
 
 ADD_TRANS_TRIGGER ~52ARUMA~ 20 ~Or(2)
  !IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USSERS)")
  !Global("US_Sersa_Mastered_All","GLOBAL",1)~
INTERJECT_COPY_TRANS2 ~52ARUMA~ 20 ~INTERJECTUSSERSJ1~ 
 == ~52ARUMA~ IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USSERS)")
Global("US_Sersa_Mastered_All","GLOBAL",1)~
 THEN @41608
 == ~USSERSJ~ @41609 
 END
 
ADD_TRANS_TRIGGER ~52SALISA~ 19 ~Or(2)
  !IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USSERS)")
  !Global("US_Sersa_Mastered_All","GLOBAL",1)~
INTERJECT_COPY_TRANS2 ~52SALISA~ 19 ~INTERJECTUSSERSJ1~ 
 == ~52SALISA~ IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USSERS)")
Global("US_Sersa_Mastered_All","GLOBAL",1)~
 THEN @41608
 == ~USSERSJ~ @41609 
 END
 
APPEND ~52MOROHE~
IF ~~ THEN BEGIN USMorohemSersaComment
  SAY @41569
  IF ~~ THEN GOTO 19
END
END

ADD_TRANS_TRIGGER ~52MOROHE~ 24 ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USSERS)")~
EXTEND_BOTTOM ~52MOROHE~ 24 IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USSERS)")~
 THEN DO ~SetGlobal("52Nonin_Storage","GLOBAL",1)~ GOTO USMorohemSersaComment END

 
ADD_TRANS_ACTION ~53MALAVO~ BEGIN 18 END BEGIN END ~SetGlobal("US_Know_Malavon_Backstory","GLOBAL",1)~

ADD_TRANS_TRIGGER ~53DROPR~ 5 ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USXHAA)")~
INTERJECT ~53DROPR~ 5 ~INTERJECTUSXHAAJ2~ 
 == ~USXHAAJ~ IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USXHAA)")~
 THEN @41620
 == ~53DROPR~ @41621 END IF ~~ THEN DO ~Enemy()~ EXIT

ADD_TRANS_TRIGGER ~60HIEPHE~ 5 ~Or(2)
  !Global("INTERJECTUSVUNAJ1","GLOBAL",0)
  !IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")~
INTERJECT_COPY_TRANS2 ~60HIEPHE~ 5 ~INTERJECTUSVUNAJ1~ 
 == ~USVUNAJ~ IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")~
 THEN @41593
 == ~60HIEPHE~ @41594 END
 
 ADD_TRANS_TRIGGER ~61RAKSHA~ 0 ~Or(2)
  !Global("INTERJECTUSVREKJ1","GLOBAL",0)
  !IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVREK)")~
INTERJECT_COPY_TRANS2 ~61RAKSHA~ 0 ~INTERJECTUSVREKJ1~ 
 == ~USVREKJ~ IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVREK)")~
 THEN @41595
 == ~61RAKSHA~ @41596
 == ~USVREKJ~ @41597
 == ~61RAKSHA~ @41598
 == ~USVREKJ~ @41599
 == ~61RAKSHA~ @41600 END
 
ADD_TRANS_TRIGGER ~63GLABS1~ 0 ~Or(3)
  !Global("INTERJECTUSXHAAJ3","GLOBAL",0)
  !IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USXHAA)")
  GlobalGT("SH_Demon_Secret","GLOBAL",2)~
INTERJECT_COPY_TRANS2 ~63GLABS1~ 0 ~INTERJECTUSXHAAJ3~ 
 == ~USXHAAJ~ IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USXHAA)")
GlobalLT("SH_Demon_Secret","GLOBAL",3)~
 THEN @41611
 == ~63GLABS1~ @41613 END
 
ADD_TRANS_TRIGGER ~63JERRE~ 13 ~Or(2)
  !Global("INTERJECTUSXHAAJ4","GLOBAL",0)
  !IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USXHAA)")~
INTERJECT_COPY_TRANS2 ~63JERRE~ 13 ~INTERJECTUSXHAAJ4~ 
 == ~USXHAAJ~ IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USXHAA)")~
 THEN @41612 END
 
ADD_TRANS_TRIGGER ~63YXBU~ 3 ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USXHAA)")~
EXTEND_BOTTOM ~63YXBU~ 3 IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USXHAA)")~
 THEN EXTERN ~USXHAAJ~ 34 END

APPEND_EARLY ~63TUTU~
IF ~~ THEN BEGIN USXhaanYxbuTutuComment
  SAY @41628
  IF ~~ THEN EXTERN ~63YXBU~ 14
END
END

EXTEND_BOTTOM ~USXHAAJ~ 37 IF ~~
 THEN EXTERN ~63TUTU~ USXhaanYxbuTutuComment END
 
ADD_TRANS_TRIGGER ~65IYTXM~ 0 ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")~ 1 3 6 10 DO 1

EXTEND_BOTTOM ~65IYTXM~ 0 IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")~
 THEN REPLY #27260 EXTERN ~USEMMAJ~ 95 END
EXTEND_BOTTOM ~65IYTXM~ 0 IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")~
 THEN REPLY #27260 EXTERN ~USVUNAJ~ 100 END
 
EXTEND_BOTTOM ~65IYTXM~ 1 IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")~
 THEN REPLY #28536 EXTERN ~USEMMAJ~ 95 END
EXTEND_BOTTOM ~65IYTXM~ 1 IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")~
 THEN REPLY #28536 EXTERN ~USVUNAJ~ 100 END
 
EXTEND_BOTTOM ~65IYTXM~ 3 IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")~
 THEN REPLY #28761 EXTERN ~USEMMAJ~ 95 END
EXTEND_BOTTOM ~65IYTXM~ 3 IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")~
 THEN REPLY #28761 EXTERN ~USVUNAJ~ 100 END
 
EXTEND_BOTTOM ~65IYTXM~ 6 IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")~
 THEN REPLY #30461 EXTERN ~USEMMAJ~ 96 END
EXTEND_BOTTOM ~65IYTXM~ 6 IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")~
 THEN REPLY #30461 EXTERN ~USVUNAJ~ 100 END
 
EXTEND_BOTTOM ~65IYTXM~ 10 IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")~
 THEN REPLY #38246 EXTERN ~USEMMAJ~ 95 END
EXTEND_BOTTOM ~65IYTXM~ 10 IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")~
 THEN REPLY #38246 EXTERN ~USVUNAJ~ 100 END

ADD_TRANS_TRIGGER ~65IYTXM~ 8 ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USSERS)")~

EXTEND_BOTTOM ~65IYTXM~ 8 IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")~
 THEN EXTERN ~USEMMAJ~ 94 END
EXTEND_BOTTOM ~65IYTXM~ 8 IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USSERS)")~
 THEN EXTERN ~USSERSJ~ 23 END

ADD_TRANS_TRIGGER ~67ORMIS~ 0 ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USXHAA)")~
EXTEND_BOTTOM ~67ORMIS~ 0 IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USXHAA)")~
 THEN EXTERN ~USXHAAJ~ 33 END
 
ADD_TRANS_TRIGGER ~67ORMIS~ 4 ~Or(2)
  !Global("INTERJECTUSSERSJ2","GLOBAL",0)
  !IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USSERS)")~
INTERJECT_COPY_TRANS2 ~67ORMIS~ 4 ~INTERJECTUSSERSJ2~ 
 == ~USSERSJ~ IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USSERS)")~
 THEN @41617 
 == ~67ORMIS~ @41618 END
 
ADD_TRANS_TRIGGER ~67ORMIS~ 7 ~Or(2)
  !Global("INTERJECTUSREIGJ1","GLOBAL",0)
  !IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")~
INTERJECT_COPY_TRANS2 ~67ORMIS~ 7 ~INTERJECTUSREIGJ1~ 
 == ~USREIGJ~ IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")~
 THEN @41586 END
 
 