BEGIN ~20NEWEMM~

IF WEIGHT #0 ~Global("US_VREK_JOIN","GLOBAL",1)
InParty("USVREK")~ THEN BEGIN VrekJoined
  SAY @40034
  IF ~~ THEN REPLY @40035 DO ~SetGlobal("SR_Emma_Revenge","GLOBAL",2)~ GOTO EmmaAttack
  IF ~~ THEN REPLY @40036 DO ~SetGlobal("SR_Emma_Revenge","GLOBAL",2)~ GOTO EmmaAttack
END

IF WEIGHT #6 ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY #36409
  IF ~~ THEN REPLY #36410 GOTO 1
  IF ~~ THEN REPLY #36411 GOTO 2
END

IF ~~ THEN BEGIN 1
  SAY #36412
  IF ~~ THEN REPLY #36413 GOTO 4
  IF ~  !ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
Global("US_THIS_PREVENTS_THE_EMMA_HEALING_EXPLOIT","GLOBAL",5)
~ THEN REPLY #36414 GOTO 3
END

IF ~~ THEN BEGIN 2
  SAY #36415
  IF ~~ THEN REPLY #36413 GOTO 4
  IF ~  !ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36414 GOTO 3
END

IF ~~ THEN BEGIN 3
  SAY #36416
  IF ~~ THEN REPLY #36417 DO ~SetGlobal("SR_Emma_Heal","GLOBAL", 1)~ GOTO 4
END

IF ~~ THEN BEGIN 4
  SAY #36418
  IF ~  !PartyHasItem("00SWDL09")
  !PartyHasItem("USHFSL09")
~ THEN REPLY #36419 GOTO 5
  IF ~  !PartyHasItem("00SWDL09")
  !PartyHasItem("USHFSL09")
~ THEN REPLY #36420 GOTO 6
  IF ~  !Global("SR_Emma_Heal","GLOBAL",1)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
!PartyHasItem("00SWDL09")
!PartyHasItem("USHFSL09")
Global("US_THIS_PREVENTS_THE_EMMA_HEALING_EXPLOIT","GLOBAL",5)
~ THEN REPLY #36421 DO ~SetGlobal("SR_Recover_Blade","GLOBAL", 3)~ JOURNAL #36401 GOTO 7
  IF ~  Global("SR_Emma_Heal","GLOBAL",1)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
!PartyHasItem("00SWDL09")
!PartyHasItem("USHFSL09")
Global("US_THIS_PREVENTS_THE_EMMA_HEALING_TRICK","GLOBAL",5)
~ THEN REPLY #36422 DO ~SetGlobal("SR_Recover_Blade","GLOBAL", 3)~ JOURNAL #36401 GOTO 8
  IF ~  ClassEx(Protagonist,PALADIN)
!PartyHasItem("00SWDL09")
~ THEN REPLY #36423 DO ~SetGlobal("SR_Recover_Blade","GLOBAL", 3)~ JOURNAL #36400 GOTO 9
  IF ~  Or(2)
  PartyHasItem("00SWDL09")
  PartyHasItem("USHFSL09")
!Global("SR_Kaitlin_Fled","GLOBAL",1)
!Global("SR_Kaitlin_Dead","GLOBAL",1)
~ THEN REPLY #2313 DO ~SetGlobal("SR_Recover_Blade","GLOBAL", 4)
SetGlobal("SR_Emma_Has_Blade","GLOBAL", 1)~ GOTO 17
  IF ~  Or(2)
  PartyHasItem("00SWDL09")
  PartyHasItem("USHFSL09")
Global("SR_Kaitlin_Fled","GLOBAL",1)
~ THEN REPLY #2313 DO ~SetGlobal("SR_Recover_Blade","GLOBAL", 4)
SetGlobal("SR_Emma_Revenge","GLOBAL", 2)
SetGlobal("SR_Emma_Has_Blade","GLOBAL", 1)~ GOTO 27
  IF ~  
Global("SR_Kaitlin_Dead","GLOBAL",1)
~ THEN REPLY #2313 DO ~SetGlobal("SR_Recover_Blade","GLOBAL", 4)
SetGlobal("SR_Emma_Revenge","GLOBAL", 3)
SetGlobal("SR_Emma_Has_Blade","GLOBAL", 1)~ GOTO 29
END

IF ~~ THEN BEGIN 5
  SAY #36424
  IF ~~ THEN REPLY #36420 GOTO 6
END

