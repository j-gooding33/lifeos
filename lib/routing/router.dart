import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/design/dev_gallery/dev_component_gallery_screen.dart';
import 'package:life_os/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:life_os/features/calendar/presentation/screens/event_detail_screen.dart';
import 'package:life_os/features/home/presentation/screens/home_screen.dart';
import 'package:life_os/features/library/presentation/screens/book_detail_screen.dart';
import 'package:life_os/features/library/presentation/screens/book_ratings_screen.dart';
import 'package:life_os/features/library/presentation/screens/book_search_screen.dart';
import 'package:life_os/features/library/presentation/screens/book_top3_screen.dart';
import 'package:life_os/features/library/presentation/screens/books_screen.dart';
import 'package:life_os/features/library/presentation/screens/collection_detail_screen.dart';
import 'package:life_os/features/library/presentation/screens/collections_screen.dart';
import 'package:life_os/features/library/presentation/screens/film_detail_screen.dart';
import 'package:life_os/features/library/presentation/screens/film_ratings_screen.dart';
import 'package:life_os/features/library/presentation/screens/film_search_screen.dart';
import 'package:life_os/features/library/presentation/screens/film_top5_screen.dart';
import 'package:life_os/features/library/presentation/screens/films_screen.dart';
import 'package:life_os/features/library/presentation/screens/library_home_screen.dart';
import 'package:life_os/features/library/presentation/screens/library_stats_screen.dart';
import 'package:life_os/features/library/presentation/screens/note_editor_screen.dart';
import 'package:life_os/features/library/presentation/screens/notes_screen.dart';
import 'package:life_os/features/library/presentation/screens/season_episodes_screen.dart';
import 'package:life_os/features/library/presentation/screens/tv_episode_ratings_screen.dart';
import 'package:life_os/features/library/presentation/screens/tv_ratings_screen.dart';
import 'package:life_os/features/library/presentation/screens/tv_search_screen.dart';
import 'package:life_os/features/library/presentation/screens/tv_show_detail_screen.dart';
import 'package:life_os/features/library/presentation/screens/tv_shows_screen.dart';
import 'package:life_os/features/library/presentation/screens/tv_top5_screen.dart';
import 'package:life_os/features/library/presentation/screens/unified_ratings_screen.dart';
import 'package:life_os/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:life_os/features/plans/presentation/screens/habit_create_screen.dart';
import 'package:life_os/features/plans/presentation/screens/habit_detail_screen.dart';
import 'package:life_os/features/plans/presentation/screens/habits_screen.dart';
import 'package:life_os/features/plans/presentation/screens/plan_calendar_screen.dart';
import 'package:life_os/features/plans/presentation/screens/plan_create_screen.dart';
import 'package:life_os/features/plans/presentation/screens/plan_detail_screen.dart';
import 'package:life_os/features/plans/presentation/screens/plan_occurrence_screen.dart';
import 'package:life_os/features/plans/presentation/screens/plans_screen.dart';
import 'package:life_os/features/quick_add/presentation/quick_add_sheet.dart';
import 'package:life_os/features/school/presentation/screens/school_dashboard_screen.dart';
import 'package:life_os/features/school/presentation/screens/school_setup_screen.dart';
import 'package:life_os/features/school/presentation/screens/school_terms_screen.dart';
import 'package:life_os/features/school/presentation/screens/school_timetable_screen.dart';
import 'package:life_os/features/settings/presentation/screens/ai_settings_screen.dart';
import 'package:life_os/features/settings/presentation/screens/appearance_screen.dart';
import 'package:life_os/features/settings/presentation/screens/settings_screen.dart';
import 'package:life_os/features/tasks/presentation/screens/goal_create_screen.dart';
import 'package:life_os/features/tasks/presentation/screens/goal_detail_screen.dart';
import 'package:life_os/features/tasks/presentation/screens/goals_screen.dart';
import 'package:life_os/features/tasks/presentation/screens/project_detail_screen.dart';
import 'package:life_os/features/tasks/presentation/screens/projects_screen.dart';
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
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
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
              GoRoute(
                path: Routes.habits,
                builder: (context, state) => const HabitsScreen(),
              ),
              GoRoute(
                path: Routes.habitsNew,
                builder: (context, state) => const HabitCreateScreen(),
              ),
              GoRoute(
                path: Routes.habitDetail,
                builder: (context, state) => HabitDetailScreen(habitId: state.pathParameters['id']!),
              ),
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
              GoRoute(
                path: Routes.projects,
                builder: (context, state) => const ProjectsScreen(),
              ),
              GoRoute(
                path: Routes.projectDetail,
                builder: (context, state) => ProjectDetailScreen(projectId: state.pathParameters['id']!),
              ),
              _placeholderRoute(Routes.projectNewTask, 'New project task'),
              GoRoute(
                path: Routes.goals,
                builder: (context, state) => const GoalsScreen(),
              ),
              GoRoute(
                path: Routes.goalsNew,
                builder: (context, state) => const GoalCreateScreen(),
              ),
              GoRoute(
                path: Routes.goalDetail,
                builder: (context, state) => GoalDetailScreen(goalId: state.pathParameters['id']!),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.library,
                builder: (context, state) => const LibraryHomeScreen(),
              ),
              GoRoute(
                path: Routes.libraryAllRatings,
                builder: (context, state) => const UnifiedRatingsScreen(),
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
                path: Routes.libraryFilmStats,
                builder: (context, state) => const LibraryStatsScreen(mediaType: MediaType.film),
              ),
              GoRoute(
                path: Routes.libraryFilmDetail,
                builder: (context, state) => FilmDetailScreen(filmId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: Routes.libraryTv,
                builder: (context, state) => const TvShowsScreen(),
              ),
              GoRoute(
                path: Routes.libraryTvSearch,
                builder: (context, state) => const TvSearchScreen(),
              ),
              // Static siblings of libraryTvDetail (`/library/tv/:id`) must
              // come before it — see the same note by libraryFilmDetail.
              GoRoute(
                path: Routes.libraryTvShowRatings,
                builder: (context, state) => const TvRatingsScreen(),
              ),
              GoRoute(
                path: Routes.libraryTvEpisodeRatings,
                builder: (context, state) => const TvEpisodeRatingsScreen(),
              ),
              GoRoute(
                path: Routes.libraryTvTop5,
                builder: (context, state) => const TvTop5Screen(),
              ),
              GoRoute(
                path: Routes.libraryTvStats,
                builder: (context, state) => const LibraryStatsScreen(mediaType: MediaType.tv),
              ),
              GoRoute(
                path: Routes.libraryTvSeason,
                builder: (context, state) => SeasonEpisodesScreen(
                  showId: state.pathParameters['id']!,
                  seasonNumber: int.parse(state.pathParameters['seasonNumber']!),
                ),
              ),
              GoRoute(
                path: Routes.libraryTvDetail,
                builder: (context, state) => TvShowDetailScreen(showId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: Routes.libraryBooks,
                builder: (context, state) => const BooksScreen(),
              ),
              GoRoute(
                path: Routes.libraryBooksSearch,
                builder: (context, state) => const BookSearchScreen(),
              ),
              // Static siblings of libraryBookDetail (`/library/books/:id`)
              // must come before it — see the note by libraryFilmDetail.
              GoRoute(
                path: Routes.libraryBookRatings,
                builder: (context, state) => const BookRatingsScreen(),
              ),
              GoRoute(
                path: Routes.libraryBookTop3,
                builder: (context, state) => const BookTop3Screen(),
              ),
              GoRoute(
                path: Routes.libraryBookStats,
                builder: (context, state) => const LibraryStatsScreen(mediaType: MediaType.book),
              ),
              GoRoute(
                path: Routes.libraryBookDetail,
                builder: (context, state) => BookDetailScreen(bookId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: Routes.libraryNotes,
                builder: (context, state) => const NotesScreen(),
              ),
              GoRoute(
                path: Routes.libraryNoteDetail,
                builder: (context, state) => NoteEditorScreen(noteId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: Routes.libraryCollections,
                builder: (context, state) => const CollectionsScreen(),
              ),
              GoRoute(
                path: Routes.libraryCollectionDetail,
                builder: (context, state) => CollectionDetailScreen(collectionId: state.pathParameters['id']!),
              ),
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

      GoRoute(
        path: Routes.schoolDashboard,
        builder: (context, state) => const SchoolDashboardScreen(),
      ),
      GoRoute(
        path: Routes.schoolSetup,
        builder: (context, state) => const SchoolSetupScreen(),
      ),
      GoRoute(
        path: Routes.schoolTimetable,
        builder: (context, state) => const SchoolTimetableScreen(),
      ),
      GoRoute(
        path: Routes.schoolTerms,
        builder: (context, state) => const SchoolTermsScreen(),
      ),

      _placeholderRoute(Routes.search, 'Search'),
      _placeholderRoute(Routes.ai, 'AI assistant'),
      _placeholderRoute(Routes.aiConversation, 'AI conversation'),

      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      _placeholderRoute(Routes.settingsAccount, 'Account'),
      _placeholderRoute(Routes.settingsProfile, 'Profile'),
      GoRoute(
        path: Routes.settingsAppearance,
        builder: (context, state) => const AppearanceScreen(),
      ),
      _placeholderRoute(Routes.settingsHome, 'Home settings'),
      _placeholderRoute(Routes.settingsNotifications, 'Notifications'),
      GoRoute(
        path: Routes.settingsAi,
        builder: (context, state) => const AiSettingsScreen(),
      ),
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
