// Radeal, the Eclipse Kensai
// Nrodlek, the Eclilpse Ant-Paladin
// Radnuht, the Eclipse Barbarian
// Reffus, the Eclipse Cleric
// Ylekilnu, the Eclipse Druid
// Citpeks, the Eclipse Sorcerer

BEGIN solae1

IF ~NumTimesTalkedTo(0)~ THEN BEGIN e1_1
  SAY @1
  IF ~~ THEN REPLY @2 DO ~SetGlobal("SolaSerious","GLOBAL",1)~ GOTO e1_3
  IF ~~ THEN REPLY @3 GOTO e1_2
  IF ~~ THEN REPLY @4 GOTO e1_4
  IF ~~ THEN REPLY @5 GOTO e1_letsdance
END

IF ~~ THEN BEGIN e1_2
  SAY @6
  IF ~~ THEN GOTO e1_paralyze
END

IF ~~ THEN BEGIN e1_paralyze
  SAY @99
  IF ~~ THEN GOTO e1_3
END

IF ~~ THEN BEGIN e1_4
  SAY @8
  IF ~~ THEN GOTO e1_3
END

IF ~~ THEN BEGIN e1_3
  SAY @7 
  IF ~~ THEN GOTO e1_10
END

IF ~~ THEN BEGIN e1_10
  SAY @9
  IF ~!Global("SolaSerious","GLOBAL",1)~ THEN REPLY @10 GOTO e1_11
  IF ~~ THEN REPLY @11 GOTO e1_end
END

IF ~~ THEN BEGIN e1_11
  SAY @12
  IF ~OR(2)
PartyHasItem("sw2h10")
PartyHasItem("sw2h19")~ THEN   EXTERN solae2 e2_holy
  IF ~!PartyHasItem("sw2h10")
!PartyHasItem("sw2h19")~ THEN  GOTO e1_12
END

IF ~~ THEN BEGIN e1_holy
  SAY @14
  IF ~~ THEN GOTO e1_12
END

IF ~~ THEN BEGIN e1_12
  SAY @15
  IF ~PartyHasItem("sw1h51")~ THEN EXTERN solae3 e3_fury
  IF ~!PartyHasItem("sw1h51")~ THEN EXTERN solae6 e6_wearoff
END

IF ~~ THEN BEGIN e1_fury
  SAY @17
  IF ~~ THEN EXTERN solae6 e6_wearoff
END

IF ~~ THEN BEGIN e1_wearoff
  SAY @19
  IF ~PartyHasItem("wa2robe")~ THEN EXTERN solae6 e6_robe
  IF ~!PartyHasItem("wa2robe")~ THEN GOTO e1_13
END

IF ~~ THEN BEGIN e1_robe
  SAY @21
  IF ~~ THEN GOTO e1_13
END

IF ~~ THEN BEGIN e1_13
  SAY @22
  IF ~~ THEN EXTERN solae4 e4_negate
END

IF ~~ THEN BEGIN e1_crom
  SAY @26
  IF ~~ THEN EXTERN solae5 e5_plan
END

IF ~~ THEN BEGIN e1_plan
  SAY @28
  IF ~~ THEN GOTO e1_curious
END

IF ~~ THEN BEGIN e1_curious
  SAY @29
  IF ~~ THEN REPLY @30 GOTO e1_ambig
  IF ~~ THEN REPLY @31 GOTO e1_ambig
  IF ~~ THEN REPLY @32 GOTO e1_ambig
END

IF ~~ THEN BEGIN e1_ambig
  SAY @33
  IF ~~ THEN GOTO e1_come
END

IF ~~ THEN BEGIN e1_come
  SAY @34
  IF  ~PartyHasItem("halb11")~ THEN EXTERN solae2 e2_ravager
  IF ~!PartyHasItem("halb11")~ THEN GOTO e1_example
END

IF ~~ THEN BEGIN e1_ravager
  SAY @36
  IF ~~ THEN GOTO e1_example
END

IF ~~ THEN BEGIN e1_example
  SAY @37
  IF ~~ THEN EXTERN solae6 e6_notfond
END

IF ~~ THEN BEGIN e1_foebane
  SAY @40
  IF ~~ THEN GOTO e1_protect
END

IF ~~ THEN BEGIN e1_protect
  SAY @41
  IF ~~ THEN REPLY @42 GOTO e1_wait
  IF ~~ THEN REPLY @43 GOTO e1_none
  IF ~~ THEN REPLY @44 GOTO e1_ego
END

