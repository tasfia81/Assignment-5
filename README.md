# FlashSwipe

## Overview
FlashSwipe is a high-fidelity, premium flashcard study application built with Flutter. The app is engineered as a showcase for advanced mobile gesture and physics-based animation engineering, featuring 3D double-sided card flipping, natural 1:1 finger-tracking, spring simulations, haptic feedback, and a dynamic 3D-like stacked deck interface.

This project was developed for the **Khizex Mobile/App Engineering Internship — Summer 2026 (Week 6 Build Challenge)**.

---

## Features
- **Real 3D Card Flip**: Card faces transition through a 180-degree Y-axis rotation with realistic camera perspective depth.
- **Interruptible Mid-Animation Flip**: Tapping the card mid-flip reverses the rotation smoothly from its current position.
- **1:1 Finger Tracking**: The top card follows the user's touch location in 2D space horizontally and vertically with zero lag.
- **Velocity-Aware Swipe Commits**: Swipes commit based on horizontal distance threshold OR quick horizontal velocity (flicks).
- **Underdamped Spring Snap-back**: Failed swipes bounce back to the exact center using genuine spring physics.
- **Velocity-Respecting Fly-away**: Committed swipes fly off-screen at speed proportional to the user's release velocity.
- **Interactive Card Stack**: Multiple cards stack under the top card, progressively scaling and shifting up as the top card is dragged.
- **Session Tracking**: Tracks known vs needs-practice states using stable card IDs to prevent index errors.
- **End-of-Deck Summary**: Transition to a dedicated summary screen displaying accurate session stats and timing.
- **Resilient Restart Flow**: Instantly restart either the full deck or practice only the cards marked "Needs Practice".
- **Mastered State Safeguard**: Replaces the weak-cards restart with a mastery state when no needs-practice cards remain.
- **Tactile Haptic Feedback**: Click triggers on 3D flips and on crossing the swipe commit threshold.
- **Responsive Layout**: Uses ScreenUtil scaling and SafeArea borders to look premium in portrait and landscape on all screen sizes.

---

## Architecture
FlashSwipe follows a strict **MVVM (Model-View-ViewModel)** architectural pattern to separate UI representation, layout transitions, and core business state:

- **Model Layer (`lib/data/models`)**: Defines structure for `FlashCard`, `FlashDeck`, and `SessionResult` data.
- **Repository Layer (`lib/data/repositories`)**: Isolates data fetching logic (e.g. `LocalDeckRepository`).
- **ViewModel Layer (`lib/viewmodels`)**: Owns the session state (card lists, current indices, timer, progress counters). Written as a clean GetX `GetxController` singleton completely decoupled from layout widgets.
- **View Layer (`lib/views`)**: Contains stateless and stateful screens (`HomeScreen`, `SessionScreen`, `SummaryScreen`) and widgets.
- **Custom Widgets (`lib/views/widgets`)**: Implements physics gesture bindings (`SwipeableCard`), 3D transitions (`FlashCardWidget`), and progress visualizers (`CustomProgressBar`).

---

## Folder Structure
```
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart         # Premium neon styling colors
│   └── theme/
│       └── app_theme.dart          # Responsive app text styles and theme
├── data/
│   ├── models/
│   │   ├── flash_deck_model.dart
│   │   ├── flashcard_model.dart
│   │   └── session_result_model.dart
│   └── repositories/
│       ├── deck_repository.dart
│       └── local_deck_repository.dart # Hardcoded mock study decks
├── routes/
│   └── app_routes.dart             # GetX screen transition configuration
├── viewmodels/
│   └── session_viewmodel.dart      # Business logic, timer, session progress
└── views/
    ├── screens/
    │   ├── home_screen.dart        # Deck selector home dashboard
    │   ├── session_screen.dart     # Card stack session interface
    │   └── summary_screen.dart     # Post-session dashboard
    └── widgets/
        ├── custom_progress_bar.dart# Segmented progress indicator
        ├── flash_card_widget.dart  # 3D flippable card renderer
        ├── glass_container.dart    # Custom glassmorphism container
        └── swipeable_card.dart     # Physics-based gesture swipe engine
```

---

## Gesture Handling Approach
1. **Interactive Tracking (1:1)**:
   - Evaluated inside the state of `SwipeableCard` using a `GestureDetector` bound to `onPanStart`, `onPanUpdate`, and `onPanEnd`.
   - On drag update, horizontal (`x`) and vertical (`y`) offsets are directly incremented 1:1 on unbounded `AnimationController`s (`_xController` and `_yController`), preventing expensive rebuilds of parent widgets.
2. **Proportional Rotation**:
   - The card's rotation angle (in radians) is calculated dynamically based on horizontal translation:
     $$\text{rotation} = \frac{\text{xOffset}}{\text{screenWidth} \times 10}$$
3. **Commit Decision**:
   - Evaluated on finger release (`onPanEnd`):
     - **Distance Condition**: Swiped distance exceeds $35\%$ of screen width.
     - **Velocity Condition**: Release horizontal velocity exceeds $800.0\text{ px/sec}$ in the direction of the drag.
     - A swipe commits if **either** condition is met, enabling natural flicks.

---

## Physics Configuration
All animations in `SwipeableCard` use Flutter's native `SpringSimulation` to model real-world physical forces rather than fixed-duration tweens:

