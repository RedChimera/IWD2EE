// This file is part of a small WeiDU tutorial written by Michael Lyashenko.
// For more information, see the WeiDU README. 

// Always start with "begin" and name of the file:
BEGIN BULEND

REPLACE JAHEI25J // Text followed after double slash is a comment
  IF ~~ THEN BEGIN 21 // Note state that we want to change, 21, not 22
  // You are completely replacing this state, so go right ahead.
    SAY ~Oh my... I... what can I say?~
    IF ~You can say... that you'll marry me.~ THEN GOTO JAHADD1 // JAHADD1 is a made-up name of the soon-to-be state
  END
END // stop replacing

APPEND JAHEI25J // Now we're appending additional state to Jaheira's file
  IF ~~ THEN BEGIN JAHADD1 // There's that made-up name again
    SAY ~I ...~
    IF ~~ THEN REPLY ~(Smile at Jaheira)~ GOTO JAHADD2 // Another made-up name, see below
  END

  // We're still not done adding, so keep typing without ENDing
  IF ~~ THEN BEGIN JAHADD2
    SAY ~But I have a duty to uphold, I'm a harper and a druid I must strive to obtain balance.  I must ... and if we ... but ...~
    IF ~~ THEN REPLY ~Jaheira!~ GOTO JAHADD3
  END

  IF ~~ THEN BEGIN JAHADD3
    SAY ~Yes?~
    IF ~~ THEN REPLY ~You're babbling, and as your husband don't you think that I would take an active hand in assisting you in anything you do?~ GOTO JAHADD4
  END

  IF ~~ THEN BEGIN JAHADD4
    SAY ~Yes I suppose ... yes, YES (ahem) I shall marry you!  You and I shall be as one, united.  Take my hand <CHARNAME> and let us leave this place.~
    // Now we don't want any response option, so no REPLY this time.
    // We also want to end this, and let Solar finally talk.
    // Remember that FINSOL 33 state, to which all previous responses led to? Go right ahead:
    IF ~~ THEN EXTERN FINSOL01 33
  END
END // We're done with APPEND, so don't forget to END it

// Now all you have to do is compile it.
// Put WeiDU.exe in your BG2 folder, as well as this file, and bulend.bat
// In bulend.bat there's this command:
// "weidu bulend.d --out override
// That tells WeiDU to compile bulend.d while putting files in override and
// saving resulted dialog.tlk by replacing the original.  *Close
// NearInfinity*, and run bulend.bat file.  You are now done, and your
// dialogs are in the game.  You can load up NearInfinity again, find
// JAHEI25J dialog, head to STATE 20, select response #3 and watch it
// unfold... :)
