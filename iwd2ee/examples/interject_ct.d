/* Behaves like INTERJECT, but after the final interjection the transitions
 * from the original location are copied (a la COPY_TRANS). */
INTERJECT_COPY_TRANS BODHI 11 somevar
  == "IMOEN2" IF ~InParty("Imoen2")~ THEN ~Hello, Bodhi. Let's go kill those thieves from Waterdeep or whatnot.~
  == "BODHI" IF ~InParty("Imoen2")~ THEN ~Shut up, Immy. Here are the things you could have said before her interjection:~
END 
