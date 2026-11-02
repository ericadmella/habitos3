import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habitos_app/main.dart';

void main() {
  testWidgets('opens the onboarding screen on first launch', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const HabitosApp());
    await tester.pumpAndSettle();

    expect(find.text('¡Bienvenido a HabitosApp!'), findsOneWidget);
  });
}
