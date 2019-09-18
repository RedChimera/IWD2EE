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
  IF ~Global("USSUOMA_SCARED", "Global", 1)~ THEN REPLY ~That does explain how they survive out here.  Well, I'm leaving.~ GOTO IgnoreLimha
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
  SAY ~Of course. But I would need some compensation for all the work. You'll need to pay a price.~
  IF ~~ THEN REPLY ~Name it.~ GOTO 22
  IF ~~ THEN REPLY ~What kind of price?~ GOTO 22
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
  SAY ~Wait! Wait! I'll do it! I'll break the curse! I'll turn all the children back to normal! Just let me live! I don't want to die! I'll fix everything...~
  IF ~~ THEN DO ~FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)~ GOTO 26
END

IF ~~ THEN BEGIN 22
  SAY ~Your life for theirs. What do you say, adventurer?~
  IF ~~ THEN REPLY ~I don't think so.~ GOTO 21
  IF ~~ THEN REPLY ~How would I even know you'd hold up your end of the bargain?~ GOTO 23
  IF ~~ THEN REPLY ~That's a terrible trade.~ GOTO 21
END

IF ~~ THEN BEGIN 23
  SAY ~I'm a witch of my word. It's up to you. Don't you want to save the village's precious children?~
  IF ~~ THEN REPLY ~Not enough to sacrifice my own life.~ GOTO 21
  IF ~~ THEN REPLY ~I do, but I have many other things to do before I die.~ GOTO 21
  IF ~~ THEN REPLY ~Yes, but I don't believe you'll live up to your end of the bargain.~ GOTO 21
  IF ~NumInParty( 2 )~ THEN REPLY ~Just me, then? My comrade would live?~ GOTO 24
  IF ~NumInParty( 3 )~ THEN REPLY ~Just me, then? My comrades would live?~ GOTO 24
  IF ~NumInParty( 4 )~ THEN REPLY ~Just me, then? My comrades would live?~ GOTO 24
  IF ~NumInParty( 5 )~ THEN REPLY ~Just me, then? My comrades would live?~ GOTO 24
  IF ~NumInParty( 6 )~ THEN REPLY ~Just me, then? My comrades would live?~ GOTO 24
  IF ~CheckSkillGT(Protagonist,10,Intimidate)~ THEN REPLY ~I have a better idea. You cure the children and I'll let you live.~ GOTO 27
END

IF ~~ THEN BEGIN 24
  SAY ~Of course. I only need one. Give me a moment to prepare the materials and I'll use your life force to bring back the children.~
  IF ~~ THEN REPLY ~Actually, no. I don't trust you with my "life force."~ GOTO 21
  IF ~~ THEN REPLY ~On second thought, no. I'm not giving up my life like that.~ GOTO 21
  IF ~!Alignment(Protagonist,MASK_EVIL)~ THEN REPLY ~Perform your spell. I'll give my life to save the children.~ DO ~FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)~ GOTO 25
END

IF ~~ THEN BEGIN 25
  SAY ~Done! You've made the right decision. Hold still--it shouldn't hurt very much.~
  IF ~~ THEN REPLY ~I hope so.~ DO ~Kill(Player1)
Kill(Player2)
Kill(Player3)
Kill(Player4)
Kill(Player5)
Kill(Player6)~ EXIT
  IF ~NumInParty( 2 )~ THEN REPLY ~My friend can always resurrect me later, anyway.~ DO ~Kill(Player1)
Kill(Player2)
~ EXIT
  IF ~NumInParty( 3 )~ THEN REPLY ~My friends can always resurrect me later, anyway.~ DO ~Kill(Player1)
Kill(Player2)
Kill(Player3)
~ EXIT
  IF ~NumInParty( 4 )~ THEN REPLY ~My friends can always resurrect me later, anyway.~ DO ~Kill(Player1)
Kill(Player2)
Kill(Player3)
Kill(Player4)
~ EXIT
  IF ~NumInParty( 5 )~ THEN REPLY ~My friends can always resurrect me later, anyway.~ DO ~Kill(Player1)
Kill(Player2)
Kill(Player3)
Kill(Player4)
Kill(Player5)
~ EXIT
  IF ~NumInParty( 6 )~ THEN REPLY ~My friends can always resurrect me later, anyway.~ DO ~Kill(Player1)
Kill(Player2)
Kill(Player3)
Kill(Player4)
Kill(Player5)
Kill(Player6)~ EXIT
END

IF ~~ THEN BEGIN 26
  SAY ~There! It's done! All the children are back to normal! They're all safe! I did what I promised! Just let me live! Please!~
  IF ~~ THEN REPLY ~Ha! No!~ DO ~AddExperienceParty(10000)~ EXIT
  IF ~~ THEN REPLY ~Take your life and go, Limha. Leave this place and never return.~ DO ~AddExperienceParty(10000)~ EXIT
  IF ~~ THEN REPLY ~You've made the right decision. Now hold still--this is going to hurt a *lot.*~ DO ~AddExperienceParty(20000)~ EXIT
END

IF ~~ THEN BEGIN 27
  SAY ~You will? How generous! But I am far more powerful than you can imagine. I am the *master* of this world.~
  IF ~CheckSkillGT(Protagonist,8,Diplomacy)~ THEN REPLY ~Why do you need to turn the children into minks? What is the point?~ GOTO 28
  IF ~~ THEN REPLY ~If I did accept your offer, how would I know you'd live up to your end of the bargain?~ GOTO 23
  IF ~~ THEN REPLY ~I gave you a chance, Limha. You didn't listen.~ GOTO 21
END

IF ~~ THEN BEGIN 28
  SAY ~The point? Because I can. Because I want to. Because no one can stop me.~
  IF ~!Alignment(Protagonist,MASK_GOOD)
