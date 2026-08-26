import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/app.dart';
import 'package:life_os/core/config/flavor.dart';

void main() {
  setUp(() => AppConfig.initialize(Flavor.dev));

  testWidgets(
    'shows an honest not-built-yet placeholder, no fake UI',
    (tester) async {
      await tester.pumpWidget(const LifeOsApp());

      expect(find.text('Life OS Dev'), findsOneWidget);
      expect(find.textContaining('Nothing is built yet'), findsOneWidget);
    },
  );
}
