import 'package:flutter_test/flutter_test.dart';
import 'package:newstamil_app/main.dart';

void main() {
  testWidgets('NewsTamilApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NewsTamilApp(initialDarkMode: false));
  });
}
