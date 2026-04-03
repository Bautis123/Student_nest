import 'package:flutter_test/flutter_test.dart';
import 'package:student_nest/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const StudentNestApp());
  });
}
