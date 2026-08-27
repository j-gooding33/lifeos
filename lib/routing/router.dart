import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/design/dev_gallery/dev_component_gallery_screen.dart';
import 'package:life_os/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:life_os/features/calendar/presentation/screens/event_detail_screen.dart';
import 'package:life_os/features/home/presentation/screens/home_screen.dart';
import 'package:life_os/features/library/presentation/screens/film_detail_screen.dart';
import 'package:life_os/features/library/presentation/screens/film_ratings_screen.dart';
import 'package:life_os/features/library/presentation/screens/film_search_screen.dart';
import 'package:life_os/features/library/presentation/screens/film_top5_screen.dart';
import 'package:life_os/features/library/presentation/screens/films_screen.dart';
import 'package:life_os/features/library/presentation/screens/library_home_screen.dart';
import 'package:life_os/features/plans/presentation/screens/plan_calendar_screen.dart';
import 'package:life_os/features/plans/presentation/screens/plan_create_screen.dart';
import 'package:life_os/features/plans/presentation/screens/plan_detail_screen.dart';
import 'package:life_os/features/plans/presentation/screens/plan_occurrence_screen.dart';
import 'package:life_os/features/plans/presentation/screens/plans_screen.dart';
import 'package:life_os/features/quick_add/presentation/quick_add_sheet.dart';
import 'package:life_os/features/tasks/presentation/screens/task_detail_screen.dart';
import 'package:life_os/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:life_os/routing/deep_links.dart';
import 'package:life_os/routing/not_built_yet_screen.dart';
import 'package:life_os/routing/routes.dart';
import 'package:life_os/routing/shell_scaffold.dart';

Widget Function(BuildContext, GoRouterState) _placeholder(String featureName) {
  return (context, state) => NotBuiltYetScreen(featureName: featureName);
}

