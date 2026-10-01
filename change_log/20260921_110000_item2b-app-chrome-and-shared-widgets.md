# Item 2, phase 2b — App chrome and shared widgets moved to ARB

**Plan:** `plans/20260921_064200_item2-arb-string-externalization.md` (phase 2b of 2a–2g)
**Status:** done. Phases 2c–2g are not started and need approval before any work begins.

---

## What this phase did

Moved every user-visible string in the app's bottom bar and in all shared widgets under
`lib/widgets/` out of the Dart code and into the three ARB files, with real Malayalam and Sanskrit
translations.

- **177 new keys**, so each ARB file now holds **201 keys** (it held 24). The three files have the
  same key set.
- **1 screen** and **17 widget files** now read their text from `AppLocalizations`.
- **2 new test files** and **2 existing tests** updated.

### Scope decision: what "app chrome" meant here

The plan listed "app bar titles" under 2b. App bar titles live inside individual screens, and
converting only the title of a screen would leave that screen half English, half translated. So this
phase converted the chrome that is **shared**: the bottom navigation bar, the shared buttons
(`actionSave`, `actionDelete`, `actionClose`, `actionDone`, `actionTryAgain`, `actionSkip`,
`actionContinue`, `actionChange`, `actionAdd`, …), and every widget in `lib/widgets/`. Each screen's
own title moves together with the rest of that screen in phases 2c–2f.

---

## Files changed

