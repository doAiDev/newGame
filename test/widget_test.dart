import 'package:flutter_test/flutter_test.dart';
import 'package:neon_drive/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const NeonDriveApp());
    expect(find.byType(NeonDriveApp), findsOneWidget);
  });
}
