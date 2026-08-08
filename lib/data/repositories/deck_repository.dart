import '../models/flash_deck_model.dart';

abstract class DeckRepository {
  Future<List<FlashDeck>> getDecks();
  Future<FlashDeck?> getDeckById(String id);
}
