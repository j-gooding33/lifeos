// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(taskRepository)
const taskRepositoryProvider = TaskRepositoryProvider._();

final class TaskRepositoryProvider
    extends $FunctionalProvider<TaskRepository, TaskRepository, TaskRepository>
    with $Provider<TaskRepository> {
  const TaskRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskRepositoryHash();

  @$internal
  @override
  $ProviderElement<TaskRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TaskRepository create(Ref ref) {
    return taskRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskRepository>(value),
    );
  }
}

String _$taskRepositoryHash() => r'37114585b2f0fb2ca769606e15bcfc3957221ee7';

@ProviderFor(todayTasks)
const todayTasksProvider = TodayTasksProvider._();

final class TodayTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppTask>>,
          List<AppTask>,
          Stream<List<AppTask>>
        >
    with $FutureModifier<List<AppTask>>, $StreamProvider<List<AppTask>> {
  const TodayTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayTasksHash();

  @$internal
  @override
  $StreamProviderElement<List<AppTask>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppTask>> create(Ref ref) {
    return todayTasks(ref);
  }
}

String _$todayTasksHash() => r'0a45cf0dbb768c2a16ac04ac3eb8500317c06d50';

@ProviderFor(overdueTasks)
const overdueTasksProvider = OverdueTasksProvider._();

final class OverdueTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppTask>>,
          List<AppTask>,
          Stream<List<AppTask>>
        >
    with $FutureModifier<List<AppTask>>, $StreamProvider<List<AppTask>> {
  const OverdueTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'overdueTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$overdueTasksHash();

  @$internal
  @override
  $StreamProviderElement<List<AppTask>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppTask>> create(Ref ref) {
    return overdueTasks(ref);
  }
}

String _$overdueTasksHash() => r'93d45eb4cc647b32f5222334bd5ab95e101e7111';

@ProviderFor(upcomingTasks)
const upcomingTasksProvider = UpcomingTasksProvider._();

final class UpcomingTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppTask>>,
          List<AppTask>,
          Stream<List<AppTask>>
        >
    with $FutureModifier<List<AppTask>>, $StreamProvider<List<AppTask>> {
  const UpcomingTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingTasksHash();

  @$internal
  @override
  $StreamProviderElement<List<AppTask>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppTask>> create(Ref ref) {
    return upcomingTasks(ref);
  }
}

String _$upcomingTasksHash() => r'47363686a99c16a034506e65039deed754db4efb';

@ProviderFor(somedayTasks)
const somedayTasksProvider = SomedayTasksProvider._();

final class SomedayTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppTask>>,
          List<AppTask>,
          Stream<List<AppTask>>
        >
    with $FutureModifier<List<AppTask>>, $StreamProvider<List<AppTask>> {
  const SomedayTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'somedayTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$somedayTasksHash();

  @$internal
  @override
  $StreamProviderElement<List<AppTask>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppTask>> create(Ref ref) {
    return somedayTasks(ref);
  }
}

String _$somedayTasksHash() => r'631e113c0d487ff4aaf1943b6a0de7f7d627b210';

@ProviderFor(completedTasks)
const completedTasksProvider = CompletedTasksProvider._();

final class CompletedTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppTask>>,
          List<AppTask>,
          Stream<List<AppTask>>
        >
    with $FutureModifier<List<AppTask>>, $StreamProvider<List<AppTask>> {
  const CompletedTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completedTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completedTasksHash();

  @$internal
  @override
  $StreamProviderElement<List<AppTask>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppTask>> create(Ref ref) {
    return completedTasks(ref);
  }
}

String _$completedTasksHash() => r'6c08877f465c6c1b5a2433b642bb8871654baa8b';

@ProviderFor(allTasksDueToday)
const allTasksDueTodayProvider = AllTasksDueTodayProvider._();

final class AllTasksDueTodayProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppTask>>,
          List<AppTask>,
          Stream<List<AppTask>>
        >
    with $FutureModifier<List<AppTask>>, $StreamProvider<List<AppTask>> {
  const AllTasksDueTodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allTasksDueTodayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allTasksDueTodayHash();

  @$internal
  @override
  $StreamProviderElement<List<AppTask>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppTask>> create(Ref ref) {
    return allTasksDueToday(ref);
  }
}

String _$allTasksDueTodayHash() => r'a1961a4cdceb761fd5cad60f7fcd7fb8746006c9';

