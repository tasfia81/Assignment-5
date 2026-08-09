import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../widgets/custom_progress_bar.dart';
import '../widgets/flash_card_widget.dart';
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

            return _buildActiveSessionView(context);
          }),
        ),
      ),
    );
  }

  ///------------------------------------ Active Session View (Cards, Progress, Swipe actions) ------------------------------------
  Widget _buildActiveSessionView(BuildContext context) {
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
                'Card ${index < total ? index + 1 : total} of $total',
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

          ///------------------------------------ Card Stack ------------------------------------
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 0.68,
                child: Obx(() {
                  final cardsIndex = controller.currentCardIndex.value;
                  final cards = controller.activeCards;
                  if (cards.isEmpty || cardsIndex >= cards.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Create a local dragXNotifier for the active card stack
                  final ValueNotifier<double> dragXNotifier = ValueNotifier<double>(0.0);

                  final List<Widget> stackChildren = [];

                  // Underneath card 2 (deepest)
                  if (cardsIndex + 2 < cards.length) {
                    stackChildren.add(
                      ValueListenableBuilder<double>(
                        valueListenable: dragXNotifier,
                        builder: (context, dragX, child) {
                          final double screenWidth = MediaQuery.of(context).size.width;
                          final double threshold = screenWidth * 0.35;
                          final double progress = (dragX.abs() / threshold).clamp(0.0, 1.0);

                          // Interpolate visual stack parameters
                          final double scale = 0.90 + 0.05 * progress;
                          final double yOffset = 16.h - 8.h * progress;
                          final double opacity = 0.5 + 0.3 * progress;

                          return Transform.translate(
                            offset: Offset(0, yOffset),
                            child: Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: opacity,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: FlashCardWidget(
                          key: ValueKey<String>('${cards[cardsIndex + 2].id}_bg2'),
                          flashCard: cards[cardsIndex + 2],
                          enableBlur: false, // Optimisation: disable blur for underneath card
                        ),
                      ),
                    );
                  }

                  // Underneath card 1 (middle)
                  if (cardsIndex + 1 < cards.length) {
                    stackChildren.add(
                      ValueListenableBuilder<double>(
                        valueListenable: dragXNotifier,
                        builder: (context, dragX, child) {
                          final double screenWidth = MediaQuery.of(context).size.width;
                          final double threshold = screenWidth * 0.35;
                          final double progress = (dragX.abs() / threshold).clamp(0.0, 1.0);

                          // Interpolate visual stack parameters
                          final double scale = 0.95 + 0.05 * progress;
                          final double yOffset = 8.h - 8.h * progress;
                          final double opacity = 0.8 + 0.2 * progress;

                          return Transform.translate(
                            offset: Offset(0, yOffset),
                            child: Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: opacity,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: FlashCardWidget(
                          key: ValueKey<String>('${cards[cardsIndex + 1].id}_bg1'),
                          flashCard: cards[cardsIndex + 1],
                          enableBlur: false, // Optimisation: disable blur for underneath card
                        ),
                      ),
                    );
                  }

                  // Top card (swipeable)
                  final topCard = cards[cardsIndex];
                  stackChildren.add(
                    SwipeableCard(
                      key: ValueKey<String>('${topCard.id}_swipe'),
                      controller: _swipeController,
                      dragXNotifier: dragXNotifier,
                      onSwipeLeft: () => controller.markAsNeedsPractice(topCard.id),
                      onSwipeRight: () => controller.markAsKnown(topCard.id),
                      child: FlashCardWidget(
                        key: ValueKey<String>(topCard.id),
                        flashCard: topCard,
                        enableBlur: true, // Keep blur enabled for active card
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
            ),
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
