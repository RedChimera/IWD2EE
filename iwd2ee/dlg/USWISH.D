BEGIN ~USWISH~

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,1)
Global("US_Wishes_P1","GLOBAL",0)~ THEN BEGIN WishP1A
  SAY ~I am the channel through which your wish shall be fulfilled. You may wish to duplicate a spell less powerful than the one you just cast, or you may wish for an effect that can only be chosen once. You have three one-time wishes remaining.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
  IF ~~ THEN REPLY ~I will make a one-time wish...~ DO ~IncrementGlobal("US_Wishes_P1","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,1)
Global("US_Wishes_P1","GLOBAL",1)~ THEN BEGIN WishP1B
  SAY ~I am the channel through which your wish shall be fulfilled. You may wish to duplicate a spell less powerful than the one you just cast, or you may wish for an effect that can only be chosen once. You have two one-time wishes remaining.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
  IF ~~ THEN REPLY ~I will make a one-time wish...~ DO ~IncrementGlobal("US_Wishes_P1","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,1)
Global("US_Wishes_P1","GLOBAL",2)~ THEN BEGIN WishP1C
  SAY ~I am the channel through which your wish shall be fulfilled. You may wish to duplicate a spell less powerful than the one you just cast, or you may wish for an effect that can only be chosen once. You have one one-time wish remaining.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
  IF ~~ THEN REPLY ~I will make a one-time wish...~ DO ~IncrementGlobal("US_Wishes_P1","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,1)
GlobalGT("US_Wishes_P1","GLOBAL",2)~ THEN BEGIN WishP1D
  SAY ~I am the channel through which your wish shall be fulfilled. You have no one-time wishes remaining, so you may only choose to duplicate a spell.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,2)
Global("US_Wishes_P2","GLOBAL",0)~ THEN BEGIN WishP2A
  SAY ~I am the channel through which your wish shall be fulfilled. You may wish to duplicate a spell less powerful than the one you just cast, or you may wish for an effect that can only be chosen once. You have three one-time wishes remaining.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
  IF ~~ THEN REPLY ~I will make a one-time wish...~ DO ~IncrementGlobal("US_Wishes_P2","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,2)
Global("US_Wishes_P2","GLOBAL",1)~ THEN BEGIN WishP2B
  SAY ~I am the channel through which your wish shall be fulfilled. You may wish to duplicate a spell less powerful than the one you just cast, or you may wish for an effect that can only be chosen once. You have two one-time wishes remaining.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
  IF ~~ THEN REPLY ~I will make a one-time wish...~ DO ~IncrementGlobal("US_Wishes_P2","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,2)
Global("US_Wishes_P2","GLOBAL",2)~ THEN BEGIN WishP2C
  SAY ~I am the channel through which your wish shall be fulfilled. You may wish to duplicate a spell less powerful than the one you just cast, or you may wish for an effect that can only be chosen once. You have one one-time wish remaining.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
  IF ~~ THEN REPLY ~I will make a one-time wish...~ DO ~IncrementGlobal("US_Wishes_P2","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,2)
GlobalGT("US_Wishes_P2","GLOBAL",2)~ THEN BEGIN WishP2D
  SAY ~I am the channel through which your wish shall be fulfilled. You have no one-time wishes remaining, so you may only choose to duplicate a spell.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,3)
Global("US_Wishes_P3","GLOBAL",0)~ THEN BEGIN WishP3A
  SAY ~I am the channel through which your wish shall be fulfilled. You may wish to duplicate a spell less powerful than the one you just cast, or you may wish for an effect that can only be chosen once. You have three one-time wishes remaining.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
  IF ~~ THEN REPLY ~I will make a one-time wish...~ DO ~IncrementGlobal("US_Wishes_P3","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,3)
Global("US_Wishes_P3","GLOBAL",1)~ THEN BEGIN WishP3B
  SAY ~I am the channel through which your wish shall be fulfilled. You may wish to duplicate a spell less powerful than the one you just cast, or you may wish for an effect that can only be chosen once. You have two one-time wishes remaining.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
  IF ~~ THEN REPLY ~I will make a one-time wish...~ DO ~IncrementGlobal("US_Wishes_P3","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,3)
Global("US_Wishes_P3","GLOBAL",2)~ THEN BEGIN WishP3C
  SAY ~I am the channel through which your wish shall be fulfilled. You may wish to duplicate a spell less powerful than the one you just cast, or you may wish for an effect that can only be chosen once. You have one one-time wish remaining.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
  IF ~~ THEN REPLY ~I will make a one-time wish...~ DO ~IncrementGlobal("US_Wishes_P3","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,3)
GlobalGT("US_Wishes_P3","GLOBAL",2)~ THEN BEGIN WishP3D
  SAY ~I am the channel through which your wish shall be fulfilled. You have no one-time wishes remaining, so you may only choose to duplicate a spell.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,4)
Global("US_Wishes_P4","GLOBAL",0)~ THEN BEGIN WishP4A
  SAY ~I am the channel through which your wish shall be fulfilled. You may wish to duplicate a spell less powerful than the one you just cast, or you may wish for an effect that can only be chosen once. You have three one-time wishes remaining.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
  IF ~~ THEN REPLY ~I will make a one-time wish...~ DO ~IncrementGlobal("US_Wishes_P4","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,4)
Global("US_Wishes_P4","GLOBAL",1)~ THEN BEGIN WishP4B
  SAY ~I am the channel through which your wish shall be fulfilled. You may wish to duplicate a spell less powerful than the one you just cast, or you may wish for an effect that can only be chosen once. You have two one-time wishes remaining.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
  IF ~~ THEN REPLY ~I will make a one-time wish...~ DO ~IncrementGlobal("US_Wishes_P4","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,4)
Global("US_Wishes_P4","GLOBAL",2)~ THEN BEGIN WishP4C
  SAY ~I am the channel through which your wish shall be fulfilled. You may wish to duplicate a spell less powerful than the one you just cast, or you may wish for an effect that can only be chosen once. You have one one-time wish remaining.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
  IF ~~ THEN REPLY ~I will make a one-time wish...~ DO ~IncrementGlobal("US_Wishes_P4","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,4)
GlobalGT("US_Wishes_P4","GLOBAL",2)~ THEN BEGIN WishP4D
  SAY ~I am the channel through which your wish shall be fulfilled. You have no one-time wishes remaining, so you may only choose to duplicate a spell.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,5)
Global("US_Wishes_P5","GLOBAL",0)~ THEN BEGIN WishP5A
  SAY ~I am the channel through which your wish shall be fulfilled. You may wish to duplicate a spell less powerful than the one you just cast, or you may wish for an effect that can only be chosen once. You have three one-time wishes remaining.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
  IF ~~ THEN REPLY ~I will make a one-time wish...~ DO ~IncrementGlobal("US_Wishes_P5","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,5)
Global("US_Wishes_P5","GLOBAL",1)~ THEN BEGIN WishP5B
  SAY ~I am the channel through which your wish shall be fulfilled. You may wish to duplicate a spell less powerful than the one you just cast, or you may wish for an effect that can only be chosen once. You have two one-time wishes remaining.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
  IF ~~ THEN REPLY ~I will make a one-time wish...~ DO ~IncrementGlobal("US_Wishes_P5","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,5)
Global("US_Wishes_P5","GLOBAL",2)~ THEN BEGIN WishP5C
  SAY ~I am the channel through which your wish shall be fulfilled. You may wish to duplicate a spell less powerful than the one you just cast, or you may wish for an effect that can only be chosen once. You have one one-time wish remaining.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
  IF ~~ THEN REPLY ~I will make a one-time wish...~ DO ~IncrementGlobal("US_Wishes_P5","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,5)
GlobalGT("US_Wishes_P5","GLOBAL",2)~ THEN BEGIN WishP5D
  SAY ~I am the channel through which your wish shall be fulfilled. You have no one-time wishes remaining, so you may only choose to duplicate a spell.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,6)
Global("US_Wishes_P6","GLOBAL",0)~ THEN BEGIN WishP6A
  SAY ~I am the channel through which your wish shall be fulfilled. You may wish to duplicate a spell less powerful than the one you just cast, or you may wish for an effect that can only be chosen once. You have three one-time wishes remaining.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
  IF ~~ THEN REPLY ~I will make a one-time wish...~ DO ~IncrementGlobal("US_Wishes_P6","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,6)
Global("US_Wishes_P6","GLOBAL",1)~ THEN BEGIN WishP6B
  SAY ~I am the channel through which your wish shall be fulfilled. You may wish to duplicate a spell less powerful than the one you just cast, or you may wish for an effect that can only be chosen once. You have two one-time wishes remaining.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
  IF ~~ THEN REPLY ~I will make a one-time wish...~ DO ~IncrementGlobal("US_Wishes_P6","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,6)
Global("US_Wishes_P6","GLOBAL",2)~ THEN BEGIN WishP6C
  SAY ~I am the channel through which your wish shall be fulfilled. You may wish to duplicate a spell less powerful than the one you just cast, or you may wish for an effect that can only be chosen once. You have one one-time wish remaining.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
  IF ~~ THEN REPLY ~I will make a one-time wish...~ DO ~IncrementGlobal("US_Wishes_P6","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,6)
GlobalGT("US_Wishes_P6","GLOBAL",2)~ THEN BEGIN WishP6D
  SAY ~I am the channel through which your wish shall be fulfilled. You have no one-time wishes remaining, so you may only choose to duplicate a spell.~
  IF ~~ THEN REPLY ~I wish to cast a spell...~ GOTO WishCastSpell
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
!IsPlayerNumber(Protagonist,1)
!IsPlayerNumber(Protagonist,2)
!IsPlayerNumber(Protagonist,3)
!IsPlayerNumber(Protagonist,4)
!IsPlayerNumber(Protagonist,5)
!IsPlayerNumber(Protagonist,6)~ THEN BEGIN WishMinion
  SAY ~I am forbidden from granting wishes to minions, amusing as that may be.~
  IF ~~ THEN EXIT
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
Global("US_Wish_Minion","LOCALS",1)~ THEN BEGIN WishMinion2
  SAY ~I am forbidden from granting wishes to minions, amusing as that may be.~
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN WishCastSpell
  SAY ~...~
  IF ~~ THEN REPLY ~... of 1st-level called...~ GOTO WishCastSpell1
  IF ~~ THEN REPLY ~... of 2nd-level called...~ GOTO WishCastSpell2
  IF ~~ THEN REPLY ~... of 3rd-level called...~ GOTO WishCastSpell3
  IF ~~ THEN REPLY ~... of 4th-level called...~ GOTO WishCastSpell4
  IF ~~ THEN REPLY ~... of 5th-level called...~ GOTO WishCastSpell5
  IF ~~ THEN REPLY ~... of 6th-level called...~ GOTO WishCastSpell6
  IF ~~ THEN REPLY ~... of 7th-level called...~ GOTO WishCastSpell7
  IF ~~ THEN REPLY ~... of 8th-level called...~ GOTO WishCastSpell8
END

IF ~~ THEN BEGIN WishCastSpell1
  SAY ~...~
  IF ~~ THEN REPLY ~... Deathwatch.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6155)")~ EXIT
  IF ~~ THEN REPLY ~... Grease.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2101)")~ EXIT
  IF ~~ THEN REPLY ~... Identify Creature.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6251)")~ EXIT
  IF ~~ THEN REPLY ~... Jump.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6156)")~ EXIT
  IF ~~ THEN REPLY ~... Mage Armor.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2102)")~ EXIT
  IF ~~ THEN REPLY ~... Perception Filter.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6356)")~ EXIT
  IF ~~ THEN REPLY ~... Protection from Evil.~ DO ~IEex_Lua("IEex_HaveSummonerCast(1107)")~ EXIT
  IF ~~ THEN REPLY ~... Protection from Petrification.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2108)")~ EXIT
  IF ~~ THEN REPLY ~... Reflect Attack.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6152)")~ EXIT
  IF ~~ THEN REPLY ~... Reflected Image.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2120)")~ EXIT
  IF ~~ THEN REPLY ~... Shield.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2114)")~ EXIT
  IF ~~ THEN REPLY ~... Sleep.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2116)")~ EXIT
  IF ~~ THEN REPLY ~... Summon Monster I.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2124)")~ EXIT
  IF ~~ THEN REPLY ~... True Strike.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6151)")~ EXIT
