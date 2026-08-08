import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flash_swipe/main.dart';
import 'package:flash_swipe/data/repositories/deck_repository.dart';
import 'package:flash_swipe/data/repositories/local_deck_repository.dart';
import 'package:flash_swipe/viewmodels/session_viewmodel.dart';

void main() {
  setUp(() {
    // Register dependencies for the widget test context
    Get.put<DeckRepository>(LocalDeckRepository());
    Get.put(SessionViewModel());
  });

  tearDown(() {
    // Clear GetX state after each test
    Get.reset();
  });

  testWidgets('FlashSwipe home screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlashSwipeApp());
    
    // Pump frames to let future builder resolve and settle UI
    await tester.pumpAndSettle();

    // Verify that our app starts on the home screen with title FlashSwipe.
    expect(find.text('FlashSwipe'), findsOneWidget);
  });
}
