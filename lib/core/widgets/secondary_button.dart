import 'package:lone_pengu/core/design/lp_design.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Secondary outlined button
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isFullWidth;
  final IconData? icon;
  final double? height;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isFullWidth = true,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      height: height ?? 56,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: LPColors.primary, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: LPColors.primary, size: 20),
                  SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: LPColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return isFullWidth ? button : IntrinsicWidth(child: button);
  }
}
