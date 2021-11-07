import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_rooms/app/app.dart';
import 'package:meeting_rooms/app/view/app_page.dart';

void main() {
  group('App', () {
    testWidgets('renders AppPage', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(AppPage), findsOneWidget);
    });
  });
}
