# DECISIONS.md — Life OS

Choices `LIFE_OS_SPEC.md` left open, and choices made during setup that a future session shouldn't silently re-litigate. Newest first.

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

### Sentry
**Decision:** `sentry_flutter` is a dependency and `bootstrap.dart` initializes it only when a `SENTRY_DSN` value is passed via `--dart-define`; with no DSN (the default for every local build), it's fully inert and errors just print to the console instead.
**Why:** "wired but opt-in" (M1 DoD) — there's no Sentry project/DSN yet, and none should be hard-coded into the repo per rule 7 (secrets never ship in the app) even once one exists; it'll be supplied at build time, not committed.

### CI / Codemagic
**Decision:** `.github/workflows/ci.yaml` (analyze, test, Android debug APK build) and `codemagic.yaml` (iOS smoke build, unsigned) exist in the repo, but neither has been run — there's no GitHub remote yet and no Codemagic account connected.
**Why:** creating a GitHub repo, pushing code, and connecting a third-party CI account are all actions visible to others / requiring credentials this session doesn't have; that needs the project owner to do or explicitly authorize.
**Follow-up:** once a GitHub remote exists, push and confirm the Actions run goes green — that's the actual M1 DoD check for "CI green," not just the workflow file existing.

### Folder structure
**Decision:** only `lib/core/config/` exists so far, plus `lib/main.dart`, `app.dart`, `bootstrap.dart`. The full §31 tree (`design/`, `data/`, `features/`, `services/`, `routing/`, per-feature subfolders) is **not** pre-created empty.
**Why:** git doesn't track empty directories, so "creating" ~100 empty folders now would mean either committing a pile of `.gitkeep` placeholders for code that doesn't exist yet, or directories that silently vanish on clone — both read as scaffolding theatre for milestones that haven't started (rule 1: nothing fake). Each milestone creates its own real subtree when it adds real files.
**How to apply:** when M2 (design system) starts, create `lib/design/tokens/`, etc. with actual token files, not before.
