import 'package:flutter_test/flutter_test.dart';

import 'package:coorporate_gig/main.dart';

void main() {
  testWidgets('App launches to role selection', (WidgetTester tester) async {
    await tester.pumpWidget(const CoorporateGigApp());
    await tester.pumpAndSettle();

    expect(find.text('Coorporate Gig'), findsOneWidget);
    expect(find.text('Client'), findsOneWidget);
    expect(find.text('Worker'), findsOneWidget);
    expect(
      find.text('Cooperative Admin', skipOffstage: false),
      findsOneWidget,
    );
  });
}
