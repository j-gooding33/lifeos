import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:life_os/data/local/daos/activity_log_dao.dart';
import 'package:life_os/data/local/daos/event_dao.dart';
import 'package:life_os/data/local/daos/library_item_dao.dart';
import 'package:life_os/data/local/daos/preferences_dao.dart';
import 'package:life_os/data/local/daos/profile_dao.dart';
import 'package:life_os/data/local/daos/top_list_dao.dart';
import 'package:life_os/data/local/daos/tv_episode_dao.dart';
import 'package:life_os/data/local/migrations/v1_indexes.dart';
import 'package:life_os/data/local/migrations/v2_indexes.dart';
import 'package:life_os/data/local/migrations/v3_search_triggers.dart';
import 'package:life_os/data/local/migrations/v4_documents.dart';
import 'package:life_os/data/local/tables/activity_log_table.dart';
import 'package:life_os/data/local/tables/ai_conversations_table.dart';
import 'package:life_os/data/local/tables/ai_messages_table.dart';
import 'package:life_os/data/local/tables/attachments_table.dart';
import 'package:life_os/data/local/tables/budgets_table.dart';
import 'package:life_os/data/local/tables/categories_table.dart';
import 'package:life_os/data/local/tables/collection_items_table.dart';
import 'package:life_os/data/local/tables/collections_table.dart';
import 'package:life_os/data/local/tables/daily_rollups_table.dart';
import 'package:life_os/data/local/tables/dashboard_cards_table.dart';
import 'package:life_os/data/local/tables/document_links_table.dart';
import 'package:life_os/data/local/tables/documents_table.dart';
import 'package:life_os/data/local/tables/events_table.dart';
import 'package:life_os/data/local/tables/expenses_table.dart';
import 'package:life_os/data/local/tables/goal_contributions_table.dart';
import 'package:life_os/data/local/tables/goal_milestones_table.dart';
import 'package:life_os/data/local/tables/goals_table.dart';
import 'package:life_os/data/local/tables/journal_entries_table.dart';
import 'package:life_os/data/local/tables/library_items_table.dart';
import 'package:life_os/data/local/tables/links_table.dart';
import 'package:life_os/data/local/tables/media_metadata_cache_table.dart';
import 'package:life_os/data/local/tables/note_links_table.dart';
import 'package:life_os/data/local/tables/notes_table.dart';
import 'package:life_os/data/local/tables/outbox_table.dart';
import 'package:life_os/data/local/tables/plan_occurrences_table.dart';
import 'package:life_os/data/local/tables/plans_table.dart';
import 'package:life_os/data/local/tables/preferences_table.dart';
import 'package:life_os/data/local/tables/profiles_table.dart';
import 'package:life_os/data/local/tables/projects_table.dart';
import 'package:life_os/data/local/tables/reminders_table.dart';
import 'package:life_os/data/local/tables/school_closures_table.dart';
import 'package:life_os/data/local/tables/school_events_table.dart';
import 'package:life_os/data/local/tables/school_lessons_table.dart';
import 'package:life_os/data/local/tables/school_profile_table.dart';
import 'package:life_os/data/local/tables/school_terms_table.dart';
import 'package:life_os/data/local/tables/subtasks_table.dart';
import 'package:life_os/data/local/tables/sync_state_table.dart';
import 'package:life_os/data/local/tables/tasks_table.dart';
import 'package:life_os/data/local/tables/top_list_items_table.dart';
import 'package:life_os/data/local/tables/tv_episodes_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Profiles,
    Preferences,
    DashboardCards,
    Tasks,
    Subtasks,
    Plans,
    PlanOccurrences,
    Goals,
    GoalMilestones,
    GoalContributions,
    Projects,
    Events,
    Reminders,
    LibraryItems,
    MediaMetadataCache,
    Collections,
    CollectionItems,
    Notes,
    NoteLinks,
    Links,
    JournalEntries,
    Categories,
    Expenses,
    Budgets,
    Attachments,
    AiConversations,
    AiMessages,
    ActivityLog,
    DailyRollups,
    Outbox,
    SyncState,
    TvEpisodes,
    TopListItems,
    SchoolProfile,
    SchoolLessons,
    SchoolTerms,
    SchoolClosures,
    SchoolEvents,
    Documents,
    DocumentLinks,
  ],
  daos: [
    ProfileDao,
    PreferencesDao,
    ActivityLogDao,
    EventDao,
    LibraryItemDao,
    TvEpisodeDao,
    TopListDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await createV1IndexesAndFts(m);
      await createV2Indexes(m);
      await createV3SearchTriggers(m);
      await createV4DocumentSearchTriggers(m);
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(tvEpisodes);
        await m.createTable(topListItems);
        await m.createTable(schoolProfile);
        await m.createTable(schoolLessons);
        await m.createTable(schoolTerms);
        await m.createTable(schoolClosures);
        await m.createTable(schoolEvents);
        await createV2Indexes(m);
      }
      if (from < 3 && to >= 3) {
        await m.createTable(links);
        await createV3SearchTriggers(m);
      }
      if (from < 4 && to >= 4) {
        await m.createTable(documents);
        await createV4DocumentSearchTriggers(m);
      }
      if (from < 5 && to >= 5) {
        await m.createTable(documentLinks);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'life_os.sqlite'));
    return NativeDatabase.createInBackground(
      file,
      setup: (database) {
        applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
        database.execute('PRAGMA foreign_keys = ON;');
      },
    );
  });
}
