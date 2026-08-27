# DECISIONS.md — Life OS

Choices `LIFE_OS_SPEC.md` left open, and choices made during setup that a future session shouldn't silently re-litigate. Newest first.

---

## §11 — Projects (2026-08-28)

Habits' spec-sequence sibling — `ProjectRepository`/`AppProject` existed since the onboarding batch (deliberately minimal then: no screen existed to use the rest of §11.2's fields). A real Projects list and detail screen now exist, so the rest of the model got wired up.

### `colour`/`icon`/`deadline`/`goalId` were already columns on `Projects` since M4, unused until now
**Decision:** `AppProject` gained all four, JSON/plain-column round-tripped through `ProjectRepository._save`/`_toDomain` — the same "wire up the column that already exists" pattern as School, Collections, and Habits' `target` this session.
**Why:** no migration needed; the schema was already designed for this.

### Progress is computed in the UI from `tasksForProjectProvider`, never stored on `AppProject`
**Decision:** neither `AppProject` nor `ProjectRepository` has a `progress`/`completedTasks` field — `ProjectsScreen`/`ProjectDetailScreen` derive the percentage from whatever `TaskRepository.watchByProjectId` currently returns.
**Why:** §11.2 says progress is "derived, never stored" outside of a `daily_rollups` cache for statistics — and that rollup table doesn't exist yet for the same reason the general Stats tab doesn't (see the Library Stats decision above). Storing progress on `AppProject` now would just be a cache with no invalidation story; computing it live from a `Stream` costs nothing extra since the screen already needs the task list to render the To do/Done sections.

### Deleting a project asks first — the two choices are separate `TaskRepository` calls, not a flag on `ProjectRepository.deleteProject`
**Decision:** the delete confirmation dialog itself decides "delete N tasks too" vs. "move them to no project," then calls `TaskRepository.deleteAllForProject`/`clearProjectForAll` (both new — thin bulk wrappers over new `TaskDao` methods) *before* calling the plain `ProjectRepository.deleteProject(id)`. `deleteProject` itself takes no such flag.
**Why:** §11.4's own wording, "never silently orphan or silently destroy," is squarely a UI-decision concern (what does the user want), not something `ProjectRepository` should encode as a boolean parameter whose two meanings live in a comment. Keeping the two task-repository calls separate and explicit at the call site makes the actual database effect of each choice legible without reading `ProjectRepository`'s internals.

### Projects reuses `TaskRow` (Tasks feature) directly; a `resolveProjectColour` helper is duplicated from `plan_colour.dart`, not imported
**Decision:** `ProjectDetailScreen`'s Tasks section is literally `TaskRow` from `lib/features/tasks/presentation/widgets/task_row.dart` — a same-feature reuse (Projects lives under the Tasks tab, `/tasks/projects/...`). `resolveProjectColour` (`lib/features/tasks/presentation/project_colour.dart`) is a near-identical ~15-line copy of `plans/`'s `resolvePlanColour`, not an import of it.
**Why:** `TaskRow` costs nothing to reuse — same feature, no boundary crossed. `resolvePlanColour` lives in `lib/features/plans/`; importing it from `lib/features/tasks/` would be a real rule-4 violation (features importing features) for the sake of one small function whose only feature-specific bit is its fallback domain name (`'plans'` vs `'tasks'`). Duplicating ~15 lines is cheaper and cleaner than restructuring where domain-colour resolution lives just to share it.
**How to apply:** if a third feature needs the same lookup, that's the signal to promote it to a shared, non-feature-owned home (e.g. `lib/design/theme/`) with a `fallbackDomain` parameter — not before.

### Files and a filtered Activity history (§11.3) are deferred
**Decision:** this pass ships Tasks (grouped, inline add) and Notes (free-text `description`) — not "Files" (needs the Links/Documents feature, itself unbuilt — §17.3) or an `activity_log`-filtered Activity section (a real feature needing its own query/rendering layer, not a quick addition).
**Why:** same category as "Fill from watchlist" and goal contributions earlier this session — the core primitive (a real Project a Task can belong to, with derived progress) is what makes Projects a real feature; these two sections are additive and depend on other unbuilt features (Files) or non-trivial new UI (a filtered activity feed) that don't block Projects from being genuinely useful today.

## §13 — Habits (2026-08-28)

The M8 media/school brief explicitly deferred `LIFE_OS_SPEC.md`'s own M8 (Goals)/M9 (Projects)/M10 (Habits) "until after this M8." With that custom M8's own named pillars (media library, rankings, personal lists, School, AI shell, plan-based scheduling) now shipped, Habits is next — and by far the most shovel-ready of the three, since §7.1's binding decision ("habits are plans with `kind = habit`, no separate engine") means the whole recurrence/completion/streak backend already existed from M6/M7. Only the habit-specific UI and a couple of small stats were missing.

### Habit creation reuses `RhythmEditor` wholesale rather than a second, smaller rhythm control
**Decision:** `HabitCreateScreen`'s "frequency row" (§13.1) embeds the same `RhythmEditor` widget `PlanCreateScreen`'s step 2 uses, defaulted to `IntervalDays(1, anchor: today)` ("Every day").
**Why:** §13.1 says "nothing else," but building a second, habit-scale rhythm picker would be a second implementation of "how often" to keep in sync with the real one — exactly what §7.1's own reasoning for not building a separate habits engine warns against, one level up the stack. `RhythmEditor` is already a self-contained widget (not tied to being "step 2 of a wizard"), so embedding it costs nothing extra.
**How to apply:** editing an existing habit reuses `PlanCreateScreen` in its edit mode (via `showPlanActionsMenu`'s existing "Edit" action, unchanged) rather than a bespoke `HabitEditScreen` — §13.1's "one screen" requirement is about creation specifically; a real, working edit flow that happens to show more controls than the minimal create screen is not a violation of it.

### `target` (§7.2) is wired end to end now — the column existed since M4, unused
**Decision:** `AppPlan.target` (a new `PlanTarget {value, unit}`, JSON-encoded into the pre-existing `plans.target` column) is set from `HabitCreateScreen`'s two optional fields and round-trips through `PlanRepository`.
**Why:** same pattern as School's and Collections' schema columns that existed unused since M4 — wiring the already-designed column costs a few lines in `_savePlan`/`_toDomain`, versus inventing a new one.
**How to apply:** counter habits (target > 1) currently store and display the target but the list/detail screens don't yet render §13.2's stepper-plus-partial-ring — `AppOccurrence.valueAchieved` (also pre-existing, also unused until now) is exactly the field a future pass would write partial progress into; this pass only ships the binary complete/incomplete interaction.

### `bestStreak` is a new field on the shared `PlanStats`, not a habit-only type
**Decision:** `PlanStats` gained `bestStreak` (longest historical consecutive-completed run) alongside the existing `streak` (current run), computed in the same `_computeStats` pass every Plan already gets, not a separate habit-specific stats query.
**Why:** the computation is a cheap second scan of data `_computeStats` already has in memory; adding it to the shared type means it's available if a future Plan-detail redesign ever wants it too, at zero extra query cost today.

### The full-year heatmap and "month calendar" are new pure logic plus reuse, not new screens
**Decision:** `computeYearHeatmap`/`computeMonthCompletionRate` (pure functions, `habit_stats.dart`) turn a plain `List<AppOccurrence>` — already fetchable via the existing `planOccurrencesInRangeProvider` — into `LHeatmapGrid`-ready values (columns: 7, so weeks stack as rows) and a month percentage. "Month calendar" is literally `PlanCalendarScreen` (§8.2, already built for regular plans) via its existing `/plans/:id/calendar` route — a habit is a plan, so its calendar is that same screen, unchanged.
**Why:** `LHeatmapGrid` is already a generic `List<double?>` renderer with no changes needed; a month-grid calendar already exists and works for any plan id. Building either again would be exactly the kind of duplication rule 4 and this session's whole pattern of reuse exist to prevent.

## §16.6 — Per-media-type Library stats (2026-08-27)

`LibraryStatsScreen`, one per media type, reached via a new stats icon on Films/TV/Books (same pattern as the existing Ratings/Top5 icons) — not the general `/stats` tab.

### Computed directly from `library_items` at render time, not a rollup table
**Decision:** `computeLibraryStats` reads whatever `LibraryItemRepository.watchAll` currently holds and derives everything (this year/month counts, average rating, top genre, runtime, rating distribution) on the spot — no `daily_rollups` row, no `StatsRecorder`.
**Why:** §20.1's "never compute statistics by scanning raw tables at render time, maintain a rollup table" is written for the general Stats tab's daily-granularity trends across every domain — a genuinely large, cross-cutting feature this session correctly left alone. §16.6 itself only says these particular figures are "computed locally from `library_items`," which is a small, already-loaded, per-user table (a personal library, not an event log) — scanning it at render time is the same cost as any other `ref.watch` over a Drift stream elsewhere in this app, not the problem §20.1 is warning about.
**How to apply:** don't reuse this precedent to justify skipping the rollup table for the actual `/stats` tab when that gets built — that one really does need it, per its own much larger domain list and daily time series.

### Total runtime is scoped to this year, and omitted entirely for books
**Decision:** `totalRuntimeMinutes` sums only the current year's finished items (matching §16.6's own worked example, "94 hours of film this year") and is `null` — hidden from the UI, not shown as `0` — when `includeRuntime: false`, which `library_stats` always passes for books.
**Why:** books have no reliably-tracked runtime-equivalent (page counts aren't tracked at all yet — `progressValue`/`progressUnit` are a generic, inconsistently-populated field, not a real page-count feature); showing a fabricated or near-always-zero stat would be exactly the "fake data" rule 1 forbids.

### The rating-distribution bar is hand-drawn with `Container` heights, not a chart package
**Decision:** `_RatingDistribution` computes each bar's height as a plain clamped fraction of a fixed max (`Container(height: ...)`), not `fl_chart` (not yet a dependency) and not `FractionallySizedBox` (whose `heightFactor` needs a bounded incoming height that a `Row`-in-`Column` layout doesn't reliably guarantee here).
**Why:** one five-bar chart doesn't justify a new charting dependency (CLAUDE.md: "No new dependency without an entry in DECISIONS.md" — better to avoid needing one), and the codebase already hand-rolls small visualisations this way (`LHeatmapGrid` for Plan stats, `LSquiggleDivider`'s `CustomPainter`) rather than reaching for a library each time.
**How to apply:** if the general Stats tab later adopts `fl_chart` per §20.2, this bar doesn't need to migrate — it's a small enough visual to stay bespoke.

