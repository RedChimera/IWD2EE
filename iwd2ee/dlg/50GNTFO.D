BEGIN ~50GNTFO~

IF ~~ THEN BEGIN 0
  SAY ~I knows who dey is!  Dey's da ones wot smashed up da ice castle!  An dey killed me brudda so's I went ta look for 'em an' got lost and saw da smoke an' foun' da' village an' dat's when I saw you an' then-~
  IF ~~ THEN EXTERN ~50THVARA~ 1
END

IF ~~ THEN BEGIN 1
  SAY ~I knows who dey is!  Dey's da ones wot smashed up da ice castle!  Dey, dey-~
  IF ~~ THEN EXTERN ~50THVARA~ 1
END

IF ~~ THEN BEGIN 2
  SAY #6570 //fighting them now?
  IF ~~ THEN EXTERN ~50THVARA~ 4
END

IF ~~ THEN BEGIN 3
  SAY #37850 //flees
  IF ~~ THEN DO ~AddExperiencePartyCR(7)
EscapeArea()~ EXIT
END

IF ~~ THEN BEGIN 4
  SAY ~Dey's lyin', da, da... lyin' liars!  Dey did it, I saws 'em wif me own peepers!~
  IF ~~ THEN EXTERN ~50THVARA~ 2CannotLie
END

IF ~~ THEN BEGIN 5
  SAY ~Dey's lyin', da, da... lyin' liars!  Dey did it, I saws 'em wif me own peepers!~
  IF ~~ THEN EXTERN ~50THVARA~ 5
END