IF ~~ THEN BEGIN e1_wait
  SAY @45 IF ~~ THEN GOTO e1_ignore
END

IF ~~ THEN BEGIN e1_none
  SAY @46 IF ~~ THEN GOTO e1_ignore
END

IF ~~ THEN BEGIN e1_ego
  SAY @47 IF ~~ THEN GOTO e1_ignore
END

IF ~~ THEN BEGIN e1_ignore
  SAY @48 
  IF ~~ THEN EXTERN solae5 e5_soundnice
END

IF ~~ THEN BEGIN e1_soundnice
  SAY @50 
  IF ~~ THEN GOTO e1_humble
END

IF ~~ THEN BEGIN e1_humble
  SAY @51 
  IF ~~ THEN GOTO e1_secret
END

IF ~~ THEN BEGIN e1_secret
  SAY @52 
  IF ~~ THEN EXTERN solae6 e6_skipthat
END

IF ~~ THEN BEGIN e1_skipthat
  SAY @54 IF ~~ THEN GOTO e1_rant1
END

IF ~~ THEN BEGIN e1_rant1
  SAY @55 IF ~~ THEN GOTO e1_rant2
END

IF ~~ THEN BEGIN e1_rant2
  SAY @56 IF ~~ THEN GOTO e1_rant3
END

IF ~~ THEN BEGIN e1_rant3
  SAY @57 IF ~~ THEN EXTERN solae2 e2_why
END

IF ~~ THEN BEGIN e1_end
  SAY @59 IF ~~ THEN GOTO e1_letsdance
END

IF ~~ THEN BEGIN e1_letsdance
  SAY @60 IF ~~ THEN EXTERN sola preserveme
END

IF ~~ THEN BEGIN e1_sigh
  SAY @24
  IF ~PartyHasItem("hamm09")~ THEN EXTERN solae3 e3_crom
  IF ~!PartyHasItem("hamm09")~ THEN EXTERN solae5 e5_plan
END

APPEND sola
  IF ~~ THEN BEGIN preserveme
    SAY @61 IF ~~ THEN DO ~ReallyForceSpell(Myself,4996)~ EXIT
  END
END

///// 
///// Nrodlek
BEGIN solae2

IF ~~ THEN BEGIN e2_holy
  SAY @13
  IF ~~ THEN EXTERN solae1 e1_holy
END

IF ~~ THEN BEGIN e2_ravager
  SAY @35
  IF ~~ THEN EXTERN solae1 e1_ravager
END

IF ~~ THEN BEGIN e2_why
  SAY @58
  IF ~~ THEN EXTERN solae1 e1_end
END

///// Radnuht, the Eclipse Barbarian
BEGIN solae3

IF ~~ THEN BEGIN e3_fury
  SAY @16
  IF ~~ THEN EXTERN solae1 e1_fury
END

IF ~~ THEN BEGIN e3_crom
  SAY @25
  IF ~~ THEN EXTERN solae1 e1_crom
END

// Reffus, the Eclipse Cleric
BEGIN solae4

IF ~NumTimesTalkedTo(0)~ THEN BEGIN start_conversation
  SAY @62
  IF ~~ THEN EXTERN solae1 e1_1
END

IF ~~ THEN BEGIN e4_negate
  SAY @23
  IF ~~ THEN EXTERN solae1 e1_sigh
END

IF ~~ THEN BEGIN e4_foebane
  SAY @39
  IF ~~ THEN EXTERN solae1 e1_foebane
END

// Ylekilnu, the Eclipse Druid
BEGIN solae5

IF ~~ THEN BEGIN e5_plan
  SAY @27
  IF ~~ THEN EXTERN solae1 e1_plan
END

IF ~~ THEN BEGIN e5_soundnice
  SAY @49
  IF ~~ THEN EXTERN solae1 e1_soundnice
END

// Citpeks, the Eclipse Sorcerer
BEGIN solae6

IF ~~ THEN BEGIN e6_wearoff
  SAY @18
  IF ~~ THEN EXTERN solae1 e1_wearoff
END

IF ~~ THEN BEGIN e6_robe
  SAY @20
  IF ~~ THEN EXTERN solae1 e1_robe
END

IF ~~ THEN BEGIN e6_notfond
  SAY @38
  IF  ~PartyHasItem("sw1h63")~ THEN EXTERN solae4 e4_foebane
  IF ~!PartyHasItem("sw1h63")~ THEN EXTERN solae1 e1_protect
END

IF ~~ THEN BEGIN e6_skipthat
  SAY @53
  IF ~~ THEN EXTERN solae1 e1_skipthat
END
