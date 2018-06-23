// This file serves three purposes: 1. To fix Korgan's PC interaction so he
// doesn't say the same thing to you over and over and over again.  (The
// problem is that the game never sets the flag that indicates that you
// have had the conversation!)
//
// 2. To fix Viconia's LOVETALK 46 so that both player options work (Reply
// #2 led nowhere)
//
// 3. To serve as a short demonstration of WeiDU's flexibility and
// usefulness for small, patch-in-place operations.
//
// To install: Place this file (kvfix.d) and the latest copy of
// WeiDU.exe in your main BG2 directory (where BGmain.exe is kept.)
// 
// Open a command window, CD to the directory in question, and type this
// command:
// 
// weidu kvfix.d --out override
// 
// This will correct the looping error, and allow Viconia's LOVETALK 46 to
// function with both top-level options.  - Jason Compton
// (jcompton@xnet.com)
//
// PS: Because we are using the in-game STRREFs here, this should work for
// any language version of the game.  This should also be compatible with
// any mods you have installed.  PPS: Those of you working on third-party
// MODs to BG2 should be sparing in your use of REPLACE--it is best left
// for making these sorts of necessary patches, rather than running wild
// through the game, because it tends to be a real downer for
// compatibility. These should be quite safe for anyone's configuration,
// unless somebody has gone through the game and COMPLETELY reworked their
// own DLG files.

REPLACE BKORGAN
IF ~See(Player1)
!StateCheck(Player1,STATE_SLEEPING)
Global("BKorgan24","LOCALS",0)~ THEN BEGIN 109 // from:
  SAY #18201 
  IF ~~ THEN REPLY #61034 DO ~Global("BKorgan24","LOCALS",1)~ GOTO 65
  IF ~~ THEN REPLY #61035 DO ~Global("BKorgan24","LOCALS",1)~ GOTO 78
END
END


REPLACE BVICONI
IF ~Global("LoveTalk","LOCALS",46)~ THEN BEGIN 103 // from:
  SAY #10537 
  IF ~~ THEN REPLY #10538 GOTO 367
  IF ~~ THEN REPLY #10539 GOTO 368
END
END
