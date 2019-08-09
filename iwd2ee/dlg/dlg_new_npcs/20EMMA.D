BEGIN ~20EMMA~

IF WEIGHT #6 ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY #2294
  IF ~~ THEN REPLY #2295 DO ~SetGlobal("Spoke_Emma","GLOBAL",1)~ GOTO 1
  IF ~~ THEN REPLY #2297 DO ~SetGlobal("Spoke_Emma","GLOBAL",1)~ GOTO 20
END

IF ~~ THEN BEGIN 1
  SAY #2301
  IF ~~ THEN REPLY #2302 GOTO 2
END

IF ~~ THEN BEGIN 2
  SAY #2303
  IF ~~ THEN REPLY #2304 GOTO 3
END

IF ~~ THEN BEGIN 3
  SAY #2305
  IF ~~ THEN REPLY #2306 JOURNAL #2287 GOTO 4
END

IF ~~ THEN BEGIN 4
  SAY #2307
  IF ~  !PartyHasItem("00SWDL09")
~ THEN REPLY #2308 DO ~SetGlobal("Recover_Emma_Blade","GLOBAL",3)~ JOURNAL #2288 GOTO 5
  IF ~~ THEN REPLY #2309 DO ~SetGlobal("Recover_Emma_Blade","GLOBAL",2)~ JOURNAL #2289 GOTO 6
  IF ~~ THEN REPLY #2312 DO ~SetGlobal("Recover_Emma_Blade","GLOBAL",1)~ JOURNAL #2290 GOTO 7
  IF ~  PartyHasItem("00SWDL09")
!Global("US_VREK_JOIN","GLOBAL",1)
~ THEN REPLY #2313 DO ~AddXpVar("Level_2_Hard",2293)
SetGlobal("Recover_Emma_Blade","GLOBAL",4)~ GOTO 21
END

IF ~~ THEN BEGIN 5
  SAY #2314
  IF ~~ THEN REPLY #2315 GOTO 8
  IF ~~ THEN REPLY #2316 EXIT
END

IF ~~ THEN BEGIN 6
  SAY #2317
  IF ~~ THEN REPLY #2315 GOTO 8
  IF ~~ THEN REPLY #2316 EXIT
END

IF ~~ THEN BEGIN 7
  SAY #2318
  IF ~~ THEN REPLY #2315 GOTO 8
  IF ~~ THEN REPLY #2316 EXIT
END

IF ~~ THEN BEGIN 8
  SAY #2331
  IF ~~ THEN REPLY #2333 GOTO 9
  IF ~~ THEN REPLY #2334 GOTO 10
END

IF ~~ THEN BEGIN 9
  SAY #2335
  IF ~~ THEN REPLY #2334 GOTO 10
END

IF ~~ THEN BEGIN 10
  SAY #2336
  IF ~~ THEN REPLY #2343 GOTO 11
END

IF ~~ THEN BEGIN 11
  SAY #2344
  IF ~~ THEN REPLY #2347 EXIT
END

IF WEIGHT #2 ~  Global("Recover_Emma_Blade","GLOBAL",1)
~ THEN BEGIN 12
  SAY #2348
  IF ~  !PartyHasItem("00SWDL09")
~ THEN REPLY #2349 DO ~SetGlobal("Recover_Emma_Blade","GLOBAL",3)~ JOURNAL #2288 GOTO 17
  IF ~  PartyHasItem("00SWDL09")
!Global("US_VREK_JOIN","GLOBAL",1)
~ THEN REPLY #2313 DO ~AddXpVar("Level_2_Hard",2293)
SetGlobal("Recover_Emma_Blade","GLOBAL",4)~ GOTO 18
  IF ~~ THEN REPLY #2350 DO ~StartStore("20Emma", Protagonist)~ EXIT
  IF ~~ THEN REPLY #2351 EXIT
END

IF ~~ THEN BEGIN 13
  SAY #2352
  IF ~~ THEN REPLY #2353 DO ~StartStore("20Emma", Protagonist)~ EXIT
  IF ~~ THEN REPLY #2354 EXIT
END

IF WEIGHT #3 ~  Global("Recover_Emma_Blade","GLOBAL",2)
~ THEN BEGIN 14
  SAY #2355
  IF ~  !PartyHasItem("00SWDL09")
