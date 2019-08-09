BEGIN ~41ZACK~

IF ~~ THEN BEGIN 0
  SAY #32232
  IF ~  CurrentAreaIs(Myself,4100)
Global("41PlayerSawTempleSideDoor","GLOBAL",1)
OpenState("AR4100_Door14",FALSE)
~ THEN REPLY #32240 GOTO 19
  IF ~  PartyHasItem("40BooKOS")
!PartyHasItem("40GenBe")
!Global("41ZackTask","GLOBAL",11)
!Global("41ZackTask","GLOBAL",12)
GlobalLT("40MendingSpell","GLOBAL",2)
Global("41NoZackBellRepeat","GLOBAL",0)
~ THEN REPLY #32242 DO ~SetGlobal("41ZackTask","GLOBAL", 0)GiveItemCreate("40GenBe",Protagonist,0,0,0)SetGlobal("41NoZackBellRepeat", "GLOBAL", 1)~ GOTO 21
  IF ~~ THEN REPLY #32466 GOTO 7
  IF ~~ THEN REPLY #32469 GOTO 8
  IF ~  Or(2)
Global("41TempleQuest","GLOBAL",1)
Global("41TempleQuest","GLOBAL",2)
~ THEN REPLY #32471 GOTO 11
  IF ~  Global("41TempleQuest","GLOBAL",3)
~ THEN REPLY #32471 GOTO 41
  IF ~  Global("41TempleQuest","GLOBAL",0)
~ THEN REPLY #32545 DO ~SetGlobal("41TempleQuest","GLOBAL",1)~ GOTO 11
  IF ~~ THEN REPLY #32546 GOTO 29
END

IF ~~ THEN BEGIN 1
  SAY #32547
  IF ~~ THEN GOTO 0
END

IF ~~ THEN BEGIN 2
  SAY #32549
  IF ~~ THEN GOTO 0
END

IF ~~ THEN BEGIN 3
  SAY #32550
  IF ~~ THEN GOTO 0
END

IF ~  NumberOfTimesTalkedTo(0)
~ THEN BEGIN 4
  SAY #32551
  IF ~  Or(2)
Race(Protagonist,GNOME)
Race(Protagonist,HALFLING)
Or(3)
Sequence(Myself,SLEEP)
Sequence(Myself,DIE)
Sequence(Myself,TWITCH)
~ THEN REPLY #32552 DO ~AddXpVar("Level_8_Hard",32202)
SetGlobal("41RescueQuest", "GLOBAL", 1)
PlayDead(0)~ JOURNAL #18898 GOTO 5
  IF ~  Or(2)
Race(Protagonist,GNOME)
Race(Protagonist,HALFLING)
!Sequence(Myself,SLEEP)
!Sequence(Myself,DIE)
!Sequence(Myself,TWITCH)
~ THEN REPLY #32552 DO ~AddXpVar("Level_8_Hard",32202)
SetGlobal("41RescueQuest", "GLOBAL", 1)~ JOURNAL #18898 GOTO 5
  IF ~  !Race(Protagonist,GNOME)
!Race(Protagonist,HALFLING)
Or(3)
Sequence(Myself,SLEEP)
Sequence(Myself,DIE)
Sequence(Myself,TWITCH)
~ THEN REPLY #32553 DO ~AddXpVar("Level_8_Hard",32202)
SetGlobal("41RescueQuest", "GLOBAL", 1)
PlayDead(0)~ JOURNAL #18898 GOTO 5
  IF ~  !Race(Protagonist,GNOME)
!Race(Protagonist,HALFLING)
!Sequence(Myself,SLEEP)
!Sequence(Myself,DIE)
!Sequence(Myself,TWITCH)
~ THEN REPLY #32553 DO ~AddXpVar("Level_8_Hard",32202)
SetGlobal("41RescueQuest", "GLOBAL", 1)~ JOURNAL #18898 GOTO 5
END

IF ~~ THEN BEGIN 5
  SAY ~Zack's the name... Zack Boosenburry... illusionist and faithful of Baervan Wildwanderer.  Have you-excuse me for a moment.  Aocha?  *Aocha?*  AOCHA?!~
  IF ~  PartyHasItem("41GenZB")
~ THEN REPLY #32555 DO ~TakePartyItem("41GenZB")~ GOTO 6
  IF ~~ THEN REPLY #32556 GOTO 8
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32720 DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  !Global("41RescueQuest","GLOBAL",1)
RandomNum(4,1)
~ THEN REPLY #32720 GOTO 0
  IF ~  !Global("41RescueQuest","GLOBAL",1)
RandomNum(4,2)
~ THEN REPLY #32720 GOTO 1
  IF ~  !Global("41RescueQuest","GLOBAL",1)
RandomNum(4,3)
~ THEN REPLY #32720 GOTO 2
  IF ~  !Global("41RescueQuest","GLOBAL",1)
