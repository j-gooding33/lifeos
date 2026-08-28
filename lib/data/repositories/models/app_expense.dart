import 'package:life_os/core/scheduling/civil_date.dart';

enum ExpenseType { income, expense }

/// §22.2. `amountMinor` is always a positive magnitude; [type] carries the
/// sign in meaning, not the stored value.
class AppExpense {
  AppExpense({
    required this.id,
    required this.userId,
    required this.type,
    required this.amountMinor,
    required this.currency,
    required this.date,
    this.categoryId,
    this.note,
    this.recurrenceRule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  final String id;
  final String userId;
  final ExpenseType type;
  final int amountMinor;
  final String currency;
  final String? categoryId;
  final CivilDate date;
  final String? note;
  final String? recurrenceRule;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppExpense copyWith({
    ExpenseType? type,
    int? amountMinor,
    String? categoryId,
    bool clearCategory = false,
    CivilDate? date,
    String? note,
    bool clearNote = false,
  }) {
    return AppExpense(
      id: id,
      userId: userId,
      type: type ?? this.type,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      date: date ?? this.date,
      note: clearNote ? null : (note ?? this.note),
      recurrenceRule: recurrenceRule,
      createdAt: createdAt,
    );
  }
}
