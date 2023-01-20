BEGIN ~50LIMHA~

IF ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY #8136
  IF ~  ClassEx(Protagonist,PALADIN)
~ THEN REPLY #35545 DO ~StartCutSceneMode()StartCutScene("50cHann0")~ JOURNAL #34747 EXIT
  IF ~  Global("50Venla_Children","Global",1)
!Global("50Carynara","Global",1)
!ClassEx(Protagonist,PALADIN)
~ THEN REPLY #8140 DO ~SetGlobal("50LimhaQ", "Global", 1)~ GOTO 3
  IF ~  Global("50Carynara","Global",1)
!ClassEx(Protagonist,PALADIN)
~ THEN REPLY #8143 GOTO 4
  IF ~  GlobalGT("AR5003_Visited","Global",0)
!Global("50Suoma_Help","Global",5)
!ClassEx(Protagonist,PALADIN)
~ THEN REPLY #8144 GOTO 5
  IF ~  !ClassEx(Protagonist,PALADIN)
~ THEN REPLY #8145 GOTO 1
  IF ~  !ClassEx(Protagonist,PALADIN)
~ THEN REPLY #8146 EXIT
END

IF ~!Global("LimhaAfterHannuDies", "GLOBAL", 1)~ THEN BEGIN 1
  SAY #8147
  IF ~  Global("50Limha","Global",0)
~ THEN REPLY #8148 DO ~SetGlobal("50Limha", "Global", 1)~ GOTO 6
  IF ~  Global("50Limha","Global",1)
~ THEN REPLY #8149 DO ~StartStore("50Limha", Protagonist)~ EXIT
  IF ~~ THEN REPLY #8150 GOTO 8
  IF ~~ THEN REPLY #8151 GOTO 9
  IF ~~ THEN REPLY #8152 GOTO 2
  IF ~~ THEN REPLY #8146 EXIT
END

IF ~~ THEN BEGIN 2
  SAY #8153
  IF ~  Global("50Venla_Children","Global",1)
!Global("50Carynara","Global",1)
~ THEN REPLY #8140 DO ~SetGlobal("50LimhaQ", "Global", 1)~ GOTO 3
  IF ~  Global("50Carynara","Global",1)
~ THEN REPLY #8143 GOTO 4
  IF ~  GlobalGT("AR5003_Visited","Global",0)
!Global("50Suoma_Help","Global",5)
~ THEN REPLY #8144 GOTO 5
  IF ~~ THEN REPLY #8154 GOTO 1
  IF ~~ THEN REPLY #8146 EXIT
END

IF ~~ THEN BEGIN 3
  SAY #8155
  IF ~~ THEN REPLY #8156 GOTO 9
  IF ~  GlobalGT("AR5003_Visited","Global",0)
!Global("50Suoma_Help","Global",5)
~ THEN REPLY #8144 GOTO 5
  IF ~  Global("50Limha","Global",0)
~ THEN REPLY #8158 DO ~SetGlobal("50Limha", "Global", 1)~ GOTO 6
  IF ~  Global("50Limha","Global",1)
~ THEN REPLY #8149 DO ~StartStore("50Limha", Protagonist)~ EXIT
  IF ~~ THEN REPLY #8150 GOTO 8
  IF ~~ THEN REPLY #8159 EXIT
END

IF ~~ THEN BEGIN 4
  SAY #8160
  IF ~~ THEN DO ~StartCutSceneMode()
StartCutScene("50cHann0")~ JOURNAL #8128 EXIT
END

IF ~~ THEN BEGIN 5
  SAY #8162
  IF ~  Global("50Venla_Children","Global",1)
!Global("50Carynara","Global",1)
~ THEN REPLY #8140 DO ~SetGlobal("50LimhaQ", "Global", 1)~ GOTO 3
  IF ~  Global("50Carynara","Global",1)
~ THEN REPLY #8143 GOTO 4
  IF ~  Global("50Limha","Global",0)
~ THEN REPLY #8158 DO ~SetGlobal("50Limha", "Global", 1)~ GOTO 6
  IF ~  Global("50Limha","Global",1)