## §16.5 — Plan-based scheduling, the flagship flow (2026-08-27)

The M8 brief's own umbrella title names "Plan-based scheduling" as a pillar alongside ratings and Top-N lists, but building it was deferred until the Library it depends on existed — `occurrence_sheet.dart` and `plan_detail_screen.dart` both carried stale comments saying so ("there's no Library to choose from until M11/M12"). Library shipped earlier in this same M8 pass, so this closes that gap: linking a Plan occurrence to a film/show/book, completing a linked occurrence marks it watched, and "Schedule this" from the item's own detail screen.

### The link lives on `plan_occurrences`' existing `linkedEntityType`/`linkedEntityId`, unused until now
**Decision:** `PlanDao.setLinkedEntity`/`PlanRepository.linkOccurrenceToLibraryItem`/`unlinkOccurrence` write `entityType = 'libraryItem'`, `entityId = library_items.id` into columns the schema has carried since M4.
**Why:** exactly the generic polymorphic reference these columns were designed for — no migration needed, and the same columns are ready for a future entity type (e.g. a Note) without another schema change.

### `PlanRepository` takes an optional `LibraryItemRepository`, per rule 4
**Decision:** `PlanRepository`'s constructor gained an optional `libraryItemRepository` param (default `null`, so every existing caller and test is unaffected). `completeOccurrence` calls `libraryItemRepository?.markWatched(...)` when the occurrence is linked, stamped with the *occurrence's* scheduled date, not "now" — completing a Sunday's film on Tuesday should still log Sunday.
**Why:** CLAUDE.md rule 4 ("cross-feature work goes through `lib/data/repositories/`") means this composition belongs at the data layer, not a cross-feature provider. There's no `lib/core/events/` bus built yet (rule 4's other sanctioned path), so direct repository injection is the only available mechanism, same layer `ActivityLogDao` is already injected at.
**How to apply:** the `null`-default means the app's own `planRepositoryProvider` singleton is the only place that needs to actually wire a real `LibraryItemRepository` in; anything constructing `PlanRepository` for an unrelated purpose (tests, `onboarding_providers.dart`'s plan-creation-only instance) can keep omitting it.

### `plans/` and `library/` each construct their own `LibraryItemRepository`/`PlanRepository` instance — never each other's provider
**Decision:** `plan_providers.dart` adds `planMediaRepositoryProvider` (wrapping `LibraryItemDao` directly) instead of importing `library_providers.dart`'s `libraryItemRepositoryProvider`; symmetrically, `library_providers.dart` adds `libraryPlanRepositoryProvider` (wrapping `PlanDao` directly) for "Schedule this," instead of importing `plan_providers.dart`.
**Why:** rule 4 forbids `lib/features/plans/` importing `lib/features/library/` (or vice versa) — even just for a provider. `onboarding_providers.dart` already established this exact workaround (constructing its own `LibraryItemRepository(LibraryItemDao(database))` rather than importing `library/`'s provider) before this decision; this just applies the same pattern in both directions. Multiple instances are safe because Drift's `watch()` streams are backed by the database's own change notifications, not by the repository object's state — a write through either instance is visible to both.

### The optional rating prompt reimplements a tiny dialog with `LStarRating` rather than importing `library/`'s `RateDialog`
**Decision:** `OccurrenceSheet._promptRatingIfNeeded` is a self-contained `AlertDialog` + `LStarRating` + `planMediaRepositoryProvider.setRating`, not a call to `lib/features/library/presentation/widgets/rate_dialog.dart`.
**Why:** same rule-4 boundary as above — `RateDialog` lives in `library/`'s presentation layer, off-limits to `plans/`. `LStarRating` is a design-system component (`lib/design/`), fair game anywhere, so reusing it here costs a dozen lines instead of a cross-feature import.

### "Schedule this" links to the next free upcoming occurrence automatically; it doesn't open a date/slot picker
**Decision:** picking a plan in `ScheduleThisSheet` finds that plan's earliest upcoming occurrence with no existing link and connects it immediately — there's no UI to pick *which* occurrence.
**Why:** §16.5's own mockup shows the primary picking motion happening from the *plan* side (`OccurrenceSheet`'s "choose a film" on a specific date), which this build fully supports. "Schedule this" from the item's side is the secondary entry point the spec also names (§16.4) — auto-picking the next free slot keeps it a one-tap action; a user who wants a specific date can already get one via the plan's own calendar/occurrence list.
**How to apply:** if a future pass wants "Schedule this" to also offer a specific date, that's an additive UI change to `ScheduleThisSheet`, not a new backend capability — `linkOccurrenceToLibraryItem` already takes any occurrence id.

### "Fill from watchlist" (bulk-assign) and the goal-contribution on completion are both deferred
**Decision:** built the single-item linking primitive (choose one film for one occurrence) and its two entry points, not §16.5's "Fill from watchlist assigns the next N unwatched items" bulk action, and not "emits a goal contribution if a films goal exists."
**Why:** "Fill from watchlist" is additive sugar over the same `linkOccurrenceToLibraryItem` primitive already built — safe to add later without touching what's here. The goal contribution can't be built at all yet: Goals is still `NotBuiltYetScreen` (see the earlier M8 umbrella decision) — there is no goal record to contribute to, and inventing one would be exactly the fake affordance rule 1 forbids.
**How to apply:** when Goals is real, `completeOccurrence`'s existing linked-item branch is the natural place to add a goal-contribution call, gated on `plan.goalId != null`.

## M8 Parts 35-40 — Settings → AI permission scopes (2026-08-27)

The buildable slice of AI (§19) identified in the earlier "AI: shell only, no live model calls" decision: a real, working permission-scopes screen with no model behind it yet.

### The screen is fully functional and saves real preferences; only the assistant itself is inert
**Decision:** `AiSettingsScreen` (`Routes.settingsAi`) has a master "Enable AI assistant" switch, a separate "Let it make changes" write switch (defaults on per §19.2), and one read-scope switch per domain (tasks, plans, habits, goals, projects, calendar, library, statistics, journal, finance — journal and finance default off). Every switch writes through `AiPermissionsRepository` immediately, same key/value `Preferences` pattern as the theme scheme and onboarding state. A card at the top states plainly that the assistant isn't available yet because there's no server component configured.
**Why:** §16.7/CLAUDE.md's "no fake affordances" rule cuts against a UI that looks interactive but silently discards input — these switches don't yet gate anything, but they're not lying either: flipping one and reopening the screen shows the same value. The explanatory card is the honest disclosure the rule actually requires, not a reason to disable the controls.
**How to apply:** when the Supabase Edge Function from the earlier AI decision exists, the context builder reads `AiPermissionScopes` from this same repository to decide what to include — no migration needed, since real user choices have been accumulating here the whole time.

### Scopes are one JSON blob under one preferences key, not one row per domain
**Decision:** `AiPermissionScopes` (12 booleans) round-trips through a single `aiPermissionScopes` preferences key via `jsonEncode`/`jsonDecode`, the same shape as `OnboardingRepository`'s saved-answers blob.
**Why:** the whole scope set is read and written together (one settings screen, one save-on-toggle flow) — a dedicated table with one row per domain would need its own migration and CRUD DAO for data that's never queried per-row or joined against anything else.

## M8 Part 28 — Media Collections (2026-08-27)

Manual collections (§15.2): named, ordered, polymorphic lists over `collections`/`collection_items`, which existed in the schema since M4 but had no DAO/repository/UI until now.

### Collections is its own hub off Library Home, not a segment inside Films/TV/Books
**Decision:** `CollectionsScreen` (`/library/collections`) and `CollectionDetailScreen` (`/library/collections/:id`) are top-level siblings of Films/TV/Books under the Library tab, reached from a new "Collections" row on `LibraryHomeScreen` — not a fourth segmented-control tab bolted onto `FilmsScreen`/`TvShowsScreen`/`BooksScreen`.
**Why:** this supersedes the plan sketched in the earlier "Films UI ships before Collections exists" decision, written before `LibraryHomeScreen` (M8.15) existed. §3.2's own route table already lists `/library/collections/:id` as a sibling of `/library/films`, `/library/tv`, `/library/books` — all reached from the Library hub — not nested under any one media type. A collection is also explicitly polymorphic (can hold a film, a TV show and a book together), so it never belonged inside a single media type's screen in the first place.
**How to apply:** the grid/tile machinery is still reused (see below) — only the entry point changed from the original plan, not the underlying screens.

### Items are added to a collection from the item's own menu, not from inside the collection
**Decision:** `showLibraryItemMenu`'s "Add to collection" action opens `AddToCollectionSheet` (a checklist of collections with a "New collection" quick action at the top); `CollectionDetailScreen` itself has no "add item" affordance, only "remove from collection" per item and rename/delete for the collection as a whole.
**Why:** a reverse picker (browse the whole library from inside a collection to add something) would duplicate the search/browse screens Films/TV/Books already have. Starting from the item keeps one direction of "add," matching how "Add to Top list" already works from the same menu.
**How to apply:** if a future collection-builder flow wants a from-the-collection add path too, it should reuse the existing per-type browse screens (`FilmsScreen` etc.) as a picker rather than building a new cross-type search.

### Collection membership is a plain id list; the poster grid is the same tile pattern as Films/TV/Books
**Decision:** `CollectionRepository` only owns rows in `collection_items` (`watchItemIds`, `addItem`, `removeItem`, `watchCollectionIdsContaining`) — same "membership only, caller joins for display" shape as `TopListRepository`. `LibraryItemDao.watchByIds`/`LibraryItemRepository.watchByIds` (new) resolve a mixed-media-type id batch in one query, and `CollectionDetailScreen`'s grid reuses `FilmsScreen`'s `_FilmTile` layout (poster + title, `LPosterTile`, long-press menu) generalised to route to whichever of `libraryFilmDetail`/`libraryTvDetail`/`libraryBookDetail` matches each item's `mediaType`.
**Why:** avoids a second "join ids to display data" implementation and a second poster-grid layout for what is visually identical to the existing Watchlist/Watched/Favourites grids — the DECISIONS.md note left by the earlier Films-UI decision ("the grid/tile/menu machinery already built here is meant to be reused, not duplicated") still holds, just applied at the tile level instead of a shared screen.

