# Life OS

A Flutter (iOS + Android) personal life-management app: tasks, plans, habits,
goals, calendar, and a media/school library, all in one place. Offline-first
— local SQLite (via Drift) is the source of truth, Supabase is for auth and
sync, and AI is proxied through a Supabase Edge Function so no model key
ever ships in the app.

The full product spec lives in [`LIFE_OS_SPEC.md`](LIFE_OS_SPEC.md). The
standing engineering rules (the "nine rules", conventions, Definition of
Done) live in [`CLAUDE.md`](CLAUDE.md) — read that before touching the code.
Architectural choices the spec left open are recorded in
[`DECISIONS.md`](DECISIONS.md); anything deliberately not built yet is in
[`POSTPONED.md`](POSTPONED.md).

## Status

Built and green (`flutter analyze` clean, full test suite passing) as of
this commit:

| Milestone | What it covers |
|---|---|
| M1 | Project setup |
| M2 | Design system (tokens, `L`-prefixed components) |
| M3 | Navigation shell, full `§3.2` route table |
| M4 | Local database (Drift) and Supabase auth |
| M5 | Tasks, Home v1, Quick Add |
| M6 | Pure-Dart recurrence engine, golden-tested |
| M7 | Plans on the recurrence engine, plan calendar, unified calendar |
| M8 | Media library (Films/TV/Books), rankings, personal lists, School timetable, AI permission shell, plan-based scheduling. Custom brief — see below. |
| Habits (§13) | Habits are Plans (`kind = 'habit'`) — creation, list with a 7-day dot strip, detail with streak/best-streak/year heatmap. |
| Projects (§11) | Full CRUD, task grouping (To do/Done, inline add), derived progress, deadline chips. |
| Goals (§12) | Full CRUD, all six goal types, honest projection arithmetic, milestones, and automatic progress from completed Plan occurrences. |
| Notes (§17.1) | A custom block editor (paragraph/heading/checklist/bullet/quote/divider/code), pinning, plain-text projection. |
| Note linking (§17.2) | A "Linked notes" section — link an existing note or create one inline — on Task, Plan, Project, Goal, Film and Book detail screens. |
| Journal (§22.1) | One entry per day, editable any day; mood (1–5) plus the same block editor Notes uses. Reached from Home's "⋯" menu. |
| Finance (§22.2) | Manual expense/income entry (amount-keypad-first quick add), categories, monthly budgets with progress bars, a category-breakdown donut. Reached from Home's "⋯" menu. |
| Universal Search (§18) | Keyword search (SQLite FTS5) across tasks, plans/habits, projects, goals, notes, journal, films/TV/books and links — grouped by type, ranked, capped at 8 with "Show all." Reached from Home's search icon. |
| Links (§17.3) | Save a URL instantly, editable title/tags, open in the browser. Open Graph enrichment isn't built. |
| Documents (§17.3) | Import a file (up to 25MB), stored locally, list/rename/delete, searchable, a total-size quota in Settings → Data, tap to open in whatever app the OS resolves for it. Syncing to a storage bucket isn't built. Reached from the Library home hub, alongside Links. |
| Home dashboard (§5.3, §5.4) | 9 of the catalogue's 15 card types (`focus` handled specially, always first): Plans today, Habits, Upcoming, Goals, Projects, Recent, Daily stats, Journal prompt, Spending. Reorder, show/hide and size, all real and persisted, from Settings → Home dashboard. Tapped-on cards (Focus, Plans today, Habits) update live everywhere; glanced-at ones (Goals, Projects, Journal, Finance, streak) refresh on Home's next load. `reading`, `filmNext`, `study`, `activity`, `aiSuggestions`, and the customise screen's live preview aren't built. |
| Settings (§22.5) | Profile, Appearance, Home dashboard and Privacy (real saved preferences, no delivery/collection behind them yet), Data (storage used, rebuild search index, clear image cache), Integrations (honest TMDB/Open Library status), About (version, licences). Account, Calendar and Subscription stay the honest "not built yet" placeholder — each needs a real auth session, a native calendar permission, or IAP. |
| Notifications (§22.3) | Local-only scheduling (`flutter_local_notifications`) for 6 of 11 categories — task reminders, plan occurrences, habit reminders, event alerts, project deadlines, goal milestones — with a master switch, per-category toggles and quiet hours, all enforced before anything reaches the OS. Reschedules on app resume and on every Settings change. Task deadlines, morning/evening briefings, free-time nudges and the weekly review are saved preferences with nothing generating them yet. |
| Statistics & Your Year (§20, §21) | Cross-domain Stats tab (today/week/month/year/all-time, computed on demand — no rollup table) covering Tasks, Plans & Habits, Goals, Library and Finance, plus Insights (§20.3: three fixed deterministic checks — best weekday, morning/evening completion rate, journal frequency — each gated on a minimum sample size). Your Year's full-year activity grid (a `CustomPainter`, not 365 widgets) with a milestone notch, a "Compare to last year" overlay line, "Share your year" PNG export to the OS share sheet, and tap-through to a read-only Day Detail screen, shared by `/home/day/:date`. Reached from Home's "⋯" menu. |