| File | Change |
|---|---|
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` | +177 keys each. English entries carry an `@key` description; placeholders are typed. |
| `lib/l10n/app_localizations*.dart` | Regenerated with `flutter gen-l10n` (generated files are committed, policy Option A). |
| `lib/screens/home_shell.dart` | The four bottom-bar labels, the exit-swipe snackbar, and the add-call banner and tooltip. |
| `lib/widgets/tag_actions_sheet.dart` | Rename / merge / delete sheet and its three dialogs. |
| `lib/widgets/post_call_feedback_sheet.dart` | The "How did it go?" sheet. See "Saved values stay English" below. |
| `lib/widgets/smart_redial_sheet.dart` | Call-unanswered sheet and the Alarms & reminders dialog. The hand-built "7:23 PM" clock text is replaced by `MaterialLocalizations.formatTimeOfDay`, which follows the language and the phone's 24-hour setting. |
| `lib/widgets/ble_share_dialog.dart` | Bluetooth send dialog, all statuses and errors. |
| `lib/widgets/ble_receive_challenge_dialog.dart` | The consent, fingerprint and PIN dialogs, including the reason text shown in the system fingerprint prompt. |
| `lib/widgets/business_card_review_sheet.dart` | Scanned-card review sheet. Row labels are now looked up when drawn, so they follow the language. |
| `lib/widgets/relationship_editor.dart` | The editor's own chrome (see "Left for later" for category names). |
| `lib/widgets/air_qr_share_dialog.dart`, `qr_share_dialog.dart`, `contact_qr_preview_dialog.dart` | QR share and scanned-QR preview dialogs. |
| `lib/widgets/contact_search_picker_sheet.dart`, `contact_multi_picker_sheet.dart` | Contact pickers. The single picker's `title` is now nullable and defaults to the translated "Choose a contact". |
| `lib/widgets/voice_input_button.dart` | `tooltip` is now nullable and defaults to the translated "Voice search". |
| `lib/widgets/default_dialer_card.dart`, `sim_picker_sheet.dart`, `number_picker_sheet.dart`, `call_lifecycle_mixin.dart` | Remaining strings. The call mixin now checks `mounted` before showing its two error snackbars. |
| `test/l10n/label_length_test.dart` | **New.** The standard §8.6 short-label budget test (proposed in the 2a change log). |
| `test/l10n/shared_widgets_l10n_test.dart` | **New.** Tests in `en`, `ml` and `sa`, described under Verification. |
| `test/contact_search_picker_sheet_test.dart`, `test/dialer_speed_dial_keypad_test.dart` | Their `MaterialApp` now registers the app's localization delegates, which the converted widgets need. One expected string changed from straight quotes to curly quotes (see below). |
| `plans/20260921_064200_item2-arb-string-externalization.md` | Status line updated. |

Each converted file was run through `dart format`, so a few of them also carry small formatting
changes on lines this phase did not otherwise touch.

---

## Decisions made along the way

### Saved values stay English

The post-call topic chips ("Work", "Family", …) save the chip's English word into
`call_logs.call_intent`. Translating the saved value would break matching on existing rows. So
the saved value is unchanged. Only the label on the chip is translated, through a new public
helper `postCallIntentLabel(l10n, intent)`. Later phases should use that helper wherever a saved
topic is shown. The tone buttons already saved `positive` / `neutral` / `negative` codes, so only
their labels changed.

### Counts use `=1`, not `one`

Plural messages (`labelContactCount`, `msgTagMerged`, `titleSendContacts`, `actionAutoRetryIn`,
`labelMinutesShort`) use an exact `=1{…}` branch. `intl` has no plural rules for Sanskrit, so a
`one{…}` branch would never be picked for `sa`. An exact match on 1 works in every language. The
widget test checks that `sa` prints "एकः सम्पर्कः" for one contact and "4 सम्पर्काः" for four.

### Things deliberately left in English or ASCII

| What | Why |
|---|---|
| The Bluetooth advertised name `"N contacts"` (`ble_share_dialog.dart`) | The advertiser cuts it to 13 UTF-8 bytes, which is only about four Malayalam or Devanagari letters. The dialog *title* is translated. |
| `"SIM 1"`, `"SIM 2"`, `"5 FPS"` | Technical labels that read the same in every language. |
| `'this contact'` default parameters (`call_lifecycle_mixin.dart`, `smart_redial_sheet.dart`) | Never shown. Every caller passes a real name. |
| `{error}` inside error messages | The technical reason from the exception. The sentence around it is translated. |
| "Bluetooth", "PIN", "SIM", "QR", "AirQR", "SreerajP Contacts Sphere" | Brand names, acronyms and the app name. |

### Android permission names inside messages

Two messages quote an Android permission ("Nearby devices", "Alarms & reminders") so the user can
find it in the phone's settings. The Malayalam text uses the name Android shows in Malayalam. Android
has no Sanskrit interface, so the phone will show English there, and the Sanskrit text keeps the
English permission name in quotes.

### Straight quotes to curly quotes

"No contacts match "x"." became "No contacts match “x”.", following the curly-quote style that
phase 2a set in the ARB (for example "doesn’t"). The one test that asserted the old text was updated.

### The Sanskrit purity gate and a false positive

The §8.5.1 grep gate matches the Hindi ending `रही` anywhere in a word, and the Sanskrit infinitive
`ग्रहीतुम्` (to receive) contains those letters. The word was replaced with `स्वीकर्तुम्` (to
accept), which the same dialog already uses, and the gate now passes. Worth noting in the standard:
the gate's substring patterns can flag real Sanskrit.

---

## Translations — needs native-reader review

Standard §8.5.4 terms were used wherever the glossary has them (Save, Delete, Cancel, Close, Done,
Add, Share, Import, Settings, Search, Skip, Continue, Retry, Name, Email, Link, Notes, Yes/No …). The
terms below are **not in the glossary** and set a pattern the remaining phases will repeat, so a
fluent reader should check these first:

| English | Malayalam | Sanskrit | Note |
|---|---|---|---|
| Contact / Contacts | കോൺടാക്റ്റ് / കോൺടാക്റ്റുകൾ | सम्पर्कः / सम्पर्काः | Malayalam uses the everyday loanword (as Android's own Malayalam does). The native `ബന്ധങ്ങൾ` would clash with this app's Relationships feature. **Suggest adding to the glossary.** |
| Call (noun) | കോൾ | आह्वानम् | Follows phase 2a. |
| Tag / Tags | ടാഗ് / ടാഗുകൾ | चिह्नम् / चिह्नानि | |
| Dialer (tab) | ഡയലർ | आह्वानपटलम् | Malayalam is a loanword. A reviewer may prefer another word. |
| Recents (tab) | സമീപകാലം | इतिवृत्तम् | Sanskrit reuses the glossary's "History". |
| Merge | ലയിപ്പിക്കുക | एकीक्रियताम् | "Let it be made one". |
| Rename | പേരുമാറ്റുക | नाम परिवर्त्यताम् | Two words in Sanskrit; §8.6 prefers one. |
| Phone (device) | ഫോൺ | दूरभाषः | Follows phase 2a. |
| Auto-retry | സ്വയം വീണ്ടും വിളിക്കൽ | स्वचालितपुनराह्वानम् | |
| Minute(s) | മിനിറ്റ് | निमेषः / निमेषाः | |
| Transfer (Bluetooth) | കൈമാറ്റം | प्रेषणम् | |
| Decline / Accept | നിരസിക്കുക / സ്വീകരിക്കുക | प्रत्याख्यायताम् / स्वीक्रियताम् | |
| Authenticate | സ്ഥിരീകരിക്കുക | प्रमाणीक्रियताम् | Malayalam shares the verb with the glossary's "Confirm". |
| Default (SIM, phone app) | സ്വതവേയുള്ള | मुख्यम् / मुख्यः | Follows phase 2a's `मुख्यः दूरभाषानुप्रयोगः`. |
| Post-call moods: Great / Okay / Rough | നന്നായി / കുഴപ്പമില്ല / മോശം | उत्तमम् / मध्यमम् / कष्टम् | |
| Post-call topics: Catch-up / Scheduling / Follow-up / Urgent | കുശലം / സമയക്രമീകരണം / തുടർനടപടി / അടിയന്തരം | कुशलप्रश्नः / समयनिर्धारणम् / अनुवर्तनम् / आत्ययिकम् | |
| Postal code | പിൻകോഡ് | पत्रालयसङ्केतः | Avoided `डाक`, which is Hindi. |
| Dismiss | അവഗണിക്കുക | उपेक्ष्यताम् | |

Prose keys (`desc…`, `error…`, `empty…`, `msg…`, `hint…`) are full sentences. Sanskrit prose ends
with a daṇḍa `।`. They should be read for naturalness, not only for correctness. The Sanskrit
agreement in "न कोऽपि सम्पर्कः प्राप्तः" and similar lines was checked (सम्पर्कः is masculine).

---

## Left for later (not in 2b scope)

1. **Text that services write.** The scanned-QR safety report (`report.summaryMessage`,
   `detectedSignals`), the contact-suggestion reasons (`s.peer.reason`), the relationship category
   names, and relationship types such as "Father" all come from services or models, not widgets.
   They move with the phases that convert those services and screens (2c–2e).
2. **The default reach-me SMS text** (`AppSettings.defaultReachMeMessage`) is a user-editable
   setting. It belongs to the settings phase (2d).
3. **14 English chrome strings are over the 20-character budget**: 13 from this phase and
   `labelBlockUnknownCallers` from phase 2a. They were already that long before they moved into
   the ARB. `test/l10n/label_length_test.dart` lists them in `_englishOverBudget`. The list can only
   shrink: if one is shortened, the test tells you to remove it. Shortening them is a copy decision.
   Every Malayalam and Sanskrit short string fits the 22-character budget.
4. **Two existing layout issues, found by the new tests, that also happen in English:**
   - At 320×640 with 1.6× text (the size the 2a pilot used), the Bluetooth consent dialog and the
     SIM and number pickers overflow in English. The new tests check at 360×740 with 1.3× text,
     where English, Malayalam and Sanskrit all fit.
   - Flutter's debug check "ListTile background color or ink splashes may be invisible" fires
     for the post-call sheet's switch row and the SIM picker's rows, because each `ListTile` sits
     inside a coloured `DecoratedBox`. It is a debug-only warning, not a crash.

   Both are layout fixes and need their own small plan.
5. **The phase 2a pilot test still carries its test-only Sanskrit fallback delegates.** Item 3
   shipped the real ones in `lib/l10n/sa_material_localizations.dart`, and the new test uses those.
   The shim in `test/l10n/blocked_numbers_screen_l10n_test.dart` can be deleted in a small follow-up.
6. **Font rendering** cannot be checked in a widget test (the test engine draws every letter as a
   box). A bottom-bar label that wraps onto two lines in Malayalam or Sanskrit on a small phone
   would only show up on a device. Stays on the manual release checklist (§8.3.3).

---

## Verification

| Check | Result |
|---|---|
| `flutter analyze` | No issues found. |
| `flutter test` (whole suite) | 601 passed, 2 skipped, 0 failed. The two skips existed before this phase. |
| `flutter test test/l10n/` | 46 passed, 1 skipped (the phase 2g About-config group). |
| ARB key parity | 201 keys in each of `app_en.arb`, `app_ml.arb`, `app_sa.arb`; no untranslated copies. |
| §8.6 label budget (`label_length_test.dart`) | All Malayalam and Sanskrit short keys within 22 characters; English within 20 apart from the 14 listed exceptions. |
| §8.5.1 Sanskrit Hindi-marker gate | Self-test passes; no markers in `app_sa.arb` or `app_config.json`. |
| `dart format` on every file this change touched | Clean. |

The new widget test checks these things in each of `en`, `ml` and `sa`:

- **The real app's bottom bar** shows the translated tab names, and none of "Dialer", "Recents"
  or "Tags" leaks into `ml` or `sa`.
- **The post-call sheet** shows translated moods and topics and has no layout overflow. Picking the
  translated "Work" chip still saves the English value `Work`.
- **The SIM and number pickers** and **the Bluetooth consent dialog** show translated text with no
  English leaking through and no layout overflow.
- **Every plural message** gives a correct result for 1 and for more than 1.

---

## What happens next

Phase 2c (core flows: contact list, contact detail, add/edit contact, dialer, call history, in-call;
roughly 200 keys) is next and **needs approval before it starts**. Before approving, it would help
to decide:

1. Whether to add "Contact", "Call", "Tag" and "Phone number" to the §8.5.4 glossary as used here.
2. Whether to shorten any of the 14 over-budget English labels.
