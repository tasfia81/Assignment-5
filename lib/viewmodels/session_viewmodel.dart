import 'dart:async';
import 'package:get/get.dart';
import '../data/models/flash_deck_model.dart';
import '../data/models/flashcard_model.dart';
import '../data/models/session_result_model.dart';

class SessionViewModel extends GetxController {
  final Rxn<FlashDeck> currentDeck = Rxn<FlashDeck>();
  final RxList<FlashCard> activeCards = <FlashCard>[].obs;
  final RxInt currentCardIndex = 0.obs;
  final RxList<FlashCard> knownCards = <FlashCard>[].obs;
  final RxList<FlashCard> needsPracticeCards = <FlashCard>[].obs;
  final RxBool isSessionFinished = false.obs;

  
  // Timing
  late DateTime _startTime;
  final Rx<Duration> elapsedDuration = Duration.zero.obs;
  Timer? _timer;

  @override
  void onClose() {
    _stopTimer();
    super.onClose();
  }

  FlashCard? get currentCard {
    if (activeCards.isEmpty || currentCardIndex.value >= activeCards.length) {
      return null;
    }
    return activeCards[currentCardIndex.value];
  }

  double get progress {
    if (activeCards.isEmpty) return 0.0;
    return currentCardIndex.value / activeCards.length;
  }

  int get totalCardsCount => activeCards.length;

  void startSession(FlashDeck deck, {List<FlashCard>? customCards}) {
    currentDeck.value = deck;
    // If customCards is provided, we run session with those specific cards (e.g. needs practice)
    activeCards.assignAll(customCards ?? List.from(deck.cards)..shuffle()); // shuffle for random practice feel
    currentCardIndex.value = 0;
    knownCards.clear();
    needsPracticeCards.clear();
    isSessionFinished.value = false;
    
    // Start timing
    _startTime = DateTime.now();
    elapsedDuration.value = Duration.zero;
    _startTimer();
  }


  void markAsKnown() {
    final card = currentCard;
    if (card != null) {
      knownCards.add(card);
      _nextCard();
    }
  }

  void markAsNeedsPractice() {
    final card = currentCard;
    if (card != null) {
      needsPracticeCards.add(card);
      _nextCard();
    }
  }

  void _nextCard() {
    if (currentCardIndex.value < activeCards.length - 1) {
      currentCardIndex.value++;
    } else {
      currentCardIndex.value++; // Go to past-end index
      _finishSession();
    }
  }

  void _finishSession() {
    _stopTimer();
    isSessionFinished.value = true;
  }

  void restartFullDeck() {
    if (currentDeck.value != null) {
      startSession(currentDeck.value!);
    }
  }

  void restartNeedsPracticeDeck() {
    if (currentDeck.value != null && needsPracticeCards.isNotEmpty) {
      final List<FlashCard> weakCards = List.from(needsPracticeCards);
      startSession(currentDeck.value!, customCards: weakCards);
    }
  }

  SessionResult? getSessionResult() {
    if (currentDeck.value == null) return null;
    return SessionResult(
      deckId: currentDeck.value!.id,
      totalCards: activeCards.length,
      knownCount: knownCards.length,
      needsPracticeCount: needsPracticeCards.length,
      duration: elapsedDuration.value,
      timestamp: DateTime.now(),
    );
  }

  // Timer helpers
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedDuration.value = DateTime.now().difference(_startTime);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
