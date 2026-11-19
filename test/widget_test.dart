import 'package:flutter_test/flutter_test.dart';
import 'package:air_quality_app/app.dart';

void main() {
  testWidgets('AirQualityApp builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AirQualityApp());
    expect(find.byType(AirQualityApp), findsOneWidget);
  });
}