IF ~~ THEN BEGIN 6
  SAY @40022
  IF ~~ THEN REPLY #36426 DO ~SetGlobal("SR_Recover_Blade","GLOBAL", 3)~ JOURNAL #36400 GOTO 11
  IF ~~ THEN REPLY @40023 DO ~SetGlobal("SR_Recover_Blade","GLOBAL", 3)~ JOURNAL #36400 GOTO 11
  IF ~  !Global("SR_Emma_Heal","GLOBAL",1)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36421 DO ~SetGlobal("SR_Recover_Blade","GLOBAL", 3)~ JOURNAL #36401 GOTO 7
  IF ~  Global("SR_Emma_Heal","GLOBAL",1)
!ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
Global("US_THIS_PREVENTS_THE_EMMA_HEALING_TRICK","GLOBAL",5)
~ THEN REPLY #36422 DO ~SetGlobal("SR_Recover_Blade","GLOBAL", 3)~ JOURNAL #36401 GOTO 8
  IF ~  ClassEx(Protagonist,PALADIN)
~ THEN REPLY #36423 DO ~SetGlobal("SR_Recover_Blade","GLOBAL", 3)~ JOURNAL #36400 GOTO 9
  IF ~  !ClassEx(Protagonist,PALADIN)
~ THEN REPLY #36427 DO ~SetGlobal("SR_Emma_Revenge","GLOBAL", 1)~ GOTO 10
END

IF ~~ THEN BEGIN 7
  SAY #36416
  IF ~~ THEN REPLY #36428 DO ~SetGlobal("SR_Emma_Heal","GLOBAL", 1)~ GOTO 11
END

IF ~~ THEN BEGIN 8
  SAY #36429
  IF ~~ THEN REPLY #36430 GOTO 11
END

IF ~~ THEN BEGIN 9
  SAY #36431
  IF ~~ THEN REPLY #36432 GOTO 11
END

IF ~~ THEN BEGIN 10
  SAY #36433
  IF ~~ THEN REPLY #36434 DO ~StartCutScene("20cEmma2")~ JOURNAL #36402 EXIT
END

IF ~~ THEN BEGIN 11
  SAY #36435
  IF ~~ THEN REPLY #36436 DO ~GiveItemCreate("00Misc32", Protagonist,3,0,0)~ GOTO 12
END

IF ~~ THEN BEGIN 12
  SAY #36437
  IF ~~ THEN REPLY #36438 GOTO 13
END

IF ~~ THEN BEGIN 13
  SAY #36439
  IF ~!NumInParty(6)
!Global("US_VREK_JOIN","GLOBAL",1)
GlobalLT("SR_Recover_Blade","GLOBAL",4)
!Global("SR_Kaitlin_Fled","GLOBAL",1)
!Global("SR_Kaitlin_Dead","GLOBAL",1)
~ THEN REPLY @40024 GOTO EmmaJoin1
  IF ~~ THEN REPLY #36440 EXIT
END

IF WEIGHT #7 ~  NumTimesTalkedToGT(0)
~ THEN BEGIN 14
  SAY #36441
  IF ~  Global("SR_Kaitlin_Fled","GLOBAL",1)
!PartyHasItem("00SWDL09")
!PartyHasItem("USHFSL09")
~ THEN REPLY #36442 DO ~SetGlobal("SR_Emma_Revenge","GLOBAL", 2)~ JOURNAL #36403 GOTO 15
  IF ~  Global("SR_Kaitlin_Dead","GLOBAL",1)
!PartyHasItem("00SWDL09")
!PartyHasItem("USHFSL09")
~ THEN REPLY #36442 DO ~SetGlobal("SR_Emma_Revenge","GLOBAL", 3)~ JOURNAL #36404 GOTO 16
  IF ~  Global("SR_Recover_Blade","GLOBAL",3)
Or(2)
  PartyHasItem("00SWDL09")
  PartyHasItem("USHFSL09")
!Global("SR_Kaitlin_Fled","GLOBAL",1)
!Global("SR_Kaitlin_Dead","GLOBAL",1)
~ THEN REPLY #36443 DO ~SetGlobal("SR_Recover_Blade","GLOBAL", 4)
SetGlobal("SR_Emma_Has_Blade","GLOBAL", 1)~ GOTO 17
  IF ~  Global("SR_Recover_Blade","GLOBAL",3)
Or(2)
  PartyHasItem("00SWDL09")
  PartyHasItem("USHFSL09")
Global("SR_Kaitlin_Fled","GLOBAL",1)
~ THEN REPLY #36443 DO ~SetGlobal("SR_Recover_Blade","GLOBAL", 4)
SetGlobal("SR_Emma_Revenge","GLOBAL", 2)
SetGlobal("SR_Emma_Has_Blade","GLOBAL", 1)~ JOURNAL #36403 GOTO 27
  IF ~  Global("SR_Recover_Blade","GLOBAL",3)
