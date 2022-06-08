BEGIN ~USSOULBI~

IF WEIGHT #0 ~NumTimesTalkedTo(0)
!IEex_LuaTrigger("return IEex_KnowsSpell(LastSummonerOf(Myself), 6963)")
!Race(Protagonist,TANARI)~ THEN BEGIN SoulGemShatter
  SAY ~Not knowing how to do anything else with the gem, you shatter it and the soul is freed.~
  IF ~~ THEN DO ~IEex_Lua("IEex_ReleaseSoulFromInventory(LastSummonerOf(Myself))")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_1,0)~ EXIT
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
~ THEN BEGIN SoulGem
  SAY ~What will you do with the soul gem?~
  IF ~IsPlayerNumber(Protagonist,1)~ THEN REPLY ~Increase an ability score.~ GOTO SoulGemAbilityScoreP1
  IF ~IsPlayerNumber(Protagonist,2)~ THEN REPLY ~Increase an ability score.~ GOTO SoulGemAbilityScoreP2
  IF ~IsPlayerNumber(Protagonist,3)~ THEN REPLY ~Increase an ability score.~ GOTO SoulGemAbilityScoreP3
  IF ~IsPlayerNumber(Protagonist,4)~ THEN REPLY ~Increase an ability score.~ GOTO SoulGemAbilityScoreP4
  IF ~IsPlayerNumber(Protagonist,5)~ THEN REPLY ~Increase an ability score.~ GOTO SoulGemAbilityScoreP5
  IF ~IsPlayerNumber(Protagonist,6)~ THEN REPLY ~Increase an ability score.~ GOTO SoulGemAbilityScoreP6
  IF ~~ THEN REPLY ~Recharge a magic item.~ DO ~IEex_Lua("IEex_CheckInventoryItems(LastSummonerOf(Myself))")~ GOTO SoulGemRecharge
  IF ~~ THEN REPLY ~Shatter it and free the soul.~ DO ~IEex_Lua("IEex_ReleaseSoulFromInventory(LastSummonerOf(Myself))")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_1,0)~ EXIT
END

IF ~~ THEN BEGIN SoulGemAbilityScoreP1
  SAY ~Which ability score?~
  IF ~GlobalLT("US_Soul_Strength_P1","GLOBAL",2)~ THEN REPLY ~Strength.~ DO ~IncrementGlobal("US_Soul_Strength_P1","GLOBAL",1)
