BEGIN USSTSH01

IF ~NumTimesTalkedTo(0)~ THEN BEGIN FirstMeeting
SAY ~Hm. You want something? This is Isair and Madae's throne room. Do you have business here? If you're not sure where to go, speak with Xavier Torsend in his office downstairs.~
+ ~CheckSkillGT(Protagonist,25,Bluff)~ + ~Yes, I'm Auren Corlath. I'm an envoy from the Speaker's Palace in Bryn Shander. We spoke with Xavier Torsend earlier; he directed us here. It's our understanding that our previous arrangement was canceled--we would like to reschedule.~ DO ~SetGlobal("USSTRL_1","GLOBAL",1)~ + TotalBluff25
+ ~CheckSkillGT(Protagonist,15,Bluff)
CheckSkillLT(Protagonist,25,Bluff)~ + ~Yes, I'm Auren Corlath. I'm an envoy from the Speaker's Palace in Bryn Shander. We spoke with Xavier Torsend earlier; he directed us here.~ DO ~SetGlobal("USSTRL_1","GLOBAL",1)~ + TotalBluff15
+ ~CheckSkillLT(Protagonist,15,Bluff)~ + ~I am a diplomat from Lonelywood. I would like to arrange a meeting with Isair and Madae.~ DO ~SetGlobal("USSTRL_1","GLOBAL",1)~ + FailedBluff
+ ~~ + ~Nevermind.~ DO ~SetGlobal("USSTRL_1","GLOBAL",0)~  + Leave
END

IF ~~ THEN BEGIN TotalBluff15
SAY ~Bryn Shander? Let me understand this--after Bryn Shander attempted to murder Isair and Madae as part of a diplomatic "gesture," now it's sending envoys on a mysteriously unscheduled diplomatic mission? Have you come to surrender your isolated city? Are you bringing some new "gifts" for Isair and Madae? Are you here to offer some pathetic apology? Or are you just some dimwitted fool who tried to talk his way into a meeting without realizing Bryn Shander's reputation among the Legion of the Chimera? Or better still, some incredibly incompetent assassin?~
+ ~Global("USSTRL_1","GLOBAL",1)~ + ~I am well aware of Bryn Shander's reputation, and I understand the Legion's perspective on the incident. That is why I am here. As it happens, we do have an apology prepared, but there is much more to discuss that the "gesture" alone... That being said, we have brought the would-be murderer himself with us, to entrust him to the Legion's custody. Bryn Shander feels that a trust-building exercise of sorts would help ease relations with the Legion.~ + SuccessfulBluff
+ ~!Global("USSTRL_1","GLOBAL",1)~ + ~I am well aware of Bryn Shander's reputation, and I understand the Legion's perspective on the incident. That is why I am here. As it happens, we do have an apology prepared, but there is much more to discuss that the "gesture" alone... That being said, we have brought the would-be murderer himself with us, to entrust him to the Legion's custody. Bryn Shander feels that a trust-building exercise of sorts would help ease relations with the Legion.~ + FailedBluff
END

IF ~~ THEN BEGIN TotalBluff25
SAY ~Bryn Shander? Let me understand this--after Bryn Shander attempted to murder Isair and Madae as part of a diplomatic "gesture," now it's sending envoys on a mysteriously unscheduled diplomatic mission? Have you come to surrender your isolated city? Are you bringing some new "gifts" for Isair and Madae? Are you here to offer some pathetic apology? Or are you just some dimwitted fool who tried to talk his way into a meeting without realizing Bryn Shander's reputation among the Legion of the Chimera? Or better still, some incredibly incompetent assassin?~
+ ~~ + ~I am well aware of Bryn Shander's reputation, and I understand the Legion's perspective on the incident. That is why I am here. As it happens, we do have an apology prepared, but there is much more to discuss that the "gesture" alone... That being said, we have brought the would-be murderer himself with us, to entrust him to the Legion's custody. Bryn Shander feels that a trust-building exercise of sorts would help ease relations with the Legion.~ + SuccessfulBluff
END

IF ~~ THEN BEGIN SuccessfulBluff
SAY ~You... you brought the cook with you? You're surrendering him as a peace offering? Hah! This is the last thing I would have expected from Bryn Shander. Very well, Auren Corlath... I'll show you to Isair and Madae. I'm sure they will be *very* interested in meeting you.~
IF ~~ THEN REPLY ~My thanks.~ DO ~StartCutSceneMode()
StartCutScene("USSTSH02")~ EXIT
END

IF ~~ THEN BEGIN FailedBluff
SAY ~Hm. No, I don't think so. Go speak with Xavier Torsend if you have legitimate business here. Get moving... whoever you are.~
IF ~~ EXIT
END

IF ~~ THEN BEGIN Leave
SAY ~Hm. Farewell, then.~
IF ~~ EXIT
END

