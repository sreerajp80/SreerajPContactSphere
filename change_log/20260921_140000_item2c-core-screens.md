# Item 2, phase 2c — Core screens moved to ARB

**Plan:** `plans/20260921_064200_item2-arb-string-externalization.md` (phase 2c of 2a–2g)
**Status:** done. Phases 2d–2g are not started and need approval before any work begins.

---

## What this phase did

Moved every user-visible string in the six core screens into the three ARB files, with Malayalam
and Sanskrit translations that use the glossary words approved in
`change_log/20260921_121000_glossary-contact-call-tag-phone-number.md` (വിലാസവിവരം, ഫോൺ വിളി,
അടയാളം).

| Screen | File |
|---|---|
| Recents (call history) | `lib/screens/call_history_screen.dart` |
| Dialer | `lib/screens/dialer_screen.dart` |
| In-call | `lib/screens/in_call_screen.dart` |
| Contact detail | `lib/screens/contact_detail_screen.dart` |
| Contact list | `lib/screens/contact_list_screen.dart` |
| Add / edit contact | `lib/screens/add_edit_contact_screen.dart` |

- **312 new keys**, so each ARB file now holds **513 keys**. The three files have the same key set.
- A search of the six screens finds no English UI text left in them. The only English words are
  saved preset values and the fixed reasons the phone validator returns (see below).

---

## Files changed

