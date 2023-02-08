BEGIN ~USVREKJ~

IF ~InParty(Myself)
Global("BANTERUSVREKJ","GLOBAL",1)~ THEN BEGIN 0
  SAY @40568
  IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVEIR)")
IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USGEOF)")~ THEN REPLY @40571 DO ~SetGlobal("DIDBANTERUSVREKJ1","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)~ EXTERN ~USGEOFJ~ 66
  IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVEIR)")
IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USGEOF)")~ THEN REPLY @40572 DO ~SetGlobal("DIDBANTERUSVREKJ1","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)~ EXTERN ~USGEOFJ~ 71
  IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVEIR)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USGEOF)")~ THEN REPLY @40573 DO ~SetGlobal("DIDBANTERUSVREKJ1","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)~ EXIT
  IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVEIR)")
IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USGEOF)")~ THEN REPLY @40574 DO ~SetGlobal("DIDBANTERUSVREKJ1","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)~ EXTERN ~USGEOFJ~ 72
  IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVEIR)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USGEOF)")~ THEN REPLY @40574 DO ~SetGlobal("DIDBANTERUSVREKJ1","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)~ EXIT
  IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")
!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVEIR)")~ THEN REPLY @40575 DO ~SetGlobal("DIDBANTERUSVREKJ1","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVUNA)")~ THEN DO ~SetGlobal("DIDBANTERUSVREKJ1","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)~ EXTERN ~USVUNAJ~ 3
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USEMMA)")~ THEN DO ~SetGlobal("DIDBANTERUSVREKJ1","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)~ EXTERN ~USEMMAJ~ 11
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")~ THEN DO ~SetGlobal("DIDBANTERUSVREKJ1","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)~ EXTERN ~USREIGJ~ 79
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USVEIR)")~ THEN DO ~SetGlobal("DIDBANTERUSVREKJ1","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)~ EXTERN ~USVEIRJ~ 0
END

IF ~InParty(Myself)
Global("BANTERUSVREKJ","GLOBAL",2)~ THEN BEGIN 1
  SAY @40715
  IF ~~ THEN REPLY @40716 DO ~SetGlobal("DIDBANTERUSVREKJ2","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)~ GOTO 2
  IF ~~ THEN REPLY @40717 DO ~SetGlobal("DIDBANTERUSVREKJ2","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)~ GOTO 3
  IF ~~ THEN REPLY @40718 DO ~SetGlobal("DIDBANTERUSVREKJ2","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)~ GOTO 4
  IF ~PartyHasItem("30WSPIDQ")~ THEN REPLY @40719 DO ~SetGlobal("DIDBANTERUSVREKJ2","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)
TakePartyItem("30WSPIDQ")
DestroyItem("30WSPIDQ")
AddXPVar("Level_5_Easy",40732)~ GOTO 6
  IF ~!PartyHasItem("30WSPIDQ")
PartyHasItem("30WSPIDR")~ THEN REPLY @40719 DO ~SetGlobal("DIDBANTERUSVREKJ2","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)
TakePartyItem("30WSPIDR")
DestroyItem("30WSPIDR")
AddXPVar("Level_5_Easy",40732)~ GOTO 6
END

IF ~~ THEN BEGIN 2
  SAY @40720
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 3
  SAY @40721
  IF ~~ THEN REPLY @40722 EXIT
  IF ~~ THEN REPLY @40723 DO ~SetGlobal("US_Promise_Vrek_Eat_Pondmuk","GLOBAL",1)~ GOTO 5
  IF ~~ THEN REPLY @40724 GOTO 2
END

IF ~~ THEN BEGIN 4
  SAY @40725
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 5
  SAY @40726
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 6
  SAY @40727
  IF ~~ THEN GOTO 7
END

IF ~~ THEN BEGIN 7
  SAY @40728
  IF ~~ THEN GOTO 8
END

IF ~~ THEN BEGIN 8
  SAY @40727
  IF ~~ THEN REPLY @40729 GOTO 5
  IF ~~ THEN REPLY @40730 EXIT
  IF ~~ THEN REPLY @40731 EXIT
END

IF ~~ THEN BEGIN 9
  SAY @40733
  IF ~~ THEN DO ~ApplySpellRES("USCHUNK","Pondmuk")
AddXPVar("Level_5_Easy",40734)~ EXIT
END

IF ~InParty(Myself)
Global("BANTERUSVREKJ","GLOBAL",3)~ THEN BEGIN 10
  SAY @40814
  IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")~ THEN REPLY @40817 DO ~SetGlobal("DIDBANTERUSVREKJ3","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)~ EXIT
  IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")~ THEN REPLY @40819 DO ~SetGlobal("DIDBANTERUSVREKJ3","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)~ EXIT
  IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")
CheckSkillGT(Protagonist,9,Wilderness_Lore)~ THEN REPLY @40820 DO ~SetGlobal("DIDBANTERUSVREKJ3","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)~ EXIT
  IF ~!IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")~ THEN REPLY @40821 DO ~SetGlobal("DIDBANTERUSVREKJ3","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)~ GOTO 11
  IF ~IEex_LuaTrigger("return IEex_IfValidForPartyDialogue(USREIG)")~ THEN DO ~SetGlobal("DIDBANTERUSVREKJ3","GLOBAL",1)
SetGlobal("BANTERUSVREKJ","GLOBAL",0)~ EXTERN ~USREIGJ~ 98
END

IF ~~ THEN BEGIN 11
  SAY @40835
  IF ~~ THEN REPLY @40836 GOTO 12
  IF ~~ THEN REPLY @40837 GOTO 13
END

IF ~~ THEN BEGIN 12
  SAY @40838
  IF ~~ THEN REPLY @40839 GOTO 15
  IF ~~ THEN REPLY @40840 GOTO 15
END

IF ~~ THEN BEGIN 13
  SAY @40841
  IF ~~ THEN REPLY @40842 GOTO 12
  IF ~~ THEN REPLY @40843 GOTO 14
END

IF ~~ THEN BEGIN 14
  SAY @40844
  IF ~~ THEN REPLY @40845 EXIT
  IF ~~ THEN REPLY @40846 GOTO 12
END

IF ~~ THEN BEGIN 15
  SAY @40847
  IF ~~ THEN REPLY @40848 GOTO 16
  IF ~~ THEN REPLY @40849 GOTO 17
END

IF ~~ THEN BEGIN 16
  SAY @40850
  IF ~~ THEN REPLY @40851 GOTO 18
END

IF ~~ THEN BEGIN 17
  SAY @40852
  IF ~~ THEN REPLY @40853 GOTO 18
END

IF ~~ THEN BEGIN 18
  SAY @40854
  IF ~CheckSkillLT(Protagonist,10,Knowledge_Arcana)~ THEN REPLY @40882 EXIT
  IF ~CheckSkillGT(Protagonist,9,Knowledge_Arcana)~ THEN REPLY @40855 EXIT
END