END

IF ~~ THEN BEGIN WishCastSpell2
  SAY ~...~
  IF ~~ THEN REPLY ~... Arcane Sight.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6254)")~ EXIT
  IF ~~ THEN REPLY ~... Blur.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2201)")~ EXIT
  IF ~~ THEN REPLY ~... Cat's Grace.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2223)")~ EXIT
  IF ~~ THEN REPLY ~... Darkness.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6256)")~ EXIT
  IF ~~ THEN REPLY ~... Death Armor.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2228)")~ EXIT
  IF ~~ THEN REPLY ~... Decastave.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2221)")~ EXIT
  IF ~~ THEN REPLY ~... Dispel Illusions.~ DO ~IEex_Lua("IEex_HaveSummonerCast(1309)")~ EXIT
  IF ~~ THEN REPLY ~... Eagle's Splendor.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2107)")~ EXIT
  IF ~~ THEN REPLY ~... Gedlee's Electric Loop.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2227)")~ EXIT
  IF ~~ THEN REPLY ~... Horror.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2205)")~ EXIT
  IF ~~ THEN REPLY ~... Invisibility.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2206)")~ EXIT
  IF ~~ THEN REPLY ~... Levitate.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6253)")~ EXIT
  IF ~~ THEN REPLY ~... Luck.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2209)")~ EXIT
  IF ~~ THEN REPLY ~... Minor Elemental Barrier.~ DO ~IEex_Lua("IEex_HaveSummonerCast(1210)")~ EXIT
  IF ~~ THEN REPLY ~... Mirror Image.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2212)")~ EXIT
  IF ~~ THEN REPLY ~... Ox's Fortitude.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2214)")~ EXIT
  IF ~~ THEN REPLY ~... Protection from Arrows.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2311)")~ EXIT
  IF ~~ THEN REPLY ~... Remove Fear.~ DO ~IEex_Lua("IEex_HaveSummonerCast(1108)")~ EXIT
  IF ~~ THEN REPLY ~... Snilloc's Snowball Swarm.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2220)")~ EXIT
  IF ~~ THEN REPLY ~... Summon Monster II.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2230)")~ EXIT
  IF ~~ THEN REPLY ~... Vocalize.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2219)")~ EXIT
  IF ~~ THEN REPLY ~... Web.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2215)")~ EXIT
