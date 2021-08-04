// creator  : C:\Users\matth\Documents\NearInfinity-IEex\NearInfinity.jar (v2.1-20210123)
// game     : C:\Program Files (x86)\Black Isle\Icewind Dale II
// resource : 41ALTAR.DLG
// source   : data\DLG.bif
// dialog   : dialog.tlk
// dialogF  : (none)

BEGIN ~41ALTAR~

IF ~NumTimesTalkedTo(0)~ THEN BEGIN 0 // from:
  SAY #21769 /* ~WELCOME, MORTALS!  HAVE YOU COME TO QUENCH MY THIRST?~ */
  IF ~Global("41PlayerKnowsTempestName", "GLOBAL", 1)~ THEN REPLY #21774 /* ~Aeij-Kllenzr't, I invoke your true name, Caged Fury, and hereby banish you from this plane of existence!~ */ DO ~AddXpVar("Level_8_Very_Hard",21727)
~ JOURNAL #18557 /* ~We found one of Auril's altars in a secluded room on the bottom floor of the ice temple.  The altar contained the spirit of a tempest named Aeij-Kllenzr't who was pretending to be Auril, and we banished him from it by invoking his true name, Caged Fury.  He's been keeping the ice from melting, but he couldn't survive outside of the altar in his current form.~ */ GOTO 8
  IF ~Global("41PlayerKnowsTempestName", "GLOBAL", 1)~ THEN REPLY @23065 GOTO US41ALTAR2
  IF ~Global("41PlayerKnowsTempestName", "GLOBAL", 0)~ THEN REPLY #21775 /* ~Who are you?~ */ GOTO 2
  IF ~~ THEN REPLY #21781 /* ~Your thirst?~ */ GOTO 3
  IF ~~ THEN REPLY #21782 /* ~No.  Farewell.~ */ GOTO 9
END

IF ~NumTimesTalkedToGT(0)~ THEN BEGIN 1 // from:
  SAY #21786 /* ~WELCOME BACK, MORTALS!  ARE YOU READY TO QUENCH MY THIRST?~ */
  IF ~Global("41PlayerKnowsTempestName", "GLOBAL", 1)~ THEN REPLY #21774 /* ~Aeij-Kllenzr't, I invoke your true name, Caged Fury, and hereby banish you from this plane of existence!~ */ DO ~AddXpVar("Level_8_Very_Hard",21727)
~ JOURNAL #18557 /* ~We found one of Auril's altars in a secluded room on the bottom floor of the ice temple.  The altar contained the spirit of a tempest named Aeij-Kllenzr't who was pretending to be Auril, and we banished him from it by invoking his true name, Caged Fury.  He's been keeping the ice from melting, but he couldn't survive outside of the altar in his current form.~ */ GOTO 8
  IF ~Global("41PlayerKnowsTempestName", "GLOBAL", 1)~ THEN REPLY @23065 GOTO US41ALTAR2
  IF ~Global("41TempestSaidName", "GLOBAL", 1)
Or(2)
CheckStatGT(Protagonist, 20, INT)
Kit(Protagonist,CLERIC_TALOS)~ THEN REPLY #21789 /* ~Aeij-Kllenzr't?  Caged Fury?~ */ GOTO US41ALTAR1
  IF ~Global("41TempestSaidName", "GLOBAL", 1)~ THEN REPLY #21790 /* ~If you're so infinite, why do you confine yourself to an altar?  Step out and face us, or is the Goddess of Winter a coward?~ */ GOTO 10
  IF ~Global("PlayerKnowsMe","LOCALS",0)
Global("41PlayerKnowsTempestName","GLOBAL",0)~ THEN REPLY #21775 /* ~Who are you?~ */ GOTO 2
  IF ~~ THEN REPLY #21781 /* ~Your thirst?~ */ GOTO 3
  IF ~~ THEN REPLY #21782 /* ~No.  Farewell.~ */ GOTO 9
END

IF ~~ THEN BEGIN 2 // from: 0.1 1.4 4.0
  SAY #21793 /* ~HAS YOUR BRAIN MELTED INTO YOUR EARS?!  CAN YOU NOT *HEAR* THE VOICE OF AURIL?!~ */
  IF ~Global("41TempestSaidName", "GLOBAL", 1)
Or(2)
CheckStatGT(Protagonist, 20, INT)
Kit(Protagonist,CLERIC_TALOS)~ THEN REPLY #21794 /* ~Didn't you say your name was Caged Fury?~ */ GOTO US41ALTAR1
  IF ~Global("41TempestSaidName", "GLOBAL", 1)
