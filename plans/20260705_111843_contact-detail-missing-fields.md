# Contact detail screen: stored fields not displayed

**Status:** completed

## Issue

The contact detail screen ([lib/screens/contact_detail_screen.dart](../lib/screens/contact_detail_screen.dart))
renders only a subset of what the app stores and hydrates. `ContactRepository.getContactById`
loads the full aggregate (phones, emails, addresses, social links, groups, tags, official
details, relationships, plus all scalar columns), and the add/edit screen lets the user enter
all of these — but `build()` never renders:

- **Birthday (`dob`)**
- **Anniversary (`anniversary`)**
- **Meetiversary (`meetiversary`)**
- **Gender (`gender`)**
- **Blood group (`bloodGroup`)**
- **Social links (`socialLinks`)** — hydrated but never shown at all
- **Tags (`tags`)** — hydrated but never shown (groups are shown as chips; tags are not)

Verified against the live database on the connected phone (`ZD222DXJ65`, package
`in.sreerajp.contact_sphere.dev`, `smart_contacts.db`): the contact in the report
([name]) has both a `dob` and an `anniversary` stored, and neither
appears on the screen. Other contacts have social links stored (e.g. a Facebook
URL) that are likewise invisible.

Secondary display bug visible in the same screenshot: an address whose fields are all
empty (the contact's "official" address row) renders a blank tile with only the type label,
because `Address.formatted` returns an empty string and the tile is built unconditionally.

## Files to change

- `lib/screens/contact_detail_screen.dart` — the only file.

## Fix

In the detail `ListView`, following the app's existing tile style (leading icon,
title = value, subtitle = label):

1. **Dates** — after the addresses block, add tiles for:
   - Birthday (`Icons.cake_outlined`) when `dob != null`
   - Anniversary (`Icons.favorite_outline`) when `anniversary != null`
   - Meetiversary (`Icons.handshake_outlined`) when `meetiversary != null`
   Format as e.g. `19 March 1980` with a small local formatter (no new dependency).
2. **Personal facts** — tiles for Gender (`Icons.person_outline`) and Blood group
   (`Icons.bloodtype_outlined`) when non-empty.
3. **Social links** — one tile per `socialLinks` entry (`Icons.link`), title = value,
   subtitle = label (e.g. "LinkedIn"), rendered next to the email/address contact info.
4. **Tags** — a chip `Wrap` like the existing groups chips, only when `tags` is non-empty,
   visually distinguishable from groups (e.g. `#tag` text or a leading label).
5. **Empty-address guard** — skip address tiles whose `formatted` is empty (show the
   type label only if there is content to title the tile with).

No schema, repository, or model changes; this is purely rendering already-loaded data.

## Out of scope

- The stray empty "official" address row in the data itself (edit-screen behaviour of
  persisting empty address forms) — can be a follow-up if wanted.
- `relationshipScore`, `isSecret`, `deviceId`, timestamps — internal fields, deliberately
  not surfaced.
