import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/settings/application/preference_toggle.dart';

const _analyticsKey = 'privacy.analytics';
const _crashReportingKey = 'privacy.crashReporting';

/// §22.5. Journal biometric lock isn't built (needs `local_auth`); see
/// DECISIONS.md.
class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final analytics = ref.watch(boolPreferenceProvider(_analyticsKey)).value ?? false;
    final crashReporting = ref.watch(boolPreferenceProvider(_crashReportingKey)).value ?? false;

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(
        padding: const EdgeInsets.all(LifeSpace.s16),
        children: [
          LListTile(
            title: 'Share anonymous usage data',
            subtitle: 'Not collected yet — this app has no analytics service configured.',
            trailing: Switch(value: analytics, onChanged: (v) => setBoolPreference(ref, _analyticsKey, value: v)),
          ),
          LListTile(
            title: 'Send crash reports',
            subtitle: 'Off by default; no crash reporting service is configured in this build.',
            trailing: Switch(value: crashReporting, onChanged: (v) => setBoolPreference(ref, _crashReportingKey, value: v)),
          ),
          const SizedBox(height: LifeSpace.cardGap),
          const LSectionHeader(title: 'What leaves this device'),
          const SizedBox(height: LifeSpace.s8),
          LCard(
            child: Text(
              'Nothing, right now. Life OS runs fully offline — every task, plan, note, journal entry and '
              "expense stays in a local database on this device. There's no account sync and no AI assistant "
              'configured in this build. When either is enabled in a future update, this section will say '
              'exactly what each one sends.',
              style: context.textStyles.body.copyWith(color: colors.neutrals.ink2),
            ),
          ),
        ],
      ),
    );
  }
}
