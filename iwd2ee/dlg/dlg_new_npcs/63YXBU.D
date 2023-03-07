// creator  : C:\Users\matth\Documents\NearInfinity-IEex\NearInfinity.jar (v2.1-20210123)
// game     : C:\Program Files (x86)\Black Isle\Icewind Dale II
// resource : 63YXBU.DLG
// source   : data\DLG.bif
// dialog   : dialog.tlk
// dialogF  : (none)

BEGIN ~63YXBU~

IF ~NumTimesTalkedTo(0)~ THEN BEGIN 0 // from:
  SAY #36750 /* ~...Patience, my minions, patience.  Soon Isair and Madae will bring their plans to fruition, and that is when we bring the Blood War to this plane.~ */
  IF ~~ THEN EXTERN ~63PFIN~ 0
END

IF ~~ THEN BEGIN 1 // from:
  SAY #36752 /* ~SILENCE!  Both of you!  I will consume both of you if I hear another exchange.~ */
  IF ~~ THEN EXTERN ~63PFIN~ 2
END

IF ~~ THEN BEGIN 2 // from:
  SAY #36753 /* ~Yes, grovel at my feet, you pathetic scourge.  Know that I am your master, and I revel in the fact that I control your destiny.  However, I do understand your voracious appetite for these mortals.  I, too, have become quite enamored with their tender flesh.~ */
  IF ~~ THEN GOTO 3
END

IF ~~ THEN BEGIN 3 // from: 2.0
  SAY #36754 /* ~Yes, I long for that day when we may roam the lands of this plane with impunity and gorge on the mortals of the land - mortals like the ones that are eavesdropping on us right now!~ */
  IF ~~ THEN GOTO 4
END

IF ~~ THEN BEGIN 4 // from: 3.0
  SAY #36755 /* ~So, mortal.  You did not think that I could sense your approach?  I can smell the blood of your kind a thousand miles away.  But, that does not concern you, does it?  You are unique among the mortals of this plane.  Your spirit reeks of the deaths of hundreds - very impressive.  Tell me, what is your name?~ */
  IF ~!ClassEx(Protagonist,Paladin) !Subrace(Protagonist,HUMAN_TIEFLING) !Subrace(Protagonist,HUMAN_AASIMAR)~ THEN REPLY #36756 /* ~My name is <CHARNAME>.~ */ GOTO 5
  IF ~Subrace(Protagonist,HUMAN_TIEFLING)
!ClassEx(Protagonist,Paladin) ~ THEN REPLY #36756 /* ~My name is <CHARNAME>.~ */ GOTO 10
  IF ~Subrace(Protagonist, HUMAN_AASIMAR)
!ClassEx(Protagonist,Paladin) ~ THEN REPLY #36756 /* ~My name is <CHARNAME>.~ */ GOTO 11
  IF ~~ THEN REPLY #36757 /* ~Foul beast!  I'll not utter my name to you!  Back to the burning fires of the Nine Hells with you!~ */ GOTO 8
END

IF ~~ THEN BEGIN 5 // from: 4.0
  SAY #36758 /* ~<CHARNAME>, is it?  How mortally simple.  Do you know what I am?  Do you know where I hail from?~ */
  IF ~CheckSkillGT(Protagonist,14,Diplomacy)~ THEN REPLY #36759 /* ~Yes, you're a gelugon. You are second in power only to the formidable pit fiends of the baatezu. Gelugons hail from the icy layers of Stygia and Cania in the Nine Hells; I can tell by your lighter coloring that you're from Cania. Your main duties include spying and being elite guards. If you prove yourself to be a formidable gelugon, which I'm sure you have, you will be given the honor of being cast into the Pit of Hellfrost for 1001 days, then...~ */ DO ~FadeToColor([0.0],0)
FadeFromColor([0.0],0)~ GOTO 6
  IF ~CheckSkillLT(Protagonist,15,Diplomacy)~ THEN REPLY #36760 /* ~From what I can tell, you're a devil. I believe devils come from the Nine Hells. Why is this relevant?~ */ EXTERN ~63PFIN~ 3
  IF ~~ THEN REPLY #36761 /* ~Foul beast!  I'll not utter my name to you!  Back to the burning fires of the Nine Hells with you!~ */ GOTO 8
END

IF ~~ THEN BEGIN 6 // from: 5.0 10.0 11.0
  SAY #36762 /* ~...hmmm, yes, continue...~ */
  IF ~~ THEN REPLY #36763 /* ~...for which legions of tanar'ri and baatezu fell under the weight of monumental battle.  Does that answer your question?~ */ GOTO 7
END

IF ~~ THEN BEGIN 7 // from: 6.0
  SAY #36764 /* ~I must say, I have never met a mortal who was so knowledgeable about the Blood War and the denizens of Baator. I respect this. In fact, I shall let you live, as a reward for your impressive knowledge. Now, I have things I must attend to. Farewell, <CHARNAME>, but know that if we meet again, I will consume you.~ */
  IF ~~ THEN DO ~AddXpVar("Level_14_Hard",36748)
