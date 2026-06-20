# IWD2EE — HD crisp UI fonts (working notes)

Goal: under the IWD2EE **2× UI** (`m_bUseNewGui`), the engine blows the small 1× bitmap
fonts up ×2 with **nearest-neighbour** → blocky. We want **sharp 2× text**: replace each
font with a 2×-authored sharp BAM **and** stop the engine doubling it (else 2×BAM × 2× = 4×).

Status: **WORKING — NORMAL renders crisp 2× at the original size, all UI screens.** See **§8 FINAL
SOLUTION** for the shipped design (it supersedes the hook iterations in §5/§7; those are kept as the
investigation trail). 2× sharp `NORMAL.BAM` in `Override/` + de-double hooks on the `CResCell`
resource chokepoint. Verified in-game: menus, character record, journal, combat log, dialogue.

---

## 0. Where things live (work here, reference the RE repo)

**Work folder (this game install):** `/home/wills/Games/Heroic/Icewind Dale 2/`
- Runtime IEex Lua = `Override/*.lua`. `Override/M__IEex.lua` is the master; it `dofile`s
  `override/IEex_Common_State.lua`, `IEex_IWD2_Patch.lua`, etc. (the loader reads `Override/`).
- Mod source (WeiDU) = `iwd2ee/ieex_override/*.lua`, BAMs in `iwd2ee/bam/`. A **WeiDU reinstall
  regenerates `Override/` from here** → any hand-edit to `Override/` is wiped on reinstall.
  Mirror edits into `iwd2ee/ieex_override/` too (and ultimately the `.tp2`) for persistence.
- BAM assets the engine reads at runtime = `Override/`.
- Launch = **Heroic** (Proton `proton-cachyos-slr`, prefix `…/Prefixes/Icewind Dale 2 Complete`,
  targetExe `IWD2EE.exe` = the IEexLoader, which injects `IEex.dll` into `iwd2.exe`).
- Logs: `IEex.log` (startup + DLL info + some `print`s), `crash/IEex_*.{log,dmp}` on a crash.

**Reference (RE repo):** `/home/wills/iwd2-re/`  — *recovered C++ of IWD2.exe; read-only here.*
- `src/` = hand-recovered C++, addresses in `// 0xADDR` comments. **The Heroic `iwd2.exe` is the
  IWD2EE-PATCHED build** (sha differs from the RE target, **15774 bytes differ**), but most
  function addresses still match — *verify before trusting* (see §6).
- `scripts/bam_font_pack.py` = the HD BAM packer (run via `.venv-reagent/bin/python`).
- `scripts/sym.py` = PE bytes / disasm / crash tools. `scripts/src_find.py NAME` = find fn/addr.
- `.bin/iwd2.exe` = vanilla RE-target binary, for byte-diff vs the patched Heroic exe.

---

## 1. THE KEY DISCOVERY — the UI text path is **2D, not 3D**

The running game is **NOT 3D-accelerated** (cnc-ddraw presents a **ddraw 2D surface**).

`CVidInf::BKTextOut @0x79E340` (the control text-draw router) does:
```
if (g_pChitin->cVideo.m_bIs3dAccelerated)            -> pFont->TextOut3d(...)   // 3D  (NOT used here)
else if (m_sFontName=="" || resref=="STATES2")       -> pFont->TextOut(...)     // 2D  <-- English UI text
else                                                 -> pFont->TextOutEx(...)   // 2D
```
So UI text goes through **`CVidFont::TextOut @0x793720` (2D)** → **`CVidCell::Render @0x7AEAD0`** (blit).

**Consequence:** the 2×→4× doubling lives in this **2D TextOut/Render path** — NOT in the
`CVidFont::m_bDoubleSize` flag that drives the **3D** `RenderCharacters` nScale. That is why
~20 launches spent clearing the SetResRef `bDoubleSize` flag **never reduced the size**: wrong path.

**Proof:** a (deliberately-installed but buggy) trace `HookRestore` on `TextOut@0x793720`
accidentally **un-doubled** the UI text (the GenLuaCall failed → stack corruption → 1× render).
i.e. disrupting the 2D path disables the doubling → **the 2D path is the lever.**