~ THEN REPLY #8149 DO ~StartStore("50Limha", Protagonist)~ EXIT
  IF ~~ THEN REPLY #8150 GOTO 8
  IF ~~ THEN REPLY #8151 GOTO 9
  IF ~~ THEN REPLY #8159 EXIT
END

IF ~~ THEN BEGIN 6
  SAY #8163
  IF ~~ THEN REPLY #8164 GOTO 7
  IF ~~ THEN REPLY #8149 DO ~StartStore("50Limha", Protagonist)~ EXIT
  IF ~~ THEN REPLY #8150 GOTO 8
  IF ~~ THEN REPLY #8151 GOTO 9
  IF ~~ THEN REPLY #8165 GOTO 2
  IF ~~ THEN REPLY #8159 EXIT
END

IF ~~ THEN BEGIN 7
  SAY #8166
  IF ~~ THEN REPLY #8149 DO ~StartStore("50Limha", Protagonist)~ EXIT
  IF ~~ THEN REPLY #8150 GOTO 8
  IF ~~ THEN REPLY #8151 GOTO 9
  IF ~~ THEN REPLY #8165 GOTO 2
  IF ~~ THEN REPLY #8159 EXIT
END

IF ~~ THEN BEGIN 8
  SAY #8168
  IF ~~ THEN REPLY #8170 DO ~FadeToColor([0.0],0)
FadeFromColor([0.0],0)
RestParty()~ EXIT
  IF ~~ THEN REPLY #8171 DO ~FadeToColor([0.0],0)
FadeFromColor([0.0],0)
RestUntilHealed()~ EXIT
  IF ~~ THEN REPLY #8146 EXIT
END

IF ~~ THEN BEGIN 9
  SAY #8172
  IF ~~ THEN EXTERN ~50AGOG~ 4
END

IF ~~ THEN BEGIN 10
  SAY #8173
  IF ~  Global("50Limha","Global",0)
~ THEN REPLY #8148 DO ~SetGlobal("50Limha", "Global", 1)~ GOTO 6
  IF ~  Global("50Limha","Global",1)
~ THEN REPLY #8149 DO ~StartStore("50Limha", Protagonist)~ EXIT
  IF ~~ THEN REPLY #8150 GOTO 8
  IF ~~ THEN REPLY #8165 GOTO 2
  IF ~~ THEN REPLY #8159 EXIT
END

IF ~  True()
~ THEN BEGIN 11
  SAY #8174
  IF ~  ClassEx(Protagonist,PALADIN)
~ THEN REPLY #35545 DO ~StartCutSceneMode()
StartCutScene("50cHann0")~ JOURNAL #34747 EXIT
  IF ~  Global("50Venla_Children","Global",1)
!Global("50Carynara","Global",1)
!ClassEx(Protagonist,PALADIN)
~ THEN REPLY #8140 DO ~SetGlobal("50LimhaQ", "Global", 1)~ GOTO 3
  IF ~  Global("50Carynara","Global",1)
!ClassEx(Protagonist,PALADIN)
~ THEN REPLY #8143 GOTO 4
  IF ~  GlobalGT("AR5003_Visited","Global",0)
!Global("50Suoma_Help","Global",5)
!ClassEx(Protagonist,PALADIN)
~ THEN REPLY #8144 GOTO 5
  IF ~  Global("50Limha","Global",0)
!ClassEx(Protagonist,PALADIN)
~ THEN REPLY #8148 DO ~SetGlobal("50Limha", "Global", 1)~ GOTO 6
  IF ~  Global("50Limha","Global",1)
!ClassEx(Protagonist,PALADIN)
~ THEN REPLY #8149 DO ~StartStore("50Limha", Protagonist)~ EXIT
  IF ~  !ClassEx(Protagonist,PALADIN)
~ THEN REPLY #8150 GOTO 8
  IF ~  !ClassEx(Protagonist,PALADIN)
~ THEN REPLY #8151 GOTO 9
  IF ~  !ClassEx(Protagonist,PALADIN)
~ THEN REPLY #8175 EXIT
END

