# LIFE OS — Master Product & Technical Specification

**Version** 1.0
**Platform** Flutter 3.x → iOS 15+ / Android 8+ (API 26+)
**Development environment** Windows PC + Claude Code
**Audience for this document** Claude Code (implementation), plus the product owner

---

## 0. HOW TO USE THIS DOCUMENT

This is the single source of truth. It is written so that each numbered section can be pasted into Claude Code as a scoped work order.

**Rules of engagement for the implementer:**

1. Build in milestone order (§23). Do not jump ahead.
2. Every milestone has a *Definition of Done*. Do not open the next milestone until the current one passes it.
3. Nothing fake. No stub buttons, no mock film databases, no invented API responses. If a feature is not built, it does not appear in the UI, or it appears behind a `FeatureFlag` that renders an honest "Not available yet" state.
4. When this document conflicts with an assumption, this document wins. When this document is silent, ask before inventing.
5. Every recurrence-engine change must be accompanied by a test case added to the golden table in §9.9.

**Reading order for a fresh Claude Code session:**
`CLAUDE.md` → §1 → §2 → §3 → §23 (data model) → §9 (scheduling engine) → the milestone you are on.

---

## 1. PRODUCT OVERVIEW

### 1.1 One line

Life OS is a personal operating system: one app that holds your tasks, schedule, routines, goals and collections, and understands how they relate to each other.

### 1.2 The problem

People currently run their life across five or six apps: a to-do list, a calendar, a habit tracker, a watchlist, a notes app, a spreadsheet. Nothing knows about anything else. Your watchlist does not know you have a free Tuesday. Your goal to read 20 books does not know you read for 30 minutes last night. The user has to be the integration layer.

### 1.3 The core insight

Most life-management apps model **actions** (a to-do) or **habits** (a daily streak). Life OS models a third thing that sits between them: the **Plan**.

A Plan is *"a thing I intend to do repeatedly, on a rhythm I choose, over a period of time."*

- "Watch one film every 3 days"
- "Study biology every other day"
- "Visit somewhere new every month"

A Plan generates dated **Occurrences**. Occurrences are real, individually editable objects. You can skip one, move one, or attach content to one (this film, this chapter, this topic) without touching the rhythm underneath. That single idea is what makes the film scheduler, the study planner, the reading tracker and the habit tracker one feature instead of four.

**Everything else in the app hangs off this:** Goals measure Plan output. The Calendar displays Plan occurrences. Statistics aggregate them. The AI manipulates them. Your Year visualises them.

### 1.4 Who it is for

The primary user is an organised individual (student, professional, or hobbyist) who already keeps lists in three apps and wants one. They value aesthetics and speed more than enterprise features. They are willing to type a sentence to create something but will not fill in a twelve-field form.

### 1.5 Non-goals for v1

Explicitly out of scope, and the UI must not hint at them:

- Team collaboration, sharing, or multi-user anything
- Bank account connection (Open Banking / Plaid)
- Automatic time tracking or screen-time capture
- Email or messaging integration
- Web app (mobile only in v1; architecture must not prevent it)
- Media playback of any kind
- Social features, feeds, leaderboards, or public profiles

### 1.6 What "v1 is done" means

- A user can install, onboard in under 90 seconds, and have a personalised dashboard.
- Tasks, Plans, Habits, Goals, Projects, Calendar, Films, Books, Notes, Search, Statistics, Journal and Finance all work fully offline.
- Data survives app deletion via cloud sync and restores on a second device within 30 seconds.
- The recurrence engine passes 100% of the golden test table (§9.9).
- The AI can create and modify entities, always through an explicit confirmation step.
- Both stores accept the build: privacy manifest, account deletion, and accessibility audit all pass.

### 1.7 Product pillars

| Pillar | Meaning | Test |
|---|---|---|
| **One place** | Every module reads and writes the same graph | A Goal can be satisfied by a Plan, which is fed by a Film, which appears on the Calendar |
| **Two seconds** | Home tells you what matters before you think | Time-to-comprehension on cold open under 2s |
| **Rhythm, not rigidity** | Missing a day is normal and costs nothing | No red streak-break UI, no guilt copy |
| **Honest software** | Nothing is faked, nothing is dark-patterned | The free tier is a complete app |
| **Offline first** | The network is an enhancement | Airplane mode changes nothing except AI |

---

## 2. DESIGN SYSTEM

Build this first, in `lib/design/`, before any feature screen. Every screen consumes tokens. No raw hex values, no raw `EdgeInsets` numbers, no `Duration(milliseconds: 237)` anywhere in feature code.

### 2.1 Direction

Quiet, dense-but-airy, and typographically led. The interface is mostly neutral surfaces and one accent, so that data (charts, the year grid, progress rings) supplies the colour. Boldness is spent in exactly one place: **Your Year** (§21). Everything else stays disciplined.

Deliberate rejections, so the implementer does not drift back to them:
- No glassmorphism except on the tab bar and sheet scrims.
- No large gradient hero blocks.
- No drop shadows in dark mode; use surface elevation by lightness instead.
- No skeuomorphic textures, no neumorphism.
- No emoji as primary iconography (emoji are allowed only where the *user* chose one).

### 2.2 Colour tokens

Defined as `LifeColors` with `light` and `dark` variants, exposed via `ThemeExtension`.

**Neutrals — light**

| Token | Hex | Use |
|---|---|---|
| `bg` | `#FCFCFD` | Screen background |
| `surface` | `#FFFFFF` | Cards, sheets |
| `surfaceAlt` | `#F3F4F8` | Inset fields, chips, unselected segments |
| `surfaceSunken` | `#EDEEF3` | Track behind progress bars |
| `border` | `#E4E5EC` | 1px hairlines |
| `ink` | `#12131A` | Primary text |
| `ink2` | `#62636F` | Secondary text |
| `ink3` | `#92939F` | Tertiary text, disabled |

**Neutrals — dark**

| Token | Hex | Use |
|---|---|---|
| `bg` | `#0A0B0F` | Screen background |
| `surface` | `#14151B` | Cards, sheets |
| `surfaceAlt` | `#1C1D25` | Inset fields, chips |
| `surfaceSunken` | `#22232C` | Progress tracks |
| `border` | `#282A34` | Hairlines |
| `ink` | `#F4F5F8` | Primary text |
| `ink2` | `#9FA1AE` | Secondary text |
| `ink3` | `#6C6E7C` | Tertiary text |

**Accent set** — user picks one in Settings; default `signal`. Each has a `base`, a `soft` (12% alpha over surface) and an `on` (text colour that meets 4.5:1 on `base`).

| Name | Base | Notes |
|---|---|---|
| `signal` (default) | `#4F5BD5` | Indigo |
| `pine` | `#0F9E8E` | Teal |
| `ember` | `#E0913A` | Amber |
| `bloom` | `#DC5A8E` | Rose |
| `iris` | `#7C5CE0` | Violet |
| `moss` | `#2FA05F` | Green |
| `tide` | `#3B7CF6` | Blue |
| `slate` | `#6E7180` | Neutral |

**Domain colours** — fixed, not user-configurable, so that a colour always means the same thing across Calendar, Stats and Your Year.

| Domain | Colour |
|---|---|
| Tasks | `#3B7CF6` |
| Plans | `#7C5CE0` |
| Habits | `#0F9E8E` |
| Goals | `#E0913A` |
| Events | `#6E7180` |
| Films / TV | `#DC5A8E` |
| Books | `#2FA05F` |
| Study | `#4F5BD5` |
| Finance | `#8A6E52` |

**Semantic**: `success #2FA05F`, `warning #E0913A`, `danger #DC4C4C`, `info #3B7CF6`.

Dark mode uses the same hues lifted 8–12% in lightness so they hold contrast on `#0A0B0F`. Store both values per token; do not compute at runtime.

### 2.3 Typography

Three roles, three families, all SIL Open Font License, all bundled locally (no runtime Google Fonts fetch — it breaks offline and adds a network dependency on first paint).

| Role | Family | Where |
|---|---|---|
| Display | **Instrument Sans** SemiBold, tracking −2% | Home greeting, big stat numbers, screen titles over 22pt |
| Body / UI | **Inter** variable | Everything else |
| Data | **IBM Plex Mono** Medium | Stat captions, the Your Year legend, dates in dense grids, durations, currency |

The mono face is the signature typographic move: any number that represents a measurement is set in mono with tabular figures, so columns align and figures never jitter when they animate.

**Scale** (size / line-height / weight):

| Token | Value |
|---|---|
| `display` | 34 / 40 / 600 |
| `title1` | 28 / 34 / 600 |
| `title2` | 22 / 28 / 600 |
| `title3` | 18 / 24 / 600 |
| `body` | 16 / 24 / 400 |
| `bodyStrong` | 16 / 24 / 600 |
| `callout` | 15 / 22 / 400 |
| `subhead` | 14 / 20 / 500 |
| `caption` | 12 / 16 / 500 |
| `micro` | 11 / 14 / 600, tracking +4%, uppercase |
| `mono` | 13 / 18 / 500, tabular |
| `statNumber` | 40 / 44 / 600, tabular |

All sizes scale with `MediaQuery.textScaler`, clamped to 0.85–1.6. Above 1.3, cards switch from horizontal to vertical layout — build `ScaledLayout.of(context).isLarge` once and use it everywhere.

### 2.4 Space, radius, elevation

- **Spacing**: `2, 4, 8, 12, 16, 20, 24, 32, 40, 56`. Screen horizontal padding is 20. Card internal padding is 16. Gap between cards is 12.
- **Radius**: `chip 8`, `control 12`, `card 16`, `cardLarge 20`, `sheet 28`, `pill 999`.
- **Elevation**: light mode uses two shadows only.
  - `raised`: `0 1 2 rgba(16,17,26,0.04)` + `0 4 12 rgba(16,17,26,0.06)`
  - `floating` (FAB, sheets): `0 8 28 rgba(16,17,26,0.14)`
  - Dark mode uses no shadows. Elevation is `surface` → `surfaceAlt` lightness steps plus a 1px `border` top highlight.

### 2.5 Motion

| Token | Duration | Curve | Use |
|---|---|---|---|
| `micro` | 120ms | `easeOutCubic` | Checkbox, chip, toggle |
| `standard` | 200ms | `easeOutCubic` | Card expand, list reorder |
| `emphasised` | 280ms | `Cubic(0.2, 0, 0, 1)` | Page push, sheet present |
| `celebrate` | 420ms | spring (`stiffness 380, damping 26`) | Goal reached, streak milestone |

Rules: never animate a list longer than 12 items on entry. Never block input during animation. Stagger is 24ms per item, capped at 6 items. When `MediaQuery.disableAnimations` is true, replace every transform with a 100ms opacity fade and disable all stagger.

### 2.6 Haptics map

Use `HapticFeedback` via a single `Haptics` service so it can be muted globally in Settings.

| Event | Feedback |
|---|---|
| Task/occurrence completed | `mediumImpact` |
| Swipe threshold crossed | `selectionClick` |
| Sheet snap point | `selectionClick` |
| Destructive confirm | `heavyImpact` |
| Goal or streak milestone | `heavyImpact` then `mediumImpact` at +90ms |
| Error / rejected input | `vibrate` 30ms |

### 2.7 Component inventory

Build these in `lib/design/components/` with golden tests before any feature uses them.

`LCard`, `LSectionHeader`, `LListTile`, `LCheckCircle`, `LSwipeRow`, `LChip`, `LSegmented`, `LButton` (`filled | tonal | plain | destructive`), `LIconButton`, `LTextField`, `LDatePicker`, `LTimePicker`, `LSheet` (with snap points), `LMenu` (long-press contextual), `LProgressBar`, `LProgressRing`, `LStat`, `LHeatmapGrid`, `LEmptyState`, `LErrorState`, `LLoadingShimmer`, `LAvatar`, `LPosterTile`, `LDayRail`, `LToast`, `LConfirmDialog`.

**`LDayRail`** is the recurring structural device: a 2px vertical rail on the left of any time-ordered list, with a dot per item and a filled segment showing elapsed time in the day. It appears on Home's schedule card, the Calendar day view, and the Plan detail timeline. It encodes real information (position in the day), which is why it is allowed to repeat.

### 2.8 Empty and error states

Every list has an `LEmptyState`: an icon, one line of what this is for, one line of what to do, one action button. Copy deck in §30.

### 2.9 Accessibility floor

- Minimum touch target 44×44 logical pixels. Swipe actions must have a long-press menu equivalent.
- Every icon-only button has a `Semantics` label.
- Charts expose a `Semantics` summary node ("Tasks completed this week: 24, up 3 from last week") and a table view toggle.
- Never encode meaning in colour alone: completion also uses a check glyph, priority also uses a shape, the Your Year grid also uses opacity steps.
- Contrast: body text ≥ 4.5:1, large text and non-text indicators ≥ 3:1. Add a golden test that asserts contrast for every token pair in both themes.
- Respect `reduceMotion`, `boldText`, `textScaler`, and `highContrast` from `MediaQuery`.

---

## 3. NAVIGATION ARCHITECTURE

### 3.1 Shell

A persistent bottom bar with five tabs and a centre action. Implemented with `go_router`'s `StatefulShellRoute.indexedStack` so each tab keeps its own navigation stack and scroll position.

```
┌──────────────────────────────────────────┐
│                                          │
│              tab content                 │
│                                          │
├──────────────────────────────────────────┤
│  Home   Plans   ( + )   Library   Stats  │
└──────────────────────────────────────────┘
```

Tabs: **Home**, **Plans**, **Tasks**, **Library**, **Stats**.
The `+` is a floating action button that overlaps the bar, raised 12px, 56×56, accent-filled.

Design note: the brief lists five tabs plus a prominent `+`. Placing `+` as the third bar item would give six targets and push Tasks off-centre. Instead the FAB floats above the bar between Plans and Tasks, and the bar renders four labels with a gap. This keeps thumb reach and preserves five destinations.

Bar behaviour: translucent (`surface` at 88% + 20px blur), 1px top border, hides on scroll-down and returns on scroll-up with a 200ms `emphasised` transition. Selected tab: accent icon, accent label, and a 3px accent underline 16px wide.

### 3.2 Route table

```
/onboarding                       (fullscreen, no shell)
/auth/sign-in
/auth/sign-up
/auth/reset

/home                             tab 0
  /home/day/:date                 Day detail (Your Year drill-down reuses this)
  /home/briefing/:period          Today AI briefing (morning|evening)
  /home/customise                 Dashboard card editor

/plans                            tab 1
  /plans/new
  /plans/:id
  /plans/:id/edit
  /plans/:id/calendar
  /plans/:id/occurrence/:occId
  /habits
  /habits/:id
  /calendar                       Unified calendar (entered from Plans header)
  /calendar/event/:id

/tasks                            tab 2
  /tasks/new
  /tasks/:id
  /projects
  /projects/:id
  /projects/:id/new-task
  /goals
  /goals/new
  /goals/:id

/library                          tab 3
  /library/films
  /library/films/search
  /library/films/:id
  /library/tv
  /library/tv/:id
  /library/books
  /library/books/search
  /library/books/:id
  /library/notes
  /library/notes/:id
  /library/collections/:id
  /library/links

/stats                            tab 4
  /stats/year
  /stats/:domain                  tasks|plans|habits|goals|films|books|study|finance
  /journal
  /journal/:date
  /finance
  /finance/expense/:id
  /finance/budgets

/search                           (modal, from any tab)
/ai                               (sheet, from any tab)
/ai/conversation/:id
/settings                         (+ 11 subroutes, see §22)
```

Everything not in that list is a sheet or dialog, not a route.

### 3.3 Presentation rules

| Interaction | Presentation |
|---|---|
| Drilling into an item | Push, `emphasised` slide |
| Creating an item | Sheet from bottom, 92% height, drag to dismiss |
| Quick Add | Sheet, 3 snap points: 40% / 72% / full |
| Editing one field | Inline, or a 40% sheet |
| Search | Full-screen modal with fade + 4px scale-up |
| AI | Sheet, snap 55% / full, keyboard-aware |
| Destructive confirm | Centre dialog, never a sheet |