RandomNum(4,4)
~ THEN REPLY #32720 GOTO 3
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY ~You're an illusionist?  Does that mean you have spells to sell?~ DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  !Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY ~You're an illusionist?  Does that mean you have spells to sell?~ GOTO 30
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32722 DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  !Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32722 GOTO 29
END

IF ~~ THEN BEGIN 6
  SAY #32723
  IF ~~ THEN REPLY #32724 GOTO 8
  IF ~  Or(2)
Global("41TempleQuest","GLOBAL",1)
Global("41TempleQuest","GLOBAL",2)
~ THEN REPLY #32471 GOTO 11
  IF ~  Global("41TempleQuest","GLOBAL",0)
~ THEN REPLY #32545 DO ~SetGlobal("41TempleQuest","GLOBAL",1)~ GOTO 11
  IF ~  Global("41TempleQuest","GLOBAL",3)
~ THEN REPLY #32471 GOTO 41
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32725 DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  !Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32725 GOTO 29
END

IF ~~ THEN BEGIN 7
  SAY #32726
  IF ~~ THEN REPLY #32730 GOTO 36
  IF ~  Or(2)
Global("41TempleQuest","GLOBAL",1)
Global("41TempleQuest","GLOBAL",2)
~ THEN REPLY #32731 GOTO 11
  IF ~  Global("41TempleQuest","GLOBAL",0)
~ THEN REPLY #32731 DO ~SetGlobal("41TempleQuest","GLOBAL",1)~ GOTO 11
  IF ~  Global("41TempleQuest","GLOBAL",3)
~ THEN REPLY #32731 GOTO 41
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32732 DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  !Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32732 GOTO 29
END

IF ~~ THEN BEGIN 8
  SAY #32733
  IF ~  GlobalLT("41AochaQuest","GLOBAL",3)
Global("41PlayerSawAocha","GLOBAL",1)
~ THEN REPLY #32734 DO ~SetGlobal("41AochaQuest","GLOBAL",2)~ GOTO 31
  IF ~  GlobalLT("41AochaQuest","GLOBAL",2)
~ THEN REPLY #32735 DO ~SetGlobal("41AochaQuest","GLOBAL",2)~ JOURNAL #32188 GOTO 29
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32720 DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  !Global("41RescueQuest","GLOBAL",1)
RandomNum(4,1)
~ THEN REPLY #32720 GOTO 0
  IF ~  !Global("41RescueQuest","GLOBAL",1)
RandomNum(4,2)
~ THEN REPLY #32720 GOTO 1
  IF ~  !Global("41RescueQuest","GLOBAL",1)
RandomNum(4,3)
~ THEN REPLY #32720 GOTO 2
  IF ~  !Global("41RescueQuest","GLOBAL",1)
RandomNum(4,4)
~ THEN REPLY #32720 GOTO 3
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32732 DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  !Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32732 GOTO 29
END

IF ~~ THEN BEGIN 9
  SAY #32736
  IF ~  GlobalLT("41AochaQuest","GLOBAL",3)
Global("41PlayerSawAocha","GLOBAL",1)
~ THEN REPLY #32737 DO ~SetGlobal("41AochaQuest","GLOBAL",2)~ GOTO 31
  IF ~  GlobalLT("41AochaQuest","GLOBAL",2)
~ THEN REPLY #32735 DO ~SetGlobal("41AochaQuest","GLOBAL",2)~ JOURNAL #32188 GOTO 29
  IF ~~ THEN REPLY #32797 GOTO 8
  IF ~  CheckSkillLT(Protagonist,5,Diplomacy)
~ THEN REPLY #32798 DO ~SetGlobal("41RescueQuest","GLOBAL",3)~ GOTO 10
  IF ~  !CheckSkillLT(Protagonist,5,Diplomacy)
~ THEN REPLY #32798 DO ~SetGlobal("41RescueQuest","GLOBAL",2)~ GOTO 10
  IF ~  CheckSkillLT(Protagonist,5,Diplomacy)
~ THEN REPLY #32799 DO ~SetGlobal("41RescueQuest","GLOBAL",4)~ GOTO 10
  IF ~  !CheckSkillLT(Protagonist,5,Diplomacy)
!CheckSkillGT(Protagonist,10,Diplomacy)
~ THEN REPLY #32799 DO ~SetGlobal("41RescueQuest","GLOBAL",3)~ GOTO 10
  IF ~  CheckSkillGT(Protagonist,10,Diplomacy)
~ THEN REPLY #32799 DO ~SetGlobal("41RescueQuest","GLOBAL",2)~ GOTO 10
  IF ~  CheckSkillLT(Protagonist,5,Diplomacy)
~ THEN REPLY #32800 DO ~Enemy()~ EXIT
  IF ~  !CheckSkillLT(Protagonist,5,Diplomacy)
!CheckSkillGT(Protagonist,10,Diplomacy)
~ THEN REPLY #32800 DO ~SetGlobal("41RescueQuest","GLOBAL",4)~ GOTO 10
  IF ~  CheckSkillGT(Protagonist,10,Diplomacy)
