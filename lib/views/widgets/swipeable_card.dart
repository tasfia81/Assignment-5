import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';

class SwipeableCardController {
  _SwipeableCardState? _state;

  void swipeLeft() {
    _state?.swipeLeft();
  }

  void swipeRight() {
    _state?.swipeRight();
  }
}

class SwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final SwipeableCardController? controller;
  final ValueNotifier<double>? dragXNotifier;

  // Swipe physics constants
  static const double distanceThresholdRatio = 0.35;
  static const double velocityThreshold = 800.0;

  const SwipeableCard({
    super.key,
    required this.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.controller,
    this.dragXNotifier,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with TickerProviderStateMixin {
  late AnimationController _xController;
  late AnimationController _yController;

  bool _isAnimating = false;
  bool _hasTriggeredHaptic = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller!._state = this;
    }

    // Unbounded controllers allow positions to grow to any value (X offset and Y offset)
    _xController = AnimationController.unbounded(vsync: this);
    _yController = AnimationController.unbounded(vsync: this);

    _xController.addListener(_onOffsetChanged);
    _yController.addListener(_onOffsetChanged);
  }

  @override
  void dispose() {
    _xController.removeListener(_onOffsetChanged);
    _yController.removeListener(_onOffsetChanged);
    _xController.dispose();
    _yController.dispose();
    super.dispose();
  }

  void _onOffsetChanged() {
    widget.dragXNotifier?.value = _xController.value;
  }

  void swipeLeft() {
    if (_isAnimating) return;
    _runFlyOutAnimation(left: true, velocityX: -800.0, velocityY: 0.0);
  }

  void swipeRight() {
    if (_isAnimating) return;
    _runFlyOutAnimation(left: false, velocityX: 800.0, velocityY: 0.0);
  }

  void _onPanStart(DragStartDetails details) {
    if (_isAnimating) return;
    _xController.stop();
    _yController.stop();
    _hasTriggeredHaptic = false;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;
    
    _xController.value += details.delta.dx;
    _yController.value += details.delta.dy;

    // Check haptic feedback condition
    final double screenWidth = MediaQuery.of(context).size.width;
    final double distanceThreshold = screenWidth * SwipeableCard.distanceThresholdRatio;
    final bool isPastThreshold = _xController.value.abs() >= distanceThreshold;

    if (isPastThreshold && !_hasTriggeredHaptic) {
      HapticFeedback.mediumImpact();
      _hasTriggeredHaptic = true;
    } else if (!isPastThreshold && _hasTriggeredHaptic) {
      _hasTriggeredHaptic = false;
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimating) return;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double distanceThreshold = screenWidth * SwipeableCard.distanceThresholdRatio;
    final double velocityThreshold = SwipeableCard.velocityThreshold;

    final double dx = _xController.value;
    final double vx = details.velocity.pixelsPerSecond.dx;
    final double vy = details.velocity.pixelsPerSecond.dy;

    bool isCommit = false;
    bool isLeft = false;

    // Evaluate release decision using both distance and velocity
    if (vx.abs() > velocityThreshold) {
      isCommit = true;
      isLeft = vx < 0;
    } else if (dx.abs() > distanceThreshold) {
      isCommit = true;
      isLeft = dx < 0;
    }

    if (isCommit) {
      _runFlyOutAnimation(left: isLeft, velocityX: vx, velocityY: vy);
    } else {
      _runSpringBackAnimation(velocityX: vx, velocityY: vy);
    }
  }

  void _runSpringBackAnimation({required double velocityX, required double velocityY}) {
    setState(() {
      _isAnimating = true;
    });

    // Underdamped spring description:
    // mass = 1.0, stiffness = 180.0, damping = 15.0
    // This allows the card to quickly return to center with a natural, bouncy settling effect.
    const spring = SpringDescription(
      mass: 1.0,
      stiffness: 180.0,
      damping: 15.0,
    );

    final simulationX = SpringSimulation(
      spring,
      _xController.value,
      0.0,
      velocityX,
    );

    final simulationY = SpringSimulation(
      spring,
      _yController.value,
      0.0,
      velocityY,
    );

    Future.wait([
      _xController.animateWith(simulationX),
      _yController.animateWith(simulationY),
    ]).then((_) {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }

  void _runFlyOutAnimation({
    required bool left,
    required double velocityX,
    required double velocityY,
  }) {
    setState(() {
      _isAnimating = true;
    });
    
    final double screenWidth = MediaQuery.of(context).size.width;
    // Set target far off screen so it flies completely off
    final double targetX = left ? -screenWidth - 300.0 : screenWidth + 300.0;

    // Fast, responsive spring simulation to pull card off-screen cleanly
    const spring = SpringDescription(
      mass: 1.0,
      stiffness: 150.0,
      damping: 20.0,
    );

    final simulationX = SpringSimulation(
      spring,
      _xController.value,
      targetX,
      velocityX,
    );

    // Let the Y coordinate quickly spring back to center horizontally as it exits
    final simulationY = SpringSimulation(
      spring,
      _yController.value,
      0.0,
      velocityY,
    );

    Future.wait([
      _xController.animateWith(simulationX),
      _yController.animateWith(simulationY),
    ]).then((_) {
      if (mounted) {
        if (left) {
          widget.onSwipeLeft();
        } else {
          widget.onSwipeRight();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double distanceThreshold = screenWidth * SwipeableCard.distanceThresholdRatio;

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([_xController, _yController]),
        builder: (context, child) {
          final x = _xController.value;
          final y = _yController.value;

          // Compute responsive rotation based on horizontal travel: 
          // rotation is proportional to horizontal offset (around 25 degrees max at screen boundary)
          final rotation = (x / screenWidth) * 0.45;

          // Calculate stamp progress and opacities
          double rightOpacity = 0.0;
          double leftOpacity = 0.0;
          double progress = 0.0;
          bool isCommitted = false;

          if (x > 0) {
            progress = (x / distanceThreshold).clamp(0.0, 1.0);
            rightOpacity = progress;
            isCommitted = x >= distanceThreshold;
          } else if (x < 0) {
            progress = (-x / distanceThreshold).clamp(0.0, 1.0);
            leftOpacity = progress;
            isCommitted = -x >= distanceThreshold;
          }

          if (isCommitted) {
            rightOpacity = 1.0;
            leftOpacity = 1.0;
            progress = 1.0;
          }

          return Transform.translate(
            offset: Offset(x, y),
            child: Transform.rotate(
              angle: rotation,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  widget.child,
                  // LEFT STAMP ("✕ NEEDS PRACTICE")
                  if (leftOpacity > 0.0)
                    Positioned(
                      top: 40.h,
                      right: 20.w,
                      child: Opacity(
                        opacity: leftOpacity,
                        child: Transform.translate(
                          offset: Offset(20.w * (1.0 - progress), 0),
                          child: Transform.rotate(
                            angle: -0.15,
                            child: _buildStamp(
                              text: '✕ NEEDS PRACTICE',
                              icon: Icons.cancel_outlined,
                              color: AppColors.error,
                              progress: progress,
                              isCommitted: isCommitted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // RIGHT STAMP ("✓ KNOWN")
                  if (rightOpacity > 0.0)
                    Positioned(
                      top: 40.h,
                      left: 20.w,
                      child: Opacity(
                        opacity: rightOpacity,
                        child: Transform.translate(
                          offset: Offset(-20.w * (1.0 - progress), 0),
                          child: Transform.rotate(
                            angle: 0.15,
                            child: _buildStamp(
                              text: '✓ KNOWN',
                              icon: Icons.check_circle_outline_rounded,
                              color: AppColors.success,
                              progress: progress,
                              isCommitted: isCommitted,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStamp({
    required String text,
    required IconData icon,
    required Color color,
    required double progress,
    required bool isCommitted,
  }) {
    final double borderWidth = isCommitted ? 4.r : (1.5.r + 1.5.r * progress);
    final Color stampColor = isCommitted ? Colors.white : color;
    final Color backgroundColor = isCommitted 
        ? color.withValues(alpha: 0.95) 
        : color.withValues(alpha: 0.15 * progress);
    final double scale = isCommitted ? 1.05 : (0.85 + 0.15 * progress);

    return Transform.scale(
      scale: scale,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: isCommitted ? Colors.white : color,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isCommitted
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12.r,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: stampColor, size: 24.r),
            SizedBox(width: 8.w),
            Text(
              text,
              style: TextStyle(
                color: stampColor,
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