---

## 1a. THE 2D LEVER — pinned end-to-end (this session, RE source read)

The single switch is **`CVidCell::m_bDoubleSize` (the cell field at +0xD6)**, consumed at **render time**:

```
CVidFont::TextOut @793720           (per glyph)
  GetCurrentFrameSize(size, FALSE)  -> RAW res frame (NATIVE w/h)  [advance x += size.cx]
  Render(nSurface, x, y, ...)       -> CVidCell::Render @7AEAD0
      GetFrame(FALSE)               -> m_pFrame = pRes->GetFrame(seq, frame, m_bDoubleSize)   <-- LEVER
                                        CResCell::GetFrame @77F520:
                                          if(m_bDoubleSize){ nCenterX*=2; nCenterY*=2; nWidth*=2; nHeight*=2; }
      Blt8To32 / sub_7AF1C0 ...     -> pixels via CResCell::GetFrameData @77F5F0:
                                        if(m_bDoubleSize) NN 2x2 expand (1 src px -> [0],[1],[pitch],[pitch+1])
      BltFromFX @7AEBxx             -> BltFast 1:1 (rSrc==rDest, NO stretch)
```

Key facts proven from `/home/wills/iwd2-re/src`:
- **`CResCell::GetFrame` (CResCell.cpp:62-71)**: `bDoubleSize` TRUE → returns `m_doubleSizeFrameEntry` with **w/h/centerX/centerY × 2**. FALSE → raw frame ptr.
- **`CResCell::GetFrameData` (CResCell.cpp:124-135)**: `bDoubleSize` TRUE → builds a **nearest-neighbour 2×2** pixel buffer (each src colour written to 4 dst px). FALSE → raw pixel ptr. *(This is the blocky doubling.)*
- **`BltFromFX` (CVidCell.cpp:1286)**: `rSrcSurface == rDest`, `BltFast` → **1:1, never scales.** So the FX→screen blit is NOT the doubler.
- **`GetCurrentFrameSize` (CVidCell.cpp:346)** reads the **raw** res frame (native), NOT the doubled entry. So **advance uses native width** while the **glyph bitmap is doubled** — consistent only if the BAM is native 1× (engine doubles both). ⇒ **author the BAM at 2× AND force `m_bDoubleSize=FALSE`** → advance = 2× native (correct), bitmap = sharp 2× (no NN re-expand).
- `CVidFont : public CVidCell` (CVidFont.h:24) — fonts use the **inherited** `m_bDoubleSize`; there is **no** separate font doubling field.

