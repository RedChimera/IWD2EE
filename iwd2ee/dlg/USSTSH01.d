BEGIN USSTSH01

IF ~NumTimesTalkedTo(0)~ THEN BEGIN FirstMeeting
SAY @6218
IF ~CheckSkillGT(Protagonist,44,Bluff)~ THEN REPLY @6219 GOTO TotalBluff25
IF ~CheckSkillGT(Protagonist,14,Bluff)
CheckSkillLT(Protagonist,45,Bluff)~ THEN REPLY @6220 GOTO TotalBluff15
IF ~CheckSkillLT(Protagonist,15,Bluff)~ THEN REPLY @6221 GOTO FailedBluff
IF ~~ THEN REPLY @6230 DO ~SetNumTimesTalkedTo(0)~ GOTO Leave
END

IF ~~ THEN BEGIN TotalBluff15
SAY @6222
IF ~~ THEN REPLY @6223 GOTO FailedBluff
END

IF ~~ THEN BEGIN TotalBluff25
SAY @6222
IF ~~ THEN REPLY @6224 GOTO SuccessfulBluff
END

IF ~~ THEN BEGIN SuccessfulBluff
SAY @6225
IF ~~ THEN REPLY @6226 DO ~StartCutSceneMode()
StartCutScene("USSTSH02")~ EXIT
END

IF ~~ THEN BEGIN FailedBluff
SAY @6227
IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN Leave
SAY @6228
IF ~~ THEN EXIT
END

IF ~NumTimesTalkedToGT(0)~ THEN BEGIN SecondMeeting
SAY @6229
IF ~~ THEN REPLY @6230 EXIT
END