/// §14.5: one range query per visible calendar period.

@ProviderFor(tasksDueInRange)
const tasksDueInRangeProvider = TasksDueInRangeFamily._();

/// §14.5: one range query per visible calendar period.

final class TasksDueInRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppTask>>,
          List<AppTask>,
          Stream<List<AppTask>>
        >
    with $FutureModifier<List<AppTask>>, $StreamProvider<List<AppTask>> {
  /// §14.5: one range query per visible calendar period.
  const TasksDueInRangeProvider._({
    required TasksDueInRangeFamily super.from,
    required (CivilDate, CivilDate) super.argument,
  }) : super(
         retry: null,
         name: r'tasksDueInRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tasksDueInRangeHash();

  @override
  String toString() {
    return r'tasksDueInRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<AppTask>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppTask>> create(Ref ref) {
    final argument = this.argument as (CivilDate, CivilDate);
    return tasksDueInRange(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is TasksDueInRangeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tasksDueInRangeHash() => r'83dc0f9b63b01f4da642b2699f9258fa381b86fa';

/// §14.5: one range query per visible calendar period.

final class TasksDueInRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<AppTask>>,
          (CivilDate, CivilDate)
        > {
  const TasksDueInRangeFamily._()
    : super(
        retry: null,
        name: r'tasksDueInRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// §14.5: one range query per visible calendar period.

  TasksDueInRangeProvider call(CivilDate from, CivilDate through) =>
      TasksDueInRangeProvider._(argument: (from, through), from: this);

  @override
  String toString() => r'tasksDueInRangeProvider';
}

@ProviderFor(recentlyCreatedTasks)
const recentlyCreatedTasksProvider = RecentlyCreatedTasksProvider._();

final class RecentlyCreatedTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppTask>>,
          List<AppTask>,
          Stream<List<AppTask>>
        >
    with $FutureModifier<List<AppTask>>, $StreamProvider<List<AppTask>> {
  const RecentlyCreatedTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentlyCreatedTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentlyCreatedTasksHash();

  @$internal
  @override
  $StreamProviderElement<List<AppTask>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppTask>> create(Ref ref) {
    return recentlyCreatedTasks(ref);
  }
}

String _$recentlyCreatedTasksHash() =>
    r'1b2920148f326356df2621c292ad05fd9d196956';

@ProviderFor(taskById)
const taskByIdProvider = TaskByIdFamily._();

final class TaskByIdProvider
    extends
        $FunctionalProvider<AsyncValue<AppTask?>, AppTask?, Stream<AppTask?>>
    with $FutureModifier<AppTask?>, $StreamProvider<AppTask?> {
  const TaskByIdProvider._({
    required TaskByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taskByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskByIdHash();

  @override
  String toString() {
    return r'taskByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<AppTask?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AppTask?> create(Ref ref) {
    final argument = this.argument as String;
    return taskById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskByIdHash() => r'18def05d992be500e3f1f63d36e27a5fd5007d04';

final class TaskByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AppTask?>, String> {
  const TaskByIdFamily._()
    : super(
        retry: null,
        name: r'taskByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TaskByIdProvider call(String taskId) =>
      TaskByIdProvider._(argument: taskId, from: this);

  @override
  String toString() => r'taskByIdProvider';
}

@ProviderFor(subtasksOf)
const subtasksOfProvider = SubtasksOfFamily._();

final class SubtasksOfProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppSubtask>>,
          List<AppSubtask>,
          Stream<List<AppSubtask>>
        >
    with $FutureModifier<List<AppSubtask>>, $StreamProvider<List<AppSubtask>> {
  const SubtasksOfProvider._({
    required SubtasksOfFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'subtasksOfProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$subtasksOfHash();

  @override
  String toString() {
    return r'subtasksOfProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<AppSubtask>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppSubtask>> create(Ref ref) {
    final argument = this.argument as String;
    return subtasksOf(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SubtasksOfProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$subtasksOfHash() => r'b1be88e9e0b807376a941d424bdfd6c8d13bbfaf';

final class SubtasksOfFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<AppSubtask>>, String> {
  const SubtasksOfFamily._()
    : super(
        retry: null,
        name: r'subtasksOfProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SubtasksOfProvider call(String taskId) =>
      SubtasksOfProvider._(argument: taskId, from: this);

  @override
  String toString() => r'subtasksOfProvider';
}
