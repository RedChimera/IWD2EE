/* Example DLG file for example MOD */
BEGIN FOOZLE

IF ~True()~ THEN BEGIN state1
  SAY ~Hello, this is FOOZLE.DLG!~
  IF ~~ THEN REPLY ~Goodbye, Foozle.~ EXIT
  IF ~~ THEN REPLY @1 EXIT // uses TRA file 
END

BEGIN FOOZLE2

IF ~True()~ THEN BEGIN state1
  SAY ~Hello, this is FOOZLE2.DLG!~
  IF ~~ THEN REPLY ~Goodbye, Foozle2.~ EXIT
END

// our TP file mentions that this DLG may not be present
APPEND NOTHERE
  IF ~~ THEN BEGIN state1
    SAY ~Hello, this is NOTHERE.DLG~
    IF ~~ THEN REPLY ~Goodbye, Not-here.~ EXIT
  END
END
