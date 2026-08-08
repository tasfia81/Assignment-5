import '../models/flash_deck_model.dart';
import '../models/flashcard_model.dart';
import 'deck_repository.dart';

class LocalDeckRepository implements DeckRepository {
  // Bundled mock decks
  final List<FlashDeck> _decks = [
    const FlashDeck(
      id: 'flutter_dart_concepts',
      name: 'Flutter & Dart Concepts',
      description: 'Master core Flutter widget lifecycles, Dart concurrency, state management principles, and memory optimization.',
      cards: [
        FlashCard(
          id: 'fd_1',
          question: 'What is hot reload in Flutter?',
          answer: 'It injects updated source code files into the running Dart VM, allowing you to see code modifications in sub-seconds without losing the application state.',
          hint: 'Focuses on Dart VM compilation.',
        ),
        FlashCard(
          id: 'fd_2',
          question: 'What is the main difference between StatelessWidget and StatefulWidget?',
          answer: 'StatelessWidgets are immutable and build once. Statefully widgets preserve state across rebuilds using a separate State object, notifying rebuilds via setState().',
          hint: 'Think about mutability and lifecycles.',
        ),
        FlashCard(
          id: 'fd_3',
          question: 'What is a Stream in Dart?',
          answer: 'A stream is a sequence of asynchronous events. It can be listened to for incoming data (via StreamSubscription) or manipulated using stream operators.',
          hint: 'Think about asynchronous data sequences.',
        ),
        FlashCard(
          id: 'fd_4',
          question: 'How does Dart achieve concurrency despite being single-threaded?',
          answer: 'Dart uses single-threaded event loops (for microtasks and events) and "Isolates" (separate memory heaps running in parallel communicating via message passing).',
          hint: 'Think about thread isolation and messaging.',
        ),
        FlashCard(
          id: 'fd_5',
          question: 'What is the purpose of InheritedWidget in Flutter?',
          answer: 'To efficiently propagate data down the widget tree, allowing descendent widgets to obtain references and rebuild when data changes, without manual prop drilling.',
          hint: 'Used underneath Provider and scoped state tools.',
        ),
        FlashCard(
          id: 'fd_6',
          question: 'Outline the lifecycle states of a Stateful Widget State object in order.',
          answer: 'createState -> initState -> didChangeDependencies -> build -> didUpdateWidget -> deactivate -> dispose.',
          hint: 'Remember the entry, update, and exit phases.',
        ),
        FlashCard(
          id: 'fd_7',
          question: 'How do you declare a library-private property or class in Dart?',
          answer: 'Prefix its name with an underscore (e.g. _myPrivateProperty). Dart does not have public/private keywords; privacy is scoping-based per library.',
          hint: 'Requires a special character prefix.',
        ),
        FlashCard(
          id: 'fd_8',
          question: 'What is the purpose of Key in Flutter widgets?',
          answer: 'To uniquely identify widgets in the widget tree, allowing the framework to preserve state and match elements when the widget tree structural changes.',
          hint: 'Crucial for item reordering in collections.',
        ),
        FlashCard(
          id: 'fd_9',
          question: 'What is the difference between Future.wait and Future.any?',
          answer: 'Future.wait waits for all futures in a list to complete and returns their combined results. Future.any returns the result of the first future to complete.',
          hint: 'Think about parallel wait vs first-completion.',
        ),
        FlashCard(
          id: 'fd_10',
          question: 'What is a Mixin in Dart?',
          answer: 'A way of reusing a class\'s code in multiple class hierarchies without using standard multiple inheritance, declared with the "mixin" keyword and applied using "with".',
          hint: 'Enables code reuse across unrelated classes.',
        ),
      ],
    ),
    const FlashDeck(
      id: 'mobile_ui_ux_principles',
      name: 'Mobile UI/UX Principles',
      description: 'Explore thumb zones, animations, target dimensions, layout density, and physics-based simulations.',
      cards: [
        FlashCard(
          id: 'ui_1',
          question: 'What is the recommended touch target size for mobile UI controls?',
          answer: 'At least 48x48 logical pixels (approx. 9mm x 9mm) to prevent accidental mis-taps and ensure accessibility for all users.',
          hint: 'Material Design standard size.',
        ),
        FlashCard(
          id: 'ui_2',
          question: 'Explain the "Thumb Zone" rule in mobile design.',
          answer: 'Placing critical interactive elements (like navigation, primary actions) in the easily reachable lower two-thirds of the screen where a user\'s thumb natural moves.',
          hint: 'Ergonomic optimization for one-handed use.',
        ),
        FlashCard(
          id: 'ui_3',
          question: 'What is Fitts\'s Law?',
          answer: 'A predictive model stating that the time required to move to a target is a function of the target\'s distance and its size (closer, larger targets are faster to hit).',
          hint: 'Relates target acquisition time to size and distance.',
        ),
        FlashCard(
          id: 'ui_4',
          question: 'What is skeleton loading and why is it used?',
          answer: 'Displaying gray/empty placeholder shapes matching the content structure during load states. It reduces perceived waiting time compared to progress spinners.',
          hint: 'Perceived performance optimization.',
        ),
        FlashCard(
          id: 'ui_5',
          question: 'What is the purpose of SpringSimulation in animations?',
          answer: 'To simulate natural physical movement (mass, stiffness, damping) rather than rigid linear/easing curves, making gestures feel tactile and responsive.',
          hint: 'Brings physical rules to app UI.',
        ),
        FlashCard(
          id: 'ui_6',
          question: 'How does high screen density affect design measurements?',
          answer: 'It increases the physical pixels per inch. Flutter solves this by using density-independent logical pixels that automatically scale to maintain size.',
          hint: 'Think about physical vs logical pixels.',
        ),
        FlashCard(
          id: 'ui_7',
          question: 'Why is micro-interaction feedback important?',
          answer: 'It confirms that the system has registered a user action (like a button hover or card flip), enhancing clarity, delight, and the feel of quality.',
          hint: 'Tiny visual or haptic feedback responses.',
        ),
        FlashCard(
          id: 'ui_8',
          question: 'Define the concept of Visual Hierarchy.',
          answer: 'Arranging UI elements in order of relative importance, guiding the user\'s eye sequence using contrast in size, color, weight, and whitespace.',
          hint: 'Guides user attention sequence.',
        ),
      ],
    ),
  ];

  @override
  Future<List<FlashDeck>> getDecks() async {
    // Simulate minor network/loading lag for production feel
    await Future.delayed(const Duration(milliseconds: 300));
    return _decks;
  }

  @override
  Future<FlashDeck?> getDeckById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _decks.firstWhere((deck) => deck.id == id);
    } catch (_) {
      return null;
    }
  }
}