GoRoute _placeholderRoute(String path, String featureName) {
  return GoRoute(path: path, builder: _placeholder(featureName));
}

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      _placeholderRoute(Routes.onboarding, 'Onboarding'),
      _placeholderRoute(Routes.authSignIn, 'Sign in'),
      _placeholderRoute(Routes.authSignUp, 'Sign up'),
      _placeholderRoute(Routes.authReset, 'Reset password'),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomeScreen(),
              ),
              _placeholderRoute(Routes.homeDay, 'Day detail'),
              _placeholderRoute(Routes.homeBriefing, 'Briefing'),
              _placeholderRoute(Routes.homeCustomise, 'Customise dashboard'),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.plans,
                builder: (context, state) => const PlansScreen(),
              ),
              GoRoute(
                path: Routes.plansNew,
                builder: (context, state) => const PlanCreateScreen(),
              ),
              GoRoute(
                path: Routes.planDetail,
                builder: (context, state) =>
                    PlanDetailScreen(planId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: Routes.planEdit,
                builder: (context, state) =>
                    PlanCreateScreen(planId: state.pathParameters['id']),
              ),
              GoRoute(
                path: Routes.planCalendar,
                builder: (context, state) =>
                    PlanCalendarScreen(planId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: Routes.planOccurrence,
                builder: (context, state) => PlanOccurrenceScreen(
                  occurrenceId: state.pathParameters['occId']!,
                ),
              ),
              _placeholderRoute(Routes.habits, 'Habits'),
              _placeholderRoute(Routes.habitDetail, 'Habit detail'),
              GoRoute(
                path: Routes.calendar,
                builder: (context, state) => const CalendarScreen(),
              ),
              GoRoute(
                path: Routes.calendarEvent,
                builder: (context, state) {
                  final id = state.pathParameters['id'];
                  if (id == 'new') {
                    return EventDetailScreen(
                      initialDate: state.extra as DateTime?,
                    );
                  }
                  return EventDetailScreen(eventId: id);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.tasks,
                builder: (context, state) => const TasksScreen(),
              ),
              GoRoute(
                path: Routes.tasksNew,
                builder: (context, state) => const TaskDetailScreen(),
              ),
              GoRoute(
                path: Routes.taskDetail,
                builder: (context, state) =>
                    TaskDetailScreen(taskId: state.pathParameters['id']),
              ),
              _placeholderRoute(Routes.projects, 'Projects'),
              _placeholderRoute(Routes.projectDetail, 'Project detail'),
              _placeholderRoute(Routes.projectNewTask, 'New project task'),
              _placeholderRoute(Routes.goals, 'Goals'),
              _placeholderRoute(Routes.goalsNew, 'New goal'),
              _placeholderRoute(Routes.goalDetail, 'Goal detail'),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.library,
                builder: (context, state) => const LibraryHomeScreen(),
              ),
              GoRoute(
                path: Routes.libraryFilms,
                builder: (context, state) => const FilmsScreen(),
              ),
              GoRoute(
                path: Routes.libraryFilmsSearch,
                builder: (context, state) => const FilmSearchScreen(),
              ),
              // Static-path siblings of `libraryFilmDetail` (`/library/films/:id`)
              // must be declared before it — go_router matches sibling routes in
              // declaration order, and `:id` would otherwise swallow them.
              GoRoute(
                path: Routes.libraryFilmRatings,
                builder: (context, state) => const FilmRatingsScreen(),
              ),
              GoRoute(
                path: Routes.libraryFilmTop5,
                builder: (context, state) => const FilmTop5Screen(),
              ),
              GoRoute(
                path: Routes.libraryFilmDetail,
                builder: (context, state) => FilmDetailScreen(filmId: state.pathParameters['id']!),
              ),
              _placeholderRoute(Routes.libraryTv, 'TV'),
              _placeholderRoute(Routes.libraryTvDetail, 'TV detail'),
              _placeholderRoute(Routes.libraryBooks, 'Books'),
              _placeholderRoute(Routes.libraryBooksSearch, 'Search books'),
              _placeholderRoute(Routes.libraryBookDetail, 'Book detail'),
              _placeholderRoute(Routes.libraryNotes, 'Notes'),
              _placeholderRoute(Routes.libraryNoteDetail, 'Note'),
              _placeholderRoute(Routes.libraryCollectionDetail, 'Collection'),
              _placeholderRoute(Routes.libraryLinks, 'Links'),
            ],
          ),
          StatefulShellBranch(
            routes: [
              _placeholderRoute(Routes.stats, 'Stats'),
              _placeholderRoute(Routes.statsYear, 'Your Year'),
              _placeholderRoute(Routes.statsDomain, 'Domain stats'),
              _placeholderRoute(Routes.journal, 'Journal'),
              _placeholderRoute(Routes.journalDate, 'Journal entry'),
              _placeholderRoute(Routes.finance, 'Finance'),
              _placeholderRoute(Routes.financeExpense, 'Expense'),
              _placeholderRoute(Routes.financeBudgets, 'Budgets'),
            ],
          ),
        ],
      ),

      _placeholderRoute(Routes.search, 'Search'),
      _placeholderRoute(Routes.ai, 'AI assistant'),
      _placeholderRoute(Routes.aiConversation, 'AI conversation'),

      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const NotBuiltYetScreen(
          featureName: 'Settings',
          showDevGalleryLink: true,
        ),
      ),
      _placeholderRoute(Routes.settingsAccount, 'Account'),
      _placeholderRoute(Routes.settingsProfile, 'Profile'),
      _placeholderRoute(Routes.settingsAppearance, 'Appearance'),
      _placeholderRoute(Routes.settingsHome, 'Home settings'),
      _placeholderRoute(Routes.settingsNotifications, 'Notifications'),
      _placeholderRoute(Routes.settingsAi, 'AI settings'),
      _placeholderRoute(Routes.settingsPrivacy, 'Privacy'),
      _placeholderRoute(Routes.settingsData, 'Data'),
      _placeholderRoute(Routes.settingsCalendar, 'Calendar settings'),
      _placeholderRoute(Routes.settingsIntegrations, 'Integrations'),
      _placeholderRoute(Routes.settingsSubscription, 'Subscription'),
      _placeholderRoute(Routes.settingsAbout, 'About'),

      if (kDebugMode)
        GoRoute(
          path: Routes.devComponentGallery,
          builder: (context, state) => const DevComponentGalleryScreen(),
        ),

      GoRoute(path: Routes.deepLinkTask, redirect: taskDeepLinkRedirect),
      GoRoute(path: Routes.deepLinkPlan, redirect: planDeepLinkRedirect),
      // No redirect needed (unlike the other aliases above): an occurrence
      // can now be looked up by its own id alone, without knowing its
      // parent plan's id up front (M7's `PlanRepository.watchOccurrenceById`).
      GoRoute(
        path: Routes.deepLinkOccurrence,
        builder: (context, state) =>
            PlanOccurrenceScreen(occurrenceId: state.pathParameters['id']!),
      ),
      GoRoute(path: Routes.deepLinkDay, redirect: dayDeepLinkRedirect),
      GoRoute(
        path: Routes.deepLinkQuickAdd,
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Quick Add')),
          body: const QuickAddSheet(),
        ),
      ),
    ],
  );
}
