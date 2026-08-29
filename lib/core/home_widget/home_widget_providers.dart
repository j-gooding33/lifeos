import 'package:life_os/core/home_widget/home_widget_service.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_widget_providers.g.dart';

@Riverpod(keepAlive: true)
HomeWidgetService homeWidgetService(Ref ref) {
  return HomeWidgetService(ref.watch(appDatabaseProvider));
}