END

IF ~~ THEN BEGIN WishCastSpell3
  SAY ~...~
  IF ~~ THEN REPLY ~... Animate Skeleton.~ DO ~IEex_Lua("IEex_HaveSummonerCast(1301)")~ EXIT
  IF ~~ THEN REPLY ~... Animate Zombie.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2501)")~ EXIT
  IF ~~ THEN REPLY ~... Blink.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2323)")~ EXIT
  IF ~~ THEN REPLY ~... Dispel Magic.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2302)")~ EXIT
  IF ~~ THEN REPLY ~... Enlarge Creature.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6255)")~ EXIT
  IF ~~ THEN REPLY ~... Fireball.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2304)")~ EXIT
  IF ~~ THEN REPLY ~... Fly.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6355)")~ EXIT
  IF ~~ THEN REPLY ~... Ghost Armor.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2317)")~ EXIT
  IF ~~ THEN REPLY ~... Haste.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2305)")~ EXIT
  IF ~~ THEN REPLY ~... Hold Person.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2306)")~ EXIT
  IF ~~ THEN REPLY ~... Invisibility Sphere.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2321)")~ EXIT
  IF ~~ THEN REPLY ~... Melf's Minute Meteors.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2322)")~ EXIT
  IF ~~ THEN REPLY ~... Moment of Prescience.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6354)")~ EXIT
  IF ~~ THEN REPLY ~... Nondetection.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2310)")~ EXIT
  IF ~~ THEN REPLY ~... Protection from Cold.~ DO ~IEex_Lua("IEex_HaveSummonerCast(5352)")~ EXIT
  IF ~~ THEN REPLY ~... Protection from Fire.~ DO ~IEex_Lua("IEex_HaveSummonerCast(1306)")~ EXIT
  IF ~~ THEN REPLY ~... Remove Magic.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6352)")~ EXIT
  IF ~~ THEN REPLY ~... Skull Trap.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2313)")~ EXIT
  IF ~~ THEN REPLY ~... Slow.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2312)")~ EXIT
  IF ~~ THEN REPLY ~... Spider Spawn.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2428)")~ EXIT
  IF ~~ THEN REPLY ~... Stinking Cloud.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2213)")~ EXIT
  IF ~~ THEN REPLY ~... Summon Monster III.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2309)")~ EXIT
END

IF ~~ THEN BEGIN WishCastSpell4
  SAY ~...~
  IF ~~ THEN REPLY ~... Break Enchantment.~ DO ~IEex_Lua("IEex_HaveSummonerCast(1307)")~ EXIT
  IF ~~ THEN REPLY ~... Carrion Summons.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2621)")~ EXIT
  IF ~~ THEN REPLY ~... Confusion.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2401)")~ EXIT
  IF ~~ THEN REPLY ~... Emotion: Fear.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2420)")~ EXIT
  IF ~~ THEN REPLY ~... Emotion: Hope.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2421)")~ EXIT
  IF ~~ THEN REPLY ~... Emotion: Rage.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2419)")~ EXIT
  IF ~~ THEN REPLY ~... Fire Shield (Blue).~ DO ~IEex_Lua("IEex_HaveSummonerCast(2426)")~ EXIT
  IF ~~ THEN REPLY ~... Fire Shield (Red).~ DO ~IEex_Lua("IEex_HaveSummonerCast(2427)")~ EXIT
  IF ~~ THEN REPLY ~... Ghoulish Feast.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6453)")~ EXIT
  IF ~~ THEN REPLY ~... Giant Vermin.~ DO ~IEex_Lua("IEex_HaveSummonerCast(1410)")~ EXIT
  IF ~~ THEN REPLY ~... Ice Storm.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2404)")~ EXIT
  IF ~~ THEN REPLY ~... Improved Invisibility.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2405)")~ EXIT
  IF ~~ THEN REPLY ~... Magic Circle Against Evil.~ DO ~IEex_Lua("IEex_HaveSummonerCast(1408)")~ EXIT
  IF ~~ THEN REPLY ~... Malison.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2412)")~ EXIT
  IF ~~ THEN REPLY ~... Minor Globe of Invulnerability.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2406)")~ EXIT
  IF ~~ THEN REPLY ~... Otiluke's Resilient Sphere.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2413)")~ EXIT
  IF ~~ THEN REPLY ~... Polymorph Self.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6455)")~ EXIT
  IF ~~ THEN REPLY ~... Shadow Conjuration.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2418)")~ EXIT
  IF ~~ THEN REPLY ~... Spirit Armor.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2414)")~ EXIT
  IF ~~ THEN REPLY ~... Stoneskin.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2408)")~ EXIT
  IF ~~ THEN REPLY ~... Suffocate.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2711)")~ EXIT
  IF ~~ THEN REPLY ~... Summon Monster IV.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2407)")~ EXIT
  IF ~~ THEN REPLY ~... Teleport Field.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6451)")~ EXIT
  IF ~~ THEN REPLY ~... Wall of Fire.~ DO ~IEex_Lua("IEex_HaveSummonerCast(1427)")~ EXIT
END

