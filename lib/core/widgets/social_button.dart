import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// Social login button (e.g., Google)
class SocialButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isFullWidth;
  final double? height;

  const SocialButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isFullWidth = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      height: height ?? 56,
      decoration: BoxDecoration(
        color: AppColors.iceWhite,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.grey200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.penguinBlack.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                if (icon != null) ...[icon!, const SizedBox(width: 12)],
                Text(
                  text,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.grey700,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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

/// Google icon widget
class GoogleIcon extends StatelessWidget {
  final double size;

  const GoogleIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: GoogleLogoPainter()),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;

    // Google colors
    final Paint bluePaint = Paint()..color = const Color(0xFF4285F4);
    final Paint redPaint = Paint()..color = const Color(0xFFEA4335);
    final Paint yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final Paint greenPaint = Paint()..color = const Color(0xFF34A853);

    // Draw the G shape
    final Path bluePath = Path()
      ..moveTo(s * 0.96, s * 0.42)
      ..lineTo(s * 0.5, s * 0.42)
      ..lineTo(s * 0.5, s * 0.58)
      ..lineTo(s * 0.79, s * 0.58)
      ..cubicTo(s * 0.74, s * 0.73, s * 0.62, s * 0.83, s * 0.5, s * 0.83)
      ..cubicTo(s * 0.32, s * 0.83, s * 0.17, s * 0.68, s * 0.17, s * 0.5)
      ..cubicTo(s * 0.17, s * 0.32, s * 0.32, s * 0.17, s * 0.5, s * 0.17)
      ..cubicTo(s * 0.58, s * 0.17, s * 0.66, s * 0.21, s * 0.72, s * 0.27)
      ..lineTo(s * 0.84, s * 0.15)
      ..cubicTo(s * 0.74, s * 0.05, s * 0.62, s, s * 0.5, s * 0)
      ..close();

    canvas.drawPath(bluePath, bluePaint);

    // Red arc
    final Path redPath = Path()
      ..moveTo(s * 0.5, s * 0)
      ..cubicTo(s * 0.38, s * 0, s * 0.26, s * 0.05, s * 0.16, s * 0.15)
      ..lineTo(s * 0.28, s * 0.27)
      ..cubicTo(s * 0.35, s * 0.21, s * 0.42, s * 0.17, s * 0.5, s * 0.17)
      ..cubicTo(s * 0.58, s * 0.17, s * 0.66, s * 0.21, s * 0.72, s * 0.27)
      ..lineTo(s * 0.84, s * 0.15)
      ..cubicTo(s * 0.74, s * 0.05, s * 0.62, s * 0, s * 0.5, s * 0)
      ..close();

    canvas.drawPath(redPath, redPaint);

    // Yellow arc
    final Path yellowPath = Path()
      ..moveTo(s * 0.16, s * 0.15)
      ..cubicTo(s * 0.06, s * 0.26, s * 0, s * 0.38, s * 0, s * 0.5)
      ..cubicTo(s * 0, s * 0.62, s * 0.06, s * 0.74, s * 0.16, s * 0.85)
      ..lineTo(s * 0.28, s * 0.73)
      ..cubicTo(s * 0.21, s * 0.66, s * 0.17, s * 0.58, s * 0.17, s * 0.5)
      ..cubicTo(s * 0.17, s * 0.42, s * 0.21, s * 0.35, s * 0.28, s * 0.27)
      ..close();

    canvas.drawPath(yellowPath, yellowPaint);

    // Green arc
    final Path greenPath = Path()
      ..moveTo(s * 0.16, s * 0.85)
      ..cubicTo(s * 0.26, s * 0.95, s * 0.38, s, s * 0.5, s)
      ..cubicTo(s * 0.69, s, s * 0.85, s * 0.89, s * 0.93, s * 0.73)
      ..lineTo(s * 0.79, s * 0.58)
      ..cubicTo(s * 0.74, s * 0.73, s * 0.62, s * 0.83, s * 0.5, s * 0.83)
      ..cubicTo(s * 0.42, s * 0.83, s * 0.35, s * 0.79, s * 0.28, s * 0.73)
      ..close();

    canvas.drawPath(greenPath, greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
