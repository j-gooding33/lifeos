# CLAUDE.md — Life OS

Read this at the start of every session, before writing any code.
The full specification is in `LIFE_OS_SPEC.md`. This file is the standing rules.

---

## What this project is

Life OS: a Flutter (iOS + Android) personal life-management app. Offline-first, local SQLite as the source of truth, Supabase for auth and sync, AI proxied through an Edge Function.

Development happens on Windows. Android is the local target. iOS builds run in CI on a macOS runner.

---

## The nine rules

1. **Nothing fake.** No stub buttons, no mock API responses presented as real, no hard-coded film or book data, no "coming soon" screens that look functional. If a feature is not built, either it is absent from the UI or it renders an honest state saying so.

2. **One milestone at a time.** Work the milestone in `LIFE_OS_SPEC.md` §33. Do not start the next one until its Definition of Done passes. If you finish early, improve tests, not scope.

3. **The scheduling engine is pure Dart.** `lib/core/scheduling/` must never import `package:flutter`. Any change to it requires a new case in the golden table (§9.9). Never use `DateTime.add(Duration(days: n))` for civil-date arithmetic — use `CivilDate` day-number maths.

4. **Features do not import features.** `lib/features/tasks/` may not import from `lib/features/plans/`. Cross-feature work goes through `lib/data/repositories/` or `lib/core/events/`. Break this rule and the app becomes unmaintainable at about module twelve.

5. **No raw values in feature code.** No hex colours, no magic `EdgeInsets` numbers, no ad-hoc `Duration`s, no hard-coded strings that a user will read. Everything comes from `lib/design/tokens/` and the l10n files.

6. **Every write is local first.** UI → repository → one local transaction (entity + rollup + outbox) → stream updates the UI. The network is never in the path of a user action. There is no "saving…" spinner for a local write.

7. **Secrets never ship in the app.** The AI key and the TMDB key live only in Supabase Edge Functions. Before every release, grep the built artifact for key patterns. The Supabase anon key is the one exception and is only safe because RLS is correct — so treat RLS as a release gate.

8. **AI proposes, the user disposes.** The AI layer never writes to the database. It returns `ProposedAction[]`; the client shows a confirmation sheet; the user's tap performs the write through the normal repositories. Every AI-sourced change lands in `activity_log` with `source = 'ai'` and is undoable for 10 seconds.

9. **No guilt mechanics.** No streak-loss pressure, no red for a missed day, no loss-aversion copy, no comparisons to other users, no notifications designed to pull someone back in. "Missed", never "Failed". This is a product rule, not a style preference — flag any copy that breaks it.

---

## Definition of done for any piece of work

- [ ] `flutter analyze` is clean
- [ ] Tests pass, and new logic has new tests (pure logic: 95%+ coverage)
- [ ] Works with the network off
- [ ] Works in both light and dark themes
- [ ] Works at text scale 1.5 with no overflow
- [ ] Every interactive element has a semantic label; every swipe action has a long-press equivalent
- [ ] Empty state and error state exist and use the §30 copy deck
- [ ] No new dependency without an entry in `DECISIONS.md`

---

## Conventions

- **State**: Riverpod with codegen. Repositories expose Drift streams. Controllers are `AsyncNotifier`. `setState` only for local animation state.
- **Models**: `freezed` + `json_serializable`. Domain models never leak Drift or Supabase types into `features/`.
- **Errors**: return `Result<T, Failure>` from repositories. Never throw across a layer boundary. Map to user-facing copy in `core/errors/error_mapper.dart`.
- **IDs**: UUID v4 generated on the client, except generated occurrences which use the deterministic UUID v5 scheme in §9.7.
- **Dates**: civil dates as `TEXT 'YYYY-MM-DD'`, wall times as `TEXT 'HH:mm'`, instants as epoch-ms integers. Never mix them.
- **Money**: integer minor units. Never a `double`.
- **Naming**: files `snake_case.dart`, classes `PascalCase`, design components prefixed `L` (`LCard`, `LButton`).
- **Commits**: `M6: recurrence engine — interval rules + golden tests`. Commit at every green point.

---

## Files to keep updated

| File | When |
|---|---|
| `DECISIONS.md` | Any choice the spec left open, any new dependency. Record the alternative you rejected and why. |
| `POSTPONED.md` | Anything deliberately not built. Reason included. |
| `LIFE_OS_SPEC.md` | If reality contradicts the spec, fix the spec in the same commit as the code. |

---

## When to stop and ask

- The spec is silent and the choice is architectural (persistence, sync semantics, security).
- A requirement appears to conflict with a store guideline.
- A milestone's Definition of Done cannot be met without changing an earlier milestone's design.
- Something would require sending user content to a third party that the spec has not already authorised.

Do not invent an answer to any of these and carry on.