~ THEN REPLY #2349 DO ~SetGlobal("Recover_Emma_Blade","GLOBAL",3)~ JOURNAL #2288 GOTO 17
  IF ~  PartyHasItem("00SWDL09")
!Global("US_VREK_JOIN","GLOBAL",1)
~ THEN REPLY #2313 DO ~AddXpVar("Level_2_Hard",2293)
SetGlobal("Recover_Emma_Blade","GLOBAL",4)~ GOTO 18
  IF ~~ THEN REPLY #2350 DO ~StartStore("20Emma", Protagonist)~ EXIT
  IF ~~ THEN REPLY #2351 EXIT
END

IF WEIGHT #4 ~  Global("Recover_Emma_Blade","GLOBAL",3)
~ THEN BEGIN 15
  SAY #2356
  IF ~~ THEN REPLY #2357 GOTO 16
  IF ~  PartyHasItem("00SWDL09")
!Global("US_VREK_JOIN","GLOBAL",1)
~ THEN REPLY #2358 DO ~AddXpVar("Level_2_Hard",2293)
SetGlobal("Recover_Emma_Blade","GLOBAL",4)~ JOURNAL #2292 GOTO 18
  IF ~~ THEN REPLY #2350 DO ~StartStore("20Emma", Protagonist)~ EXIT
END

IF ~~ THEN BEGIN 16
  SAY #2359
  IF ~~ THEN REPLY #2360 EXIT
  IF ~  Global("Vrek_Has_Blade","GLOBAL",1)
!Global("SR_Vrek_Dead","GLOBAL",1)
Global("Emma_Gave_Fire","GLOBAL",0)
~ THEN REPLY #2361 DO ~SetGlobal("Emma_Gave_Fire","GLOBAL",1)~ GOTO 17
  IF ~  Global("Emma_Gave_Fire","GLOBAL",1)
~ THEN REPLY #2361 GOTO 22
END

IF ~~ THEN BEGIN 17
  SAY #2362
  IF ~~ THEN REPLY #2354 DO ~SetGlobal("Talked_Vrek","GLOBAL",4)
GiveItemCreate("00Potn52", Protagonist,1,0,0)~ EXIT
END

IF ~~ THEN BEGIN 18
  SAY #2363
  IF ~  !ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #2354 DO ~TakePartyItem("00SWDL09")
GiveItemCreate("Misc07", Protagonist, 2000, 0, 0)
~ EXIT
  IF ~  !ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
!NumInParty(6)
!Global("US_VREK_JOIN","GLOBAL",1)
~ THEN REPLY ~Before we leave, would you consider joining us?  The horde has laid claim to Shaengarne Bridge, and Lord Ulbrec has asked us to retake the bridge.  We would be grateful if you would lend us your assistance.~ DO ~TakePartyItem("00SWDL09")
GiveItemCreate("Misc07", Protagonist, 2000, 0, 0)
~ GOTO EmmaJoin1
  IF ~  Kit(Protagonist,CLERIC_SELUNE)
!Global("Emma_Gave_Blade","GLOBAL",1)
~ THEN REPLY #2365 DO ~SetGlobal("Emma_Gave_Blade","GLOBAL",1)~ GOTO 28
  IF ~  !ClassEx(Protagonist,PALADIN)
ClassEx(Protagonist,MONK)
~ THEN REPLY #33517 DO ~TakePartyItem("00SWDL09")
~ GOTO 30
  IF ~  ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #33517 DO ~TakePartyItem("00SWDL09")
~ GOTO 30
END

IF WEIGHT #5 ~  Global("Recover_Emma_Blade","GLOBAL",4)
~ THEN BEGIN 19
  SAY #2364
  IF ~~ THEN REPLY #2353 DO ~StartStore("20Emma", Protagonist)~ EXIT
  IF ~  Kit(Protagonist,CLERIC_SELUNE)
!Global("Emma_Gave_Blade","GLOBAL",1)
~ THEN REPLY #2365 DO ~SetGlobal("Emma_Gave_Blade","GLOBAL",1)~ GOTO 28
  IF ~~ THEN REPLY #2366 EXIT
END

IF ~~ THEN BEGIN 20
  SAY #2368
  IF ~~ THEN REPLY #2302 GOTO 2
