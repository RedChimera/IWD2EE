BEGIN ~USSTMA~

IF WEIGHT #0 ~  NumTimesTalkedTo(0)
~ THEN BEGIN 0
  SAY ~Well, well... I did not think they would really be here, yet here they are. You were right, Mirabel.~
  IF ~~ THEN EXTERN ~USSTMI~ 0
END

IF ~~ THEN BEGIN 1
  SAY ~I will not. So, how shall we proceed?~
  IF ~~ THEN EXTERN ~USSTMI~ 1
END

IF ~~ THEN BEGIN 2
  SAY ~I am Majrash. Conjurer and connoisseur of fine wine and fine women.~
  IF ~~ THEN EXTERN ~USSTMI~ 2
END

IF ~~ THEN BEGIN 3
  SAY ~The Legion of the Chimera selected us to bury you. They have excellent taste in assassins.~
  IF ~~ THEN EXTERN ~USSTMI~ 3
END

IF ~~ THEN BEGIN 4
  SAY ~'Twas 20,000 gold pieces. Wherever shall we spend it all?~
  IF ~~ THEN REPLY ~What if I paid you 20,000 to leave us be?~ EXTERN ~USSTMI~ 4
  IF ~PartyGoldLT(20000)~ THEN REPLY ~Well, I can't afford that. Nevermind, then.~ DO ~Enemy()
~ EXIT
END

IF ~~ THEN BEGIN 5
  SAY ~How lovely. Shall we go?~
  IF ~~ THEN REPLY ~Farewell, assassins.~ DO ~AddexperienceParty(20000)
TakePartyGold(20000)
~ EXIT
END

IF ~~ THEN BEGIN 6
  SAY ~Don't push your luck, adventurer. 20,000 gold, and n-not a copper more.~
  IF ~~ THEN REPLY ~Farewell, assassins.~ DO ~AddexperienceParty(20000)
TakePartyGold(20000)
~ EXIT
END

IF ~~ THEN BEGIN 7
  SAY ~How lovely. Shall we go?~
  IF ~~ THEN REPLY ~Farewell, assassins.~ DO ~AddexperienceParty(20000)
TakePartyGold(30000)
~ EXIT
END

IF ~~ THEN BEGIN 8
  SAY ~How lovely. Shall we go?~
  IF ~~ THEN REPLY ~Farewell, assassins.~ DO ~AddexperienceParty(20000)
TakePartyGold(40000)
~ EXIT
END

IF ~~ THEN BEGIN 9
  SAY ~How lovely. Shall we go?~
  IF ~~ THEN REPLY ~Farewell, assassins.~ DO ~AddexperienceParty(20000)
TakePartyGold(50000)
~ EXIT
END
