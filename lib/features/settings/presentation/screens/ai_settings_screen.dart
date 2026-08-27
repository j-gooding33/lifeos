import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/data/repositories/models/ai_permission_scopes.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/settings/application/ai_settings_providers.dart';

typedef _DomainScope = ({
  String label,
  bool Function(AiPermissionScopes) get,
  AiPermissionScopes Function(AiPermissionScopes, {required bool value}) set,
});

const _domains = <_DomainScope>[
  (label: 'Tasks', get: _tasks, set: _setTasks),
  (label: 'Plans', get: _plans, set: _setPlans),
  (label: 'Habits', get: _habits, set: _setHabits),
  (label: 'Goals', get: _goals, set: _setGoals),
  (label: 'Projects', get: _projects, set: _setProjects),
  (label: 'Calendar', get: _calendar, set: _setCalendar),
  (label: 'Library', get: _library, set: _setLibrary),
  (label: 'Statistics', get: _statistics, set: _setStatistics),
  (label: 'Journal', get: _journal, set: _setJournal),
  (label: 'Finance', get: _finance, set: _setFinance),
];

bool _tasks(AiPermissionScopes s) => s.tasks;
bool _plans(AiPermissionScopes s) => s.plans;
bool _habits(AiPermissionScopes s) => s.habits;
bool _goals(AiPermissionScopes s) => s.goals;
bool _projects(AiPermissionScopes s) => s.projects;
bool _calendar(AiPermissionScopes s) => s.calendar;
bool _library(AiPermissionScopes s) => s.library;
bool _statistics(AiPermissionScopes s) => s.statistics;
bool _journal(AiPermissionScopes s) => s.journal;
bool _finance(AiPermissionScopes s) => s.finance;

AiPermissionScopes _setTasks(AiPermissionScopes s, {required bool value}) => s.copyWith(tasks: value);
AiPermissionScopes _setPlans(AiPermissionScopes s, {required bool value}) => s.copyWith(plans: value);
AiPermissionScopes _setHabits(AiPermissionScopes s, {required bool value}) => s.copyWith(habits: value);
AiPermissionScopes _setGoals(AiPermissionScopes s, {required bool value}) => s.copyWith(goals: value);
AiPermissionScopes _setProjects(AiPermissionScopes s, {required bool value}) => s.copyWith(projects: value);
AiPermissionScopes _setCalendar(AiPermissionScopes s, {required bool value}) => s.copyWith(calendar: value);
AiPermissionScopes _setLibrary(AiPermissionScopes s, {required bool value}) => s.copyWith(library: value);
AiPermissionScopes _setStatistics(AiPermissionScopes s, {required bool value}) => s.copyWith(statistics: value);
AiPermissionScopes _setJournal(AiPermissionScopes s, {required bool value}) => s.copyWith(journal: value);
AiPermissionScopes _setFinance(AiPermissionScopes s, {required bool value}) => s.copyWith(finance: value);

/// Settings → AI (§22.5, §19.2). M8 Parts 35-40 built the permission-scopes
/// UI only — §19.1 requires a Supabase Edge Function for a real AI chat,
/// which doesn't exist yet (see DECISIONS.md). These switches save real
/// preferences now so nothing needs re-asking once that backend exists.
class AiSettingsScreen extends ConsumerWidget {
  const AiSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncScopes = ref.watch(aiPermissionScopesProvider);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('AI assistant')),
      body: asyncScopes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text("Couldn't load your settings.", style: context.textStyles.body.copyWith(color: colors.neutrals.ink2)),
        ),
        data: (scopes) => _buildForm(context, ref, scopes),
      ),
    );
  }

  Widget _buildForm(BuildContext context, WidgetRef ref, AiPermissionScopes scopes) {
    final colors = context.colors;

    Future<void> update(AiPermissionScopes next) => saveAiPermissionScopes(ref, next);

    return ListView(
      padding: const EdgeInsets.all(LifeSpace.s16),
      children: [
        LCard(
          child: Text(
            "The AI assistant isn't available yet — it needs a server component this app doesn't have configured. "
            'These permissions are saved now and will take effect as soon as it is.',
            style: context.textStyles.callout.copyWith(color: colors.neutrals.ink2),
          ),
        ),
        const SizedBox(height: LifeSpace.cardGap),
        LListTile(
          title: 'Enable AI assistant',
          subtitle: 'Master switch for the whole feature.',
          trailing: Switch(value: scopes.enabled, onChanged: (v) => update(scopes.copyWith(enabled: v))),
        ),
        LListTile(
          title: 'Let it make changes',
          subtitle: 'Every change still needs your confirmation first.',
          trailing: Switch(value: scopes.canWrite, onChanged: (v) => update(scopes.copyWith(canWrite: v))),
        ),
        const SizedBox(height: LifeSpace.s16),
        const LSectionHeader(title: 'What it can read'),
        const SizedBox(height: LifeSpace.s8),
        for (final domain in _domains)
          LListTile(
            title: domain.label,
            trailing: Switch(value: domain.get(scopes), onChanged: (v) => update(domain.set(scopes, value: v))),
          ),
      ],
    );
  }
}