IF ~~ THEN BEGIN WishCastSpell5
  SAY ~...~
  IF ~~ THEN REPLY ~... Ball Lightning.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2525)")~ EXIT
  IF ~~ THEN REPLY ~... Cloudkill.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2503)")~ EXIT
  IF ~~ THEN REPLY ~... Ghostform.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6552)")~ EXIT
  IF ~~ THEN REPLY ~... Greater Shadow Conjuration.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2512)")~ EXIT
  IF ~~ THEN REPLY ~... Hold Monster.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2508)")~ EXIT
  IF ~~ THEN REPLY ~... Lesser Planar Binding: Air Elemental.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2520)")~ EXIT
  IF ~~ THEN REPLY ~... Lesser Planar Binding: Earth Elemental.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2515)")~ EXIT
  IF ~~ THEN REPLY ~... Lesser Planar Binding: Fire Elemental.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2514)")~ EXIT
  IF ~~ THEN REPLY ~... Lesser Planar Binding: Water Elemental.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2516)")~ EXIT
  IF ~~ THEN REPLY ~... Phantom Blade.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2521)")~ EXIT
  IF ~~ THEN REPLY ~... Protection from Acid.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2522)")~ EXIT
  IF ~~ THEN REPLY ~... Protection from Electricity.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2523)")~ EXIT
  IF ~~ THEN REPLY ~... Protection from Magic Energy.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2624)")~ EXIT
  IF ~~ THEN REPLY ~... Rewind Time.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6553)")~ EXIT
  IF ~~ THEN REPLY ~... Shroud of Flame.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2511)")~ EXIT
  IF ~~ THEN REPLY ~... Spell Shield.~ DO ~IEex_Lua("IEex_HaveSummonerCast(1219)")~ EXIT
  IF ~~ THEN REPLY ~... Sunfire.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2519)")~ EXIT
  IF ~~ THEN REPLY ~... Summon Monster V.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2505)")~ EXIT
  IF ~~ THEN REPLY ~... Summon Shadow.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2513)")~ EXIT
END

IF ~~ THEN BEGIN WishCastSpell6
  SAY ~...~
  IF ~~ THEN REPLY ~... Antimagic Field.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2601)")~ EXIT
  IF ~~ THEN REPLY ~... Boulder Roll.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6653)")~ EXIT
  IF ~~ THEN REPLY ~... Chaos.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2509)")~ EXIT
  IF ~~ THEN REPLY ~... Circle of Death.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2606)")~ EXIT
  IF ~~ THEN REPLY ~... Darts of Bone.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2618)")~ EXIT
  IF ~~ THEN REPLY ~... Death Fog.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2605)")~ EXIT
  IF ~~ THEN REPLY ~... Globe of Invulnerability.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2608)")~ EXIT
  IF ~~ THEN REPLY ~... Lich Touch.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2610)")~ EXIT
  IF ~~ THEN REPLY ~... Mass Haste.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2623)")~ EXIT
  IF ~~ THEN REPLY ~... Planar Binding: Air Elemental.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2622)")~ EXIT
  IF ~~ THEN REPLY ~... Planar Binding: Earth Elemental.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2628)")~ EXIT
  IF ~~ THEN REPLY ~... Planar Binding: Fire Elemental.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2627)")~ EXIT
  IF ~~ THEN REPLY ~... Planar Binding: Water Elemental.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2629)")~ EXIT
  IF ~~ THEN REPLY ~... Shades.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2613)")~ EXIT
  IF ~~ THEN REPLY ~... Soul Eater.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2619)")~ EXIT
  IF ~~ THEN REPLY ~... Spellstaff.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6656)")~ EXIT
  IF ~~ THEN REPLY ~... Summon Invisible Stalker.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2609)")~ EXIT
  IF ~~ THEN REPLY ~... Summon Monster VI.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2611)")~ EXIT
  IF ~~ THEN REPLY ~... Summon Shadow.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2513)")~ EXIT
  IF ~~ THEN REPLY ~... Tenser's Transformation.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2616)")~ EXIT
  IF ~~ THEN REPLY ~... Trollish Fortitude.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2620)")~ EXIT
  IF ~~ THEN REPLY ~... True Seeing.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2203)")~ EXIT
  IF ~~ THEN REPLY ~... Wyvern Call.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2626)")~ EXIT
END

IF ~~ THEN BEGIN WishCastSpell7
  SAY ~...~
  IF ~~ THEN REPLY ~... Acid Storm.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2708)")~ EXIT
  IF ~~ THEN REPLY ~... Banishment.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2718)")~ EXIT
  IF ~~ THEN REPLY ~... Cacofiend.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2713)")~ EXIT
  IF ~~ THEN REPLY ~... Control Undead.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2717)")~ EXIT
  IF ~~ THEN REPLY ~... Death Ward.~ DO ~IEex_Lua("IEex_HaveSummonerCast(1424)")~ EXIT
  IF ~~ THEN REPLY ~... Delayed Blast Fireball.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2714)")~ EXIT
  IF ~~ THEN REPLY ~... Forcecage.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6761)")~ EXIT
  IF ~~ THEN REPLY ~... Malavon's Rage.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2707)")~ EXIT
  IF ~~ THEN REPLY ~... Mantle.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6752)")~ EXIT
  IF ~~ THEN REPLY ~... Mass Invisibility.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2709)")~ EXIT
  IF ~~ THEN REPLY ~... Mordenkainen's Sword.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2704)")~ EXIT
  IF ~~ THEN REPLY ~... Omnipresence.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6860)")~ EXIT
  IF ~~ THEN REPLY ~... Repulsion.~ DO ~IEex_Lua("IEex_HaveSummonerCast(5653)")~ EXIT
  IF ~~ THEN REPLY ~... Seven Eyes.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2710)")~ EXIT
  IF ~~ THEN REPLY ~... Skeleton Traps.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6762)")~ EXIT
  IF ~~ THEN REPLY ~... Skip Time.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6760)")~ EXIT
  IF ~~ THEN REPLY ~... Spell Sequencer.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6758)")~ EXIT
  IF ~~ THEN REPLY ~... Spell Turning.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6763)")~ EXIT
  IF ~~ THEN REPLY ~... Stygian Ice Storm.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6751)")~ EXIT
  IF ~~ THEN REPLY ~... Summon Djinni.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2716)")~ EXIT
  IF ~~ THEN REPLY ~... Summon Efreeti.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2715)")~ EXIT
  IF ~~ THEN REPLY ~... Summon Monster VII.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2703)")~ EXIT
  IF ~~ THEN REPLY ~... Sympathy.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6759)")~ EXIT
  IF ~~ THEN REPLY ~... Vipergout.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2719)")~ EXIT
END

