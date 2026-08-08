class SessionResult {
  final String deckId;
  final int totalCards;
  final int knownCount;
  final int needsPracticeCount;
  final Duration duration;
  final DateTime timestamp;

  const SessionResult({
    required this.deckId,
    required this.totalCards,
    required this.knownCount,
    required this.needsPracticeCount,
    required this.duration,
    required this.timestamp,
  });

  double get accuracyRate => totalCards > 0 ? (knownCount / totalCards) * 100 : 0.0;
}
