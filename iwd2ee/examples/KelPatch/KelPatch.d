BEGIN ~KelPatch~

APPEND ~J#KLSYJ~  // Appends an entry to NPC's "J" dialog file (inter-party banter)
  IF ~True()~ THEN BEGIN add1
    SAY ~Insert Something To Say here.~  // This is what your NPC will say when you try to talk to him/her
    IF ~~ THEN DO ~StartCutScene("kfix")~ EXIT // This gives no response choice, only End Dialog, which on its own
                                               // triggers an execution of the fix-it script which we patched above,
                                               // restoring name, bio and sounds of our damaged NPC.
  END
END              