### Collections are manual only in this pass; `itemType` isn't yet user-set at creation
**Decision:** `CollectionRepository.create()` always writes `itemType = null` (mixed); the schema column and domain model (`AppCollection.itemType`) exist and round-trip correctly, but no UI control sets it yet. `isSmart`/`smartQuery` are untouched, per §15.2's "smart collections ship in M15."
**Why:** no v1 flow actually needs a single-media-type-restricted collection yet, and adding a create-time picker for a restriction nothing enforces downstream would be speculative. The column staying wired end-to-end (just not exposed) means adding that control later is a UI-only change.
**How to apply:** if a future collection type needs the restriction enforced (e.g. `AddToCollectionSheet` filtering out mismatched media types), that's a small addition to `create()`'s caller and the sheet's list — the repository and schema already carry the data.

## M8.30-M8.34 — School Timetable (2026-08-27)

Manual timetable entry, term dates/closures, and a today-view dashboard, built on the pure-Dart `school_week_engine.dart` (Week A/B parity, term/closure open-day logic) written in an earlier session.

### School has no bottom-nav tab; it's reached from a Home app-bar icon
**Decision:** `Routes.schoolDashboard` and its three sub-routes (`schoolSetup`, `schoolTimetable`, `schoolTerms`) are top-level `GoRoute`s outside the `StatefulShellRoute` tab shell, not a fifth tab. `HomeScreen`'s app bar gained a school-icon `IconButton` next to Settings as the entry point.
**Why:** the bottom nav was just finalised at four slots (Home/Plans/Tasks/Library) during the earlier FAB-overlap fix batch — adding a fifth so soon after would re-open a layout decision that batch deliberately closed. School is also not a daily-use-for-everyone feature the way Tasks or Home is, so an app-bar icon is proportionate.
**How to apply:** if a future feature wants nav-bar-level prominence, treat that as its own layout decision, not a default for every new feature area — most should follow School's pattern of a top-level route reached from an icon or a link.

### School lessons are not merged into the shared `CalendarScreen`/`calendar_providers.dart` yet
**Decision:** School's "what's happening today" surface is its own `SchoolDashboardScreen`, not an addition to the existing shared calendar merge that Tasks/Plans/Library due dates already feed into.
**Why:** `calendar_providers.dart` is a shared component several features already depend on; folding in a new, under-tested source the same session it was built risks a regression in a surface nothing here directly tests. A dedicated dashboard gets School shipped without that risk.
**How to apply:** a future pass can add School lessons/events as another source feeding the shared calendar merge — the `SchoolRepository.lessonsFor`/`isOpenOn` composition methods already return plain domain data, not UI, so they're ready to be a calendar data source without changes.

