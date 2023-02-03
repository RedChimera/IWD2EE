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