CheckStatGT(Protagonist, 8, INT)
CheckStatLT(Protagonist, 21, INT)~ THEN REPLY #21797 /* ~Didn't you say your name was Aeij-Kllenzr't?~ */ GOTO 9
  IF ~~ THEN REPLY #21801 /* ~Why are you doing this?~ */ GOTO 4
  IF ~~ THEN REPLY #21806 /* ~What do you thirst for?~ */ GOTO 3
  IF ~~ THEN REPLY #21814 /* ~Of course.  Farewell.~ */ GOTO 9
END

IF ~~ THEN BEGIN 3 // from: 0.2 1.5 2.3 4.1
  SAY #21815 /* ~I THIRST FOR THE BLOOD OF MORTALS.  SPILL IT UPON THE DAIS ABOVE AND YOUR LIVES SHALL BE SPARED.~ */
  IF ~Global("Lysara_dead", "GLOBAL", 1)
Global("Cathin_dead", "GLOBAL", 1)
Global("Oria_dead", "GLOBAL", 1)~ THEN REPLY #21816 /* ~There's no one left to feed you.  Your cause is lost.~ */ GOTO 5
  IF ~Global("Lysara_dead", "GLOBAL", 1)
Global("Cathin_dead", "GLOBAL", 1)
Global("Oria_dead", "GLOBAL", 1)
CheckSkillGT(Protagonist,7,Intimidate )~ THEN REPLY #21818 /* ~There's no one left to feed you.  Your cause is lost.  Surrender now!~ */ GOTO US41ALTAR3
  IF ~Global("41XhaanGaveName", "GLOBAL", 1)~ THEN REPLY #28799 /* ~"Spill it upon the dais above?"  You're the one Xhaan calls Aeij-Kllenzr't!~ */ GOTO 12
  IF ~~ THEN REPLY #28802 /* ~I'll consider it.  Farewell.~ */ GOTO 9
END

IF ~~ THEN BEGIN 4 // from: 2.2
  SAY #30544 /* ~THE MORTALS OF THIS LAND HAVE BECOME COMPLACENT.  THEY MUST LEARN TO ONCE AGAIN FEAR THE GODS OF FURY!~ */
  IF ~Global("PlayerKnowsMe","LOCALS",0)
Global("41PlayerKnowsTempestName","GLOBAL",0)~ THEN REPLY #21775 /* ~Who are you?~ */ GOTO 2
  IF ~~ THEN REPLY #21806 /* ~What do you thirst for?~ */ GOTO 3
  IF ~~ THEN REPLY #30546 /* ~I see.  Farewell.~ */ GOTO 9
END

IF ~~ THEN BEGIN 5 // from: 3.0 3.1
  SAY #30547 /* ~IT'S NO MATTER!  OTHERS WILL REPLACE THEM, AND I HAVE ALL OF ETERNITY TO WAGE THIS WAR!~ */
  IF ~~ THEN REPLY #30549 /* ~You'll never win.~ */ GOTO 6
  IF ~CheckSkillGT(Protagonist,7,Intimidate)~ THEN REPLY #32133 /* ~You'll never win.  Surrender now!~ */ GOTO US41ALTAR3
  IF ~~ THEN REPLY #30546 /* ~I see.  Farewell.~ */ GOTO 9
END

IF ~~ THEN BEGIN 6 // from: 5.0 5.1
  SAY #32134 /* ~WHY, MORTAL?!  I'LL HUMOR YOU THIS *ONE* TIME!~ */
  IF ~CheckStatGT(Protagonist, 15, INT)~ THEN REPLY #32135 /* ~With your Aurilites gone, you are now only one.  We, on the other hand, have friends, and they have armies, so together we are many.~ */ DO ~SetGlobal("41TempestSaidName", "GLOBAL", 1)~ GOTO 7
  IF ~CheckStatGT(Protagonist, 8, INT)
CheckStatLT(Protagonist, 16, INT)
NumInParty(1)~ THEN REPLY #32136 /* ~You're alone now.  I'll return with more allies.~ */ DO ~SetGlobal("41TempestSaidName", "GLOBAL", 1)~ GOTO 7
  IF ~CheckStatGT(Protagonist, 8, INT)
CheckStatLT(Protagonist, 16, INT)
NumInParty(2)~ THEN REPLY #32137 /* ~My companions and I outnumber you two to one.~ */ DO ~SetGlobal("41TempestSaidName", "GLOBAL", 1)~ GOTO 7
  IF ~CheckStatGT(Protagonist, 8, INT)
