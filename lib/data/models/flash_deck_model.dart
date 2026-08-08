import 'flashcard_model.dart';

class FlashDeck {
  final String id;
  final String name;
  final String description;
  final List<FlashCard> cards;

  const FlashDeck({
    required this.id,
    required this.name,
    required this.description,
    required this.cards,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cards': cards.map((c) => c.toJson()).toList(),
    };
  }

  factory FlashDeck.fromJson(Map<String, dynamic> json) {
    return FlashDeck(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      cards: (json['cards'] as List<dynamic>)
          .map((c) => FlashCard.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
