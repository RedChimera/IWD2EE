// Improved Multi-Player NPC kick-out script. You may ask them to wait
// here, go to the copper coronet (SoA) or the pocket plane (ToB). 
// 
// TO INSTALL ME:
// Go to your main BGII directory and type: 
// C:\BGII> weidu multig.d --out override 

/*
 * MULTIG patch version 1.0.1
 * home page: http://www.cs.berkeley.edu/~weimer/bgate
 * edit: g_blucher@yahoo.com
 * This version uses existing strings, for non-english versions of game.
 */

BEGIN ~MULTIG~

// this is what we say if we are kicked out and waiting around
IF ~Global("Waiting","LOCALS",1)
!InParty(Myself)~ THEN BEGIN wait
  SAY #13347 /* ~Hello again. A pleasure as it was before.~ */
  IF ~~ THEN REPLY #74098 /* ~Please rejoin the party.~ */
    DO ~SetGlobal("Waiting","LOCALS",0)
JoinParty()~ EXIT
  IF ~~ THEN REPLY #27251 /* ~You will have to wait here.  I have no room for you at the moment.~ */ EXIT
END

// this is what we say when we were just recently kicked out
IF ~Global("Waiting","LOCALS",0)
!InParty(Myself)~ THEN BEGIN left
  SAY #43200 /* ~It has been a pleasure adventuring with you. Well met, and farewell.~ */
  IF ~~ THEN REPLY #74098 /* ~Please rejoin the party.~ */ DO ~JoinParty()~ EXIT
  IF ~GlobalLT("Chapter","GLOBAL",8)
!AreaCheck("AR0406")~ THEN REPLY #49701 /* ~Go wait for us at the Copper Coronet.  If things change, we'll come meet you there.~ */ DO
~SetGlobal("Waiting","LOCALS",1)
EscapeAreaMove("AR0406",689,1127,0)~ EXIT
  IF ~!GlobalLT("Chapter","GLOBAL",8)
!AreaCheck("AR4500")
!AreaCheck("AR4000")
!AreaCheck("AR6200")~ THEN REPLY #65242 /* ~I'll send you back to the pocket plane...wait for me there.~ */ DO 
~CreateVisualEffectObject("SPDIMNDR",Myself)
SetGlobal("Waiting","LOCALS",1)
Wait(2)
MoveBetweenAreas("AR4500",[2552.1445],2)~ EXIT
  IF ~~ THEN REPLY #27251 /* ~You will have to wait here.  I have no room for you at the moment.~ */ DO ~SetGlobal("Waiting","LOCALS",1)~ EXIT
END

// how did we ever get here?
IF ~InParty(Myself)
Gender(Myself,MALE)~ THEN BEGIN boy
  SAY #11082 /* ~ Hello there.~ [GENMG05] */
  IF ~~ THEN EXIT
END

// how did we ever get here?
IF ~InParty(Myself)
Gender(Myself,FEMALE)~ THEN BEGIN girl
  SAY #11119 /* ~ Hello there.~ [GENFG12] */
  IF ~~ THEN EXIT
END