~ THEN REPLY #32800 DO ~SetGlobal("41RescueQuest","GLOBAL",3)~ GOTO 10
  IF ~~ THEN REPLY #32801 GOTO 29
END

IF ~~ THEN BEGIN 10
  SAY #32802
  IF ~  RandomNum(4,1)
~ THEN REPLY #32720 GOTO 0
  IF ~  RandomNum(4,2)
~ THEN REPLY #32720 GOTO 1
  IF ~  RandomNum(4,3)
~ THEN REPLY #32720 GOTO 2
  IF ~  RandomNum(4,4)
~ THEN REPLY #32720 GOTO 3
  IF ~~ THEN REPLY #32803 GOTO 30
  IF ~~ THEN REPLY #32804 GOTO 29
END

IF ~~ THEN BEGIN 11
  SAY #32805
  IF ~  Global("41TempleQuest","GLOBAL",2)
GlobalGT("41ZackTempleInfo","GLOBAL",0)
~ THEN REPLY #32806 GOTO 32
  IF ~  GlobalLT("41TempleQuest","GLOBAL",2)
GlobalGT("41ZackTempleInfo","GLOBAL",0)
~ THEN REPLY #32807 DO ~SetGlobal("41TempleQuest","GLOBAL",2)~ GOTO 32
  IF ~  GlobalLT("41TempleQuest","GLOBAL",2)
Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32808 DO ~SetGlobal("41TempleQuest","GLOBAL",2)
SetGlobal("41AochaQuest","GLOBAL",1)~ JOURNAL #32200 GOTO 9
  IF ~  GlobalLT("41TempleQuest","GLOBAL",2)
!Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32808 DO ~SetGlobal("41TempleQuest","GLOBAL",2)~ JOURNAL #32200 GOTO 29
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #425 DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  !Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #425 GOTO 29
END

IF ~~ THEN BEGIN 12
  SAY ~Response: Aocha - come here girl!  *PHHIRRR!*  Oh, I almost forgot - fumbling around inside that worm I hit upon a few items.  If there's anything I can do for you, let me know.~
  IF ~~ THEN REPLY ~We're happy for you.  Farewell.~ DO ~GiveItemCreate("00Brac09",Protagonist,0,0,0)
GiveItemCreate("00Gem27",Protagonist,0,0,0)
GiveItemCreate("00Ring75",Protagonist,0,0,0)
SetGlobal("41ZackAreaNum", "GLOBAL", 4100)
SetGlobal("41ZackTask","GLOBAL", 14)~ EXIT
  IF ~!NumInParty(6)~ THEN REPLY ~Actually, we could use your help.  Would you consider joining us?~ DO ~GiveItemCreate("00Brac09",Protagonist,0,0,0)
GiveItemCreate("00Gem27",Protagonist,0,0,0)
GiveItemCreate("00Ring75",Protagonist,0,0,0)
SetGlobal("41ZackAreaNum", "GLOBAL", 4100)
SetGlobal("41ZackTask","GLOBAL", 14)~ GOTO ZackJoin1
END

IF ~~ THEN BEGIN 13
  SAY ~Aocha... AOCHA...!  A good mount she was...  Perhaps her death was inevitable, <CHARNAME> - being who... *what* she was.  If I was nearby, I could have rescued her, but...~
  IF ~  RandomNum(4,1)
~ THEN REPLY #32720 GOTO 0
  IF ~  RandomNum(4,2)
~ THEN REPLY #32720 GOTO 1
  IF ~  RandomNum(4,3)
~ THEN REPLY #32720 GOTO 2
  IF ~  RandomNum(4,4)
~ THEN REPLY #32720 GOTO 3
  IF ~~ THEN REPLY #32813 GOTO 30
  IF ~~ THEN REPLY #32814 GOTO 29
END

IF ~~ THEN BEGIN 14
  SAY #32815
  IF ~~ THEN REPLY #32816 DO ~SetGlobal("41ZackTask","GLOBAL", 1)
SetGlobal("41ZackAreaNum", "GLOBAL", 4001)
SetGlobal("LeaveArea", "LOCALS", 1)~ EXIT
  IF ~~ THEN REPLY #32817 GOTO 29
END

IF ~~ THEN BEGIN 15
  SAY #32818
  IF ~~ THEN REPLY #32819 DO ~SetGlobal("41ZackTask","GLOBAL", 15)
SetGlobal("41ZackAreaNum", "GLOBAL", 4100)
SetGlobal("40OswaldAwake","GLOBAL",1)
SetGlobal("LeaveArea", "LOCALS", 1)~ GOTO 29
END

IF ~~ THEN BEGIN 16
  SAY #32820
  IF ~  Global("41PlayerSawTopAltar","GLOBAL",1)