### 3.4 Deep links and app links

Scheme `lifeos://` plus universal links on `https://lifeos.app/o/`. Supported: `/task/:id`, `/plan/:id`, `/occurrence/:id`, `/day/:date`, `/quickadd?type=`, `/ai?prompt=`. Notifications and widgets both open through this table, so there is one entry path to test.

---

## 4. COMPLETE SCREEN LIST

64 screens. Grouped by milestone so the build order is obvious.

**Onboarding & auth (M4, M33)** — 1 Splash · 2 Welcome · 3 Name · 4 What to organise · 5 What matters most · 6 Module picker · 7 Generating dashboard · 8 Sign in · 9 Sign up · 10 Password reset · 11 Notification permission primer

**Home (M5)** — 12 Home dashboard · 13 Dashboard customise · 14 Day detail · 15 Morning briefing · 16 Evening briefing

**Create (M5)** — 17 Quick Add menu · 18 Natural-language capture · 19 AI proposal confirm

**Tasks & projects (M5, M9)** — 20 Task list (Today/Upcoming/Overdue/Completed segments) · 21 Task detail · 22 Task create/edit · 23 Project list · 24 Project detail · 25 Project create/edit

**Plans & habits (M6, M10)** — 26 Plans list · 27 Plan detail · 28 Plan create step 1 (what) · 29 Plan create step 2 (rhythm) · 30 Plan create step 3 (details) · 31 Plan calendar · 32 Occurrence detail sheet · 33 Reschedule occurrence · 34 Habits list · 35 Habit detail · 36 Habit create/edit

**Calendar (M7)** — 37 Calendar day · 38 Calendar 3-day · 39 Calendar week · 40 Calendar month · 41 Event detail · 42 Event create/edit

**Goals (M8)** — 43 Goals list · 44 Goal detail · 45 Goal create/edit · 46 Milestone editor · 47 Link plan to goal

**Library (M11–M13)** — 48 Library home · 49 Films list · 50 Film search · 51 Film detail · 52 TV detail · 53 Books list · 54 Book search · 55 Book detail · 56 Collection detail · 57 Notes list · 58 Note editor · 59 Links list

**Search & AI (M14, M16)** — 60 Universal search · 61 AI assistant

**Stats & journal & finance (M15)** — 62 Stats overview · 63 Your Year · 64 Domain stat detail · 65 Journal list · 66 Journal entry · 67 Finance overview · 68 Expense create/edit · 69 Budgets

**Settings (M21)** — 70 Settings root + 11 subscreens (§22)

---

## 5. HOME

### 5.1 What it does and why it exists

Home answers one question: *what does today look like, and what should I touch first?* It is the only screen the user is guaranteed to see every day, so it is also the app's memory of who they are.

### 5.2 Layout

```
┌────────────────────────────────────┐
│ Good evening, Sam            ⌕  ◎  │   ← ◎ = avatar → Settings
│ Wednesday 26 August                │
│                                    │
│ ┌────────────────────────────────┐ │
│ │ TODAY                    6/9   │ │   ← Focus card, always first,
│ │ ▌ 18:30  Watch Interstellar    │ │     cannot be hidden or moved
│ │ ▌ 20:00  Gym                   │ │
│ │ ○ Finish geography project     │ │
│ │ ○ Email Dr Hall                │ │
│ └────────────────────────────────┘ │
│                                    │
│ ┌────────────────────────────────┐ │
│ │ PLANS TODAY                    │ │
│ │ ◉ Read 30 minutes      done    │ │
│ │ ○ Study biology                │ │
│ └────────────────────────────────┘ │
│         … configurable cards …     │
└────────────────────────────────────┘
```

Header: `display` greeting by local hour (05–11 morning, 12–17 afternoon, 18–04 evening), `subhead` date in `ink2`. Header collapses to a 44px pinned bar with just the name on scroll.

### 5.3 Card catalogue

Each card is a `DashboardCard` with `type`, `position`, `visible`, `config` (JSON), `size` (`small | medium | large`).

| Card | Content | Tap target |
|---|---|---|
| `focus` | Merged, time-ordered list of today's events, plan occurrences and tasks, capped at 6 with "+N more" | Item → detail |
| `plansToday` | Today's occurrences with inline complete | Complete inline; title → plan |
| `habits` | Row of habit rings, tap to complete | Ring → habit detail |
| `upcoming` | Next 7 days, one line per day with counts | Day → day detail |
| `goals` | Up to 3 goals with progress bars | Goal detail |
| `projects` | Up to 3 active projects with % | Project detail |
| `reading` | Current book, % read, "log progress" | Book detail |
| `filmNext` | Next scheduled film with poster | Occurrence sheet |
| `study` | Minutes studied today vs target | Study stats |
| `activity` | Sparkline of last 14 days completion | Stats |
| `dailyStats` | 3 counters: tasks done, plans done, streak days | Stats |
| `aiSuggestions` | Up to 2 AI suggestions, each with Accept / Dismiss | Inline action |
| `recent` | Last 5 created items | Item detail |
| `journalPrompt` | "Write today's entry" with a one-line prompt | Journal entry |
| `spending` | Month to date vs budget | Finance |

Default set for a new user (before onboarding answers apply): `focus`, `plansToday`, `habits`, `upcoming`, `goals`.

### 5.4 Customise screen

Reorderable list with drag handles, visibility toggles, and a size selector per card. Live preview at the top. Saved to `dashboard_cards` and synced. Reset to default is available and is a destructive confirm.

### 5.5 Data required

A single `HomeSnapshot` provider that runs one composed query and returns everything the visible cards need. Do not let each card open its own stream — that produced N queries on cold start in prototyping and cost 400ms. Recompute on: date rollover, app resume, any write to tasks/occurrences/habits/goals, and manual pull-to-refresh.

### 5.6 Edge cases

| Case | Behaviour |
|---|---|
| Nothing scheduled today | Focus card shows the empty state, not an empty box: "Nothing scheduled. Add something, or take the day." |
| Everything done | Focus card collapses to a single line: "Today's done. 9 of 9." with a `celebrate` animation once per day only |
| Midnight rollover while app is open | Listen for `Timer` at next local midnight plus `AppLifecycleState.resumed`; rebuild snapshot, do not require restart |
| Timezone changed (travel) | Recompute "today" from the device timezone; show a one-time banner "Your timezone changed to CET. Dates now use local time." |
| Over 40 items today | Cap each card, never render an unbounded list on Home |

### 5.7 Offline

Fully offline. Only `aiSuggestions` requires network; when offline it is hidden entirely rather than showing an error, because Home must never look broken.

### 5.8 Claude Code deliverables

`HomeScreen`, `HomeSnapshotProvider`, 15 card widgets each in its own file, `DashboardCustomiseScreen`, `dashboard_cards` table + repository, date-rollover service, golden tests for each card in both themes at text scale 1.0 and 1.5.

---

## 6. QUICK ADD

### 6.1 What it does

One button creates anything in under five seconds. It is the app's most-used control and must never feel like a form.

### 6.2 Flow

Tapping `+` opens a sheet at snap 1 (40%):

```
┌────────────────────────────────────┐
│  ▁▁▁▁                              │
│  What are you adding?              │
│                                    │
│  ┌──────────┐ ┌──────────┐         │
│  │ ✓ Task   │ │ ▤ Event  │         │
│  ├──────────┤ ├──────────┤         │
│  │ ↻ Plan   │ │ ◎ Habit  │         │
│  ├──────────┤ ├──────────┤         │
│  │ ◈ Goal   │ │ ⊞ Project│         │
│  └──────────┘ └──────────┘         │
│  Note · Film · Book · Expense ·    │
│  Journal · Reminder                │
│                                    │
│  ┌────────────────────────────────┐│
│  │ ✦ Ask AI — describe it instead ││
│  └────────────────────────────────┘│
└────────────────────────────────────┘
```

The six primary types are large tiles; the remaining six are a wrap of chips. Order of the primary six adapts to the user's last 30 days of creation counts, recalculated weekly, with a minimum of 5 creations before reordering so it does not shuffle on day two.

### 6.3 Natural language capture

Tapping **Ask AI**, or long-pressing the FAB, opens a single text field with voice input.

The parse runs in **two layers**:

**Layer 1 — local deterministic parser** (no network, always runs first, `lib/core/nlp/`):
- Dates: `today, tomorrow, tonight, tmrw, mon–sun, next monday, 3rd sept, 03/09, in 3 days, next week`
- Times: `at 6, 6pm, 18:00, this evening, morning, noon, midnight`
- Recurrence: `every day, daily, every other day, every 3 days, every weekday, every mon and thu, weekly, every 2 weeks, monthly, every month, twice a week`
- Priority: `!`, `!!`, `!!!` or `urgent`, `important`
- Project: `#projectname`
- Category/tag: `@tag`
- Duration: `for 30 minutes`, `1h`, `90m`
- Quantity goals: `20 books`, `500 km`, `£500`

If Layer 1 finds a confident structure, the sheet shows a live preview and creates with zero network. `"read for 30 minutes every day"` never needs the AI.

