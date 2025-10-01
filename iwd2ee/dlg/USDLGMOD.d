APPEND ~11DENHAM~
IF ~~ THEN BEGIN USDenhamLetterComment
  SAY #36173
  IF ~~ THEN REPLY @56027 GOTO 30
END
END

APPEND ~11RAGNIB~
IF ~~ THEN BEGIN USRagniLetterComment
  SAY @56026
  IF ~~ THEN EXTERN ~11DENHAM~ USDenhamLetterComment
END
END

EXTEND_BOTTOM ~11DENHAM~ 0 IF ~PartyHasItem("11GENGOL")
Global("Garradun_Quest","GLOBAL",1)
Global("Garradun_Dead","GLOBAL",0)~ THEN REPLY @56024 DO ~TakePartyItem("11GENGOL")
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO 30 END
EXTEND_BOTTOM ~11DENHAM~ 0 IF ~PartyHasItem("11GENGOL")
Or(2)
Global("Garradun_Quest","GLOBAL",3)
Global("Garradun_Dead","GLOBAL",1)~ THEN REPLY @56025 DO ~TakePartyItem("11GENGOL")
AddXPVar("Level_1_Easy",25122)
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ JOURNAL #25120 GOTO 38 END
EXTEND_BOTTOM ~11DENHAM~ 12 IF ~PartyHasItem("11GENGOL")
Global("Garradun_Quest","GLOBAL",1)
Global("Garradun_Dead","GLOBAL",0)~ THEN REPLY @56024 DO ~TakePartyItem("11GENGOL")
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO 30 END
EXTEND_BOTTOM ~11DENHAM~ 12 IF ~PartyHasItem("11GENGOL")
Or(2)
Global("Garradun_Quest","GLOBAL",3)
Global("Garradun_Dead","GLOBAL",1)~ THEN REPLY @56025 DO ~TakePartyItem("11GENGOL")
AddXPVar("Level_1_Easy",25122)
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ JOURNAL #25120 GOTO 38 END
EXTEND_BOTTOM ~11DENHAM~ 15 IF ~PartyHasItem("11GENGOL")
Global("Garradun_Quest","GLOBAL",1)
Global("Garradun_Dead","GLOBAL",0)~ THEN REPLY @56024 DO ~TakePartyItem("11GENGOL")
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO 30 END
EXTEND_BOTTOM ~11DENHAM~ 15 IF ~PartyHasItem("11GENGOL")
Or(2)
Global("Garradun_Quest","GLOBAL",3)
Global("Garradun_Dead","GLOBAL",1)~ THEN REPLY @56025 DO ~TakePartyItem("11GENGOL")
AddXPVar("Level_1_Easy",25122)
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ JOURNAL #25120 GOTO 38 END
EXTEND_BOTTOM ~11DENHAM~ 23 IF ~PartyHasItem("11GENGOL")
Global("Garradun_Quest","GLOBAL",1)
Global("Garradun_Dead","GLOBAL",0)~ THEN REPLY @56024 DO ~TakePartyItem("11GENGOL")
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO 30 END
EXTEND_BOTTOM ~11DENHAM~ 23 IF ~PartyHasItem("11GENGOL")
Or(2)
Global("Garradun_Quest","GLOBAL",3)
Global("Garradun_Dead","GLOBAL",1)~ THEN REPLY @56025 DO ~TakePartyItem("11GENGOL")
AddXPVar("Level_1_Easy",25122)
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ JOURNAL #25120 GOTO 38 END
EXTEND_BOTTOM ~11RAGNIB~ 3 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Global("Garradun_Quest","GLOBAL",1)
Global("Garradun_Dead","GLOBAL",0)~ THEN REPLY @56024 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO USRagniLetterComment END
EXTEND_BOTTOM ~11RAGNIB~ 3 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Or(2)
Global("Garradun_Quest","GLOBAL",3)
Global("Garradun_Dead","GLOBAL",1)~ THEN REPLY @56025 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Ragni_Dop","GLOBAL",1)
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO 35 END
EXTEND_BOTTOM ~11RAGNIB~ 5 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Global("Garradun_Quest","GLOBAL",1)
Global("Garradun_Dead","GLOBAL",0)~ THEN REPLY @56024 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO USRagniLetterComment END
EXTEND_BOTTOM ~11RAGNIB~ 5 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Or(2)
Global("Garradun_Quest","GLOBAL",3)
Global("Garradun_Dead","GLOBAL",1)~ THEN REPLY @56025 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Ragni_Dop","GLOBAL",1)
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO 35 END
EXTEND_BOTTOM ~11RAGNIB~ 6 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Global("Garradun_Quest","GLOBAL",1)
Global("Garradun_Dead","GLOBAL",0)~ THEN REPLY @56024 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO USRagniLetterComment END
EXTEND_BOTTOM ~11RAGNIB~ 6 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Or(2)
Global("Garradun_Quest","GLOBAL",3)
Global("Garradun_Dead","GLOBAL",1)~ THEN REPLY @56025 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Ragni_Dop","GLOBAL",1)
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO 35 END
EXTEND_BOTTOM ~11RAGNIB~ 7 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Global("Garradun_Quest","GLOBAL",1)
Global("Garradun_Dead","GLOBAL",0)~ THEN REPLY @56024 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO USRagniLetterComment END
EXTEND_BOTTOM ~11RAGNIB~ 7 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Or(2)
Global("Garradun_Quest","GLOBAL",3)
Global("Garradun_Dead","GLOBAL",1)~ THEN REPLY @56025 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Ragni_Dop","GLOBAL",1)
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO 35 END
EXTEND_BOTTOM ~11RAGNIB~ 8 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Global("Garradun_Quest","GLOBAL",1)
Global("Garradun_Dead","GLOBAL",0)~ THEN REPLY @56024 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO USRagniLetterComment END
EXTEND_BOTTOM ~11RAGNIB~ 8 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Or(2)
Global("Garradun_Quest","GLOBAL",3)
Global("Garradun_Dead","GLOBAL",1)~ THEN REPLY @56025 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Ragni_Dop","GLOBAL",1)
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO 35 END
EXTEND_BOTTOM ~11RAGNIB~ 12 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Global("Garradun_Quest","GLOBAL",1)
Global("Garradun_Dead","GLOBAL",0)~ THEN REPLY @56024 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO USRagniLetterComment END
EXTEND_BOTTOM ~11RAGNIB~ 12 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Or(2)
Global("Garradun_Quest","GLOBAL",3)
Global("Garradun_Dead","GLOBAL",1)~ THEN REPLY @56025 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Ragni_Dop","GLOBAL",1)
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO 35 END
EXTEND_BOTTOM ~11RAGNIB~ 14 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Global("Garradun_Quest","GLOBAL",1)
Global("Garradun_Dead","GLOBAL",0)~ THEN REPLY @56024 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO USRagniLetterComment END
EXTEND_BOTTOM ~11RAGNIB~ 14 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Or(2)
Global("Garradun_Quest","GLOBAL",3)
Global("Garradun_Dead","GLOBAL",1)~ THEN REPLY @56025 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Ragni_Dop","GLOBAL",1)
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO 35 END
EXTEND_BOTTOM ~11RAGNIB~ 15 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Global("Garradun_Quest","GLOBAL",1)
Global("Garradun_Dead","GLOBAL",0)~ THEN REPLY @56024 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO USRagniLetterComment END
EXTEND_BOTTOM ~11RAGNIB~ 15 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Or(2)
Global("Garradun_Quest","GLOBAL",3)
Global("Garradun_Dead","GLOBAL",1)~ THEN REPLY @56025 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Ragni_Dop","GLOBAL",1)
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO 35 END
EXTEND_BOTTOM ~11RAGNIB~ 16 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Global("Garradun_Quest","GLOBAL",1)
Global("Garradun_Dead","GLOBAL",0)~ THEN REPLY @56024 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO USRagniLetterComment END
EXTEND_BOTTOM ~11RAGNIB~ 16 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Or(2)
Global("Garradun_Quest","GLOBAL",3)
Global("Garradun_Dead","GLOBAL",1)~ THEN REPLY @56025 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Ragni_Dop","GLOBAL",1)
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO 35 END
EXTEND_BOTTOM ~11RAGNIB~ 17 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Global("Garradun_Quest","GLOBAL",1)
Global("Garradun_Dead","GLOBAL",0)~ THEN REPLY @56024 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO USRagniLetterComment END
EXTEND_BOTTOM ~11RAGNIB~ 17 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Or(2)
Global("Garradun_Quest","GLOBAL",3)
Global("Garradun_Dead","GLOBAL",1)~ THEN REPLY @56025 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Ragni_Dop","GLOBAL",1)
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO 35 END
EXTEND_BOTTOM ~11RAGNIB~ 22 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Global("Garradun_Quest","GLOBAL",1)
Global("Garradun_Dead","GLOBAL",0)~ THEN REPLY @56024 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO USRagniLetterComment END
EXTEND_BOTTOM ~11RAGNIB~ 22 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Or(2)
Global("Garradun_Quest","GLOBAL",3)
Global("Garradun_Dead","GLOBAL",1)~ THEN REPLY @56025 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Ragni_Dop","GLOBAL",1)
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO 35 END
EXTEND_BOTTOM ~11RAGNIB~ 23 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Global("Garradun_Quest","GLOBAL",1)
Global("Garradun_Dead","GLOBAL",0)~ THEN REPLY @56024 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO USRagniLetterComment END
EXTEND_BOTTOM ~11RAGNIB~ 23 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Or(2)
Global("Garradun_Quest","GLOBAL",3)
Global("Garradun_Dead","GLOBAL",1)~ THEN REPLY @56025 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Ragni_Dop","GLOBAL",1)
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO 35 END
EXTEND_BOTTOM ~11RAGNIB~ 34 IF ~PartyHasItem("11GENGOL")
Global("Ragni_Garradun","GLOBAL",0)
Or(2)
Global("Garradun_Quest","GLOBAL",3)
Global("Garradun_Dead","GLOBAL",1)~ THEN REPLY @56025 DO ~TakePartyItem("11GENGOL")
DestroyItem("11GENGOL")
SetGlobal("Ragni_Dop","GLOBAL",1)
SetGlobal("Know_Denham","GLOBAL",1)
SetGlobal("Garradun_Quest","GLOBAL",2)~ GOTO 35 END