StartCutSceneMode()
StartCutScene("63cDemLv")~ EXIT
END

IF ~~ THEN BEGIN 8 // from: 4.3 5.2 10.2 11.2
  SAY #37653 /* ~Typical mortal hero. Oh well, I was getting a bit hungry anyways. Gentle-devils, after you...~ */
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 9 // from:
  SAY #37654 /* ~ENOUGH!  For the hate of Bane...  I have a simple solution.  Tutup'limbobo, you grab its right leg, Pfinik'millillin, you grab its left leg - and then pull in opposite directions.  The one with the bigger piece wins and gets to watch me eat all the remains.  If there are any scraps left over, then the winner may eat that.  Now go!~ */
  IF ~~ THEN DO ~Enemy()~ EXIT
END

IF ~~ THEN BEGIN 10 // from: 4.1
  SAY #37655 /* ~<CHARNAME>, is it?  Interesting name for a tiefling.  Being as we are kindred spirits of sorts, do you know what I am?  Do you know where I hail from?~ */
  IF ~CheckSkillGT(Protagonist,10,Diplomacy)~ THEN REPLY #36759 /* ~Yes, you're a gelugon. You are second in power only to the formidable pit fiends of the baatezu. Gelugons hail from the icy layers of Stygia and Cania in the Nine Hells; I can tell by your lighter coloring that you're from Cania. Your main duties include spying and being elite guards. If you prove yourself to be a formidable gelugon, which I'm sure you have, you will be given the honor of being cast into the Pit of Hellfrost for 1001 days, then...~ */ DO ~FadeToColor([0.0],0)
FadeFromColor([0.0],0)~ GOTO 6
  IF ~CheckSkillLT(Protagonist,11,Diplomacy)~ THEN REPLY #36760 /* ~From what I can tell, you're a devil. I believe devils come from the Nine Hells. Why is this relevant?~ */ EXTERN ~63PFIN~ 3
  IF ~~ THEN REPLY #36761 /* ~Foul beast!  I'll not utter my name to you!  Back to the burning fires of the Nine Hells with you!~ */ GOTO 8
END

IF ~~ THEN BEGIN 11 // from: 4.2
  SAY #37656 /* ~<CHARNAME>, is it?  Bah, even your name sickens me, aasimar.  Does your celestial blood tingle in my presence - do you know what I am?  Do you know where I come from?~ */
  IF ~CheckSkillGT(Protagonist,17,Diplomacy)~ THEN REPLY #36759 /* ~Yes, you're a gelugon. You are second in power only to the formidable pit fiends of the baatezu. Gelugons hail from the icy layers of Stygia and Cania in the Nine Hells; I can tell by your lighter coloring that you're from Cania. Your main duties include spying and being elite guards. If you prove yourself to be a formidable gelugon, which I'm sure you have, you will be given the honor of being cast into the Pit of Hellfrost for 1001 days, then...~ */ DO ~FadeToColor([0.0],0)
FadeFromColor([0.0],0)~ GOTO 6
  IF ~CheckSkillLT(Protagonist,18,Diplomacy)~ THEN REPLY #36760 /* ~From what I can tell, you're a devil. I believe devils come from the Nine Hells. Why is this relevant?~ */ EXTERN ~63PFIN~ 3
  IF ~~ THEN REPLY #36761 /* ~Foul beast!  I'll not utter my name to you!  Back to the burning fires of the Nine Hells with you!~ */ GOTO 8
END

IF ~~ THEN BEGIN 12
  SAY @41624
  IF ~~ THEN EXTERN ~USXHAAJ~ 36
END

IF ~~ THEN BEGIN 13
  SAY @41626
  IF ~~ THEN EXTERN ~USXHAAJ~ 37
END

IF ~~ THEN BEGIN 14
  SAY @41629
  IF ~~ THEN DO ~SetGlobal("US_Xhaan_Yxbu_Deal","GLOBAL",1)
Enemy()~ EXIT
END

IF ~Global("US_Xhaan_Yxbu_Deal","GLOBAL",2)~ THEN BEGIN 15
  SAY @41630
  IF ~~ THEN EXTERN ~USXHAAJ~ 38
END

IF ~~ THEN BEGIN 16
  SAY @41639
  IF ~~ THEN EXTERN ~USXHAAJ~ 42
END

IF ~Global("US_Xhaan_Yxbu_Deal","GLOBAL",4)~ THEN BEGIN 17
  SAY @41646
  IF ~~ THEN DO ~SetGlobal("US_Xhaan_Yxbu_Deal","GLOBAL",5)
ChangeEnemyAlly(Myself,NEUTRAL)
StartCutSceneMode()
StartCutScene("USXHAAY3")~ EXIT
END

IF ~~ THEN BEGIN 18
  SAY @41648
  IF ~~ THEN DO ~SetGlobal("US_Xhaan_Yxbu_Deal","GLOBAL",6)
Enemy()~ EXIT
END