!Global("41FakeAltarDestroyed","GLOBAL",1)
!CurrentAreaIs(Myself,4101)
~ THEN REPLY #32821 DO ~SetGlobal("41ZackTask","GLOBAL", 3)
SetGlobal("41ZackAreaNum", "GLOBAL", 4101)
SetGlobal("LeaveArea", "LOCALS", 1)~ EXIT
  IF ~  Global("41PlayerSawTopAltar","GLOBAL",1)
!Global("41FakeAltarDestroyed","GLOBAL",1)
CurrentAreaIs(Myself,4101)
~ THEN REPLY #32821 DO ~SetGlobal("41ZackTask","GLOBAL", 3)~ EXIT
  IF ~  Global("41PlayerSawBottomAltar","GLOBAL",1)
!Global("CagedFury_dead","GLOBAL",1)
!CurrentAreaIs(Myself,4102)
~ THEN REPLY #32822 DO ~SetGlobal("41ZackTask","GLOBAL", 6)
SetGlobal("41ZackAreaNum", "GLOBAL", 4102)
SetGlobal("LeaveArea", "LOCALS", 1)~ EXIT
  IF ~  Global("41PlayerSawBottomAltar","GLOBAL",1)
!Global("CagedFury_dead","GLOBAL",1)
CurrentAreaIs(Myself,4102)
~ THEN REPLY #32822 DO ~SetGlobal("41ZackTask","GLOBAL", 6)~ EXIT
  IF ~  !CurrentAreaIs(Myself,4100)
~ THEN REPLY #32823 DO ~SetGlobal("41ZackTask","GLOBAL", 15)
SetGlobal("41ZackAreaNum", "GLOBAL", 4100)
SetGlobal("LeaveArea", "LOCALS", 1)~ EXIT
  IF ~  CurrentAreaIs(Myself,4100)
~ THEN REPLY #32823 DO ~SetGlobal("41ZackTask","GLOBAL", 0)~ GOTO 29
END

IF ~~ THEN BEGIN 17
  SAY #32824
  IF ~  Global("41ZackTask","GLOBAL",4)
~ THEN REPLY #32819 DO ~SetGlobal("41ZackTask","GLOBAL", 0)~ GOTO 35
  IF ~  Global("41ZackTask","GLOBAL",7)
~ THEN REPLY #32819 DO ~SetGlobal("41ZackTask","GLOBAL", 0)~ GOTO 29
END

IF ~~ THEN BEGIN 18
  SAY #32825
  IF ~  CurrentAreaIs(Myself,4101)
~ THEN REPLY #32826 DO ~SetGlobal("41ZackTask","GLOBAL", 3)~ GOTO 29
  IF ~  CurrentAreaIs(Myself,4102)
~ THEN REPLY #32826 DO ~SetGlobal("41ZackTask","GLOBAL", 6)~ GOTO 29
  IF ~  !CurrentAreaIs(Myself,4100)
~ THEN REPLY #32827 DO ~SetGlobal("41ZackTask","GLOBAL", 15)
SetGlobal("41ZackAreaNum", "GLOBAL", 4100)
SetGlobal("LeaveArea", "LOCALS", 1)~ EXIT
  IF ~  CurrentAreaIs(Myself,4100)
~ THEN REPLY #32827 DO ~SetGlobal("41ZackTask","GLOBAL", 0)~ GOTO 29
END

IF ~~ THEN BEGIN 19
  SAY #32828
  IF ~~ THEN REPLY #32829 DO ~SetGlobal("41ZackTask","GLOBAL", 9)~ GOTO 29
  IF ~~ THEN REPLY #32823 DO ~SetGlobal("41ZackTask","GLOBAL", 0)~ GOTO 29
END

IF ~~ THEN BEGIN 20
  SAY #32830
  IF ~  CurrentAreaIs(Myself,4000)
~ THEN REPLY #32917 DO ~SetGlobal("41ZackTask","GLOBAL", 11)
SetGlobalTimer("41BelladonnaTimer","GLOBAL",300)~ GOTO 33
  IF ~  !CurrentAreaIs(Myself,4000)
~ THEN REPLY #32917 DO ~SetGlobal("41ZackTask","GLOBAL", 11)
SetGlobal("41ZackAreaNum", "GLOBAL", 4000)
SetGlobalTimer("41BelladonnaTimer","GLOBAL",300)~ GOTO 34
  IF ~  CurrentAreaIs(Myself,4100)
~ THEN REPLY #32918 DO ~SetGlobal("41ZackTask","GLOBAL", 11)
SetGlobalTimer("41BelladonnaTimer","GLOBAL",2400)~ GOTO 33
  IF ~  !CurrentAreaIs(Myself,4100)
~ THEN REPLY #32918 DO ~SetGlobal("41ZackTask","GLOBAL", 11)
SetGlobal("41ZackAreaNum", "GLOBAL", 4100)
SetGlobalTimer("41BelladonnaTimer","GLOBAL",2400)~ GOTO 34
  IF ~  CurrentAreaIs(Myself,4101)
