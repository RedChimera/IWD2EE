// CHAIN example: Adapted from Blue's Tutorial

BEGIN ~BBLUE~ // We are in a banter file, specifically, the banter file for the NPC Blue.

CHAIN IF ~InParty("Jan")  // Is the NPC Blue wants to talk to in the party?
See("Jan")  // Can she SEE the NPC?
!StateCheck("Jan",STATE_SLEEPING)  // Is the NPC conscious?
Global("JanBlueTalk","LOCALS",0)~ THEN 
BBLUE BlueJanBanterChain
  ~Agh! What am I doing in a computer game? I should never have eaten that leftover pizza.~  // Blue should say this.
DO ~SetGlobal("JanBlueTalk","LOCALS",1)~ // Okay, make sure this talk won't happen again, and let's see the NPC's reply.
== BJAN
~Have a turnip! It'll make you feel better. The same thing happened to my third-cousin-twice-removed-once-by-marriage Philroy waaaaay back just two weeks ago -~  // We already know who's replying here, so no need to specify.
== BBLUE  // Okay, now we want Blue to say something, so we go back to her banter file.
~And to make things worse, I'm stuck in a banter with HIM! Give me a sentence that's less than four words long, please?~  // And that's what she says.
== BJAN  // Alright, back to Jan.
~What are you talking about?~  // That's what he says.
== BBLUE 
~Argh! That's FIVE words, FIVE!~  // Blue gives her ending line.
EXIT