PartyGoldGT(1000)~ THEN REPLY ~What if we paid you to leave? You can take your... activities... elsewhere.~ GOTO 29
  IF ~~ THEN REPLY ~I see. If I did accept your offer, how would I know you'd live up to your end of the bargain?~ GOTO 23
  IF ~!Alignment(Protagonist,MASK_EVIL)~ THEN REPLY ~This is disgusting. This ends now!~ GOTO 21
  IF ~Alignment(Protagonist,MASK_EVIL)~ THEN REPLY ~I'm tired of this. This ends now!~ GOTO 21
END

IF ~~ THEN BEGIN 29
  SAY ~What could you possibly offer me?~
  IF ~!Alignment(Protagonist,MASK_EVIL)~ THEN REPLY ~How about 1,000 gold? That should be enough to get you anywhere you want to go.~ GOTO 32
  IF ~Alignment(Protagonist,MASK_EVIL)~ THEN REPLY ~How about 1,000 gold? You could set up shop in the city. There should be plenty of poor beggars and peasants you can toy with that no one will miss.~ GOTO 30
END

IF ~~ THEN BEGIN 30
  SAY ~Hm... Hm! Now that you mention it, I could do a lot with that. That's a fine price for a batch of minks. Show me the gold and I'll break the curse...~
  IF ~~ THEN DO ~FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)
TakePartyGold(1000)~ GOTO 31
END

IF ~~ THEN BEGIN 31
  SAY ~Done! A pleasure doing business with you, adventurers. Perhaps I'll make my way to Neverwinter--this will be so much fun! *Hm-hm-hm!*~
  IF ~~ THEN REPLY ~Maybe I'll pay you a visit sometime. Farewell, Limha.~ DO ~AddExperienceParty(20000)~ EXIT
END

IF ~~ THEN BEGIN 32
  SAY ~Is that all? Why should I settle for so little? I *love* my life here.~
  IF ~~ THEN REPLY ~Very well, make it 1,500 gold.~ GOTO 33
END

IF ~~ THEN BEGIN 33
  SAY ~Oh, you *do* want those children freed, don't you? Let's make it 15,000.~
  IF ~PartyGoldGT(15000)
CheckSkillLT(Protagonist,5,Diplomacy)~ THEN REPLY ~Very well. If that's what it takes to free the children, we'll pay it.~ DO ~TakePartyGold(15000)~ DO ~AddExperienceParty(5000)~ GOTO 34
  IF ~PartyGoldGT(10000)
CheckSkillLT(Protagonist,10,Diplomacy)
CheckSkillGT(Protagonist,5,Diplomacy)~ THEN REPLY ~We don't have that much to spare. Make it 10,000 and you have a deal.~ DO ~TakePartyGold(10000)~ DO ~AddExperienceParty(7500)~ GOTO 35
  IF ~PartyGoldGT(5000)
CheckSkillLT(Protagonist,20,Diplomacy)
CheckSkillGT(Protagonist,10,Diplomacy)~ THEN REPLY ~These aren't *our* children, Limha. We just need to buy some goodwill with Suoma. We'll pay you 5,000, no more.~ DO ~TakePartyGold(5000)~ DO ~AddExperienceParty(10000)~ GOTO 35
  IF ~PartyGoldGT(1500)
CheckSkillGT(Protagonist,20,Diplomacy)~ THEN REPLY ~These aren't *our* children, Limha; we just need to buy some goodwill with Suoma--and that's only worth so much gold. Besides, I can tell from this hut that 1,500 gold is more gold than you've ever possessed in your life. 1,500 is the best deal you're ever going to see.~ DO ~TakePartyGold(1500)~ DO ~AddExperienceParty(15000)~ GOTO 35
  IF ~~ THEN REPLY ~15,000 gold pieces? I'm not going to stand here and be extorted!~ GOTO 21
END

IF ~~ THEN BEGIN 34
  SAY ~A fair price for a batch of minks, isn't it? Very well, I'll break the curse...~
  IF ~~ THEN DO ~FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)~ GOTO 36
END

IF ~~ THEN BEGIN 35
  SAY ~Fair enough. A fine price for a batch of minks, isn't it? Give me a moment and I'll break the curse...~
  IF ~~ THEN DO ~FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)~ GOTO 36
END

IF ~~ THEN BEGIN 36
  SAY ~Done! A pleasure doing business with you, adventurers. *Hm-hm-hm!*~
  IF ~~ THEN REPLY ~Now leave this place, witch. You're not welcome here anymore.~ EXIT
END

IF ~~ THEN BEGIN IgnoreLimha
  SAY ~What?  You're leaving?~
  IF ~~ THEN REPLY ~I already got the directions I needed from Suoma, and I'm not interested in fighting a witch.  I'm not going to get in your way.~ GOTO IgnoreLimha2
  IF ~~ THEN REPLY ~I'm done with the village.  I don't really care what you're doing with the children.~ GOTO IgnoreLimha2
END

IF ~~ THEN BEGIN IgnoreLimha2
  SAY ~Oh.  That's surprising.  I'll just get rid of this pest, then. *Hm-hm-hm!*~
  IF ~~ THEN DO ~SetGlobal("LimhaAfterHannuDies", "GLOBAL", 1)~ EXTERN ~50HANNU~ 8
END

IF ~Global("LimhaAfterHannuDies", "GLOBAL", 1)~ THEN BEGIN LimhaAfterHannuDies
  SAY ~I welcome you again, precious thing.  I do hope you'll stay a while this time...~
  IF ~~ THEN REPLY ~I'd like to purchase something.~ DO ~StartStore("50Limha", Protagonist)~ EXIT
  IF ~~ THEN REPLY ~I'm just passing through.  Farewell, Limha.~ EXIT
END

