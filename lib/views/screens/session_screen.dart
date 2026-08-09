import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../widgets/custom_progress_bar.dart';
import '../widgets/flash_card_widget.dart';
import '../widgets/glass_container.dart';
import '../widgets/swipeable_card.dart';

class SessionScreen extends GetView<SessionViewModel> {
  final SwipeableCardController _swipeController = SwipeableCardController();

  SessionScreen({super.key});

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.currentDeck.value == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.isSessionFinished.value) {
              return _buildCompletionView();
            }

            return _buildActiveSessionView();
          }),
        ),
      ),
    );
  }

  ///------------------------------------ Active Session View (Cards, Progress, Swipe actions) ------------------------------------
  Widget _buildActiveSessionView() {
    final total = controller.totalCardsCount;
    final index = controller.currentCardIndex.value;
    final knownCount = controller.knownCards.length;
    final practiceCount = controller.needsPracticeCards.length;
    final elapsed = controller.elapsedDuration.value;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///------------------------------------ Header Row ------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.close, color: AppColors.textPrimary, size: 24.r),
                onPressed: () => Get.back(),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    controller.currentDeck.value!.name,
                    style: AppTextStyles.h3.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.timer_outlined, color: AppColors.textSecondary, size: 16.r),
                  SizedBox(width: 4.w),
                  Text(
                    _formatDuration(elapsed),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),

          ///------------------------------------ Progress Area ------------------------------------
          CustomProgressBar(
            total: total,
            known: knownCount,
            needsPractice: practiceCount,
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Card ${index + 1} of $total',
                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  _buildStatDot(AppColors.success, '$knownCount'),
                  SizedBox(width: 12.w),
                  _buildStatDot(AppColors.error, '$practiceCount'),
                ],
              )
            ],
          ),
          SizedBox(height: 24.h),

          Expanded(
            child: Obx(() {
              final index = controller.currentCardIndex.value;
              final cards = controller.activeCards;
              if (cards.isEmpty || index >= cards.length) {
                return const Center(child: CircularProgressIndicator());
              }

              final List<Widget> stackChildren = [];

              // Underneath card 2 (deepest)
              if (index + 2 < cards.length) {
                stackChildren.add(
                  Transform.translate(
                    offset: Offset(0, 16.h),
                    child: Transform.scale(
                      scale: 0.90,
                      child: Opacity(
                        opacity: 0.5,
                        child: FlashCardWidget(
                          key: ValueKey<String>('${cards[index + 2].id}_bg2'),
                          flashCard: cards[index + 2],
                        ),
                      ),
                    ),
                  ),
                );
              }

              // Underneath card 1 (middle)
              if (index + 1 < cards.length) {
                stackChildren.add(
                  Transform.translate(
                    offset: Offset(0, 8.h),
                    child: Transform.scale(
                      scale: 0.95,
                      child: Opacity(
                        opacity: 0.8,
                        child: FlashCardWidget(
                          key: ValueKey<String>('${cards[index + 1].id}_bg1'),
                          flashCard: cards[index + 1],
                        ),
                      ),
                    ),
                  ),
                );
              }

              // Top card (swipeable)
              final topCard = cards[index];
              stackChildren.add(
                SwipeableCard(
                  key: ValueKey<String>('${topCard.id}_swipe'),
                  controller: _swipeController,
                  onSwipeLeft: () => controller.markAsNeedsPractice(),
                  onSwipeRight: () => controller.markAsKnown(),
                  child: FlashCardWidget(
                    key: ValueKey<String>(topCard.id),
                    flashCard: topCard,
                  ),
                ),
              );

              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: stackChildren,
              );
            }),
          ),
          SizedBox(height: 24.h),

          ///------------------------------------ Controls Action Row ------------------------------------
          Row(
            children: [
              ///------------------------------------ Needs Practice Button ------------------------------------
              Expanded(
                child: _buildActionButton(
                  onPressed: () => _swipeController.swipeLeft(),
                  label: 'Needs Practice',
                  icon: Icons.cancel_outlined,
                  color: AppColors.error,
                  isOutlined: true,
                ),
              ),
              SizedBox(width: 16.w),
              ///------------------------------------ Known Button ------------------------------------
              Expanded(
                child: _buildActionButton(
                  onPressed: () => _swipeController.swipeRight(),
                  label: 'Known',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  isOutlined: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///------------------------------------ End of Deck Summary / Completion View ------------------------------------
  Widget _buildCompletionView() {
    final result = controller.getSessionResult();
    if (result == null) return const Center(child: CircularProgressIndicator());

    final isWeakPracticeAvailable = controller.needsPracticeCards.isNotEmpty;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ///------------------------------------ Celebratory Icon Glow ------------------------------------
            Container(
              height: 100.r,
              width: 100.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                color: Colors.white,
                size: 48.r,
              ),
            ),
            SizedBox(height: 24.h),

            Text(
              'Session Finished!',
              style: AppTextStyles.h2,
            ),
            SizedBox(height: 8.h),
            Text(
              'Great job practicing this deck.',
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: 32.h),

            ///------------------------------------ Statistics Grid Container ------------------------------------
            GlassContainer(
              padding: EdgeInsets.all(24.r),
              child: Column(
                children: [
                  Text(
                    'SESSION SUMMARY',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Accuracy', '${result.accuracyRate.toStringAsFixed(0)}%', AppColors.success),
                      _buildStatColumn('Time Spent', _formatDuration(result.duration), AppColors.primaryLight),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  const Divider(color: AppColors.border, height: 1),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryCounter('Known', result.knownCount, AppColors.success),
                      _buildSummaryCounter('Needs Practice', result.needsPracticeCount, AppColors.error),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),

            ///------------------------------------ Action Buttons ------------------------------------
            // Option 1: Restart Needs-Practice Deck (Weak Cards)
            if (isWeakPracticeAvailable) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.restartNeedsPracticeDeck(),
                  icon: Icon(Icons.replay_circle_filled, size: 20.r, color: Colors.white),
                  label: Text('Practice Weak Cards (${result.needsPracticeCount})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],

            // Option 2: Restart Full Deck
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.restartFullDeck(),
                icon: Icon(Icons.refresh, size: 20.r, color: Colors.white),
                label: const Text('Restart Full Deck'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Option 3: Return Home
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => Get.back(),
                icon: Icon(Icons.home_outlined, size: 20.r, color: AppColors.textSecondary),
                label: const Text('Back to Decks'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: const BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///------------------------------------ Stat Indicators ------------------------------------
  Widget _buildStatDot(Color color, String count) {
    return Row(
      children: [
        Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          count,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: AppTextStyles.h2.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildSummaryCounter(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12.r,
          height: 12.r,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '$count $label',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  ///------------------------------------ Action Buttons Builder ------------------------------------
  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    required Color color,
    required bool isOutlined,
  }) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.r),
      side: isOutlined ? BorderSide(color: color, width: 1.5) : BorderSide.none,
    );

    final textStyle = TextStyle(
      fontSize: 15.sp,
      fontWeight: FontWeight.bold,
      color: isOutlined ? color : Colors.white,
    );

    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 20.r),
        label: Text(label, style: textStyle),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          side: BorderSide(color: color, width: 1.5),
          shape: shape,
          foregroundColor: color,
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 20.r),
      label: Text(label, style: textStyle),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: shape,
        elevation: 0,
      ),
    );
  }
}
