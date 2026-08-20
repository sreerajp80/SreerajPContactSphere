# Plan: Update Features & Help Cards in Settings

**Timestamp:** 2026-08-20 19:16:01 +05:30
**Target:** SreerajP Contacts Sphere (Flutter Android App)

---

## 1. Overview & Objective
Update the **Features** and **Help** sections under Settings so that:
1. The **Features** screen provides a comprehensive, easy-to-understand catalog of every implemented feature in the app, written in friendly, plain English with highlight tags and appropriate icons.
2. The **Help** section is expanded to cover all major capabilities, common user workflows, and answers to maximum user questions/FAQs (including calling, screening/blocking, contact sharing/scanning, privacy/security, duplicate merging, quiet hours, and troubleshooting).

---

## 2. Issues & Current State
- `lib/screens/features_screen.dart` currently covers a subset of features and misses some newly implemented capabilities (such as Spoken Caller ID, Quick Reject SMS, Relationship Quiet Hours, Contact Merging & Deduplication, Screenshot Guard, Audit Logging, and Group/SIM Ringtones). Descriptions can also be further simplified for everyday users.
- `lib/screens/help/help_home_screen.dart` currently only links to 8 help articles focusing mostly on sync, emergency info, biometrics, and T9.
- Users lack dedicated help guides for:
  - Smart Calling, In-Call Controls, Spoken Caller ID & Smart Redial
  - Call Screening & Blocking Spam
  - Contact Sharing & Scanning (QR Codes, On-Device Business Card OCR, Offline Bluetooth LE)
  - Duplicate Contacts Detection & Merging
  - Security, App Lock, Secret Contacts & Screenshot Guard
  - Comprehensive FAQs & Troubleshooting Guide

---

## 3. Proposed Fix & Changes

### A. Update `lib/screens/features_screen.dart`
Organize all implemented app features into 8 clean, logical categories with normal-user friendly descriptions:
1. **Smart Dialer & Calling**: T9 Multi-Script Search (Malayalam/English/Devanagari), Editable Dialer Input, Top Contacts Quick Strip, Dual-SIM Call Selector, Smart Redial & "Reach Me" SMS, Spoken Caller ID, Quick Reject SMS Replies.
2. **In-Call & Caller Intelligence**: In-Call Controls (Mute, Speaker, Hold, Keypad, Swap, Conference Merge), Live Relationship Context Cards, Pre-Call & Follow-Up Reminders, Post-Call Voice/Text Notes.
3. **Contact Management & Relations**: Rich Profiles (Multi-Phone, Email, Addresses, Birthdays/Anniversaries), 7 Relationship Spheres, Relationship Quiet Hours (DND filter), Tagging & Groups, Duplicate Contact Detection & Smart Merge.
4. **Privacy, Security & Vault**: Secret Contacts Vault, Biometric & App PIN Lock, Screenshot Guard, Security Audit Log.
5. **Instant Contact Sharing & Scanning**: vCard QR Code Sharing & Built-In Scanner, Paper Business Card OCR Scanner (On-Device), Offline Bluetooth LE Share.
6. **Data Sync & Backup**: Device Contacts & Call Log Bi-directional Sync, Local Wi-Fi Direct (P2P) Sync, Encrypted Cloud Sync & Google Drive Backup, Offline Encrypted Backup & Restore.
7. **Call Defense & Spam Blocking**: Automatic Background Call Screening, Blocked Numbers Manager.
8. **Personalization & Accessibility**: Dynamic Themes & Accent Color Engine, Per-SIM & Relationship Group Ringtones, Default Country Code Auto-Formatting.

### B. Create New In-Depth Help Screens
1. `lib/screens/help/call_management_help_screen.dart`:
   - Explains how in-call controls, dual-SIM calling, conference calls, smart redial, and spoken caller announcements work.
2. `lib/screens/help/call_screening_help_screen.dart`:
   - Explains spam blocking, native call screening, how blocked calls are handled, and why Default Phone App role is required.
3. `lib/screens/help/contact_sharing_help_screen.dart`:
   - Explains QR code generation & scanning, on-device business card OCR scanning (privacy-friendly, no cloud upload), and offline Bluetooth LE sharing.
4. `lib/screens/help/privacy_security_help_screen.dart`:
   - Explains Secret Contacts, Biometric vs App PIN security, Screenshot Guard, and the Security Audit Log.
5. `lib/screens/help/duplicate_merge_help_screen.dart`:
   - Explains how duplicate contacts are found, how smart merging works safely, and previewing merged records.
6. `lib/screens/help/faq_troubleshooting_help_screen.dart`:
   - Comprehensive answers to top user questions (Permissions, Default Dialer setup, Offline Privacy Guarantee, Quiet Hours troubleshooting, Cloud sync vs Wi-Fi P2P sync).

### C. Update `lib/screens/help/help_home_screen.dart`
- Group the help topics into clear sections with search/category organization so users can effortlessly find answers to any question.

---

## 4. Verification Plan
- Run `flutter analyze` to ensure zero compilation or lint errors.
- Run `flutter test` to verify existing tests pass cleanly.
- Verify that all newly created help screens navigate correctly and render properly without UI overflow.
