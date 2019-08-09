BEGIN ~52SERSA~

IF ~  True()
~ THEN BEGIN 0
  SAY #9959
  IF ~  NumberOfTimesTalkedTo(0)
!Global("52Sersa_Train","GLOBAL",2)
~ THEN REPLY #9960 GOTO 1
  IF ~  NumTimesTalkedToGT(0)
!Global("52Sersa_Train","GLOBAL",2)
~ THEN REPLY #9961 GOTO 8
  IF ~  Global("52Sersa_Train","GLOBAL",2)
~ THEN REPLY #9961 GOTO 10
  IF ~~ THEN REPLY #9962 EXIT
END

IF ~~ THEN BEGIN 1
  SAY #9963
  IF ~~ THEN REPLY #9964 DO ~StartStore("52Sersa", Protagonist)~ EXIT
  IF ~~ THEN REPLY #9965 GOTO 2
  IF ~~ THEN REPLY #9966 EXIT
END

IF ~~ THEN BEGIN 2
  SAY #9967
  IF ~  GlobalLT("52Sersa_Train","GLOBAL",2)
~ THEN REPLY #9968 DO ~StartStore("52Sersa", Protagonist)~ EXIT
  IF ~  Global("52Sersa_Train","GLOBAL",2)
~ THEN REPLY #9968 GOTO 7
  IF ~  Global("52Sersa_Train","GLOBAL",0)
~ THEN REPLY #9969 DO ~SetGlobal("52Sersa_Train", "GLOBAL", 1)~ JOURNAL #9955 GOTO 3
  IF ~~ THEN REPLY #9970 EXIT
END

IF ~~ THEN BEGIN 3
  SAY #9971
  IF ~  CheckStatGT(Protagonist,9,CLASSLEVELMONK)
CheckStatLT(Protagonist,15,WIS)
~ THEN REPLY #9972 GOTO 4
  IF ~  CheckStatGT(Protagonist,0,CLASSLEVELMONK)
CheckStatLT(Protagonist,10,CLASSLEVELMONK)
CheckStatGT(Protagonist,14,WIS)
~ THEN REPLY #9973 GOTO 4
  IF ~  CheckStatGT(Protagonist,0,CLASSLEVELMONK)
CheckStatLT(Protagonist,10,CLASSLEVELMONK)
CheckStatLT(Protagonist,15,WIS)
~ THEN REPLY #9972 GOTO 4
  IF ~  CheckStatGT(Protagonist,9,CLASSLEVELMONK)
CheckStatGT(Protagonist,14,WIS)
~ THEN REPLY #9974 DO ~AddXpVar("Level_11_Easy",9958)
SetGlobal("52Sersa_Train", "GLOBAL", 2)
FadeToColor([0.0],0)
FadeFromColor([0.0],0)~ JOURNAL #9956 GOTO 6
  IF ~~ THEN REPLY #9975 GOTO 5
  IF ~~ THEN REPLY #9976 DO ~StartStore("52Sersa", Protagonist)~ EXIT
  IF ~~ THEN REPLY #9970 EXIT
END

IF ~~ THEN BEGIN 4
  SAY #9977
  IF ~~ THEN REPLY #9975 GOTO 5
  IF ~~ THEN REPLY #9964 DO ~StartStore("52Sersa", Protagonist)~ EXIT
  IF ~~ THEN REPLY #9978 EXIT
END

IF ~~ THEN BEGIN 5
  SAY #9979
  IF ~~ THEN REPLY #9964 DO ~StartStore("52Sersa", Protagonist)~ EXIT
  IF ~~ THEN REPLY #9978 EXIT
END

IF ~~ THEN BEGIN 6
  SAY #9980
  IF ~~ THEN REPLY #9981 GOTO 7
  IF ~~ THEN REPLY #9978 EXIT
  IF ~!NumInParty(6)~ THEN REPLY ~I can teach you more, if you like.  I've been practicing my skills all across Icewind Dale and I've learned far more than I did when I was training in a cramped little room.  We could use a dedicated and energetic monk like you.~ GOTO SersaJoinMonk1
END

