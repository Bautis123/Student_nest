import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:student_nest/main.dart';

void main() {
  test('App smoke test', () {
    final app = const StudentNestApp();
    expect(app, isA<Widget>());
  });
}
