# Remove real contact names and phone numbers from `plans/` and `change_log/`

**Status:** completed

## The issue

Many plan and change-log files quote **real data from the user's own address book** —
real people's names (Malayalam and Latin script), real business/contact names, and real
phone numbers. These files are checked into git, so the data is public to anyone with
repo access.

A full scan of `plans/*.md` and `change_log/*.md` found:

* **8 real phone numbers**, in 13 files.
* **~30 real contact names**, in 24 files.

Fake/documentation numbers (`9876543210`, `5551234567`) and generic
example names (`Ramesh` / `രമേഷ്`, `Anu` / `അനു`, `Amma` / `അമ്മ`, `Ammu`, `Ajay`) are
**not** personal data and stay. Malayalam *language* words used to explain the script
(`കോൾ` = call, `വിളിക്കൂ`, `ഡയൽ`, `ഹോസ്പിറ്റൽ`, letters, vowel signs, `മരം`) also stay.
The app author string `"Sreeraj P"` inside `app_config.json` snippets stays — that is
app metadata, not a contact.

## What will be removed

### A. Phone numbers (real)

This document deliberately does **not** repeat the values being removed — that would
just move the leak here. Each row names the number only by where it appeared.

| Number | Files |
| --- | --- |
| number A (national + `+91` forms) | plans 20260701_221400, 20260701_221932, 20260703_091109, 20260703_091833; change_log 20260701_222900 |
| numbers B and C (the KEEP-vs-others pair) | plans 20260701_205704; change_log 20260701_205704 |
| number D (second number of a two-SIM contact) | plans 20260703_091833 |
| number E (incoming caller ID) | plans 20260703_120832 |
| numbers F and G (the 7-digit collision pair) | plans 20260711_165449; change_log 20260711_170801 |
| number H (triplicated Recents row) | plans 20260805_080000 |
| number I (outgoing call-log sample) | plans 20260806_184304 |

(`1044498166` in plans 20260711_084625 is a key fingerprint, not a phone number — kept.)

### B. Contact names (real)

Again, the names themselves are not repeated here — only what each was and where.

| What it was | Files |
| --- | --- |
| a two-word Malayalam personal name (the duplicate-merge case) | plans 20260701_205704, 20260701_211428; change_log 20260701_211428 |
| a short Malayalam nickname, plus its case-inflected forms and romanizations | plans 20260703_091109, 20260703_091833, 20260703_092741, 20260703_124905, 20260705_111843, 20260706_212719; change_log 20260703_092352, 20260705_113716, 20260706_221327 |
| a Malayalam personal name shown on an incoming call | plans 20260703_120832 |
| the owner's own name, used as a contact row | plans 20260703_124905 |
| two Malayalam personal names in the stale-search-key example, plus a stale key derived from one | plans 20260706_211951; change_log 20260706_212800 |
| a Latin doctor's name and two Malayalam nicknames for one relative | plans 20260717_205448, 20260805_061744; change_log 20260717_213958 |
| four given names used in the transliteration tables (Latin + Malayalam spellings), and three surnames in a loose-code example | plans 20260725_061214, 20260730_102300; change_log 20260725_065016 |
| a business contact name and two Malayalam given names in the avatar-initial tests | plans 20260729_063000; change_log 20260729_063000 |
| a Malayalam given name plus surname, two trade-name business contacts, and a Malayalam surname | plans 20260730_181113, 20260806_194300; change_log 20260730_181113 |
| four hospital business contacts, one Malayalam given name + surname, and two more business rows | plans 20260806_194300 |
| six Malayalam personal names and one Latin name from the Soundex-collision examples | plans 20260805_040000, 20260805_075917, 20260806_160055; change_log 20260805_040000, 20260806_160055 |
| a business contact name in a Recents screenshot | plans 20260805_080000 |

Also removed: a contact's row id, birth date and anniversary in plans 20260705_111843 /
change_log 20260705_113716 — the id and dates point back at the same real person.

## How it will be replaced

Per your choice, the default is a **redaction marker**: `[name]` for a name, `[phone]`
for a number, numbered (`[name-1]`, `[name-2]`, `[phone-1]`) when a paragraph needs to
tell two of them apart.