Or(2)
  PartyHasItem("00SWDL09")
  PartyHasItem("USHFSL09")
Global("SR_Kaitlin_Dead","GLOBAL",1)
~ THEN REPLY #36443 DO ~SetGlobal("SR_Recover_Blade","GLOBAL", 4)
SetGlobal("SR_Emma_Revenge","GLOBAL", 3)
SetGlobal("SR_Emma_Has_Blade","GLOBAL", 1)~ JOURNAL #36404 GOTO 29
  IF ~  !Global("SR_Emma_Heal","GLOBAL",1)
~ THEN REPLY #36444 DO ~StartStore("20Emma", Protagonist)~ EXIT
  IF ~  Global("SR_Emma_Heal","GLOBAL",1)
~ THEN REPLY #36444 DO ~StartStore("20EmDis", Protagonist)~ EXIT
  IF ~~ THEN REPLY #36445 DO ~FadeToColor([0.0],0)
RestUntilHealed()
FadeFromColor([0.0],0)~ EXIT
  IF ~!NumInParty(6)
!Global("US_VREK_JOIN","GLOBAL",1)
Global("SR_Recover_Blade","GLOBAL",4)
!Global("SR_Kaitlin_Fled","GLOBAL",1)
!Global("SR_Kaitlin_Dead","GLOBAL",1)
~ THEN REPLY @40025 GOTO EmmaJoin1
  IF ~!NumInParty(6)
!Global("US_VREK_JOIN","GLOBAL",1)
GlobalLT("SR_Recover_Blade","GLOBAL",4)
!Global("SR_Kaitlin_Fled","GLOBAL",1)
!Global("SR_Kaitlin_Dead","GLOBAL",1)
~ THEN REPLY ~How about you join us?  We'll find your blade together.~ GOTO EmmaJoin5
  IF ~~ THEN REPLY #36446 EXIT
END

IF ~~ THEN BEGIN 15
  SAY #36447
  IF ~~ THEN REPLY #36434 DO ~StartCutScene("20cEmma2")~ EXIT
END

IF ~~ THEN BEGIN 16
  SAY #36448
  IF ~~ THEN REPLY #36434 DO ~StartCutScene("20cEmma2")~ EXIT
END

IF ~~ THEN BEGIN 17
  SAY #36449
  IF ~  !ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36450 DO ~AddXpVar("Level_3_Hard",36407)
TakePartyItem("00SWDL09")
TakePartyItem("USHFSL09")
GiveItemCreate("Misc07", Protagonist, 2000, 0, 0)~ JOURNAL #36405 GOTO 18
  IF ~  !ClassEx(Protagonist,PALADIN)
ClassEx(Protagonist,MONK)
~ THEN REPLY #36451 DO ~AddXpVar("Level_3_Hard",36407)
TakePartyItem("00SWDL09")
TakePartyItem("USHFSL09")
~ JOURNAL #36405 GOTO 19
  IF ~  ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #36451 DO ~AddXpVar("Level_3_Hard",36407)
TakePartyItem("00SWDL09")
TakePartyItem("USHFSL09")
~ JOURNAL #36405 GOTO 19
  IF ~  Global("SR_Dereth_Freed","GLOBAL",4)
Global("SR_Sabrina_Freed","GLOBAL",4)
GlobalGT("SR_Rescue_Villagers","GLOBAL",3)
!Global("SR_Dereth_Dead","GLOBAL",1)
!Global("SR_Sabrina_Dead","GLOBAL",1)
!Global("SR_Kaitlin_Dead","GLOBAL",1)
~ THEN REPLY #36452 DO ~AddXpVar("Level_4_Hard",36408)
~ JOURNAL #36406 GOTO 20
END

IF ~~ THEN BEGIN 18
  SAY #36453
  IF ~!NumInParty(6)
!Global("US_VREK_JOIN","GLOBAL",1)
~ THEN REPLY @40025 GOTO EmmaJoin1
  IF ~  !Global("SR_Emma_Heal","GLOBAL",1)
~ THEN REPLY #36444 DO ~StartStore("20Emma", Protagonist)~ EXIT
  IF ~  Global("SR_Emma_Heal","GLOBAL",1)
~ THEN REPLY #36444 DO ~StartStore("20EmDis", Protagonist)~ EXIT
  IF ~~ THEN REPLY #36445 DO ~FadeToColor([0.0],0)
RestUntilHealed()
FadeFromColor([0.0],0)~ EXIT
  IF ~~ THEN REPLY #36454 EXIT
END

IF ~~ THEN BEGIN 19
  SAY @40026
  IF ~!NumInParty(6)
