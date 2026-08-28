import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/routing/routes.dart';

class _SettingsRow {
  const _SettingsRow(this.icon, this.title, this.route);
  final IconData icon;
  final String title;
  final String route;
}

const _accountRows = [
  _SettingsRow(Icons.person_outline, 'Account', Routes.settingsAccount),
  _SettingsRow(Icons.badge_outlined, 'Profile', Routes.settingsProfile),
  _SettingsRow(Icons.replay_outlined, 'Redo setup', Routes.onboarding),
];

const _preferenceRows = [
  _SettingsRow(Icons.palette_outlined, 'Appearance', Routes.settingsAppearance),
  _SettingsRow(Icons.dashboard_customize_outlined, 'Home dashboard', Routes.settingsHome),
  _SettingsRow(Icons.notifications_outlined, 'Notifications', Routes.settingsNotifications),
  _SettingsRow(Icons.calendar_month_outlined, 'Calendar', Routes.settingsCalendar),
  _SettingsRow(Icons.auto_awesome_outlined, 'AI', Routes.settingsAi),
];

const _dataRows = [
  _SettingsRow(Icons.lock_outline, 'Privacy', Routes.settingsPrivacy),
  _SettingsRow(Icons.storage_outlined, 'Data', Routes.settingsData),
  _SettingsRow(Icons.extension_outlined, 'Integrations', Routes.settingsIntegrations),
];

const _aboutRows = [
  _SettingsRow(Icons.workspace_premium_outlined, 'Subscription', Routes.settingsSubscription),
  _SettingsRow(Icons.info_outline, 'About', Routes.settingsAbout),
];

/// The Settings hub (§22.5) — every section from the route table gets a
/// real, navigable entry here. Built: Profile, Appearance, Notifications
/// (preferences only, nothing scheduled yet), AI, Privacy, Data,
/// Integrations, About. Account, Home dashboard, Calendar and Subscription
/// resolve to the honest "not built yet" state (CLAUDE.md rule 1) — each
/// needs either a real auth session, a card catalogue, a native calendar
/// permission, or IAP, none of which exist yet; see DECISIONS.md.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: LifeSpace.s8),
        children: [
          _group(context, 'Account', _accountRows),
          _group(context, 'Preferences', _preferenceRows),
          _group(context, 'Data & Privacy', _dataRows),
          _group(context, 'About', _aboutRows),
          if (kDebugMode) _group(context, 'Developer', const [_SettingsRow(Icons.widgets_outlined, 'Component gallery', Routes.devComponentGallery)]),
        ],
      ),
    );
  }

  Widget _group(BuildContext context, String title, List<_SettingsRow> rows) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(LifeSpace.s16, LifeSpace.s16, LifeSpace.s16, LifeSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LSectionHeader(title: title),
          const SizedBox(height: LifeSpace.s4),
          for (final row in rows)
            LListTile(
              leading: Icon(row.icon, color: colors.neutrals.ink2),
              title: row.title,
              trailing: Icon(Icons.chevron_right, color: colors.neutrals.ink3),
              onTap: () => context.push(row.route),
            ),
        ],
      ),
    );
  }
}