**Why clearing `bDoubleSize` at `SetResRef` did nothing to 2D (the old arc's dead end):** the flag is
consumed at *render* time, but it's *set* later/elsewhere — UI managers assign `cell.m_bDoubleSize =
g_pBaldurChitin->m_bUseNewGui` directly (e.g. `CCacheStatus.cpp`, `CScreenLoad.cpp:1039`), and the **3D**
`LoadToTexture` (CVidFont.cpp:768-863) save/restores it. So a one-shot clear at load is overwritten.
⇒ **clear it at the point of consumption (TextOut entry), not at load.**

---

## 2. Addresses & offsets (verified to MATCH the patched Heroic binary unless noted)

| What | Addr | Notes |
|---|---|---|
| `CVidInf::BKTextOut` | `0x79E340` | text-draw router (2D vs 3D) |
| `CVidFont::TextOut` (2D) | `0x793720` | **English UI text path**; → `Render`. prologue `83 EC 10 / 55 / 8B 6C 24 18` (steal 8 → 0x793728) |
| `CVidFont::TextOutEx` (2D) | `0x793A70` | non-empty `m_sFontName` path. steal 8 → 0x793A78 |
| `CVidCell::Render` (2D blit) | `0x7AEAD0` | called by TextOut; calls `GetFrame(FALSE)` → `pRes->GetFrame(...,m_bDoubleSize)`; FX→screen via `BltFromFX` (1:1, no scale) |
| `CResCell::GetFrame` | `0x77F520` | **DIM doubler**: `bDoubleSize` → w/h/center × 2 (CResCell.cpp:62-71) |
| `CResCell::GetFrameData` | `0x77F5F0` | **PIXEL doubler**: `bDoubleSize` → NN 2×2 expand (CResCell.cpp:124-135) |
| `CVidCell::BltFromFX` | `0x7AEBxx` | FX→screen `BltFast`, `rSrc==rDest` → never scales (CVidCell.cpp:1286) |
| `CVidFont::TextOut3d` (3D) | `0x7A1210` | NOT used (game is 2D) |
| `CVidFont::RenderCharacters` (3D) | `0x7A1660` | 3D atlas path, nScale = m_bDoubleSize?2:1 — NOT used |
| `CVidFont::SetResRef` | `0x793170` | font load; `__thiscall`, [esp+4]=`CResRef&`, [esp+8]=`bDoubleSize`. prologue `83 EC 08 53 8B 5C 24 10` (steal 8) |
| `m_bUseNewGui` | `pBaldurChitin+0x4A28` | 2× UI enable (BYTE). field `+0x4A2C`=1. Set by `IEex_Gui_State.lua` `InitHighResolutionPaddingPanels`, only at resW≥2048 & resH≥1200 |
| `CVidCell::m_bDoubleSize` | `+0xD6` | BOOL |

Recovered source lines (RE repo): `BKTextOut` src/CVidInf.cpp:1742 · `TextOut` 2D src/CVidFont.cpp:326 ·
`Render` src/CVidCell.cpp:939 · `SetResRef` src/CVidFont.cpp:202 · `TextOut3d`/`RenderCharacters`/`LoadToTexture` in src/CVidFont.cpp.

---

## 3. HD asset pipeline (DONE, works)

`/home/wills/iwd2-re/scripts/bam_font_pack.py` — packs a **sharp 2× HD BAM** from a real TTF:
```
.venv-reagent/bin/python scripts/bam_font_pack.py <in.BAM> <out.BAM> [--font ttf] [--tracking N] [--sheet preview.png]
```
- Face = **TeX Gyre Pagella (Palatino)** — `/usr/share/fonts/tex-gyre/texgyrepagella-regular.otf`
  (user pick; closest faithful to the original narrow Times-ish IE font; installed via `pacman tex-gyre-fonts`).
- Per-glyph advance = Palatino's **natural** advance (NOT orig_w×2 — that clips; Palatino word-width ≈ original so UI layout is preserved).
- Replicates the original **black-ink + white-halo** look (idx = round(coverage×255) into the orig palette, white1→black255 ramp).
- Outputs **BAMC** (zlib) = the format the game's Override BAMs use.
- Validated HD NORMAL preserved here: **`hd_fonts_wip/NORMAL.BAM`** (+ `NORMAL_preview.png`).
- Fonts to redo (BAMv1, ~255 glyphs, frame=char−1, cp1252): `NORMAL`(body) · `STONESML`(caps stone) ·
  `TOOLFONT` · `INFOFONT` · `REALMS`(display) · `NUMFONT` · `INITIALS`(drop-caps, decorative — defer).

---

## 4. IEex hook recipe — 6 hard-won lessons

1. **dword immediates need `#`**: `!cmp_eax_dword #4D524F4E` (bare = native crash). byte forms use bare hex.
2. **`IEex_WriteAssembly`/`AttemptHook` do NOT manage page protection** → must run inside
   `IEex_DisableCodeProtection()` … `IEex_EnableCodeProtection()`. Calling `DisableCodeProtection()`
   from a **late standalone `dofile`** (after `IEex_IWD2_Patch`) **faults**. → install hooks at the
   **end of `IEex_Gui_Patch.lua`, inside that file's existing Disable/Enable wrap** (before its
   `IEex_EnableCodeProtection()` / `end)()`).
3. `AttemptHook`/`HookRestore` patch a **JMP** (esp unchanged at hook entry). `__thiscall`: this=`ecx`,
   stack args `[esp+4]`,`[esp+8]`. After `!push_eax` (esp−4) those become `[esp+08]`,`[esp+0C]`.
   **`!marked_esp` is a no-op for the offset** here — use the literal current-esp offset. (The off-by-4
   that NULLed the resref ptr and crashed `mov eax,[ebx]` @0x79317A was exactly this.)
