# Voice dial: understand Malayalam / cross-script "call X" phrases

**Status:** completed

## The issue

Voice dialing a contact by name fails when the phone's speech recognizer is set
to Malayalam. Two real cases:

1. **User speaks English "Call Seetha".** The Malayalam recognizer transcribes the
   *sound* into Malayalam script: `കോൾ സീത` ("കോൾ" = call, "സീത" = sita). The
   parser in [voice_dial_parser.dart](../lib/utils/voice_dial_parser.dart) only
   strips English lead-in words (`call/dial/ring/phone` at
   [line 51](../lib/utils/voice_dial_parser.dart#L51)). It does not recognize
   `കോൾ` as "call", so the whole phrase `കോൾ സീത` is searched as a name. The
   search transliterates it to `kol sita`, which does not match the stored
   contact key `sita` → **"No contact matches"** (the reported screenshot).

2. **User speaks natural Malayalam "സീതയെ വിളിക്കൂ".** Here the call-verb
   `വിളിക്കൂ` is *last* (Malayalam puts the verb at the end), and the name
   carries an accusative case suffix: `സീതയെ` = `സീത` + `-യെ`. The parser drops
   only a *leading* command word, so nothing is stripped, and even if the verb
   were stripped, `സീതയെ` transliterates to `sitaye`, which still does not
   substring-match the stored key `sita`.

The search itself is fine — the app already stores a romanized `name_translit`
key and matches English-script queries against Malayalam names via `searchKey`
([contact_repository.dart:768](../lib/repositories/contact_repository.dart)).
The defect is entirely in how the spoken phrase is reduced to a bare name.

## The fix

Parts A + B are in the parser. Part C is a narrow, voice-only addition to the
repository search (existing typed search is untouched). No schema/DB change.

### Part A — cross-script lead-in words (fixes the reported case)

Expand `_leadIns` beyond English to include the Malayalam forms:

- `കോൾ` — the loanword a Malayalam recognizer produces for spoken English "call".
- `വിളി`, `വിളിക്ക്`, `വിളിക്കൂ`, `വിളിക്കണം` — native "call/summon" verb forms.
- `ഡയൽ` (dial), `ഫോൺ` (phone), `റിംഗ്` (ring).

So `കോൾ സീത` → drop `കോൾ` → `സീത` → `searchKey` → `sita` → matches. ✅

### Part B — trailing call-verb (natural Malayalam word order)

Malayalam puts the verb last. Add a `_trailingVerbs` set
(`വിളി/വിളിക്ക്/വിളിക്കൂ/വിളിക്കണം`) and, when there is more than one token,
drop a trailing verb the same way a leading one is dropped. So
`സീതയെ വിളിക്കൂ` → `സീതയെ`.

### Part C — stem (prefix) matching in the search, not suffix stripping

The earlier idea of stripping case suffixes in the parser is dropped. Instead we
match on the **stem**, which is the correct fix and needs no morphology rules.

**Why this works.** Malayalam case inflection only ever *appends* to the name
(it is agglutinative), and this survives transliteration: `searchKey("സീത")` =
`sita`, `searchKey("സീതയെ")` = `sitaie`. So the bare name's key is always a
**prefix** of any inflected form's key — for accusative, dative, genitive and
sociative alike. One prefix rule subsumes every case ending; no `mlmorph`, no
per-suffix list.

**What changes.** The parser does *nothing* extra for Part C (Parts A + B leave
`സീതയെ` as the name). The matching moves to the repository's voice lookup:

- Today's search matches `name_translit LIKE '%<queryKey>%'`, i.e. "does the
  stored key *contain* the spoken key?" For an inflected phrase (`sitaie`) that
  fails against the stored stem (`sita`).
- Add a **stem match**, computed token-wise in Dart (SQL can't cleanly tokenize
  a multi-word `name_translit`): a contact matches when **every** spoken name
  token has a stored name token where one key is a **prefix** of the other, with
  a **length guard of ≥ 3** key characters so short stems don't match everything.
- **Candidate prefilter (efficiency):** narrow rows in SQL first —
  `name_translit LIKE '<firstNChars>%' OR name_translit LIKE '% <firstNChars>%'`
  for each query token — then score the small candidate set in Dart. Avoids
  loading the whole book.
- **Ranking:** exact token match beats prefix match; a longer shared prefix
  beats a shorter one. The dialer already auto-fills on a single match and lists
  several, so ranking just orders that list.

**Scope of the behavior change (kept narrow).** The stem match is used only by
the dialer's voice path, and only as a **fallback**: `_onVoiceWords` first calls
the existing `searchContactSummaries` (unchanged — typed search and its results
are untouched); if that returns nothing, it calls the new stem search. So
`കോൾ സീത` is already solved by Part A (→ `സീത` → exact substring hit, no
fallback), and the stem fallback specifically rescues the natural-Malayalam
inflected form `സീതയെ വിളിക്കൂ` → `സീതയെ` → stem-matches `സീത`.

**Remaining limit (accepted):** names whose stem mutates *internally* via sandhi
(rare ം-ending nouns, e.g. മരം → മരത്ത്) are not covered by a prefix rule. An
edit-distance fallback could catch those later; it is **out of scope** here.

## Files to change

- `lib/utils/voice_dial_parser.dart` — expand `_leadIns` (Part A); add
  `_trailingVerbs` and trailing-verb removal (Part B). **No** suffix stripping.
- `lib/repositories/contact_repository.dart` — add a stem/prefix name-matching
  method (SQL prefix prefilter + Dart token-wise prefix scoring + ranking) for
  the voice path. Existing `searchContactSummaries` is left unchanged.
- `lib/screens/dialer_screen.dart` — in `_onVoiceWords`, fall back to the new
  stem search when `searchContactSummaries` yields no matches.
- `test/voice_dial_parser_test.dart` — parser cases: `കോൾ സീത` → name(`സീത`);
  `സീതയെ വിളിക്കൂ` → name(`സീതയെ`); existing English cases still pass.
- `test/` (repository) — a stem-match test: stored `സീത` is found by the key of
  `സീതയെ`/`സീതയോട്`; the ≥ 3-char guard holds; a non-matching name is not
  returned.

## Out of scope (noted, not changing now)

- Setting the recognizer locale (currently the device default). The
  transliteration/`name_translit` path is the app's deliberate cross-script
  strategy, so we lean on it rather than forcing an English locale.
- Auto-dialing on a confident single match (separate enhancement discussed
  earlier).
