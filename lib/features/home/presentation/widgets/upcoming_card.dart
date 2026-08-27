import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/colors.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/home/application/home_providers.dart';
import 'package:life_os/features/home/presentation/widgets/suggestion_card.dart';
import 'package:life_os/routing/routes.dart';

/// Next 7 days plus an undated bucket (§5.3, item 6/7). Days with nothing
/// are hidden by default — a list of seven mostly-empty rows every day is
/// worse than a short list that says what's actually coming — behind a
/// "show empty days" toggle for when the full week's shape matters.
class UpcomingCard extends StatefulWidget {
  const UpcomingCard({required this.snapshot, super.key});

  final HomeSnapshot snapshot;

  @override
  State<UpcomingCard> createState() => _UpcomingCardState();
}

class _UpcomingCardState extends State<UpcomingCard> {
  var _showEmptyDays = false;

  static const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.snapshot;
    if (snapshot.hasNothingUpcoming) {
      return const SuggestionCard(title: 'Nothing upcoming');
    }

    final colors = context.colors;
    final today = CivilDate.fromDateTime(DateTime.now());
    final days = [for (var i = 1; i <= 7; i++) today.addDays(i)];
    final visibleDays = _showEmptyDays
        ? days
        : days.where((d) => !(snapshot.upcomingByDay[d.toIso()] ?? const UpcomingBucket(count: 0, firstTitle: null)).isEmpty).toList();
    final hiddenCount = days.length - visibleDays.length;

    return LCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LSectionHeader(title: 'Upcoming'),
          const SizedBox(height: LifeSpace.s8),
          for (final date in visibleDays)
            _bucketRow(
              context,
              colors,
              label: '${_weekdayNames[date.isoWeekday - 1]} ${date.day} ${_monthNames[date.month - 1]}',
              bucket: snapshot.upcomingByDay[date.toIso()] ?? const UpcomingBucket(count: 0, firstTitle: null),
              onTap: () => context.push(Routes.homeDay.replaceFirst(':date', date.toIso())),
            ),
          if (!snapshot.upcomingUndated.isEmpty)
            _bucketRow(context, colors, label: 'No date', bucket: snapshot.upcomingUndated, onTap: null),
          if (hiddenCount > 0 || _showEmptyDays)
            Padding(
              padding: const EdgeInsets.only(top: LifeSpace.s4),
              child: TextButton(
                onPressed: () => setState(() => _showEmptyDays = !_showEmptyDays),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
                child: Text(
                  _showEmptyDays ? 'Hide empty days' : 'Show empty days ($hiddenCount)',
                  style: context.textStyles.caption.copyWith(color: colors.accent.base),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bucketRow(
    BuildContext context,
    LifeColors colors, {
    required String label,
    required UpcomingBucket bucket,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: LifeSpace.s4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 72,
              child: Text(label, style: context.textStyles.body.copyWith(color: colors.neutrals.ink)),
            ),
            Expanded(
              child: bucket.isEmpty
                  ? Text('Nothing', style: context.textStyles.body.copyWith(color: colors.neutrals.ink3))
                  : Text(
                      bucket.firstTitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.body.copyWith(color: colors.neutrals.ink2),
                    ),
            ),
            Text(
              bucket.isEmpty ? '—' : '${bucket.count}',
              style: context.textStyles.mono.copyWith(color: colors.neutrals.ink2),
            ),
          ],
        ),
      ),
    );
  }
}
