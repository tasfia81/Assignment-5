import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flash_swipe/views/widgets/swipeable_card.dart';

void main() {
  testWidgets('SwipeableCard drag and commit right test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    bool swipedLeft = false;
    bool swipedRight = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) {
          return MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                onSwipeLeft: () => swipedLeft = true,
                onSwipeRight: () => swipedRight = true,
                child: const SizedBox(width: 200, height: 300, child: Text('Card Content')),
              ),
            ),
          );
        },
      ),
    );

    // Verify card content is visible
    expect(find.text('Card Content'), findsOneWidget);

    // Drag the card to the right past the 35% threshold (390 * 0.35 = 136.5 pixels)
    // We drag by 200 pixels to the right
    await tester.drag(find.text('Card Content'), const Offset(200, 0));
    await tester.pumpAndSettle();

    // Verify callback was triggered
    expect(swipedRight, isTrue);
    expect(swipedLeft, isFalse);
  });

  testWidgets('SwipeableCard drag and spring back test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    bool swipedLeft = false;
    bool swipedRight = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) {
          return MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                onSwipeLeft: () => swipedLeft = true,
                onSwipeRight: () => swipedRight = true,
                child: const SizedBox(width: 200, height: 300, child: Text('Card Content')),
              ),
            ),
          );
        },
      ),
    );

    // Drag the card to the right but below the threshold (e.g. 50 pixels)
    await tester.drag(find.text('Card Content'), const Offset(50, 0));
    await tester.pump();

    // Verify callbacks are not triggered yet
    expect(swipedRight, isFalse);
    expect(swipedLeft, isFalse);

    // Let the spring-back animation finish
    await tester.pumpAndSettle();

    // Still not triggered
    expect(swipedRight, isFalse);
    expect(swipedLeft, isFalse);
  });

  testWidgets('SwipeableCard flick/velocity-based commit test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    bool swipedLeft = false;
    bool swipedRight = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) {
          return MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                onSwipeLeft: () => swipedLeft = true,
                onSwipeRight: () => swipedRight = true,
                child: const SizedBox(width: 200, height: 300, child: Text('Card Content')),
              ),
            ),
          );
        },
      ),
    );

    // Fling/flick to the left (negative offset, high velocity)
    // We drag a short distance but fast
    await tester.fling(find.text('Card Content'), const Offset(-60, 0), 1000.0);
    await tester.pumpAndSettle();

    // Verify callback was triggered on velocity-based swipe
    expect(swipedLeft, isTrue);
    expect(swipedRight, isFalse);
  });
}
