import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

/// Custom stepper for Brand Kit wizard
class BrandKitStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  final Function(int)? onStepTap;

  const BrandKitStepper({
    super.key,
    required this.currentStep,
    required this.steps,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector line
            final stepIndex = index ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: stepIndex < currentStep
                      ? AppColors.auroraTeal
                      : AppColors.grey200,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentStep;
          final isCurrent = stepIndex == currentStep;

          return GestureDetector(
            onTap: () => onStepTap?.call(stepIndex),
            child: AnimatedContainer(
              duration: AppConstants.shortDuration,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Step circle
                  AnimatedContainer(
                    duration: AppConstants.shortDuration,
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.auroraTeal
                          : isCurrent
                          ? AppColors.arcticBlue
                          : AppColors.grey100,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.auroraTeal
                            : isCurrent
                            ? AppColors.arcticBlue
                            : AppColors.grey300,
                        width: 2,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.arcticBlue.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: AppColors.iceWhite,
                            )
                          : Text(
                              '${stepIndex + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isCurrent
                                    ? AppColors.iceWhite
                                    : AppColors.grey500,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Step label
                  Text(
                    steps[stepIndex],
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isCurrent
                          ? AppColors.arcticBlue
                          : isCompleted
                          ? AppColors.auroraTeal
                          : AppColors.grey500,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