IF ~~ THEN BEGIN WishCastSpell8
  SAY ~...~
  IF ~~ THEN REPLY ~... Contagious Fear.~ DO ~IEex_Lua("IEex_HaveSummonerCast(1727)")~ EXIT
  IF ~~ THEN REPLY ~... Elemental Barrier.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2712)")~ EXIT
  IF ~~ THEN REPLY ~... Fiery Cloud.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2802)")~ EXIT
  IF ~~ THEN REPLY ~... Horrid Wilting.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2805)")~ EXIT
  IF ~~ THEN REPLY ~... Iron Body.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2807)")~ EXIT
  IF ~~ THEN REPLY ~... Living Lightning.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6954)")~ EXIT
  IF ~~ THEN REPLY ~... Metafireball.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6858)")~ EXIT
  IF ~~ THEN REPLY ~... Mind Blank.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2804)")~ EXIT
  IF ~~ THEN REPLY ~... Otto's Irresistible Spin.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6859)")~ EXIT
  IF ~~ THEN REPLY ~... Power Word: Blind.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2808)")~ EXIT
  IF ~~ THEN REPLY ~... Reverse Gravity.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6863)")~ EXIT
  IF ~~ THEN REPLY ~... Simulacrum.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6862)")~ EXIT
  IF ~~ THEN REPLY ~... Spell Trap.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6856)")~ EXIT
  IF ~~ THEN REPLY ~... Summon Fiend.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2809)")~ EXIT
  IF ~~ THEN REPLY ~... Summon Monster VIII.~ DO ~IEex_Lua("IEex_HaveSummonerCast(2803)")~ EXIT
  IF ~~ THEN REPLY ~... Symbol of Death.~ DO ~IEex_Lua("IEex_HaveSummonerCast(1726)")~ EXIT
  IF ~~ THEN REPLY ~... Symbol of Hopelessness.~ DO ~IEex_Lua("IEex_HaveSummonerCast(1715)")~ EXIT
  IF ~~ THEN REPLY ~... Symbol of Pain.~ DO ~IEex_Lua("IEex_HaveSummonerCast(1714)")~ EXIT
  IF ~~ THEN REPLY ~... Symbol of Stunning.~ DO ~IEex_Lua("IEex_HaveSummonerCast(1728)")~ EXIT
  IF ~~ THEN REPLY ~... Teleport Step.~ DO ~IEex_Lua("IEex_HaveSummonerCast(6855)")~ EXIT
END

