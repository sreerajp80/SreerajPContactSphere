# Workflow Rules — ContactSphere

This document defines the mandatory development workflow rules for the ContactSphere project.
Every contributor, AI agent, and LLM coding assistant must follow these rules without exception.

Read [../CLAUDE.md](../CLAUDE.md), [../AGENTS.md](../AGENTS.md), and [GUIDELINES_MANIFEST.md](GUIDELINES_MANIFEST.md) first.

---

## 1. Plan Before Changing

Before making any edit, creation, or deletion of project files, you must first write a comprehensive, standalone plan document.

- **Location**: `plans/`
- **Filename pattern**: `yyyymmdd_hhMMss_<short-slug>.md` using current local time.
- **Required contents**:
  - `**Status:** pending` header line.
  - Clear statement of the problem or task objective.
  - Complete list of files to be created, modified, or deleted.
  - Step-by-step implementation plan.
  - Verification strategy (commands, automated tests, manual validation).

The only allowed file creation prior to approval is the plan file itself.

---

## 2. Explicit User Approval Gate

Writing the plan is only the first step. You must **STOP and wait for explicit approval** before touching any other project files.

- Proceed **only** upon receiving an affirmative confirmation (e.g., "yes", "approved", "go ahead").
- An ambiguous reply, feedback question, or discussion is **not** approval.
- If the plan changes during review or implementation, re-present the revised plan and obtain fresh approval.
- The sole exception is when the user explicitly states to skip the plan for that specific change.

---

## 3. Log After Changing

Immediately after completing implementation and verifying changes, you must record a change log entry.

- **Location**: `change_log/`
- **Filename pattern**: `yyyymmdd_hhMMss_<short-slug>.md` using current local time.
- **Required contents**:
  - Reference to the corresponding plan in `plans/`.
  - Summary of what changed across each file.
  - Verification results (test outputs, build status).
  - Any notes or deviations from the original plan.
- Update the `**Status:**` header in the corresponding plan file from `pending` to `completed`.

---

## 4. Relative Paths & Privacy Rules

All `plans/` and `change_log/` files are committed to version control and may be published publicly. They must remain completely clean of machine-specific or sensitive details:

1. **Relative repository paths only**:
   - Always write `lib/screens/contact_list_screen.dart` or `android/app/build.gradle.kts`.
   - Never write absolute local paths such as `C:\...`, `l:\...`, or `file:///...`.
2. **Zero local system details**:
   - Never record OS usernames, workstation/hostnames, home directory paths, or drive letters.
   - Never include network share names, LAN/internal IP addresses, local dev server URLs with ports, or hardware/device serial numbers.
   - Never include personal email addresses or phone numbers not already published in open project configuration.
3. **Zero secrets**:
   - Never record passwords, keystore passphrases, API keys, auth tokens, private keys, or seed data.
