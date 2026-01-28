import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector line
            final stepIndex = index ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: stepIndex < currentStep
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.outlineVariant,
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
              duration: const Duration(milliseconds: 200),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Step circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? theme.colorScheme.tertiary
                          : isCurrent
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? theme.colorScheme.tertiary
                            : isCurrent
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        width: 2,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.3,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: theme.colorScheme.onTertiary,
                            )
                          : Text(
                              '${stepIndex + 1}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isCurrent
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Step label
                  Text(
                    steps[stepIndex],
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isCurrent
                          ? theme.colorScheme.primary
                          : isCompleted
                          ? theme.colorScheme.tertiary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                      fontSize: 10,
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