IF ~~ THEN BEGIN 7
  SAY #9982
  IF ~~ THEN REPLY #9983 DO ~FadeToColor([0.0],0)
FadeFromColor([0.0],0)
RestParty()~ EXIT
  IF ~~ THEN REPLY #9984 DO ~FadeToColor([0.0],0)
FadeFromColor([0.0],0)
RestUntilHealed()~ EXIT
  IF ~~ THEN REPLY #9966 EXIT
END

IF ~~ THEN BEGIN 8
  SAY #9985
  IF ~  Global("52Sersa_Train","GLOBAL",1)
CheckStatGT(Protagonist,9,CLASSLEVELMONK)
CheckStatGT(Protagonist,14,WIS)
~ THEN REPLY #9986 DO ~AddXpVar("Level_11_Easy",9958)
SetGlobal("52Sersa_Train", "GLOBAL", 2)
FadeToColor([0.0],0)
FadeFromColor([0.0],0)~ JOURNAL #9956 GOTO 6
  IF ~  Global("52Sersa_Train","GLOBAL",1)
Global("52Svaltid_Sersa","GLOBAL",1)
~ THEN REPLY #9988 DO ~AddXpVar("Level_11_Easy",9958)
SetGlobal("52Sersa_Train", "GLOBAL", 2)~ JOURNAL #9957 GOTO 9
  IF ~~ THEN REPLY #9964 DO ~StartStore("52Sersa", Protagonist)~ EXIT
  IF ~~ THEN REPLY #9965 GOTO 2
  IF ~~ THEN REPLY #9966 EXIT
END

IF ~~ THEN BEGIN 9
  SAY #9989
  IF ~~ THEN REPLY #9981 GOTO 7
  IF ~~ THEN REPLY #9978 EXIT
  IF ~CheckSkillGT(Protagonist,9,Diplomacy)
!NumInParty(6)
!Global("US_Sersa_Says_No", "GLOBAL", 1)~ THEN REPLY ~You know, there's no better teacher than experience.  If you want to improve your skills, we could use a dedicated monk.  You can learn a lot from adventuring, and not just about the martial arts.~ GOTO SersaJoinSvaltid1
END

IF ~~ THEN BEGIN 10
  SAY #9991
  IF ~~ THEN REPLY #9981 GOTO 7
  IF ~~ THEN REPLY #9965 GOTO 2
  IF ~~ THEN REPLY #9966 EXIT
END

IF ~~ THEN BEGIN SersaJoinSvaltid1
  SAY ~Leave the monastery?  But I've learned so much here -- and my training isn't done yet!~
  IF ~~ THEN REPLY ~If you need outside help just to convince your teacher to do his job, then I think you're going to keep hitting mental walls.  Why don't you go get your last lesson while Svaltid is feeling helpful, then come with us?~ GOTO SersaJoinSvaltid2
END

IF ~~ THEN BEGIN SersaJoinSvaltid2
  SAY ~I've always wanted to travel Faerun... That's how I got to the monastery in the first place, but I settled down to practice my skills.  It suppose it depends on where you're going and what you're doing.~
  IF ~CheckStatGT(Protagonist,6,CHR)~ THEN REPLY ~The Ten Towns are in danger.  The Legion of the Chimera is moving to attack all of them, so we're moving to defend all of them.~ GOTO SersaJoinSvaltid3
  IF ~CheckStatGT(Protagonist,17,CHR)~ THEN REPLY ~Wherever the wind takes us next... which appears to be the depths of the Underdark, and all the horrible creatures therein.  Sounds fun, doesn't it?~ GOTO SersaJoinSvaltid3
  IF ~CheckStatGT(Protagonist,8,CHR)~ THEN REPLY ~We're on a mission from Lord Ulbrec of Targos to bring down the Legion of the Chimera.  We've had to trek all across Icewind Dale to get where we are.  As for where we're going, it starts with the Underdark passage, but after that, it could be anywhere.~ GOTO SersaJoinSvaltid3
  IF ~CheckStatGT(Protagonist,22,CHR)
