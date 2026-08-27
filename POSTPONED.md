# POSTPONED.md — Life OS

Deliberately not built in v1. Recorded per §37.2 of `LIFE_OS_SPEC.md` so the decision stays visible instead of forgotten. Nothing here should be hinted at in the UI (§1.5).

| Item | Reason |
|---|---|
| Two-way device calendar sync | v1 ships read-only import only; two-way sync needs a conflict story with a third-party calendar, out of scope until sync (M19) is proven with our own data first |
| Semantic search | Candidate for Premium post-M16; needs an embeddings pipeline and vector storage not justified before the FTS5 baseline (M14) ships |
| Smart collections | Depends on stats/rollups (M15) being stable first |
| Web app and desktop | Explicit non-goal, §1.5; architecture must not prevent it later but nothing is built now |
| Apple Watch and Wear OS | Separate app targets and lifecycle; no justification until the phone app is stable |
| Live Activities and Dynamic Island | iOS-only, high-maintenance surface; revisit once notifications (M17) and widgets (M18) are solid |
| Shortcuts / App Intents / Siri | Needs a stable, versioned intent surface; premature before the domain model settles |
| Bank connection, multi-currency, receipt scanning | Explicit non-goal, §1.5 (no Open Banking / Plaid in v1); finance stays manual entry |
| Sharing, collaboration, public profiles | Explicit non-goal, §1.5 (no multi-user anything) |
| Import from Todoist, Notion, Apple Reminders, Letterboxd, Goodreads | Each is its own mapping/format project; none blocks v1 usefulness |
| Health app integration | No clear v1 feature depends on it |
| Time tracking and Pomodoro | Explicit non-goal, §1.5 (no automatic time tracking) |
| Location-based reminders | Adds a permissions and battery surface not justified for v1 scope |
| Handwriting and drawing in notes | Notes ship with text block types only in v1 |
| Themes beyond accent colour | One accent + light/dark covers §2 design direction; full theming is a v2 surface |
| Localisation beyond English | Every string is wrapped in the l10n system from M2 so this stays cheap later, but no translations ship in v1 |

---

Add new entries here the moment scope is deliberately cut, with a one-line reason. Do not delete entries — if something later gets built, move it out with a note of which milestone shipped it instead of deleting the row.