IF ~~ THEN BEGIN WishOneTime
  SAY ~...~
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Strength_P1","GLOBAL",0)~ THEN REPLY ~... to become stronger.~ DO ~SetGlobal("US_Wish_Strength_P1","GLOBAL",1)~ GOTO WishStrength
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Strength_P2","GLOBAL",0)~ THEN REPLY ~... to become stronger.~ DO ~SetGlobal("US_Wish_Strength_P2","GLOBAL",1)~ GOTO WishStrength
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Strength_P3","GLOBAL",0)~ THEN REPLY ~... to become stronger.~ DO ~SetGlobal("US_Wish_Strength_P3","GLOBAL",1)~ GOTO WishStrength
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Strength_P4","GLOBAL",0)~ THEN REPLY ~... to become stronger.~ DO ~SetGlobal("US_Wish_Strength_P4","GLOBAL",1)~ GOTO WishStrength
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Strength_P5","GLOBAL",0)~ THEN REPLY ~... to become stronger.~ DO ~SetGlobal("US_Wish_Strength_P5","GLOBAL",1)~ GOTO WishStrength
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Strength_P6","GLOBAL",0)~ THEN REPLY ~... to become stronger.~ DO ~SetGlobal("US_Wish_Strength_P6","GLOBAL",1)~ GOTO WishStrength
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Dexterity_P1","GLOBAL",0)~ THEN REPLY ~... to become more agile.~ DO ~SetGlobal("US_Wish_Dexterity_P1","GLOBAL",1)~ GOTO WishDexterity
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Dexterity_P2","GLOBAL",0)~ THEN REPLY ~... to become more agile.~ DO ~SetGlobal("US_Wish_Dexterity_P2","GLOBAL",1)~ GOTO WishDexterity
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Dexterity_P3","GLOBAL",0)~ THEN REPLY ~... to become more agile.~ DO ~SetGlobal("US_Wish_Dexterity_P3","GLOBAL",1)~ GOTO WishDexterity
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Dexterity_P4","GLOBAL",0)~ THEN REPLY ~... to become more agile.~ DO ~SetGlobal("US_Wish_Dexterity_P4","GLOBAL",1)~ GOTO WishDexterity
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Dexterity_P5","GLOBAL",0)~ THEN REPLY ~... to become more agile.~ DO ~SetGlobal("US_Wish_Dexterity_P5","GLOBAL",1)~ GOTO WishDexterity
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Dexterity_P6","GLOBAL",0)~ THEN REPLY ~... to become more agile.~ DO ~SetGlobal("US_Wish_Dexterity_P6","GLOBAL",1)~ GOTO WishDexterity
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Constitution_P1","GLOBAL",0)~ THEN REPLY ~... to become tougher.~ DO ~SetGlobal("US_Wish_Constitution_P1","GLOBAL",1)~ GOTO WishConstitution
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Constitution_P2","GLOBAL",0)~ THEN REPLY ~... to become tougher.~ DO ~SetGlobal("US_Wish_Constitution_P2","GLOBAL",1)~ GOTO WishConstitution
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Constitution_P3","GLOBAL",0)~ THEN REPLY ~... to become tougher.~ DO ~SetGlobal("US_Wish_Constitution_P3","GLOBAL",1)~ GOTO WishConstitution
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Constitution_P4","GLOBAL",0)~ THEN REPLY ~... to become tougher.~ DO ~SetGlobal("US_Wish_Constitution_P4","GLOBAL",1)~ GOTO WishConstitution
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Constitution_P5","GLOBAL",0)~ THEN REPLY ~... to become tougher.~ DO ~SetGlobal("US_Wish_Constitution_P5","GLOBAL",1)~ GOTO WishConstitution
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Constitution_P6","GLOBAL",0)~ THEN REPLY ~... to become tougher.~ DO ~SetGlobal("US_Wish_Constitution_P6","GLOBAL",1)~ GOTO WishConstitution
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Intelligence_P1","GLOBAL",0)~ THEN REPLY ~... to become smarter.~ DO ~SetGlobal("US_Wish_Intelligence_P1","GLOBAL",1)~ GOTO WishIntelligence
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Intelligence_P2","GLOBAL",0)~ THEN REPLY ~... to become smarter.~ DO ~SetGlobal("US_Wish_Intelligence_P2","GLOBAL",1)~ GOTO WishIntelligence
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Intelligence_P3","GLOBAL",0)~ THEN REPLY ~... to become smarter.~ DO ~SetGlobal("US_Wish_Intelligence_P3","GLOBAL",1)~ GOTO WishIntelligence
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Intelligence_P4","GLOBAL",0)~ THEN REPLY ~... to become smarter.~ DO ~SetGlobal("US_Wish_Intelligence_P4","GLOBAL",1)~ GOTO WishIntelligence
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Intelligence_P5","GLOBAL",0)~ THEN REPLY ~... to become smarter.~ DO ~SetGlobal("US_Wish_Intelligence_P5","GLOBAL",1)~ GOTO WishIntelligence
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Intelligence_P6","GLOBAL",0)~ THEN REPLY ~... to become smarter.~ DO ~SetGlobal("US_Wish_Intelligence_P6","GLOBAL",1)~ GOTO WishIntelligence
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Wisdom_P1","GLOBAL",0)~ THEN REPLY ~... to become wiser.~ DO ~SetGlobal("US_Wish_Wisdom_P1","GLOBAL",1)~ GOTO WishWisdom
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Wisdom_P2","GLOBAL",0)~ THEN REPLY ~... to become wiser.~ DO ~SetGlobal("US_Wish_Wisdom_P2","GLOBAL",1)~ GOTO WishWisdom
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Wisdom_P3","GLOBAL",0)~ THEN REPLY ~... to become wiser.~ DO ~SetGlobal("US_Wish_Wisdom_P3","GLOBAL",1)~ GOTO WishWisdom
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Wisdom_P4","GLOBAL",0)~ THEN REPLY ~... to become wiser.~ DO ~SetGlobal("US_Wish_Wisdom_P4","GLOBAL",1)~ GOTO WishWisdom
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Wisdom_P5","GLOBAL",0)~ THEN REPLY ~... to become wiser.~ DO ~SetGlobal("US_Wish_Wisdom_P5","GLOBAL",1)~ GOTO WishWisdom
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Wisdom_P6","GLOBAL",0)~ THEN REPLY ~... to become wiser.~ DO ~SetGlobal("US_Wish_Wisdom_P6","GLOBAL",1)~ GOTO WishWisdom
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Charisma_P1","GLOBAL",0)~ THEN REPLY ~... to become more charismatic.~ DO ~SetGlobal("US_Wish_Charisma_P1","GLOBAL",1)~ GOTO WishCharisma
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Charisma_P2","GLOBAL",0)~ THEN REPLY ~... to become more charismatic.~ DO ~SetGlobal("US_Wish_Charisma_P2","GLOBAL",1)~ GOTO WishCharisma
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Charisma_P3","GLOBAL",0)~ THEN REPLY ~... to become more charismatic.~ DO ~SetGlobal("US_Wish_Charisma_P3","GLOBAL",1)~ GOTO WishCharisma
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Charisma_P4","GLOBAL",0)~ THEN REPLY ~... to become more charismatic.~ DO ~SetGlobal("US_Wish_Charisma_P4","GLOBAL",1)~ GOTO WishCharisma
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Charisma_P5","GLOBAL",0)~ THEN REPLY ~... to become more charismatic.~ DO ~SetGlobal("US_Wish_Charisma_P5","GLOBAL",1)~ GOTO WishCharisma
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Charisma_P6","GLOBAL",0)~ THEN REPLY ~... to become more charismatic.~ DO ~SetGlobal("US_Wish_Charisma_P6","GLOBAL",1)~ GOTO WishCharisma
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Item_P1","GLOBAL",0)~ THEN REPLY ~... to obtain a powerful magic item.~ DO ~SetGlobal("US_Wish_Item_P1","GLOBAL",1)~ GOTO WishItem
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Item_P2","GLOBAL",0)~ THEN REPLY ~... to obtain a powerful magic item.~ DO ~SetGlobal("US_Wish_Item_P2","GLOBAL",1)~ GOTO WishItem
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Item_P3","GLOBAL",0)~ THEN REPLY ~... to obtain a powerful magic item.~ DO ~SetGlobal("US_Wish_Item_P3","GLOBAL",1)~ GOTO WishItem
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Item_P4","GLOBAL",0)~ THEN REPLY ~... to obtain a powerful magic item.~ DO ~SetGlobal("US_Wish_Item_P4","GLOBAL",1)~ GOTO WishItem
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Item_P5","GLOBAL",0)~ THEN REPLY ~... to obtain a powerful magic item.~ DO ~SetGlobal("US_Wish_Item_P5","GLOBAL",1)~ GOTO WishItem
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Item_P6","GLOBAL",0)~ THEN REPLY ~... to obtain a powerful magic item.~ DO ~SetGlobal("US_Wish_Item_P6","GLOBAL",1)~ GOTO WishItem
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Gold_P1","GLOBAL",0)~ THEN REPLY ~... to become rich.~ DO ~SetGlobal("US_Wish_Gold_P1","GLOBAL",1)~ GOTO WishGold
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Gold_P2","GLOBAL",0)~ THEN REPLY ~... to become rich.~ DO ~SetGlobal("US_Wish_Gold_P2","GLOBAL",1)~ GOTO WishGold
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Gold_P3","GLOBAL",0)~ THEN REPLY ~... to become rich.~ DO ~SetGlobal("US_Wish_Gold_P3","GLOBAL",1)~ GOTO WishGold
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Gold_P4","GLOBAL",0)~ THEN REPLY ~... to become rich.~ DO ~SetGlobal("US_Wish_Gold_P4","GLOBAL",1)~ GOTO WishGold
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Gold_P5","GLOBAL",0)~ THEN REPLY ~... to become rich.~ DO ~SetGlobal("US_Wish_Gold_P5","GLOBAL",1)~ GOTO WishGold
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Gold_P6","GLOBAL",0)~ THEN REPLY ~... to become rich.~ DO ~SetGlobal("US_Wish_Gold_P6","GLOBAL",1)~ GOTO WishGold
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Rest_P1","GLOBAL",0)~ THEN REPLY ~... to regain all my memorized spells, as if I had slept 8 hours.~ DO ~SetGlobal("US_Wish_Rest_P1","GLOBAL",1)~ GOTO WishRest
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Rest_P2","GLOBAL",0)~ THEN REPLY ~... to regain all my memorized spells, as if I had slept 8 hours.~ DO ~SetGlobal("US_Wish_Rest_P2","GLOBAL",1)~ GOTO WishRest
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Rest_P3","GLOBAL",0)~ THEN REPLY ~... to regain all my memorized spells, as if I had slept 8 hours.~ DO ~SetGlobal("US_Wish_Rest_P3","GLOBAL",1)~ GOTO WishRest
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Rest_P4","GLOBAL",0)~ THEN REPLY ~... to regain all my memorized spells, as if I had slept 8 hours.~ DO ~SetGlobal("US_Wish_Rest_P4","GLOBAL",1)~ GOTO WishRest
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Rest_P5","GLOBAL",0)~ THEN REPLY ~... to regain all my memorized spells, as if I had slept 8 hours.~ DO ~SetGlobal("US_Wish_Rest_P5","GLOBAL",1)~ GOTO WishRest
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Rest_P6","GLOBAL",0)~ THEN REPLY ~... to regain all my memorized spells, as if I had slept 8 hours.~ DO ~SetGlobal("US_Wish_Rest_P6","GLOBAL",1)~ GOTO WishRest
  IF ~~ THEN REPLY ~... to cast an epic spell called...~ GOTO WishEpic