**Layer 2 — AI parse** (only if Layer 1 confidence < 0.6, and only if the user has AI enabled and is online). Sends the raw string plus a minimal context block (today's date, timezone, existing plan names, existing project names) and receives a proposed action list (§18.4). Never writes directly.

**Preview is mandatory in both layers.** The sheet expands to show the parsed object as an editable card before anything is saved:

```
Plan · Watch a film
Every 3 days, starting today
Reminder 18:00
                      [ Edit ]  [ Create ]
```

### 6.4 Worked examples

| Input | Result |
|---|---|
| "I want to watch one film every three days" | Plan, `kind=plan`, category Films, `INTERVAL_DAYS(3)`, anchor today, linked media type `film`, prompts "Pick films from your watchlist?" |
| "Remind me to finish my geography project tomorrow at 6" | Task, due tomorrow 18:00, reminder at 18:00, project match on "geography" if a project exists, else a plain task |
| "I want to read 20 books this year" | Goal, target 20, unit `books`, period = current year, offers to link to an existing "Read" plan or create one |
| "gym mon wed fri" | Plan, `WEEKLY_DAYS([MO,WE,FR])`, category Exercise |
| "call mum" | Task, no date, inbox |
| "spent 12.50 on lunch" | Expense, £12.50, category Food, today |

### 6.5 Edge cases

| Case | Behaviour |
|---|---|
| Ambiguous ("every 3") | Preview shows a choice chip row: "3 days / 3 weeks / 3 months" |
| Past date parsed | Ask: "That's in the past. Use next year, or set it as overdue?" |
| Offline and Layer 1 fails | Fall back to the type picker with the text pre-filled in the title field. Never lose typed text. |
| Multiple entities in one sentence | AI may return up to 5 proposed actions; confirm screen lists them all with individual toggles |
| User dismisses mid-preview | Draft is kept in memory for 10 minutes; reopening Quick Add offers "Continue where you left off" |

### 6.6 Claude Code deliverables

`QuickAddSheet`, `NaturalLanguageField`, `LocalParser` with a 120-case unit test suite, `AiParseService`, `ProposalConfirmSheet`, draft persistence, voice input via `speech_to_text` with a graceful fallback if the permission is denied.

---

## 7. PLANS

### 7.1 What it does and why it exists

A Plan is a named intention with a rhythm. It is the feature that makes Life OS different from a to-do app, and it is the engine that Films, Study, Reading, Exercise, Chores and Habits all run on.

Design decision, binding: **Habits are Plans.** A habit is a row in `plans` with `kind = 'habit'`. It uses the same recurrence engine and the same `plan_occurrences` table. The only differences are the creation UI (one step instead of three), the default frequency (daily), and the presentation (streaks and heatmap rather than a schedule list). This avoids writing and testing the hardest code in the app twice. Do not create a separate habits engine.

### 7.2 Plan fields

| Field | Type | Notes |
|---|---|---|
| `id` | uuid | Client-generated |
| `kind` | enum | `plan` \| `habit` |
| `title` | text | Required |
| `icon` | text | Icon name from the app set, or a user-chosen emoji |
| `colour` | text | Domain colour or accent name |
| `category` | text | `films, books, exercise, study, hobby, chores, creative, mindfulness, social, custom` |
| `mediaType` | enum? | `film, tv, book, none` — enables content attachment on occurrences |
| `rule` | json | RecurrenceRule, §9 |
| `anchorDate` | date | The date the rhythm counts from |
| `startDate` | date | First date the plan is active (defaults to anchor) |
| `endDate` | date? | Null = open-ended |
| `endAfterCount` | int? | Alternative ending condition |
| `timeOfDay` | time? | Suggested time, drives the default reminder |
| `durationMinutes` | int? | For time-based plans ("read 30 minutes") |
| `target` | json? | `{value, unit}` e.g. `{30, minutes}`, `{1, film}`, `{10, pages}` |
| `reminderOffsets` | int[] | Minutes relative to `timeOfDay` |
| `missedPolicy` | enum | `skip` \| `markMissed` \| `rollForward` — §9.6 |
| `scheduleMode` | enum | `fixed` \| `rolling` — §9.4 |
| `pauseFrom`,`pauseUntil` | date? | Holiday pause |
| `goalId` | uuid? | Contributes to a goal |
| `notes` | text | |
| `archivedAt` | ts? | |

### 7.3 Creation flow — three steps, each one screen

**Step 1 — What.** Title field with live suggestions from a template list. Templates are starting points, not hard-coded content: Watch a film · Read · Exercise · Study · Practise an instrument · Clean · Cook something new · Take a photo · Learn a language · Call someone · Walk · Journal · Stretch · Custom. Choosing a template pre-fills icon, colour, category, mediaType and a suggested rhythm, all editable.

**Step 2 — Rhythm.** The important screen.

```
┌────────────────────────────────────┐
│ How often?                         │
│                                    │
│ [ Every day ] [ Every other day ]  │
│ [ Every 3 days ] [ Weekly ]        │
│ [ Specific days ] [ Custom ]       │
│                                    │
│ ── Every ──                        │
│      [ 3 ]  [ days ▾ ]             │
│                                    │
│ Starting  [ Today ▾ ]              │
│                                    │
│ Next dates                         │
│ 26 Aug · 29 Aug · 1 Sep · 4 Sep    │
│ 7 Sep · 10 Sep · 13 Sep            │
└────────────────────────────────────┘
```

The "Next dates" preview is required. It updates on every keystroke and is the fastest way for a user to confirm that "every 3 days" means what they think. It is also the fastest way for a developer to spot an off-by-one.

Custom opens the full rule editor with all seven rule types (§9.2), including `TIMES_PER_PERIOD` ("3 times a week, any days") which is presented as "Flexible".

**Step 3 — Details.** Time of day, duration or target, reminders, colour and icon, link to a goal, notes, and end condition. All optional; a plan can be created from step 2 alone by tapping Create.

### 7.4 Plans list screen

Segmented: **Active** · **Habits** · **Paused** · **Archived**.

Each row: icon in a colour-soft circle, title, rhythm in `mono` ("every 3 days"), and a right-hand state:
- Due today and pending → an `LCheckCircle` to complete inline
- Done today → filled check, row at 60% opacity
- Not due today → next date in `mono` `ink3`

Sort options: next due, recently created, alphabetical, completion rate. Filter by category. Long-press → pause, edit, duplicate, archive, delete.

Header has a calendar icon that opens `/calendar` filtered to plan occurrences, and a segmented "List / Calendar" toggle.

### 7.5 Plan detail screen

```
┌────────────────────────────────────┐
│ ←            🎬 Watch a film    ⋯  │
│                                    │
│   Every 3 days · 18:30             │
│   Since 1 September                │
│                                    │
│ ┌──────┬──────┬──────┬──────┐      │
│ │  47  │  92% │  12  │  3   │      │
│ │ done │ rate │streak│missed│      │
│ └──────┴──────┴──────┴──────┘      │
│                                    │
│  ▓▓▓░▓▓▓▓░▓▓▓▓▓▓░▓▓▓  (12 weeks)   │
│                                    │
│  UPCOMING                          │
│  ▌ Fri 29 Aug  🎬 The Truman Show  │
│  ▌ Mon 1 Sep   + choose a film     │
│  ▌ Thu 4 Sep   + choose a film     │
│                                    │
│  HISTORY                           │
│  ✓ Tue 26 Aug  Interstellar  ★★★★☆ │
│  – Sat 23 Aug  skipped             │
└────────────────────────────────────┘
```

Stats strip uses `statNumber` in mono. The heatmap is 12 weeks of occurrence outcomes. Upcoming and History are two sections of the same list, split at today, with History reverse-chronological and lazily paged.

For `mediaType != none`, each future occurrence has a content slot: tap "+ choose a film" to pick from the watchlist or search, which writes `plan_occurrences.linked_entity_id`.

### 7.6 Connections to other features

| Connects to | How |
|---|---|
| Calendar | Occurrences render as calendar items with the plan's colour |
| Goals | `plan.goalId` — each completed occurrence emits progress to the goal (§12.4) |
| Films/Books | `mediaType` allows attaching a library item to an occurrence; completing it marks the item watched/read |
| Statistics | Occurrence outcomes feed `daily_rollups` |
| Notifications | `reminderOffsets` schedule local notifications per occurrence |
| Journal | A journal entry auto-links occurrences completed that day |
| AI | Full read/write via tools `create_plan`, `move_occurrence`, `skip_occurrence` |

### 7.7 Offline

Fully offline including generation. Occurrence materialisation runs locally; the server never generates occurrences. This is deliberate: two devices generating the same deterministic set from the same rule produce identical IDs (§9.7), so sync is a merge rather than a duplication.

---

## 8. PLAN CALENDAR AND OCCURRENCES

### 8.1 Occurrence model

An occurrence is a real row, not a computed view. It exists so it can be individually skipped, moved, annotated, linked to a film, and completed with a timestamp.

| Field | Notes |
|---|---|
| `id` | Deterministic for generated rows (§9.7), random uuid for user-inserted extras |
| `planId` | |
| `scheduledDate` | Local civil date `YYYY-MM-DD` |
| `scheduledTime` | Local wall time `HH:mm`, nullable |
| `originalDate` | Set when moved, so "moved from 29 Aug" can be displayed and undone |
| `status` | `pending` \| `completed` \| `skipped` \| `missed` \| `moved` \| `cancelled` |
| `completedAt` | UTC timestamp |
| `valueAchieved` | numeric — 30 (minutes), 1 (film), 12 (pages) |
| `linkedEntityType` / `linkedEntityId` | film, book, note, task |
| `note` | |
| `isException` | true if the user touched it; protects it from regeneration |
| `generationVersion` | The plan rule version it was generated from |

### 8.2 Calendar view for a single plan

Month grid, plan colour only. Cell states: filled dot (completed), hollow dot (pending), diagonal hatch (skipped), muted dot (missed), arrow glyph (moved). Tap a day → occurrence sheet. Long-press a blank day → "Add an extra occurrence here" (creates a non-generated occurrence, `isException = true`).

### 8.3 Occurrence sheet actions

```
Monday 1 September · 18:30
Watch a film

[ Complete ]  [ Skip ]

Move to…            ▸ Tomorrow / Pick a date
Choose a film       ▸
Add a note          ▸
Remove this date
Edit the whole plan ▸
```

The last two lines are separated by a rule and set in `ink2`, because the critical rule of this screen is that **changing one occurrence must not change the plan.** The only control that edits the rhythm is explicitly labelled as doing so.

### 8.4 Move semantics

Moving occurrence O from date A to date B:

1. Set `O.originalDate = A`, `O.scheduledDate = B`, `O.isException = true`, `status = pending`.
2. **Do not shift** any other occurrence when `scheduleMode = fixed`. The next generated date is still computed from `anchorDate`.
3. If `scheduleMode = rolling`, recompute all *future pending non-exception* occurrences from B as the new effective anchor.
4. If B already holds an occurrence of the same plan, offer: "There's already one on that day. Merge, or keep both?"
5. Reschedule the notification for O.
6. Write an `activity_log` entry so the change is visible in history and undoable for 10 seconds via toast.

### 8.5 Skip semantics

`status = skipped`, `isException = true`. Skipped never counts as missed in statistics and never breaks a streak. This is a product decision: skipping is an active, honest choice, and punishing it would push users to lie to their tracker.

### 8.6 Edge cases

| Case | Behaviour |
|---|---|
| Plan edited after 200 occurrences exist | Past occurrences frozen. Future `pending && !isException` deleted and regenerated. Exceptions preserved and reported: "12 dates you'd changed were kept." |
| Two occurrences of the same plan on one day | Allowed only via explicit "add extra"; generation never produces duplicates (unique index on `planId + scheduledDate + generationVersion`) |
| End date passes | Plan auto-archives at next generation run and shows "Completed" state, not deleted |
| Pause window | Occurrences inside `pauseFrom..pauseUntil` are generated with `status = cancelled` and hidden from all counts |
| User completes a future occurrence | Allowed. `completedAt` is now, `scheduledDate` unchanged. Statistics attribute it to `scheduledDate` for streaks and to `completedAt` for "what did I do today" |
| Occurrence in the past still pending at midnight | The `MissedSweep` job applies `missedPolicy` (§9.6) |

### 8.7 Claude Code deliverables

`PlanRepository`, `OccurrenceRepository`, `PlanCalendarScreen`, `OccurrenceSheet`, `MoveOccurrenceFlow`, `MissedSweep` service, undo toast infrastructure, and the regeneration routine with tests asserting exception preservation.

---

## 9. THE RECURRENCE ENGINE

This is the highest-risk component in the app. Build it first (Milestone 6), build it as a pure Dart library with **zero Flutter imports**, and test it exhaustively before any UI touches it.

Location: `lib/core/scheduling/`. Public surface:

```dart
abstract class RecurrenceEngine {
  /// Pure: given a rule and a window, return the civil dates it fires on.
  List<DateTime> datesIn(RecurrenceRule rule, DateRange window);

  /// Next N dates strictly after [after].
  List<DateTime> next(RecurrenceRule rule, DateTime after, int count);

  /// Does the rule fire on this exact civil date?
  bool firesOn(RecurrenceRule rule, DateTime date);
}
```

### 9.1 Time model — read this before writing any date code

Three distinct concepts, never mixed:

1. **Civil date** — `2026-09-01`. No time, no zone. Used for: occurrence dates, task due dates, journal dates, stat buckets. Stored as `TEXT 'YYYY-MM-DD'`. In Dart, use a dedicated `CivilDate` value type wrapping `(int y, int m, int d)`. **Do not use `DateTime` for these.** `DateTime` arithmetic across DST boundaries silently produces 23- and 25-hour days, which is the classic source of "every 3 days" drifting to "every 3 days except in late March".
2. **Wall time** — `18:30` in the user's zone. Stored as `TEXT 'HH:mm'` plus the plan's or event's IANA zone name.
3. **Instant** — an absolute moment. Stored as epoch milliseconds UTC. Used for `createdAt`, `updatedAt`, `completedAt`, and for calendar events that have a true instant (a video call).

Interval arithmetic is always performed on `CivilDate` by day counting, never by adding `Duration`.

### 9.2 Rule types

```dart
sealed class RecurrenceRule {
  final CivilDate anchor;
  final CivilDate? until;
  final int? count;
}

class IntervalDays   extends RecurrenceRule { final int n; }              // every n days
class WeeklyDays     extends RecurrenceRule { final Set<Weekday> days;
                                              final int everyNWeeks; }   // Mon+Thu, every 2 weeks
class MonthlyDay     extends RecurrenceRule { final int dayOfMonth;      // 1..31 or -1 for last
                                              final int everyNMonths; }
class MonthlyWeekday extends RecurrenceRule { final int nth;             // 1..4, -1 = last
                                              final Weekday day;
                                              final int everyNMonths; }
class Yearly         extends RecurrenceRule { final int month, day; }
class CustomDates    extends RecurrenceRule { final List<CivilDate> dates; }
class TimesPerPeriod extends RecurrenceRule { final int times;           // "3 times a week"
                                              final Period period; }     // week | month
```

`TimesPerPeriod` is the flexible rule. It does not pin dates. It creates a per-period quota row and the UI shows "2 of 3 this week" with a single completable action available on any day. Generation for it produces one occurrence per period with `remainingInPeriod`, not N dated rows.

### 9.3 Algorithms

**IntervalDays(n)**: `fires(d) ⟺ daysBetween(anchor, d) ≥ 0 && daysBetween(anchor, d) % n == 0`. `daysBetween` converts both dates to a Julian day number and subtracts. This is DST-proof by construction.

**WeeklyDays**: compute the ISO week index of `d` relative to the anchor's week: `weekIndex = floor(daysBetween(startOfWeek(anchor), startOfWeek(d)) / 7)`. Fires when `weekIndex % everyNWeeks == 0 && days.contains(d.weekday)`. Week start is a user setting (Mon default, Sun for US locales) and must be read from settings, not hard-coded.

**MonthlyDay**: `monthsBetween(anchor, d) % everyNMonths == 0` and `d.day == clampDayToMonth(dayOfMonth, d)`. Clamping rule: day 31 in a 30-day month fires on the 30th; day 31 in February fires on the 28th/29th. `-1` always means the true last day. State this in the UI: "The 31st — on shorter months, the last day."

**MonthlyWeekday**: nth occurrence of the weekday in the month; `-1` = last. If the 5th Monday is requested and does not exist, it does not fire that month (unlike day clamping — different because "the 5th Monday" has no natural fallback).

**Yearly**: 29 February anchors fire on 28 February in non-leap years, with a settings toggle for "1 March" instead.

### 9.4 Fixed vs rolling

- `fixed` (default): dates come from the anchor. Completing early or late changes nothing downstream. "Every 3 days" means a grid.
- `rolling`: the next date is `completedAt + n days`. Use for plans like "water the plants every 5 days" where the clock genuinely restarts on completion. When a rolling plan's occurrence is completed, delete future pending non-exception occurrences and regenerate from the completion date.

Expose this in Step 3 as a single switch: "Count from the schedule" / "Count from when I last did it."

### 9.5 Materialisation

Occurrences are generated lazily into a horizon.

- `HORIZON_DAYS = 120` for the active plan being viewed; `60` for background generation.
- `ensureMaterialised(planId, through: date)` is idempotent and is called by: plan create, plan edit, plan detail open, calendar view scroll past the horizon, app resume, and the daily maintenance job.
- The daily job at first launch after local midnight extends every active plan's horizon and runs `MissedSweep`.
- Cap: 5,000 occurrences per plan. Beyond that, stop generating and surface "This plan has generated 5,000 dates. Set an end date to keep it manageable."

### 9.6 Missed policy

Applied by `MissedSweep` to occurrences whose `scheduledDate < today` and `status == pending`:

- `skip` — silently set `cancelled`. Nothing is counted. Good for casual plans.
- `markMissed` (default) — set `missed`. Counts against completion rate. Streak resets. Neutral copy only.
- `rollForward` — move the occurrence to today. Cap: only one roll-forward per occurrence, and never roll forward more than 3 items per plan per day, so returning after a two-week absence does not produce a wall of 14 items.

### 9.7 Deterministic occurrence IDs

Generated occurrences use `uuidV5(namespace: planId, name: "${generationVersion}|${scheduledDate}")`.

This means device A and device B generating the same plan produce the same row IDs, so sync upserts merge instead of duplicating. User-created extras use `uuidV4`. `generationVersion` increments on every rule change, so a regenerated series does not collide with the old one.

### 9.8 Performance budget

- `datesIn` over a 1-year window: under 2ms.
- Materialising 120 days for 50 active plans: under 150ms, off the UI isolate if it exceeds 16ms.
- Plan detail open with 2,000 historical occurrences: under 100ms, using an indexed paged query, never loading all rows.

### 9.9 Golden test table — implement all of these before the UI

| # | Rule | Anchor | Assertion |
|---|---|---|---|
| 1 | IntervalDays(3) | 2026-09-01 | 1,4,7,10,13,16 Sep |
| 2 | IntervalDays(1) | 2026-03-27 | Fires on 29 Mar (UK DST spring forward) and 30 Mar |
| 3 | IntervalDays(2) | 2026-10-24 | Fires 24,26,28 Oct (DST fall back) with no repeat of the 25th |
| 4 | IntervalDays(7) | 2027-02-24 | 24 Feb, 3 Mar — correct across a non-leap February |
| 5 | IntervalDays(3) | 2028-02-26 | 26 Feb, 29 Feb, 3 Mar — leap year |
| 6 | WeeklyDays({MO,TH}) | 2026-09-02 (Wed) | First fire 3 Sep (Thu), then 7, 10, 14 |
| 7 | WeeklyDays({SU}, every 2 weeks) | 2026-09-06 | 6, 20 Sep, 4 Oct |
| 8 | WeeklyDays week start Sunday vs Monday | 2026-01-01 | Different `everyNWeeks` bucketing; both asserted |
| 9 | MonthlyDay(31) | 2026-01-31 | 31 Jan, 28 Feb, 31 Mar, 30 Apr |
| 10 | MonthlyDay(-1) | 2026-01-31 | Last day of every month including 29 Feb 2028 |
| 11 | MonthlyDay(15, every 3 months) | 2026-01-15 | 15 Jan, 15 Apr, 15 Jul, 15 Oct |
| 12 | MonthlyWeekday(nth=5, TU) | 2026-09-29 | Skips months without a 5th Tuesday entirely |
| 13 | MonthlyWeekday(nth=-1, FR) | 2026-09-25 | Last Friday each month |
| 14 | Yearly(2, 29) | 2028-02-29 | 2029 fires 28 Feb under default setting |
| 15 | IntervalDays(3) + until 2026-09-10 | 2026-09-01 | Exactly 1,4,7,10 |
| 16 | IntervalDays(3) + count 4 | 2026-09-01 | Exactly 4 dates |
| 17 | TimesPerPeriod(3, week) | any | 1 quota row per ISO week, quota resets on week start setting |
| 18 | Any rule, query window entirely before anchor | — | Empty list, no exception |
| 19 | Any rule, 10-year window | — | Under 20ms, no memory spike |
| 20 | Rolling IntervalDays(5), completed 2 days late | — | Next date = completion + 5, not anchor + 10 |
| 21 | Regeneration with 3 exceptions in the future | — | All 3 exceptions survive, all other future pending rows replaced |
| 22 | Timezone changes from Europe/London to Asia/Tokyo | — | Civil dates unchanged; only wall-clock reminders reschedule |
| 23 | Device clock moved backwards 1 day | — | No duplicate generation, no double-counting of streaks |
| 24 | Pause 2026-09-05..2026-09-12 with IntervalDays(2) | 2026-09-01 | 5,7,9,11 Sep are `cancelled`, 13 Sep is `pending` |

---

## 10. TASKS

### 10.1 What it does

One-off actions with an optional deadline. The lowest-friction object in the app: title only is a valid task.

### 10.2 Fields

`id, title, notes, dueDate (civil), dueTime (wall), priority (none|low|medium|high), categoryId, projectId, goalId?, subtasks[], attachments[], reminders[], recurrenceRule?, completedAt, sortIndex, createdAt, updatedAt, deletedAt`

A task with a `recurrenceRule` is a *repeating task*, which differs from a Plan: on completion it creates the next instance immediately and the previous one stays in history. Plans pre-materialise a calendar; repeating tasks do not. Use repeating tasks for "pay rent monthly", use Plans for "read every day".

### 10.3 Views

Segmented control: **Today · Upcoming · Overdue · Completed**, plus a Projects entry point in the header.

- **Today**: due today + overdue pulled to the top under an "Overdue" header + tasks with no date that the user pinned to today.
- **Upcoming**: grouped by day for 30 days, then "Later", then "Someday" (no date).
- **Overdue**: red-tinted count in the segment, oldest first, with a bulk action bar: "Reschedule all to today".
- **Completed**: grouped by completion day, 90-day retention in the view, all retained in the database.

### 10.4 Interaction

- Tap the circle → complete, with a 120ms circle fill, strikethrough at 60ms, row collapse at 200ms, and a 5-second undo toast.
- **Swipe right** → complete. Threshold 30% of width, colour fills green progressively.
- **Swipe left** → reveals Reschedule / Priority / Delete.
- **Long-press** → context menu with the same actions plus Duplicate, Convert to plan, Move to project, Add to a goal. Every swipe action must also exist here, for accessibility.
- **Drag** to reorder within a manual-sorted list.
- Inline add: a persistent "＋ Add task" row at the bottom of each day group that creates without leaving the list.

### 10.5 Subtasks

Rendered as an indented checklist inside task detail with their own progress bar ("3 of 5"). Completing all subtasks prompts, does not force, completion of the parent. Subtasks cannot have subtasks.

### 10.6 Edge cases

| Case | Behaviour |
|---|---|
| Completing a repeating task | Next instance created immediately; toast says "Next: 26 September" |
| Task due in the past created by the user | Allowed, appears in Overdue, no warning |
| 500+ tasks in one view | `ListView.builder` with paged queries of 50, never `toList()` on the whole table |
| Task deleted with attachments | Attachments soft-deleted with it, purged on the 30-day sweep |
| Completing a task that satisfies a goal | Goal progress increments with a `celebrate` animation if it crosses the target |

### 10.7 Offline

Fully offline, including attachments (stored in the app documents directory, uploaded on next sync).

---

## 11. PROJECTS

### 11.1 What it does

A container for tasks with a shared outcome, progress and deadline.

### 11.2 Fields

`id, title, description, colour, icon, deadline (civil), status (active|onHold|done|archived), notes[], attachments[], goalId?, createdAt, completedAt`

Progress is **derived, never stored**: `completedTasks / totalTasks`, weighted optionally by task priority if the user turns on "weight by priority". Store a cached value in `daily_rollups` for statistics only.

### 11.3 Detail screen

Header with title, colour, deadline chip (turns amber at 3 days, danger when overdue), and a progress ring. Sections: Tasks (grouped To do / Done, with inline add), Notes, Files, Activity.

Activity history is an append-only `activity_log` filtered to this project: task added, task completed, deadline changed, note added. This also powers undo and the AI's "what happened on this project?" answers.

### 11.4 Edge cases

Deleting a project asks: "Delete 12 tasks too, or move them to no project?" Never silently orphan or silently destroy. A project with zero tasks shows 0% and an empty state, not a divide-by-zero.

---

## 12. GOALS

### 12.1 What it does

A measurable outcome over a period. Goals are the layer that gives Plans and Tasks a reason.

### 12.2 Fields

`id, title, description, type, targetValue, currentValue, unit, startDate, endDate, milestones[], linkedPlanIds[], linkedProjectIds[], colour, icon, status`

`type`:
- `count` — 20 books, 100 films, 10 projects
- `quantity` — 500 km, 10,000 pages
- `duration` — 50 hours of study
- `currency` — save £500
- `milestone` — no number, a checklist of steps ("Learn Spanish": A1, A2, B1)
- `boolean` — done or not

### 12.3 Detail screen

A large progress ring (`statNumber` inside: "12 / 20"), a projection line ("On track — 8 to go, 4 months left, you're averaging 1.4 a month"), a contributions timeline, linked plans, and milestones.

The projection is honest arithmetic, not encouragement: if the current rate will miss the target it says so plainly and offers "Adjust the target" or "Increase the plan frequency", with the AI able to compute the required rate.

### 12.4 Automatic progress

This is the connective tissue of the app. A `GoalProgressService` listens to domain events and applies rules:

| Event | Goal type it feeds | Increment |
|---|---|---|
| Occurrence completed on a plan with `goalId` | any | `valueAchieved` or 1 |
| Film marked watched | `count` with unit `films` | 1 |
| Book marked finished | `count` with unit `books` | 1 |
| Task completed in a linked project | `count` with unit `tasks` | 1 |
| Expense saved into a savings category | `currency` | amount |
| Manual log | any | user-entered |

Every increment writes a `goal_contributions` row `(goalId, sourceType, sourceId, value, date)` so progress is auditable and reversible. Un-completing a film decrements exactly the contribution it created. **Never mutate `currentValue` without a contribution row.**

### 12.5 Edge cases

| Case | Behaviour |
|---|---|
| Goal target reached | Ring completes, `celebrate` animation, "Reached" state; the goal stays visible until the user archives it, and continued progress still counts ("22 / 20") |
| End date passes unmet | Status `ended`, neutral copy: "Ended at 14 of 20." Offer "Start again for 2027" which clones the goal with new dates |
| Linked plan deleted | Contributions remain (history is true), goal shows "1 linked plan was deleted" |
| Double counting | A film watched via a plan occurrence emits one event, not two. `GoalProgressService` deduplicates on `(goalId, sourceType, sourceId)` |

---

## 13. HABITS

Habits are Plans with `kind = 'habit'` (§7.1). This section covers only what differs.

### 13.1 Creation

One screen: name, icon, colour, and a frequency row that defaults to Every day. Optional target ("8 glasses"). Optional reminder. Nothing else.

### 13.2 Presentation

- **List**: a row per habit with a 7-day dot strip (this week), tap any dot to complete retroactively within the last 7 days.
- **Detail**: current streak, best streak, this month's completion percentage, a full-year heatmap, and a month calendar.
- **Counter habits**: target > 1 renders a stepper and a partial ring ("5 of 8").

### 13.3 Language rules — enforce in review

| Never | Always |
|---|---|
| "Failed" | "Missed" |
| "You broke your streak!" | "Streak reset. Best: 34 days." |
| "Don't lose your progress" | (nothing — do not use loss aversion) |
| Red for a missed day | `ink3` neutral for missed, colour only for done |
| Push notification guilting a user at 23:00 | Reminders only at user-chosen times |

Streak rules: skipped days do not break streaks. A `graceDays` setting (default 0, max 2 per month) allows a missed day to be forgiven, shown honestly as "1 grace day used".

No leaderboards, no comparisons with other users, no "you're in the bottom 20%".

---

## 14. UNIFIED CALENDAR

### 14.1 What it shows

One timeline containing: events, tasks with due times, plan occurrences, habit occurrences, goal milestone dates, reminders, and scheduled films/study sessions. Each source has a toggle in a filter sheet, persisted.

### 14.2 Views

| View | Layout |
|---|---|
| **Day** | Hour rail 06:00–23:00 (auto-expands to cover items outside), `LDayRail` on the left, all-day strip pinned at top, current-time indicator line |
| **3-day** | Three compressed columns, used as the default on small screens in landscape |
| **Week** | 7 columns, event blocks, tasks as chips in the all-day strip |
| **Month** | Grid with up to 3 coloured dots per day, plus an agenda list under the grid for the selected day |

Swipe horizontally to change period. Pinch to move between Day → 3-day → Week → Month. A "Today" button appears in the header whenever the visible range excludes today.

### 14.3 Interaction

Tap any item → its detail. Long-press an empty slot → create an event at that time. Drag an event to move it (events only; plan occurrences must use the move flow in §8.4 so the fixed/rolling rule is respected — dragging one is allowed but shows a one-time explainer: "This moves just this date. The plan keeps its rhythm.").

### 14.4 Device calendar integration

Read-only in v1, opt-in, via `device_calendar`. Imported events are stored with `source = 'device'` and `externalId`, rendered in grey, and are not editable in Life OS. A settings screen lists device calendars with per-calendar toggles. Two-way sync is postponed (§37.2) because write-back conflict handling is a project of its own.

If permission is denied: the calendar still works with Life OS's own events, and a dismissible row offers "Turn on device calendar in Settings".

### 14.5 Performance

Month view must not query per cell. One range query per visible period plus one prefetch of the adjacent periods. Target: 60fps scroll with 300 items in the visible month.

---

## 15. LIBRARY

### 15.1 Structure

Library home is a grid of sections: **Films · TV · Books · Notes · Links · Documents · Collections**. Each section tile shows a count and a 3-item preview thumbnail stack.

### 15.2 Collections

A collection is a named, ordered, polymorphic list. `collections(id, title, description, coverImage, itemType?, isSmart, smartQuery)`; `collection_items(collectionId, entityType, entityId, sortIndex, addedAt)`.

Smart collections are saved queries (e.g. "unwatched films rated 8+ on TMDB, under 100 minutes"). Ship with manual collections in M11; smart collections in M15 once the query layer is stable.

---

## 16. FILMS AND TV

### 16.1 What it does

A watchlist, a watch history, ratings, and — the point — the ability to feed a Plan.

### 16.2 Architecture: the metadata provider must be replaceable

Define the boundary before touching any HTTP client:

```dart
abstract class MediaMetadataProvider {
  String get providerId;                     // 'tmdb'
  String get attributionText;
  Future<List<MediaSearchResult>> search(String q, {MediaType type, int page});
  Future<MediaDetail> detail(String externalId, MediaType type);
  Future<List<MediaSearchResult>> trending({MediaType type});
  Uri imageUrl(String path, ImageSize size);
}
```

`TmdbMetadataProvider` is the only implementation in v1. Nothing outside `lib/data/media/` may import it or reference TMDB types. Library code depends on `MediaMetadataProvider` and on the app's own `MediaDetail` model, so swapping to OMDb, Watchmode, or a self-hosted cache is a one-file change.

**Legal requirements, non-negotiable:**
- Register for a TMDB API key and read their terms before shipping. Commercial use requires their approval.
- Display the required attribution ("This product uses the TMDB API but is not endorsed or certified by TMDB") plus the TMDB logo on the Film search screen and in Settings → About.
- Do not redistribute or bulk-cache their catalogue. Cache only items the user saved, only as long as the user keeps them.
- Never bundle a film list in the app. If the API key is missing at build time, film search shows an honest configuration error, not fake results.

Books use the same pattern with `OpenLibraryProvider` (no key required) and `GoogleBooksProvider` as an alternative.

### 16.3 Local model

`library_items(id, mediaType, title, sortTitle, providerId, externalId, year, posterPath, backdropPath, overview, runtimeMinutes, genres[], creators[], status, rating, isFavourite, notes, addedAt, startedAt, finishedAt, progressValue, progressUnit)`

`status`: `wishlist | inProgress | done | abandoned`. One vocabulary for films (want to watch / watching / watched), TV, and books (want to read / reading / read), so the query layer is shared.

`media_metadata_cache(providerId, externalId, payloadJson, fetchedAt)` with a 30-day TTL and an offline fallback to the stale copy.

### 16.4 Screens

- **Films list**: segmented Watchlist / Watched / Favourites / Collections. Poster grid (3 columns) or list toggle. Sort by added, title, year, rating, runtime.
- **Search**: debounced 350ms, results with poster, title, year, and an "＋" that adds straight to the watchlist without opening detail. Recent searches persisted. Offline: shows local library matches only, with a clear "Showing your library. Search needs a connection."
- **Detail**: backdrop header, poster, title, year, runtime, genres, director/creator, synopsis, cast strip, then user controls: status, rating (5 stars, half-steps), favourite, watch date, notes, collections, and **Schedule this** which offers existing film plans or creates one.

### 16.5 Scheduling films — the flagship flow

From a plan with `mediaType = film`:

```
Film Schedule · Watch a film · Every 3 days

Mon 1 Sep   🎬 Interstellar
Thu 4 Sep   🎬 The Truman Show
Sun 7 Sep   🎬 The Grand Budapest Hotel
Wed 10 Sep  ＋ choose a film
```

- "Fill from watchlist" assigns the next N unwatched items to the next N empty occurrences, in the user's chosen order (added, alphabetical, shortest first, or shuffle).
- Completing an occurrence with a linked film sets the film to `done`, stamps `finishedAt` with the occurrence date, opens an optional rating prompt, and emits a goal contribution if a films goal exists.
- Unlinking a film from an occurrence never changes the film's status.

### 16.6 Stats shown

Films watched this year · average rating · most-watched genre · films this month · total runtime ("You've watched 94 hours of film this year") · a rating distribution bar. All computed locally from `library_items`, never from the API.

### 16.7 Edge cases

| Case | Behaviour |
|---|---|
| API key missing or invalid | Search disabled with an explicit message; manual add ("Add without searching") remains available so the feature still works |
| Rate limited (429) | Exponential backoff, request coalescing, and a queue; show "Searching…" not an error, fail after 3 attempts with a retry button |
| Film has no poster | Rendered as a typographic tile using the title, not a broken image or grey box |
| Same film added twice | Unique index on `(providerId, externalId, userId)`; adding again just opens the existing item |
| TV series | v1 tracks the series as one item with season/episode progress fields. Per-episode tracking is postponed (§37.2) |
| User goes offline mid-browse | Cached posters via `cached_network_image` with a disk cache cap of 200MB and an LRU eviction |

---

## 17. NOTES, LINKS, DOCUMENTS

### 17.1 Notes

Rich enough to be useful, not a Notion clone. Block types: paragraph, heading, checklist item, bullet, quote, divider, image, link card, code. Stored as a JSON block array, not HTML or Markdown, so future block types do not require a parser rewrite.

Editing uses `flutter_quill` or a custom block editor — evaluate in M13 and record the decision in `DECISIONS.md`. Whatever is chosen must support: offline, images, checklists, and a plain-text projection for search indexing.

`notes(id, title, blocksJson, plainText, folderId, pinned, colour, createdAt, updatedAt)`. `plainText` is maintained on every save and is what the search index reads.

### 17.2 Linking

`note_links(noteId, entityType, entityId)` — a note can attach to tasks, projects, goals, plans, occurrences, films, books, journal entries. Every one of those detail screens gets a Notes section, and the linkage is bidirectional in the UI.

### 17.3 Links and documents

Links: a saved URL with title, favicon, tags, and optional Open Graph enrichment (network-optional; the link is saved instantly and enriched later). Documents: files stored locally, uploaded to the user's storage bucket on sync, with size cap 25MB per file and a total quota shown in Settings → Data.

---

## 18. UNIVERSAL SEARCH

### 18.1 Behaviour

Opens from the Home header, and from a swipe-down gesture on any tab root. Full-screen modal. Empty state shows recent searches and 4 suggested queries.

Results are grouped by type with a count per group, ranked by a composite score: exact title match > prefix > token match > body match, then boosted by recency and by whether the item is due today.

### 18.2 Implementation

SQLite **FTS5** virtual table `search_index(entityType, entityId, title, body, tags, tokenize='unicode61 remove_diacritics 2')`, maintained by triggers on every searchable table. Rebuild command available in Settings → Data for corruption recovery.

Query pipeline: FTS5 match → rank → group → cap at 8 per group with "Show all". Target under 50ms for 20,000 rows.

### 18.3 Semantic search (Premium, M16+)

Layered on top, never replacing FTS. When enabled and online, the query also goes to an embedding endpoint; results are merged with keyword results by reciprocal rank fusion. Embeddings for the user's items are computed server-side on sync and stored in a `pgvector` column. Requires explicit opt-in because it sends note titles and bodies to the server.

"Find the film I saved about space" works because the film's cached overview is indexed and embedded.

Offline: keyword search only, with a one-line note "Semantic search needs a connection."

---

## 19. AI ASSISTANT

### 19.1 Architecture

```
Flutter app
   │  HTTPS + Supabase JWT
   ▼
Supabase Edge Function  /ai/chat
   │  – validates JWT, resolves user
   │  – enforces quota + permission scopes
   │  – builds context from Postgres (never trusts client-supplied context)
   │  – calls the model API with the tool schema
   │  – returns text + proposed tool calls
   ▼
Anthropic API
```

**The model API key never exists on the device.** No exceptions, not even for debug builds.

### 19.2 Permission scopes

Settings → AI has one master switch and per-domain read scopes: tasks, plans, habits, goals, projects, calendar, library, statistics, journal, finance. Journal and finance default **off**. Write permission is a separate switch and defaults on, but writes always require confirmation (§19.5).

The context builder only reads tables the user has enabled. If a scope is off and the user asks about it, the assistant says so plainly: "I don't have access to your journal. You can turn that on in Settings → AI."

### 19.3 Context building

Never send the whole database. Build a compact snapshot, target under 4,000 tokens:

- Profile: first name, timezone, week start, currency.
- Today and the next 7 days: events, occurrences, tasks due (title, time, status only).
- Overdue count and the 5 oldest.
- Active plans: title, rhythm in words, next date, 30-day completion rate.
- Active goals: title, current/target, end date.
- Active projects: title, progress, deadline.
- Counts only for library and finance, unless the question needs detail — in which case a second, targeted retrieval runs (a `search_user_data` tool the model can call).

Titles only. Never note bodies or journal text unless the user's question is explicitly about them and the scope is on.

### 19.4 Tool schema

```
create_task, update_task, complete_task
create_plan, update_plan, pause_plan
complete_occurrence, skip_occurrence, move_occurrence, assign_media_to_occurrence
create_goal, update_goal
create_project, add_tasks_to_project
create_event, move_event
create_note, create_journal_entry, create_expense
search_user_data(query, types[], dateRange)
get_day(date)
suggest_schedule(freeMinutes, date)
```

Every mutating tool returns a **proposal**, not a result. The Edge Function does not write to the database. It returns a structured `ProposedAction[]` to the client; the client writes locally through the normal repositories, which means every AI change is offline-consistent, undoable, and synced by the same path as manual edits.

### 19.5 Confirmation UI

```
┌────────────────────────────────────┐
│ I can do this:                     │
│                                    │
│ ✓ Move "Watch a film" from Friday  │
│   to Saturday 30 August            │
│   ⓘ This changes one date only.    │
│                                    │
│ ✓ Create task "Book train tickets" │
│   due Thu 27 Aug, 09:00            │
│                                    │
│        [ Not now ]   [ Do it ]     │
└────────────────────────────────────┘
```

Rules:
- Every action is individually toggleable.
- Destructive actions (delete, archive, bulk edit, changing a whole plan) are listed separately under a "This changes more than one thing" header and require a second tap.
- Bulk operations over 10 items always show a count and a sample: "Reschedules 23 tasks. Showing 3."
- After execution, a toast with Undo (10 seconds), and an `activity_log` entry tagged `source = 'ai'`, filterable in Settings → AI → Activity.

### 19.6 Conversation

`ai_conversations` and `ai_messages` stored locally and synced. Conversations are per-thread with titles auto-generated from the first message. Streaming responses via SSE. A stop button. Message history capped at the last 20 turns sent to the model, with older context summarised.

### 19.7 Example capabilities

"What should I do tonight?" → reads free time, overdue tasks, tonight's occurrences, returns a ranked shortlist with reasons.
"What films am I supposed to watch this week?" → queries occurrences with linked films.
"Move my film from Friday to Saturday" → `move_occurrence` proposal.
"I have two hours free tomorrow, what should I work on?" → `suggest_schedule` weighing deadlines, project progress and goal shortfalls.
"How am I doing on my reading goal?" → goal state plus the arithmetic of what is needed.

### 19.8 Failure and cost

| Case | Behaviour |
|---|---|
| Offline | AI entry points show "AI needs a connection" and the rest of the app is untouched |
| API error / timeout (15s) | "AI is temporarily unavailable. You can carry on using Life OS normally." Retry button |
| Quota exceeded (free tier) | Honest counter: "You've used your 30 AI messages this month. Resets 1 September." Never a fake error |
| Model returns malformed tool JSON | Validate against the schema; on failure ask the model once to correct; on second failure show "I couldn't work that out — try rephrasing" |
| Model proposes something impossible (a plan on a deleted project) | Client-side validation rejects the action before it appears in the confirm sheet |

### 19.9 Today AI briefing

Optional, off by default, enabled in onboarding or Settings → AI.

- **Morning** (user-chosen time, default 08:00): generated locally when possible. Counts of tasks, occurrences, the nearest deadline, and free-time windows come from local queries. Only the one-sentence framing is model-generated, and if AI is off or offline, the briefing still renders with a plain deterministic sentence. This is important: the briefing must work without the network.
- **Evening** (default 21:00): what was completed, what moved, what is on tomorrow.
- Delivered as a notification that opens `/home/briefing/morning`, and as a Home card.
- Fully disableable, with separate switches for morning and evening.

---

## 20. STATISTICS

### 20.1 Architecture

Never compute statistics by scanning raw tables at render time. Maintain a rollup table.

`daily_rollups(date, userId, tasksCompleted, tasksCreated, occurrencesCompleted, occurrencesMissed, occurrencesSkipped, habitsCompleted, habitsDue, filmsWatched, booksFinished, pagesRead, studyMinutes, activityMinutes, goalContributions, expenseTotal, journalWritten, activityScore, updatedAt)`

Maintenance:
- **Incremental**: a `StatsRecorder` subscribes to domain events and increments the affected day's row inside the same transaction as the write. Cost per write: one upsert.
- **Nightly reconcile**: the daily maintenance job recomputes the last 3 days from source tables and corrects drift. Cheap, and it means a bug in incremental logic self-heals.
- **Full rebuild**: available in Settings → Data, chunked at 90 days per frame so it never blocks the UI.

`activityScore` is 0–4, used by Your Year: 0 = nothing, then thresholds on a weighted sum of completions. Thresholds are relative to the user's own 30-day median, so an active user and a light user both get a readable grid.

### 20.2 Stats overview screen

Period selector: **Today · Week · Month · Year · All time** (segmented, persisted).

Content: a headline row of 4 `LStat` tiles, then one card per domain with a compact chart and a tap-through to the domain detail. Charts via `fl_chart`, styled with design tokens only.

| Domain | Primary chart |
|---|---|
| Tasks | Bar chart of completions per day/week, plus completion rate ring |
| Plans | Stacked bar: completed / skipped / missed |
| Habits | Year heatmap plus per-habit rate list |
| Goals | Horizontal progress bars sorted by shortfall |
| Projects | Progress bars with deadline markers |
| Films | Count over time, rating distribution, genre breakdown, total runtime |
| Books | Books finished, pages over time, average days per book |
| Study | Minutes per day with a 7-day moving average |
| Finance | Monthly spend, category donut, budget bars |

Every chart has: an accessible summary node, a "view as table" toggle, and an empty state that explains what would fill it.

### 20.3 Insights

Deterministic, computed locally, no AI required:
- "Your best day for finishing tasks is Tuesday."
- "You complete 82% of morning occurrences and 54% of evening ones."
- "You've read on 22 of the last 30 days."

Rules: only surface an insight with at least 14 days of data and a difference above a fixed threshold. Never phrase an insight as a judgement.

---

## 21. YOUR YEAR

The signature screen. Everything else in the design system is quiet so that this can be loud.

### 21.1 Layout

A 53×7 grid of day cells for the selected year, weeks as columns, weekdays as rows. Month labels in `micro` above, weekday labels in `mono` on the left. Cell 11×11 with 3px gaps on a 390pt screen; the grid scrolls horizontally with the current week snapped to the right edge on open.

Cell rendering:
- Fill = accent colour at opacity `[0, 0.18, 0.42, 0.68, 1.0]` by `activityScore`.
- Future days: 1px border only, no fill.
- Today: a ring in `ink`.
- Days with a completed goal milestone: a tiny notch in the top-right corner, so meaning is not carried by colour alone.

Above the grid: year selector, and three `statNumber` figures in mono (active days, total completions, longest streak). Below: a legend and a "Compare to last year" toggle that overlays a thin line of last year's weekly totals.

### 21.2 Day detail

Tapping a cell pushes `/home/day/:date`:

```
26 August 2026

Tasks         6 / 7
Plans         3 / 4
Films         1     Interstellar
Study         1h 20m
Goals         2 progressed
Journal       written

TIMELINE
08:00  ✓ Morning routine
09:30  ✓ Email Dr Hall
18:30  ✓ Watch Interstellar
20:00  – Gym (skipped)
```

The same screen serves the Home "day detail" route, so it is built once.

### 21.3 Performance

365 cells must not be 365 widgets rebuilding. Render the grid with a single `CustomPainter` over an `Int8List` of scores. Hit-testing maps a tap position to an index arithmetically. Target: first paint under 80ms, 60fps on scroll, on a mid-range Android device.

Data comes from one query: `SELECT date, activityScore FROM daily_rollups WHERE date BETWEEN ? AND ?`.

### 21.4 Sharing

"Share your year" exports the grid as a 1080×1350 PNG with the year, three headline numbers, and a small wordmark. No personal titles or content in the image, ever — only counts. Rendered offscreen via `RepaintBoundary`.

---

## 22. JOURNAL, FINANCE, NOTIFICATIONS, WIDGETS, SETTINGS

### 22.1 Journal

`journal_entries(id, date UNIQUE per user, blocksJson, plainText, mood?, weather?, createdAt, updatedAt)`

One entry per day, editable any day. The entry screen shows an auto-generated context strip that is *not* part of the entry text: what you completed, what you watched, what you spent. Tapping any of it inserts a reference block.

Privacy: journal content is excluded from the AI context by default and from semantic search unless separately enabled. If the user turns on local biometric lock for the journal (`local_auth`), the plainText column is excluded from FTS until unlocked in-session.

Prompts: an optional rotating one-line prompt. Never a streak, never a nag.

### 22.2 Finance

Deliberately light. Manual entry only, no bank connection in v1 (§1.5).

`expenses(id, type income|expense, amount, currency, categoryId, date, note, isRecurring, recurrenceRule?, attachmentId?)`
`budgets(id, categoryId?, amount, period monthly|weekly, startDate)`

Screens: overview (month spend, budget bars, category donut, recent transactions), quick add (amount keypad first, then category, then optional note — amount is the first tap, always), budgets, and category management.

Currency: single currency chosen in onboarding, stored as minor units (integer pence) to avoid floating point. Multi-currency is postponed.

Statistics: monthly totals, category breakdown, 6-month trend, budget adherence. Nothing predictive, nothing advisory. The app does not give financial advice.

### 22.3 Notification architecture

Local notifications for everything except the daily briefing fallback. `flutter_local_notifications` + `timezone`.

**The iOS 64 pending-notification limit is a hard platform constraint.** Design for it:

- A `NotificationScheduler` owns all scheduling. No feature schedules directly.
- It maintains a priority-ordered candidate list from: task reminders, occurrence reminders, event alerts, briefings, deadline warnings.
- It schedules the top **56** by time (leaving headroom), and reschedules on: app resume, any write to a source, timezone change, and the daily maintenance job.
- Android has no such limit but the same scheduler is used, capped at 200.

**Android exact alarms**: on Android 13+, `SCHEDULE_EXACT_ALARM` is restricted. Use inexact alarms for briefings and deadline warnings (a few minutes of drift is irrelevant), and request exact-alarm permission contextually only when the user sets a time-critical reminder. If refused, fall back to inexact and say so plainly in the reminder editor.

**Battery optimisation** (Samsung, Xiaomi, OnePlus are the usual offenders): if notifications appear to be suppressed, show a one-time Settings row linking to the OEM battery settings, with copy explaining why.

Categories, each independently toggleable in Settings: task reminders, task deadlines, plan occurrences, habit reminders, event alerts, project deadlines, goal milestones, morning briefing, evening briefing, free-time nudges, weekly review. Quiet hours with a start/end. A global master switch.

Notification content rules: never guilt, never include private note or journal text in the body, always deep-link to the exact item.

### 22.4 Widgets

`home_widget` for the data bridge, native rendering on each platform: SwiftUI **WidgetKit** on iOS, **Glance** (or RemoteViews) on Android.

Data flow: the app writes a small JSON payload to the shared container (iOS App Group `group.app.lifeos`, Android SharedPreferences) after every relevant write and on the daily job. Widgets read that payload only. Widgets never open the database and never make network calls.

| Widget | Sizes | Content |
|---|---|---|
| Today's tasks | S, M | Up to 5, tap to open |
| Today's schedule | M, L | Time-ordered next 5 |
| Habit progress | S | Rings for up to 4 habits |
| Goal progress | S | One goal, ring + numbers |
| Upcoming film | M | Poster + date |
| Quick Add | S | Four deep-link buttons |
| Daily overview | L | Counts + next item + streak |

iOS also gets a Lock Screen accessory widget (circular: today's completion ring) and a Live Activity is explicitly postponed. Android gets a `WorkManager` periodic refresh every 30 minutes plus event-driven refresh.

Widgets must render a sensible state when there is no data yet ("Nothing today") and when the user is signed out ("Open Life OS").

### 22.5 Settings

Root list with 12 sections, each a subroute:

1. **Account** — email, sign out, change password, **delete account** (§27.4)
2. **Profile** — name, avatar, week start, currency, date format
3. **Appearance** — theme (Light/Dark/System), accent colour, app icon (Premium), text size preview, reduce motion override, haptics toggle
4. **Home** — dashboard card editor entry point, greeting name
5. **Notifications** — master switch, 11 categories, quiet hours, briefing times, permission status row
6. **AI** — master switch, per-domain scopes, write permission, briefing toggles, usage counter, activity log, "Clear AI history"
7. **Privacy** — analytics opt-out, crash reporting opt-out, journal lock, what leaves the device (a plain-English list)
8. **Data** — storage used, export, import, rebuild search index, rebuild statistics, clear image cache
9. **Calendar** — device calendar permission and per-calendar toggles
10. **Integrations** — TMDB status, Open Library status; each shows connected/not configured honestly
11. **Subscription** — current plan, what Plus adds, manage/restore purchases
12. **About** — version, build, licences (`showLicensePage`), TMDB attribution, privacy policy, terms, contact, "What's new"

Settings must be fully usable offline; anything requiring the network (subscription restore) says so.

---

## 23. DATA MODEL

### 23.1 Conventions applied to every table

| Column | Type | Purpose |
|---|---|---|
| `id` | TEXT | UUID v4 generated **on the client**, so creation works offline |
| `user_id` | TEXT | Owner; RLS key on the server |
| `created_at` | INTEGER | epoch ms UTC |
| `updated_at` | INTEGER | epoch ms UTC, bumped on every write |
| `deleted_at` | INTEGER? | Soft delete; purged after 30 days |
| `dirty` | INTEGER | 0/1, local-only, marks rows needing push |
| `version` | INTEGER | Increments per write, used for conflict logging |

Dates use `TEXT 'YYYY-MM-DD'`, times `TEXT 'HH:mm'`, timezone `TEXT` IANA name, money `INTEGER` minor units, lists and rules `TEXT` JSON.

### 23.2 Entity relationship summary

```
User 1─* Task *─1 Project *─1 Goal
     │         └─* Subtask
     │
     1─* Plan 1─* PlanOccurrence *─0..1 LibraryItem
     │      └─0..1 Goal                └─0..1 Task
     │
     1─* Goal 1─* GoalMilestone
     │      └─* GoalContribution ─* (any source)
     │
     1─* Event   1─* Habit(=Plan kind)
     1─* Note *─* (any entity via note_links)
     1─* LibraryItem *─* Collection
     1─* JournalEntry   1─* Expense *─1 Category
     1─* Reminder → (any entity)
     1─* Attachment → (any entity)
     1─* AIConversation 1─* AIMessage
     1─* DailyRollup (one per date)
```

### 23.3 Schema (SQLite / Drift; mirrored in Postgres for Supabase)

```sql
-- identity and preferences ---------------------------------------------
CREATE TABLE profiles (
  id TEXT PRIMARY KEY, display_name TEXT, avatar_path TEXT,
  timezone TEXT NOT NULL DEFAULT 'UTC', week_start INTEGER NOT NULL DEFAULT 1,
  currency TEXT NOT NULL DEFAULT 'GBP', date_format TEXT NOT NULL DEFAULT 'dmy',
  onboarded_at INTEGER, created_at INTEGER, updated_at INTEGER
);

CREATE TABLE preferences (       -- key/value, avoids a migration per setting
  user_id TEXT, key TEXT, value TEXT, updated_at INTEGER,
  PRIMARY KEY (user_id, key)
);

CREATE TABLE dashboard_cards (
  id TEXT PRIMARY KEY, user_id TEXT, type TEXT NOT NULL,
  position INTEGER NOT NULL, visible INTEGER NOT NULL DEFAULT 1,
  size TEXT NOT NULL DEFAULT 'medium', config TEXT,
  updated_at INTEGER, dirty INTEGER DEFAULT 0
);

-- tasks -----------------------------------------------------------------
CREATE TABLE tasks (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL,
  title TEXT NOT NULL, notes TEXT,
  due_date TEXT, due_time TEXT, timezone TEXT,
  priority INTEGER NOT NULL DEFAULT 0,          -- 0 none .. 3 high
  category_id TEXT, project_id TEXT, goal_id TEXT,
  recurrence_rule TEXT, parent_recurring_id TEXT,
  sort_index REAL NOT NULL DEFAULT 0,
  completed_at INTEGER,
  created_at INTEGER, updated_at INTEGER, deleted_at INTEGER,
  dirty INTEGER DEFAULT 0, version INTEGER DEFAULT 1
);
CREATE INDEX idx_tasks_due     ON tasks(user_id, due_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_project ON tasks(project_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_open    ON tasks(user_id, completed_at) WHERE deleted_at IS NULL;

CREATE TABLE subtasks (
  id TEXT PRIMARY KEY, task_id TEXT NOT NULL, title TEXT NOT NULL,
  completed_at INTEGER, sort_index REAL,
  created_at INTEGER, updated_at INTEGER, deleted_at INTEGER, dirty INTEGER DEFAULT 0
);

-- plans and occurrences --------------------------------------------------
CREATE TABLE plans (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL,
  kind TEXT NOT NULL DEFAULT 'plan',            -- plan | habit
  title TEXT NOT NULL, icon TEXT, colour TEXT, category TEXT,
  media_type TEXT,                              -- film | tv | book | null
  rule TEXT NOT NULL,                           -- JSON RecurrenceRule
  generation_version INTEGER NOT NULL DEFAULT 1,
  anchor_date TEXT NOT NULL, start_date TEXT NOT NULL,
  end_date TEXT, end_after_count INTEGER,
  time_of_day TEXT, duration_minutes INTEGER, target TEXT,
  reminder_offsets TEXT, missed_policy TEXT NOT NULL DEFAULT 'markMissed',
  schedule_mode TEXT NOT NULL DEFAULT 'fixed',
  grace_days INTEGER NOT NULL DEFAULT 0,
  pause_from TEXT, pause_until TEXT,
  goal_id TEXT, notes TEXT, sort_index REAL,
  archived_at INTEGER, created_at INTEGER, updated_at INTEGER,
  deleted_at INTEGER, dirty INTEGER DEFAULT 0, version INTEGER DEFAULT 1
);

CREATE TABLE plan_occurrences (
  id TEXT PRIMARY KEY,                          -- uuidV5 for generated rows
  plan_id TEXT NOT NULL, user_id TEXT NOT NULL,
  scheduled_date TEXT NOT NULL, scheduled_time TEXT, original_date TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  completed_at INTEGER, value_achieved REAL,
  linked_entity_type TEXT, linked_entity_id TEXT,
  note TEXT, is_exception INTEGER NOT NULL DEFAULT 0,
  generation_version INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER, updated_at INTEGER, deleted_at INTEGER,
  dirty INTEGER DEFAULT 0, version INTEGER DEFAULT 1
);
CREATE UNIQUE INDEX idx_occ_unique ON plan_occurrences(plan_id, scheduled_date, generation_version)
  WHERE is_exception = 0 AND deleted_at IS NULL;
CREATE INDEX idx_occ_date  ON plan_occurrences(user_id, scheduled_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_occ_plan  ON plan_occurrences(plan_id, scheduled_date DESC);

-- goals, projects --------------------------------------------------------
CREATE TABLE goals (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL, title TEXT NOT NULL, description TEXT,
  type TEXT NOT NULL, target_value REAL, current_value REAL DEFAULT 0, unit TEXT,
  start_date TEXT, end_date TEXT, colour TEXT, icon TEXT,
  status TEXT NOT NULL DEFAULT 'active',        -- active|reached|ended|archived
  created_at INTEGER, updated_at INTEGER, deleted_at INTEGER, dirty INTEGER DEFAULT 0
);
CREATE TABLE goal_milestones (
  id TEXT PRIMARY KEY, goal_id TEXT NOT NULL, title TEXT, target_value REAL,
  due_date TEXT, completed_at INTEGER, sort_index REAL, updated_at INTEGER, dirty INTEGER DEFAULT 0
);
CREATE TABLE goal_contributions (
  id TEXT PRIMARY KEY, goal_id TEXT NOT NULL, source_type TEXT NOT NULL,
  source_id TEXT NOT NULL, value REAL NOT NULL, date TEXT NOT NULL,
  created_at INTEGER, dirty INTEGER DEFAULT 0
);
CREATE UNIQUE INDEX idx_contrib_dedupe ON goal_contributions(goal_id, source_type, source_id);

CREATE TABLE projects (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL, title TEXT NOT NULL, description TEXT,
  colour TEXT, icon TEXT, deadline TEXT, goal_id TEXT,
  status TEXT NOT NULL DEFAULT 'active', sort_index REAL,
  completed_at INTEGER, created_at INTEGER, updated_at INTEGER,
  deleted_at INTEGER, dirty INTEGER DEFAULT 0
);

-- calendar, reminders ----------------------------------------------------
CREATE TABLE events (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL, title TEXT NOT NULL, notes TEXT,
  location TEXT, start_at INTEGER, end_at INTEGER,
  start_date TEXT, end_date TEXT, all_day INTEGER DEFAULT 0,
  timezone TEXT, colour TEXT, recurrence_rule TEXT,
  source TEXT NOT NULL DEFAULT 'local',         -- local | device
  external_id TEXT, external_calendar_id TEXT,
  created_at INTEGER, updated_at INTEGER, deleted_at INTEGER, dirty INTEGER DEFAULT 0
);
CREATE INDEX idx_events_range ON events(user_id, start_at);

CREATE TABLE reminders (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL,
  entity_type TEXT NOT NULL, entity_id TEXT NOT NULL,
  fire_at INTEGER NOT NULL, offset_minutes INTEGER,
  platform_id INTEGER,                          -- OS notification id
  delivered_at INTEGER, cancelled_at INTEGER,
  created_at INTEGER, updated_at INTEGER, dirty INTEGER DEFAULT 0
);
CREATE INDEX idx_reminders_fire ON reminders(user_id, fire_at) WHERE cancelled_at IS NULL;

-- library ----------------------------------------------------------------
CREATE TABLE library_items (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL,
  media_type TEXT NOT NULL,                     -- film | tv | book | link | document
  title TEXT NOT NULL, sort_title TEXT,
  provider_id TEXT, external_id TEXT,
  year INTEGER, poster_path TEXT, backdrop_path TEXT, overview TEXT,
  runtime_minutes INTEGER, genres TEXT, creators TEXT,
  status TEXT NOT NULL DEFAULT 'wishlist',
  rating REAL, is_favourite INTEGER DEFAULT 0, notes TEXT,
  progress_value REAL, progress_unit TEXT,
  added_at INTEGER, started_at INTEGER, finished_at INTEGER,
  created_at INTEGER, updated_at INTEGER, deleted_at INTEGER, dirty INTEGER DEFAULT 0
);
CREATE UNIQUE INDEX idx_lib_external ON library_items(user_id, provider_id, external_id)
  WHERE external_id IS NOT NULL AND deleted_at IS NULL;

CREATE TABLE media_metadata_cache (
  provider_id TEXT, external_id TEXT, media_type TEXT,
  payload TEXT NOT NULL, fetched_at INTEGER NOT NULL,
  PRIMARY KEY (provider_id, external_id, media_type)
);

CREATE TABLE collections (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL, title TEXT NOT NULL, description TEXT,
  cover_path TEXT, item_type TEXT, is_smart INTEGER DEFAULT 0, smart_query TEXT,
  sort_index REAL, created_at INTEGER, updated_at INTEGER, deleted_at INTEGER, dirty INTEGER DEFAULT 0
);
CREATE TABLE collection_items (
  collection_id TEXT, entity_type TEXT, entity_id TEXT,
  sort_index REAL, added_at INTEGER, dirty INTEGER DEFAULT 0,
  PRIMARY KEY (collection_id, entity_type, entity_id)
);

-- notes, journal, finance -------------------------------------------------
CREATE TABLE notes (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL, title TEXT, blocks TEXT NOT NULL,
  plain_text TEXT, folder_id TEXT, pinned INTEGER DEFAULT 0, colour TEXT,
  created_at INTEGER, updated_at INTEGER, deleted_at INTEGER, dirty INTEGER DEFAULT 0
);
CREATE TABLE note_links (
  note_id TEXT, entity_type TEXT, entity_id TEXT, created_at INTEGER,
  PRIMARY KEY (note_id, entity_type, entity_id)
);
CREATE TABLE journal_entries (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL, date TEXT NOT NULL,
  blocks TEXT, plain_text TEXT, mood INTEGER,
  created_at INTEGER, updated_at INTEGER, deleted_at INTEGER, dirty INTEGER DEFAULT 0
);
CREATE UNIQUE INDEX idx_journal_date ON journal_entries(user_id, date) WHERE deleted_at IS NULL;

CREATE TABLE categories (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL, domain TEXT NOT NULL,  -- task|expense|plan
  name TEXT NOT NULL, colour TEXT, icon TEXT, sort_index REAL,
  updated_at INTEGER, deleted_at INTEGER, dirty INTEGER DEFAULT 0
);
CREATE TABLE expenses (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL, type TEXT NOT NULL,
  amount_minor INTEGER NOT NULL, currency TEXT NOT NULL,
  category_id TEXT, date TEXT NOT NULL, note TEXT,
  recurrence_rule TEXT, attachment_id TEXT,
  created_at INTEGER, updated_at INTEGER, deleted_at INTEGER, dirty INTEGER DEFAULT 0
);
CREATE TABLE budgets (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL, category_id TEXT,
  amount_minor INTEGER NOT NULL, period TEXT NOT NULL, start_date TEXT,
  updated_at INTEGER, deleted_at INTEGER, dirty INTEGER DEFAULT 0
);

-- attachments, ai, stats, sync --------------------------------------------
CREATE TABLE attachments (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL, entity_type TEXT, entity_id TEXT,
  filename TEXT, mime_type TEXT, size_bytes INTEGER,
  local_path TEXT, remote_path TEXT, upload_state TEXT DEFAULT 'pending',
  created_at INTEGER, deleted_at INTEGER, dirty INTEGER DEFAULT 0
);
CREATE TABLE ai_conversations (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL, title TEXT,
  created_at INTEGER, updated_at INTEGER, deleted_at INTEGER, dirty INTEGER DEFAULT 0
);
CREATE TABLE ai_messages (
  id TEXT PRIMARY KEY, conversation_id TEXT NOT NULL, role TEXT NOT NULL,
  content TEXT, proposed_actions TEXT, executed_actions TEXT,
  token_count INTEGER, created_at INTEGER, dirty INTEGER DEFAULT 0
);
CREATE TABLE activity_log (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL, entity_type TEXT, entity_id TEXT,
  action TEXT, payload TEXT, source TEXT DEFAULT 'user',   -- user | ai | system
  created_at INTEGER
);
CREATE TABLE daily_rollups (
  user_id TEXT, date TEXT,
  tasks_completed INTEGER DEFAULT 0, tasks_created INTEGER DEFAULT 0,
  occurrences_completed INTEGER DEFAULT 0, occurrences_missed INTEGER DEFAULT 0,
  occurrences_skipped INTEGER DEFAULT 0, habits_completed INTEGER DEFAULT 0,
  habits_due INTEGER DEFAULT 0, films_watched INTEGER DEFAULT 0,
  books_finished INTEGER DEFAULT 0, pages_read INTEGER DEFAULT 0,
  study_minutes INTEGER DEFAULT 0, activity_minutes INTEGER DEFAULT 0,
  goal_contributions INTEGER DEFAULT 0, expense_total_minor INTEGER DEFAULT 0,
  journal_written INTEGER DEFAULT 0, activity_score INTEGER DEFAULT 0,
  updated_at INTEGER, dirty INTEGER DEFAULT 0,
  PRIMARY KEY (user_id, date)
);
CREATE TABLE outbox (
  seq INTEGER PRIMARY KEY AUTOINCREMENT, table_name TEXT NOT NULL,
  row_id TEXT NOT NULL, op TEXT NOT NULL,       -- upsert | delete
  payload TEXT, created_at INTEGER, attempts INTEGER DEFAULT 0, last_error TEXT
);
CREATE TABLE sync_state (
  table_name TEXT PRIMARY KEY, last_pulled_at INTEGER, last_pushed_seq INTEGER
);
CREATE VIRTUAL TABLE search_index USING fts5(
  entity_type UNINDEXED, entity_id UNINDEXED, title, body, tags,
  tokenize='unicode61 remove_diacritics 2'
);
```

### 23.4 Migration policy

Drift schema versions, one migration per release, never a destructive migration. Every migration ships with a test that opens a fixture database at version N-1 and asserts the upgrade. Keep generated schema snapshots in `drift_schemas/` and run `drift_dev schema` in CI.

---

## 24. OFFLINE ARCHITECTURE AND SYNC

### 24.1 Principle

The local SQLite database is the source of truth for the running app. The server is a durable replica and a transport between the user's devices. Nothing in the UI ever waits on the network.

Every write path is: **UI → repository → local transaction (data + rollup + outbox) → UI updates from the stream → sync pushes later.** No optimistic-update special cases, because there is nothing to be optimistic about.

### 24.2 Push

The outbox is an ordered log. The sync worker drains it in `seq` order, batching up to 200 rows per request into a Supabase RPC that performs an upsert with `ON CONFLICT (id)`. On success, clear `dirty` and advance `last_pushed_seq`. On network failure, exponential backoff (2s, 8s, 30s, 2m, 10m, capped) and retry with the same payload — upserts are idempotent, so a duplicated request is harmless.

### 24.3 Pull

Per table, `SELECT * WHERE user_id = auth.uid() AND updated_at > last_pulled_at ORDER BY updated_at LIMIT 500`, paged until exhausted. Advance the cursor to the **server's** max `updated_at` from the response, never to the device clock, which removes clock-skew bugs.

Triggers: app start, resume after 60s, manual pull-to-refresh, Supabase Realtime notification of a change from another device, and every 15 minutes while foregrounded.

### 24.4 Conflict resolution

Default: last-write-wins on `updated_at`, tie-broken by `device_id` string comparison so both devices converge on the same answer.

Field-level exceptions, because LWW gets these wrong in ways users notice:

| Case | Rule |
|---|---|
| Occurrence status | Precedence `completed > skipped > moved > missed > pending`. A completion on one device is never erased by a stale pending from another. |
| Task `completed_at` | Non-null wins over null. |
| Goal `current_value` | Never synced directly. Recomputed from `goal_contributions`, which are append-only and therefore conflict-free. |
| Deletions | A delete always wins over a concurrent edit. Tombstone retained 30 days. |
| Counters in `daily_rollups` | Never merged. Recomputed locally from source rows after a pull. |
| Notes blocks | LWW on the whole document, and the loser is kept as a `note_conflicts` row surfaced as "A version of this note from your other device was saved separately." Never silently lose writing. |

### 24.5 What is not synced

Local-only: `outbox`, `sync_state`, `search_index`, `media_metadata_cache`, image caches, and OS notification ids. All rebuildable.

### 24.6 First sync on a new device

Full pull with a progress screen, ordered so the app becomes usable early: profile and preferences → plans → occurrences (last 90 days + all future) → tasks → goals/projects → library → notes → everything else → historical occurrences in the background. Show "You can start using Life OS" as soon as the first four groups land.

### 24.7 Offline capability matrix

| Feature | Offline |
|---|---|
| Everything in Tasks, Plans, Habits, Goals, Projects, Calendar, Notes, Journal, Finance, Statistics, Your Year, Search (keyword), Widgets | Full |
| Film/book **search** | No — local library search only |
| Film/book posters | Cached only |
| AI chat, AI parse, briefing framing sentence | No — Layer 1 parser and deterministic briefing still work |
| Semantic search | No |
| Sign in / sign up | No — but an existing session persists and works |

Global behaviour: a thin `offline` banner appears under the header after 3 seconds offline, reading "Offline. Changes are saved here and will sync." It disappears on reconnect with a brief "Synced" confirmation.

---

## 25. AUTHENTICATION

### 25.1 Approach

Supabase Auth. Methods in v1: email + password, Sign in with Apple (required by App Store guideline 4.8 if any other third-party sign-in is offered), Google Sign-In. Magic links are postponed (deep-link handling plus email deliverability is a project).

**Local-first onboarding**: the user can complete onboarding and use the app before creating an account. Data is written locally against a device-scoped `user_id`. When they sign up, the local rows are re-keyed to the real `user_id` in one transaction and pushed. This removes the sign-up wall, which is the single biggest drop-off point in apps of this type.

### 25.2 Session

Access token in memory, refresh token in `flutter_secure_storage` (Keychain / EncryptedSharedPreferences). Silent refresh on resume. On refresh failure: keep the local database, show a non-blocking "Sign in again to sync" banner, and continue working offline. **Never wipe local data on an auth failure.**

### 25.3 Server-side security

Row Level Security on every table:

```sql
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
CREATE POLICY tasks_owner ON tasks
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
```

Repeat for all synced tables. Add a CI check that fails if any table lacks RLS. The anon key is public by design; it is safe only because RLS is correct, so RLS correctness is a release gate.

---

## 26. API REQUIREMENTS

| API | Purpose | Key handling | Failure mode |
|---|---|---|---|
| **Supabase** (Auth, Postgres, Storage, Realtime, Edge Functions) | Account, sync, files, AI proxy | Anon key in app (safe with RLS); service key only in Edge Functions | App works offline |
| **Anthropic API** | AI assistant | Server only, never in the app | AI features disabled, app unaffected |
| **TMDB** | Film/TV metadata | Read token stored server-side; app calls a thin Edge Function proxy so the key never ships | Search disabled, manual add available |
| **Open Library** | Book metadata | No key | Falls back to Google Books, then manual add |
| **RevenueCat** | Subscriptions | Public SDK key | Entitlement cached locally for 7 days |
| **Sentry** | Crash reporting | DSN in app | Silent |

Design note on TMDB: proxying through an Edge Function costs one hop but means the key can be rotated without an app release, rate limiting can be applied per user, and responses can be cached at the edge. Do this from the start; retrofitting it is painful.

---

## 27. PRIVACY ARCHITECTURE

### 27.1 Data classes

| Class | Examples | Handling |
|---|---|---|
| Identity | email, name | Supabase Auth, encrypted at rest |
| Content | tasks, notes, journal, finance | User's own rows, RLS-scoped, never used for training, never read by staff |
| Derived | rollups, search index | Local; rollups sync |
| Diagnostic | crashes, performance | Opt-in, scrubbed of content |
| AI context | the snapshot in §19.3 | Sent only for the current request, retained only in `ai_messages` locally |

### 27.2 Rules

- Analytics and crash reporting are **opt-in**, asked once after onboarding, never re-prompted more than once a year.
- No advertising SDKs. No third-party analytics beyond the chosen crash reporter. No IDFA request.
- Notification bodies never contain journal or note text.
- Settings → Privacy contains a plain-English "What leaves your device" list, per feature, kept accurate as features are added.

### 27.3 Store compliance

- iOS: complete the App Privacy questionnaire truthfully and ship a `PrivacyInfo.xcprivacy` manifest declaring required-reason APIs (file timestamps, user defaults, disk space).
- Android: Data Safety form matching the actual behaviour, plus a Play-compliant account deletion path both in-app and on the web.

### 27.4 Account deletion

Required by both stores. Settings → Account → Delete account:
1. Explain what is deleted and that it is irreversible.
2. Offer "Export your data first" as the primary alternative action.
3. Re-authenticate.
4. Type the word `delete` to confirm.
5. Call an Edge Function that removes all rows and storage objects, then deletes the auth user.
6. Wipe the local database and return to Welcome.
7. Provide the same flow at a public URL for users who have uninstalled.

### 27.5 Export and import

Export: a ZIP containing one JSON file per entity type (full fidelity, re-importable), a `data.csv` bundle for spreadsheets, and attachments. Generated locally so it works offline. Share sheet delivery.

Import: accepts our own export, plus CSV mapping for tasks and expenses. Import is always additive with a dry-run preview showing counts before writing. Never destructive.

---

## 28. SUBSCRIPTION STRATEGY

### 28.1 Principle

The free tier is a complete application. Nothing that a person needs to run their life is behind the paywall. Plus pays for the things that cost money to run (AI inference, cloud storage) and for depth, not for access.

### 28.2 Split

**Free — unlimited forever**: tasks, subtasks, projects (unlimited), plans, habits, goals, calendar, notes, films, TV, books, collections, journal, finance, statistics, Your Year, search, widgets, notifications, themes, export, and cloud sync on up to 2 devices.

**Plus (£2.99/month, £24.99/year, 7-day trial)**:
- AI assistant beyond 30 messages a month
- AI natural-language capture beyond 30 a month (Layer 1 local parsing stays unlimited)
- Semantic search
- Advanced statistics: custom date ranges, correlations, year-over-year comparison, CSV of any chart
- Unlimited devices and 5GB attachment storage (free tier: 100MB)
- Alternative app icons and custom accent colours
- Smart collections
- Priority support

**Never gated**: number of tasks, projects, plans, goals, habits, films, books or notes. Reminders. Data export. Account deletion. Offline use.

### 28.3 Implementation

RevenueCat with StoreKit 2 and Google Play Billing 6. Entitlement `plus` cached locally for 7 days so a subscriber who is offline is never locked out. Restore purchases on the Subscription screen and automatically on fresh install after sign-in.

Paywall rules: shown only when a gated action is attempted, plus one dismissible card in Settings. Never on launch. Never interstitial. Always shows the price and renewal terms on the same screen as the buy button, with Restore and Terms links.

---

## 29. ONBOARDING

Target: under 90 seconds, skippable at every step, and it produces a visibly personalised app.

| Step | Screen | Output |
|---|---|---|
| 1 | Welcome — one sentence, one illustration, "Get started" / "I have an account" | — |
| 2 | "What should I call you?" | `display_name` |
| 3 | "What do you want to organise?" — multi-select chips: Work · Study · Fitness · Films & TV · Reading · Hobbies · Money · Home · Health · Creative | Determines default categories and plan templates |
| 4 | "What matters most right now?" — single select: Getting things done · Building routines · Reaching a goal · Keeping track of what I enjoy | Determines default dashboard order |
| 5 | "Which parts do you want?" — toggles for the optional modules: Films & TV, Books, Journal, Finance, Habits, Study. All on by default | Hides tabs/sections that are off (reversible in Settings) |
| 6 | Optional: "Add your first thing" — a single Quick Add prompt with a suggested example based on step 3 | One real object |
| 7 | Building your dashboard — 1.2s animated assembly of the actual cards | `dashboard_cards` rows |
| 8 | Notification primer (custom screen, then the OS prompt only if they tap Enable) | Permission |

Skipping goes straight to a sensible default dashboard. The user must never be blocked. Account creation is offered at the end and again after three days of use, never as a gate.

---

## 30. COPY DECK — EMPTY STATES AND ERRORS

Voice: plain, second person, no exclamation marks, no apologies, no jokes at the user's expense. An empty state says what the thing is for and offers one action.

| Screen | Copy |
|---|---|
| Tasks — Today | **Nothing due today.** Add a task, or enjoy the gap. → Add task |
| Tasks — Completed | **Nothing finished yet.** Completed tasks collect here. |
| Plans | **Build a routine for anything.** Watch a film every Sunday, read every day, practise a hobby, or make your own. → Create a plan |
| Plan detail, no occurrences | **No dates yet.** Set a start date to generate the schedule. |
| Habits | **Small things, often.** Pick one thing you want to do regularly. → Add habit |
| Goals | **Nothing here yet.** Give yourself something to work towards. → Set a goal |
| Projects | **Group tasks that share an outcome.** → New project |
| Calendar day | **Nothing scheduled.** Long-press a time to add something. |
| Films | **Your watchlist is empty.** Add your first film. → Search films |
| Films watched | **No films watched yet.** They'll appear here once you mark one watched. |
| Books | **Nothing on the shelf.** Add a book to start tracking. |
| Notes | **No notes yet.** Notes can attach to tasks, plans, films — anything. → New note |
| Collections | **Make a list of anything.** Favourite films, books you own, places to visit. |
| Search | **Search everything.** Tasks, plans, films, notes, journal entries. |
| Search, no results | **Nothing matches "%s".** Try fewer words. |
| Statistics | **Not enough yet.** Come back after a few days of use. |
| Your Year | **Your year starts filling in as you use Life OS.** |
| Journal | **Nothing written yet.** → Write today's entry |
| Finance | **No transactions yet.** → Add an expense |
| AI | **Ask about your day, your plans, or anything you want to set up.** |

| Error | Copy |
|---|---|
| Offline | You're offline. Your changes are saved here and will sync when you're back. |
| AI unavailable | AI is temporarily unavailable. You can carry on using Life OS normally. |
| AI quota reached | You've used your 30 AI messages this month. They reset on 1 September. |
| Film search offline | Search needs a connection. Showing films already in your library. |
| Film API not configured | Film search isn't set up in this build. You can still add films manually. |
| Calendar permission denied | Calendar access isn't enabled. Life OS still works — turn it on in Settings whenever you like. |
| Notification permission denied | Reminders are off. You can turn them on in Settings. |
| Sync failed | Couldn't sync. Your data is safe on this device. Retrying. |
| Sign-in failed | That didn't work. Check your email and password, or reset it. |
| Storage full | Not enough space to save this file. Free some space and try again. |
| Note conflict | This note was edited on another device. Both versions are saved. → Compare |

---

## 31. FLUTTER PROJECT STRUCTURE

Feature-first, with a hard rule: **features may not import each other.** Cross-feature communication goes through `core/events` or a shared repository in `data/`. This is what keeps a 20-module app from turning into a knot.

```
lib/
  main.dart
  app.dart                         // MaterialApp.router, theme, locale
  bootstrap.dart                   // DI, db open, migrations, error zone

  design/
    tokens/ colors.dart typography.dart spacing.dart motion.dart shadows.dart
    theme/ light_theme.dart dark_theme.dart theme_extensions.dart
    components/ (30 files, §2.7)
    icons/ life_icons.dart

  core/
    scheduling/                    // PURE DART, no Flutter imports
      civil_date.dart recurrence_rule.dart recurrence_engine.dart
      materialiser.dart missed_sweep.dart
    nlp/ local_parser.dart tokens.dart patterns.dart
    events/ domain_event.dart event_bus.dart
    errors/ failure.dart error_mapper.dart
    utils/ result.dart debouncer.dart id.dart
    permissions/ permission_service.dart
    haptics/ haptics.dart
    connectivity/ connectivity_service.dart

  data/
    local/
      database.dart                // Drift
      tables/ (one per table)
      daos/ (one per aggregate)
      migrations/
    remote/
      supabase_client.dart
      sync/ sync_service.dart outbox_worker.dart puller.dart conflict_resolver.dart
      functions/ ai_function.dart tmdb_function.dart
    media/
      media_metadata_provider.dart // the abstraction
      tmdb/ tmdb_provider.dart tmdb_models.dart
      books/ open_library_provider.dart google_books_provider.dart
    repositories/ (task_repository.dart, plan_repository.dart, ...)

  features/
    onboarding/ auth/ home/ quick_add/ tasks/ projects/ plans/ habits/
    calendar/ goals/ library/ films/ books/ notes/ search/ ai/
    stats/ year/ journal/ finance/ settings/ widgets_bridge/
      // each: presentation/screens, presentation/widgets, application/controllers, domain/

  services/
    notifications/ notification_scheduler.dart notification_service.dart
    stats/ stats_recorder.dart rollup_service.dart
    goals/ goal_progress_service.dart
    maintenance/ daily_job.dart
    export/ export_service.dart import_service.dart
    purchases/ purchase_service.dart
    analytics/ analytics.dart          // no-op unless opted in

  routing/ router.dart routes.dart shell_scaffold.dart deep_links.dart

test/                                  // mirrors lib/
integration_test/
```

Native:
```
ios/LifeOSWidgets/          // SwiftUI WidgetKit
android/app/src/main/java/.../widgets/   // Glance
```

State management: **Riverpod** with code generation. Repositories expose `Stream` from Drift; controllers are `AsyncNotifier`. No `setState` outside purely local widget animation state.

---

## 32. RECOMMENDED PACKAGES

| Concern | Package | Note |
|---|---|---|
| State | `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator` | |
| Routing | `go_router` | `StatefulShellRoute` for tabs |
| Local DB | `drift`, `sqlite3_flutter_libs`, `path_provider` | FTS5 available |
| Models | `freezed`, `json_serializable`, `build_runner` | |
| Backend | `supabase_flutter` | Auth + Postgres + Storage + Realtime |
| Secure storage | `flutter_secure_storage` | Refresh token only |
| Notifications | `flutter_local_notifications`, `timezone`, `permission_handler` | |
| Background | `workmanager` | Android refresh + daily job |
| Charts | `fl_chart` | Style with tokens; Your Year uses CustomPainter, not fl_chart |
| Calendar grid | custom widget | `table_calendar` is a fallback if the month grid slips; note the decision if used |
| Images | `cached_network_image`, `flutter_cache_manager` | 200MB cap |
| Widgets | `home_widget` | Bridge only |
| Purchases | `purchases_flutter` (RevenueCat) | |
| Device calendar | `device_calendar` | Read-only v1 |
| Voice | `speech_to_text` | Optional, degrade silently |
| Biometrics | `local_auth` | Journal lock |
| Files | `file_picker`, `image_picker`, `share_plus`, `archive` | Export ZIP |
| Utility | `uuid`, `collection`, `intl`, `url_launcher`, `package_info_plus`, `device_info_plus` | |
| Crash | `sentry_flutter` | Opt-in |
| Motion | `flutter_animate` | Use sparingly, tokens still govern durations |
| Lint | `very_good_analysis` | |
| Test | `mocktail`, `drift_dev` (schema tests), plain `flutter_test` goldens (`golden_toolkit` is pub.dev-discontinued — see DECISIONS.md), `integration_test`, `patrol` | |

Rules: no package for something a 40-line widget can do. Every dependency added must be recorded in `DECISIONS.md` with the reason and the alternative rejected. Avoid anything unmaintained for over 12 months or without null safety.

**Windows development note.** Flutter builds Android and Windows locally. iOS builds and TestFlight uploads require macOS, so set up **Codemagic** or **GitHub Actions with a macOS runner** from Milestone 1 and treat iOS as a CI-only target until a Mac is available. Develop against an Android emulator plus a physical Android device. Do not defer this to the end; iOS-specific issues (App Groups, widget targets, sign-in with Apple, notification entitlements) surface only on a real build.

---

## 33. DEVELOPMENT MILESTONES

Each milestone is a complete, shippable increment with a Definition of Done. Do not start the next one until DoD passes.

**M1 — Project setup.** Flutter project, folder structure, lints, `build_runner`, flavours (dev/prod), CI on GitHub Actions (analyze + test + Android build), Codemagic macOS lane, Sentry wired but opt-in, `CLAUDE.md` and `DECISIONS.md` committed.
*DoD:* `flutter analyze` clean, CI green, debug APK installs.

**M2 — Design system.** All tokens, both themes, all 26 components (§2.7 — corrected from "30", which didn't match the actual list; see DECISIONS.md), golden tests at scale 1.0 and 1.5 in both themes, a `/dev/components` gallery screen behind a debug flag.
*DoD:* every component has a golden; contrast test passes for all token pairs.

**M3 — Navigation shell.** Five tabs, FAB, route table, deep-link handling, per-tab state preservation, placeholder screens that say "Not built yet" honestly.
*DoD:* every route in §3.2 resolves; back behaviour correct on Android; deep links open the right screen.

**M4 — Local database and auth.** Drift schema for all tables, migration test harness, repositories for profile/preferences, Supabase auth with email + Apple + Google, local-first onboarding identity, secure token storage, RLS policies deployed and tested.
*DoD:* sign up, sign out, sign in, kill app, session persists; a second account cannot read the first's rows (test against the live project).

**M5 — Tasks + Home v1.** Task CRUD, subtasks, all four views, swipe and long-press, inline add, undo, Home with `focus`, `upcoming` and `recent` cards, Quick Add type picker (no AI yet).
*DoD:* 500-task list scrolls at 60fps; complete/undo works offline; Home reflects a change within 100ms.

**M6 — Recurrence engine + Plans.** The pure engine with the full golden table, materialiser, missed sweep, plan CRUD, three-step creation, plans list, plan detail, occurrence completion.
*DoD:* all 24 golden cases pass; creating "every 3 days" produces the correct 120-day horizon; editing a plan preserves exceptions.

**M7 — Plan calendar + unified calendar.** Occurrence sheet, move/skip flows, month/week/3-day/day views, event CRUD, device calendar read-only import.
*DoD:* moving one occurrence provably does not shift the series (test); month view with 300 items scrolls at 60fps.

**M8 — Goals.** Goal CRUD, milestones, contributions, `GoalProgressService`, linking plans, projection arithmetic.
*DoD:* completing a linked occurrence increments the goal exactly once; un-completing decrements exactly once.

**M9 — Projects.** Project CRUD, task grouping, derived progress, activity log, deletion flow.
*DoD:* deleting a project offers both options and neither orphans nor silently deletes.

**M10 — Habits.** Habit kind, one-step creation, streaks, grace days, heatmap, 7-day strip, retroactive completion.
*DoD:* language audit passes (§13.3); skipped days never break a streak.

**M11 — Library + collections.** Library home, collections, links, documents, attachments with local storage.
*DoD:* a collection can hold films, books and notes together.

**M12 — Films and TV.** `MediaMetadataProvider`, TMDB via Edge Function proxy, search, detail, watchlist, ratings, film stats, and the schedule-films flow.
*DoD:* with the API key removed the app degrades to manual add with an honest message; attribution is displayed; no film data is bundled.

**M13 — Books and Notes.** Book provider, book tracking with progress, note editor with all block types, note linking from every detail screen.
*DoD:* a note attached to a task appears on both screens; notes survive a force-quit mid-edit.

**M14 — Search.** FTS5 index, triggers on every searchable table, ranking, grouped results, recent searches, rebuild command.
*DoD:* 20,000 rows searched under 50ms; a newly created task is findable within one second.

**M15 — Statistics + Your Year + Journal + Finance.** Rollups with incremental and nightly reconcile, stats screens, the CustomPainter year grid, day detail, journal, finance.
*DoD:* year grid first paint under 80ms; a full rebuild of 3 years of rollups completes without dropping frames.

**M16 — AI.** Edge Function, permission scopes, context builder, tool schema, proposal/confirmation flow, conversation UI, Layer 2 natural-language capture, briefings.
*DoD:* no API key in the app bundle (grep the built artifact); every mutating action passes through confirmation; app fully usable with AI off.

**M17 — Notifications.** `NotificationScheduler` with the 56-slot budget, all categories, quiet hours, exact-alarm handling, deep links from notifications.
*DoD:* with 200 candidate reminders, exactly 56 are scheduled on iOS and the nearest ones win; killing and relaunching reschedules correctly.

**M18 — Widgets.** Shared-container bridge, seven widgets on both platforms, refresh strategy.
*DoD:* widget updates within 30 seconds of an in-app change; signed-out and empty states render.

**M19 — Sync.** Outbox worker, puller, conflict resolver with the field-level exceptions, realtime trigger, first-sync flow, offline banner.
*DoD:* two devices, both offline, both edit the same task and the same occurrence; after reconnect they converge to the documented result with no data loss.

**M20 — Polish and accessibility.** Empty states, error states, animations, haptics, VoiceOver/TalkBack pass, Dynamic Type pass, reduce-motion pass, performance pass.
*DoD:* full app navigable by screen reader; no unlabelled controls; text scale 1.6 causes no overflow.

**M21 — Store preparation.** Icons, splash, screenshots, listings, privacy manifests, data safety form, account deletion web page, subscription products, TestFlight and internal testing builds.
*DoD:* both stores accept the build for review.

---

## 34. TESTING STRATEGY

| Layer | Target | Tooling |
|---|---|---|
| Pure logic (`core/scheduling`, `core/nlp`, conflict resolver, goal progress) | **95%+ coverage, non-negotiable** | `test` |
| Repositories and DAOs | 80% | `drift` in-memory database |
| Migrations | Every version transition | `drift_dev` schema fixtures |
| Controllers | Happy path + each error state | `riverpod` overrides + `mocktail` |
| Widgets | Every component; key screens | `flutter_test` |
| Goldens | Every design component, 2 themes × 2 text scales | `flutter_test` (`matchesGoldenFile` + a hand-rolled font-loading `flutter_test_config.dart`) |
| Integration | 12 critical journeys | `integration_test` / `patrol` |
| Performance | Frame timings on the 6 heavy screens | `integration_test` + `TimelineSummary` |

**Critical journeys to automate**: onboard → create task → complete it · create "every 3 days" plan → verify dates → skip one → verify the series is unchanged · add film → schedule it → complete → check the goal moved · go offline → make 10 edits → reconnect → verify sync · sign in on a second device → verify data arrives · delete account → verify local wipe.

Manual test matrix per release: iPhone SE (small, Dynamic Type XXL), iPhone 15 Pro, iPad (compatibility mode), Pixel (Android 14), Samsung (One UI, aggressive battery killer), a low-end Android (2GB RAM). Plus: DST transition day, timezone change mid-session, device date changed backwards, 10,000-row database, airplane mode throughout.

---

## 35. STORE PREPARATION

**Both**: app icon set, adaptive icon, splash, 6–8 screenshots per device class with real (seeded, non-fake) data, a 30-second preview video, description, keywords, support URL, privacy policy URL, marketing URL.

**Apple specifics**: App Privacy answers, `PrivacyInfo.xcprivacy` with required-reason API declarations, Sign in with Apple if any other social sign-in ships (4.8), account deletion in-app (5.1.1(v)), subscription metadata and a review note explaining the free tier, App Group entitlement for widgets, `NSCalendarsUsageDescription` / `NSPhotoLibraryUsageDescription` / `NSMicrophoneUsageDescription` / `NSSpeechRecognitionUsageDescription` / `NSFaceIDUsageDescription` written as user-facing sentences, not developer notes. Age rating 4+.

**Google specifics**: Data Safety form, target API level current, `POST_NOTIFICATIONS` runtime request, `SCHEDULE_EXACT_ALARM` justification only if used, account deletion web URL, subscription base plans and offers, closed testing track with 12 testers for 14 days before production (Play's current requirement for new personal developer accounts — verify at submission time).

**Review notes to include**: a demo account with seeded data, an explanation that AI features are optional and proxied, and confirmation that no film data is bundled and TMDB attribution is present.

---

## 36. TECHNICAL RISKS AND HOW TO SOLVE THEM

| # | Risk | Why it bites | Solution |
|---|---|---|---|
| 1 | DST and timezone drift in interval recurrence | `DateTime.add(Duration(days:3))` crosses a DST boundary and lands an hour off, then rounds to the wrong day | `CivilDate` value type, day-number arithmetic, no `Duration` in the engine. Golden cases 2, 3, 22. |
| 2 | Occurrence table growth | An open-ended daily plan over 5 years is 1,825 rows; 30 plans is 55,000 | 120-day horizon, lazy materialisation, per-plan cap of 5,000, indexed paged queries |
| 3 | Editing a plan destroys user exceptions | Users lose deliberate reschedules and stop trusting the app | Regeneration only touches `pending && !isException` future rows; report what was preserved; test 21 |
| 4 | Sync duplicates occurrences across devices | Two devices generate the same series with different UUIDs | Deterministic uuidV5 ids (§9.7) |
| 5 | LWW erases a completion | You tick a habit on your phone, your tablet syncs a stale row, the tick disappears | Field-level precedence rules (§24.4) |
| 6 | iOS 64 pending-notification cap | Silent, undocumented-feeling failure once a user has many reminders | Central `NotificationScheduler`, 56-slot budget, reschedule on every relevant event |
| 7 | Android exact alarms and OEM battery killers | Reminders never arrive on Samsung/Xiaomi | Inexact by default, contextual exact-alarm request, OEM settings helper row, honest copy |
| 8 | Home screen jank on cold start | 15 cards each opening a stream | One composed `HomeSnapshot` query, measured budget under 400ms |
| 9 | Your Year rebuilds 365 widgets | Dropped frames on the flagship screen | Single `CustomPainter` over an `Int8List` |
| 10 | AI key leakage | A key in the app is extractable from the bundle in minutes | Edge Function proxy for both AI and TMDB; CI grep of the release artifact for key patterns |
| 11 | AI hallucinating destructive changes | "Clear my week" deletes real data | Proposals only, never server-side writes, per-action toggles, second confirm for bulk, 10-second undo, `activity_log` with `source='ai'` |
| 12 | AI cost per user | Unbounded context and message volume | 4k-token context cap, 20-turn window, 30-message free quota, server-side rate limit, small model for parsing and a larger one only for reasoning |
| 13 | TMDB terms and rate limits | Suspension of the key, or store rejection over attribution | Proxy with per-user rate limiting and edge caching, cache only saved items, display required attribution, review terms before commercial launch |
| 14 | FTS index drift | Search silently misses new items | Triggers not manual calls, plus a nightly consistency check and a user-visible rebuild command |
| 15 | Drift migration failure in the field | Corrupt or unopenable database on upgrade | Schema fixtures for every version in CI, automatic pre-migration backup file, recovery path that restores the backup and reports it |
| 16 | Windows-only development | iOS problems found at the very end | CI macOS lane from M1, iOS smoke build every milestone |
| 17 | Attachment storage cost | Users upload 500MB of images | 25MB per file, 100MB free tier quota, visible usage meter, upload only over the sync worker with resumability |
| 18 | Scope creep across 20 modules | The app never ships | Milestone gates with DoD; §37 postponement list is binding |
| 19 | Text scale 1.6 breaking dense screens | Accessibility rejection or unusable UI | `ScaledLayout` switch at 1.3, golden tests at 1.5, overflow test in CI |
| 20 | Clock skew and device date changes | Duplicate generation, wrong streaks, corrupted sync cursor | Server timestamps for sync cursors, monotonic guard on the daily job, test 23 |

---

## 37. BUILD ORDER — WHAT FIRST, WHAT LATER

### 37.1 Build first (the load-bearing walls)

1. Design system — everything else depends on it and retrofitting tokens is miserable.
2. The recurrence engine — the highest-risk, highest-value component, and it is pure Dart so it can be perfected without any UI.
3. Local database and repositories — the app's actual foundation.
4. Tasks — the simplest complete vertical slice, which proves the architecture end to end.
5. Plans and occurrences — the differentiating feature.
6. Home — the daily surface that makes the app feel like a product.

### 37.2 Postponed to v1.1 or later — do not build these now

- Two-way device calendar sync (read-only in v1)
- Per-episode TV tracking (series-level only in v1)
- Semantic search (M16+, Premium)
- Smart collections (M15 at the earliest)
- Web app and desktop
- Apple Watch and Wear OS
- Live Activities and Dynamic Island
- Shortcuts / App Intents / Siri
- Bank connection, multi-currency, receipt scanning
- Sharing, collaboration, public profiles
- Import from Todoist, Notion, Apple Reminders, Letterboxd, Goodreads
- Health app integration
- Time tracking and Pomodoro
- Location-based reminders
- Handwriting and drawing in notes
- Themes beyond accent colour
- Localisation beyond English (but wrap every string in the l10n system from M2 so this stays cheap)

Record each of these in `POSTPONED.md` with the reason, so the decision is visible rather than forgotten.

---

## 38. IMPLEMENTATION ROADMAP FOR CLAUDE CODE

Work through these prompts in order, one session each. Start every session by reading `CLAUDE.md` and the referenced sections.

| # | Prompt to give Claude Code | Reads |
|---|---|---|
| 1 | Set up the Flutter project, folder structure, lints, flavours, CI, and commit `CLAUDE.md`, `DECISIONS.md`, `POSTPONED.md`. | §31, §32, M1 |
| 2 | Build the complete design system: tokens, both themes, all components in §2.7, the dev gallery, and golden tests. | §2, M2 |
| 3 | Build the navigation shell, route table and deep links, with honest placeholder screens. | §3, M3 |
| 4 | Implement the full Drift schema, migration harness, and profile/preferences repositories. | §23, M4 |
| 5 | Implement Supabase auth, local-first identity, secure session storage, and RLS policies with a cross-account access test. | §25, M4 |
| 6 | **Build `core/scheduling` as pure Dart.** Implement `CivilDate`, all seven rule types, the engine, and all 24 golden test cases. No UI. Do not proceed until every case passes. | §9, M6 |
| 7 | Build Tasks end to end: repository, four views, swipes, subtasks, undo, inline add. | §10, M5 |
| 8 | Build Home v1 with the `HomeSnapshot` provider and the first six cards, plus the customise screen. | §5, M5 |
| 9 | Build Quick Add with the local Layer 1 parser and its 120-case test suite. No AI yet. | §6, M5 |
| 10 | Build Plans: CRUD, three-step creation with the live date preview, materialiser, missed sweep, list and detail. | §7, §9.5, §9.6, M6 |
| 11 | Build the occurrence sheet, move/skip flows, and the plan calendar, with a test proving a move does not shift the series. | §8, M7 |
| 12 | Build the unified calendar: four views, event CRUD, read-only device calendar import. | §14, M7 |
| 13 | Build Goals, `GoalProgressService`, and the contributions ledger. | §12, M8 |
| 14 | Build Projects with derived progress and the activity log. | §11, M9 |
| 15 | Build Habits on top of the Plan engine, with streaks, grace days and the language audit. | §13, M10 |
| 16 | Build Library and Collections, including attachments. | §15, M11 |
| 17 | Build the `MediaMetadataProvider` abstraction, the TMDB Edge Function proxy, film search, detail and watchlist. | §16, M12 |
| 18 | Build the film scheduling flow that links library items to occurrences. | §16.5, M12 |
| 19 | Build Books and the Notes editor with linking. | §16, §17, M13 |
| 20 | Build FTS5 search with triggers, ranking and the rebuild command. | §18, M14 |
| 21 | Build the rollup pipeline, the statistics screens, and Your Year with the CustomPainter grid. | §20, §21, M15 |
| 22 | Build Journal and Finance. | §22.1, §22.2, M15 |
| 23 | Build the AI Edge Function, context builder, tool schema, and the proposal/confirmation flow. Then wire Layer 2 capture and the briefings. | §19, M16 |
| 24 | Build the `NotificationScheduler` with the 56-slot budget and all categories. | §22.3, M17 |
| 25 | Build the widget bridge and the seven widgets on both platforms. | §22.4, M18 |
| 26 | Build sync: outbox, puller, conflict resolver, realtime, first-sync flow. Then run the two-device convergence test. | §24, M19 |
| 27 | Build Settings in full, including export, import and account deletion. | §22.5, §27, M21 |
| 28 | Build onboarding. | §29, M21 |
| 29 | Polish pass: empty states, errors, animation, haptics, accessibility, performance. | §2.9, §30, M20 |
| 30 | Store preparation: assets, manifests, listings, subscriptions, test tracks. | §35, M21 |

### 38.1 Session hygiene

- One milestone per session. If a session runs long, stop at a green test suite, not mid-refactor.
- Commit at every green point with a message naming the milestone.
- Update `DECISIONS.md` whenever a choice is made that this spec left open.
- If a section of this spec turns out to be wrong in practice, change the spec in the same commit as the code. A stale spec is worse than none.

---

*End of specification.*
