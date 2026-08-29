import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/utils/first_value.dart';
import 'package:life_os/data/local/daos/task_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/models/app_task.dart';
import 'package:life_os/data/repositories/task_repository.dart';

const _dataKey = 'today_tasks';
// The dev flavor's applicationIdSuffix (§4, build.gradle.kts) makes the
// runtime package (app.lifeos.life_os.dev) diverge from the Kotlin
// source's actual package (app.lifeos.life_os, same as MainActivity) —
// found live-testing as a ClassNotFoundException, since home_widget's
// plain `androidName` resolves against the former. `qualifiedAndroidName`
// is the escape hatch: an exact class path, unaffected by flavor suffix.
const _androidWidgetName = 'app.lifeos.life_os.TodayTasksWidgetProvider';
const _maxRows = 5;

/// §22.4. Owns the Flutter side of the data bridge: compute a small JSON
/// payload and hand it to `home_widget`, which writes it to the platform's
/// shared container (Android SharedPreferences here; no iOS target exists
/// yet — see DECISIONS.md). `TodayTasksWidgetProvider` (Android, native)
/// reads that payload back and renders it — the widget itself never opens
/// the database or makes a network call, matching §22.4's data-flow rule.
///
/// There's no "signed out" payload to write: `currentUserId` (§4, M4) is a
/// local-first identity that's never absent, so that spec-required state
/// is instead the native side's own default before [refresh] has ever run
/// once — see `TodayTasksWidgetProvider.render`'s null-payload branch.
class HomeWidgetService {
  HomeWidgetService(AppDatabase db) : _taskRepository = TaskRepository(TaskDao(db));

  final TaskRepository _taskRepository;

  Future<void> refresh(String userId) async {
    final tasks = await firstValue(_taskRepository.watchToday(userId, CivilDate.fromDateTime(DateTime.now())));
    await HomeWidget.saveWidgetData<String>(_dataKey, buildPayload(tasks));
    await HomeWidget.updateWidget(qualifiedAndroidName: _androidWidgetName);
  }

  @visibleForTesting
  static String buildPayload(List<AppTask> tasks) {
    final titles = tasks.take(_maxRows).map((t) => t.title).toList();
    return jsonEncode({'signedIn': true, 'titles': titles});
  }
}