CheckStatLT(Protagonist, 16, INT)
NumInParty(3)~ THEN REPLY #32138 /* ~My companions and I outnumber you three to one.~ */ DO ~SetGlobal("41TempestSaidName", "GLOBAL", 1)~ GOTO 7
  IF ~CheckStatGT(Protagonist, 8, INT)
CheckStatLT(Protagonist, 16, INT)
NumInParty(4)~ THEN REPLY #32139 /* ~My companions and I outnumber you four to one.~ */ DO ~SetGlobal("41TempestSaidName", "GLOBAL", 1)~ GOTO 7
  IF ~CheckStatGT(Protagonist, 8, INT)
CheckStatLT(Protagonist, 16, INT)
NumInParty(5)~ THEN REPLY #32141 /* ~My companions and I outnumber you five to one.~ */ DO ~SetGlobal("41TempestSaidName", "GLOBAL", 1)~ GOTO 7
  IF ~CheckStatGT(Protagonist, 8, INT)
CheckStatLT(Protagonist, 16, INT)
NumInParty(6)~ THEN REPLY #32142 /* ~My companions and I outnumber you six to one.~ */ DO ~SetGlobal("41TempestSaidName", "GLOBAL", 1)~ GOTO 7
  IF ~CheckStatLT(Protagonist, 9, INT)~ THEN REPLY #32143 /* ~I don't know, but I'm sure there's a good reason.~ */ GOTO 9
  IF ~~ THEN REPLY #33310 /* ~No reason.  Farewell.~ */ GOTO 9
END

IF ~~ THEN BEGIN 7 // from: 6.0 6.1 6.2 6.3 6.4 6.5 6.6
  SAY #33312 /* ~YES, YOU *ARE* MANY, THIS IS TRUE... BUT YOU ARE FINITE.  AND YES, I *AM* ONLY ONE... BUT *I*, AEIJ-KLLENZR'T, AM INFINITE!~ */
  IF ~Or(2)
CheckStatGT(Protagonist, 20, INT)
Kit(Protagonist,CLERIC_TALOS)~ THEN REPLY #21789 /* ~Aeij-Kllenzr't?  Caged Fury?~ */ DO ~SetGlobal("41PlayerKnowsTempestName", "GLOBAL", 1)~ GOTO US41ALTAR1
  IF ~CheckStatLT(Protagonist, 21, INT)
!Kit(Protagonist,CLERIC_TALOS)~ THEN REPLY #33313 /* ~Aeij-Kllenzr't?~ */ GOTO 9
  IF ~~ THEN REPLY #21790 /* ~If you're so infinite, why do you confine yourself to an altar?  Step out and face us, or is the Goddess of Winter a coward?~ */ GOTO 10
  IF ~~ THEN REPLY #30546 /* ~I see.  Farewell.~ */ GOTO 9
END

IF ~~ THEN BEGIN 8 // from: 0.0 1.0 1.1 1.2 2.0 3.2 5.2 7.2 10.0 11.0
  SAY #33314 /* ~WHAT?! TALOS, SAVE YOUR LOYAL SERVANT!  I... I KEPT THE ICE FLOWING - AS YOU COMMANDED!... ONCE YOU BOUND MY SPIRIT INTO THIS ALTAR I PRETENDED TO BE AURIL...~ */
  IF ~~ THEN GOTO 13
END

IF ~~ THEN BEGIN 9 // from: 0.3 1.3 1.6 2.1 2.4 3.4 4.2 5.3 6.7 6.8 7.0 7.1 7.3 7.4 12.0
  SAY #33571 /* ~DISTURB YOUR GODDESS AGAIN WITHOUT AN OFFERING AND SUFFER THE PAIN OF A MILLION DEATHS!  NOW AWAY WITH YOU BEFORE SHE RECONSIDERS!~ */
  IF ~RandomNum(4, 1)~ THEN DO ~ReallyForceSpell(LastMarkedObject,WIZARD_GEDLEES_ELECTRIC_LOOP)~ EXIT
  IF ~RandomNum(4, 2)~ THEN DO ~ReallyForceSpell(LastMarkedObject, WIZARD_CHAIN_LIGHTNING)~ EXIT
  IF ~RandomNum(4, 3)~ THEN DO ~ReallyForceSpell(LastMarkedObject,WIZARD_ICE_STORM)~ EXIT
  IF ~RandomNum(4, 4)~ THEN DO ~ReallyForceSpell(LastMarkedObject, WIZARD_LIGHTNING_BOLT)~ EXIT