4. `print()` buffers unreliably (lost on crash). `io.open(append)+close` per step survives a crash.
   **But both can silently fail from a render-thread hook** (per-thread Lua state — see lesson 6).
5. IEexLoader **"error injecting IEex.dll"** is often a **downstream** symptom: (a) a native crash in
   `IEex.dll` Lua init = *your hook* (check `IEex.log`: did it reach "Executing IEex lua file" + your
   prints? + read `crash/IEex_*.dmp`); (b) a **degraded WeiDU install** (missing files → a **WeiDU
   reinstall** fixes it); (c) Wine/Proton injection flakiness.
6. Minidump: `sym.py crash` chokes on the Wine stream type `0xFFF0`. **Parse manually**: header `MDMP`,
   dir at off 0xC, find stream **type 6 = ExceptionStream** → `ExceptionAddress` (faulting EIP). That
   one read pinpointed the resref-NULL bug instantly.
7. **Trace blocker (unsolved):** the Debug `GenLuaCall` pattern (`IEex_Extern_Debug_LogButtonInvalidation`)
   is behind a default-`false` flag = untested; copying it did **not** call my extern from a render-thread
   hook (no `ZZFONT` in `IEex.log`). Next session: find an **active** `GenLuaCall`-with-args example
   (e.g. cnc-ddraw `IEex_Extern_CheckForceFullscreen` in `IEex_Render_Patch.lua` has the structure), or a
   pure-asm log, that works on the render thread.

---

## 5. Deploy / revert (when re-attempting)

Deployed to (DONE):
- HD BAM → `Override/NORMAL.BAM` (engine reads here) + `iwd2ee/bam/NORMAL.BAM` (game-dir source)
  + `/home/wills/IWD2EE/iwd2ee/bam/NORMAL.BAM` (git clone, branch `feature/ui-2x-scaling`).
- Hook → end of all **3** `IEex_Gui_Patch.lua`: `Override/` (runtime), `iwd2ee/ieex_override/`
  (game-dir source), `/home/wills/IWD2EE/iwd2ee/ieex_override/` (git) — inside the
  `DisableCodeProtection` wrap (before the final `IEex_EnableCodeProtection()`).
- NOT a separate `EX_*.lua` `dofile` (DisableCodeProtection faults late — lesson 4.2).
- **Not in the `.tp2`** → a WeiDU reinstall regenerates `Override/` and wipes it. The git clone copy
  persists the source; still TODO to formalize into the tp2 for a clean reinstall.

Revert (runtime): `rm Override/NORMAL.BAM` and delete the `[HD UI fonts]` hook block from
`Override/IEex_Gui_Patch.lua` (the `0x793720` AttemptHook). Same for the two source copies to fully back out.

**The DEPLOYED 2D hooks** (in all 3 `IEex_Gui_Patch.lua` copies, inside the DisableCodeProtection wrap,
before the final `IEex_EnableCodeProtection()`). **BOTH** 2D routers are hooked — `CVidInf::BKTextOut`
sends a control to `TextOut` when its `m_sFontName==""`, else to `TextOutEx`; the record/character
screen body text uses **`TextOutEx`** (button labels use `TextOut`), so one hook alone leaves the body 4×:
```lua
IEex_AttemptHook(0x793720,  -- CVidFont::TextOut (2D)
    {"!push(eax) !push(ecx) !pop(eax) !mov_eax_[eax+dword] #AC !cmp_eax_dword #4D524F4E !jne_dword >skip !push(ecx) !pop(eax) !mov([eax+0xD6],0) @skip !pop(eax)"},
    {"83 EC 10 55 8B 6C 24 18 !jmp_dword :793728"},
    {0x83, 0xEC, 0x10, 0x55, 0x8B, 0x6C, 0x24, 0x18})
IEex_AttemptHook(0x793A70,  -- CVidFont::TextOutEx (2D)
    {"!push(eax) !push(ecx) !pop(eax) !mov_eax_[eax+dword] #AC !cmp_eax_dword #4D524F4E !jne_dword >skip !push(ecx) !pop(eax) !mov([eax+0xD6],0) @skip !pop(eax)"},
    {"A1 D8 F6 8C 00 83 EC 1C !jmp_dword :793A78"},
    {0xA1, 0xD8, 0xF6, 0x8C, 0x00, 0x83, 0xEC, 0x1C})
```
`m_bDoubleSize@+0xD6` is now hard-confirmed from the `GetFrame@0x7B0980` call site (`mov eax,[esi+0xd6] / push eax` → `CResCell::GetFrame@0x77F520`). Both prologues verified in the live patched exe.
- `this`=ecx (CVidFont*). Read `dword[this+0xAC]` (base cResRef); if == `"NORM"` (0x4D524F4E) write
  `dword[this+0xD6]=0` (m_bDoubleSize=FALSE). eax saved/restored, ecx untouched, esp balanced, flags
  irrelevant to resume code. Steals 8-byte prologue (`sub esp,10 / push ebp / mov ebp,[esp+18]`),
  resumes @0x793728.
