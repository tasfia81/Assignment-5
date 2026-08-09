import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../widgets/glass_container.dart';

class SummaryScreen extends GetView<SessionViewModel> {
  const SummaryScreen({super.key});

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final result = controller.getSessionResult();
    if (result == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final deckName = controller.currentDeck.value?.name ?? 'Deck';
    final isWeakPracticeAvailable = result.needsPracticeCount > 0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
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
                      gradient: isWeakPracticeAvailable
                          ? AppColors.primaryGradient
                          : AppColors.successGradient,
                      boxShadow: [
                        BoxShadow(
                          color: (isWeakPracticeAvailable
                                  ? AppColors.primary
                                  : AppColors.success)
                              .withValues(alpha: 0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      isWeakPracticeAvailable
                          ? Icons.emoji_events_outlined
                          : Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 48.r,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  Text(
                    isWeakPracticeAvailable ? 'Session Finished!' : 'Deck Mastered!',
                    style: AppTextStyles.h2,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    isWeakPracticeAvailable
                        ? 'Great job practicing "$deckName".'
                        : 'Amazing! You know every card in "$deckName".',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
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
                            Expanded(
                              child: _buildSummaryCounter('Known', result.knownCount, AppColors.success),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: _buildSummaryCounter('Needs Practice', result.needsPracticeCount, AppColors.error),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),

                  ///------------------------------------ Action Buttons ------------------------------------
                  if (isWeakPracticeAvailable) ...[
                    // Option 1: Restart Needs-Practice Deck (Weak Cards)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          controller.restartNeedsPracticeDeck();
                          Get.offNamed('/session');
                        },
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
                  ] else ...[
                    // Mastered state notification
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 1.5.r),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stars_rounded, color: AppColors.success, size: 24.r),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Mastered! No weak cards to practice.',
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],

                  // Option 2: Restart Full Deck
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        controller.restartFullDeck();
                        Get.offNamed('/session');
                      },
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
                      onPressed: () => Get.offAllNamed('/'),
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
          ),
        ),
      ),
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
      mainAxisSize: MainAxisSize.min,
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
        Flexible(
          child: Text(
            '$count $label',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