~ THEN REPLY #32919 DO ~SetGlobal("41ZackTask","GLOBAL", 11)
SetGlobalTimer("41BelladonnaTimer","GLOBAL",7200)~ GOTO 33
  IF ~  !CurrentAreaIs(Myself,4101)
~ THEN REPLY #32919 DO ~SetGlobal("41ZackTask","GLOBAL", 11)
SetGlobal("41ZackAreaNum", "GLOBAL", 4101)
SetGlobalTimer("41BelladonnaTimer","GLOBAL",7200)~ GOTO 34
  IF ~  CurrentAreaIs(Myself,4102)
~ THEN REPLY #32920 DO ~SetGlobal("41ZackTask","GLOBAL", 11)
SetGlobalTimer("41BelladonnaTimer","GLOBAL",7200)~ GOTO 33
  IF ~  !CurrentAreaIs(Myself,4102)
~ THEN REPLY #32920 DO ~SetGlobal("41ZackTask","GLOBAL", 11)
SetGlobal("41ZackAreaNum", "GLOBAL", 4102)
SetGlobalTimer("41BelladonnaTimer","GLOBAL",7200)~ GOTO 34
  IF ~~ THEN REPLY #32823 DO ~SetGlobal("41ZackTask","GLOBAL", 0)~ GOTO 29
END

IF ~~ THEN BEGIN 21
  SAY #32921
  IF ~~ THEN REPLY #32819 GOTO 29
END

IF ~~ THEN BEGIN 22
  SAY #32922
  IF ~~ THEN REPLY #21776 EXIT
  IF ~  !CurrentAreaIs(Myself,4000)
~ THEN REPLY #32924 DO ~SetGlobal("41ZackTask","GLOBAL", 11)
SetGlobal("41ZackAreaNum", "GLOBAL", 4000)
SetGlobalTimer("41BelladonnaTimer","GLOBAL",300)
SetGlobal("LeaveArea", "LOCALS", 1)~ EXIT
  IF ~  !CurrentAreaIs(Myself,4100)
~ THEN REPLY #32925 DO ~SetGlobal("41ZackTask","GLOBAL", 11)
SetGlobal("41ZackAreaNum", "GLOBAL", 4100)
SetGlobalTimer("41BelladonnaTimer","GLOBAL",2400)
SetGlobal("LeaveArea", "LOCALS", 1)~ EXIT
  IF ~  !CurrentAreaIs(Myself,4101)
~ THEN REPLY #32926 DO ~SetGlobal("41ZackTask","GLOBAL", 11)
SetGlobal("41ZackAreaNum", "GLOBAL", 4101)
SetGlobalTimer("41BelladonnaTimer","GLOBAL",7200)
SetGlobal("LeaveArea", "LOCALS", 1)~ EXIT
  IF ~  !CurrentAreaIs(Myself,4102)
~ THEN REPLY #32927 DO ~SetGlobal("41ZackTask","GLOBAL", 11)
SetGlobal("41ZackAreaNum", "GLOBAL", 4102)
SetGlobalTimer("41BelladonnaTimer","GLOBAL",7200)
SetGlobal("LeaveArea", "LOCALS", 1)~ EXIT
  IF ~~ THEN REPLY #32827 DO ~SetGlobal("41ZackTask","GLOBAL", 0)~ GOTO 29
END

IF ~~ THEN BEGIN 23
  SAY #32928
  IF ~~ THEN REPLY #32811 EXIT
END

IF ~  Global("41AochaQuest","GLOBAL",2)
~ THEN BEGIN 24
  SAY #32929
  IF ~  GlobalLT("41AochaQuest","GLOBAL",3)
Global("41PlayerSawAocha","GLOBAL",1)
~ THEN REPLY #32930 DO ~SetGlobal("41AochaQuest","GLOBAL",2)~ GOTO 31
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32720 DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  !Global("41RescueQuest","GLOBAL",1)
RandomNum(4,1)
~ THEN REPLY #32720 GOTO 0
  IF ~  !Global("41RescueQuest","GLOBAL",1)
RandomNum(4,2)
~ THEN REPLY #32720 GOTO 1
  IF ~  !Global("41RescueQuest","GLOBAL",1)
RandomNum(4,3)
~ THEN REPLY #32720 GOTO 2
  IF ~  !Global("41RescueQuest","GLOBAL",1)
RandomNum(4,4)
~ THEN REPLY #32720 GOTO 3
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32931 DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  !Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32931 GOTO 30
  IF ~~ THEN REPLY #33288 JOURNAL #32188 GOTO 29
END

IF ~  Global("41TempleQuest","GLOBAL",2)
~ THEN BEGIN 25
  SAY #33289
  IF ~  GlobalGT("41ZackTempleInfo","GLOBAL",0)
~ THEN REPLY #32930 GOTO 32
  IF ~  RandomNum(4,1)
~ THEN REPLY #33290 GOTO 0
  IF ~  RandomNum(4,2)
