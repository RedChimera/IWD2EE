BEGIN USALCP01

IF ~AnyPCSeesEnemy()~ THEN BEGIN 0
  SAY @4796
  IF ~~ THEN REPLY @4795 EXIT
END

IF ~Or(6)
	CheckSkillGT(Player1,31,Alchemy)
	CheckSkillGT(Player2,31,Alchemy)
	CheckSkillGT(Player3,31,Alchemy)
	CheckSkillGT(Player4,31,Alchemy)
	CheckSkillGT(Player5,31,Alchemy)
	CheckSkillGT(Player6,31,Alchemy)~ THEN BEGIN 1
  SAY @4793
  IF ~~ THEN REPLY @4794 DO ~StartStore("USALCP13",LastTalkedToBy)~ EXIT
  IF ~~ THEN REPLY @4795 EXIT
END

IF ~Or(6)
	CheckSkillGT(Player1,29,Alchemy)
	CheckSkillGT(Player2,29,Alchemy)
	CheckSkillGT(Player3,29,Alchemy)
	CheckSkillGT(Player4,29,Alchemy)
	CheckSkillGT(Player5,29,Alchemy)
	CheckSkillGT(Player6,29,Alchemy)~ THEN BEGIN 1
  SAY @4793
  IF ~~ THEN REPLY @4794 DO ~StartStore("USALCP12",LastTalkedToBy)~ EXIT
  IF ~~ THEN REPLY @4795 EXIT
END

IF ~Or(6)
	CheckSkillGT(Player1,27,Alchemy)
	CheckSkillGT(Player2,27,Alchemy)
	CheckSkillGT(Player3,27,Alchemy)
	CheckSkillGT(Player4,27,Alchemy)
	CheckSkillGT(Player5,27,Alchemy)
	CheckSkillGT(Player6,27,Alchemy)~ THEN BEGIN 1
  SAY @4793
  IF ~~ THEN REPLY @4794 DO ~StartStore("USALCP11",LastTalkedToBy)~ EXIT
  IF ~~ THEN REPLY @4795 EXIT
END

IF ~Or(6)
	CheckSkillGT(Player1,25,Alchemy)
	CheckSkillGT(Player2,25,Alchemy)
	CheckSkillGT(Player3,25,Alchemy)
	CheckSkillGT(Player4,25,Alchemy)
	CheckSkillGT(Player5,25,Alchemy)
	CheckSkillGT(Player6,25,Alchemy)~ THEN BEGIN 1
  SAY @4793
  IF ~~ THEN REPLY @4794 DO ~StartStore("USALCP10",LastTalkedToBy)~ EXIT
  IF ~~ THEN REPLY @4795 EXIT
END

IF ~Or(6)
	CheckSkillGT(Player1,23,Alchemy)
	CheckSkillGT(Player2,23,Alchemy)
	CheckSkillGT(Player3,23,Alchemy)
	CheckSkillGT(Player4,23,Alchemy)
	CheckSkillGT(Player5,23,Alchemy)
	CheckSkillGT(Player6,23,Alchemy)~ THEN BEGIN 1
  SAY @4793
  IF ~~ THEN REPLY @4794 DO ~StartStore("USALCP09",LastTalkedToBy)~ EXIT
  IF ~~ THEN REPLY @4795 EXIT
END

IF ~Or(6)
	CheckSkillGT(Player1,21,Alchemy)
	CheckSkillGT(Player2,21,Alchemy)
	CheckSkillGT(Player3,21,Alchemy)
	CheckSkillGT(Player4,21,Alchemy)
	CheckSkillGT(Player5,21,Alchemy)
	CheckSkillGT(Player6,21,Alchemy)~ THEN BEGIN 1
  SAY @4793
  IF ~~ THEN REPLY @4794 DO ~StartStore("USALCP08",LastTalkedToBy)~ EXIT
  IF ~~ THEN REPLY @4795 EXIT
END

