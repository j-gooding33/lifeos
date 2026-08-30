import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/home/application/briefing.dart';
import 'package:life_os/features/home/application/briefing_providers.dart';

/// §19.9's `/home/briefing/:period`. The framing sentence is always the
/// deterministic one (`morningSentence`/`eveningSentence`) — there's no
/// AI backend wired up to generate the model version yet (see Settings →
/// AI's own decision), which is exactly the spec's own fallback anyway:
/// "the briefing must work without the network."
class BriefingScreen extends ConsumerWidget {
  const BriefingScreen({required this.period, super.key});

  final BriefingPeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncBriefing = ref.watch(briefingProvider(period));
    final title = period == BriefingPeriod.morning ? 'Morning briefing' : 'Evening briefing';

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: Text(title)),
      body: asyncBriefing.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text("Couldn't load your briefing.", style: context.textStyles.body.copyWith(color: colors.neutrals.ink2)),
        ),
        data: (briefing) => ListView(
          padding: const EdgeInsets.all(LifeSpace.s20),
          children: [
            Text(briefing.sentence, style: context.textStyles.title3.copyWith(color: colors.neutrals.ink)),
            const SizedBox(height: LifeSpace.cardGap),
            if (period == BriefingPeriod.morning) _FreeTimeSection(windows: briefing.freeWindows) else _CompletedSection(titles: briefing.completedToday),
          ],
        ),
      ),
    );
  }
}

class _FreeTimeSection extends StatelessWidget {
  const _FreeTimeSection({required this.windows});

  final List<FreeTimeWindow> windows;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LSectionHeader(title: 'Free time'),
        const SizedBox(height: LifeSpace.s8),
        if (windows.isEmpty)
          Text(
            'No free windows of 30 minutes or more left today.',
            style: context.textStyles.body.copyWith(color: colors.neutrals.ink2),
          )
        else
          for (final window in windows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: LifeSpace.s4),
              child: Text(
                '${_formatTime(context, window.start)} – ${_formatTime(context, window.end)} '
                '(${_formatDuration(window.duration)})',
                style: context.textStyles.body.copyWith(color: colors.neutrals.ink2),
              ),
            ),
      ],
    );
  }

  String _formatTime(BuildContext context, DateTime dt) => TimeOfDay.fromDateTime(dt).format(context);

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
}

class _CompletedSection extends StatelessWidget {
  const _CompletedSection({required this.titles});

  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LSectionHeader(title: 'Completed today'),
        const SizedBox(height: LifeSpace.s8),
        if (titles.isEmpty)
          Text('Nothing marked done today.', style: context.textStyles.body.copyWith(color: colors.neutrals.ink2))
        else
          for (final title in titles)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: LifeSpace.s4),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 18, color: colors.accent.base),
                  const SizedBox(width: LifeSpace.s8),
                  Expanded(child: Text(title, style: context.textStyles.body.copyWith(color: colors.neutrals.ink))),
                ],
              ),
            ),
      ],
    );
  }
}