IF ~NumTimesTalkedTo(1)~ THEN BEGIN SecondMeeting
SAY ~It's you again. Do you need something?~
+ ~CheckSkillGT(Protagonist,25,Bluff)
Global("USSTRL_2","GLOBAL",0)~ + ~Yes, I'm Auren Corlath. I'm an envoy from the Speaker's Palace in Bryn Shander. We spoke with Xavier Torsend earlier; he directed us here. It's our understanding that our previous arrangement was canceled--we would like to reschedule.~ + TotalBluff25
+ ~CheckSkillGT(Protagonist,15,Bluff)
CheckSkillLT(Protagonist,25,Bluff)
Global("USSTRL_2","GLOBAL",0)~ + ~Yes, I'm Auren Corlath. I'm an envoy from the Speaker's Palace in Bryn Shander. We spoke with Xavier Torsend earlier; he directed us here.~ + TotalBluff15
+ ~CheckSkillLT(Protagonist,15,Bluff)
Global("USSTRL_2","GLOBAL",0)~ + ~I am a diplomat from Lonelywood. I would like to arrange a meeting with Isair and Madae.~ + FailedBluff
+ ~CheckSkillGT(Protagonist,30,Bluff)
Global("USSTRL_2","GLOBAL",0)~ + ~I am well aware of Bryn Shander's reputation, and I understand the Legion's perspective on the incident. That is why I am here. As it happens, we do have an apology prepared, but there is much more to discuss that the "gesture" alone... That being said, we have brought the would-be murderer himself with us, to entrust him to the Legion's custody. Bryn Shander feels that a trust-building exercise of sorts would help ease relations with the Legion.~ + 2ndTotalBluff30
+ ~CheckSkillGT(Protagonist,20,Bluff)
CheckSkillLT(Protagonist,30,Bluff)
Global("USSTRL_2","GLOBAL",0)~ + ~I am well aware of Bryn Shander's reputation, and I understand the Legion's perspective on the incident. That is why I am here. As it happens, we do have an apology prepared, but there is much more to discuss that the "gesture" alone... That being said, we have brought the would-be murderer himself with us, to entrust him to the Legion's custody. Bryn Shander feels that a trust-building exercise of sorts would help ease relations with the Legion.~ + 2ndTotalBluff20
+ ~CheckSkillLT(Protagonist,20,Bluff)
Global("USSTRL_2","GLOBAL",0)~ + ~I am a diplomat from Lonelywood. I would like to arrange a meeting with Isair and Madae.~ + 2ndFailedBluff
+ ~~ + ~Nevermind.~ + Leave
END

IF ~~ THEN BEGIN 2ndTotalBluff20
SAY ~Bryn Shander? Let me understand this--after Bryn Shander attempted to murder Isair and Madae as part of a diplomatic "gesture," now it's sending envoys on a mysteriously unscheduled diplomatic mission? Have you come to surrender your isolated city? Are you bringing some new "gifts" for Isair and Madae? Are you here to offer some pathetic apology? Or are you just some dimwitted fool who tried to talk his way into a meeting without realizing Bryn Shander's reputation among the Legion of the Chimera? Or better still, some incredibly incompetent assassin?~
+ ~Global("USSTRL_1","GLOBAL",1)~ + ~I am well aware of Bryn Shander's reputation, and I understand the Legion's perspective on the incident. That is why I am here. As it happens, we do have an apology prepared, but there is much more to discuss that the "gesture" alone... That being said, we have brought the would-be murderer himself with us, to entrust him to the Legion's custody. Bryn Shander feels that a trust-building exercise of sorts would help ease relations with the Legion.~ + 2ndSuccessfulBluff
+ ~!Global("USSTRL_1","GLOBAL",1)~ + ~I am well aware of Bryn Shander's reputation, and I understand the Legion's perspective on the incident. That is why I am here. As it happens, we do have an apology prepared, but there is much more to discuss that the "gesture" alone... That being said, we have brought the would-be murderer himself with us, to entrust him to the Legion's custody. Bryn Shander feels that a trust-building exercise of sorts would help ease relations with the Legion.~ + 2ndFailedBluff
END

IF ~~ THEN BEGIN 2ndTotalBluff30
SAY ~Bryn Shander? Let me understand this--after Bryn Shander attempted to murder Isair and Madae as part of a diplomatic "gesture," now it's sending envoys on a mysteriously unscheduled diplomatic mission? Have you come to surrender your isolated city? Are you bringing some new "gifts" for Isair and Madae? Are you here to offer some pathetic apology? Or are you just some dimwitted fool who tried to talk his way into a meeting without realizing Bryn Shander's reputation among the Legion of the Chimera? Or better still, some incredibly incompetent assassin?~
+ ~~ + ~I am well aware of Bryn Shander's reputation, and I understand the Legion's perspective on the incident. That is why I am here. As it happens, we do have an apology prepared, but there is much more to discuss that the "gesture" alone... That being said, we have brought the would-be murderer himself with us, to entrust him to the Legion's custody. Bryn Shander feels that a trust-building exercise of sorts would help ease relations with the Legion.~ + SuccessfulBluff
END

IF ~~ THEN BEGIN 2ndSuccessfulBluff
SAY ~You... you brought the cook with you? You're surrendering him as a peace offering? Hah! This is the last thing I would have expected from Bryn Shander. Very well, Auren Corlath... I'll show you to Isair and Madae. I'm sure they will be *very* interested in meeting you.~
IF ~~ THEN REPLY ~My thanks.~ DO ~StartCutSceneMode()
StartCutScene("USSTSH02")~ EXIT
END

IF ~~ THEN BEGIN 2ndFailedBluff
SAY ~Hm. No, I don't think so. Go speak with Xavier Torsend if you have legitimate business here. Get moving... whoever you are.~
IF ~~ EXIT
END

IF ~NumTimesTalkedToGT(1)~ THEN BEGIN ThirdMeeting
SAY ~I don't know who you are, but if you have no business here, then leave.~
+ ~~ + ~Nevermind.~ + Leave
END
