import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flash_swipe/main.dart';
import 'package:flash_swipe/data/models/flashcard_model.dart';
import 'package:flash_swipe/data/repositories/deck_repository.dart';
import 'package:flash_swipe/data/repositories/local_deck_repository.dart';
import 'package:flash_swipe/viewmodels/session_viewmodel.dart';
import 'package:flash_swipe/views/widgets/flash_card_widget.dart';

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

  testWidgets('FlashCardWidget 3D flip and interruptibility test', (WidgetTester tester) async {
    // Set viewport dimensions to design spec so ScreenUtil scales correctly
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const card = FlashCard(
      id: 'test_card_1',
      question: 'What is Dart?',
      answer: 'A client-optimized language for fast apps on any platform.',
    );

    // Build the widget with ScreenUtilInit context
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) {
          return const GetMaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 400,
                  child: FlashCardWidget(flashCard: card),
                ),
              ),
            ),
          );
        },
      ),
    );

    // 1. Initial State: Front (Question) is visible
    expect(find.text('What is Dart?'), findsOneWidget);
    expect(find.text('A client-optimized language for fast apps on any platform.'), findsNothing);

    // 2. Tap to flip forward
    await tester.tap(find.byType(FlashCardWidget));
    
    // Pump a fraction of the animation (duration is 400ms, pump 100ms)
    await tester.pump(const Duration(milliseconds: 100));

    // The animation is midway (25% complete).
    // Angle = 0.25 * pi, which is < pi/2 (45 degrees), so Front side should still be active.
    expect(find.text('What is Dart?'), findsOneWidget);
    expect(find.text('A client-optimized language for fast apps on any platform.'), findsNothing);

    // 3. Interrupt: Tap again while animating to reverse the flip
    await tester.tap(find.byType(FlashCardWidget));
    
    // Let the reverse animation complete fully
    await tester.pumpAndSettle();

    // Card should have reversed back to the front side smoothly
    expect(find.text('What is Dart?'), findsOneWidget);
    expect(find.text('A client-optimized language for fast apps on any platform.'), findsNothing);

    // 4. Complete Flip: Tap and let it run to completion
    await tester.tap(find.byType(FlashCardWidget));
    await tester.pumpAndSettle();

    // Card is now flipped to the back side showing the answer
    expect(find.text('What is Dart?'), findsNothing);
    expect(find.text('A client-optimized language for fast apps on any platform.'), findsOneWidget);

    // 5. Flip back to front: Tap on the back side
    await tester.tap(find.byType(FlashCardWidget));
    await tester.pumpAndSettle();

    // Card should return to the front side question
    expect(find.text('What is Dart?'), findsOneWidget);
    expect(find.text('A client-optimized language for fast apps on any platform.'), findsNothing);
  });
}