- **Verified:** `pRes@+0xA8` (∴ base `cResRef@+0xAC`) read from `GetFrame@0x7B0980` disasm;
  `m_bDoubleSize@+0xD6` (CVidCell.h, doc-confirmed); prologue bytes confirmed in the **live patched
  Heroic exe** via `sym.py bytes 0x793720` (`IWD2_EXE=<heroic>`), so `expectedBytes` match ⇒ applies.
- **Scope:** NORMAL only (other fonts fall through `>skip`, keep their doubling). `TextOutEx@0x793A70`
  NOT hooked — add the same block there if some NORMAL text routes through it.
- All `#disp`/store/cmp/jmp macro forms have direct precedent in `ieex_override/` (no novel asm).

Superseded ref — the old `SetResRef@0x793170` hook (`!mov([esp+0C],0)`): correct asm, but clearing
`bDoubleSize` at *load* gets overwritten before *render* (§1a). The TextOut hook clears at consumption.

---

## 6. Verify an address isn't IWD2EE-patched (the Heroic exe ≠ RE target)
```
.venv-reagent/bin/python - <<'PY'
r=open('/home/wills/iwd2-re/.bin/iwd2.exe','rb').read()
h=open('/home/wills/Games/Heroic/Icewind Dale 2/iwd2.exe','rb').read()
va=0x793720; off=va-0x754FE0   # VA->file delta (from SetResRef VA 0x793170 -> file 0x3e190)
print('repo', r[off:off+8].hex(' '), '| heroic', h[off:off+8].hex(' '),
      '| MATCH' if r[off:off+8]==h[off:off+8] else '| DIFFER (patched!)')
PY
```

---

## 7. NEXT SESSION (lever pinned — build the hook)

Step 1 (pin the lever) = **DONE**, see §1a. The switch is `CVidCell::m_bDoubleSize` (+0xD6),
consumed at render time by `CResCell::GetFrame`/`GetFrameData`.

