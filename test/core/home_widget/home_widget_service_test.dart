import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/home_widget/home_widget_service.dart';
import 'package:life_os/data/repositories/models/app_task.dart';

AppTask _task(String title) => AppTask(id: title, userId: 'u1', title: title);

void main() {
  test('an empty task list still marks the payload signed in, not just absent', () {
    final payload = jsonDecode(HomeWidgetService.buildPayload([])) as Map<String, Object?>;
    expect(payload['signedIn'], isTrue);
    expect(payload['titles'], isEmpty);
  });

  test('titles are carried through in order', () {
    final payload = jsonDecode(HomeWidgetService.buildPayload([_task('Water plants'), _task('Call dentist')])) as Map<String, Object?>;
    expect(payload['titles'], ['Water plants', 'Call dentist']);
  });

  test("caps at 5 rows, matching the widget layout's 5 fixed slots", () {
    final tasks = List.generate(8, (i) => _task('Task $i'));
    final payload = jsonDecode(HomeWidgetService.buildPayload(tasks)) as Map<String, Object?>;
    expect(payload['titles'], hasLength(5));
    expect(payload['titles'], ['Task 0', 'Task 1', 'Task 2', 'Task 3', 'Task 4']);
  });
}
