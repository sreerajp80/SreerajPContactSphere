# Voice dial: understand Malayalam / cross-script "call X" phrases

Implements plan
[plans/20260706_212719_voice-dial-malayalam-leadins.md](../plans/20260706_212719_voice-dial-malayalam-leadins.md).

## The problem

Voice-dialing a contact by name failed when the phone's speech recognizer was
set to Malayalam. Speaking English "Call Seetha" was transcribed phonetically into
Malayalam script as `കോൾ സീത` ("കോൾ" = call, "സീത" = sita). The dialer's voice
parser only stripped English lead-in words, so it searched the whole phrase
`കോൾ സീത`, which transliterates to `kol sita` and does not match the stored
contact key `sita` — the screen showed *No contact matches "കോൾ സീത"*. Natural
Malayalam phrasing (`സീതയെ വിളിക്കൂ`, verb last, name in the accusative) failed
for the same family of reasons.

## What changed

Three parts, matching the plan (Part C became stem matching, not suffix
stripping):

- **`lib/utils/voice_dial_parser.dart`**
  - **Part A** — `_leadIns` now includes Malayalam command words: the loanword
    `കോൾ` (how a Malayalam recognizer renders spoken English "call"), the native
    verb forms `വിളി/വിളിക്ക്/വിളിക്കൂ/വിളിക്കണം`, and `ഡയൽ/ഫോൺ/റിംഗ്`. A leading
    one is dropped, so `കോൾ സീത` → `സീത`.
  - **Part B** — added `_trailingVerbs` and drop a *trailing* Malayalam call-verb
    (Malayalam puts the verb last), so `സീതയെ വിളിക്കൂ` → `സീതയെ`. A lone verb is
    never removed (still treated as a name query).

- **`lib/repositories/contact_repository.dart`**
  - **Part C** — added `searchContactsByNameStem`, a stem (prefix) name matcher.
    Malayalam case endings only append to the name and this survives the
    romanized `searchKey` (`sita` is a prefix of `sitaie`), so a query name token
    matches a stored name token when one key is a prefix of the other, sharing at
    least `_stemMinLen` (3) characters. Candidates are prefiltered in SQL, scored
    token-wise in Dart (exact hits rank above prefix hits), and returned
    best-first. Existing `searchContactSummaries` is unchanged.

- **`lib/screens/dialer_screen.dart`**
  - `_onVoiceWords` now falls back to `searchContactsByNameStem` when the normal
    `searchContactSummaries` returns nothing. So `കോൾ സീത` is solved by Part A
    (exact hit, no fallback), and the inflected `സീതയെ വിളിക്കൂ` is rescued by the
    stem fallback. Typed search is untouched.

## Tests

- **`test/voice_dial_parser_test.dart`** — added: Malayalam lead-in dropped
  (`കോൾ സീത`, `വിളിക്കൂ സീത` → `സീത`); trailing verb dropped
  (`സീതയെ വിളിക്കൂ` → `സീതയെ`); a lone Malayalam command word stays a name query.
- **`test/contact_stem_search_test.dart`** (new) — accusative `സീതയെ`, sociative
  `സീതയോട്`, dative `സീതയ്ക്ക്` all resolve to stored `സീത`; an unrelated name is
  not returned; a sub-3-char stem matches nothing; an exact stem hit ranks above
  a prefix-only hit.

## Verification

- `flutter analyze` on all changed files — **clean, no issues**.
- `flutter test test/voice_dial_parser_test.dart test/contact_stem_search_test.dart`
  — **All 14 tests passed** (the 5 stem tests run against a real sqflite DB via
  `sqflite_common_ffi`).

**Full-suite run blocked by a toolchain bug (not this change):** on this Windows
setup `flutter test` intermittently crashes with
`PathExistsException: Cannot copy file to build\native_assets\windows\sqlite3.dll`
(`errno 183`) — a `flutter_tools` native-assets double-copy regression in
`_copyNativeCodeAssetsToBundleOnWindowsLinux`. It aborts the run before tests
execute and also crashes the untouched v13→v14 migration test, so it is
unrelated to these edits. The first full run (before the crash surfaced) reached
`+117 -1` (117 passing, the single failure being this crash). Workaround for a
clean run: run one sqlite-backed test file per `flutter test` invocation, or
delete `build\native_assets\windows\sqlite3.dll` between runs.

## Not done (as planned, out of scope)

- Edit-distance fallback for names whose stem mutates internally via sandhi
  (rare ം-ending nouns).
- Recognizer locale selection; hands-free auto-dial on a confident single match.
