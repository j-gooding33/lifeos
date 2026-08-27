/// Path constants for the §3.2 route table. Every path here must have a
/// matching `GoRoute` in `router.dart` — that pairing is what M3's DoD
/// ("every route in §3.2 resolves") actually checks.
class Routes {
  const Routes._();

  static const onboarding = '/onboarding';
  static const authSignIn = '/auth/sign-in';
  static const authSignUp = '/auth/sign-up';
  static const authReset = '/auth/reset';

  static const home = '/home';
  static const homeDay = '/home/day/:date';
  static const homeBriefing = '/home/briefing/:period';
  static const homeCustomise = '/home/customise';

  static const plans = '/plans';
  static const plansNew = '/plans/new';
  static const planDetail = '/plans/:id';
  static const planEdit = '/plans/:id/edit';
  static const planCalendar = '/plans/:id/calendar';
  static const planOccurrence = '/plans/:id/occurrence/:occId';
  static const habits = '/habits';
  static const habitDetail = '/habits/:id';
  static const calendar = '/calendar';
  static const calendarEvent = '/calendar/event/:id';

  static const tasks = '/tasks';
  static const tasksNew = '/tasks/new';
  static const taskDetail = '/tasks/:id';
  static const projects = '/projects';
  static const projectDetail = '/projects/:id';
  static const projectNewTask = '/projects/:id/new-task';
  static const goals = '/goals';
  static const goalsNew = '/goals/new';
  static const goalDetail = '/goals/:id';

  static const library = '/library';
  static const libraryFilms = '/library/films';
  static const libraryFilmsSearch = '/library/films/search';
  static const libraryFilmDetail = '/library/films/:id';
  static const libraryTv = '/library/tv';
  static const libraryTvDetail = '/library/tv/:id';
  static const libraryBooks = '/library/books';
  static const libraryBooksSearch = '/library/books/search';
  static const libraryBookDetail = '/library/books/:id';
  static const libraryNotes = '/library/notes';
  static const libraryNoteDetail = '/library/notes/:id';
  static const libraryCollectionDetail = '/library/collections/:id';
  static const libraryLinks = '/library/links';

  // M8 additions — not in §3.2's original table (that milestone predates
  // this brief). Same `/library/<type>/...` convention as the routes
  // above.
  static const libraryFilmRatings = '/library/films/ratings';
  static const libraryFilmTop5 = '/library/films/top5';
  static const libraryTvSearch = '/library/tv/search';
  static const libraryTvSeason = '/library/tv/:id/season/:seasonNumber';
  static const libraryTvShowRatings = '/library/tv/ratings';
  static const libraryTvEpisodeRatings = '/library/tv/episode-ratings';
  static const libraryTvTop5 = '/library/tv/top5';
  static const libraryBookRatings = '/library/books/ratings';
  static const libraryBookTop3 = '/library/books/top3';
  static const libraryAllRatings = '/library/ratings';

  static const stats = '/stats';
  static const statsYear = '/stats/year';
  static const statsDomain = '/stats/:domain';
  static const journal = '/journal';
  static const journalDate = '/journal/:date';
  static const finance = '/finance';
  static const financeExpense = '/finance/expense/:id';
  static const financeBudgets = '/finance/budgets';

  static const search = '/search';
  static const ai = '/ai';
  static const aiConversation = '/ai/conversation/:id';

  static const settings = '/settings';
  // §22.5 lists 12 sections; §3.2 says "+ 11 subroutes" — corrected in the
  // spec, see DECISIONS.md.
  static const settingsAccount = '/settings/account';
  static const settingsProfile = '/settings/profile';
  static const settingsAppearance = '/settings/appearance';
  static const settingsHome = '/settings/home';
  static const settingsNotifications = '/settings/notifications';
  static const settingsAi = '/settings/ai';
  static const settingsPrivacy = '/settings/privacy';
  static const settingsData = '/settings/data';
  static const settingsCalendar = '/settings/calendar';
  static const settingsIntegrations = '/settings/integrations';
  static const settingsSubscription = '/settings/subscription';
  static const settingsAbout = '/settings/about';

  static const devComponentGallery = '/dev/components';

  // §3.4 deep-link aliases — shorter paths used by `lifeos://` and
  // `https://lifeos.app/o/`, redirected onto the real in-app routes above.
  static const deepLinkTask = '/task/:id';
  static const deepLinkPlan = '/plan/:id';
  static const deepLinkOccurrence = '/occurrence/:id';
  static const deepLinkDay = '/day/:date';
  static const deepLinkQuickAdd = '/quickadd';
  static const deepLinkAi = '/ai'; // same path as the in-app AI sheet route
}