IF ~Or(6)
	CheckSkillGT(Player1,19,Alchemy)
	CheckSkillGT(Player2,19,Alchemy)
	CheckSkillGT(Player3,19,Alchemy)
	CheckSkillGT(Player4,19,Alchemy)
	CheckSkillGT(Player5,19,Alchemy)
	CheckSkillGT(Player6,19,Alchemy)~ THEN BEGIN 1
  SAY @4793
  IF ~~ THEN REPLY @4794 DO ~StartStore("USALCP07",LastTalkedToBy)~ EXIT
  IF ~~ THEN REPLY @4795 EXIT
END

IF ~Or(6)
	CheckSkillGT(Player1,17,Alchemy)
	CheckSkillGT(Player2,17,Alchemy)
	CheckSkillGT(Player3,17,Alchemy)
	CheckSkillGT(Player4,17,Alchemy)
	CheckSkillGT(Player5,17,Alchemy)
	CheckSkillGT(Player6,17,Alchemy)~ THEN BEGIN 1
  SAY @4793
  IF ~~ THEN REPLY @4794 DO ~StartStore("USALCP06",LastTalkedToBy)~ EXIT
  IF ~~ THEN REPLY @4795 EXIT
END

IF ~Or(6)
	CheckSkillGT(Player1,15,Alchemy)
	CheckSkillGT(Player2,15,Alchemy)
	CheckSkillGT(Player3,15,Alchemy)
	CheckSkillGT(Player4,15,Alchemy)
	CheckSkillGT(Player5,15,Alchemy)
	CheckSkillGT(Player6,15,Alchemy)~ THEN BEGIN 1
  SAY @4793
  IF ~~ THEN REPLY @4794 DO ~StartStore("USALCP05",LastTalkedToBy)~ EXIT
  IF ~~ THEN REPLY @4795 EXIT
END

IF ~Or(6)
	CheckSkillGT(Player1,13,Alchemy)
	CheckSkillGT(Player2,13,Alchemy)
	CheckSkillGT(Player3,13,Alchemy)
	CheckSkillGT(Player4,13,Alchemy)
	CheckSkillGT(Player5,13,Alchemy)
	CheckSkillGT(Player6,13,Alchemy)~ THEN BEGIN 1
  SAY @4793
  IF ~~ THEN REPLY @4794 DO ~StartStore("USALCP04",LastTalkedToBy)~ EXIT
  IF ~~ THEN REPLY @4795 EXIT
END

IF ~Or(6)
	CheckSkillGT(Player1,11,Alchemy)
	CheckSkillGT(Player2,11,Alchemy)
	CheckSkillGT(Player3,11,Alchemy)
	CheckSkillGT(Player4,11,Alchemy)
	CheckSkillGT(Player5,11,Alchemy)
	CheckSkillGT(Player6,11,Alchemy)~ THEN BEGIN 1
  SAY @4793
  IF ~~ THEN REPLY @4794 DO ~StartStore("USALCP03",LastTalkedToBy)~ EXIT
  IF ~~ THEN REPLY @4795 EXIT
END

IF ~Or(6)
	CheckSkillGT(Player1,9,Alchemy)
	CheckSkillGT(Player2,9,Alchemy)
	CheckSkillGT(Player3,9,Alchemy)
	CheckSkillGT(Player4,9,Alchemy)
	CheckSkillGT(Player5,9,Alchemy)
	CheckSkillGT(Player6,9,Alchemy)~ THEN BEGIN 1
  SAY @4793
  IF ~~ THEN REPLY @4794 DO ~StartStore("USALCP02",LastTalkedToBy)~ EXIT
  IF ~~ THEN REPLY @4795 EXIT
END

IF ~True()~ THEN BEGIN 1
  SAY @4793
  IF ~~ THEN REPLY @4794 DO ~StartStore("USALCP01",LastTalkedToBy)~ EXIT
  IF ~~ THEN REPLY @4795 EXIT
END
