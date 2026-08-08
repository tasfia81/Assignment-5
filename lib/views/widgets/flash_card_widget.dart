import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/flashcard_model.dart';
import 'glass_container.dart';

class FlashCardWidget extends StatefulWidget {
  final FlashCard flashCard;

  const FlashCardWidget({
    super.key,
    required this.flashCard,
  });

  @override
  State<FlashCardWidget> createState() => _FlashCardWidgetState();
}

class _FlashCardWidgetState extends State<FlashCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 400ms duration provides a snappy, premium flip feel
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Dynamic linear animation mapping from 0.0 to 1.0
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Trigger physical haptic feedback where supported
    HapticFeedback.lightImpact();

    // Check if currently animating to ensure interruptibility
    if (_controller.isAnimating) {
      if (_controller.status == AnimationStatus.forward) {
        _controller.reverse();
      } else if (_controller.status == AnimationStatus.reverse) {
        _controller.forward();
      }
    } else {
      if (_controller.value == 0.0) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isFront = angle < pi / 2;

          // Compute perspective matrix transformation
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.0015) // Perspective factor (depth perception)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: isFront
                ? _buildCardSide(
                    label: 'QUESTION',
                    content: widget.flashCard.question,
                    hint: 'TAP TO REVEAL ANSWER',
                    labelColor: AppColors.textMuted,
                    contentStyle: AppTextStyles.cardQuestion,
                    glowColor: AppColors.primary.withValues(alpha: 0.4),
                  )
                : Transform(
                    // Rotate the back widget by pi around Y axis to prevent horizontal mirroring
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildCardSide(
                      label: 'ANSWER',
                      content: widget.flashCard.answer,
                      hint: 'TAP TO SEE QUESTION',
                      labelColor: AppColors.primaryLight,
                      contentStyle: AppTextStyles.cardAnswer,
                      glowColor: AppColors.primaryLight.withValues(alpha: 0.4),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardSide({
    required String label,
    required String content,
    required String hint,
    required Color labelColor,
    required TextStyle contentStyle,
    required Color glowColor,
  }) {
    return GlassContainer(
      width: double.infinity,
      height: double.infinity,
      hasGlow: true,
      glowColor: glowColor,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Card Type Header Label
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: labelColor,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          
          // Question or Answer Text
          Expanded(
            flex: 8,
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  content,
                  style: contentStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          
          const Spacer(),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app_outlined,
                size: 16.r,
                color: AppColors.textMuted,
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  hint,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