!ClassEx(Protagonist, Paladin)~ THEN REPLY ~Gold, mostly.  It tends to run out fast... We have some expensive habits.~ GOTO SersaJoinMonk3Alternate
  IF ~CheckStatGT(Protagonist,16,CHR)
!ClassEx(Protagonist, Paladin)~ THEN REPLY ~We have certain grievances with the Legion of the Chimera and its various allies -- namely, their constant attempts to kill us.  We intend to wipe them out.~ GOTO SersaJoinMonk3Alternate
  IF ~CheckStatGT(Protagonist,5,CHR)~ THEN REPLY ~Practicing our skills, just like you.  A constant drive towards self-perfection -- which happens to coincide with a mission to save the Ten Towns from the Legion of the Chimera.~ GOTO SersaJoinSvaltid3
  IF ~CheckStatGT(Protagonist,24,CHR)~ THEN REPLY ~We're killing monsters.  We go where the monsters are and then we kill them.~ GOTO SersaJoinMonk3Alternate
  IF ~CheckStatGT(Protagonist,10,CHR)~ THEN REPLY ~Aside from defeating the Legion of the Chimera?  We're seeing the sights.  Enjoying the weather.  Meeting new people.  Making discoveries.~ GOTO SersaJoinSvaltid3
  IF ~CheckStatGT(Protagonist,21,CHR)~ THEN REPLY ~I don't really know.~ GOTO SersaJoinMonk3Alternate
  IF ~!CheckStatGT(Protagonist,6,CHR)~ THEN REPLY ~The Ten Towns are in danger.  The Legion of the Chimera is moving to attack all of them, so we're moving to defend all of them.~ GOTO SersaJoinSvaltidFailed
  IF ~!CheckStatGT(Protagonist,17,CHR)~ THEN REPLY ~Wherever the wind takes us next... which appears to be the depths of the Underdark, and all the horrible creatures therein.  Sounds fun, doesn't it?~ GOTO SersaJoinSvaltidFailed
  IF ~!CheckStatGT(Protagonist,8,CHR)~ THEN REPLY ~We're on a mission from Lord Ulbrec of Targos to bring down the Legion of the Chimera.  We've had to trek all across Icewind Dale to get where we are.  As for where we're going, it starts with the Underdark passage, but after that, it could be anywhere.~ GOTO SersaJoinSvaltidFailed
  IF ~!CheckStatGT(Protagonist,22,CHR)
!ClassEx(Protagonist, Paladin)~ THEN REPLY ~Gold, mostly.  It tends to run out fast... We have some expensive habits.~ GOTO SersaJoinSvaltidFailed
  IF ~!CheckStatGT(Protagonist,16,CHR)
!ClassEx(Protagonist, Paladin)~ THEN REPLY ~We have certain grievances with the Legion of the Chimera and its various allies -- namely, their constant attempts to kill us.  We intend to wipe them out.~ GOTO SersaJoinSvaltidFailed
  IF ~!CheckStatGT(Protagonist,5,CHR)~ THEN REPLY ~Practicing our skills, just like you.  A constant drive towards self-perfection -- which happens to coincide with a mission to save the Ten Towns from the Legion of the Chimera.~ GOTO SersaJoinSvaltidFailed
  IF ~!CheckStatGT(Protagonist,24,CHR)~ THEN REPLY ~We're killing monsters.  We go where the monsters are and then we kill them.~ GOTO SersaJoinSvaltidFailed
  IF ~!CheckStatGT(Protagonist,10,CHR)~ THEN REPLY ~Aside from defeating the Legion of the Chimera?  We're seeing the sights.  Enjoying the weather.  Meeting new people.  Making discoveries.~ GOTO SersaJoinSvaltidFailed
  IF ~!CheckStatGT(Protagonist,21,CHR)~ THEN REPLY ~I don't really know.~ GOTO SersaJoinSvaltidFailed
END

IF ~~ THEN BEGIN SersaJoinSvaltidFailed
  SAY ~That, um... That sounds like it could be interesting.  But I think I am better off staying here.  I have friends at the monastery and, uh... many things to do.  But I do appreciate you talking to Svaltid for me.  Thank you.~
  IF ~~ THEN REPLY ~I understand.  Farewell, Sersa.~ DO ~SetGlobal("US_Sersa_Says_No", "GLOBAL", 1)~ EXIT
