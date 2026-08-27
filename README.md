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
| M8 (in progress) | Media library (Films/TV/Books), personal Top-N lists, School timetable data model, AI shell. See below. |

### M8 — Media Library & School Timetable (custom brief, see `DECISIONS.md`)

Done:
- Data architecture: `library_items` (films/TV/books, one polymorphic
  table), `tv_episodes` (per-episode 0–6★ tracking, the 6th star a distinct
  "personal favourite" tier), `top_list_items` (capped, manually curated
  Top 5/Top 5/Top 3 — independent of star ratings), and the School tables
  (`school_profile`, `school_lessons`, `school_terms`, `school_closures`,
  `school_events`) plus a pure-Dart week-A/B parity engine
  (`lib/core/school/school_week_engine.dart`).
- Real metadata providers: `TmdbMetadataProvider` (films/TV, needs a free
  API key — see "Running the app" below) and `OpenLibraryProvider` (books,
  no key needed), both behind one `MediaMetadataProvider` interface so the
  provider is swappable later.
- Films, end to end: search → add → watchlist/watched/favourites grid →
  detail (interactive rating, favourite, watched log) → sortable rating
  history → reorderable Top 5.

Not yet built: TV shows UI, Books UI, School timetable UI, media
collections, unified media/ratings overview, stats screens, and the live
AI backend (the permission-scopes shell exists; there is no Supabase
project or Edge Function yet to call).

## Running the app

### Quickest: Chrome (no setup needed)

```bash
flutter run -d chrome
```

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