~ THEN REPLY #33290 GOTO 1
  IF ~  RandomNum(4,3)
~ THEN REPLY #33290 GOTO 2
  IF ~  RandomNum(4,4)
~ THEN REPLY #33290 GOTO 3
  IF ~~ THEN REPLY #32931 GOTO 30
  IF ~~ THEN REPLY #33297 GOTO 29
END

IF ~  NumTimesTalkedToGT(0)
~ THEN BEGIN 26
  SAY #33298
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32720 DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  RandomNum(4,1)
!Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32720 GOTO 0
  IF ~  RandomNum(4,2)
!Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32720 GOTO 1
  IF ~  RandomNum(4,3)
!Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32720 GOTO 2
  IF ~  RandomNum(4,4)
!Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32720 GOTO 3
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32803 DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  Global("41RescueQuest","GLOBAL",2)
~ THEN REPLY #40330 DO ~StartStore("41Zack3", Protagonist)~ EXIT
  IF ~  Global("41RescueQuest","GLOBAL",3)
~ THEN REPLY #40331 DO ~StartStore("41Zack2", Protagonist)~ EXIT
  IF ~  Global("41RescueQuest","GLOBAL",4)
~ THEN REPLY #40332 DO ~StartStore("41Zack1", Protagonist)~ EXIT
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32722 DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  !Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32722 GOTO 29
END

IF ~~ THEN BEGIN 27
  SAY #33299
  IF ~~ THEN REPLY #33300 DO ~SetGlobal("41ZackTask","GLOBAL", 13)~ EXIT
  IF ~~ THEN REPLY #33307 DO ~SetGlobal("41ZackTask","GLOBAL", 0)
ClearAllActions()~ EXIT
END

IF ~~ THEN BEGIN 28
  SAY #33308
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 29
  SAY #33309
  IF ~  Global("41AochaQuest","GLOBAL",2)
!Global("41TempleQuest","GLOBAL",2)
~ THEN REPLY #33485 GOTO 27
  IF ~  !Global("41AochaQuest","GLOBAL",2)
Global("41TempleQuest","GLOBAL",2)
~ THEN REPLY #33485 GOTO 28
  IF ~  Global("41AochaQuest","GLOBAL",2)
Global("41TempleQuest","GLOBAL",2)
~ THEN REPLY #33485 GOTO 27
  IF ~  !Global("41AochaQuest","GLOBAL",2)
!Global("41TempleQuest","GLOBAL",2)
~ THEN REPLY #33485 EXIT
END

IF ~~ THEN BEGIN 30
  SAY #33486
  IF ~  Global("41RescueQuest","GLOBAL",2)
~ THEN REPLY #33487 DO ~StartStore("41Zack3", Protagonist)~ EXIT
  IF ~  Global("41RescueQuest","GLOBAL",3)
~ THEN REPLY #33487 DO ~StartStore("41Zack2", Protagonist)~ EXIT
  IF ~  Global("41RescueQuest","GLOBAL",4)
~ THEN REPLY #33487 DO ~StartStore("41Zack1", Protagonist)~ EXIT
  IF ~  RandomNum(4,1)
~ THEN REPLY #33488 GOTO 0
  IF ~  RandomNum(4,2)
~ THEN REPLY #33488 GOTO 1
  IF ~  RandomNum(4,3)
~ THEN REPLY #33488 GOTO 2
  IF ~  RandomNum(4,4)
~ THEN REPLY #33488 GOTO 3
  IF ~~ THEN REPLY #33489 GOTO 29
END

IF ~~ THEN BEGIN 31
  SAY #33490
  IF ~  GlobalLT("41RescueQuest","GLOBAL",4)
!Global("Aocha_dead","GLOBAL",1)
Global("41PlayerSawAocha","GLOBAL",1)
~ THEN REPLY #33491 DO ~AddXpVar("Level_8_Very_Hard",32226)
SetGlobal("41AochaQuest","GLOBAL",3)
SetGlobal("41RescueQuest","GLOBAL",2)~ JOURNAL #32189 GOTO 12
  IF ~  Global("41RescueQuest","GLOBAL",4)
!Global("Aocha_dead","GLOBAL",1)
Global("41PlayerSawAocha","GLOBAL",1)
~ THEN REPLY #33491 DO ~AddXpVar("Level_8_Very_Hard",32226)
SetGlobal("41AochaQuest","GLOBAL",3)
SetGlobal("41RescueQuest","GLOBAL",3)~ JOURNAL #32189 GOTO 12
  IF ~  Global("41RescueQuest","GLOBAL",2)
Global("Aocha_dead","GLOBAL",1)
Global("41PlayerSawAocha","GLOBAL",1)
~ THEN REPLY #33492 DO ~AddXpVar("Level_8_Hard",32226)
SetGlobal("41AochaQuest","GLOBAL",3)
SetGlobal("41RescueQuest","GLOBAL",3)~ JOURNAL #32189 GOTO 13
  IF ~  GlobalGT("41RescueQuest","GLOBAL",2)
