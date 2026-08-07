# Critical review of docs/features.md — fill remaining gaps

**Status:** completed

## What the issue is

A fresh critical read of `docs/features.md`, checked directly against the code
in `lib/` and `android/.../kotlin` (every screen, every service, the native
Kotlin files, and `AndroidManifest.xml`), found the document is accurate on
substance — nothing it claims is fabricated, and no screen or service in the
code is left out entirely. Three small things still need fixing:

1. **Missing field in the contact field list.** Section 1 ("Contacts
   management") lists the fields you can set on a contact (name, phones,
   emails, birthday/anniversary, etc.) but leaves out **meetiversary date**
   (the day you met the contact) — a real, editable field
   (`add_edit_contact_screen.dart`, "Meetiversary · the day you met"). It is
   only mentioned once, in passing, under the device-sync section (as a
   field that stays local), so a reader looking at section 1 for "what can a
   contact hold" would miss it.

2. **Ephemeral contacts' background mechanism isn't named.** Section 1
   describes self-destructing contacts (expire after a set time or one call)
   but doesn't say this is enforced by a continuously-running background
   check (`EphemeralContactService`, a 60-second timer), which is a fact
   worth knowing (e.g. it means expiry isn't instant to the second, and it
   only runs while the app process is alive).

3. **The "What this app is" description undersells the app.** It currently
   reads as "contacts manager + dialer, encrypted local storage, default
   dialer role with call waiting/merge, device sync, phone-to-phone sync,
   backup/restore, multi-script T9" — accurate, but it leaves out several of
   the app's most distinctive "advanced" capabilities that are already
   documented in detail further down: relationship tracking with duplicate
   detection/merge, caller ID and spam-call blocking, and the security layer
   (app lock, secret contacts, an emergency-info card). Without a nod to
   these, the opening description reads more like "a synced dialer" than the
   fuller picture the rest of the file paints.

## Files to be changed

- `docs/features.md` only. No code changes.

## The plan for the fix

1. **"What this app is" (intro paragraph):** add one sentence naming the
   three missing pillars — relationship tracking with duplicate detection,
   caller ID/spam-call blocking, and app-lock/secret-contacts/emergency-info
   security — so the description matches the depth of the rest of the file.

2. **Section 1 (Contacts management), field list bullet:** add "meetiversary
   date" alongside birthday/anniversary.

3. **Section 1, ephemeral-contacts bullet:** add a short clause noting expiry
   is checked by a continuous background timer (about every 60 seconds)
   while the app is running.

No other section changes — everything else already matches the code.

## Why this shape

This is a documentation-only precision pass: two small factual omissions and
one description-completeness fix, found by reading the actual screens,
services, and native code rather than trusting the document's own prior
self-review. No new app behavior is implied or required.
