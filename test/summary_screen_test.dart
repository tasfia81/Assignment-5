import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flash_swipe/data/models/flash_deck_model.dart';
import 'package:flash_swipe/data/models/flashcard_model.dart';
import 'package:flash_swipe/data/repositories/deck_repository.dart';
import 'package:flash_swipe/data/repositories/local_deck_repository.dart';
import 'package:flash_swipe/viewmodels/session_viewmodel.dart';
import 'package:flash_swipe/views/screens/summary_screen.dart';

void main() {
  setUp(() {
    Get.put<DeckRepository>(LocalDeckRepository());
    Get.put(SessionViewModel());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('SummaryScreen shows correct statistics and mastered state when zero needs practice', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final SessionViewModel sessionVM = Get.find<SessionViewModel>();
    
    const deck = FlashDeck(
      id: 'test_deck',
      name: 'Test Deck',
      description: 'Test Description',
      cards: [
        FlashCard(id: 'c1', question: 'Q1', answer: 'A1'),
        FlashCard(id: 'c2', question: 'Q2', answer: 'A2'),
      ],
    );

    // Simulate session finished with 100% accuracy (2 known, 0 needs practice)
    sessionVM.currentDeck.value = deck;
    sessionVM.activeCards.assignAll(deck.cards);
    sessionVM.knownCards.assignAll(deck.cards);
    sessionVM.needsPracticeCards.clear();
    sessionVM.isSessionFinished.value = true;
    sessionVM.currentCardIndex.value = 2;
    sessionVM.elapsedDuration.value = const Duration(seconds: 45);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) {
          return const GetMaterialApp(
            home: SummaryScreen(),
          );
        },
      ),
    );

    // Verify statistics render correctly
    expect(find.text('Deck Mastered!'), findsOneWidget);
    expect(find.text('Accuracy'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('00:45'), findsOneWidget);
    expect(find.text('2 Known'), findsOneWidget);
    expect(find.text('0 Needs Practice'), findsOneWidget);

    // Verify "Mastered! No weak cards to practice." text is present
    expect(find.text('Mastered! No weak cards to practice.'), findsOneWidget);
    // Verify "Practice Weak Cards" button is NOT rendered
    expect(find.textContaining('Practice Weak Cards'), findsNothing);
    // Verify "Restart Full Deck" button is present
    expect(find.text('Restart Full Deck'), findsOneWidget);
  });

  testWidgets('SummaryScreen shows weak cards restart option when needs practice count > 0', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final SessionViewModel sessionVM = Get.find<SessionViewModel>();
    
    const deck = FlashDeck(
      id: 'test_deck',
      name: 'Test Deck',
      description: 'Test Description',
      cards: [
        FlashCard(id: 'c1', question: 'Q1', answer: 'A1'),
        FlashCard(id: 'c2', question: 'Q2', answer: 'A2'),
      ],
    );

    // Simulate session finished with 50% accuracy (1 known, 1 needs practice)
    sessionVM.currentDeck.value = deck;
    sessionVM.activeCards.assignAll(deck.cards);
    sessionVM.knownCards.add(deck.cards[0]);
    sessionVM.needsPracticeCards.add(deck.cards[1]);
    sessionVM.isSessionFinished.value = true;
    sessionVM.currentCardIndex.value = 2;
    sessionVM.elapsedDuration.value = const Duration(seconds: 30);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) {
          return const GetMaterialApp(
            home: SummaryScreen(),
          );
        },
      ),
    );

    expect(find.text('Session Finished!'), findsOneWidget);
    expect(find.text('Accuracy'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('00:30'), findsOneWidget);
    expect(find.text('1 Known'), findsOneWidget);
    expect(find.text('1 Needs Practice'), findsOneWidget);

    // Verify "Practice Weak Cards (1)" button is rendered
    expect(find.text('Practice Weak Cards (1)'), findsOneWidget);
  });
}
