// creator  : C:\Users\matth\Documents\Downloads\NearInfinity.jar (v2.1-20180615)
// game     : C:\Program Files (x86)\Black Isle\Icewind Dale II
// resource : 61ARCHON.DLG
// source   : data\DLG.bif
// dialog   : dialog.tlk
// dialogF  : (none)

BEGIN ~61ARCHON~

IF ~True()~ THEN BEGIN 0 // from: 1.14 4.0 5.0
  SAY #35807 /* ~Destination?~ */
  IF ~!Global("CurrentDestination","MYAREA", 3)
Global("PlayerCanRequestExit","MYAREA", 1)~ THEN REPLY #35810 /* ~Take us to the Fields of Slaughter exit.~ */ DO ~SetGlobal("DestinationRequest", "LOCALS", 3)~ GOTO 1
  IF ~!Global("CurrentDestination", "MYAREA", 2)
Global("PlayerSawGuardPost", "MYAREA", 1)~ THEN REPLY #35809 /* ~We'd like to see the guard post.~ */ DO ~SetGlobal("DestinationRequest", "LOCALS", 2)~ GOTO 1
  IF ~!Global("CurrentDestination", "MYAREA", 4)
Global("PlayerKnowsLothar", "MYAREA", 1)~ THEN REPLY #35811 /* ~King Lothar's citadel if it's accessible.~ */ DO ~SetGlobal("DestinationRequest", "LOCALS", 4)~ GOTO 1
  IF ~!Global("CurrentDestination", "MYAREA", 5)
Global("PlayerKnowsPyrosDead", "MYAREA", 1)~ THEN REPLY #35813 /* ~We'd like to see Lord Pyros' domain.~ */ DO ~SetGlobal("DestinationRequest", "LOCALS", 5)~ GOTO 1
  IF ~!Global("CurrentDestination", "MYAREA", 6)
Global("PlayerKnowsJasper", "MYAREA", 1)~ THEN REPLY #35814 /* ~We need to visit Ambassador Jasper's embassy.~ */ DO ~SetGlobal("DestinationRequest", "LOCALS", 6)~ GOTO 1
  IF ~!Global("CurrentDestination","MYAREA",7)
Global("PlayerKnowsStash","MYAREA",1)~ THEN REPLY @6191 /* ~Can you reach a lava mephit lair southwest of the amphitheatre?~ */ DO ~SetGlobal("DestinationRequest", "LOCALS", 7)~ GOTO 1
  IF ~!Global("CurrentDestination", "MYAREA", 8)
Global("PlayerSawAmphitheatre", "MYAREA", 1)~ THEN REPLY #35816 /* ~We were considering the amphitheatre.~ */ DO ~SetGlobal("DestinationRequest", "LOCALS", 8)~ GOTO 1
  IF ~!Global("CurrentDestination", "MYAREA", 1)~ THEN REPLY #35808 /* ~We're ready to return to the upper levels.~ */ DO ~SetGlobal("DestinationRequest", "LOCALS", 1)~ GOTO 2
  IF ~Global("CurrentDestination", "MYAREA", 1)
Global("PlayerCanRequestExit","MYAREA", 0)
Global("PlayerSawGuardPost", "MYAREA", 0)
Global("PlayerKnowsLothar", "MYAREA", 0)
Global("PlayerKnowsPyrosDead", "MYAREA", 0)
Global("PlayerKnowsJasper", "MYAREA", 0)
Global("PlayerSawAmphitheatre", "MYAREA", 0)~ THEN REPLY @6192 /* ~We need to visit Ambassador Jasper's embassy.~ */ DO ~SetGlobal("DestinationRequest", "LOCALS", 6)~ GOTO 1
  IF ~~ THEN REPLY #30477 /* ~Can you heal me?~ */ DO ~SetGlobal("DestinationRequest", "LOCALS", 0)
StartStore("61Archon",Protagonist)~ EXIT
  IF ~~ THEN REPLY #35817 /* ~None at the moment.  Farewell.~ */ DO ~SetGlobal("DestinationRequest", "LOCALS", 0)~ EXIT
END

IF ~~ THEN BEGIN 1 // from: 0.0 0.1 0.2 0.4 0.6 0.7 0.8
  SAY #35818 /* ~Journey requires three hundred gold pieces per traveler.  Will you pay?~ */
  IF ~NumInParty(1)
PartyGoldGT(299)~ THEN REPLY #35819 /* ~Yes.~ */ DO ~TakePartyGold(300)~ GOTO 2
  IF ~NumInParty(2)
PartyGoldGT(599)~ THEN REPLY #35819 /* ~Yes.~ */ DO ~TakePartyGold(600)~ GOTO 2
  IF ~NumInParty(3)
PartyGoldGT(899)~ THEN REPLY #35819 /* ~Yes.~ */ DO ~TakePartyGold(900)~ GOTO 2
  IF ~NumInParty(4)
PartyGoldGT(1199)~ THEN REPLY #35819 /* ~Yes.~ */ DO ~TakePartyGold(1200)~ GOTO 2
  IF ~NumInParty(5)
PartyGoldGT(1499)~ THEN REPLY #35819 /* ~Yes.~ */ DO ~TakePartyGold(1500)~ GOTO 2
  IF ~NumInParty(6)
PartyGoldGT(1799)~ THEN REPLY #35819 /* ~Yes.~ */ DO ~TakePartyGold(1800)~ GOTO 2
  IF ~NumInParty(1)
!PartyGoldGT(299)~ THEN REPLY #35819 /* ~Yes.~ */ GOTO 3
  IF ~NumInParty(2)
!PartyGoldGT(599)~ THEN REPLY #35819 /* ~Yes.~ */ GOTO 3
  IF ~NumInParty(3)
