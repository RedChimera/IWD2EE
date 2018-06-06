BEGIN USALCP01

IF ~CheckSkillLT(Protagonist,10,Alchemy)~ THEN BEGIN 0
  SAY ~Concoct Potions~
  IF ~~ THEN REPLY ~Begin.~ DO ~StartStore("USALCP01",NearestPC)~ EXIT
  IF ~~ THEN REPLY ~Exit.~ EXIT
END

IF ~CheckSkillGT(Protagonist,10,Alchemy)
CheckSkillLT(Protagonist,12,Alchemy)~ THEN BEGIN 1
  SAY ~Concoct Potions~
  IF ~~ THEN REPLY ~Begin.~ DO ~StartStore("USALCP02",NearestPC)~ EXIT
  IF ~~ THEN REPLY ~Exit.~ EXIT
END

IF ~CheckSkillGT(Protagonist,12,Alchemy)
CheckSkillLT(Protagonist,14,Alchemy)~ THEN BEGIN 1
  SAY ~Concoct Potions~
  IF ~~ THEN REPLY ~Begin.~ DO ~StartStore("USALCP03",NearestPC)~ EXIT
  IF ~~ THEN REPLY ~Exit.~ EXIT
END

IF ~CheckSkillGT(Protagonist,14,Alchemy)
CheckSkillLT(Protagonist,16,Alchemy)~ THEN BEGIN 1
  SAY ~Concoct Potions~
  IF ~~ THEN REPLY ~Begin.~ DO ~StartStore("USALCP04",NearestPC)~ EXIT
  IF ~~ THEN REPLY ~Exit.~ EXIT
END

IF ~CheckSkillGT(Protagonist,16,Alchemy)
CheckSkillLT(Protagonist,18,Alchemy)~ THEN BEGIN 1
  SAY ~Concoct Potions~
  IF ~~ THEN REPLY ~Begin.~ DO ~StartStore("USALCP05",NearestPC)~ EXIT
  IF ~~ THEN REPLY ~Exit.~ EXIT
END

IF ~CheckSkillGT(Protagonist,18,Alchemy)
CheckSkillLT(Protagonist,20,Alchemy)~ THEN BEGIN 1
  SAY ~Concoct Potions~
  IF ~~ THEN REPLY ~Begin.~ DO ~StartStore("USALCP06",NearestPC)~ EXIT
  IF ~~ THEN REPLY ~Exit.~ EXIT
END

IF ~CheckSkillGT(Protagonist,20,Alchemy)
CheckSkillLT(Protagonist,22,Alchemy)~ THEN BEGIN 1
  SAY ~Concoct Potions~
  IF ~~ THEN REPLY ~Begin.~ DO ~StartStore("USALCP07",NearestPC)~ EXIT
  IF ~~ THEN REPLY ~Exit.~ EXIT
END

IF ~CheckSkillGT(Protagonist,22,Alchemy)
CheckSkillLT(Protagonist,24,Alchemy)~ THEN BEGIN 1
  SAY ~Concoct Potions~
  IF ~~ THEN REPLY ~Begin.~ DO ~StartStore("USALCP08",NearestPC)~ EXIT
  IF ~~ THEN REPLY ~Exit.~ EXIT
END

IF ~CheckSkillGT(Protagonist,24,Alchemy)
CheckSkillLT(Protagonist,26,Alchemy)~ THEN BEGIN 1
  SAY ~Concoct Potions~
  IF ~~ THEN REPLY ~Begin.~ DO ~StartStore("USALCP09",NearestPC)~ EXIT
  IF ~~ THEN REPLY ~Exit.~ EXIT
END

IF ~CheckSkillGT(Protagonist,26,Alchemy)
CheckSkillLT(Protagonist,28,Alchemy)~ THEN BEGIN 1
  SAY ~Concoct Potions~
  IF ~~ THEN REPLY ~Begin.~ DO ~StartStore("USALCP10",NearestPC)~ EXIT
  IF ~~ THEN REPLY ~Exit.~ EXIT
END

IF ~CheckSkillGT(Protagonist,28,Alchemy)
CheckSkillLT(Protagonist,30,Alchemy)~ THEN BEGIN 1
  SAY ~Concoct Potions~
  IF ~~ THEN REPLY ~Begin.~ DO ~StartStore("USALCP11",NearestPC)~ EXIT
  IF ~~ THEN REPLY ~Exit.~ EXIT
END

IF ~CheckSkillGT(Protagonist,30,Alchemy)
CheckSkillLT(Protagonist,32,Alchemy)~ THEN BEGIN 1
  SAY ~Concoct Potions~
  IF ~~ THEN REPLY ~Begin.~ DO ~StartStore("USALCP12",NearestPC)~ EXIT
  IF ~~ THEN REPLY ~Exit.~ EXIT
END

IF ~CheckSkillGT(Protagonist,32,Alchemy)~ THEN BEGIN 1
  SAY ~Concoct Potions~
  IF ~~ THEN REPLY ~Begin.~ DO ~StartStore("USALCP13",NearestPC)~ EXIT
  IF ~~ THEN REPLY ~Exit.~ EXIT
END