!Global("US_VREK_JOIN","GLOBAL",1)
~ THEN REPLY @40025 GOTO EmmaJoin1
  IF ~  Global("SR_Emma_Heal","GLOBAL",1)
~ THEN REPLY #36444 DO ~StartStore("20EmDis", Protagonist)~ EXIT
  IF ~~ THEN REPLY #36445 DO ~FadeToColor([0.0],0)
RestUntilHealed()
FadeFromColor([0.0],0)~ EXIT
  IF ~~ THEN REPLY #36456 EXIT
END

IF ~~ THEN BEGIN 20
  SAY #36457
  IF ~~ THEN REPLY #36458 GOTO 21
END

IF ~~ THEN BEGIN 21
  SAY #36459
  IF ~!NumInParty(6)
!Global("US_VREK_JOIN","GLOBAL",1)
~ THEN REPLY @40025 GOTO EmmaJoin1
  IF ~~ THEN REPLY #36460 EXIT
END

IF WEIGHT #5 ~  GlobalLT("SR_Orcs_Dead","GLOBAL",2)
~ THEN BEGIN 22
  SAY #36461
  IF ~~ THEN DO ~SetNumTimesTalkedTo(0)~ EXIT
END

IF WEIGHT #1 ~  Global("SR_Emma_Revenge","GLOBAL",1)
~ THEN BEGIN 23
  SAY #36463
  IF ~~ THEN REPLY #36464 DO ~Enemy()~ EXIT
END

IF WEIGHT #2 ~  Global("SR_Emma_Revenge","GLOBAL",2)
~ THEN BEGIN 24
  SAY #36465
  IF ~~ THEN REPLY #36464 DO ~Enemy()~ EXIT
END

IF WEIGHT #3 ~  Global("SR_Emma_Revenge","GLOBAL",3)
~ THEN BEGIN 25
  SAY #36466
  IF ~~ THEN REPLY #36464 DO ~Enemy()~ EXIT
END

IF WEIGHT #4 ~  Global("SR_Emma_Revenge","GLOBAL",4)
~ THEN BEGIN 26
  SAY #36467
  IF ~~ THEN REPLY #36464 DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 27
  SAY #36468
  IF ~~ THEN REPLY #36469 DO ~TakePartyItem("00SWDL09")
TakePartyItem("USHFSL09")~ GOTO 28
END

IF ~~ THEN BEGIN 28
  SAY #36470
  IF ~~ THEN REPLY #36434 DO ~StartCutScene("20cEmma2")~ EXIT
END

IF ~~ THEN BEGIN 29
  SAY #36468
  IF ~~ THEN REPLY #36469 DO ~TakePartyItem("00SWDL09")
TakePartyItem("USHFSL09")~ GOTO 30
END

IF ~~ THEN BEGIN 30
  SAY #36471
  IF ~~ THEN REPLY #36434 DO ~StartCutScene("20cEmma2")~ EXIT
END

IF ~~ THEN BEGIN EmmaJoin1
  SAY @40027
  IF ~~ THEN REPLY @40028 GOTO EmmaJoin2
  IF ~~ THEN REPLY @40029 GOTO EmmaJoin3
END

IF ~~ THEN BEGIN EmmaJoin2
  SAY @40030
  IF ~~ THEN DO ~SetGlobal("US_Emma_Joined", "GLOBAL", 1)
ApplySpellRES("USEMMAC",Myself)~ EXIT
END

IF ~~ THEN BEGIN EmmaJoin3
  SAY @40031
  IF ~~ THEN DO ~SetGlobal("US_Emma_Joined", "GLOBAL", 1)
ApplySpellRES("USEMMAC",Myself)~ EXIT
END

IF ~~ THEN BEGIN EmmaJoin4
  SAY @40032
  IF ~~ THEN DO ~SetGlobal("US_Emma_Joined", "GLOBAL", 1)
ApplySpellRES("USEMMAC",Myself)~ EXIT
END

IF ~~ THEN BEGIN EmmaJoin5
  SAY @40033
  IF ~~ THEN DO ~SetGlobal("US_Emma_Joined", "GLOBAL", 1)
ApplySpellRES("USEMMAC",Myself)~ EXIT
END

IF ~~ THEN BEGIN EmmaAttack
  SAY @40037
  IF ~~ THEN REPLY @40038 GOTO EmmaAttack2
  IF ~~ THEN REPLY @40039 GOTO EmmaAttack2
END

IF ~~ THEN BEGIN EmmaAttack2
  SAY @40040
  IF ~~ THEN REPLY @40041 DO ~StartCutScene("20cEmma2")~ EXIT
END