ReallyForceSpellRES("USWSHSTR",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Dexterity_P1","GLOBAL",2)~ THEN REPLY ~Dexterity.~ DO ~IncrementGlobal("US_Soul_Dexterity_P1","GLOBAL",1)
ReallyForceSpellRES("USWSHDEX",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Constitution_P1","GLOBAL",2)~ THEN REPLY ~Constitution.~ DO ~IncrementGlobal("US_Soul_Constitution_P1","GLOBAL",1)
ReallyForceSpellRES("USWSHCON",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Intelligence_P1","GLOBAL",2)~ THEN REPLY ~Intelligence.~ DO ~IncrementGlobal("US_Soul_Intelligence_P1","GLOBAL",1)
ReallyForceSpellRES("USWSHINT",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Wisdom_P1","GLOBAL",2)~ THEN REPLY ~Wisdom.~ DO ~IncrementGlobal("US_Soul_Wisdom_P1","GLOBAL",1)
ReallyForceSpellRES("USWSHWIS",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Charisma_P1","GLOBAL",2)~ THEN REPLY ~Charisma.~ DO ~IncrementGlobal("US_Soul_Charisma_P1","GLOBAL",1)
ReallyForceSpellRES("USWSHCHR",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~~ THEN REPLY ~Never mind.~ GOTO SoulGem
END

IF ~~ THEN BEGIN SoulGemAbilityScoreP2
  SAY ~Which ability score?~
  IF ~GlobalLT("US_Soul_Strength_P2","GLOBAL",2)~ THEN REPLY ~Strength.~ DO ~IncrementGlobal("US_Soul_Strength_P2","GLOBAL",1)
ReallyForceSpellRES("USWSHSTR",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Dexterity_P2","GLOBAL",2)~ THEN REPLY ~Dexterity.~ DO ~IncrementGlobal("US_Soul_Dexterity_P2","GLOBAL",1)
ReallyForceSpellRES("USWSHDEX",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Constitution_P2","GLOBAL",2)~ THEN REPLY ~Constitution.~ DO ~IncrementGlobal("US_Soul_Constitution_P2","GLOBAL",1)
ReallyForceSpellRES("USWSHCON",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Intelligence_P2","GLOBAL",2)~ THEN REPLY ~Intelligence.~ DO ~IncrementGlobal("US_Soul_Intelligence_P2","GLOBAL",1)
ReallyForceSpellRES("USWSHINT",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Wisdom_P2","GLOBAL",2)~ THEN REPLY ~Wisdom.~ DO ~IncrementGlobal("US_Soul_Wisdom_P2","GLOBAL",1)
ReallyForceSpellRES("USWSHWIS",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Charisma_P2","GLOBAL",2)~ THEN REPLY ~Charisma.~ DO ~IncrementGlobal("US_Soul_Charisma_P2","GLOBAL",1)
ReallyForceSpellRES("USWSHCHR",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~~ THEN REPLY ~Never mind.~ GOTO SoulGem
END

IF ~~ THEN BEGIN SoulGemAbilityScoreP3
  SAY ~Which ability score?~
  IF ~GlobalLT("US_Soul_Strength_P3","GLOBAL",2)~ THEN REPLY ~Strength.~ DO ~IncrementGlobal("US_Soul_Strength_P3","GLOBAL",1)
ReallyForceSpellRES("USWSHSTR",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Dexterity_P3","GLOBAL",2)~ THEN REPLY ~Dexterity.~ DO ~IncrementGlobal("US_Soul_Dexterity_P3","GLOBAL",1)
ReallyForceSpellRES("USWSHDEX",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Constitution_P3","GLOBAL",2)~ THEN REPLY ~Constitution.~ DO ~IncrementGlobal("US_Soul_Constitution_P3","GLOBAL",1)
ReallyForceSpellRES("USWSHCON",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Intelligence_P3","GLOBAL",2)~ THEN REPLY ~Intelligence.~ DO ~IncrementGlobal("US_Soul_Intelligence_P3","GLOBAL",1)
ReallyForceSpellRES("USWSHINT",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Wisdom_P3","GLOBAL",2)~ THEN REPLY ~Wisdom.~ DO ~IncrementGlobal("US_Soul_Wisdom_P3","GLOBAL",1)
ReallyForceSpellRES("USWSHWIS",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Charisma_P3","GLOBAL",2)~ THEN REPLY ~Charisma.~ DO ~IncrementGlobal("US_Soul_Charisma_P3","GLOBAL",1)
ReallyForceSpellRES("USWSHCHR",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~~ THEN REPLY ~Never mind.~ GOTO SoulGem
END

IF ~~ THEN BEGIN SoulGemAbilityScoreP4
  SAY ~Which ability score?~
  IF ~GlobalLT("US_Soul_Strength_P4","GLOBAL",2)~ THEN REPLY ~Strength.~ DO ~IncrementGlobal("US_Soul_Strength_P4","GLOBAL",1)
ReallyForceSpellRES("USWSHSTR",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Dexterity_P4","GLOBAL",2)~ THEN REPLY ~Dexterity.~ DO ~IncrementGlobal("US_Soul_Dexterity_P4","GLOBAL",1)
ReallyForceSpellRES("USWSHDEX",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Constitution_P4","GLOBAL",2)~ THEN REPLY ~Constitution.~ DO ~IncrementGlobal("US_Soul_Constitution_P4","GLOBAL",1)
ReallyForceSpellRES("USWSHCON",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Intelligence_P4","GLOBAL",2)~ THEN REPLY ~Intelligence.~ DO ~IncrementGlobal("US_Soul_Intelligence_P4","GLOBAL",1)
ReallyForceSpellRES("USWSHINT",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Wisdom_P4","GLOBAL",2)~ THEN REPLY ~Wisdom.~ DO ~IncrementGlobal("US_Soul_Wisdom_P4","GLOBAL",1)
ReallyForceSpellRES("USWSHWIS",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Charisma_P4","GLOBAL",2)~ THEN REPLY ~Charisma.~ DO ~IncrementGlobal("US_Soul_Charisma_P4","GLOBAL",1)
ReallyForceSpellRES("USWSHCHR",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~~ THEN REPLY ~Never mind.~ GOTO SoulGem
END

IF ~~ THEN BEGIN SoulGemAbilityScoreP5
  SAY ~Which ability score?~
  IF ~GlobalLT("US_Soul_Strength_P5","GLOBAL",2)~ THEN REPLY ~Strength.~ DO ~IncrementGlobal("US_Soul_Strength_P5","GLOBAL",1)
ReallyForceSpellRES("USWSHSTR",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Dexterity_P5","GLOBAL",2)~ THEN REPLY ~Dexterity.~ DO ~IncrementGlobal("US_Soul_Dexterity_P5","GLOBAL",1)
ReallyForceSpellRES("USWSHDEX",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Constitution_P5","GLOBAL",2)~ THEN REPLY ~Constitution.~ DO ~IncrementGlobal("US_Soul_Constitution_P5","GLOBAL",1)
ReallyForceSpellRES("USWSHCON",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Intelligence_P5","GLOBAL",2)~ THEN REPLY ~Intelligence.~ DO ~IncrementGlobal("US_Soul_Intelligence_P5","GLOBAL",1)
ReallyForceSpellRES("USWSHINT",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Wisdom_P5","GLOBAL",2)~ THEN REPLY ~Wisdom.~ DO ~IncrementGlobal("US_Soul_Wisdom_P5","GLOBAL",1)
ReallyForceSpellRES("USWSHWIS",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Charisma_P5","GLOBAL",2)~ THEN REPLY ~Charisma.~ DO ~IncrementGlobal("US_Soul_Charisma_P5","GLOBAL",1)
ReallyForceSpellRES("USWSHCHR",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~~ THEN REPLY ~Never mind.~ GOTO SoulGem
END

IF ~~ THEN BEGIN SoulGemAbilityScoreP6
  SAY ~Which ability score?~
  IF ~GlobalLT("US_Soul_Strength_P6","GLOBAL",2)~ THEN REPLY ~Strength.~ DO ~IncrementGlobal("US_Soul_Strength_P6","GLOBAL",1)
ReallyForceSpellRES("USWSHSTR",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Dexterity_P6","GLOBAL",2)~ THEN REPLY ~Dexterity.~ DO ~IncrementGlobal("US_Soul_Dexterity_P6","GLOBAL",1)
ReallyForceSpellRES("USWSHDEX",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Constitution_P6","GLOBAL",2)~ THEN REPLY ~Constitution.~ DO ~IncrementGlobal("US_Soul_Constitution_P6","GLOBAL",1)
ReallyForceSpellRES("USWSHCON",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Intelligence_P6","GLOBAL",2)~ THEN REPLY ~Intelligence.~ DO ~IncrementGlobal("US_Soul_Intelligence_P6","GLOBAL",1)
ReallyForceSpellRES("USWSHINT",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Wisdom_P6","GLOBAL",2)~ THEN REPLY ~Wisdom.~ DO ~IncrementGlobal("US_Soul_Wisdom_P6","GLOBAL",1)
ReallyForceSpellRES("USWSHWIS",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~GlobalLT("US_Soul_Charisma_P6","GLOBAL",2)~ THEN REPLY ~Charisma.~ DO ~IncrementGlobal("US_Soul_Charisma_P6","GLOBAL",1)
ReallyForceSpellRES("USWSHCHR",Protagonist)
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~~ THEN REPLY ~Never mind.~ GOTO SoulGem
END

IF ~~ THEN BEGIN SoulGemRecharge
  SAY ~Which item will you recharge?~
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 0)")~ THEN REPLY ~<EXINVSLOT0>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 0, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 1)")~ THEN REPLY ~<EXINVSLOT1>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 1, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 2)")~ THEN REPLY ~<EXINVSLOT2>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 2, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 3)")~ THEN REPLY ~<EXINVSLOT3>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 3, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 4)")~ THEN REPLY ~<EXINVSLOT4>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 4, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 5)")~ THEN REPLY ~<EXINVSLOT5>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 5, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 6)")~ THEN REPLY ~<EXINVSLOT6>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 6, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 7)")~ THEN REPLY ~<EXINVSLOT7>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 7, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 8)")~ THEN REPLY ~<EXINVSLOT8>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 8, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 9)")~ THEN REPLY ~<EXINVSLOT9>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 9, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 15)")~ THEN REPLY ~<EXINVSLOT15>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 15, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 16)")~ THEN REPLY ~<EXINVSLOT16>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 16, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 17)")~ THEN REPLY ~<EXINVSLOT17>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 17, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 18)")~ THEN REPLY ~<EXINVSLOT18>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 18, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 19)")~ THEN REPLY ~<EXINVSLOT19>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 19, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 20)")~ THEN REPLY ~<EXINVSLOT20>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 20, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 21)")~ THEN REPLY ~<EXINVSLOT21>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 21, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 22)")~ THEN REPLY ~<EXINVSLOT22>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 22, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 23)")~ THEN REPLY ~<EXINVSLOT23>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 23, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 24)")~ THEN REPLY ~<EXINVSLOT24>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 24, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 25)")~ THEN REPLY ~<EXINVSLOT25>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 25, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 26)")~ THEN REPLY ~<EXINVSLOT26>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 26, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 27)")~ THEN REPLY ~<EXINVSLOT27>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 27, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 28)")~ THEN REPLY ~<EXINVSLOT28>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 28, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 29)")~ THEN REPLY ~<EXINVSLOT29>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 29, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 30)")~ THEN REPLY ~<EXINVSLOT30>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 30, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 31)")~ THEN REPLY ~<EXINVSLOT31>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 31, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 32)")~ THEN REPLY ~<EXINVSLOT32>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 32, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 33)")~ THEN REPLY ~<EXINVSLOT33>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 33, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 34)")~ THEN REPLY ~<EXINVSLOT34>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 34, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 35)")~ THEN REPLY ~<EXINVSLOT35>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 35, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 36)")~ THEN REPLY ~<EXINVSLOT36>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 36, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 37)")~ THEN REPLY ~<EXINVSLOT37>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 37, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 38)")~ THEN REPLY ~<EXINVSLOT38>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 38, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 39)")~ THEN REPLY ~<EXINVSLOT39>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 39, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 40)")~ THEN REPLY ~<EXINVSLOT40>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 40, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 41)")~ THEN REPLY ~<EXINVSLOT41>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 41, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 43)")~ THEN REPLY ~<EXINVSLOT43>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 43, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 44)")~ THEN REPLY ~<EXINVSLOT44>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 44, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 45)")~ THEN REPLY ~<EXINVSLOT45>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 45, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 46)")~ THEN REPLY ~<EXINVSLOT46>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 46, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 47)")~ THEN REPLY ~<EXINVSLOT47>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 47, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 48)")~ THEN REPLY ~<EXINVSLOT48>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 48, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 49)")~ THEN REPLY ~<EXINVSLOT49>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 49, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~IEex_LuaTrigger("return IEex_HasChargeItemInSlot(LastSummonerOf(Myself), 50)")~ THEN REPLY ~<EXINVSLOT50>.~ DO ~IEex_Lua("IEex_RechargeItemInSlot(LastSummonerOf(Myself), 50, 100)")
SpellHitEffectSprite(Protagonist,Protagonist,DRAGONS_DEATH_ANIMATION_2,0)~ EXIT
  IF ~~ THEN REPLY ~Never mind.~ GOTO SoulGem
END