END

IF ~~ THEN BEGIN 21
  SAY #2369
  IF ~  !ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #2370 DO ~TakePartyItem("00SWDL09")
GiveItemCreate("Misc07", Protagonist, 2000, 0, 0)
~ JOURNAL #2292 GOTO 8
  IF ~  Kit(Protagonist,CLERIC_SELUNE)
!Global("Emma_Gave_Blade","GLOBAL",1)
~ THEN REPLY #2365 DO ~SetGlobal("Emma_Gave_Blade","GLOBAL",1)~ GOTO 32
  IF ~  !ClassEx(Protagonist,PALADIN)
ClassEx(Protagonist,MONK)
~ THEN REPLY #33517 DO ~TakePartyItem("00SWDL09")
~ GOTO 31
  IF ~  ClassEx(Protagonist,PALADIN)
!ClassEx(Protagonist,MONK)
~ THEN REPLY #33517 DO ~TakePartyItem("00SWDL09")
~ GOTO 31
END

IF ~~ THEN BEGIN 22
  SAY #2371
  IF ~~ THEN REPLY #2354 EXIT
END

IF WEIGHT #1 ~  Global("Druid_Aid_Quest","GLOBAL",3)
~ THEN BEGIN 23
  SAY #2372
  IF ~~ THEN REPLY #2373 DO ~SetCriticalPathObject(Myself,FALSE)~ GOTO 24
END

IF ~~ THEN BEGIN 24
  SAY #2377
  IF ~~ THEN REPLY #2378 DO ~FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)~ GOTO 25
END

IF ~~ THEN BEGIN 25
  SAY #2379
  IF ~~ THEN REPLY #2316 EXIT
END

IF WEIGHT #0 ~  Global("2001_Emma_Orcs_Dead","GLOBAL",0)
~ THEN BEGIN 26
  SAY #2380
  IF ~~ THEN REPLY #2381 DO ~SetNumTimesTalkedTo(0)~ EXIT
  IF ~~ THEN REPLY #31506 DO ~SetNumTimesTalkedTo(0)~ EXIT
END

IF WEIGHT #7 ~  NumTimesTalkedToGT(0)
~ THEN BEGIN 27
  SAY #2382
  IF ~~ THEN REPLY #2302 GOTO 2
END

IF ~~ THEN BEGIN 28
  SAY #2383
  IF ~~ THEN REPLY #2384 DO ~GiveItem("00SWDL09", Protagonist)~ GOTO 29
END

IF ~~ THEN BEGIN 29
  SAY #2385
  IF ~~ THEN REPLY #2354 EXIT
  IF ~!NumInParty(6)
!Global("US_VREK_JOIN","GLOBAL",1)
~ THEN REPLY ~Before we leave, would you consider joining us?  The horde has laid claim to Shaengarne Bridge, and Lord Ulbrec has asked us to retake the bridge.  We would be grateful if you would lend us your assistance.~ GOTO EmmaJoin1
END

IF ~~ THEN BEGIN 30
  SAY #33519
  IF ~~ THEN REPLY #2316 EXIT
  IF ~!NumInParty(6)
!Global("US_VREK_JOIN","GLOBAL",1)
~ THEN REPLY ~Before we leave, would you consider joining us?  The horde has laid claim to Shaengarne Bridge, and Lord Ulbrec has asked us to retake the bridge.  We would be grateful if you would lend us your assistance.~ GOTO EmmaJoin1
END

IF ~~ THEN BEGIN 31
  SAY #33521
  IF ~~ THEN REPLY #2370 GOTO 8
END

IF ~~ THEN BEGIN 32
  SAY #33986
  IF ~~ THEN REPLY #2384 DO ~GiveItem("00SWDL09", Protagonist)~ GOTO 33
END

IF ~~ THEN BEGIN 33
  SAY #33987
  IF ~~ THEN REPLY #2370 GOTO 8
END

IF ~~ THEN BEGIN EmmaJoin1
  SAY ~These orcs have concerned me as well.  If you need any assistance, I will gladly provide it.~
  IF ~~ THEN DO ~SetGlobal("US_Emma_Joined", "GLOBAL", 1)
ApplySpellRES("USEMMAC",Myself)~ EXIT
END