END

IF ~~ THEN BEGIN 10 // from:
  SAY #33572 /* ~YOU DARE CHALLENGE ME *AND* THE QUEEN OF FROST IN HER DOMAIN?!  I SHALL DRAIN YOUR BODY 'TIL NOTHING BUT DUST REMAINS!~ */
  IF ~~ THEN DO ~HideCreature(Myself,TRUE)
CreateCreature("USCFURY2","USCagedFury",[1085.765],2)~ EXIT
END

IF ~~ THEN BEGIN 11 // from:
  SAY #33573 /* ~HA!  HOW FOOLISH OF YOU TO THINK THE GREAT GODS OF FURY CAN BE TOUCHED BY A SLUG LIKE BAERVAN WILDWANDERER!  I'VE HAD JUST A-~ */
  IF ~~ THEN DO ~AddXpVar("Level_8_Very_Hard",21767)
~ JOURNAL #21724 /* ~We found one of Auril's altars in a secluded room on the bottom floor of the ice temple.  The altar contained the spirit of a tempest named Aeij-Kllenzr't who was pretending to be Auril, and Zack Boosenburry banished him from the altar by desecrating it.  The spirit has been keeping the ice from melting, but he couldn't survive outside of the altar in his current form.~ */ GOTO 8
END

IF ~~ THEN BEGIN 12 // from: 3.3
  SAY #33574 /* ~YES... the abishai are superb at ripping the sacrificial flesh apart to let the blood flow freely into me.  For that payment do I keep this precious abode from melting.~ */
  IF ~Global("Lysara_dead", "GLOBAL", 1)
Global("Cathin_dead", "GLOBAL", 1)
Global("Oria_dead", "GLOBAL", 1)~ THEN REPLY #21816 /* ~There's no one left to feed you.  Your cause is lost.~ */ GOTO 5
  IF ~Global("Lysara_dead", "GLOBAL", 1)
Global("Cathin_dead", "GLOBAL", 1)
Global("Oria_dead", "GLOBAL", 1)
CheckSkillGT(Protagonist,7,Intimidate )~ THEN REPLY #21818 /* ~There's no one left to feed you.  Your cause is lost.  Surrender now!~ */ GOTO US41ALTAR3
  IF ~~ THEN REPLY #30546 /* ~I see.  Farewell.~ */ DO ~SetGlobal("PlayerKnowsMe","LOCALS",1)~ GOTO 9
END

IF ~~ THEN BEGIN 13 // from: 8.0
  SAY #33576 /* ~I DEMANDED SACRIFICES FROM THE SISTERS AND FORCED THEIR ABISHAI TO DO MY BIDDING... NOOOOoooo!  I am... *immortal!*  This is *not* over!  I-I-I can't breath...!  *You!*  You will-!~ */
  IF ~~ THEN DO ~SetGlobal("41TempestDieRequest","MYAREA",1)
SetGlobal("41TempestSaidName", "GLOBAL", 1)~ EXIT
END

IF ~~ THEN BEGIN US41ALTAR1
  SAY @23064
  IF ~~ THEN REPLY #21774 /* ~Aeij-Kllenzr't, I invoke your true name, Caged Fury, and hereby banish you from this plane of existence!~ */ DO ~AddXpVar("Level_8_Very_Hard",21727)
~ JOURNAL #18557 /* ~We found one of Auril's altars in a secluded room on the bottom floor of the ice temple.  The altar contained the spirit of a tempest named Aeij-Kllenzr't who was pretending to be Auril, and we banished him from it by invoking his true name, Caged Fury.  He's been keeping the ice from melting, but he couldn't survive outside of the altar in his current form.~ */ GOTO 8
  IF ~~ THEN REPLY @23065 GOTO US41ALTAR2
  IF ~~ THEN REPLY @23066 GOTO 9
END

IF ~~ THEN BEGIN US41ALTAR2
  SAY @23067
  IF ~~ THEN DO ~HideCreature(Myself,TRUE)
CreateCreature("USCFURY2","USCagedFury",[1085.765],2)~ EXIT
END

IF ~~ THEN BEGIN US41ALTAR3
  SAY @23068
  IF ~~ THEN DO ~HideCreature(Myself,TRUE)
CreateCreature("USCFURY2","USCagedFury",[1085.765],2)~ EXIT
END