BEGIN ~USGEOFJ~

IF ~~ THEN BEGIN 0
  SAY @40179
  IF ~~ THEN EXTERN ~USREIGJ~ 1
END

IF ~~ THEN BEGIN 1
  SAY @40181
  IF ~~ THEN EXTERN ~USREIGJ~ 2
END

IF ~~ THEN BEGIN 2
  SAY @40183
  IF ~~ THEN EXTERN ~USREIGJ~ 3
END

IF ~~ THEN BEGIN 3
  SAY @40185
  IF ~~ THEN EXTERN ~USREIGJ~ 4
END

IF ~~ THEN BEGIN 4
  SAY @40187
  IF ~~ THEN EXIT
END

IF ~InParty(Myself)
Global("BANTERUSGEOFJ","GLOBAL",1)~ THEN BEGIN 5
  SAY @40411
  IF ~~ THEN REPLY @40412 DO ~SetGlobal("DIDBANTERUSGEOFJ1","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 6
  IF ~~ THEN REPLY @40413 DO ~SetGlobal("DIDBANTERUSGEOFJ1","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXIT
  IF ~~ THEN REPLY @40414 DO ~SetGlobal("DIDBANTERUSGEOFJ1","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 7
  IF ~~ THEN REPLY @40415 DO ~SetGlobal("DIDBANTERUSGEOFJ1","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 8
  IF ~~ THEN REPLY @40416 DO ~SetGlobal("DIDBANTERUSGEOFJ1","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 9
END

IF ~~ THEN BEGIN 6
  SAY @40417
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 7
  SAY @40418
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 8
  SAY @40419
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 9
  SAY @40420
  IF ~~ THEN EXIT
END

IF ~InParty(Myself)
Global("BANTERUSGEOFJ","GLOBAL",2)~ THEN BEGIN 10
  SAY @40425
  IF ~PartyGoldGT(4999)~ THEN REPLY @40426 DO ~SetGlobal("DIDBANTERUSGEOFJ2","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXIT
  IF ~~ THEN REPLY @40427 DO ~SetGlobal("DIDBANTERUSGEOFJ2","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXIT
  IF ~Global("S_R_3","GLOBAL",0)~ THEN REPLY @40428 DO ~SetGlobal("DIDBANTERUSGEOFJ2","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 11
  IF ~~ THEN REPLY @40429 DO ~SetGlobal("DIDBANTERUSGEOFJ2","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 13
END

IF ~~ THEN BEGIN 11
  SAY @40430
  IF ~~ THEN REPLY @40431 GOTO 12
  IF ~~ THEN REPLY @40432 GOTO 12
  IF ~~ THEN REPLY @40433 EXIT
END

IF ~~ THEN BEGIN 12
  SAY @40434
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 13
  SAY @40435
  IF ~~ THEN REPLY @40436 GOTO 14
  IF ~~ THEN REPLY @40437 EXIT
END

IF ~~ THEN BEGIN 14
  SAY @40438
  IF ~~ THEN EXIT
END

IF ~InParty(Myself)
Global("BANTERUSGEOFJ","GLOBAL",3)~ THEN BEGIN 15
  SAY @40439
  IF ~~ THEN REPLY @40443 DO ~SetGlobal("DIDBANTERUSGEOFJ3","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXIT
  IF ~~ THEN REPLY @40440 DO ~SetGlobal("DIDBANTERUSGEOFJ3","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 16
  IF ~~ THEN REPLY @40441 DO ~SetGlobal("DIDBANTERUSGEOFJ3","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 21
  IF ~~ THEN REPLY @40442 DO ~SetGlobal("DIDBANTERUSGEOFJ3","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 22
  IF ~CheckStatGT(Protagonist,4,KNOWLEDGEARCANA)~ THEN REPLY @40456 DO ~SetGlobal("DIDBANTERUSGEOFJ3","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 23
END

IF ~~ THEN BEGIN 16
  SAY @40444
  IF ~~ THEN REPLY @40445 GOTO 17
  IF ~~ THEN REPLY @40446 GOTO 19
  IF ~~ THEN REPLY @40447 GOTO 20
END

IF ~~ THEN BEGIN 17
  SAY @40448
  IF ~~ THEN REPLY @40449 EXIT
  IF ~~ THEN REPLY @40450 GOTO 18
END

IF ~~ THEN BEGIN 18
  SAY @40451
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 19
  SAY @40452
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 20
  SAY @40453
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 21
  SAY @40454
  IF ~~ THEN REPLY @40445 GOTO 17
  IF ~~ THEN REPLY @40446 GOTO 19
  IF ~~ THEN REPLY @40447 GOTO 20
END

IF ~~ THEN BEGIN 22
  SAY @40455
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 23
  SAY @40457
  IF ~~ THEN EXIT
END

IF ~InParty(Myself)
Global("BANTERUSGEOFJ","GLOBAL",4)~ THEN BEGIN 24
  SAY @40458
  IF ~~ THEN REPLY @40459 DO ~SetGlobal("DIDBANTERUSGEOFJ4","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 25
  IF ~~ THEN REPLY @40460 DO ~SetGlobal("DIDBANTERUSGEOFJ4","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 26
  IF ~LevelInClass(Protagonist,0,PALADIN)
!Kit(Protagonist,CLERIC_SELUNE)~ THEN REPLY @40461 DO ~SetGlobal("DIDBANTERUSGEOFJ4","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXIT
  IF ~Kit(Protagonist,CLERIC_SELUNE)~ THEN REPLY @40462 DO ~SetGlobal("DIDBANTERUSGEOFJ4","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 27
  IF ~~ THEN REPLY #22378 DO ~SetGlobal("DIDBANTERUSGEOFJ4","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 27
END

IF ~~ THEN BEGIN 25
  SAY @40463
  IF ~~ THEN REPLY @40464 GOTO 27
  IF ~~ THEN REPLY @40465 GOTO 27
END

IF ~~ THEN BEGIN 26
  SAY @40466
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 27
  SAY @40467
  IF ~~ THEN EXIT
END

IF ~InParty(Myself)
Global("BANTERUSGEOFJ","GLOBAL",5)~ THEN BEGIN 28
  SAY @40468
  IF ~~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ5","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXIT
END

IF ~InParty(Myself)
Global("BANTERUSGEOFJ","GLOBAL",6)~ THEN BEGIN 29
  SAY @40469
  IF ~~ THEN REPLY @40470 DO ~SetGlobal("DIDBANTERUSGEOFJ6","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 30
  IF ~~ THEN REPLY @40471 DO ~SetGlobal("DIDBANTERUSGEOFJ6","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXIT
END

IF ~~ THEN BEGIN 30
  SAY @40472
  IF ~~ THEN EXIT
END

IF ~InParty(Myself)
Global("BANTERUSGEOFJ","GLOBAL",7)~ THEN BEGIN 31
  SAY @40473
  IF ~~ THEN REPLY @40474 DO ~SetGlobal("DIDBANTERUSGEOFJ7","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 32
  IF ~~ THEN REPLY @40475 DO ~SetGlobal("DIDBANTERUSGEOFJ7","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 33
  IF ~~ THEN REPLY @40476 DO ~SetGlobal("DIDBANTERUSGEOFJ7","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 33
END

IF ~~ THEN BEGIN 32
  SAY @40477
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 33
  SAY @40478
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 34
  SAY @40479
  IF ~~ THEN EXIT
END

IF ~InParty(Myself)
Global("BANTERUSGEOFJ","GLOBAL",8)~ THEN BEGIN 35
  SAY @40480
  IF ~~ THEN REPLY @40481 DO ~SetGlobal("DIDBANTERUSGEOFJ8","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)
ApplySpellRES("USGEOFMB",Myself)~ GOTO 36
  IF ~GlobalLT("SR_Emma_Revenge","GLOBAL",2)~ THEN REPLY @40482 DO ~SetGlobal("DIDBANTERUSGEOFJ8","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 37
  IF ~Or(3)
  CheckStatGT(Protagonist,7,KNOWLEDGEARCANA)
  LevelInClassGT(Protagonist,0,CLERIC)
  LevelInClassGT(Protagonist,0,PALADIN)~ THEN REPLY @40483 DO ~SetGlobal("DIDBANTERUSGEOFJ8","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 38
END

IF ~~ THEN BEGIN 36
  SAY @40484
  IF ~~ THEN REPLY @40485 GOTO 40
  IF ~Alignment(Protagonist,MASK_GOOD)~ THEN REPLY @40486 GOTO 42
  IF ~!Alignment(Protagonist,MASK_GOOD)~ THEN REPLY @40486 DO ~ApplySpellRES("USGEOFMB",Protagonist)~ GOTO 43
END

IF ~~ THEN BEGIN 37
  SAY @40487
  IF ~~ THEN DO ~ApplySpellRES("USGEOFMB",Myself)~ GOTO 36
END

IF ~~ THEN BEGIN 38
  SAY @40488
  IF ~~ THEN DO ~ApplySpellRES("USGEOFMB",Myself)~ GOTO 39
END

IF ~~ THEN BEGIN 39
  SAY @40489
  IF ~~ THEN REPLY @40490 GOTO 40
END

IF ~~ THEN BEGIN 40
  SAY @40491
  IF ~GlobalLT("SR_Emma_Revenge","GLOBAL",2)~ THEN REPLY @40492 GOTO 41
  IF ~~ THEN REPLY @40493 EXIT
END

IF ~~ THEN BEGIN 41
  SAY @40494
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 42
  SAY @40495
  IF ~GlobalLT("SR_Emma_Revenge","GLOBAL",2)~ THEN REPLY @40492 GOTO 41
  IF ~~ THEN REPLY @40496 EXIT
  IF ~~ THEN REPLY @40493 EXIT
END

IF ~~ THEN BEGIN 43
  SAY @40497
  IF ~GlobalLT("SR_Emma_Revenge","GLOBAL",2)~ THEN REPLY @40492 GOTO 41
  IF ~~ THEN REPLY @40493 EXIT
END

IF ~InParty(Myself)
Global("BANTERUSGEOFJ","GLOBAL",9)~ THEN BEGIN 44
  SAY @40498
  IF ~~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ9","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USEMMAJ~ 1
END

IF ~~ THEN BEGIN 45
  SAY @40500
  IF ~~ THEN DO ~~ EXTERN ~USEMMAJ~ 2
END

IF ~InParty(Myself)
Global("BANTERUSGEOFJ","GLOBAL",10)~ THEN BEGIN 46
  SAY @40522
  IF ~~ THEN REPLY @40523 DO ~SetGlobal("DIDBANTERUSGEOFJ10","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 32
  IF ~~ THEN REPLY @40524 DO ~SetGlobal("DIDBANTERUSGEOFJ10","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 33
  IF ~~ THEN REPLY @40525 DO ~SetGlobal("DIDBANTERUSGEOFJ10","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 33
END

IF ~~ THEN BEGIN 47
  SAY @40526
  IF ~~ THEN GOTO 54
END

IF ~~ THEN BEGIN 48
  SAY @40527
  IF ~~ THEN GOTO 54
END

IF ~~ THEN BEGIN 49
  SAY @40528
  IF ~~ THEN REPLY @40529 GOTO 50
  IF ~~ THEN REPLY @40530 GOTO 51
  IF ~~ THEN REPLY @40531 GOTO 52
  IF ~~ THEN REPLY @40532 GOTO 53
END

IF ~~ THEN BEGIN 50
  SAY @40533
  IF ~~ THEN GOTO 54
END

IF ~~ THEN BEGIN 51
  SAY @40534
  IF ~~ THEN GOTO 54
END

IF ~~ THEN BEGIN 52
  SAY @40535
  IF ~~ THEN GOTO 54
END

IF ~~ THEN BEGIN 53
  SAY @40536
  IF ~~ THEN GOTO 54
END

IF ~~ THEN BEGIN 54
  SAY @40537
  IF ~~ THEN GOTO 55
END

IF ~~ THEN BEGIN 55
  SAY @40538
  IF ~~ THEN GOTO 56
END

IF ~~ THEN BEGIN 56
  SAY @40539
  IF ~Gender(Protagonist,MALE)~ THEN REPLY @40540 GOTO 57
  IF ~Gender(Protagonist,FEMALE)~ THEN REPLY @40541 GOTO 58
  IF ~~ THEN REPLY @40542 GOTO 61
  IF ~~ THEN REPLY @40543 GOTO 60
  IF ~~ THEN REPLY @40544 GOTO 63
  IF ~CheckStatGT(Protagonist,13,CHR)~ THEN REPLY @40545 GOTO 64
END

IF ~~ THEN BEGIN 57
  SAY @40546
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 58
  SAY @40547
  IF ~~ THEN REPLY @40548 GOTO 59
  IF ~~ THEN REPLY @40549 GOTO 60
  IF ~~ THEN REPLY @40550 EXIT
END

IF ~~ THEN BEGIN 59
  SAY @40551
  IF ~~ THEN REPLY @40552 EXIT
END

IF ~~ THEN BEGIN 60
  SAY @40553
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 61
  SAY @40554
  IF ~~ THEN REPLY @40555 GOTO 62
  IF ~~ THEN REPLY @40556 EXIT
  IF ~~ THEN REPLY @40557 EXIT
  IF ~~ THEN REPLY @40558 GOTO 62
END

IF ~~ THEN BEGIN 62
  SAY @40559
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 63
  SAY @40560
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 64
  SAY @40561
  IF ~~ THEN REPLY @40562 EXIT
  IF ~~ THEN REPLY @40563 EXIT
END

IF ~InParty(Myself)
Global("BANTERUSGEOFJ","GLOBAL",12)~ THEN BEGIN 65
  SAY @40565
  IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVEIR)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVREK)")~ THEN REPLY @40571 DO ~SetGlobal("DIDBANTERUSGEOFJ12","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 66
  IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVEIR)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVREK)")~ THEN REPLY @40572 DO ~SetGlobal("DIDBANTERUSGEOFJ12","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 71
  IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVEIR)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVREK)")~ THEN REPLY @40574 DO ~SetGlobal("DIDBANTERUSGEOFJ12","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 72
  IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVEIR)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVREK)")~ THEN REPLY @40575 DO ~SetGlobal("DIDBANTERUSGEOFJ12","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ12","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USVUNAJ~ 3
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ12","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USEMMAJ~ 11
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ12","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USREIGJ~ 79
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVEIR)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ12","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USVEIRJ~ 0
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVREK)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ12","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USVREKJ~ 0
END

IF ~~ THEN BEGIN 66
  SAY @40577
  IF ~~ THEN REPLY @40578 GOTO 67
  IF ~~ THEN REPLY @40579 GOTO 68
  IF ~~ THEN REPLY @40580 GOTO 69
  IF ~~ THEN REPLY @40581 GOTO 68
END

IF ~~ THEN BEGIN 67
  SAY @40582
  IF ~~ THEN REPLY @40583 GOTO 68
  IF ~~ THEN REPLY @40584 EXIT
  IF ~~ THEN REPLY @40585 GOTO 70
END

IF ~~ THEN BEGIN 68
  SAY @40586
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 69
  SAY @40587
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 70
  SAY @40588
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 71
  SAY @40589
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 72
  SAY @40590
  IF ~~ THEN REPLY @40591 EXIT
  IF ~~ THEN REPLY @40592 GOTO 68
  IF ~~ THEN REPLY @40593 EXIT
END

IF ~~ THEN BEGIN 73
  SAY @40697
  IF ~~ THEN EXTERN ~USVUNAJ~ 27
END

IF ~~ THEN BEGIN 74
  SAY @40699
  IF ~~ THEN EXTERN ~USVUNAJ~ 28
END

IF ~~ THEN BEGIN 75
  SAY @40701
  IF ~~ THEN DO ~SetGlobalTimer("USGEOF_Banter_Timer_13","GLOBAL",1)~ EXIT
END

IF ~InParty(Myself)
Global("BANTERUSGEOFJ","GLOBAL",13)~ THEN BEGIN 76
  SAY @40702
  IF ~~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ13","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USVUNAJ~ 27
END

IF ~InParty(Myself)
Global("BANTERUSGEOFJ","GLOBAL",14)~ THEN BEGIN 77
  SAY @40812
  IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVREK)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")~ THEN REPLY @40817 DO ~SetGlobal("DIDBANTERUSGEOFJ14","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXIT
  IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVREK)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")~ THEN REPLY @40819 DO ~SetGlobal("DIDBANTERUSGEOFJ14","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXIT
  IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVREK)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")
CheckSkillGT(Protagonist,9,Wilderness_Lore)~ THEN REPLY @40820 DO ~SetGlobal("DIDBANTERUSGEOFJ14","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ14","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USREIGJ~ 98
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVREK)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ14","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USVREKJ~ 10
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ14","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USEMMAJ~ 49
END

IF ~InParty(Myself)
Global("BANTERUSGEOFJ","GLOBAL",15)~ THEN BEGIN 78
  SAY @40890
  IF ~~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ15","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXIT
END

IF ~InParty(Myself)
Global("BANTERUSGEOFJ","GLOBAL",16)~ THEN BEGIN 79
  SAY @40982
  IF ~~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ16","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USXHAA)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ16","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USXHAAJ~ 15
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ16","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USVUNAJ~ 35
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USZACK)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ16","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USZACKJ~ 34
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ16","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USEMMAJ~ 71
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ16","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USREIGJ~ 107
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USPAIR)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ16","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USPAIRJ~ 1
END

IF ~~ THEN BEGIN 80
  SAY @41030
  IF ~~ THEN EXTERN ~USVUNAJ~ 41
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")~ THEN EXTERN ~USREIGJ~ 108
END

IF ~~ THEN BEGIN 81
  SAY @41091
  IF ~~ THEN EXTERN ~USREIGJ~ 112
END

IF ~InParty(Myself)
Global("BANTERUSGEOFJ","GLOBAL",17)~ THEN BEGIN 82
  SAY @41144
    IF ~~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ17","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ17","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USVUNAJ~ 44
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ17","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USEMMAJ~ 77
END

IF ~InParty(Myself)
Global("BANTERUSGEOFJ","GLOBAL",18)~ THEN BEGIN 83
  SAY @41274
  IF ~LevelInClassGT(Protagonist,0,MONK)~ THEN REPLY @41275 DO ~SetGlobal("DIDBANTERUSGEOFJ18","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 84
  IF ~Or(2)
  LevelInClassGT(Protagonist,0,MONK)
  CheckStatGT(Protagonist,17,WIS)~ THEN REPLY @41276 DO ~SetGlobal("DIDBANTERUSGEOFJ18","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 85
  IF ~~ THEN REPLY @41277 DO ~SetGlobal("DIDBANTERUSGEOFJ18","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 86
  IF ~LevelInClass(Protagonist,0,MONK)
CheckStatLT(Protagonist,18,WIS)~ THEN REPLY @41278 DO ~SetGlobal("DIDBANTERUSGEOFJ18","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 87
  IF ~LevelInClass(Protagonist,0,MONK)~ THEN REPLY @41279 DO ~SetGlobal("DIDBANTERUSGEOFJ18","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 88
  IF ~LevelInClass(Protagonist,0,MONK)~ THEN REPLY @41280 DO ~SetGlobal("DIDBANTERUSGEOFJ18","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ GOTO 89
END

IF ~~ THEN BEGIN 84
  SAY @41281
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 85
  SAY @41282
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 86
  SAY @41283
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 87
  SAY @41284
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 88
  SAY @41285
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 89
  SAY @41286
  IF ~~ THEN EXIT
END

IF ~InParty(Myself)
Global("BANTERUSGEOFJ","GLOBAL",19)~ THEN BEGIN 90
  SAY @41295
  IF ~~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ19","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXIT
END

IF ~~ THEN BEGIN 91
  SAY @41354
  IF ~~ THEN EXTERN ~USREIGJ~ 155
END

IF ~~ THEN BEGIN 92
  SAY @41356
  IF ~~ THEN EXTERN ~USREIGJ~ 156
END

IF ~~ THEN BEGIN 93
  SAY @41358
  IF ~~ THEN EXTERN ~USREIGJ~ 157
END

IF ~InParty(Myself)
Global("BANTERUSGEOFJ","GLOBAL",20)~ THEN BEGIN 94
  SAY @41559
    IF ~~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ20","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USZACK)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ20","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USZACKJ~ 77
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVEIR)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ20","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USVEIRJ~ 53
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVREK)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ20","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USVREKJ~ 48
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ20","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USEMMAJ~ 93
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ20","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USVUNAJ~ 99
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ20","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USREIGJ~ 158
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USSERS)")~ THEN DO ~SetGlobal("DIDBANTERUSGEOFJ20","GLOBAL",1)
SetGlobal("BANTERUSGEOFJ","GLOBAL",0)~ EXTERN ~USSERSJ~ 22
END