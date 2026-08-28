// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(financeRepository)
const financeRepositoryProvider = FinanceRepositoryProvider._();

final class FinanceRepositoryProvider
    extends
        $FunctionalProvider<
          FinanceRepository,
          FinanceRepository,
          FinanceRepository
        >
    with $Provider<FinanceRepository> {
  const FinanceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'financeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$financeRepositoryHash();

  @$internal
  @override
  $ProviderElement<FinanceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FinanceRepository create(Ref ref) {
    return financeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FinanceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FinanceRepository>(value),
    );
  }
}

String _$financeRepositoryHash() => r'ceef8c7ca9607c4b9cb09f0ea0bfe1b17d0e2702';

@ProviderFor(allExpenses)
const allExpensesProvider = AllExpensesProvider._();

final class AllExpensesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppExpense>>,
          List<AppExpense>,
          Stream<List<AppExpense>>
        >
    with $FutureModifier<List<AppExpense>>, $StreamProvider<List<AppExpense>> {
  const AllExpensesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allExpensesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allExpensesHash();

  @$internal
  @override
  $StreamProviderElement<List<AppExpense>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppExpense>> create(Ref ref) {
    return allExpenses(ref);
  }
}

String _$allExpensesHash() => r'69be93be2b4c30e88d1f7be4e6f98cba7c9df085';

@ProviderFor(expenseById)
const expenseByIdProvider = ExpenseByIdFamily._();

final class ExpenseByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppExpense?>,
          AppExpense?,
          Stream<AppExpense?>
        >
    with $FutureModifier<AppExpense?>, $StreamProvider<AppExpense?> {
  const ExpenseByIdProvider._({
    required ExpenseByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'expenseByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$expenseByIdHash();

  @override
  String toString() {
    return r'expenseByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<AppExpense?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppExpense?> create(Ref ref) {
    final argument = this.argument as String;
    return expenseById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpenseByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$expenseByIdHash() => r'83bfe26eadead64d5c052347123dfb4b69a2c6d8';

final class ExpenseByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AppExpense?>, String> {
  const ExpenseByIdFamily._()
    : super(
        retry: null,
        name: r'expenseByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExpenseByIdProvider call(String expenseId) =>
      ExpenseByIdProvider._(argument: expenseId, from: this);

  @override
  String toString() => r'expenseByIdProvider';
}

/// §22.2's single onboarding-chosen currency (`AppProfile.currency`,
/// default `'GBP'`) — Finance reads it rather than storing its own copy.

@ProviderFor(currentCurrency)
const currentCurrencyProvider = CurrentCurrencyProvider._();

/// §22.2's single onboarding-chosen currency (`AppProfile.currency`,
/// default `'GBP'`) — Finance reads it rather than storing its own copy.

final class CurrentCurrencyProvider
    extends $FunctionalProvider<AsyncValue<String>, String, Stream<String>>
    with $FutureModifier<String>, $StreamProvider<String> {
  /// §22.2's single onboarding-chosen currency (`AppProfile.currency`,
  /// default `'GBP'`) — Finance reads it rather than storing its own copy.
  const CurrentCurrencyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentCurrencyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentCurrencyHash();

  @$internal
  @override
  $StreamProviderElement<String> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String> create(Ref ref) {
    return currentCurrency(ref);
  }
}

String _$currentCurrencyHash() => r'b17f1d01e5d81d2bb41885e7ff86b772ce694a26';

@ProviderFor(allBudgets)
const allBudgetsProvider = AllBudgetsProvider._();

final class AllBudgetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppBudget>>,
          List<AppBudget>,
          Stream<List<AppBudget>>
        >
    with $FutureModifier<List<AppBudget>>, $StreamProvider<List<AppBudget>> {
  const AllBudgetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allBudgetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allBudgetsHash();

  @$internal
  @override
  $StreamProviderElement<List<AppBudget>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppBudget>> create(Ref ref) {
    return allBudgets(ref);
  }
}

String _$allBudgetsHash() => r'1691cf8c1d06a050124aed1f12caa148f40284e0';

@ProviderFor(expenseCategories)
const expenseCategoriesProvider = ExpenseCategoriesProvider._();

final class ExpenseCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppCategory>>,
          List<AppCategory>,
          Stream<List<AppCategory>>
        >
    with
        $FutureModifier<List<AppCategory>>,
        $StreamProvider<List<AppCategory>> {
  const ExpenseCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseCategoriesHash();

  @$internal
  @override
  $StreamProviderElement<List<AppCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppCategory>> create(Ref ref) {
    return expenseCategories(ref);
  }
}

String _$expenseCategoriesHash() => r'a108aeacae088ced71886d5938409a25a092f0f7';