1. **The clean hook = at the point of consumption, scoped to HD fonts.** Hook **`CVidFont::TextOut
   @0x793720`** entry (and **`TextOutEx @0x793A70`** for non-empty-fontname text): zero the cell's
   `m_bDoubleSize` at **`[ecx+0xD6]`** (`this`=ecx, `__thiscall`) *for our HD-font resref only*
   (filter on the cell's resref, like the old `"NORM"` cmp). This sets it FALSE right before
   `Render`→`GetFrame` reads it ⇒ native 1:1, no NN re-expand. Sidesteps the SetResRef-overwrite
   trap (§1a). The accidental-undouble proof (§1) already shows disrupting TextOut controls it.
   - Install per lesson 4.2: end of `IEex_Gui_Patch.lua`, inside its Disable/Enable wrap.
   - Alt (broader, simpler): if **all** UI fonts get 2× BAMs, drop the resref filter and zero
     `m_bDoubleSize` unconditionally in the font 2D path. Risk: any un-replaced font shrinks to 1×
     (incl. `INITIALS` drop-caps) — so keep the filter until every listed font is repacked.
2. **Author the 2× BAMs** for the §3 font list (NORMAL done) via `bam_font_pack.py`.
3. **Get a working render-thread trace** (lessons 6/7) to confirm `m_bDoubleSize` flips at runtime.
4. Deploy 2× BAM + hook; judge at a res where pixel sharpness shows (game renders small at test res).

Everything is preserved: packer (RE repo) + `hd_fonts_wip/NORMAL.BAM` + this doc + the
`feature/ui-2x-scaling` branch (now cloned to `/home/wills/IWD2EE`). The unlock = **it's the 2D path.**

---

## 8. FINAL SOLUTION (shipped — supersedes §5/§7 hook iterations)

Two parts: a **de-double hook** (engine) + a **correctly-authored 2× BAM** (asset). The hook went
through several wrong turns (per-variant `TextOut`/`TextOutEx`, then cell-level
`GetCurrentFrameSize`/`GetFrameSize`/`GetFrame`) because the flag is read on many paths, **some with
`GetResFrame` inlined** (e.g. `CUtil::SplitString` for word-wrap). The fix is the deepest convergence
point.

### 8a. Hook — at the `CResCell` resource chokepoint (in `IEex_Gui_Patch.lua`)
Every metric read (advance/line-height/center/wrap) and pixel fetch — inlined or not — funnels through
`CResCell::GetFrame`/`GetFrameData`. Zero the `bDoubleSize` **arg** there, scoped to the NORMAL
resource, so the 2× BAM is never re-doubled. Timing-independent (acts at the read, not the member).
```lua
-- this=ecx=CResCell*; m_pDimmKeyTableEntry @+0x10, its resRef first dword @+0; "NORM"=0x4D524F4E.
IEex_AttemptHook(0x77F520,  -- CResCell::GetFrame (metrics); bDoubleSize arg @[esp+0x0C] (->+0x10 after push)
    {"!push(eax) !mov(eax,[ecx+0x10]) !test_eax_eax !jz_dword >skip !mov(eax,[eax]) !cmp_eax_dword #4D524F4E !jne_dword >skip !mov([esp+10],0) @skip !pop(eax)"},
    {"8B 51 64 56 85 D2 !jmp_dword :77F526"}, {0x8B,0x51,0x64,0x56,0x85,0xD2})
IEex_AttemptHook(0x77F5F0,  -- CResCell::GetFrameData (pixels); bDoubleSize arg @[esp+0x08] (->+0x0C after push)
    {"!push(eax) !mov(eax,[ecx+0x10]) !test_eax_eax !jz_dword >skip !mov(eax,[eax]) !cmp_eax_dword #4D524F4E !jne_dword >skip !mov([esp+0C],0) @skip !pop(eax)"},
    {"83 EC 10 53 8B D9 !jmp_dword :77F5F6"}, {0x83,0xEC,0x10,0x53,0x8B,0xD9})
```
Offsets verified from disasm: `m_pDimmKeyTableEntry@+0x10`, `resRef@+0`; both prologues match the live
patched exe. NULL-guarded; resref-scoped so sprites/items/other fonts keep their doubling. (The 2× UI
itself = branch files `IEex_Gui_State.lua` + `IEex_Key_State.lua`, gate `resW≥2048 & resH≥1200`.)

### 8b. BAM — `bam_font_pack.py` (RE repo), two fixes that mattered
1. **Line-metric frames.** The engine reads control frames **0 & 1** for line metrics
   (`GetBaseLineHeight = GetFrameSize(seq0).cy`, `GetFontHeight = GetFrameSize(seq1).cy`), which drive
   `CUIControlTextDisplay` line spacing (journal/combat-log/dialogue). The old packer wrote blank
   control frames as `h=1` → line spacing 1px → multi-line text **collapsed**. Fix: scale the
   original's control-frame `h/cy` ×2 (orig 11/13 → 22/26).
2. **Size = original line box ×2** (not cap-height). `measure_cap_height` clips the probe glyph and
   under-reports, so the cap-based sizer overshot (~cap 25 = "too big"). `pick_font_size_by_lineheight`
   sizes the face so ascent+descent = `orig_line(13)×2 = 26` → cap lands ~18 = orig×2 = original
   font:UI ratio. `--size-scale` fine-tunes.
3. **Sub-pixel weight** (`--weight`). Pagella Regular reads lighter than the original (whose 9px
   strokes can't go below 1px). `--weight 0.25` adds a faux-bold via a supersampled stroke
   (render at ×4, stroke `round(weight×4)`, **BOX**-downsample — Lanczos rings and inflates each
   glyph's bbox). Picked by A/B ladder vs the original (`hd_fonts_wip/COMPARE_WEIGHT.png`).

**Shipped NORMAL recipe** (face = TeX Gyre **Pagella**, user pick over the closer-but-rejected Times clones):
```
.venv-reagent/bin/python scripts/bam_font_pack.py NORMAL_orig_raw.BAM NORMAL.BAM --scale 2 --weight 0.25
```
(Input = the stock `NORMAL.BAM` extracted from `Data/GUIfont.bif`, decompressed BAMC→BAM via the
KEY/BIFF reader; locator bif idx 3 file idx 2.)

### 8c. Remaining fonts (each needs its OWN face)
Only **NORMAL** is repacked. The others (`STONESML`=carved caps · `REALMS`=display/title · `INITIALS`
=drop-caps · `TOOLFONT` · `INFOFONT` · `NUMFONT`) are **different typefaces** from NORMAL — the
decorative ones especially (REALMS/INITIALS). So **don't blanket-Pagella**: for each, extract the stock
BAM (KEY/BIFF), render its glyph sheet, and run a candidate comparison (`COMPARE.png` workflow) +
weight ladder to pick the closest face, like NORMAL. Then repack (`--scale 2 --weight N --font …`).
Engine side: the `0x77F520`/`0x77F5F0` hooks already de-double any resref == `"NORM"`; widen the
filter per font (or drop it once all are repacked). Not in the `.tp2` yet → a WeiDU reinstall
regenerates `Override/` and wipes the runtime copy (git source persists).

### 8d. Tooltip box must scale with the HD `TOOLFONT` (separate subsystem)
The cursor/tooltip layer is **not** part of CUIManager's `m_bUseNewGui` 2× path. `CInfCursor::Initialize`
(`0x597020`) sets the `TOOLTIP` box **and** `TOOLFONT` with `bDoubleSize=FALSE`, and `CInfToolTip::Initialize`
(`0x597EE0`) hardcodes `field_5E4 = 256` (the 1× text-wrap budget) — so tooltips always rendered **1×**.
Fine until the HD `TOOLFONT` BAM made the glyphs 2×: the still-1× box (too short) + 256 budget (too
narrow) **clipped/truncated** the text. Fix = one hook at the `field_5E4` store `0x597F39`
(`mov word[esi+0x5E4],0x100`, 9 bytes `66 C7 86 E4 05 00 00 00 01`): when `m_bUseNewGui`
(`[g_pBaldurChitin+0x4A28]`, `g_pBaldurChitin=[0x8CF6DC]`) is set, force the box `CVidCell`
`m_bDoubleSize=TRUE` (`this+0xD6`, `BOOL`; `m_font` is at `+0xDA` so a dword write is safe) **and** write
`field_5E4 = 512`; else keep vanilla `256`/undoubled. `esi=this` at the site, `eax` saved/restored, the
original store is **not** re-run (we own the write → `restorePart = jmp :597F42`). The later cap measures
(`GetFrameSize 1/2` @`0x597F54`) then run with `m_bDoubleSize=TRUE`, so `field_5DE` caps scale too. The
box doubles via the engine's NN path (it's a flat dark panel → acceptable); author an HD `TOOLTIP.BAM`
later if the 2px border looks chunky. **Note** the 8-char resref filter is what lets this work: `TOOLTIP`
= `"TOOL"+"TIP\0"` ≠ `TOOLFONT` `"TOOL"+"FONT"`, so the de-double hook skips the box (it doubles) while
catching the font (it stays sharp-2×). A 4-char `"TOOL"` prefix would have de-doubled the box too.
