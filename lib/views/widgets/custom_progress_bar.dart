import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';

class CustomProgressBar extends StatelessWidget {
  final int total;
  final int known;
  final int needsPractice;

  const CustomProgressBar({
    super.key,
    required this.total,
    required this.known,
    required this.needsPractice,
  });

  @override
  Widget build(BuildContext context) {
    final int remaining = total - (known + needsPractice);
    final double height = 8.h;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: Row(
          children: [
            if (known > 0)
              Expanded(
                flex: known,
                child: Container(
                  height: height,
                  color: AppColors.success,
                ),
              ),
            if (needsPractice > 0)
              Expanded(
                flex: needsPractice,
                child: Container(
                  height: height,
                  color: AppColors.error,
                ),
              ),
            if (remaining > 0)
              Expanded(
                flex: remaining,
                child: Container(
                  height: height,
                  color: Colors.transparent, // Background shows through
                ),
              ),
          ],
        ),
      ),
    );
  }
}