!PartyGoldGT(899)~ THEN REPLY #35819 /* ~Yes.~ */ GOTO 3
  IF ~NumInParty(4)
!PartyGoldGT(1199)~ THEN REPLY #35819 /* ~Yes.~ */ GOTO 3
  IF ~NumInParty(5)
!PartyGoldGT(1499)~ THEN REPLY #35819 /* ~Yes.~ */ GOTO 3
  IF ~NumInParty(6)
!PartyGoldGT(1799)~ THEN REPLY #35819 /* ~Yes.~ */ GOTO 3
  IF ~~ THEN REPLY #36807 /* ~Will you take items instead?~ */ DO ~SetGlobal("DestinationRequest", "LOCALS", 0)
StartStore("61Archon",Protagonist)~ EXIT
  IF ~GlobalGT("MaxArchonBluffs","MYAREA",0)~ THEN REPLY #38340 /* ~We paid double last time in anticipation of this trip.  Don't you remember?~ */ DO ~IncrementGlobal("MaxArchonBluffs","MYAREA",-1)~ GOTO 2
  IF ~~ THEN REPLY #35820 /* ~Actually we'd like to go someplace else.~ */ GOTO 0
  IF ~~ THEN REPLY #35822 /* ~No.  Farewell.~ */ DO ~SetGlobal("DestinationRequest", "LOCALS", 0)~ EXIT
END

IF ~~ THEN BEGIN 2 // from: 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.13
  SAY #35824 /* ~Departure pending embarkation.~ */
  IF ~~ THEN DO ~SetGlobal("TravelStep","LOCALS",0)~ EXIT
END

IF ~~ THEN BEGIN 3 // from: 1.6 1.7 1.8 1.9 1.10 1.11
  SAY #35826 /* ~Before me is not an adequate supply of coins.  Request denied.~ */
  IF ~~ THEN REPLY #38488 /* ~Will you take anything else?~ */ GOTO 6
  IF ~~ THEN REPLY #1487 /* ~Farewell.~ */ DO ~SetGlobal("DestinationRequest", "LOCALS", 0)~ EXIT
END

IF ~~ THEN BEGIN 4 // from: 0.3
  SAY #35827 /* ~Lord Pyros, killed yesterday by Inquisitor Venomin, walks the Land of the Dead - to which I cannot travel.~ */
  IF ~~ THEN REPLY #35835 /* ~We'd like to go someplace else then.~ */ DO ~SetGlobal("DestinationRequest", "LOCALS", 0)~ GOTO 0
  IF ~~ THEN REPLY #35836 /* ~I see.  Farewell.~ */ EXIT
END

IF ~~ THEN BEGIN 5 // from: 0.5
  SAY #36477 /* ~Lord Pyros is having a private meeting with Inquisitor Venomin.  Neither is to be disturbed.~ */
  IF ~~ THEN REPLY #36478 /* ~Oh?!  We'd like to go someplace else then.~ */ DO ~SetGlobal("DestinationRequest", "LOCALS", 0)~ GOTO 0
  IF ~~ THEN REPLY #17971 /* ~I see.  Farewell.~ */ EXIT
END

IF ~~ THEN BEGIN 6 // from: 3.0
  SAY #38486 /* ~Yes... let me drain some of your life force.~ */
  IF ~CheckStatGT(Protagonist,1,STR)~ THEN REPLY #38490 /* ~You may have some of my strength.~ */ DO ~ChangeStat(Protagonist,STR,-1,ADD)
DisplayString(Protagonist,38474)~ EXIT
  IF ~CheckStatGT(Protagonist,1,INT)~ THEN REPLY #38491 /* ~Feel free to make me slightly less intelligent.~ */ DO ~ChangeStat(Protagonist,INT,-1,ADD)
DisplayString(Protagonist,38475)~ EXIT
  IF ~CheckStatGT(Protagonist,1,WIS)~ THEN REPLY #38492 /* ~I'll share a bit of my wisdom with you.~ */ DO ~ChangeStat(Protagonist,WIS,-1,ADD)
DisplayString(Protagonist,38477)~ EXIT
  IF ~CheckStatGT(Protagonist,1,DEX)~ THEN REPLY #38493 /* ~Becoming somewhat less dexterous is acceptable.~ */ DO ~ChangeStat(Protagonist,DEX,-1,ADD)
DisplayString(Protagonist,38479)~ EXIT
  IF ~CheckStatGT(Protagonist,1,CON)~ THEN REPLY #38494 /* ~I'm willing to donate a portion of my constitution.~ */ DO ~ChangeStat(Protagonist,CON,-1,ADD)
DisplayString(Protagonist,38481)~ EXIT
  IF ~CheckStatGT(Protagonist,1,CHR)~ THEN REPLY #38495 /* ~You can make me slightly less charismatic.~ */ DO ~ChangeStat(Protagonist,CHR,-1,ADD)
DisplayString(Protagonist,38482)~ EXIT
  IF ~~ THEN REPLY #38496 /* ~Will you take items instead?~ */ DO ~SetGlobal("DestinationRequest", "LOCALS", 0)
StartStore("61Archon",Protagonist)~ EXIT
  IF ~GlobalGT("MaxArchonBluffs","MYAREA",0)~ THEN REPLY #38497 /* ~Actually, we paid double last time in anticipation of this trip.  Don't you remember?~ */ DO ~IncrementGlobal("MaxArchonBluffs","MYAREA",-1)~ EXIT
  IF ~~ THEN REPLY #38498 /* ~I think not.  Farewell.~ */ DO ~SetGlobal("DestinationRequest", "LOCALS", 0)~ EXIT
END
