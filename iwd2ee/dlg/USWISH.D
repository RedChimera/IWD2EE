BEGIN ~USWISH~

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,1)
Global("US_Wishes_P1","GLOBAL",0)~ THEN BEGIN WishP1A
  SAY @30159
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
  IF ~~ THEN REPLY @30164 DO ~IncrementGlobal("US_Wishes_P1","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,1)
Global("US_Wishes_P1","GLOBAL",1)~ THEN BEGIN WishP1B
  SAY @30160
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
  IF ~~ THEN REPLY @30164 DO ~IncrementGlobal("US_Wishes_P1","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,1)
Global("US_Wishes_P1","GLOBAL",2)~ THEN BEGIN WishP1C
  SAY @30161
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
  IF ~~ THEN REPLY @30164 DO ~IncrementGlobal("US_Wishes_P1","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,1)
GlobalGT("US_Wishes_P1","GLOBAL",2)~ THEN BEGIN WishP1D
  SAY @30162
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,2)
Global("US_Wishes_P2","GLOBAL",0)~ THEN BEGIN WishP2A
  SAY @30159
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
  IF ~~ THEN REPLY @30164 DO ~IncrementGlobal("US_Wishes_P2","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,2)
Global("US_Wishes_P2","GLOBAL",1)~ THEN BEGIN WishP2B
  SAY @30160
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
  IF ~~ THEN REPLY @30164 DO ~IncrementGlobal("US_Wishes_P2","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,2)
Global("US_Wishes_P2","GLOBAL",2)~ THEN BEGIN WishP2C
  SAY @30161
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
  IF ~~ THEN REPLY @30164 DO ~IncrementGlobal("US_Wishes_P2","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,2)
GlobalGT("US_Wishes_P2","GLOBAL",2)~ THEN BEGIN WishP2D
  SAY @30162
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,3)
Global("US_Wishes_P3","GLOBAL",0)~ THEN BEGIN WishP3A
  SAY @30159
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
  IF ~~ THEN REPLY @30164 DO ~IncrementGlobal("US_Wishes_P3","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,3)
Global("US_Wishes_P3","GLOBAL",1)~ THEN BEGIN WishP3B
  SAY @30160
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
  IF ~~ THEN REPLY @30164 DO ~IncrementGlobal("US_Wishes_P3","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,3)
Global("US_Wishes_P3","GLOBAL",2)~ THEN BEGIN WishP3C
  SAY @30161
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
  IF ~~ THEN REPLY @30164 DO ~IncrementGlobal("US_Wishes_P3","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,3)
GlobalGT("US_Wishes_P3","GLOBAL",2)~ THEN BEGIN WishP3D
  SAY @30162
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,4)
Global("US_Wishes_P4","GLOBAL",0)~ THEN BEGIN WishP4A
  SAY @30159
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
  IF ~~ THEN REPLY @30164 DO ~IncrementGlobal("US_Wishes_P4","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,4)
Global("US_Wishes_P4","GLOBAL",1)~ THEN BEGIN WishP4B
  SAY @30160
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
  IF ~~ THEN REPLY @30164 DO ~IncrementGlobal("US_Wishes_P4","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,4)
Global("US_Wishes_P4","GLOBAL",2)~ THEN BEGIN WishP4C
  SAY @30161
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
  IF ~~ THEN REPLY @30164 DO ~IncrementGlobal("US_Wishes_P4","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,4)
GlobalGT("US_Wishes_P4","GLOBAL",2)~ THEN BEGIN WishP4D
  SAY @30162
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,5)
Global("US_Wishes_P5","GLOBAL",0)~ THEN BEGIN WishP5A
  SAY @30159
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
  IF ~~ THEN REPLY @30164 DO ~IncrementGlobal("US_Wishes_P5","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,5)
Global("US_Wishes_P5","GLOBAL",1)~ THEN BEGIN WishP5B
  SAY @30160
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
  IF ~~ THEN REPLY @30164 DO ~IncrementGlobal("US_Wishes_P5","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,5)
Global("US_Wishes_P5","GLOBAL",2)~ THEN BEGIN WishP5C
  SAY @30161
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
  IF ~~ THEN REPLY @30164 DO ~IncrementGlobal("US_Wishes_P5","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,5)
GlobalGT("US_Wishes_P5","GLOBAL",2)~ THEN BEGIN WishP5D
  SAY @30162
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,6)
Global("US_Wishes_P6","GLOBAL",0)~ THEN BEGIN WishP6A
  SAY @30159
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
  IF ~~ THEN REPLY @30164 DO ~IncrementGlobal("US_Wishes_P6","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,6)
Global("US_Wishes_P6","GLOBAL",1)~ THEN BEGIN WishP6B
  SAY @30160
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
  IF ~~ THEN REPLY @30164 DO ~IncrementGlobal("US_Wishes_P6","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,6)
Global("US_Wishes_P6","GLOBAL",2)~ THEN BEGIN WishP6C
  SAY @30161
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
  IF ~~ THEN REPLY @30164 DO ~IncrementGlobal("US_Wishes_P6","GLOBAL",1)~ GOTO WishOneTime
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
IsPlayerNumber(Protagonist,6)
GlobalGT("US_Wishes_P6","GLOBAL",2)~ THEN BEGIN WishP6D
  SAY @30162
  IF ~~ THEN REPLY @30163 GOTO WishCastSpell
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
!IsPlayerNumber(Protagonist,1)
!IsPlayerNumber(Protagonist,2)
!IsPlayerNumber(Protagonist,3)
!IsPlayerNumber(Protagonist,4)
!IsPlayerNumber(Protagonist,5)
!IsPlayerNumber(Protagonist,6)~ THEN BEGIN WishMinion
  SAY @30165
  IF ~~ THEN EXIT
END

IF WEIGHT #2 ~NumTimesTalkedTo(0)
Global("US_Wish_Minion","LOCALS",1)~ THEN BEGIN WishMinion2
  SAY @30165
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN WishCastSpell
  SAY @30189
  IF ~~ THEN REPLY @30190 GOTO WishCastSpell1
  IF ~~ THEN REPLY @30191 GOTO WishCastSpell2
  IF ~~ THEN REPLY @30192 GOTO WishCastSpell3
  IF ~~ THEN REPLY @30193 GOTO WishCastSpell4
  IF ~~ THEN REPLY @30194 GOTO WishCastSpell5
  IF ~~ THEN REPLY @30195 GOTO WishCastSpell6
  IF ~~ THEN REPLY @30196 GOTO WishCastSpell7
  IF ~~ THEN REPLY @30197 GOTO WishCastSpell8
END

IF ~~ THEN BEGIN WishCastSpell1
  SAY @30189
  IF ~~ THEN REPLY @30198 DO ~IEex_Lua("IEex_HaveSummonerCast(6155)")~ EXIT
  IF ~~ THEN REPLY @30199 DO ~IEex_Lua("IEex_HaveSummonerCast(2101)")~ EXIT
  IF ~~ THEN REPLY @30200 DO ~IEex_Lua("IEex_HaveSummonerCast(6251)")~ EXIT
  IF ~~ THEN REPLY @30201 DO ~IEex_Lua("IEex_HaveSummonerCast(6156)")~ EXIT
  IF ~~ THEN REPLY @30202 DO ~IEex_Lua("IEex_HaveSummonerCast(2102)")~ EXIT
  IF ~~ THEN REPLY @30203 DO ~IEex_Lua("IEex_HaveSummonerCast(6356)")~ EXIT
  IF ~~ THEN REPLY @30204 DO ~IEex_Lua("IEex_HaveSummonerCast(1107)")~ EXIT
  IF ~~ THEN REPLY @30205 DO ~IEex_Lua("IEex_HaveSummonerCast(2108)")~ EXIT
  IF ~~ THEN REPLY @30206 DO ~IEex_Lua("IEex_HaveSummonerCast(6152)")~ EXIT
  IF ~~ THEN REPLY @30207 DO ~IEex_Lua("IEex_HaveSummonerCast(2120)")~ EXIT
  IF ~~ THEN REPLY @30208 DO ~IEex_Lua("IEex_HaveSummonerCast(2114)")~ EXIT
  IF ~~ THEN REPLY @30209 DO ~IEex_Lua("IEex_HaveSummonerCast(2116)")~ EXIT
  IF ~~ THEN REPLY @30210 DO ~IEex_Lua("IEex_HaveSummonerCast(2124)")~ EXIT
  IF ~~ THEN REPLY @30211 DO ~IEex_Lua("IEex_HaveSummonerCast(6151)")~ EXIT
END

IF ~~ THEN BEGIN WishCastSpell2
  SAY @30189
  IF ~~ THEN REPLY @30212 DO ~IEex_Lua("IEex_HaveSummonerCast(6254)")~ EXIT
  IF ~~ THEN REPLY @30213 DO ~IEex_Lua("IEex_HaveSummonerCast(2201)")~ EXIT
  IF ~~ THEN REPLY @30214 DO ~IEex_Lua("IEex_HaveSummonerCast(2223)")~ EXIT
  IF ~~ THEN REPLY @30215 DO ~IEex_Lua("IEex_HaveSummonerCast(6256)")~ EXIT
  IF ~~ THEN REPLY @30216 DO ~IEex_Lua("IEex_HaveSummonerCast(2228)")~ EXIT
  IF ~~ THEN REPLY @30217 DO ~IEex_Lua("IEex_HaveSummonerCast(2221)")~ EXIT
  IF ~~ THEN REPLY @30218 DO ~IEex_Lua("IEex_HaveSummonerCast(1309)")~ EXIT
  IF ~~ THEN REPLY @30219 DO ~IEex_Lua("IEex_HaveSummonerCast(2107)")~ EXIT
  IF ~~ THEN REPLY @30220 DO ~IEex_Lua("IEex_HaveSummonerCast(2227)")~ EXIT
  IF ~~ THEN REPLY @30221 DO ~IEex_Lua("IEex_HaveSummonerCast(2205)")~ EXIT
  IF ~~ THEN REPLY @30222 DO ~IEex_Lua("IEex_HaveSummonerCast(2206)")~ EXIT
  IF ~~ THEN REPLY @30223 DO ~IEex_Lua("IEex_HaveSummonerCast(6253)")~ EXIT
  IF ~~ THEN REPLY @30224 DO ~IEex_Lua("IEex_HaveSummonerCast(2209)")~ EXIT
  IF ~~ THEN REPLY @30225 DO ~IEex_Lua("IEex_HaveSummonerCast(1210)")~ EXIT
  IF ~~ THEN REPLY @30226 DO ~IEex_Lua("IEex_HaveSummonerCast(2212)")~ EXIT
  IF ~~ THEN REPLY @30227 DO ~IEex_Lua("IEex_HaveSummonerCast(2214)")~ EXIT
  IF ~~ THEN REPLY @30228 DO ~IEex_Lua("IEex_HaveSummonerCast(2311)")~ EXIT
  IF ~~ THEN REPLY @30229 DO ~IEex_Lua("IEex_HaveSummonerCast(1108)")~ EXIT
  IF ~~ THEN REPLY @30230 DO ~IEex_Lua("IEex_HaveSummonerCast(2220)")~ EXIT
  IF ~~ THEN REPLY @30231 DO ~IEex_Lua("IEex_HaveSummonerCast(2230)")~ EXIT
  IF ~~ THEN REPLY @30232 DO ~IEex_Lua("IEex_HaveSummonerCast(2219)")~ EXIT
  IF ~~ THEN REPLY @30233 DO ~IEex_Lua("IEex_HaveSummonerCast(2215)")~ EXIT
END

IF ~~ THEN BEGIN WishCastSpell3
  SAY @30189
  IF ~~ THEN REPLY @30234 DO ~IEex_Lua("IEex_HaveSummonerCast(1301)")~ EXIT
  IF ~~ THEN REPLY @30235 DO ~IEex_Lua("IEex_HaveSummonerCast(2501)")~ EXIT
  IF ~~ THEN REPLY @30236 DO ~IEex_Lua("IEex_HaveSummonerCast(2323)")~ EXIT
  IF ~~ THEN REPLY @30237 DO ~IEex_Lua("IEex_HaveSummonerCast(2302)")~ EXIT
  IF ~~ THEN REPLY @30238 DO ~IEex_Lua("IEex_HaveSummonerCast(2419)")~ EXIT
  IF ~~ THEN REPLY @30239 DO ~IEex_Lua("IEex_HaveSummonerCast(6255)")~ EXIT
  IF ~~ THEN REPLY @30240 DO ~IEex_Lua("IEex_HaveSummonerCast(2304)")~ EXIT
  IF ~~ THEN REPLY @30241 DO ~IEex_Lua("IEex_HaveSummonerCast(6355)")~ EXIT
  IF ~~ THEN REPLY @30242 DO ~IEex_Lua("IEex_HaveSummonerCast(2317)")~ EXIT
  IF ~~ THEN REPLY @30243 DO ~IEex_Lua("IEex_HaveSummonerCast(2305)")~ EXIT
  IF ~~ THEN REPLY @30244 DO ~IEex_Lua("IEex_HaveSummonerCast(2306)")~ EXIT
  IF ~~ THEN REPLY @30245 DO ~IEex_Lua("IEex_HaveSummonerCast(2321)")~ EXIT
  IF ~~ THEN REPLY @30246 DO ~IEex_Lua("IEex_HaveSummonerCast(2322)")~ EXIT
  IF ~~ THEN REPLY @30247 DO ~IEex_Lua("IEex_HaveSummonerCast(6354)")~ EXIT
  IF ~~ THEN REPLY @30248 DO ~IEex_Lua("IEex_HaveSummonerCast(2310)")~ EXIT
  IF ~~ THEN REPLY @30249 DO ~IEex_Lua("IEex_HaveSummonerCast(5352)")~ EXIT
  IF ~~ THEN REPLY @30250 DO ~IEex_Lua("IEex_HaveSummonerCast(1306)")~ EXIT
  IF ~~ THEN REPLY @30251 DO ~IEex_Lua("IEex_HaveSummonerCast(6352)")~ EXIT
  IF ~~ THEN REPLY @30252 DO ~IEex_Lua("IEex_HaveSummonerCast(2313)")~ EXIT
  IF ~~ THEN REPLY @30253 DO ~IEex_Lua("IEex_HaveSummonerCast(2312)")~ EXIT
  IF ~~ THEN REPLY @30254 DO ~IEex_Lua("IEex_HaveSummonerCast(2213)")~ EXIT
  IF ~~ THEN REPLY @30255 DO ~IEex_Lua("IEex_HaveSummonerCast(2309)")~ EXIT
END

IF ~~ THEN BEGIN WishCastSpell4
  SAY @30189
  IF ~~ THEN REPLY @30256 DO ~IEex_Lua("IEex_HaveSummonerCast(1307)")~ EXIT
  IF ~~ THEN REPLY @30257 DO ~IEex_Lua("IEex_HaveSummonerCast(2621)")~ EXIT
  IF ~~ THEN REPLY @30258 DO ~IEex_Lua("IEex_HaveSummonerCast(2401)")~ EXIT
  IF ~~ THEN REPLY @30259 DO ~IEex_Lua("IEex_HaveSummonerCast(2420)")~ EXIT
  IF ~~ THEN REPLY @30260 DO ~IEex_Lua("IEex_HaveSummonerCast(2426)")~ EXIT
  IF ~~ THEN REPLY @30261 DO ~IEex_Lua("IEex_HaveSummonerCast(2427)")~ EXIT
  IF ~~ THEN REPLY @30262 DO ~IEex_Lua("IEex_HaveSummonerCast(6453)")~ EXIT
  IF ~~ THEN REPLY @30263 DO ~IEex_Lua("IEex_HaveSummonerCast(1410)")~ EXIT
  IF ~~ THEN REPLY @30264 DO ~IEex_Lua("IEex_HaveSummonerCast(2404)")~ EXIT
  IF ~~ THEN REPLY @30265 DO ~IEex_Lua("IEex_HaveSummonerCast(2405)")~ EXIT
  IF ~~ THEN REPLY @30266 DO ~IEex_Lua("IEex_HaveSummonerCast(1408)")~ EXIT
  IF ~~ THEN REPLY @30267 DO ~IEex_Lua("IEex_HaveSummonerCast(2412)")~ EXIT
  IF ~~ THEN REPLY @30268 DO ~IEex_Lua("IEex_HaveSummonerCast(2406)")~ EXIT
  IF ~~ THEN REPLY @30269 DO ~IEex_Lua("IEex_HaveSummonerCast(2413)")~ EXIT
  IF ~~ THEN REPLY @30270 DO ~IEex_Lua("IEex_HaveSummonerCast(6455)")~ EXIT
  IF ~~ THEN REPLY @30271 DO ~IEex_Lua("IEex_HaveSummonerCast(2418)")~ EXIT
  IF ~~ THEN REPLY @30272 DO ~IEex_Lua("IEex_HaveSummonerCast(2428)")~ EXIT
  IF ~~ THEN REPLY @30273 DO ~IEex_Lua("IEex_HaveSummonerCast(2414)")~ EXIT
  IF ~~ THEN REPLY @30274 DO ~IEex_Lua("IEex_HaveSummonerCast(2408)")~ EXIT
  IF ~~ THEN REPLY @30275 DO ~IEex_Lua("IEex_HaveSummonerCast(2711)")~ EXIT
  IF ~~ THEN REPLY @30276 DO ~IEex_Lua("IEex_HaveSummonerCast(2407)")~ EXIT
  IF ~~ THEN REPLY @30277 DO ~IEex_Lua("IEex_HaveSummonerCast(6451)")~ EXIT
  IF ~~ THEN REPLY @30278 DO ~IEex_Lua("IEex_HaveSummonerCast(1427)")~ EXIT
END

IF ~~ THEN BEGIN WishCastSpell5
  SAY @30189
  IF ~~ THEN REPLY @30279 DO ~IEex_Lua("IEex_HaveSummonerCast(2525)")~ EXIT
  IF ~~ THEN REPLY @30280 DO ~IEex_Lua("IEex_HaveSummonerCast(2503)")~ EXIT
  IF ~~ THEN REPLY @30281 DO ~IEex_Lua("IEex_HaveSummonerCast(6552)")~ EXIT
  IF ~~ THEN REPLY @30282 DO ~IEex_Lua("IEex_HaveSummonerCast(2512)")~ EXIT
  IF ~~ THEN REPLY @30283 DO ~IEex_Lua("IEex_HaveSummonerCast(2508)")~ EXIT
  IF ~~ THEN REPLY @30284 DO ~IEex_Lua("IEex_HaveSummonerCast(2520)")~ EXIT
  IF ~~ THEN REPLY @30285 DO ~IEex_Lua("IEex_HaveSummonerCast(2515)")~ EXIT
  IF ~~ THEN REPLY @30286 DO ~IEex_Lua("IEex_HaveSummonerCast(2514)")~ EXIT
  IF ~~ THEN REPLY @30287 DO ~IEex_Lua("IEex_HaveSummonerCast(2516)")~ EXIT
  IF ~~ THEN REPLY @30288 DO ~IEex_Lua("IEex_HaveSummonerCast(2521)")~ EXIT
  IF ~~ THEN REPLY @30289 DO ~IEex_Lua("IEex_HaveSummonerCast(2522)")~ EXIT
  IF ~~ THEN REPLY @30290 DO ~IEex_Lua("IEex_HaveSummonerCast(2523)")~ EXIT
  IF ~~ THEN REPLY @30291 DO ~IEex_Lua("IEex_HaveSummonerCast(2624)")~ EXIT
  IF ~~ THEN REPLY @30292 DO ~IEex_Lua("IEex_HaveSummonerCast(6553)")~ EXIT
  IF ~~ THEN REPLY @30293 DO ~IEex_Lua("IEex_HaveSummonerCast(2511)")~ EXIT
  IF ~~ THEN REPLY @30294 DO ~IEex_Lua("IEex_HaveSummonerCast(1219)")~ EXIT
  IF ~~ THEN REPLY @30295 DO ~IEex_Lua("IEex_HaveSummonerCast(2519)")~ EXIT
  IF ~~ THEN REPLY @30296 DO ~IEex_Lua("IEex_HaveSummonerCast(2505)")~ EXIT
  IF ~~ THEN REPLY @30297 DO ~IEex_Lua("IEex_HaveSummonerCast(2513)")~ EXIT
  IF ~~ THEN REPLY @30298 DO ~IEex_Lua("IEex_HaveSummonerCast(1714)")~ EXIT
END

IF ~~ THEN BEGIN WishCastSpell6
  SAY @30189
  IF ~~ THEN REPLY @30299 DO ~IEex_Lua("IEex_HaveSummonerCast(2601)")~ EXIT
  IF ~~ THEN REPLY @30300 DO ~IEex_Lua("IEex_HaveSummonerCast(6653)")~ EXIT
  IF ~~ THEN REPLY @30301 DO ~IEex_Lua("IEex_HaveSummonerCast(2509)")~ EXIT
  IF ~~ THEN REPLY @30302 DO ~IEex_Lua("IEex_HaveSummonerCast(2606)")~ EXIT
  IF ~~ THEN REPLY @30303 DO ~IEex_Lua("IEex_HaveSummonerCast(2618)")~ EXIT
  IF ~~ THEN REPLY @30304 DO ~IEex_Lua("IEex_HaveSummonerCast(2605)")~ EXIT
  IF ~~ THEN REPLY @30305 DO ~IEex_Lua("IEex_HaveSummonerCast(2608)")~ EXIT
  IF ~~ THEN REPLY @30306 DO ~IEex_Lua("IEex_HaveSummonerCast(2610)")~ EXIT
  IF ~~ THEN REPLY @30307 DO ~IEex_Lua("IEex_HaveSummonerCast(2623)")~ EXIT
  IF ~~ THEN REPLY @30308 DO ~IEex_Lua("IEex_HaveSummonerCast(2622)")~ EXIT
  IF ~~ THEN REPLY @30309 DO ~IEex_Lua("IEex_HaveSummonerCast(2628)")~ EXIT
  IF ~~ THEN REPLY @30310 DO ~IEex_Lua("IEex_HaveSummonerCast(2627)")~ EXIT
  IF ~~ THEN REPLY @30311 DO ~IEex_Lua("IEex_HaveSummonerCast(2629)")~ EXIT
  IF ~~ THEN REPLY @30312 DO ~IEex_Lua("IEex_HaveSummonerCast(2613)")~ EXIT
  IF ~~ THEN REPLY @30313 DO ~IEex_Lua("IEex_HaveSummonerCast(2619)")~ EXIT
  IF ~~ THEN REPLY @30314 DO ~IEex_Lua("IEex_HaveSummonerCast(6656)")~ EXIT
  IF ~~ THEN REPLY @30315 DO ~IEex_Lua("IEex_HaveSummonerCast(2609)")~ EXIT
  IF ~~ THEN REPLY @30316 DO ~IEex_Lua("IEex_HaveSummonerCast(2611)")~ EXIT
  IF ~~ THEN REPLY @30317 DO ~IEex_Lua("IEex_HaveSummonerCast(2513)")~ EXIT
  IF ~~ THEN REPLY @30318 DO ~IEex_Lua("IEex_HaveSummonerCast(2616)")~ EXIT
  IF ~~ THEN REPLY @30319 DO ~IEex_Lua("IEex_HaveSummonerCast(2620)")~ EXIT
  IF ~~ THEN REPLY @30320 DO ~IEex_Lua("IEex_HaveSummonerCast(2203)")~ EXIT
  IF ~~ THEN REPLY @30321 DO ~IEex_Lua("IEex_HaveSummonerCast(2626)")~ EXIT
END

IF ~~ THEN BEGIN WishCastSpell7
  SAY @30189
  IF ~~ THEN REPLY @30322 DO ~IEex_Lua("IEex_HaveSummonerCast(2708)")~ EXIT
  IF ~~ THEN REPLY @30323 DO ~IEex_Lua("IEex_HaveSummonerCast(2718)")~ EXIT
  IF ~~ THEN REPLY @30324 DO ~IEex_Lua("IEex_HaveSummonerCast(2713)")~ EXIT
  IF ~~ THEN REPLY @30325 DO ~IEex_Lua("IEex_HaveSummonerCast(2717)")~ EXIT
  IF ~~ THEN REPLY @30326 DO ~IEex_Lua("IEex_HaveSummonerCast(1424)")~ EXIT
  IF ~~ THEN REPLY @30327 DO ~IEex_Lua("IEex_HaveSummonerCast(2714)")~ EXIT
  IF ~~ THEN REPLY @30328 DO ~IEex_Lua("IEex_HaveSummonerCast(6761)")~ EXIT
  IF ~~ THEN REPLY @30329 DO ~IEex_Lua("IEex_HaveSummonerCast(2707)")~ EXIT
  IF ~~ THEN REPLY @30330 DO ~IEex_Lua("IEex_HaveSummonerCast(6752)")~ EXIT
  IF ~~ THEN REPLY @30331 DO ~IEex_Lua("IEex_HaveSummonerCast(2709)")~ EXIT
  IF ~~ THEN REPLY @30332 DO ~IEex_Lua("IEex_HaveSummonerCast(2704)")~ EXIT
  IF ~~ THEN REPLY @30333 DO ~IEex_Lua("IEex_HaveSummonerCast(6860)")~ EXIT
  IF ~~ THEN REPLY @30334 DO ~IEex_Lua("IEex_HaveSummonerCast(5653)")~ EXIT
  IF ~~ THEN REPLY @30335 DO ~IEex_Lua("IEex_HaveSummonerCast(2710)")~ EXIT
  IF ~~ THEN REPLY @30336 DO ~IEex_Lua("IEex_HaveSummonerCast(6762)")~ EXIT
  IF ~~ THEN REPLY @30337 DO ~IEex_Lua("IEex_HaveSummonerCast(6760)")~ EXIT
  IF ~~ THEN REPLY @30338 DO ~IEex_Lua("IEex_HaveSummonerCast(6758)")~ EXIT
  IF ~~ THEN REPLY @30339 DO ~IEex_Lua("IEex_HaveSummonerCast(6763)")~ EXIT
  IF ~~ THEN REPLY @30340 DO ~IEex_Lua("IEex_HaveSummonerCast(6751)")~ EXIT
  IF ~~ THEN REPLY @30341 DO ~IEex_Lua("IEex_HaveSummonerCast(2716)")~ EXIT
  IF ~~ THEN REPLY @30342 DO ~IEex_Lua("IEex_HaveSummonerCast(2715)")~ EXIT
  IF ~~ THEN REPLY @30343 DO ~IEex_Lua("IEex_HaveSummonerCast(2703)")~ EXIT
  IF ~~ THEN REPLY @30344 DO ~IEex_Lua("IEex_HaveSummonerCast(6759)")~ EXIT
  IF ~~ THEN REPLY @30345 DO ~IEex_Lua("IEex_HaveSummonerCast(2719)")~ EXIT
END

IF ~~ THEN BEGIN WishCastSpell8
  SAY @30189
  IF ~~ THEN REPLY @30370 DO ~IEex_Lua("IEex_HaveSummonerCast(6866)")~ EXIT
  IF ~~ THEN REPLY @30346 DO ~IEex_Lua("IEex_HaveSummonerCast(1727)")~ EXIT
  IF ~~ THEN REPLY @30347 DO ~IEex_Lua("IEex_HaveSummonerCast(2712)")~ EXIT
  IF ~~ THEN REPLY @30348 DO ~IEex_Lua("IEex_HaveSummonerCast(2802)")~ EXIT
  IF ~~ THEN REPLY @30349 DO ~IEex_Lua("IEex_HaveSummonerCast(2805)")~ EXIT
  IF ~~ THEN REPLY @30350 DO ~IEex_Lua("IEex_HaveSummonerCast(2807)")~ EXIT
  IF ~~ THEN REPLY @30351 DO ~IEex_Lua("IEex_HaveSummonerCast(6954)")~ EXIT
  IF ~~ THEN REPLY @30352 DO ~IEex_Lua("IEex_HaveSummonerCast(6858)")~ EXIT
  IF ~~ THEN REPLY @30353 DO ~IEex_Lua("IEex_HaveSummonerCast(2804)")~ EXIT
  IF ~~ THEN REPLY @30354 DO ~IEex_Lua("IEex_HaveSummonerCast(6859)")~ EXIT
  IF ~~ THEN REPLY @30355 DO ~IEex_Lua("IEex_HaveSummonerCast(2808)")~ EXIT
  IF ~~ THEN REPLY @30356 DO ~IEex_Lua("IEex_HaveSummonerCast(6863)")~ EXIT
  IF ~~ THEN REPLY @30357 DO ~IEex_Lua("IEex_HaveSummonerCast(6862)")~ EXIT
  IF ~~ THEN REPLY @30358 DO ~IEex_Lua("IEex_HaveSummonerCast(6856)")~ EXIT
  IF ~~ THEN REPLY @30359 DO ~IEex_Lua("IEex_HaveSummonerCast(2809)")~ EXIT
  IF ~~ THEN REPLY @30360 DO ~IEex_Lua("IEex_HaveSummonerCast(2803)")~ EXIT
  IF ~~ THEN REPLY @30361 DO ~IEex_Lua("IEex_HaveSummonerCast(1726)")~ EXIT
  IF ~~ THEN REPLY @30362 DO ~IEex_Lua("IEex_HaveSummonerCast(1715)")~ EXIT
  IF ~~ THEN REPLY @30363 DO ~IEex_Lua("IEex_HaveSummonerCast(1728)")~ EXIT
END

IF ~~ THEN BEGIN WishOneTime
  SAY @30189
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Strength_P1","GLOBAL",0)~ THEN REPLY @30166 DO ~SetGlobal("US_Wish_Strength_P1","GLOBAL",1)~ GOTO WishStrength
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Strength_P2","GLOBAL",0)~ THEN REPLY @30166 DO ~SetGlobal("US_Wish_Strength_P2","GLOBAL",1)~ GOTO WishStrength
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Strength_P3","GLOBAL",0)~ THEN REPLY @30166 DO ~SetGlobal("US_Wish_Strength_P3","GLOBAL",1)~ GOTO WishStrength
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Strength_P4","GLOBAL",0)~ THEN REPLY @30166 DO ~SetGlobal("US_Wish_Strength_P4","GLOBAL",1)~ GOTO WishStrength
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Strength_P5","GLOBAL",0)~ THEN REPLY @30166 DO ~SetGlobal("US_Wish_Strength_P5","GLOBAL",1)~ GOTO WishStrength
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Strength_P6","GLOBAL",0)~ THEN REPLY @30166 DO ~SetGlobal("US_Wish_Strength_P6","GLOBAL",1)~ GOTO WishStrength
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Dexterity_P1","GLOBAL",0)~ THEN REPLY @30167 DO ~SetGlobal("US_Wish_Dexterity_P1","GLOBAL",1)~ GOTO WishDexterity
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Dexterity_P2","GLOBAL",0)~ THEN REPLY @30167 DO ~SetGlobal("US_Wish_Dexterity_P2","GLOBAL",1)~ GOTO WishDexterity
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Dexterity_P3","GLOBAL",0)~ THEN REPLY @30167 DO ~SetGlobal("US_Wish_Dexterity_P3","GLOBAL",1)~ GOTO WishDexterity
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Dexterity_P4","GLOBAL",0)~ THEN REPLY @30167 DO ~SetGlobal("US_Wish_Dexterity_P4","GLOBAL",1)~ GOTO WishDexterity
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Dexterity_P5","GLOBAL",0)~ THEN REPLY @30167 DO ~SetGlobal("US_Wish_Dexterity_P5","GLOBAL",1)~ GOTO WishDexterity
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Dexterity_P6","GLOBAL",0)~ THEN REPLY @30167 DO ~SetGlobal("US_Wish_Dexterity_P6","GLOBAL",1)~ GOTO WishDexterity
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Constitution_P1","GLOBAL",0)~ THEN REPLY @30168 DO ~SetGlobal("US_Wish_Constitution_P1","GLOBAL",1)~ GOTO WishConstitution
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Constitution_P2","GLOBAL",0)~ THEN REPLY @30168 DO ~SetGlobal("US_Wish_Constitution_P2","GLOBAL",1)~ GOTO WishConstitution
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Constitution_P3","GLOBAL",0)~ THEN REPLY @30168 DO ~SetGlobal("US_Wish_Constitution_P3","GLOBAL",1)~ GOTO WishConstitution
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Constitution_P4","GLOBAL",0)~ THEN REPLY @30168 DO ~SetGlobal("US_Wish_Constitution_P4","GLOBAL",1)~ GOTO WishConstitution
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Constitution_P5","GLOBAL",0)~ THEN REPLY @30168 DO ~SetGlobal("US_Wish_Constitution_P5","GLOBAL",1)~ GOTO WishConstitution
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Constitution_P6","GLOBAL",0)~ THEN REPLY @30168 DO ~SetGlobal("US_Wish_Constitution_P6","GLOBAL",1)~ GOTO WishConstitution
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Intelligence_P1","GLOBAL",0)~ THEN REPLY @30169 DO ~SetGlobal("US_Wish_Intelligence_P1","GLOBAL",1)~ GOTO WishIntelligence
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Intelligence_P2","GLOBAL",0)~ THEN REPLY @30169 DO ~SetGlobal("US_Wish_Intelligence_P2","GLOBAL",1)~ GOTO WishIntelligence
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Intelligence_P3","GLOBAL",0)~ THEN REPLY @30169 DO ~SetGlobal("US_Wish_Intelligence_P3","GLOBAL",1)~ GOTO WishIntelligence
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Intelligence_P4","GLOBAL",0)~ THEN REPLY @30169 DO ~SetGlobal("US_Wish_Intelligence_P4","GLOBAL",1)~ GOTO WishIntelligence
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Intelligence_P5","GLOBAL",0)~ THEN REPLY @30169 DO ~SetGlobal("US_Wish_Intelligence_P5","GLOBAL",1)~ GOTO WishIntelligence
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Intelligence_P6","GLOBAL",0)~ THEN REPLY @30169 DO ~SetGlobal("US_Wish_Intelligence_P6","GLOBAL",1)~ GOTO WishIntelligence
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Wisdom_P1","GLOBAL",0)~ THEN REPLY @30170 DO ~SetGlobal("US_Wish_Wisdom_P1","GLOBAL",1)~ GOTO WishWisdom
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Wisdom_P2","GLOBAL",0)~ THEN REPLY @30170 DO ~SetGlobal("US_Wish_Wisdom_P2","GLOBAL",1)~ GOTO WishWisdom
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Wisdom_P3","GLOBAL",0)~ THEN REPLY @30170 DO ~SetGlobal("US_Wish_Wisdom_P3","GLOBAL",1)~ GOTO WishWisdom
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Wisdom_P4","GLOBAL",0)~ THEN REPLY @30170 DO ~SetGlobal("US_Wish_Wisdom_P4","GLOBAL",1)~ GOTO WishWisdom
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Wisdom_P5","GLOBAL",0)~ THEN REPLY @30170 DO ~SetGlobal("US_Wish_Wisdom_P5","GLOBAL",1)~ GOTO WishWisdom
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Wisdom_P6","GLOBAL",0)~ THEN REPLY @30170 DO ~SetGlobal("US_Wish_Wisdom_P6","GLOBAL",1)~ GOTO WishWisdom
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Charisma_P1","GLOBAL",0)~ THEN REPLY @30171 DO ~SetGlobal("US_Wish_Charisma_P1","GLOBAL",1)~ GOTO WishCharisma
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Charisma_P2","GLOBAL",0)~ THEN REPLY @30171 DO ~SetGlobal("US_Wish_Charisma_P2","GLOBAL",1)~ GOTO WishCharisma
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Charisma_P3","GLOBAL",0)~ THEN REPLY @30171 DO ~SetGlobal("US_Wish_Charisma_P3","GLOBAL",1)~ GOTO WishCharisma
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Charisma_P4","GLOBAL",0)~ THEN REPLY @30171 DO ~SetGlobal("US_Wish_Charisma_P4","GLOBAL",1)~ GOTO WishCharisma
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Charisma_P5","GLOBAL",0)~ THEN REPLY @30171 DO ~SetGlobal("US_Wish_Charisma_P5","GLOBAL",1)~ GOTO WishCharisma
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Charisma_P6","GLOBAL",0)~ THEN REPLY @30171 DO ~SetGlobal("US_Wish_Charisma_P6","GLOBAL",1)~ GOTO WishCharisma
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Item_P1","GLOBAL",0)~ THEN REPLY @30172 DO ~SetGlobal("US_Wish_Item_P1","GLOBAL",1)~ GOTO WishItem
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Item_P2","GLOBAL",0)~ THEN REPLY @30172 DO ~SetGlobal("US_Wish_Item_P2","GLOBAL",1)~ GOTO WishItem
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Item_P3","GLOBAL",0)~ THEN REPLY @30172 DO ~SetGlobal("US_Wish_Item_P3","GLOBAL",1)~ GOTO WishItem
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Item_P4","GLOBAL",0)~ THEN REPLY @30172 DO ~SetGlobal("US_Wish_Item_P4","GLOBAL",1)~ GOTO WishItem
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Item_P5","GLOBAL",0)~ THEN REPLY @30172 DO ~SetGlobal("US_Wish_Item_P5","GLOBAL",1)~ GOTO WishItem
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Item_P6","GLOBAL",0)~ THEN REPLY @30172 DO ~SetGlobal("US_Wish_Item_P6","GLOBAL",1)~ GOTO WishItem
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Gold_P1","GLOBAL",0)~ THEN REPLY @30173 DO ~SetGlobal("US_Wish_Gold_P1","GLOBAL",1)~ GOTO WishGold
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Gold_P2","GLOBAL",0)~ THEN REPLY @30173 DO ~SetGlobal("US_Wish_Gold_P2","GLOBAL",1)~ GOTO WishGold
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Gold_P3","GLOBAL",0)~ THEN REPLY @30173 DO ~SetGlobal("US_Wish_Gold_P3","GLOBAL",1)~ GOTO WishGold
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Gold_P4","GLOBAL",0)~ THEN REPLY @30173 DO ~SetGlobal("US_Wish_Gold_P4","GLOBAL",1)~ GOTO WishGold
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Gold_P5","GLOBAL",0)~ THEN REPLY @30173 DO ~SetGlobal("US_Wish_Gold_P5","GLOBAL",1)~ GOTO WishGold
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Gold_P6","GLOBAL",0)~ THEN REPLY @30173 DO ~SetGlobal("US_Wish_Gold_P6","GLOBAL",1)~ GOTO WishGold
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Rest_P1","GLOBAL",0)~ THEN REPLY @30174 DO ~SetGlobal("US_Wish_Rest_P1","GLOBAL",1)~ GOTO WishRest
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Rest_P2","GLOBAL",0)~ THEN REPLY @30174 DO ~SetGlobal("US_Wish_Rest_P2","GLOBAL",1)~ GOTO WishRest
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Rest_P3","GLOBAL",0)~ THEN REPLY @30174 DO ~SetGlobal("US_Wish_Rest_P3","GLOBAL",1)~ GOTO WishRest
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Rest_P4","GLOBAL",0)~ THEN REPLY @30174 DO ~SetGlobal("US_Wish_Rest_P4","GLOBAL",1)~ GOTO WishRest
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Rest_P5","GLOBAL",0)~ THEN REPLY @30174 DO ~SetGlobal("US_Wish_Rest_P5","GLOBAL",1)~ GOTO WishRest
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Rest_P6","GLOBAL",0)~ THEN REPLY @30174 DO ~SetGlobal("US_Wish_Rest_P6","GLOBAL",1)~ GOTO WishRest
  IF ~~ THEN REPLY @30175 GOTO WishEpic
END

IF ~~ THEN BEGIN WishStrength
  SAY @30186
  IF ~~ THEN DO ~IEex_Lua("IEex_HaveSummonerCast(USWSHSTR,true)")~ EXIT
END

IF ~~ THEN BEGIN WishDexterity
  SAY @30186
  IF ~~ THEN DO ~IEex_Lua("IEex_HaveSummonerCast(USWSHDEX,true)")~ EXIT
END

IF ~~ THEN BEGIN WishConstitution
  SAY @30186
  IF ~~ THEN DO ~IEex_Lua("IEex_HaveSummonerCast(USWSHCON,true)")~ EXIT
END

IF ~~ THEN BEGIN WishIntelligence
  SAY @30186
  IF ~~ THEN DO ~IEex_Lua("IEex_HaveSummonerCast(USWSHINT,true)")~ EXIT
END

IF ~~ THEN BEGIN WishWisdom
  SAY @30186
  IF ~~ THEN DO ~IEex_Lua("IEex_HaveSummonerCast(USWSHWIS,true)")~ EXIT
END

IF ~~ THEN BEGIN WishCharisma
  SAY @30186
  IF ~~ THEN DO ~IEex_Lua("IEex_HaveSummonerCast(USWSHCHR,true)")~ EXIT
END

IF ~~ THEN BEGIN WishItem
  SAY @30187
  IF ~~ THEN DO ~GiveItemCreate("USRT15_V",Protagonist,1,1,1)~ EXIT
END

IF ~~ THEN BEGIN WishGold
  SAY @30188
  IF ~~ THEN DO ~GiveItemCreate("Misc07",Protagonist,10000,0,0)
GiveItemCreate("Misc07",Protagonist,10000,0,0)
GiveItemCreate("Misc07",Protagonist,10000,0,0)
GiveItemCreate("Misc07",Protagonist,10000,0,0)
GiveItemCreate("Misc07",Protagonist,10000,0,0)
GiveItemCreate("Misc07",Protagonist,10000,0,0)
GiveItemCreate("Misc07",Protagonist,10000,0,0)
GiveItemCreate("Misc07",Protagonist,10000,0,0)
GiveItemCreate("Misc07",Protagonist,10000,0,0)
GiveItemCreate("Misc07",Protagonist,10000,0,0)~ EXIT
END

IF ~~ THEN BEGIN WishRest
  SAY @30186
  IF ~~ THEN DO ~IEex_Lua("IEex_HaveSummonerCast(USWSHRST,true)")~ EXIT
END

IF ~~ THEN BEGIN WishEpic
  SAY @30189
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_005_P1","GLOBAL",0)~ THEN REPLY @30176 DO ~SetGlobal("US_Wish_Epic_005_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10005)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_005_P2","GLOBAL",0)~ THEN REPLY @30176 DO ~SetGlobal("US_Wish_Epic_005_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10005)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_005_P3","GLOBAL",0)~ THEN REPLY @30176 DO ~SetGlobal("US_Wish_Epic_005_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10005)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_005_P4","GLOBAL",0)~ THEN REPLY @30176 DO ~SetGlobal("US_Wish_Epic_005_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10005)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_005_P5","GLOBAL",0)~ THEN REPLY @30176 DO ~SetGlobal("US_Wish_Epic_005_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10005)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_005_P6","GLOBAL",0)~ THEN REPLY @30176 DO ~SetGlobal("US_Wish_Epic_005_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10005)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_013_P1","GLOBAL",0)~ THEN REPLY @30177 DO ~SetGlobal("US_Wish_Epic_013_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10013)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_013_P2","GLOBAL",0)~ THEN REPLY @30177 DO ~SetGlobal("US_Wish_Epic_013_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10013)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_013_P3","GLOBAL",0)~ THEN REPLY @30177 DO ~SetGlobal("US_Wish_Epic_013_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10013)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_013_P4","GLOBAL",0)~ THEN REPLY @30177 DO ~SetGlobal("US_Wish_Epic_013_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10013)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_013_P5","GLOBAL",0)~ THEN REPLY @30177 DO ~SetGlobal("US_Wish_Epic_013_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10013)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_013_P6","GLOBAL",0)~ THEN REPLY @30177 DO ~SetGlobal("US_Wish_Epic_013_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10013)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_012_P1","GLOBAL",0)~ THEN REPLY @30178 DO ~SetGlobal("US_Wish_Epic_012_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10012)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_012_P2","GLOBAL",0)~ THEN REPLY @30178 DO ~SetGlobal("US_Wish_Epic_012_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10012)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_012_P3","GLOBAL",0)~ THEN REPLY @30178 DO ~SetGlobal("US_Wish_Epic_012_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10012)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_012_P4","GLOBAL",0)~ THEN REPLY @30178 DO ~SetGlobal("US_Wish_Epic_012_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10012)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_012_P5","GLOBAL",0)~ THEN REPLY @30178 DO ~SetGlobal("US_Wish_Epic_012_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10012)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_012_P6","GLOBAL",0)~ THEN REPLY @30178 DO ~SetGlobal("US_Wish_Epic_012_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10012)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_004_P1","GLOBAL",0)~ THEN REPLY @30179 DO ~SetGlobal("US_Wish_Epic_004_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10004)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_004_P2","GLOBAL",0)~ THEN REPLY @30179 DO ~SetGlobal("US_Wish_Epic_004_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10004)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_004_P3","GLOBAL",0)~ THEN REPLY @30179 DO ~SetGlobal("US_Wish_Epic_004_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10004)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_004_P4","GLOBAL",0)~ THEN REPLY @30179 DO ~SetGlobal("US_Wish_Epic_004_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10004)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_004_P5","GLOBAL",0)~ THEN REPLY @30179 DO ~SetGlobal("US_Wish_Epic_004_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10004)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_004_P6","GLOBAL",0)~ THEN REPLY @30179 DO ~SetGlobal("US_Wish_Epic_004_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10004)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_003_P1","GLOBAL",0)~ THEN REPLY @30180 DO ~SetGlobal("US_Wish_Epic_003_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10003)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_003_P2","GLOBAL",0)~ THEN REPLY @30180 DO ~SetGlobal("US_Wish_Epic_003_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10003)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_003_P3","GLOBAL",0)~ THEN REPLY @30180 DO ~SetGlobal("US_Wish_Epic_003_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10003)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_003_P4","GLOBAL",0)~ THEN REPLY @30180 DO ~SetGlobal("US_Wish_Epic_003_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10003)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_003_P5","GLOBAL",0)~ THEN REPLY @30180 DO ~SetGlobal("US_Wish_Epic_003_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10003)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_003_P6","GLOBAL",0)~ THEN REPLY @30180 DO ~SetGlobal("US_Wish_Epic_003_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10003)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_021_P1","GLOBAL",0)~ THEN REPLY @30367 DO ~SetGlobal("US_Wish_Epic_021_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10021)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_021_P2","GLOBAL",0)~ THEN REPLY @30367 DO ~SetGlobal("US_Wish_Epic_021_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10021)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_021_P3","GLOBAL",0)~ THEN REPLY @30367 DO ~SetGlobal("US_Wish_Epic_021_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10021)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_021_P4","GLOBAL",0)~ THEN REPLY @30367 DO ~SetGlobal("US_Wish_Epic_021_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10021)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_021_P5","GLOBAL",0)~ THEN REPLY @30367 DO ~SetGlobal("US_Wish_Epic_021_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10021)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_021_P6","GLOBAL",0)~ THEN REPLY @30367 DO ~SetGlobal("US_Wish_Epic_021_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10021)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_014_P1","GLOBAL",0)~ THEN REPLY @30181 DO ~SetGlobal("US_Wish_Epic_014_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10014)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_014_P2","GLOBAL",0)~ THEN REPLY @30181 DO ~SetGlobal("US_Wish_Epic_014_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10014)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_014_P3","GLOBAL",0)~ THEN REPLY @30181 DO ~SetGlobal("US_Wish_Epic_014_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10014)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_014_P4","GLOBAL",0)~ THEN REPLY @30181 DO ~SetGlobal("US_Wish_Epic_014_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10014)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_014_P5","GLOBAL",0)~ THEN REPLY @30181 DO ~SetGlobal("US_Wish_Epic_014_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10014)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_014_P6","GLOBAL",0)~ THEN REPLY @30181 DO ~SetGlobal("US_Wish_Epic_014_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10014)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_009_P1","GLOBAL",0)~ THEN REPLY @30182 DO ~SetGlobal("US_Wish_Epic_009_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10009)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_009_P2","GLOBAL",0)~ THEN REPLY @30182 DO ~SetGlobal("US_Wish_Epic_009_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10009)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_009_P3","GLOBAL",0)~ THEN REPLY @30182 DO ~SetGlobal("US_Wish_Epic_009_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10009)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_009_P4","GLOBAL",0)~ THEN REPLY @30182 DO ~SetGlobal("US_Wish_Epic_009_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10009)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_009_P5","GLOBAL",0)~ THEN REPLY @30182 DO ~SetGlobal("US_Wish_Epic_009_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10009)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_009_P6","GLOBAL",0)~ THEN REPLY @30182 DO ~SetGlobal("US_Wish_Epic_009_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10009)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_020_P1","GLOBAL",0)~ THEN REPLY @30366 DO ~SetGlobal("US_Wish_Epic_020_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10020)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_020_P2","GLOBAL",0)~ THEN REPLY @30366 DO ~SetGlobal("US_Wish_Epic_020_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10020)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_020_P3","GLOBAL",0)~ THEN REPLY @30366 DO ~SetGlobal("US_Wish_Epic_020_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10020)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_020_P4","GLOBAL",0)~ THEN REPLY @30366 DO ~SetGlobal("US_Wish_Epic_020_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10020)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_020_P5","GLOBAL",0)~ THEN REPLY @30366 DO ~SetGlobal("US_Wish_Epic_020_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10020)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_020_P6","GLOBAL",0)~ THEN REPLY @30366 DO ~SetGlobal("US_Wish_Epic_020_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10020)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_006_P1","GLOBAL",0)~ THEN REPLY @30183 DO ~SetGlobal("US_Wish_Epic_006_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10006)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_006_P2","GLOBAL",0)~ THEN REPLY @30183 DO ~SetGlobal("US_Wish_Epic_006_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10006)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_006_P3","GLOBAL",0)~ THEN REPLY @30183 DO ~SetGlobal("US_Wish_Epic_006_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10006)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_006_P4","GLOBAL",0)~ THEN REPLY @30183 DO ~SetGlobal("US_Wish_Epic_006_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10006)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_006_P5","GLOBAL",0)~ THEN REPLY @30183 DO ~SetGlobal("US_Wish_Epic_006_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10006)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_006_P6","GLOBAL",0)~ THEN REPLY @30183 DO ~SetGlobal("US_Wish_Epic_006_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10006)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_025_P1","GLOBAL",0)~ THEN REPLY @30372 DO ~SetGlobal("US_Wish_Epic_025_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10025)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_025_P2","GLOBAL",0)~ THEN REPLY @30372 DO ~SetGlobal("US_Wish_Epic_025_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10025)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_025_P3","GLOBAL",0)~ THEN REPLY @30372 DO ~SetGlobal("US_Wish_Epic_025_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10025)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_025_P4","GLOBAL",0)~ THEN REPLY @30372 DO ~SetGlobal("US_Wish_Epic_025_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10025)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_025_P5","GLOBAL",0)~ THEN REPLY @30372 DO ~SetGlobal("US_Wish_Epic_025_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10025)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_025_P6","GLOBAL",0)~ THEN REPLY @30372 DO ~SetGlobal("US_Wish_Epic_025_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10025)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_015_P1","GLOBAL",0)~ THEN REPLY @30184 DO ~SetGlobal("US_Wish_Epic_015_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10015)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_015_P2","GLOBAL",0)~ THEN REPLY @30184 DO ~SetGlobal("US_Wish_Epic_015_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10015)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_015_P3","GLOBAL",0)~ THEN REPLY @30184 DO ~SetGlobal("US_Wish_Epic_015_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10015)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_015_P4","GLOBAL",0)~ THEN REPLY @30184 DO ~SetGlobal("US_Wish_Epic_015_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10015)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_015_P5","GLOBAL",0)~ THEN REPLY @30184 DO ~SetGlobal("US_Wish_Epic_015_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10015)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_015_P6","GLOBAL",0)~ THEN REPLY @30184 DO ~SetGlobal("US_Wish_Epic_015_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10015)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_018_P1","GLOBAL",0)~ THEN REPLY @30364 DO ~SetGlobal("US_Wish_Epic_018_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10018)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_018_P2","GLOBAL",0)~ THEN REPLY @30364 DO ~SetGlobal("US_Wish_Epic_018_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10018)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_018_P3","GLOBAL",0)~ THEN REPLY @30364 DO ~SetGlobal("US_Wish_Epic_018_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10018)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_018_P4","GLOBAL",0)~ THEN REPLY @30364 DO ~SetGlobal("US_Wish_Epic_018_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10018)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_018_P5","GLOBAL",0)~ THEN REPLY @30364 DO ~SetGlobal("US_Wish_Epic_018_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10018)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_018_P6","GLOBAL",0)~ THEN REPLY @30364 DO ~SetGlobal("US_Wish_Epic_018_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10018)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_022_P1","GLOBAL",0)~ THEN REPLY @30368 DO ~SetGlobal("US_Wish_Epic_022_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10022)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_022_P2","GLOBAL",0)~ THEN REPLY @30368 DO ~SetGlobal("US_Wish_Epic_022_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10022)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_022_P3","GLOBAL",0)~ THEN REPLY @30368 DO ~SetGlobal("US_Wish_Epic_022_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10022)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_022_P4","GLOBAL",0)~ THEN REPLY @30368 DO ~SetGlobal("US_Wish_Epic_022_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10022)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_022_P5","GLOBAL",0)~ THEN REPLY @30368 DO ~SetGlobal("US_Wish_Epic_022_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10022)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_022_P6","GLOBAL",0)~ THEN REPLY @30368 DO ~SetGlobal("US_Wish_Epic_022_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10022)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_023_P1","GLOBAL",0)~ THEN REPLY @30369 DO ~SetGlobal("US_Wish_Epic_023_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10023)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_023_P2","GLOBAL",0)~ THEN REPLY @30369 DO ~SetGlobal("US_Wish_Epic_023_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10023)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_023_P3","GLOBAL",0)~ THEN REPLY @30369 DO ~SetGlobal("US_Wish_Epic_023_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10023)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_023_P4","GLOBAL",0)~ THEN REPLY @30369 DO ~SetGlobal("US_Wish_Epic_023_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10023)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_023_P5","GLOBAL",0)~ THEN REPLY @30369 DO ~SetGlobal("US_Wish_Epic_023_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10023)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_023_P6","GLOBAL",0)~ THEN REPLY @30369 DO ~SetGlobal("US_Wish_Epic_023_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10023)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,1)
Global("US_Wish_Epic_008_P1","GLOBAL",0)~ THEN REPLY @30185 DO ~SetGlobal("US_Wish_Epic_008_P1","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10008)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,2)
Global("US_Wish_Epic_008_P2","GLOBAL",0)~ THEN REPLY @30185 DO ~SetGlobal("US_Wish_Epic_008_P2","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10008)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,3)
Global("US_Wish_Epic_008_P3","GLOBAL",0)~ THEN REPLY @30185 DO ~SetGlobal("US_Wish_Epic_008_P3","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10008)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,4)
Global("US_Wish_Epic_008_P4","GLOBAL",0)~ THEN REPLY @30185 DO ~SetGlobal("US_Wish_Epic_008_P4","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10008)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,5)
Global("US_Wish_Epic_008_P5","GLOBAL",0)~ THEN REPLY @30185 DO ~SetGlobal("US_Wish_Epic_008_P5","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10008)")~ EXIT
  IF ~IsPlayerNumber(Protagonist,6)
Global("US_Wish_Epic_008_P6","GLOBAL",0)~ THEN REPLY @30185 DO ~SetGlobal("US_Wish_Epic_008_P6","GLOBAL",1)
IEex_Lua("IEex_HaveSummonerCast(10008)")~ EXIT
END