END

IF ~~ THEN BEGIN WishStrength
  SAY ~Then so you shall.~
  IF ~~ THEN DO ~ReallyForceSpellRES("USWSHSTR",Protagonist)~ EXIT
END

IF ~~ THEN BEGIN WishDexterity
  SAY ~Then so you shall.~
  IF ~~ THEN DO ~ReallyForceSpellRES("USWSHDEX",Protagonist)~ EXIT
END

IF ~~ THEN BEGIN WishConstitution
  SAY ~Then so you shall.~
  IF ~~ THEN DO ~ReallyForceSpellRES("USWSHCON",Protagonist)~ EXIT
END

IF ~~ THEN BEGIN WishIntelligence
  SAY ~Then so you shall.~
  IF ~~ THEN DO ~ReallyForceSpellRES("USWSHINT",Protagonist)~ EXIT
END

IF ~~ THEN BEGIN WishWisdom
  SAY ~Then so you shall.~
  IF ~~ THEN DO ~ReallyForceSpellRES("USWSHWIS",Protagonist)~ EXIT
END

IF ~~ THEN BEGIN WishCharisma
  SAY ~Then so you shall.~
  IF ~~ THEN DO ~ReallyForceSpellRES("USWSHCHR",Protagonist)~ EXIT
END

IF ~~ THEN BEGIN WishItem
  SAY ~Then you shall have it.~
  IF ~~ THEN DO ~GiveItemCreate("USRT15_V",Protagonist,1,1,1)~ EXIT
END

IF ~~ THEN BEGIN WishGold
  SAY ~Rich you shall become!~
  IF ~~ THEN DO ~GiveItemCreate("Misc07",Protagonist,10000,0,0)
GiveItemCreate("Misc07",Protagonist,10000,0,0)
GiveItemCreate("Misc07",Protagonist,10000,0,0)
GiveItemCreate("Misc07",Protagonist,10000,0,0)
GiveItemCreate("Misc07",Protagonist,10000,0,0)
GiveItemCreate("Misc07",Protagonist,10000,0,0)
GiveItemCreate("Misc07",Protagonist,10000,0,0)
GiveItemCreate("Misc07",Protagonist,10000,0,0)
GiveItemCreate("Misc07",Protagonist,10000,0,0)
GiveItemCreate("Misc07",Protagonist,10000,0,0)~ EXIT
END

IF ~~ THEN BEGIN WishRest
  SAY ~Then so you shall.~
  IF ~~ THEN DO ~ReallyForceSpellRES("USWSHRST",Protagonist)~ EXIT
END