| File | Change |
|---|---|
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` | +312 keys each. |
| `lib/l10n/app_localizations*.dart` | Regenerated with `flutter gen-l10n`. |
| `lib/l10n/stored_labels.dart` | **New.** `storedLabelText(l10n, value)`, explained below. |
| The six screens above | All user-visible strings now come from `AppLocalizations`. |
| `lib/utils/call_type_mapper.dart` | `callOutcomeLabel` takes an optional `AppLocalizations`. Without it, it still returns English, so the existing unit tests and non-UI callers are unchanged. |
| `test/l10n/core_screens_l10n_test.dart` | **New.** Tests described under Verification. |
| `test/l10n/label_length_test.dart` | Eight English keys added to `_englishOverBudget` (see "Over-budget English"). |
| `test/dialer_keypad_legend_test.dart` | Its `MaterialApp` now registers the localization delegates the dialer needs. |
| `plans/20260921_064200_item2-arb-string-externalization.md` | Status line updated. |

Each converted screen was run through `dart format`, so some also carry small formatting changes
on lines this phase did not otherwise touch.

---

## Decisions made along the way

### Saved values stay English; only the shown text is translated

Several contact fields save a preset's English word, not a code: phone labels ("Mobile", "Home",
"Work", "Main", "Fax", "Other"), email labels ("Personal", "School"), the "Website" social label,
the gender presets ("Male", "Female", "Non-binary", "Prefer not to say"), and the address types
`personal` / `official`. Translating the saved value would break matching for every contact
already stored.

So the saved value is unchanged. The new `storedLabelText(l10n, value)` in
`lib/l10n/stored_labels.dart` turns a known preset into the label for the current language, and
returns anything else (a custom label the user typed, a brand such as "LinkedIn") unchanged.
The add/edit form uses it for the label menus and chips, and the contact detail page uses it for
the phone, email, social and address subtitles and for gender.

This also fixes a small existing bug: the detail page used to show a saved address type as the
raw code (`personal`, `official`). It now shows "Personal address" / "Work address".

Call topics saved from the post-call sheet are shown through `postCallIntentLabel` (added in
phase 2b), so Recents now shows them translated too.

### Suggested tags are saved in the language they are shown in

The add/edit form suggests starter tags (VIP, Mentor, Client, Investor, Neighbor, Family). Tags
are the user's own free text, so these suggestions are translated and saved as shown, like any
tag the user types. A user who switches language later keeps the tags they already have.

### Sentences are never built from a translated noun

The add/edit form used to build its remove prompts as `'Remove $noun?'`, putting an English noun
into an English sentence. That cannot work in Malayalam or Sanskrit, so each row type now has its
own whole title and body (`titleRemovePhone`, `descRemovePhone`, and the same for email and social
link). The in-call block dialog, previously one long English string, is now three translated
sentences joined in code.

### Phone validation reasons

`PhoneNormalizer.validateNumber` returns fixed English reasons ("Number is too short"…), and its
unit tests check that text. The validator is unchanged; the add/edit screen maps each reason to
a translated message.

### Dates and times

- The contact detail page and the add/edit form built dates from hand-written English month
  lists. Both now use `DateFormat(..., formattingLocale(...))`, so Malayalam shows Malayalam
  month names. Sanskrit falls back to English patterns, as item 1 decided.
- Recents: "Today" / "Yesterday", the relative times on the contact list ("3d ago") and the
  short call durations ("3m 5s") are now translated. Duration units are abbreviated in all three
  languages because the rows are crowded; the Sanskrit countdown on a temporary contact writes
  the units out in full (see "Sanskrit gate" below).

### Plurals

"contact(s)", "match(es)" and similar now use ICU plurals with an exact `=1` branch, so every
language reads correctly for one and for many. `intl` has no plural rules for Sanskrit; the exact
match is what makes the singular appear there.

### One layout fix found by the new tests

On a 360-pixel-wide phone, the contact list's All / Favorites filter row overflowed by a few
pixels in Malayalam, because a `Row` cannot give way. It is now a `Wrap`, so the second chip
moves to a new line only when it has to. It looks the same as before when both fit. No text is
shrunk or cut, as the standard requires.

### Small accessibility additions

The contact detail page's Edit icon and the country-code picker's Close icon had no tooltip.
Both now have one (standard §7.8 asks for a tooltip on every icon-only control).

### A few English wording tidy-ups

- The dialer's "Hide Keypad" button now reads "Hide keypad", matching the tooltip.
- "Deleted 3 contact(s)" / "Imported 3 contact(s)" now read "Deleted 3 contacts" / "Deleted 1
  contact".
- "No contact matches "x"." now uses curly quotes, like the rest of the ARB.

No test asserted the old wording.

---

## Left in English on purpose

| What | Why |
|---|---|
| Keypad letters (ABC, DEF…), "DTMF", "SIM 1", "vCard (.vcf)", "CSV", "SQLCipher", "Bluetooth", "Google", "WhatsApp" | Technical labels, formats and brand names that read the same in every language. |
| Social platform names (LinkedIn, X (Twitter), Instagram, Facebook, GitHub) | Brand names. |
| Field examples `555 0123` and `name@email.com` | Examples of a format, not words. |
| Country names in the country-code picker | They come from the phone-number library's data. Moving them needs a country-name source per language; left for a later phase. |
| Text written by services: the before-you-call "best time" sentence, the in-call caller-context headline, the scanned-QR safety report | They come from services, which move in their own phases. |
| Saved relationship types ("Father") and group names | The user's own data. |

---

## Over-budget English

Eight existing English labels are longer than the §8.6 limit of 20 characters. They are listed in
`test/l10n/label_length_test.dart` as known exceptions, like the 14 that were shortened earlier.
Every Malayalam and Sanskrit label fits the 22-character limit.

| Key | English | Length |
|---|---|---|
| `tooltipBackspace` | Backspace (hold to delete continuously) | 39 |
| `labelMeetiversaryDayYouMet` | Meetiversary · the day you met | 30 |
| `labelExpiryAfterOneCall` | Auto-delete after 1 call | 24 |
| `actionSmartRedialReachMe` | Smart Redial & Reach Me (feature name) | 23 |
| `actionSendAllViaBluetooth` | Send all via Bluetooth | 22 |
| `labelCallerIdNotVerified` | Caller ID not verified | 22 |
| `actionShareVcard` | Share as vCard (.vcf) | 21 |
| `tooltipRemoveFromFavorites` | Remove from favorites | 21 |

Whether to shorten them is a copy decision for the owner.

---

## Sanskrit gate

The §8.5.1 gate flagged two Sanskrit strings during this phase. Both were changed:

| Key | Flagged text | Why | Now |
|---|---|---|---|
| `descEphemeralCountdown` | `{hours} हो.` | The abbreviation for होरा (hour) reads as the Hindi word हो. | Units written out: `होराः`, `निमेषाः`, `क्षणाः`. |
| `actionChooseFromGallery` | `चित्रसङ्ग्रहात्` | False positive: सङ्ग्रह contains the letters रहा. | `चित्रकोशात् चीयताम्` |

(The third, `ग्रहीतुम्` in phase 2b, was the same kind of false positive.) The gate's substring
patterns flag real Sanskrit words that contain रहा / रही. Worth raising in the guidelines
repository so the standard can note it.

---

## Translations — needs native-reader review

The approved glossary words were used for Contact, Call, Tag and Phone number, and the §8.5.4
glossary for everything it covers. These terms are **not in the glossary** and repeat across
screens, so they are the ones to check first:

| English | Malayalam | Sanskrit |
|---|---|---|
| Ringtone | റിംഗ്ടോൺ | आह्वानध्वनिः |
| Mobile (phone label) | മൊബൈൽ | चलदूरभाषः |
| Fax | ഫാക്സ് | दूरप्रतिलिपिः |
| Non-binary | നോൺ-ബൈനറി | अद्विलिङ्गम् |
| Spam | സ്പാം | अवाञ्छितम् |
| Speaker (loudspeaker) | സ്പീക്കർ | ध्वनिवर्धकः |
| Mute / Hold | നിശ്ശബ്ദം / കാത്തുനിർത്തുക | मौनम् / स्थगनम् |
| Keypad | കീപാഡ് | सङ्ख्यापटलम् |
| Missed (call) | എടുക്കാത്തത് | अगृहीतम् |
| Address | വിലാസം | सङ्केतः |
| Ephemeral (temporary) contact | താൽക്കാലിക വിലാസവിവരം | अल्पकालिकः सम्पर्कः |
| Meetiversary | പരിചയ വാർഷികം | परिचयवार्षिकम् |
| Secret contacts | രഹസ്യ വിലാസവിവരങ്ങൾ | गुप्तसम्पर्काः |
| Duplicates | ഇരട്ടിപ്പുകൾ | द्विरुक्तानि |
| Hour / minute / second (abbreviated) | മ. / മി. / സെ. | होराः / नि. / क्ष. |

Proofreading also caught and fixed one mixed-script typo before it was saved: a Malayalam virama
inside a Sanskrit word. A script check over every Malayalam and Sanskrit value now finds no
mixing, apart from the two language names, which are meant to be in their own scripts.

---

## Verification

| Check | Result |
|---|---|
| `flutter analyze` | No issues found. |
| `flutter test` (whole suite) | 608 passed, 2 skipped, 0 failed. The two skips existed before. |
| `flutter test test/l10n/` | 53 passed, 1 skipped (phase 2g About-config group). |
| ARB key parity | 513 keys in each file; no untranslated copies. |
| §8.6 label budget | All Malayalam and Sanskrit short keys within 22 characters; English within 20 apart from the 8 listed. |
| §8.5.1 Sanskrit gate | Self-test passes; no markers in `app_sa.arb` or `app_config.json`. |
| `dart format` on every file this phase touched | Clean. |

`test/l10n/core_screens_l10n_test.dart` checks, in each of `en`, `ml` and `sa`:

- **The real app on a 360×740 phone:** the Contacts, Dialer and Recents tabs show their
  translated search hints and filter chips, with no English strings leaking into `ml` or `sa`.
- **`storedLabelText`:** translates the saved presets and leaves custom labels and brand names
  alone.
- **`callOutcomeLabel`:** stays English without `l10n`, and follows the language with it.

Contact detail, add/edit and in-call need a stored contact or a live call to open, so their
strings are covered by the parity and label-length tests rather than a pumped screen.

---

## What happens next

Phase 2d (the Settings tree: all `*_settings_screen.dart` plus `lib/screens/settings/`, roughly
180 keys) is next and **needs approval before it starts**. Before approving, it would help to
decide whether to shorten any of the 8 over-budget English labels above.
