// created  : Mon Feb 04 20:24:37 2002
// from     : override/solafoe.dlg
// using    : C:\Program Files\Black Isle\BGII - SoA\dialog.tlk
// solafoe  : 10 states, 14 trans, 1 state-trigs, 3 trans-trigs, 1 actions

BEGIN solafoe

IF ~Global("SolaFoeFight","GLOBAL",0)~ THEN BEGIN 0 // from:
  SAY @1 // #83051 ~Ah, it is the petty surfacers who watch over Solaufein. I am Archryssa, a favorite of Lolth.~ |92| {7}
  IF ~~ THEN GOTO 1
END

IF ~~ THEN BEGIN 1 // from: 0.0
  SAY @2 // #83052 ~I have come for Solaufein and Lolth shall feast upon his bones. Surrender him to me and I may let you live.~ |107| {7}
  IF ~~ THEN REPLY @3 // #83053 ~I think not, drow! Together we have defeated enemies much stronger than you. ~ |77| {7}
    GOTO 2
  IF ~~ THEN REPLY @4 // #83054 ~Solaufein and I stand as one, Archryssa. If you want him you will have to get through me!~ |89| {7}
    GOTO 7
  IF ~~ THEN REPLY @5 // #83055 ~You will not find Solaufein easy prey. Even alone he is more than a match for you!~ |82| {7}
    GOTO 8
END

IF ~~ THEN BEGIN 2 // from: 1.0
  SAY @6 // #83056 ~Ah, but you will not fight me together, surfacer. ~ |50| {7}
  IF ~~ THEN GOTO 3
END

IF ~~ THEN BEGIN 3 // from: 2.0 7.0 8.0
  SAY @7 // #83057 ~Lolth has granted me the power to separate you from your companions, Solaufein. Her vengeance shall be highly personal. They will watch on from the Void while you face me ... and all your worst nightmares ... alone!~ |215| {7}
  IF ~IsValidForPartyDialog("VICONIA")~ THEN GOTO 4
  IF ~!IsValidForPartyDialog("VICONIA")~ THEN GOTO 5
END

IF ~~ THEN BEGIN 4 // from: 3.0
  SAY @8 // #83058 ~Oh, and Viconia ... we haven't forgotten about you either. Your turn will come. ~ |80| {7}
  IF ~~ THEN GOTO 5
END

IF ~~ THEN BEGIN 5 // from: 3.1 4.0
  SAY @9 // #83059 ~And now for the fun part ... your death!~ |40| {7}
  IF ~~ THEN EXTERN SOLA damnyou
END

IF ~~ THEN BEGIN thinknot // from: 3.2
  SAY @10 // #83060 ~I think not, male. Through me, Lolth will suck your soul dry! And when you have fallen she shall feast on your companions.~ |122| {7}
  IF ~~ THEN GOTO drider
END

IF ~~ THEN BEGIN 7 // from: 1.1
  SAY @11 // #83061 ~You may stand as one, but for this battle you shall be riven apart. ~ |68| {7}
  IF ~~ THEN GOTO 3
END

IF ~~ THEN BEGIN 8 // from: 1.2
  SAY @12 // #83062 ~We shall see. With the Spider Queen's favor my power is vast.~ |61| {7}
  IF ~~ THEN GOTO 3
END

IF ~~ THEN BEGIN drider
  SAY @14 
  IF ~~ THEN GOTO 9
END

IF ~~ THEN BEGIN 9 // from: 6.0
  SAY @13 // #83063 ~And if you flee ... she will feast on them now! Face me, Solaufein! Face your doom!~ |83| {7}
  IF ~~ THEN DO ~IncrementGlobal("SolaFoeFight","GLOBAL",1)~ EXIT
END

APPEND SOLA
  IF ~False()~ THEN BEGIN damnyou // from:
    SAY @175 // #82997 ~No! Damn you!~ |13| {7}
    IF ~~ THEN EXTERN solafoe thinknot
  END
END