REPLACE_TRANS_TRIGGER ~11GARRAD~ BEGIN 11 END BEGIN END ~GlobalGT("Garradun_Quest","GLOBAL",1)~ ~Or(3)
	GlobalGT("Garradun_Quest","GLOBAL",1)
	PartyHasItem("11GENGOL")~

REPLACE_TRANS_ACTION ~11DENHAM~ BEGIN 33 END BEGIN END ~GiveItemCreate("11GenDen",Protagonist,1,1,1)~ ~DestroyItem("11GENGOL")
GiveItemCreate("USGENGOL",Protagonist,1,1,1)
GiveItemCreate("11GenDen",Protagonist,1,1,1)~

ADD_TRANS_TRIGGER ~51DARGAB~ 2 ~CheckDoorFlags("AR5102_Door1",DOOROPEN)~
ADD_TRANS_TRIGGER ~51DARGAB~ 18 ~CheckDoorFlags("AR5102_Door1",DOOROPEN)~
ADD_TRANS_TRIGGER ~51DARGAB~ 19 ~CheckDoorFlags("AR5102_Door1",DOOROPEN)~
EXTEND_BOTTOM ~51DARGAB~ 2 IF ~!CheckDoorFlags("AR5102_Door1",DOOROPEN)~ THEN REPLY @56000 GOTO 5 END
EXTEND_BOTTOM ~51DARGAB~ 18 IF ~!CheckDoorFlags("AR5102_Door1",DOOROPEN)~ THEN REPLY @56000 GOTO 5 END
EXTEND_BOTTOM ~51DARGAB~ 19 IF ~!CheckDoorFlags("AR5102_Door1",DOOROPEN)~ THEN REPLY @56000 GOTO 5 END

ADD_TRANS_TRIGGER ~64ORRICK~ 70 ~Global("US_Final_Battle_Alternate","GLOBAL",0)~ DO 1
ADD_TRANS_TRIGGER ~64ORRICK~ 71 ~Global("US_Final_Battle_Alternate","GLOBAL",0)~
EXTEND_BOTTOM ~64ORRICK~ 70 IF ~!Global("US_Final_Battle_Alternate","GLOBAL",0)~ THEN REPLY #33931 DO ~AddXPVar("Level_15_Very_Hard",32684)
Unlock("AR6303_Door1")
OpenDoor("AR6303_Door1")
StartCutSceneMode()
StartCutScene("US63CFB6")~ EXIT END
EXTEND_BOTTOM ~64ORRICK~ 71 IF ~!Global("US_Final_Battle_Alternate","GLOBAL",0)~ THEN REPLY #33933 DO ~AddXPVar("Level_15_Very_Hard",32684)
Unlock("AR6303_Door1")
OpenDoor("AR6303_Door1")
StartCutSceneMode()
StartCutScene("US63CFB6")~ EXIT END