### 1. Spring-back (Uncommitted)
Bounces the card back to the exact center $(0, 0)$ when released under the threshold:
- **Mass ($m$)**: `1.0`
- **Stiffness ($k$)**: `180.0`
- **Damping ratio ($\zeta$)**: `15.0`
- *Reasoning*: A stiffness of `180.0` produces a snappy return. A damping ratio of `15.0` is underdamped relative to critical damping ($2\sqrt{mk} \approx 26.8$), providing a bouncy, natural physical settling animation.

### 2. Fly-away (Committed)
Launches the card off-screen when committed:
- **Mass ($m$)**: `1.0`
- **Stiffness ($k$)**: `150.0`
- **Damping ratio ($\zeta$)**: `20.0`
- *Reasoning*: A slightly lower stiffness and higher damping ensures the card exits smoothly without oscillating back onto the screen.
- *Velocity Handoff*: The simulation is initialized with the user's actual release velocity (`vx`), ensuring a harder flick produces a faster, continuous exit animation.

---

## Card Flip Implementation
The 3D card flip is localized inside `FlashCardWidget` and implemented using a single `AnimationController` (running a `easeInOut` curve over $400\text{ms}$):
- **Perspective Matrix**:
  ```dart
  final transform = Matrix4.identity()
    ..setEntry(3, 2, 0.0015) // Perspective factor (depth perception)
    ..rotateY(angle);
  ```
- **Flicker & Mirroring Resolution**:
  - The card face switch occurs exactly at $90^\circ$ ($\pi/2$ radians) where the card is edge-on to the camera and invisible to the eye, preventing texture flicker.
  - The back card face is rotated by $180^\circ$ ($\pi$ radians) inside the transform to offset horizontal mirroring, rendering text correctly.
- **Interruptibility**:
  - Tapping while animating checks `_controller.isAnimating`. If true, it reverses the current timeline direction immediately, avoiding jumps.

---

## State Management
GetX is used selectively where it is most justified:
1. **Routing**: To configure clean slide and fade page transitions.
2. **ViewModel reactivity**: `SessionViewModel` utilizes reactive streams (`RxList`, `RxInt`, `RxBool`) to track session statistics.
3. **Selective UI rendering**: Only critical static labels (e.g. progress counter and timer) listen to ViewModel updates via `Obx` containers, avoiding heavy full-screen rebuilds on gesture frames.

---

## Data Model
- **`FlashCard`**: Represents a single study card containing an `id`, `question`, `answer`, and an optional `hint`.
- **`FlashDeck`**: Represents a deck group containing an `id`, `name`, `description`, and a `List<FlashCard>`.
- **`SessionResult`**: Holds post-deck results including `deckId`, counts of known/needs-practice cards, total cards, time elapsed, accuracy rate, and timestamp.

---

## Performance Optimizations
To secure smooth $60\text{fps}$ rendering on mid-range devices:
1. **No Full-Stack Rebuilds**: The `SwipeableCard` updates position and rotation using `AnimatedBuilder` transforms, modifying only the GPU render layer without invoking `setState` or triggering layout passes on the card content.
2. **Underneath Stack Interpolation**: The underneath cards scale and translate reactively inside a `ValueListenableBuilder` bound to the active card's horizontal `dragXNotifier`.
3. **Card Face Caching**: The front and back widgets of `FlashCardWidget` are built once outside the `AnimatedBuilder`'s builder function, preventing heavy layout reconstruction on every frame of the flip animation.
4. **Stacked Blur Elimination**: Backdrop blur (`BackdropFilter`) is an expensive GPU raster operation. Background cards in the stack are rendered with `enableBlur: false`. Only the active top card uses `enableBlur: true`.

---

## Responsive Design
- **Aspect Ratio Constraint**: The card stack is wrapped inside an `AspectRatio(aspectRatio: 0.68)` layout. On extra-tall phones, the card adapts without stretching; on landscape tablets, the card centers neatly at its natural aspect ratio rather than stretching to the screen edges.
- **Dynamic Text Scaling**: All text style definitions use ScreenUtil scaling `.sp` to adapt font sizes based on device screen density.
- **Safe Area Guards**: Safe area spacing is used in all screens to prevent notches, status bars, and system navigation indicators from clipping interactive buttons or header info.

---

## Haptics
- **3D Flip Haptic**: Triggers `HapticFeedback.lightImpact()` on tap to flip.
- **Threshold Crossing Haptic**: Triggers `HapticFeedback.mediumImpact()` the moment the drag distance crosses the commit threshold. Tracks state using `_hasTriggeredHaptic` so that haptics are never fired repeatedly on subsequent drag frames.

---

## How to Run
To run the project locally, execute the following commands in the project root folder:
```bash
flutter pub get
flutter run
```

---

## Build APK
To compile a debug Android build for testing, run:
```bash
flutter build apk --debug
```
The compiled APK will be outputted to:
`build\app\outputs\flutter-apk\app-debug.apk`

---

## Demo Checklist
When recording a demo video for submission, verify that you demonstrate:
1. **Interactive 3D Flip**: Tap a card to flip, and tap mid-flip to reverse the animation.
2. **Committed Right Swipe**: Drag a card to the right past the threshold (green "KNOWN" stamp appears, tactile click triggers) and release.
3. **Committed Left Swipe**: Swipe a card to the left past the threshold (red "NEEDS PRACTICE" stamp appears) and release.
4. **Flick/Velocity Commit**: Drag a card a short distance, then flick it quickly to verify it commits based on velocity.
5. **Failed Swipe Spring-back**: Drag a card slightly and release to show it bouncing back to center.
6. **Summary Screen**: Complete the deck, verify results (accuracy, timer, counts), and test "Restart Full Deck" and "Restart Practice" buttons.