**One flagged exception.** In about eight files the name or the digits *are* the
technical point, and a bare `[name]` would destroy the explanation:

* the transliteration tables — the point is which letters produce which key;
* the avatar-initial bug — the point is that `കൊ` is a split vowel sign;
* the 10-digit collision example — the point is that two numbers share their last
  7 digits;
* the country-code example — the point is a national number matching its `+91` form;
* the Malayalam case-inflection example — the point is that `-യെ` only appends.

For those I substitute a **generic, non-contact example** instead of a marker: stock
stand-in names (`സീത` / `Seetha`, `Michael` / `മൈക്കിൾ`, `Suresh` / `സുരേഷ്`,
`Thomas` / `തോമസ്`, `Kumar` / `കുമാർ`), and clearly-fake numbers in the `9876543210`
/ `90001234xx` range. Every stand-in's transliteration and phonetic keys are
**recomputed with the project's own `searchKey` / `phoneticCode`** so the tables stay
factually correct. Every such spot is listed in the change log.

If you would rather have `[name]` / `[phone]` even where it breaks the example, say so
and I will do that instead.

## Files to be changed

**plans/ (24)**

- `20260701_205704_choose-keep-contact.md`
- `20260701_211428_default-untick-same-name.md`
- `20260701_221400_incoming-call-caller-id-country-code.md`
- `20260701_221932_default-country-number-normalization.md`
- `20260703_091109_dialer-tap-false-add-to-contacts.md`
- `20260703_091833_multi-number-call-picker.md`
- `20260703_092741_multi-number-load-full-list.md`
- `20260703_120832_incoming-call-notification-name.md`
- `20260703_124905_relationship-sphere-dedup-and-menu.md`
- `20260705_111843_contact-detail-missing-fields.md`
- `20260706_211951_rebuild-name-translit-migration.md`
- `20260706_212719_voice-dial-malayalam-leadins.md`
- `20260711_165449_missed-call-name-mirror.md`
- `20260717_205448_merged-duplicates-reappear.md`
- `20260725_061214_search-fixes-and-group-picker.md`
- `20260729_063000_avatar-initial-overflow.md`
- `20260730_102300_emergency-picker-search.md`
- `20260730_181113_search-malayalam-english-fixes.md`
- `20260805_040000_fix_phonetic_duplicate_false_positives.md`
- `20260805_061744_stable_id_for_merged_duplicates.md`
- `20260805_080000_recents_menu_and_dup_contact_fixes.md`
- `20260806_160055_duplicate-detection-doc-and-labels.md`
- `20260806_184304_call-outcome-error-mapping.md`
- `20260806_194300_search-relevance-ranking.md`

**change_log/ (12)**

- `20260701_205704_choose-keep-contact.md`
- `20260701_211428_default-untick-same-name.md`
- `20260701_222900_default-country-number-normalization.md`
- `20260703_092352_multi-number-call-picker.md`
- `20260705_113716_contact-detail-missing-fields.md`
- `20260706_212800_rebuild-name-translit-migration.md`
- `20260706_221327_voice-dial-malayalam-leadins.md`
- `20260711_170801_missed-call-name-mirror.md`
- `20260717_213958_merged-duplicates-reappear.md`
- `20260725_065016_search-fixes-and-group-picker.md`
- `20260729_063000_avatar-initial-overflow.md`
- `20260730_181113_search-malayalam-english-fixes.md`
- `20260805_040000_fix_phonetic_duplicate_false_positives.md`
- `20260806_160055_duplicate-detection-doc-and-labels.md`

Plus one new file: `change_log/<timestamp>_redact-pii-from-docs.md`.

No source code, tests, or `docs/` files are touched by this plan.

## Verification

After editing, re-run the same scans and confirm they come back clean:

1. Phone scan — regex for 10-digit / `+91…` numbers across both folders; only the
   documentation numbers and the key fingerprint should remain.
2. Name scan — grep for every name in section B; zero hits.
3. Read each edited paragraph to confirm it still makes sense.

## Not in scope

* `docs/`, source code, tests, and `assets/` — not scanned by this plan. If you want
  those checked too, that is a separate pass. (Note: git history will still contain the
  old text; scrubbing history is also a separate, more invasive job.)

---

**Do you approve this plan?**