IF ~~ THEN BEGIN 12
  SAY #8176
  IF ~~ THEN EXTERN ~50AGOG~ 5
END

IF ~~ THEN BEGIN 13
  SAY #8177
  IF ~~ THEN REPLY #8178 JOURNAL #8126 GOTO 14
END

IF ~~ THEN BEGIN 14
  SAY #8180
  IF ~~ THEN REPLY #8185 GOTO 15
  IF ~~ THEN REPLY #8186 GOTO 15
END

IF ~~ THEN BEGIN 15
  SAY #8187
  IF ~~ THEN GOTO 16
END

IF ~~ THEN BEGIN 16
  SAY #8188
  IF ~~ THEN REPLY #8189 GOTO 17
  IF ~~ THEN REPLY #8190 GOTO 17
  IF ~Global("USSUOMA_SCARED", "Global", 1)~ THEN REPLY @6065 GOTO IgnoreLimha
END

IF ~~ THEN BEGIN 17
  SAY #8191
  IF ~~ THEN GOTO 18
END

IF ~~ THEN BEGIN 18
  SAY #8193
  IF ~~ THEN REPLY #8194 GOTO 19
END

IF ~~ THEN BEGIN 19
  SAY @6066
  IF ~~ THEN REPLY @6067 GOTO 22
  IF ~~ THEN REPLY @6068 GOTO 22
END

IF ~~ THEN BEGIN 20
  SAY #8199
  IF ~~ THEN REPLY #8200 GOTO 21
  IF ~~ THEN REPLY #8201 GOTO 21
END

IF ~~ THEN BEGIN 21
  SAY #8202
  IF ~~ THEN REPLY #8203 DO ~Enemy()~ EXTERN ~50HANNU~ 4
END

IF ~Global("LimhaLowHP", "GLOBAL", 1)~ THEN BEGIN LimhaLowHP
  SAY @6069
  IF ~~ THEN DO ~SetGlobal("Limha_Dead","GLOBAL",1)
FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)~ GOTO 26
END

IF ~~ THEN BEGIN 22
  SAY @6070
  IF ~~ THEN REPLY @6071 GOTO 21
  IF ~~ THEN REPLY @6072 GOTO 23
  IF ~~ THEN REPLY @6073 GOTO 21
END

IF ~~ THEN BEGIN 23
  SAY @6074
  IF ~~ THEN REPLY @6075 GOTO 21
  IF ~~ THEN REPLY @6076 GOTO 21
  IF ~~ THEN REPLY @6077 GOTO 21
  IF ~NumInParty(2)~ THEN REPLY @6078 GOTO 24
  IF ~NumInPartyGT(2)~ THEN REPLY @6079 GOTO 24
  IF ~CheckSkillGT(Protagonist,10,Intimidate)~ THEN REPLY @6080 GOTO 27
END

IF ~~ THEN BEGIN 24
  SAY @6081
  IF ~~ THEN REPLY @6082 GOTO 21
  IF ~~ THEN REPLY @6083 GOTO 21
  IF ~!Alignment(Protagonist,MASK_EVIL)~ THEN REPLY @6084 DO ~FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)~ GOTO 25
END

IF ~~ THEN BEGIN 25
  SAY @6085
  IF ~~ THEN REPLY @6086 DO ~Kill(Player1)
Kill(Player2)
Kill(Player3)
Kill(Player4)
Kill(Player5)
Kill(Player6)~ EXIT
END

IF ~~ THEN BEGIN 26
  SAY @6087
  IF ~~ THEN REPLY @6088 DO ~AddExperienceParty(10000)~ EXIT
  IF ~~ THEN REPLY @6089 DO ~AddExperienceParty(10000)
  SetGlobal("US_Limha_Spared","GLOBAL",1)~ EXIT
  IF ~~ THEN REPLY @6090 DO ~AddExperienceParty(10000)~ EXIT
END

IF ~~ THEN BEGIN 27
  SAY @6091
  IF ~!Alignment(Protagonist,MASK_GOOD)
