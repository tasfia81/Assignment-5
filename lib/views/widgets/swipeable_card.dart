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

  const SwipeableCard({
    super.key,
    required this.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.controller,
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
    // Rebuilds only the AnimatedBuilder layer (high performance)
  }

  void swipeLeft() {
    if (_isAnimating) return;
    _runFlyOutAnimation(left: true, velocity: -800.0);
  }

  void swipeRight() {
    if (_isAnimating) return;
    _runFlyOutAnimation(left: false, velocity: 800.0);
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
    final double distanceThreshold = screenWidth * 0.35;
    final bool isPastThreshold = _xController.value.abs() > distanceThreshold;

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
    final double distanceThreshold = screenWidth * 0.35;
    final double velocityThreshold = 800.0;

    final double dx = _xController.value;
    final double vx = details.velocity.pixelsPerSecond.dx;

    bool isCommit = false;
    bool isLeft = false;

    // Evaluate release decision using both distance and velocity
    if (dx.abs() > distanceThreshold) {
      isCommit = true;
      isLeft = dx < 0;
    } else if (vx.abs() > velocityThreshold) {
      isCommit = true;
      isLeft = vx < 0;
    }

    if (isCommit) {
      _runFlyOutAnimation(left: isLeft, velocity: vx);
    } else {
      _runSpringBackAnimation(velocityX: vx, velocityY: details.velocity.pixelsPerSecond.dy);
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

  void _runFlyOutAnimation({required bool left, required double velocity}) {
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
      velocity,
    );

    // Let the Y coordinate quickly spring back to center horizontally as it exits
    final simulationY = SpringSimulation(
      spring,
      _yController.value,
      0.0,
      0.0,
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
    final double distanceThreshold = screenWidth * 0.35;

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: Listenable.merge([_xController, _yController]),
        builder: (context, child) {
          final x = _xController.value;
          final y = _yController.value;

          // Compute responsive rotation based on horizontal travel: 
          // rotation is proportional to horizontal offset
          final rotation = x / (screenWidth * 10);

          // Calculate stamp opacities
          double rightOpacity = 0.0;
          double leftOpacity = 0.0;
          if (x > 0) {
            rightOpacity = (x / distanceThreshold).clamp(0.0, 1.0);
          } else if (x < 0) {
            leftOpacity = (-x / distanceThreshold).clamp(0.0, 1.0);
          }

          return Transform.translate(
            offset: Offset(x, y),
            child: Transform.rotate(
              angle: rotation,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  widget.child,
                  // LEFT STAMP ("NEEDS PRACTICE")
                  if (leftOpacity > 0.0)
                    Positioned(
                      top: 40.h,
                      right: 20.w,
                      child: Opacity(
                        opacity: leftOpacity,
                        child: Transform.rotate(
                          angle: -0.2,
                          child: _buildStamp(
                            text: 'NEEDS PRACTICE',
                            icon: Icons.cancel_outlined,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  // RIGHT STAMP ("KNOWN")
                  if (rightOpacity > 0.0)
                    Positioned(
                      top: 40.h,
                      left: 20.w,
                      child: Opacity(
                        opacity: rightOpacity,
                        child: Transform.rotate(
                          angle: 0.2,
                          child: _buildStamp(
                            text: 'KNOWN',
                            icon: Icons.check_circle_outline_rounded,
                            color: AppColors.success,
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
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 3.r),
        borderRadius: BorderRadius.circular(12.r),
        color: color.withValues(alpha: 0.15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24.r),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
