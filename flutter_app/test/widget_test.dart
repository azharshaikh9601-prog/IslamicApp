import 'package:flutter_test/flutter_test.dart';
import 'package:hafiz_hasnain_app/main.dart';

void main() {
  testWidgets('Islamic App initial smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HafizHasnainApp());
    expect(find.byType(HafizHasnainApp), findsOneWidget);
  });
}
