import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/utils/money_format.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_progress_bar.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/home/application/home_providers.dart';
import 'package:life_os/routing/routes.dart';

/// §5.3's `spending` — month to date vs the overall budget, if one exists.
class SpendingCard extends StatelessWidget {
  const SpendingCard({required this.snapshot, super.key});

  final HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final budget = snapshot.monthlyBudgetMinor;

    return LCard(
      onTap: () => context.push(Routes.finance),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LSectionHeader(title: 'Spending'),
          const SizedBox(height: LifeSpace.s8),
          Text(
            budget == null
                ? '${formatMoney(snapshot.spentThisMonthMinor, snapshot.currency)} this month'
                : '${formatMoney(snapshot.spentThisMonthMinor, snapshot.currency)} of ${formatMoney(budget, snapshot.currency)}',
            style: context.textStyles.bodyStrong.copyWith(color: colors.neutrals.ink),
          ),
          if (budget != null) ...[
            const SizedBox(height: LifeSpace.s4),
            LProgressBar(value: budget == 0 ? 0 : snapshot.spentThisMonthMinor / budget, semanticLabel: 'Monthly budget'),
          ],
        ],
      ),
    );
  }
}
