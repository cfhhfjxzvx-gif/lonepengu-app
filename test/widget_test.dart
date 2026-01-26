import 'package:flutter_test/flutter_test.dart';
import 'package:lone_pengu/main.dart';

void main() {
  testWidgets('LonePenguApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LonePenguApp());
    // Verify that landing screen loads
    expect(find.text('LonePengu'), findsAny);
  });
}
