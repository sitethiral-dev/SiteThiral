import 'package:flutter_test/flutter_test.dart';
import 'package:sitethiral/main.dart';

void main() {
  testWidgets('SiteThiral app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SiteThiralApp());
  });
}