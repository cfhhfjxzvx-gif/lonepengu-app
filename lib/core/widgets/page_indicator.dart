import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// Page indicator dots for page views
class PageIndicator extends StatelessWidget {
  final int pageCount;
  final int currentPage;
  final Color? activeColor;
  final Color? inactiveColor;

  const PageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => AnimatedContainer(
          duration: AppConstants.shortDuration,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == currentPage
                ? (activeColor ?? AppColors.arcticBlue)
                : (inactiveColor ?? AppColors.grey300),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
