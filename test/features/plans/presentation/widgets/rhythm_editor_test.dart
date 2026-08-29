import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';
import 'package:life_os/features/plans/presentation/widgets/rhythm_editor.dart';

import '../../../../design/golden_harness.dart';

/// Reproduces `HabitCreateScreen`/`PlanCreateScreen`'s own call site: a
/// parent whose `onRuleChanged` is an inline `setState`, exactly the
/// shape that crashed both of them (see the test below).
class _Parent extends StatefulWidget {
  const _Parent();

  @override
  State<_Parent> createState() => _ParentState();
}

class _ParentState extends State<_Parent> {
  RecurrenceRule? _rule;

  @override
  Widget build(BuildContext context) {
    return RhythmEditor(
      anchor: CivilDate.fromDateTime(DateTime.now()),
      onRuleChanged: (rule) => setState(() => _rule = rule),
    );
  }
}

void main() {
  testWidgets("mounting inside a parent whose onRuleChanged calls setState doesn't crash", (tester) async {
    await pumpGolden(tester, const _Parent(), brightness: Brightness.dark, textScale: 1);
    // The bug this guards: RhythmEditor.initState called onRuleChanged
    // synchronously, which is the parent's own setState, called while
    // the parent was still being built for the first time — Flutter's
    // "setState() or markNeedsBuild() called during build" assertion.
    expect(tester.takeException(), isNull);

    // The deferred notify still needs to actually happen, one frame
    // later, or the parent never learns the editor's initial rule.
    await tester.pump();
    expect(tester.state<_ParentState>(find.byType(_Parent))._rule, isNotNull);
  });
}