Global("Aocha_dead","GLOBAL",1)
Global("41PlayerSawAocha","GLOBAL",1)
~ THEN REPLY #33492 DO ~AddXpVar("Level_8_Hard",32226)
SetGlobal("41AochaQuest","GLOBAL",3)
SetGlobal("41RescueQuest","GLOBAL",4)~ JOURNAL #32189 GOTO 13
  IF ~  Global("41PlayerKilledAocha","GLOBAL",1)
Global("Aocha_dead","GLOBAL",1)
~ THEN REPLY #33493 DO ~AddXpVar("Level_8_Hard",32226)
SetGlobal("41AochaQuest","GLOBAL",3)
SetGlobal("41RescueQuest","GLOBAL",4)~ JOURNAL #32189 GOTO 13
  IF ~  Global("41PlayerKilledAocha","GLOBAL",1)
Global("Aocha_dead","GLOBAL",1)
Alignment(Protagonist,MASK_EVIL)
~ THEN REPLY #33494 DO ~AddXpVar("Level_8_Hard",32226)
SetGlobal("41AochaQuest","GLOBAL",3)
Enemy()~ JOURNAL #32189 EXIT
  IF ~~ THEN REPLY #33495 GOTO 29
END

IF ~~ THEN BEGIN 32
  SAY #33496
  IF ~  GlobalLT("41RescueQuest","GLOBAL",4)
Global("41ZackTempleInfo","GLOBAL",1)
~ THEN REPLY #33497 DO ~AddXpVar("Level_8_Easy",32227)
SetGlobal("41RescueQuest","GLOBAL",2)
SetGlobal("41TempleQuest","GLOBAL",3)~ JOURNAL #32201 GOTO 23
  IF ~  Global("41RescueQuest","GLOBAL",4)
Global("41ZackTempleInfo","GLOBAL",1)
~ THEN REPLY #33497 DO ~AddXpVar("Level_8_Easy",32227)
SetGlobal("41RescueQuest","GLOBAL",3)
SetGlobal("41TempleQuest","GLOBAL",3)~ JOURNAL #32201 GOTO 23
  IF ~  Global("41ZackTempleInfo","GLOBAL",2)
~ THEN REPLY #33498 DO ~AddXpVar("Level_8_Average",32228)
SetGlobal("41RescueQuest","GLOBAL",2)
SetGlobal("41TempleQuest","GLOBAL",3)~ JOURNAL #32201 GOTO 23
  IF ~  Global("41ZackTempleInfo","GLOBAL",3)
~ THEN REPLY #33499 DO ~AddXpVar("Level_8_Hard",32229)
SetGlobal("41RescueQuest","GLOBAL",2)
SetGlobal("41TempleQuest","GLOBAL",3)~ JOURNAL #32201 GOTO 23
  IF ~  Global("41ZackTempleInfo","GLOBAL",4)
~ THEN REPLY #33577 DO ~AddXpVar("Level_8_Very_Hard",32231)
SetGlobal("41RescueQuest","GLOBAL",2)
SetGlobal("41TempleQuest","GLOBAL",3)~ JOURNAL #32201 GOTO 23
  IF ~  RandomNum(4,1)
~ THEN REPLY #33578 GOTO 0
  IF ~  RandomNum(4,2)
~ THEN REPLY #33578 GOTO 1
  IF ~  RandomNum(4,3)
~ THEN REPLY #33578 GOTO 2
  IF ~  RandomNum(4,4)
~ THEN REPLY #33578 GOTO 3
  IF ~~ THEN REPLY #33579 GOTO 30
  IF ~~ THEN REPLY #33580 GOTO 29
END

IF ~~ THEN BEGIN 33
  SAY #33581
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN 34
  SAY #33582
  IF ~~ THEN DO ~SetGlobal("LeaveArea", "LOCALS", 1)~ EXIT
END

IF ~~ THEN BEGIN 35
  SAY #33583
  IF ~~ THEN GOTO 29
END

IF ~~ THEN BEGIN 36
  SAY #33584
  IF ~  Or(2)
Global("41TempleQuest","GLOBAL",1)
Global("41TempleQuest","GLOBAL",2)
~ THEN REPLY #33586 GOTO 11
  IF ~  Global("41TempleQuest","GLOBAL",0)
~ THEN REPLY #33586 DO ~SetGlobal("41TempleQuest","GLOBAL",1)~ GOTO 11
  IF ~  Global("41TempleQuest","GLOBAL",3)
~ THEN REPLY #33586 GOTO 41
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32732 DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  !Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #32732 GOTO 29
END

IF ~~ THEN BEGIN 37
  SAY #33587
  IF ~~ THEN REPLY #32930 DO ~SetGlobal("41WormTraining","GLOBAL",2)~ GOTO 38
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #33588 DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  RandomNum(4,1)
!Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #33588 GOTO 0
  IF ~  RandomNum(4,2)
!Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #33588 GOTO 1
  IF ~  RandomNum(4,3)
!Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #33588 GOTO 2
  IF ~  RandomNum(4,4)
!Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #33588 GOTO 3
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #33589 DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  !Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #33589 GOTO 30
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #33590 DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  !Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #33590 GOTO 29
END

IF ~~ THEN BEGIN 38
  SAY #33591
  IF ~~ THEN GOTO 39
END

IF ~~ THEN BEGIN 39
  SAY #33592
  IF ~~ THEN GOTO 40
END

IF ~~ THEN BEGIN 40
  SAY #33593
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #33588 DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  RandomNum(4,1)
!Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #33588 GOTO 0
  IF ~  RandomNum(4,2)
!Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #33588 GOTO 1
  IF ~  RandomNum(4,3)
!Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #33588 GOTO 2
  IF ~  RandomNum(4,4)
!Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #33588 GOTO 3
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #33594 DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  !Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #33594 GOTO 30
  IF ~  Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #33595 DO ~SetGlobal("41AochaQuest","GLOBAL",1)~ GOTO 9
  IF ~  !Global("41RescueQuest","GLOBAL",1)
~ THEN REPLY #33595 GOTO 29
END

IF ~~ THEN BEGIN 41
  SAY #33990
  IF ~  RandomNum(4,1)
~ THEN REPLY #33588 GOTO 0
  IF ~  RandomNum(4,2)
~ THEN REPLY #33588 GOTO 1
  IF ~  RandomNum(4,3)
~ THEN REPLY #33588 GOTO 2
  IF ~  RandomNum(4,4)
~ THEN REPLY #33588 GOTO 3
  IF ~~ THEN REPLY #33594 GOTO 30
  IF ~~ THEN REPLY #425 GOTO 29
END

IF ~~ THEN BEGIN ZackJoin1
  SAY ~I can consider all sorts of things.  What do you need help with?~
  IF ~!Global("41WesternPassDone","GLOBAL",1)~ THEN REPLY ~We intend to destroy that glacier blocking the pass.  Lord Ulbrec sent us to meet with the Neverwinter soldiers, and this ice wall is blocking the way.~ GOTO ZackJoinIceWallUp1
  IF ~Global("41WesternPassDone","GLOBAL",1)~ THEN REPLY ~We need to send word to Targos about the Aurilites' activities here.  Without the airship we used to travel here, we'll need to make our way to Kuldahar through the Eastern Pass.  We could use your help getting there.~ GOTO ZackJoinIceWallDown
END

IF ~~ THEN BEGIN ZackJoinIceWallUp1
  SAY ~I came here to study the glacier - the enchantments on the ice are fascinating.  I'd hate to see it fall before I had a chance to research it!~
  IF ~~ THEN REPLY ~You'll have plenty of time to study the wall.  In fact, I don't know if we even *could* bring down the wall before we researched it.  Why not come along with us to study it?  You'll need protection from all these Aurilites.~ GOTO ZackJoinIceWallUp2
END

IF ~~ THEN BEGIN ZackJoinIceWallUp2
  SAY ~Good point.  I certainly don't want to get devoured by another one of those worms, either.  I'll help you bring down the wall, as long as I have some time to take notes.  Just let me get Aocha first.~
  IF ~~ THEN REPLY ~Aocha's coming with us?~ GOTO ZackJoinAocha1
END

IF ~~ THEN BEGIN ZackJoinAocha1
  SAY ~Of course!  She's quite friendly, though she can be quite a bruiser when we're in trouble.  I usually keep her in my pocket - she's safer there.~
  IF ~~ THEN REPLY ~You keep a giant spider in your pocket?~ GOTO ZackJoinAocha2
END

IF ~~ THEN BEGIN ZackJoinAocha2
  SAY ~It's one of my little inventions. I designed a magical pocket for her to hide in!  It comes in handy when I need to go into town - you wouldn't believe how many people are scared of her! I also have a special formula in there, just in case she gets hurt.  Let me shrink her down and put her in my pocket, and I'll be ready to go...~
  IF ~~ THEN DO ~FadeToColor([0.0],0)
HideCreature("41Aocha",TRUE)
Wait(3)
FadeFromColor([0.0],0)~ GOTO ZackJoinAocha3
END

IF ~~ THEN BEGIN ZackJoinAocha3
  SAY ~Done!  Aocha is comfortable, and I'm all set.  Shall we?~
  IF ~~ THEN REPLY ~Let's go.~ DO ~SetGlobal("US_Zack_Joined", "GLOBAL", 1)
ApplySpellRES("USZACKC",Myself)~ EXIT
END

IF ~~ THEN BEGIN ZackJoinIceWallDown
  SAY ~Sounds like a fair trade for saving my life and Aocha, and with the ice wall broken, there's not much left for me here, anyway.  Very well, I can tag along for a while.  Just let me get Aocha first.~
  IF ~~ THEN REPLY ~Aocha's coming with us?~ GOTO ZackJoinAocha1
END