IF ~~ THEN BEGIN WishEpic
  SAY ~...~
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_005_P1","GLOBAL",0)~ THEN REPLY ~... Animus Blast.~ DO ~SetGlobal("US_Wish_Epic_005_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10005)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_005_P2","GLOBAL",0)~ THEN REPLY ~... Animus Blast.~ DO ~SetGlobal("US_Wish_Epic_005_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10005)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_005_P3","GLOBAL",0)~ THEN REPLY ~... Animus Blast.~ DO ~SetGlobal("US_Wish_Epic_005_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10005)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_005_P4","GLOBAL",0)~ THEN REPLY ~... Animus Blast.~ DO ~SetGlobal("US_Wish_Epic_005_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10005)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_005_P5","GLOBAL",0)~ THEN REPLY ~... Animus Blast.~ DO ~SetGlobal("US_Wish_Epic_005_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10005)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_005_P6","GLOBAL",0)~ THEN REPLY ~... Animus Blast.~ DO ~SetGlobal("US_Wish_Epic_005_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10005)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_013_P1","GLOBAL",0)~ THEN REPLY ~... Animus Blizzard.~ DO ~SetGlobal("US_Wish_Epic_013_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10013)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_013_P2","GLOBAL",0)~ THEN REPLY ~... Animus Blizzard.~ DO ~SetGlobal("US_Wish_Epic_013_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10013)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_013_P3","GLOBAL",0)~ THEN REPLY ~... Animus Blizzard.~ DO ~SetGlobal("US_Wish_Epic_013_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10013)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_013_P4","GLOBAL",0)~ THEN REPLY ~... Animus Blizzard.~ DO ~SetGlobal("US_Wish_Epic_013_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10013)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_013_P5","GLOBAL",0)~ THEN REPLY ~... Animus Blizzard.~ DO ~SetGlobal("US_Wish_Epic_013_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10013)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_013_P6","GLOBAL",0)~ THEN REPLY ~... Animus Blizzard.~ DO ~SetGlobal("US_Wish_Epic_013_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10013)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_012_P1","GLOBAL",0)~ THEN REPLY ~... Create Winterwight.~ DO ~SetGlobal("US_Wish_Epic_012_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10012)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_012_P2","GLOBAL",0)~ THEN REPLY ~... Create Winterwight.~ DO ~SetGlobal("US_Wish_Epic_012_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10012)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_012_P3","GLOBAL",0)~ THEN REPLY ~... Create Winterwight.~ DO ~SetGlobal("US_Wish_Epic_012_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10012)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_012_P4","GLOBAL",0)~ THEN REPLY ~... Create Winterwight.~ DO ~SetGlobal("US_Wish_Epic_012_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10012)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_012_P5","GLOBAL",0)~ THEN REPLY ~... Create Winterwight.~ DO ~SetGlobal("US_Wish_Epic_012_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10012)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_012_P6","GLOBAL",0)~ THEN REPLY ~... Create Winterwight.~ DO ~SetGlobal("US_Wish_Epic_012_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10012)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_004_P1","GLOBAL",0)~ THEN REPLY ~... Epic Mage Armor.~ DO ~SetGlobal("US_Wish_Epic_004_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10004)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_004_P2","GLOBAL",0)~ THEN REPLY ~... Epic Mage Armor.~ DO ~SetGlobal("US_Wish_Epic_004_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10004)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_004_P3","GLOBAL",0)~ THEN REPLY ~... Epic Mage Armor.~ DO ~SetGlobal("US_Wish_Epic_004_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10004)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_004_P4","GLOBAL",0)~ THEN REPLY ~... Epic Mage Armor.~ DO ~SetGlobal("US_Wish_Epic_004_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10004)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_004_P5","GLOBAL",0)~ THEN REPLY ~... Epic Mage Armor.~ DO ~SetGlobal("US_Wish_Epic_004_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10004)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_004_P6","GLOBAL",0)~ THEN REPLY ~... Epic Mage Armor.~ DO ~SetGlobal("US_Wish_Epic_004_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10004)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_003_P1","GLOBAL",0)~ THEN REPLY ~... Epic Warding.~ DO ~SetGlobal("US_Wish_Epic_003_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10003)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_003_P2","GLOBAL",0)~ THEN REPLY ~... Epic Warding.~ DO ~SetGlobal("US_Wish_Epic_003_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10003)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_003_P3","GLOBAL",0)~ THEN REPLY ~... Epic Warding.~ DO ~SetGlobal("US_Wish_Epic_003_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10003)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_003_P4","GLOBAL",0)~ THEN REPLY ~... Epic Warding.~ DO ~SetGlobal("US_Wish_Epic_003_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10003)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_003_P5","GLOBAL",0)~ THEN REPLY ~... Epic Warding.~ DO ~SetGlobal("US_Wish_Epic_003_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10003)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_003_P6","GLOBAL",0)~ THEN REPLY ~... Epic Warding.~ DO ~SetGlobal("US_Wish_Epic_003_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10003)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_014_P1","GLOBAL",0)~ THEN REPLY ~... Many Missiles.~ DO ~SetGlobal("US_Wish_Epic_014_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10014)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_014_P2","GLOBAL",0)~ THEN REPLY ~... Many Missiles.~ DO ~SetGlobal("US_Wish_Epic_014_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10014)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_014_P3","GLOBAL",0)~ THEN REPLY ~... Many Missiles.~ DO ~SetGlobal("US_Wish_Epic_014_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10014)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_014_P4","GLOBAL",0)~ THEN REPLY ~... Many Missiles.~ DO ~SetGlobal("US_Wish_Epic_014_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10014)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_014_P5","GLOBAL",0)~ THEN REPLY ~... Many Missiles.~ DO ~SetGlobal("US_Wish_Epic_014_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10014)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_014_P6","GLOBAL",0)~ THEN REPLY ~... Many Missiles.~ DO ~SetGlobal("US_Wish_Epic_014_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10014)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_009_P1","GLOBAL",0)~ THEN REPLY ~... Mass Energy Drain.~ DO ~SetGlobal("US_Wish_Epic_009_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10009)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_009_P2","GLOBAL",0)~ THEN REPLY ~... Mass Energy Drain.~ DO ~SetGlobal("US_Wish_Epic_009_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10009)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_009_P3","GLOBAL",0)~ THEN REPLY ~... Mass Energy Drain.~ DO ~SetGlobal("US_Wish_Epic_009_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10009)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_009_P4","GLOBAL",0)~ THEN REPLY ~... Mass Energy Drain.~ DO ~SetGlobal("US_Wish_Epic_009_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10009)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_009_P5","GLOBAL",0)~ THEN REPLY ~... Mass Energy Drain.~ DO ~SetGlobal("US_Wish_Epic_009_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10009)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_009_P6","GLOBAL",0)~ THEN REPLY ~... Mass Energy Drain.~ DO ~SetGlobal("US_Wish_Epic_009_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10009)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_006_P1","GLOBAL",0)~ THEN REPLY ~... Pestilence.~ DO ~SetGlobal("US_Wish_Epic_006_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10006)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_006_P2","GLOBAL",0)~ THEN REPLY ~... Pestilence.~ DO ~SetGlobal("US_Wish_Epic_006_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10006)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_006_P3","GLOBAL",0)~ THEN REPLY ~... Pestilence.~ DO ~SetGlobal("US_Wish_Epic_006_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10006)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_006_P4","GLOBAL",0)~ THEN REPLY ~... Pestilence.~ DO ~SetGlobal("US_Wish_Epic_006_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10006)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_006_P5","GLOBAL",0)~ THEN REPLY ~... Pestilence.~ DO ~SetGlobal("US_Wish_Epic_006_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10006)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_006_P6","GLOBAL",0)~ THEN REPLY ~... Pestilence.~ DO ~SetGlobal("US_Wish_Epic_006_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10006)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_015_P1","GLOBAL",0)~ THEN REPLY ~... Souleating Weapon.~ DO ~SetGlobal("US_Wish_Epic_015_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10015)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_015_P2","GLOBAL",0)~ THEN REPLY ~... Souleating Weapon.~ DO ~SetGlobal("US_Wish_Epic_015_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10015)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_015_P3","GLOBAL",0)~ THEN REPLY ~... Souleating Weapon.~ DO ~SetGlobal("US_Wish_Epic_015_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10015)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_015_P4","GLOBAL",0)~ THEN REPLY ~... Souleating Weapon.~ DO ~SetGlobal("US_Wish_Epic_015_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10015)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_015_P5","GLOBAL",0)~ THEN REPLY ~... Souleating Weapon.~ DO ~SetGlobal("US_Wish_Epic_015_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10015)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_015_P6","GLOBAL",0)~ THEN REPLY ~... Souleating Weapon.~ DO ~SetGlobal("US_Wish_Epic_015_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10015)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_008_P1","GLOBAL",0)~ THEN REPLY ~... Xvimian Storm.~ DO ~SetGlobal("US_Wish_Epic_008_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10008)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_008_P2","GLOBAL",0)~ THEN REPLY ~... Xvimian Storm.~ DO ~SetGlobal("US_Wish_Epic_008_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10008)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_008_P3","GLOBAL",0)~ THEN REPLY ~... Xvimian Storm.~ DO ~SetGlobal("US_Wish_Epic_008_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10008)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_008_P4","GLOBAL",0)~ THEN REPLY ~... Xvimian Storm.~ DO ~SetGlobal("US_Wish_Epic_008_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10008)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_008_P5","GLOBAL",0)~ THEN REPLY ~... Xvimian Storm.~ DO ~SetGlobal("US_Wish_Epic_008_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10008)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_008_P6","GLOBAL",0)~ THEN REPLY ~... Xvimian Storm.~ DO ~SetGlobal("US_Wish_Epic_008_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10008)")~ EXIT
END