END

IF ~~ THEN BEGIN SersaJoinSvaltid3
  SAY ~That... actually sounds interesting.  But I have so many things to learn here, too... I can't say right now.  Let me go do my training with Svaltid and sleep on it.  I'll talk to you again in the morning...~
  IF ~~ THEN DO ~FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)
RestUntilHealed()~ GOTO SersaJoinSvaltid4
END

IF ~~ THEN BEGIN SersaJoinSvaltid4
  SAY ~I've thought about what you've said and... my answer is yes.  I'd be delighted to join your group.  I've already spoken to Salisam and he's said it's a good opportunity for me.  I'm sure there are things I'll miss by leaving the monastery, but I guess that's the cost of trying new things.  I have my things together -- which basically just means me -- and I'm ready to go.~
  IF ~~ THEN REPLY ~Great.  Let's get started.~ DO ~SetGlobal("US_Sersa_Joined", "GLOBAL", 1)
ApplySpellRES("USSERSC",Myself)~ EXIT
END

IF ~~ THEN BEGIN SersaJoinMonk1
  SAY ~Leave the monastery?  But I've learned so much here -- and my training isn't done yet.~
  IF ~~ THEN REPLY ~I've seen the monks here and the teachers have great skill.  But you are already approaching the limit of what they can teach you.  I see great talent in you.  Perhaps it's time to leave home and go out in search of more knowledge.~ GOTO SersaJoinMonk2
END

IF ~~ THEN BEGIN SersaJoinMonk2
  SAY ~Maybe... But I need to know more about what I'm getting into.  Tell me, where are you going, exactly?~
  IF ~~ THEN REPLY ~The Ten Towns are in danger.  The Legion of the Chimera is moving to attack all of them, so we're moving to defend all of them.~ GOTO SersaJoinMonk3
  IF ~~ THEN REPLY ~Wherever the wind takes us next... which appears to be the depths of the Underdark, and all the horrible creatures therein.  Sounds fun, doesn't it?~ GOTO SersaJoinMonk3
  IF ~~ THEN REPLY ~Lord Ulbrec asked us to bring down the Legion of the Chimera.  We've had to trek all across Icewind Dale to get where we are.  As for where we're going, it starts with the Underdark passage, but after that, it could be anywhere.~ GOTO SersaJoinMonk3
  IF ~~ THEN REPLY ~Practicing my skills, just like you.  I am on a constant drive towards self-perfection -- which happens to coincide with a mission to save the Ten Towns from the Legion of the Chimera.~ GOTO SersaJoinMonk3
END

IF ~~ THEN BEGIN SersaJoinMonk3
  SAY ~That... actually sounds interesting.  But I'm not sure... I can't say right now.  I need to sleep on this.  Give me a day and I'll talk to you again in the morning.~
  IF ~~ THEN REPLY ~Very well.  I will see you then.~ DO ~FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)
RestUntilHealed()~ GOTO SersaJoinMonk4
END

IF ~~ THEN BEGIN SersaJoinMonk3Alternate
  SAY ~I'm not sure... I can't say right now.  I need to sleep on this.  Give me a day and I'll talk to you again in the morning.~
  IF ~~ THEN REPLY ~Very well.  I will see you then.~ DO ~FadeToColor([0.0],0)
Wait(3)
FadeFromColor([0.0],0)
RestUntilHealed()~ GOTO SersaJoinMonk4
END

IF ~~ THEN BEGIN SersaJoinMonk4
  SAY ~I've thought about what you've said and... my answer is yes.  I'd be delighted to join you.  I've already spoken to Salisam and he's said it's a good opportunity for me.  I'm sure there are things I'll miss by leaving the monastery, but that's the cost of trying new things.  I have my things together -- which basically just means me -- and I'm ready to go.~
  IF ~~ THEN REPLY ~Great.  Let's get started.~ DO ~SetGlobal("US_Sersa_Joined", "GLOBAL", 1)
ApplySpellRES("USSERSC",Myself)~ EXIT
END