PartyGoldGT(999)~ THEN REPLY @6092 GOTO 29
  IF ~~ THEN REPLY @6093 GOTO 23
  IF ~~ THEN REPLY @6094 GOTO 21
END

IF ~~ THEN BEGIN 28
  SAY @6095
  IF ~!Alignment(Protagonist,MASK_EVIL)~ THEN REPLY @6096 GOTO 32
  IF ~Alignment(Protagonist,MASK_EVIL)~ THEN REPLY @6097 GOTO 30
END

IF ~~ THEN BEGIN 29
  SAY @6095
  IF ~!Alignment(Protagonist,MASK_EVIL)~ THEN REPLY @6096 GOTO 32
  IF ~Alignment(Protagonist,MASK_EVIL)~ THEN REPLY @6097 GOTO 30
END

IF ~~ THEN BEGIN 30
  SAY @6098
  IF ~~ THEN DO ~SetGlobal("US_Limha_Spared","GLOBAL",1)
SetGlobal("Limha_Dead","GLOBAL",1)
FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)
TakePartyGold(1000)~ GOTO 31
END

IF ~~ THEN BEGIN 31
  SAY @6099
  IF ~~ THEN REPLY @6100 DO ~AddExperienceParty(12000)~ EXIT
END

IF ~~ THEN BEGIN 32
  SAY @6101
  IF ~~ THEN REPLY @6102 GOTO 33
END

IF ~~ THEN BEGIN 33
  SAY @6103
  IF ~PartyGoldGT(15000)
CheckSkillLT(Protagonist,5,Diplomacy)~ THEN REPLY @6104 DO ~TakePartyGold(15000)~ DO ~AddExperienceParty(12000)~ GOTO 34
  IF ~PartyGoldGT(10000)
CheckSkillLT(Protagonist,10,Diplomacy)
CheckSkillGT(Protagonist,4,Diplomacy)~ THEN REPLY @6105 DO ~TakePartyGold(10000)~ DO ~AddExperienceParty(12000)~ GOTO 35
  IF ~PartyGoldGT(5000)
CheckSkillLT(Protagonist,20,Diplomacy)
CheckSkillGT(Protagonist,9,Diplomacy)~ THEN REPLY @6106 DO ~TakePartyGold(5000)~ DO ~AddExperienceParty(12000)~ GOTO 35
  IF ~PartyGoldGT(1500)
CheckSkillGT(Protagonist,19,Diplomacy)~ THEN REPLY @6107 DO ~TakePartyGold(1500)~ DO ~AddExperienceParty(12000)~ GOTO 35
  IF ~~ THEN REPLY @6108 GOTO 21
END

IF ~~ THEN BEGIN 34
  SAY @6109
  IF ~~ THEN DO ~SetGlobal("US_Limha_Spared","GLOBAL",1)
SetGlobal("Limha_Dead","GLOBAL",1)
FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)~ GOTO 36
END

IF ~~ THEN BEGIN 35
  SAY @6110
  IF ~~ THEN DO ~SetGlobal("US_Limha_Spared","GLOBAL",1)
SetGlobal("Limha_Dead","GLOBAL",1)
FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)~ GOTO 36
END

IF ~~ THEN BEGIN 36
  SAY @6111
  IF ~~ THEN REPLY @6112 EXIT
END

IF ~~ THEN BEGIN IgnoreLimha
  SAY @6113
  IF ~~ THEN REPLY @6114 GOTO IgnoreLimha2
  IF ~~ THEN REPLY @6115 GOTO IgnoreLimha2
END

IF ~~ THEN BEGIN IgnoreLimha2
  SAY @6116
  IF ~~ THEN DO ~SetGlobal("LimhaAfterHannuDies", "GLOBAL", 1)~ EXTERN ~50HANNU~ 8
END

IF ~Global("LimhaAfterHannuDies", "GLOBAL", 1)~ THEN BEGIN LimhaAfterHannuDies
  SAY #8174
  IF ~~ THEN REPLY #8149 DO ~StartStore("50Limha", Protagonist)~ EXIT
  IF ~~ THEN REPLY #8175 EXIT
END

