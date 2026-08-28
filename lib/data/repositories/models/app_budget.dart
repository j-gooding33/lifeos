import 'package:life_os/core/scheduling/civil_date.dart';

enum BudgetPeriod { monthly, weekly }

/// §22.2. `categoryId == null` means an overall budget, not per-category.
class AppBudget {
  AppBudget({
    required this.id,
    required this.userId,
    required this.amountMinor,
    required this.period,
    this.categoryId,
    this.startDate,
  });

  final String id;
  final String userId;
  final String? categoryId;
  final int amountMinor;
  final BudgetPeriod period;
  final CivilDate? startDate;

  AppBudget copyWith({int? amountMinor, BudgetPeriod? period, String? categoryId, bool clearCategory = false}) {
    return AppBudget(
      id: id,
      userId: userId,
      amountMinor: amountMinor ?? this.amountMinor,
      period: period ?? this.period,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      startDate: startDate,
    );
  }
}