`LIFE_OS_SPEC.md`'s own M8 (Goals), M9 (Projects) and M10 (Habits) were
deferred until the custom M8 brief below shipped; all three are now done,
along with Notes (part of M13).

### M8 — Media Library & School Timetable (custom brief, see `DECISIONS.md`)

Done, end to end:
- **Films/TV/Books**: search → add → watchlist/in-progress/done/favourites
  grid → detail (interactive rating, favourite, watched/finished log) →
  sortable rating history (per type and unified) → reorderable Top 5/Top 5/
  Top 3. TV additionally tracks per-episode watched state and a distinct
  0–6★ "personal favourite" tier, never averaged into the show's own 1–5★
  rating.
- **Media Collections**: named, ordered, polymorphic lists (a collection
  can hold a film, a show and a book together) — create/rename/delete, add
  from any item's own menu, reachable from the Library home hub.
- **Per-media-type stats**: watched/read this year and this month, average
  rating, most common genre, total runtime (year-scoped, films/TV only),
  and a rating-distribution bar — computed live from `library_items`, no
  rollup table needed at this scale.
- **School timetable**: profile setup (one-week or two-week A/B, computed
  by a pure week-parity engine — `lib/core/school/school_week_engine.dart`),
  manual lesson entry, term dates and closures, and a dashboard showing
  today's Week A/B, open/closed status, and today's lessons.
- **AI permission-scopes shell**: a real, working Settings → AI screen
  (master switch, write permission, ten per-domain read scopes) that saves
  real preferences now, with no model or backend behind it yet — see
  "Not yet built" below.
- **Plan-based scheduling (§16.5, "the flagship flow")**: a Plan occurrence
  can be linked to a film/show/book from either side (the occurrence's own
  sheet, or "Schedule this" on the item's detail screen); completing a
  linked occurrence marks the item watched/finished and offers an optional
  rating prompt.

Not yet built: the live AI backend (needs a Supabase project and an Edge
Function — same blocker as sync) and semantic search (§18.3, layered on
top of the FTS5 keyword search that does now exist) — both blocked on a
real backend, not on anything this session chose to defer. See `DECISIONS.md`
for the full list of smaller, deliberate cuts within each shipped feature
(e.g. "Fill from watchlist," the counter-habit stepper, Projects'
Files/Activity sections, five of Goals' six automatic-progress rows,
Journal's auto-generated context strip, Finance's recurring expenses,
Links'/Documents' sync-to-storage-bucket half, Stats' 30-day-median-relative
activity scoring).

## Running the app

Web is not a supported target: `drift`/`sqlite3_flutter_libs` use
`dart:ffi` for native SQLite, which doesn't exist on the web platform at
all (`flutter run -d chrome` fails at compile time with "Dart library
'dart:ffi' is not available on this platform" across every `sqlite3`/`ffi`
file — not a missing-config issue `flutter create .` would fix). Android
(emulator or device) is the fastest way to actually run this app; iOS
needs a Mac.

### Android emulator (one-time setup on this machine)

The Android SDK, an AVD, and a JDK are already present on this machine but
weren't wired into `PATH`/`JAVA_HOME` by default. Each new shell needs:

```powershell
$env:JAVA_HOME = "D:\dev\jdk-17"
$env:PATH = "D:\dev\flutter\bin;D:\dev\jdk-17\bin;D:\dev\android-sdk\platform-tools;$env:PATH"
```

The emulator itself also needs Windows Hypervisor Platform enabled (a
one-time, admin + restart step — see `DECISIONS.md` for why this blocked
the first run attempt):

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -All -NoRestart
```

Restart, then:

```powershell
flutter emulators --launch life_os_pixel
flutter run
```

### Enabling real film/TV search

Film and TV search (`TmdbMetadataProvider`) needs a free TMDB API key —
register at themoviedb.org, then run with:

```bash
flutter run --dart-define=TMDB_API_KEY=your_key_here
```

Without it, search shows an honest "not configured" state and manual
add-by-title still works. Book search (Open Library) needs no key.

## Testing

```bash
flutter analyze
flutter test --exclude-tags=live
```

`--exclude-tags=live` skips the one test that makes a genuine network call
against the real Open Library API (`open_library_provider_live_test.dart`)
— that one is run separately with `dart test`, not `flutter test` (see
`DECISIONS.md` for why `flutter_test` can't be used for it).

## Architecture at a glance

- **State**: Riverpod with codegen (`@riverpod`). Repositories expose Drift
  streams; controllers are `AsyncNotifier`.
- **Errors**: repositories return `Result<T, Failure>`, never throw across a
  layer boundary.
- **Layering**: `lib/features/<feature>/` never imports another feature —
  cross-feature work goes through `lib/data/repositories/`. `lib/core/` has
  no Flutter dependency (the scheduling and school-week engines are pure
  Dart, golden-tested).
- **Design system**: every color/spacing/type value comes from
  `lib/design/tokens/`; components are prefixed `L` (`LButton`, `LCard`,
  `LStarRating`, …) and live in `lib/design/components/`.