### Repository composition methods wrap the pure engine; they don't reimplement it
**Decision:** `SchoolRepository.lessonsFor`/`isOpenOn`/`weekLabelOn` do nothing but convert domain rows to the engine's plain types (`SchoolLessonSlot`, `DateRange`) and call `lessonsOnDate`/`isSchoolOpen`/`weekLabelFor` from `school_week_engine.dart`.
**Why:** keeps the actual date-parity and open/closed logic in one pure, directly-unit-testable place (already covered by the engine's own tests from the session that wrote it) rather than duplicated or subtly diverged in the repository layer.
**How to apply:** any new School query that needs date logic should add a pure function to the engine file first, then a thin repository wrapper — not inline date maths in the repository or a screen.

## M8.7-M8.11 — TV Shows (2026-08-27)

Same vertical slice as Films (search → library → detail → ratings → Top 5), plus per-episode tracking, which films don't need.

### Season import runs through a provider, not a widget `initState` side effect
**Decision:** `seasonImportProvider(showId, seasonNumber)` (a `Future<Result<void, Failure>>` provider) does the "fetch episodes from TMDB, then `TvEpisodeRepository.importSeason`" work; `SeasonEpisodesScreen` just `ref.watch`es it alongside the real episode list from the local DB.
**Why:** a provider is naturally keyed/cached per `(showId, seasonNumber)` and re-runs correctly on `ref.invalidate` or a fresh navigation, without the widget needing its own "have I already imported this?" flag. It also means the episode list (read straight from the DB stream) never blocks on the import finishing — episodes already tracked from a previous visit show immediately even if TMDB is slow or down.
**How to apply:** the same "provider does the fetch-then-write, screen just watches the local stream" split is the template for any future "sync from a remote provider into local state" screen.

### Episode ratings get their own history screen, not folded into the show's
**Decision:** `TvRatingsScreen` (1-5★ show ratings) and `TvEpisodeRatingsScreen` (1-6★ episode ratings, across every show) are two separate screens, cross-linked by an app bar icon.
**Why:** Part 42 is explicit that the two scales are never averaged or compared — a single sorted list mixing 1-5 and 1-6 values would misrepresent one or the other. Keeping them as separate screens is more honest than a combined list with two different star-scales rendered side by side.

### TV's own long-press quick-actions menu reuses `showLibraryItemMenu` unchanged
**Decision:** `TvShowsScreen`'s grid tile calls the exact same `showLibraryItemMenu` Films uses, passing `doneVerb: 'Watched'` (the default). No TV-specific menu was written.
**Why:** the menu's actions (mark done, rate, favourite, Top list, remove) are identical across every media type by construction — see the M8 Films decision that built it that way. Confirms that decision paid off: zero new menu code needed for TV.

## Onboarding, Home/Tasks polish, and a first-run gate (2026-08-27)

A batch of UI bugs found by actually using the app on the emulator, plus a first-run onboarding flow, done as one item-per-commit sequence.

### First run is a widget swap in `LifeOsApp`, not a go_router redirect
**Decision:** `LifeOsApp.build()` watches `hasOnboardedProvider` and renders `MaterialApp(home: OnboardingScreen())` when it's false, or the normal `MaterialApp.router(routerConfig: _router)` once it's true. `_router` is a `late final` field built lazily on first access, so a first-run user never constructs the router (or pays for building the whole `StatefulShellRoute` tree) until onboarding actually finishes.
**Why:** a go_router-level `redirect` callback would need `buildRouter()` to take a `Ref`, which every existing call site (`route_resolution_test.dart` included) constructs without one — a bigger, riskier change for the same outcome. The widget-swap approach touches nothing about the router itself and needed no changes to `buildRouter()`'s signature.
**How to apply:** `OnboardingScreen`'s "Finish" button doesn't navigate anywhere itself — it calls `completeOnboarding()`, which flips `hasOnboardedProvider`, and `LifeOsApp` rebuilds into the router on its own. Reached again later from Settings ("Redo setup") via a normal `context.push` — there, Finish's `Navigator.pop()` (a no-op on first run, since that stack is empty) pops back to Settings instead.

### Onboarding answers convert to real records immediately, not a persisted backlog
**Decision:** `completeOnboarding()` runs the mapper and creates real Task/Plan/Project/Library rows in the same call that marks `hasOnboarded = true`. The saved-answers JSON (`OnboardingRepository.saveAnswers`) is a record of what was asked, not a queue `SuggestionCard` reads from.
**Why:** item 8's own instruction was "on completion, turn the answers into real records" — immediate, not deferred. That leaves `SuggestionCard`'s fallback list (below) with nothing to swap to yet: the records it would suggest already exist the moment onboarding finishes.
**How to apply:** if a future "a few more ideas" feature wants to re-surface onboarding answers as ongoing suggestions, it should read `OnboardingRepository.getAnswers()` directly rather than assuming they're still "to do" — some or all may already have real records now edited or completed.

### `SuggestionCard`'s fallback list is not yet swapped for onboarding answers
**Decision:** despite the above, `SuggestionCard` (item 7) still shows a fixed generic list, not anything derived from `OnboardingRepository`.
**Why:** see the decision above — after onboarding, its answers are already real records, so there's no unconverted backlog left to surface. Wiring it up now would mean re-listing things that already have their own real place in the app.
**How to apply:** don't wire this up reactively "because item 7 said to" — only do it alongside a real feature that needs to reference onboarding answers after the fact.

### Onboarding's "daily or weekly" question always creates a daily habit
**Decision:** every answer to `OnboardingQuestion.dailyWeekly` becomes a habit-kind Plan with `IntervalDays(1, anchor: today)`, regardless of whether the user meant daily or weekly.
**Why:** the mapper is explicitly rules-based, not NLP — there's no reliable way to tell "meditate daily" from "meal prep on Sundays" apart from free text alone. Defaulting to daily and leaving the user to edit the rule once the Plan exists is honest about that limit, rather than guessing a specific weekday.
**How to apply:** an AI-based `OnboardingMapper` (the interface exists for exactly this) can replace this with a real weekly/daily distinction once it exists.

### The "read or watch" question's book/film split is a toggle, not a guess
**Decision:** `OnboardingScreen`'s fourth page has an explicit Book / Film segmented control; every answer entered on that page (free text or chip) is tagged with whichever is selected. There's no attempt to infer the type from the text itself.
**Why:** same reasoning as the daily/weekly rule above — a rules-based mapper can't reliably tell "Dune" (a book, a film, or both) apart without being told. An explicit toggle is honest and takes one tap.

### Projects gets a minimal real repository, not a stub or a Task workaround
**Decision:** `ProjectDao`/`ProjectRepository`/`AppProject` are new, real, and write to the `Projects` table that has existed in the schema since it was first set up (no migration needed — it was just never read from). `Routes.projects` is still the honest `NotBuiltYetScreen` placeholder.
**Why:** item 8 explicitly asks for "longer efforts become Projects" as real records, and the table already existed for exactly this. Routing "currently working on" answers into Tasks instead (to avoid touching a new table) would have been the fake move — CLAUDE.md rule 1. The records are real now; only the dedicated screen to browse them isn't built yet, same category as `collections` before its own UI existed.
**How to apply:** when a real Projects feature is built, its repository is already here — don't re-derive it from the Tasks workaround this decision explicitly avoided.

### Tasks/Plans screens' own FABs were removed, not just visually deduplicated
**Decision:** `TasksScreen` and `PlansScreen` no longer declare a `floatingActionButton` on their own nested `Scaffold` — the shell's single global Quick Add FAB is now the only one. Quick Add's "Plan" tile was wired to `Routes.plansNew` (previously a "not shipped" toast) so plan creation didn't silently disappear along with the screen-level FAB.
**Why:** the two FABs were rendering on top of each other; keeping both and just changing z-order or opacity would have papered over the duplication rather than removed its cause (a genuinely redundant second `Scaffold`-level FAB).

---

## Theme Schemes — four selectable visual identities (2026-08-27)

The project owner asked to move off the original M2 look and, after reviewing four pitched directions in an Artifact, picked **After Hours** (dark, ambient, coral-on-charcoal) as the shipped default, with all four available from Settings → Appearance.

### One `LifeThemeScheme`, not an accent picker layered on light/dark
**Decision:** replaced the old `LifeColors.of(Brightness, {accentName})` construction with `LifeColors.forScheme(LifeThemeScheme)`. A scheme is a complete bundle — neutrals palette, one signature accent, and a type trio — not three independently-set knobs. There's no separate light/dark `ThemeMode` any more: `LifeThemeScheme.brightness` (After Hours → dark, the other three → light) *is* the brightness: `LifeOsApp` calls `MaterialApp.router(theme: buildThemeForScheme(scheme))` with no `darkTheme`/`themeMode`.
**Why:** the four pitched directions differ in palette *and* type *and* mood together — Ledger's cool cobalt-on-slate reads nothing like Fieldnotes' warm moss-on-stone even though both are "light." Keeping brightness and scheme as separate axes would let someone combine e.g. Fieldnotes' palette with a forced dark `ThemeMode`, a combination that was never designed and wouldn't look intentional.
**How to apply:** `LifeAccentName`/`LifeAccents` (the eight per-*plan*-tag colours, `plan_colour.dart`) are untouched and unrelated — a plan's colour tag is independent of which app-wide scheme is active. Don't conflate the two when touching `colors.dart`.

### Radius and shadow stay fixed across all four schemes (scope cut)
**Decision:** `LifeRadius`/`LifeShadows` were **not** made scheme-aware. Ledger's tight hairline-square-corner pitch and Signal's fully sharp corners aren't implemented — every scheme currently uses the same `LifeRadius`/`LifeShadows.raised()` constants the app always has.
**Why:** doing this properly means turning `LifeRadius` into a `ThemeExtension` and re-pointing every component that reads the static class (`LButton`, `LCard`, `LChip`, `LTextField`, `LSheet`, …) — real, additional work, and palette + accent + type alone already make the four schemes read as distinct, different products. Not worth blocking the actual ask (a working theme picker) on it.
**How to apply:** if the flat-corner/hairline distinction is wanted later, convert `LifeRadius` to a `ThemeExtension` parameterized by `LifeThemeScheme`, following the exact pattern `LifeColors`/`LifeTextStyles` already use.

### Fieldnotes' italic-greeting touch was dropped, not built as a global italic style
**Decision:** the pitched Fieldnotes mockup showed the home greeting in italic Fraunces; the shipped scheme doesn't do this anywhere.
**Why:** the only clean way to express "italic sometimes, on this one specific piece of text" through the token system would be a scheme-conditional inside a feature widget (`if (scheme == fieldnotes) ...`), which breaks the whole point of the token architecture — feature code should never know which scheme is active. Making display text *always* italic for Fieldnotes was rejected too — italic section headers/titles would misread as emphasis everywhere, not just in a greeting.
**How to apply:** don't add scheme-conditionals to feature widgets to chase this back. If it matters later, it needs its own token (e.g. a `LifeTextStyles.greeting` role, scheme-provided) rather than a widget-level `if`.

### Eight new font families, fetched from `google/fonts` on GitHub, added as pubspec assets
**Decision:** Archivo, IBM Plex Sans, Sora, JetBrains Mono, Fraunces, Public Sans, Bebas Neue and Work Sans — one variable-font file each (static-only for Bebas Neue, matching how IBM Plex Mono already ships) — downloaded via `curl` from `raw.githubusercontent.com/google/fonts/main/ofl/<family>/`, the same SIL OFL source the original three (InstrumentSans/Inter/IBMPlexMono) came from. Each family's `OFL.txt` is bundled alongside it in `assets/fonts/`, matching the existing convention.
**Why:** the pitched directions each depend on a real, distinct type pairing for their identity (Ledger's Archivo, Fieldnotes' Fraunces, Signal's Bebas Neue) — reusing the original three fonts with only colour changed would have undercut exactly what made the four pitches read as different products. Google Fonts' GitHub mirror is the same canonical OFL source `fonts.gstatic.com` serves, just fetchable as raw files instead of needing a browser.
**How to apply:** `LifeSchemeFonts` (`typography.dart`) is the one place that maps scheme → family names; `LifeTextStyles.forScheme` is the only place that reads it. A fifth scheme needs a new `LifeThemeScheme` value, a `LifeNeutrals` palette, an entry in `_schemeAccents`, and three font families registered the same way.

### A genuinely confusing test-only bug: new fonts render as solid blocks in `flutter test`
**Decision/finding:** adding a font family to `pubspec.yaml` is **not enough** for it to render in a golden test on this project. `test/flutter_test_config.dart` explicitly `FontLoader`-loads a fixed list of families before any test runs — pubspec registration alone only wires the family into the *real app's* asset bundle, and `flutter_test`'s binding doesn't consult that automatically. The eight new families all had to be added to that explicit list too.
**Why this was hard to isolate:** the failure mode (every string renders as a solid black rectangle, not tofu/missing-glyph boxes) looked exactly like a corrupt or unsupported font file. Ruled that out by re-pointing a *new* family name at the bytes of an already-working font (`Inter-Variable.ttf`) — it still rendered as blocks under the new name, proving the problem was about the family name never being explicitly loaded, not the file contents. `test/flutter_test_config.dart`'s own comment already named this exact gotcha for the original three fonts; it just hadn't been extended for the new eight.
**How to apply:** any future new font family needs a `_loadFont(...)` call added to `flutter_test_config.dart`, in addition to the `pubspec.yaml` entry — one is not a substitute for the other.

### Theme choice persists through the existing `Preferences` key/value table, not a new dependency
**Decision:** `SettingsRepository`-equivalent logic (`settings_providers.dart`) reads/writes a `'themeScheme'` key through the *existing* `PreferencesRepository`/`Preferences` table (§23.3, built in M4, previously unused by any real feature) rather than adding `shared_preferences` or a new Drift table.
**Why:** `PreferencesRepository`'s own doc comment invites exactly this ("callers define their own typed wrappers on top") — a single string setting doesn't justify a new dependency (CLAUDE.md: every new dependency needs a DECISIONS.md entry) or a schema migration, and it keeps the "every write is local-first" story (CLAUDE.md rule 6) uniform with everything else in the app.
**How to apply:** any future simple app-wide setting (not per-entity data) should default to a `Preferences` row with its own typed wrapper, the same way, before reaching for a new table or package.

### Settings hub is real navigation to every §22.5 section; only Appearance is built out
**Decision:** `SettingsScreen` lists all twelve `§22.5` sections with real `context.push(...)` navigation. Only Appearance (the theme picker) has a real destination screen; Account/Profile/Home/Notifications/Calendar/AI/Privacy/Data/Integrations/Subscription/About still resolve to the existing `NotBuiltYetScreen` placeholder.
**Why:** the same reasoning as the Library hub (M8) — a real, browsable menu with honest "not built yet" leaves (CLAUDE.md rule 1) rather than either hiding unbuilt sections (which would make the settings route table a dead end) or faking them with non-functional content.
**How to apply:** as each settings section gets built for real, swap its `_placeholderRoute` for a real `GoRoute` in `router.dart` — `SettingsScreen` itself doesn't need to change, since it already routes by the `Routes.settingsX` constant.

---

## M8 — Media Library, Rankings, Personal Lists & School Timetable (2026-08-27, ongoing)

### Films UI ships before Collections exists, so the watchlist screen has no Collections segment yet
**Decision:** `FilmsScreen` (Watchlist/Watched/Favourites) omits the "Collections" segment the brief's Part 3 sketches, and the long-press/detail actions don't offer "add to collection" yet.
**Why:** Part 28's `MediaCollection` (reusing `collections`/`collection_items` per the Top-N-lists decision above) hasn't been built yet in this milestone's sequence — a Collections tab with nothing behind it would be a fake affordance, which CLAUDE.md rule 1 rules out.
**How to apply:** when Part 28 ships, add the Collections segment to `FilmsScreen` (and its TV/Books equivalents) rather than building a separate collections browser; the grid/tile/menu machinery already built here is meant to be reused, not duplicated.

### M8 is a custom milestone brief, not `LIFE_OS_SPEC.md`'s own M8
**Decision:** the project owner supplied a large, self-contained M8 spec (Media Library covering Films/TV/Books with ratings, Top-N lists and Plan-based scheduling, plus an entirely new School Timetable system) that reorganises and significantly expands `LIFE_OS_SPEC.md`'s own M8 (Goals) through M13 (Books/Notes) and pulls pieces of M16 (AI) forward. Treating the pasted brief as this milestone's actual spec, the same way `LIFE_OS_SPEC.md` itself is treated elsewhere — cross-referenced against the existing spec's relevant sections (§15, §16, §19) rather than ignored, since much of the existing architecture (see below) was already designed for exactly this.
**How to apply:** `LIFE_OS_SPEC.md`'s own M8 (Goals)/M9 (Projects)/M10 (Habits) are deferred until after this M8 — Goals/Projects still show `NotBuiltYetScreen`, unchanged.

### Films/TV/Books reuse `library_items`, not new per-type tables
**Decision:** the brief's Part 41 proposes separate `Film`/`TVShow`/`Book`/`FilmRating`/`FilmLog`/… tables. Built on the existing `library_items` polymorphic table (§16.3, from M4) instead — it already has `mediaType`, `status` (wishlist/inProgress/done/abandoned — one vocabulary for "want to watch/reading/watched" per §16.3), `rating`, `isFavourite`, `notes` (the personal log), `startedAt`/`finishedAt`, poster/genre/creator fields.
**Why:** the brief's own Part 45 rules say "identify reusable components" and "do not duplicate existing functionality" — `library_items` already *is* Part 41's proposed schema, just unified across the three media types the way §16.3 deliberately designed it, so the query/sort/filter layer (rating history, stats, watchlist) is one implementation instead of three.
**How to apply:** only build new tables for what `library_items` genuinely can't express — per-episode TV data and Top-N rankings (both below).

### Per-episode TV tracking is un-postponed
**Decision:** M1's `POSTPONED.md` explicitly deferred per-episode tracking ("series-level tracking covers the primary use case"). The project owner explicitly asked to reverse that for M8 (Parts 10-15, including 1-6★ episode ratings) when asked directly. New `tv_episodes` table: one row per episode, combining cached TMDB metadata with the user's own watched/rating/log state — same shape `library_items` already uses for the show itself.
**How to apply:** `POSTPONED.md`'s entry is removed rather than struck through, per that file's own convention ("if something later gets built, move it out ... instead of deleting the row") — moved here instead, since this *is* the note of which milestone shipped it.

### The 6-star episode rating is a distinct tier, never averaged as "out of 5"
**Decision:** `tv_episodes.rating` stores 0–6 in 0.5 steps; `AppTvEpisode.isPersonalFavourite` is `rating >= 6`. Nothing derives a show's overall rating from its episodes' ratings, or vice versa (Part 42, explicit) — `library_items.rating` (the show) and `tv_episodes.rating` (each episode) are written by entirely separate repository methods with no cross-reference.

### Top-N lists ("Top 5 Films", "Top 5 TV Shows", "Top 3 Books") are their own table
**Decision:** a new `top_list_items(id, userId, mediaType, libraryItemId, rank)` table, not a repurposed `collections` row.
**Why:** considered modelling a Top-N list as a system-managed `Collections` row (it's structurally an ordered, capped list of item refs, which `collections`/`collection_items` already are). Rejected because a Top-N list has exactly one instance per `(userId, mediaType)`, a hard cap the repository enforces (5/5/3 — Part 42), and specific "1./2./3." ranking UI — bolting that onto the general-purpose, arbitrarily-many, user-named `collections` concept would mean filtering "system" rows out of every collections query for the rest of the app's life. A plain `MediaCollection` for user-named lists (Part 28) still reuses `collections`/`collection_items` directly — that one *is* the same shape.
**How to apply:** `reorder()` writes ranks in two passes (negative placeholders, then final values) — a straight one-pass rewrite can transiently collide with the table's `(userId, mediaType, rank)` unique index when a permutation asks for a rank another not-yet-moved row still holds. Caught by a real test (`reorder rewrites ranks to match the given order`), not spotted in review.

### A recurring `insertOnConflictUpdate` footgun, now a house rule
**Decision/finding:** `into(table).insertOnConflictUpdate(companion)` is only safe for a **sparse** partial update (a companion that omits some of the table's `NOT NULL` columns) when the row doesn't already exist in a way that matters — for an *existing* row it can silently fail to apply, the same bug M7's `PlanRepository._setArchived` hit and fixed by switching to `update(table).where(...).write(companion)`. `TvEpisodeDao` hit it again this milestone (`updateUserState`) before a test caught it.
**How to apply, going forward:** use `insertOnConflictUpdate` only when the companion supplies every `NOT NULL` column (a full-row rewrite, `library_items`' and `plans`' own `_save` pattern) or for genuine insert-or-fully-replace cases. Use `update(table).where(...).write(companion)` for any partial/sparse update to a row that may already exist — this is now the default choice for new sparse-update DAO methods, not `insertOnConflictUpdate`.

### `MediaMetadataProvider` returns `Result`, not the spec's bare `Future`
**Decision:** §16.2's own interface sketch uses plain `Future<...>` return types. Implemented with `Future<Result<T, Failure>>` instead, matching every other repository in this codebase.
**Why:** a bare `Future` that can throw would be the only error-handling convention in the app that doesn't go through `Result`/`Failure` — every call site would need a special try/catch just for media calls. `TmdbMetadataProvider`/`OpenLibraryProvider` still implement the exact same *shape* (search/detail/trending/imageUrl) §16.2 asks for.

### TMDB: built code-complete now, key supplied later
**Decision:** `TmdbMetadataProvider` is a real implementation against TMDB's documented v3 API (search, detail with credits, season/episode listing, trending), gated by `isConfigured` exactly like `isSupabaseConfigured` — the project owner will register for a free TMDB API key and supply it via `--dart-define=TMDB_API_KEY=...` when ready, the same pattern as Supabase's URL/anon key.
**Why:** same category as M4's Supabase auth — creating an account is something only the project owner can do. Unlike Supabase, this doesn't block anything else in the milestone: Books (Open Library, no key) can ship and be verified live in the meantime, and Films/TV UI can be built and tested against a fake `http.Client` now, then smoke-tested for real the moment a key exists.
**How to apply:** run with `flutter run --dart-define=TMDB_API_KEY=your_key_here` once a key exists. Until then, `isTmdbConfigured` is false and Films/TV search shows the honest "not configured" state (§16.7) — manual add remains available.

### TMDB's genre list is embedded as a static map, not fetched
**Decision:** `tmdb_genres.dart` hard-codes TMDB's published `/genre/movie/list` and `/genre/tv/list` taxonomies (19 and 16 entries) rather than calling those endpoints.
**Why:** this is TMDB's fixed, publicly documented vocabulary, not their catalogue or search results — embedding it avoids a network round-trip on every single search purely to resolve `genre_ids`, and isn't the "bulk-caching their catalogue" §16.2 actually prohibits.

### Provider tests: fake client for CI, one real call kept separate and tagged `live`
**Decision:** `tmdb_metadata_provider_test.dart`/`open_library_provider_test.dart` use an injectable fake `http.Client` (deterministic, no network, no key needed) and are what `flutter test`/CI run. `open_library_provider_live_test.dart` makes one genuine call to the real Open Library API (the one provider this session can verify live, needing no key) — tagged `live`, run via plain `dart test` (not `flutter test`, whose `TestWidgetsFlutterBinding` forces every real `HttpClient` request to fail with a fake 400), and excluded from the standard suite (`ci.yaml` now runs `flutter test --exclude-tags=live`) so a flaky network or an Open Library outage never breaks CI.
**How to apply:** any future live-network check follows this same file-per-check, `live`-tagged, plain-`dart test` pattern.

### The School week-parity engine re-anchors on drift rather than modelling holiday conventions
**Decision:** `weekLabelFor` computes Week A/B purely as calendar-weeks-since-anchor, parity-alternating, regardless of closures. If a holiday breaks the alternation in a way a school announces explicitly (returning as "Week B" after an odd-length break) rather than lets fall out of pure week-counting, the fix is the user editing `SchoolProfile.anchorDate`/`anchorWeekLabel` to the actual return day, not the engine guessing school-specific conventions.
**Why:** real schools' holiday-length-vs-parity conventions vary and aren't knowable in general; a single, always-correctable anchor is simple, testable, and matches how the recurrence engine's own `anchor` field works — one source of truth the rest of the maths derives from, correctable rather than clever.
**How to apply:** if this genuinely causes friction (frequent manual re-anchoring), the fix is a UI convenience — "set this week's label" — that just rewrites the anchor, not a change to the engine's maths.

### AI (Parts 35-40): shell only, no live model calls
**Decision:** built nothing that calls a real language model this milestone. §19.1 is explicit and non-negotiable — the model API key must never exist on the device; the real architecture is a Supabase Edge Function the client calls over HTTPS, which needs a live Supabase project (still blocked, same as M4/M19) and a deployed function, neither of which exists.
**Why:** there's no way to build a working AI chat without that infrastructure regardless of how much of the rest of M8 ships. What's genuinely buildable now — and where the effort actually goes — is the Settings → AI permission-scopes UI (inert until there's a backend to enforce it) and making sure the media/school/plan repositories built this milestone are already shaped like the eventual tools (§19.4's `get_films()`, `get_timetable()`, `assign_media_to_occurrence()` etc. are, or will be, just repository methods — no separate "AI-facing" API layer to build later).
**How to apply:** when Supabase + an Edge Function exist (this needs the project owner's account, same as M4), wire the permission scopes to actually gate context building, and give the Edge Function the repository methods as its tool implementations.

---

## M7 — Plan calendar + unified calendar (2026-08-27)

### Occurrence status stays at five values; "moved" is derived, not stored
**Decision:** §8.1 lists six statuses (`pending | completed | skipped | missed | moved | cancelled`), but `OccurrenceStatus` only has five — `moved` isn't one of them. A moved occurrence's calendar glyph is rendered by checking `pending && originalDate != null` instead.
**Why:** §8.4 step 1 itself sets a moved occurrence's status to `pending` (not `moved`) — the six-value list and the move algorithm's own first step disagree, and the algorithm is the more specific, mechanism-describing text. Storing a `moved` status that the spec's own move procedure never actually writes would create a column value nothing ever produces.

### Skip and the missed-policy "skip" outcome are different things, both real
**Decision:** M6 already used `status = 'cancelled'` for §9.6's `missedPolicy: skip` outcome and for pause-window occurrences (both spec'd verbatim that way). M7 adds a genuinely distinct `status = 'skipped'` for §8.5's user-initiated "Skip" action. Both are neutral for streaks and completion rate; they're just different sources (system-applied vs. an active user choice) and now have different history labels ("cancelled" vs. "skipped") so a user can tell which happened.

### Occurrence CRUD stays on `PlanRepository`; no separate `OccurrenceRepository`
**Decision:** §8.7 names `PlanRepository` and `OccurrenceRepository` as separate deliverables; this session kept everything on one `PlanRepository` (move/skip/remove/add-extra joined the create/edit/complete methods already there from M6). See the class doc comment in `plan_repository.dart` for the reasoning — every occurrence operation already needs its plan's rule/`missedPolicy`/`scheduleMode`, so splitting the class would just relocate that dependency rather than remove it.

### Unified calendar: Month and Day views only; Week and 3-day deferred
**Decision:** built the two views that between them prove out both layout paradigms (a grid and a time-ordered list with `LDayRail`) and satisfy the DoD's own "month view... 60fps" line. Week and 3-day — each essentially N columns of the Day view's hour-rail layout side by side — aren't built.
**Why:** Week and 3-day are real, additional work (a multi-column variant of the Day view, with its own horizontal-scroll/column-sizing logic), not a rendering tweak, and neither is named in M7's DoD checklist. Building two views well read as better use of the time than four views built thin.
**How to apply:** implement Week as N `_DayView`-style columns sharing one `LDayRail`-per-column layout; 3-day is the same component with `N=3`. Both can reuse `_CalendarData` and `_CalendarItem` unchanged.

### Pinch-to-morph between calendar views is a segmented toggle instead
**Decision:** §14.2 asks for "pinch to move between Day → 3-day → Week → Month"; this session built a plain Day/Month `LSegmented` toggle.
**Why:** a real pinch gesture that continuously morphs between four distinct layouts (not just zooms a single canvas) is a substantial custom-gesture-recognizer-plus-cross-fade-animation project on its own, disproportionate to the rest of M7 and not covered by the DoD. Swipe-to-change-period (§14.2's other gesture) is also not wired up yet for the same reason — "Today" and the chevron buttons cover period navigation for now.
**How to apply:** revisit once Week/3-day exist too (above) — a 4-way pinch is more meaningfully testable once there are 4 real views to morph between.

### Device calendar read-only import is not built
**Decision:** §14.4's `device_calendar` integration (permission flow, per-calendar toggles, grey read-only imported events) isn't implemented. The `Events.source`/`externalId` columns exist in the schema and `AppEvent.isFromDevice` is already there for when this lands, but nothing writes a `source = 'device'` row yet.
**Why:** same category as M4's Supabase auth — a third-party plugin needing a real OS permission dialog to verify, which isn't meaningfully testable on this Windows dev machine without a device. Unlike Supabase (needed for core sign-in), this is also an explicitly opt-in, additive feature the app already works fully without (§14.4: "if permission is denied, the calendar still works with Life OS's own events").
**How to apply:** add the `device_calendar` dependency and settings screen once there's a device to grant the calendar permission on and verify the import against.

### Events don't support recurrence yet
**Decision:** `Events.recurrenceRule` exists in the schema (§23.3) but `AppEvent`/`EventRepository` don't read or write it — every event created through `EventDetailScreen` is a single occurrence.
**Why:** a recurring-event materialiser would be a second, event-shaped implementation of the same idea Plans already solve properly with a tested engine; §7.1's "don't build the hardest logic twice" reasoning (binding for habits-as-plans) applies just as much here, and nothing in M7's DoD calls for recurring events specifically.
**How to apply:** if recurring events turn out to be genuinely needed, prefer teaching the calendar to render a Plan/occurrence as a "system event" over building a parallel recurrence path for the `events` table.

### The unified calendar merges tasks, events and plan occurrences — not all seven §14.1 sources
**Decision:** §14.1 lists events, tasks, plan occurrences, habit occurrences, goal milestone dates, reminders, and scheduled films/study sessions. Habit occurrences need no separate handling (§7.1: habits are plans, so they're already plan occurrences). Goal milestones (M8), reminders (M17) and scheduled films/study sessions (the Plan↔Library link, M12) aren't on the timeline yet because none of those data sources exist.
**How to apply:** each source folds into `_CalendarData`'s `items` list the same way tasks/events/occurrences already do, the moment its owning milestone ships real data — same pattern as Home's `focus` card and M6's Plans-list sort options.

---

## M6 — Recurrence engine + Plans (2026-08-27)

### Occurrence CRUD lives on `PlanRepository`, not a separate `OccurrenceRepository`
**Decision:** §8.7 names `PlanRepository` and `OccurrenceRepository` as two separate deliverables; this session built one `PlanRepository` that owns both plans and their occurrences (`watchUpcoming`, `watchHistory`, `completeOccurrence`, `_regenerate`, stats, the missed sweep).
**Why:** every occurrence operation needs the owning plan's rule, `missedPolicy`, `scheduleMode` and `startDate` to do anything (materialise, sweep, roll a rolling-mode plan forward) — splitting occurrence CRUD into its own class would mean either that class taking a `PlanRepository` dependency anyway, or duplicating plan-lookup logic on both sides. One class matches how the two pieces of data are actually used together everywhere in this codebase so far.
**How to apply:** if `OccurrenceRepository` genuinely earns its own class later (e.g. the calendar work in M7 needs occurrence queries with no plan context, like "every occurrence across every plan this week"), split it out then — extending `PlanRepository` is cheaper until that need is concrete.

### Regeneration and the missed sweep run opportunistically, not on a true midnight/resume job
**Decision:** `ensureMaterialised` runs when a plan is created, edited, or its detail screen opens (three of §9.5's five triggers); `applyMissedSweep` runs once whenever the Plans list screen opens. Neither runs on `AppLifecycleState.resumed` or a genuine local-midnight timer — the other two §9.5 triggers ("app resume" and "the daily maintenance job").
**Why:** same category of deferral as Home's date-rollover service in M5 (see that entry) — a real background scheduler is infrastructure shared by several features (Home's own midnight rollover, notifications later) and deserves one implementation, not a Plans-specific stopgap. Opening the Plans list is a good-enough proxy for "the user is here, make sure the data's current" until that shared piece exists.
**How to apply:** when a real app-lifecycle/midnight service is built (likely alongside Home's rollover, or notifications in M17), wire `PlanRepository.applyMissedSweep` and per-active-plan `ensureMaterialised` calls into it instead of the Plans screen's `initState`.

### Rhythm editor: six presets over one shared "every N (days/weeks/months)" control, "Custom" unlocks all seven rule types
**Decision:** §7.3's mockup shows six preset buttons above a single "Every [N] [unit ▾]" field. Read that as: the first four presets (day/other day/3 days/weekly) and "Specific days" all drive that one shared control (unit=days → `IntervalDays`, unit=weeks with no explicit days → `WeeklyDays` on the anchor's own weekday, "Specific days" → `WeeklyDays` with a user-picked day set); "Custom" replaces it with a full seven-type picker covering `MonthlyDay`, `MonthlyWeekday`, `Yearly`, `CustomDates` and `TimesPerPeriod` too, per §7.3's explicit "Custom opens the full rule editor with all seven rule types" line.
**Why:** the mockup's simple control genuinely can't express five of the seven rule types, but the prose is explicit that all seven must be reachable somewhere — "Custom" is that somewhere. This was the only reading that satisfies both the mockup and the prose without inventing a rule type the engine doesn't have.

### Habit creation still goes through `NotBuiltYetScreen`
**Decision:** `PlanCreateScreen` (the three-step wizard) always creates `kind: PlanKind.plan` — there's no path to `kind: PlanKind.habit` yet, even though the data layer fully supports habits (`watchHabits`, the Habits segment, `PlanRow` rendering either kind identically).
**Why:** §7.1's binding rule ("habits are plans") is about the *engine*, which is shared and done. The *UI* difference — "one step instead of three, daily default, streaks/heatmap presentation instead of a schedule list" — is its own deliverable explicitly sequenced at M10 (§38 item 15). The Habits tab itself is still `NotBuiltYetScreen`, so there's nowhere for a habit-creation entry point to live yet regardless.

### Plans list: no category filter, no "next due"/"completion rate" sort
**Decision:** §7.4 asks for sort by next-due/recently-created/alphabetical/completion-rate and a category filter. Built recently-created (the default row order) and alphabetical only; skipped the category filter chips.
**Why:** minor relative to the rest of M6 — "next due" and "completion rate" sorts need a per-plan async lookup (next fire date, or the same stats computation the detail screen does) at list-render time for every row, which is a real perf question worth its own pass rather than a quick add-on. Smaller in scope than the parser/Home-card deferrals, noted here rather than asked about separately.
**How to apply:** add the two remaining sort modes once there's a cheap way to get "next due" per plan without N extra stream subscriptions (e.g. batching through `HomeSnapshot`-style single composed query, §5.5's own lesson).

### Occurrence content slot ("+ choose a film") isn't rendered
**Decision:** §7.5 says every future occurrence of a `mediaType != none` plan gets a tap target to attach a library item. `PlanDetailScreen`'s Upcoming rows never show it, regardless of `mediaType`.
**Why:** there's nothing to attach to until Library/Films exists (M11/M12) — rendering the affordance now would be exactly the dead-button problem rule 1 exists to prevent.
**How to apply:** add the content slot to the Upcoming row once `LibraryRepository` (M11) exists to back a picker.

---

## M5 — Tasks, Home v1, Quick Add (2026-08-27)

### Quick Add ships as a type-picker only; the Layer 1 NLP parser is deferred
**Decision:** built the §6.2 type picker (6 primary tiles + 6 secondary chips) — only "Task" navigates anywhere, every other tile shows an `LToast` reading "$type creation is on the roadmap but hasn't shipped," and the "Ask AI" entry point from the mockup isn't rendered at all. **Not built:** the local Layer 1 natural-language parser and its 120-case test suite that §38's roadmap (item 9) also assigns to M5 — Quick Add does not parse free text into a typed item at all yet, it's tile-selection only.
**Why:** Events, Plans, Habits, Goals, Notes, etc. don't have creation flows yet (that's M6/M7/later), and several don't even have a "new" route in §3.2's table to send them to — a tile that navigates to a wrong or half-built screen is worse than one that's honest about not existing yet (rule 1). The parser itself is a separate, self-contained pure-Dart engine on the same scale as the recurrence engine (M6-core) — parsing dates, times, types and modifiers out of free text, proven against 120 golden cases — and building it as a rushed add-on inside a session also covering M6 and M7 risked the same shortcut-taking the recurrence engine was deliberately built standalone to avoid. "Ask AI" needs both this parser and an AI proxy that doesn't exist until M16, so it's omitted entirely rather than present-but-dead.
**How to apply:** dedicate a future session to a `core/nlp/` (or similar) pure-Dart parser with its own 120-case golden suite, gated the same way the recurrence engine was — no UI until every case passes. Once it exists, Quick Add's sheet gains a text-entry mode above the tile grid; as each type's creation flow ships, swap its tile's `_select` branch from the toast to a real `context.push`.

### Home ships with 3 of the 6 spec'd first cards; customise screen and rollover service deferred
**Decision:** built `focus`, `upcoming`, `recent` — the only 3 of §5.3's 15-card catalogue with a real repository behind them at M5. **Not built:** `plansToday`, `habits`, `goals` (the rest of §38 item 8's "first six cards"), the `DashboardCustomiseScreen` (drag-reorder, visibility toggles, size selector), the `dashboard_cards` table + repository, and the §5.6 midnight-rollover / `AppLifecycleState.resumed` recompute service.
**Why:** `plansToday` needs `OccurrenceRepository` (M6), `habits` needs the habit data model (M10), `goals` needs goal progress (M13) — none exist yet, so those 3 cards would either render against empty tables that don't exist (fake) or need those milestones' full data layers built early, which is a much bigger scope explosion than Home itself. A drag-reorder customise screen is premature plumbing for 3 fixed cards there's currently no reason to hide or reorder. The rollover service matters most once a session can genuinely span midnight or a suspend/resume cycle with visible state to refresh; with only tasks behind Home, Drift's existing live-query streams already pick up same-day writes immediately, so the gap is real but lower-stakes for now.
**How to apply:** each of `plansToday`/`habits`/`goals` is added to `HomeSnapshot` and gets its own card widget the moment its owning milestone (M6/M10/M13) ships real data — same pattern as the cross-domain `focus` merge below. Build the customise screen once there are enough real cards (5-6) to make reordering meaningful, backed by a real `dashboard_cards` table at that point, not before. Build the rollover `Timer`-at-midnight + resume listener alongside it or whenever an actual overnight-session bug report justifies it, whichever comes first.

### Home's cross-domain merge is tasks-only for now
**Decision:** `HomeSnapshot`'s `focusItems` (Today) and `upcomingByDay` counts are built entirely from `TaskRepository` queries. §5.3's actual model — Today merges events, plan occurrences, and tasks into one list — isn't implemented; there's nothing from Plans or Calendar to merge yet.
**Why:** M6 (Plans/occurrences) and M7 (Calendar/events) don't exist yet, so a "merge" today would just be tasks with extra unused code paths. `home_providers.dart` composes only the task providers now; the merge becomes real (and testable — §5.6's edge cases actually need multiple sources to be meaningful) once M6 and M7 land.
**How to apply:** when `OccurrenceRepository` and a calendar `EventRepository` exist, extend `homeSnapshotProvider` to fold their "due/occurring today" queries into `focusItems` alongside tasks, sorted per §5.3's ordering rule.

### Drift's stream-cleanup timer needs a forced-flush pattern in every widget test that reaches a database-backed screen
**Decision:** any `flutter_test` that renders a screen backed by a Drift stream query (`TaskDetailScreen`, `HomeScreen`, and — because `StatefulShellRoute.indexedStack` keeps every branch mounted — any test whose router starts at `/home` even if it navigates elsewhere) must end with `await tester.pumpWidget(const SizedBox()); await tester.pump(Duration.zero);` before the test body returns.
**Why:** Drift schedules a zero-duration cleanup `Timer` when a stream query's last listener unsubscribes, which only happens once the widget is actually unmounted — normally after the test body returns, too late for an in-body `pump` to catch, which trips `flutter_test`'s "no pending timers" assertion. Discovered on the `/task/:id` deep-link test in M5-core, then hit again on four more `route_resolution_test.dart` cases and both `widget_test.dart` cases once Home stopped being a static placeholder and started as the router's real, database-backed `initialLocation`.
**How to apply:** add the same two lines to any new widget test whose router setup can reach a live-query screen, including ones that never navigate there directly — Home's `IndexedStack` branch means it's always mounted once the app boots.

---

## M4 — Local database and auth (2026-08-26)

### Full 30-table Drift schema now; full Postgres/RLS mirror deferred per-table
**Decision:** implemented all 30 SQLite tables from §23.3 in Drift now (§33 M4 explicitly says "for all tables"), but wrote the Postgres + RLS mirror in `supabase/schema.sql` for only `profiles` and `preferences` — the two tables M4's own repository scope actually covers.
**Why:** RLS policies I can't deploy or test yet (no live Supabase project) are much more likely to be wrong than ones I write alongside the code that will actually exercise them. Writing all 30 tables' RLS blind, this far ahead of the sync work (M19) that would ever call them, seemed like exactly the kind of "no half-finished implementations" the project avoids elsewhere. Each feature milestone adds its own table's Postgres mirror + RLS when it adds that table's repository.

### Supabase auth is real code, not yet a tested integration
**Decision:** `AuthRepository`, `supabase_client.dart` (with a `flutter_secure_storage`-backed session store, not the default SharedPreferences one), and `supabase/schema.sql`'s RLS policies are all written and compile, but none of it has run against a live Supabase project — this machine doesn't have one.
**Why:** same category as M1's GitHub/Codemagic accounts — creating and configuring a third-party project needs the project owner's account, not something this session can do unilaterally. `isSupabaseConfigured` gates every method so the app fails clearly (an `AuthFailure`) rather than silently misbehaving without one.
**How to apply:** M4's actual DoD line — "sign up, sign out, sign in, kill app, session persists; a second account cannot read the first's rows (test against the live project)" — is **not verified**. Once a Supabase project exists: run `supabase/schema.sql`, supply `SUPABASE_URL`/`SUPABASE_ANON_KEY` via `--dart-define`, and run that exact test manually (create two accounts, confirm cross-account row access fails).

### Sign-in/sign-up/reset screens stay placeholders
**Decision:** `/auth/sign-in`, `/auth/sign-up`, `/auth/reset` still render `NotBuiltYetScreen` (from M3) rather than real forms wired to `AuthRepository`.
**Why:** Apple and Google sign-in need their own external configuration (Apple Developer account, Google Cloud OAuth client) beyond just a Supabase project, so even a "complete" auth UI would have two of three methods non-functional regardless. Building the email form alone now, then coming back to add two buttons later, seemed more likely to produce visible rework than waiting until all three can be wired at once.

### Riverpod/DI wiring deferred to the first feature that needs it (M5)
**Decision:** `AppDatabase`/`ProfileRepository`/`PreferencesRepository`/`AuthRepository` are constructed directly in tests, not exposed through any app-wide provider yet — `bootstrap.dart` only calls `initializeSupabase()`.
**Why:** CLAUDE.md's own conventions name Riverpod as the state-management choice, but nothing in the UI reads from these repositories yet (M4 has no UI deliverable). Adding `flutter_riverpod` and a provider tree with zero consumers is exactly the kind of premature plumbing the project's own minimalism rule warns against. M5 (Tasks + Home v1) is the first milestone that actually needs a widget to read live data, so that's where DI wiring starts for real.

### Drift's reserved `tableName` identifier
**Decision:** the `outbox.table_name` and `sync_state.table_name` columns from §23.3 are implemented as `target_table` (Dart getter *and* SQL column name) instead.
**Why:** `Table` (Drift's base class) reserves a member literally named `tableName` to mean "override this table's own SQL name." A regular *column* named `table_name` round-trips through Drift's snake_case-to-camelCase conversion to a Dart getter also called `tableName`, which collides — and critically, renaming only the Dart-side getter (keeping the SQL column named `table_name` via `.named(...)`) does *not* fix it, because drift_dev's schema-snapshot tooling (used for migration testing, §23.4) regenerates historical table classes from the SQL column name alone. The actual SQL name had to change. First real deviation from the spec's literal DDL, forced by tooling rather than a judgment call.

---

## M3 — Navigation shell (2026-08-26)

### Five full tabs, not four-plus-a-nub
**Decision:** the bottom bar renders five equal, fully-labelled tabs (Home, Plans, Tasks, Library, Stats); the `+` FAB floats above the boundary between Plans and Tasks without removing Tasks' own label.
**Why:** §3.1's ASCII mockup shows only four text labels with no "Tasks," but the prose two lines later names all five tabs with no exception, and the design note only says the FAB floats *between* Plans and Tasks — it never says Tasks loses its label. Reducing a primary destination to an unlabelled nub seemed like reading too much into an ASCII-art approximation. Full reasoning + a code comment where the decision lives, in `shell_scaffold.dart`.

### `/occurrence/:id` deep link doesn't resolve
**Decision:** the §3.4 deep-link alias `/occurrence/:id` renders its own honest placeholder rather than redirecting into `/plans/:id/occurrence/:occId`.
**Why:** the in-app route needs a plan id the deep link never carries; resolving "which plan does this occurrence belong to" needs a real `OccurrenceRepository` lookup, which doesn't exist until M7. Revisit then — see the comment in `deep_links.dart`.

### Settings has 12 subroutes, not 11
**Decision:** built all 12 sections §22.5 actually lists (Account, Profile, Appearance, Home, Notifications, AI, Privacy, Data, Calendar, Integrations, Subscription, About).
**Why:** §3.2 says "+ 11 subroutes, see §22," but §22.5 numbers 12. Same category of stale cross-reference as M2's component-count issue — trusted the detailed section over the summary line.

### No `IntegrationTestWidgetsFlutterBinding` route verification
**Decision:** M3's DoD line "every route in §3.2 resolves; back behaviour correct on Android; deep links open the right screen" is verified with a `flutter_test` widget test driving `GoRouter.go()` through every path (`test/routing/route_resolution_test.dart`), not a real on-device integration test.
**Why:** no Android emulator or physical device is available on this machine (see the M1 emulator entry above) — `integration_test` needs one. The widget-test approach catches route-definition bugs (typos, missing builders, param mismatches) but can't verify real Android back-button behaviour or OS-level deep-link delivery. Re-run properly once a device is available.

### `AppConfig.instance` is `late`, not `late final`
**Decision:** dropped `final` from the static `instance` field in `lib/core/config/flavor.dart`.
**Why:** `flutter test` runs every test file in one isolate, so a second file's `setUp(() => AppConfig.initialize(...))` hit `LateInitializationError: already initialized`. Re-initializing app config is harmless — it's just a flavor tag, not something with side effects that compound.

---

## M2 — Design system (2026-08-26)

### Golden test tooling: plain `flutter_test`, not `golden_toolkit`
**Decision:** goldens use `flutter_test`'s built-in `matchesGoldenFile`, with a hand-written `test/flutter_test_config.dart` that loads the bundled fonts (and the Material Icons font) before any test runs, rather than `golden_toolkit`'s `loadAppFonts()`.
**Why:** §32/§34 name `golden_toolkit`, but it's been pub.dev-flagged **discontinued** for three years — directly contradicting the spec's own package rule ("avoid anything unmaintained for over 12 months"). Per CLAUDE.md: "If a section of this spec turns out to be wrong in practice, change the spec in the same commit as the code." §32/§34 are updated accordingly in this commit.
**How to apply:** any future golden test just needs `test/design/golden_harness.dart`'s `pumpGolden`/`goldenMatrix` helpers; no new dependency.

### `statNumber` uses the Data (mono) family, not Display
**Decision:** the big number in `LStat` (e.g. "47") renders in `IBMPlexMono`, not `InstrumentSans`.
**Why:** §2.3 has an internal conflict — the Display-family bullet lists "big stat numbers," but the later "signature typographic move" paragraph says *any number representing a measurement* is set in mono with tabular figures "so columns align," which is a direct description of the §7.5 stats-strip mockup. The more specific, mechanism-explaining rule wins; the caption underneath (e.g. "done") was never ambiguous — it's mono either way.

### Component count: 26, not "30"
**Decision:** built exactly the components named in §2.7's list — 26, not the "all 30 components" figure in §33's M2 entry.
**Why:** counted the §2.7 list twice; it names 26. Rather than inventing 4 more to hit a round number the spec itself doesn't specify, built what's actually listed. §33 is corrected to say 26 in this commit.

### `ThemeData.textTheme` is derived from `LifeTextStyles`
**Decision:** added `buildLifeTextTheme()` mapping our type scale onto Flutter's `TextTheme` roles, applied in both `light_theme.dart` and `dark_theme.dart`.
**Why:** not spec-mandated explicitly, but discovered as a real bug while generating goldens — an unstyled `Text()` (which Material's own widgets like `AppBar`/`SnackBar`/`Dialog` use internally) fell back to Flutter's default Roboto-based theme instead of Inter/Instrument Sans, silently breaking rule 5 ("no raw values... everything comes from tokens") for any code path that doesn't manually apply `context.textStyles`. Confirmed via the `l_card` golden showing "tofu" boxes before the fix.

### Dark-mode accent "on" colour uses pure black, not the ink token
**Decision:** for accent/domain/semantic colours, the dark-theme `on` (text-on-fill) colour is computed against pure black/white, not the theme's `ink`/`ink2` tokens.
**Why:** dark-theme accent bases are lightness-lifted (per §2.2) to read well against the near-black page background, which makes them light/mid-tone colours in their own right — a *different* surface than the page background, so the page's near-white `ink` token is the wrong comparison. Verified by computing WCAG contrast for every accent/domain/semantic colour in both themes; all clear 4.5:1 this way (see `test/design/contrast_test.dart`).

---

## M1 — Project setup (2026-08-26)

### Toolchain install location
**Decision:** Flutter SDK, JDK 17 (Temurin), and the Android SDK command-line tools are installed under `D:\dev\`, not the default `C:\...` locations. `GRADLE_USER_HOME` and `PUB_CACHE` are also redirected to `D:\dev\gradle-home` and `D:\dev\pub-cache`.
**Why:** the `C:` drive had ~536MB free at setup time — not enough for the Flutter SDK, an Android SDK, and a Gradle cache (a single Android build can pull 500MB+ of Gradle dependencies alone).
**Rejected:** installing to the default `C:` paths and hoping disk pressure wouldn't bite — rejected because it would fail partway through the first `flutter build` in an unpredictable way.
**Follow-up:** if `C:` free space is recovered later, these can move back, but there's no need to.

### Application ID / org
**Decision:** org `app.lifeos`, project name `life_os`, giving Android `applicationId app.lifeos.life_os` and iOS bundle id to match. Dev flavor suffixes `.dev`.
**Why:** the spec never states a bundle id, but §3.4 establishes the domain `lifeos.app` for universal links, so the reverse-DNS org matches a domain the product already claims rather than inventing an unrelated one (e.g. `com.example`).
**Rejected:** `com.lifeos.*` — not wrong, but doesn't match the real domain in the deep-link spec.

### Lint package
**Decision:** `very_good_analysis`, per §32, with `public_member_api_docs` explicitly turned back off in `analysis_options.yaml`.
**Why:** `very_good_analysis` defaults that rule on, which is meant for published packages with external consumers. Life OS is an app; forcing a doc comment on every class before there's a single real feature would just be noise, and conflicts with the project's "no comments unless the why is non-obvious" style.
**Rejected:** leaving it on — rejected as pure lint-fixing busywork with no reader it serves.

### Flavours
**Decision:** `dev` / `prod` implemented as Android product flavors (`app.lifeos.life_os.dev` vs `app.lifeos.life_os`, differing `app_name` via `resValue`), with matching Dart entrypoints `lib/main_dev.dart` / `lib/main_prod.dart` and an `AppConfig`/`Flavor` class in `lib/core/config/flavor.dart`. `lib/main.dart` defaults to `dev` for plain `flutter run`.
**iOS flavors are NOT wired up yet.** Flutter iOS flavors need matching Xcode build configurations and schemes (Debug-dev, Release-dev, etc.), which means editing `ios/Runner.xcodeproj/project.pbxproj` and Xcode scheme files. Doing that blind, on Windows, without Xcode to open and verify the result, risks corrupting the Xcode project in a way that's hard to diagnose without a Mac.
**Follow-up:** the first time this project is opened in Xcode (a Mac, or the Codemagic macOS lane), add the `dev`/`prod` build configurations and schemes there, where they can actually be verified. Until then, `codemagic.yaml`'s iOS lane builds the single default `Runner` target using the `dev` Dart entrypoint, not a real Xcode flavor.

### Lint: line length
**Decision:** disabled `lines_longer_than_80_chars` in `analysis_options.yaml` on top of `very_good_analysis`.
**Why:** Flutter's declarative widget syntax (nested named-parameter constructors) routinely produces well-formatted lines past 80 columns even with sensible wrapping; the rule has no configurable width, only on/off, so keeping it on meant either fighting `dart format`'s own line breaks or fragmenting simple one-line widget props for no readability gain. Surfaced in M2 once the design components made the volume of 80+-char lines obvious.
**Rejected:** manually re-wrapping every flagged line — inspected the M2 component set and the wraps were consistently cosmetic, not clarifying.

### Sentry
**Decision:** `sentry_flutter` is a dependency and `bootstrap.dart` initializes it only when a `SENTRY_DSN` value is passed via `--dart-define`; with no DSN (the default for every local build), it's fully inert and errors just print to the console instead.
**Why:** "wired but opt-in" (M1 DoD) — there's no Sentry project/DSN yet, and none should be hard-coded into the repo per rule 7 (secrets never ship in the app) even once one exists; it'll be supplied at build time, not committed.

### CI / Codemagic
**Decision:** `.github/workflows/ci.yaml` (analyze, test, Android debug APK build) and `codemagic.yaml` (iOS smoke build, unsigned) exist in the repo, but neither has been run — there's no GitHub remote yet and no Codemagic account connected.
**Why:** creating a GitHub repo, pushing code, and connecting a third-party CI account are all actions visible to others / requiring credentials this session doesn't have; that needs the project owner to do or explicitly authorize.
**Follow-up:** once a GitHub remote exists, push and confirm the Actions run goes green — that's the actual M1 DoD check for "CI green," not just the workflow file existing.

### Android emulator (debug APK "installs" check)
**Decision:** an AVD (`life_os_test`, Pixel 6 profile, Android 15 x86_64 google_apis) was created under `D:\dev\avd`, but it was never booted successfully and M1's "debug APK installs" DoD line is verified only as "the debug APK builds," not as an actual install/run.
**Why:** the emulator refused to boot — "x86_64 emulation currently requires hardware acceleration... Android Emulator hypervisor driver is not installed on this machine." Fixing that means enabling the Windows Hypervisor Platform optional feature, which needs admin rights and a reboot. That's a system-settings change, and the project owner chose to skip the emulator rather than have it made on their behalf.
**Follow-up:** either enable Windows Hypervisor Platform (Turn Windows features on or off → check it → reboot) and retry `emulator -avd life_os_test`, or just test on a physical Android device over USB (`adb install build/app/outputs/flutter-apk/app-dev-debug.apk` once a device shows up in `adb devices`).

**Update (M8 session, 2026-08-27):** re-investigated when the project owner asked to run the app for the first time. The Android SDK, a system image (`android-35;google_apis;x86_64`), and a JDK (`D:\dev\jdk-17`) all turned out to already be present on this machine, just not on `PATH`/`JAVA_HOME` — with those set, `flutter doctor`'s Android toolchain goes fully green. Created a new working AVD, `life_os_pixel`, via `avdmanager` directly (`flutter emulators --create` failed to match the installed image; `avdmanager create avd -n life_os_pixel -k "system-images;android-35;google_apis;x86_64"` worked). It still hits the exact same hypervisor error as `life_os_test` above — confirming this was never actually an AVD-configuration problem, only ever the missing Windows Hypervisor Platform feature. That toggle is still admin+reboot territory and still left to the project owner; see `README.md`'s "Running the app" section for the exact commands (`PATH`/`JAVA_HOME` exports, the `Enable-WindowsOptionalFeature` command, and the emulator launch) now that they're known to work.

### Folder structure
**Decision:** only `lib/core/config/` exists so far, plus `lib/main.dart`, `app.dart`, `bootstrap.dart`. The full §31 tree (`design/`, `data/`, `features/`, `services/`, `routing/`, per-feature subfolders) is **not** pre-created empty.
**Why:** git doesn't track empty directories, so "creating" ~100 empty folders now would mean either committing a pile of `.gitkeep` placeholders for code that doesn't exist yet, or directories that silently vanish on clone — both read as scaffolding theatre for milestones that haven't started (rule 1: nothing fake). Each milestone creates its own real subtree when it adds real files.
**How to apply:** when M2 (design system) starts, create `lib/design/tokens/`, etc. with actual token files, not before.
