/// LonePengu Button System - Tailwind-like Buttons
///
/// Consistent button system with loading/disabled states
/// Usage: AppButton.primary(label: "Save", onTap: () {})

import 'package:flutter/material.dart';
import 'colors.dart';
import 'spacing.dart';
import 'radius.dart';
import 'shadows.dart';
import 'text_styles.dart';

/// Button size variants
enum ButtonSize { sm, md, lg }

/// Button widget with multiple variants
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final IconData? suffixIcon;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;
  final ButtonSize size;
  final _ButtonVariant _variant;
  final Color? customColor;
  final Color? customTextColor;

  const AppButton._({
    required this.label,
    required this.onTap,
    required _ButtonVariant variant,
    this.icon,
    this.suffixIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = false,
    this.size = ButtonSize.md,
    this.customColor,
    this.customTextColor,
  }) : _variant = variant;

  // ═══════════════════════════════════════════
  // FACTORY CONSTRUCTORS
  // ═══════════════════════════════════════════

  /// Primary filled button (Arctic Blue)
  factory AppButton.primary({
    required String label,
    VoidCallback? onTap,
    IconData? icon,
    IconData? suffixIcon,
    bool isLoading = false,
    bool isDisabled = false,
    bool fullWidth = false,
    ButtonSize size = ButtonSize.md,
  }) => AppButton._(
    label: label,
    onTap: onTap,
    icon: icon,
    suffixIcon: suffixIcon,
    isLoading: isLoading,
    isDisabled: isDisabled,
    fullWidth: fullWidth,
    size: size,
    variant: _ButtonVariant.primary,
  );

  /// Secondary outlined button
  factory AppButton.secondary({
    required String label,
    VoidCallback? onTap,
    IconData? icon,
    IconData? suffixIcon,
    bool isLoading = false,
    bool isDisabled = false,
    bool fullWidth = false,
    ButtonSize size = ButtonSize.md,
  }) => AppButton._(
    label: label,
    onTap: onTap,
    icon: icon,
    suffixIcon: suffixIcon,
    isLoading: isLoading,
    isDisabled: isDisabled,
    fullWidth: fullWidth,
    size: size,
    variant: _ButtonVariant.secondary,
  );

  /// Ghost/Text button (no background)
  factory AppButton.ghost({
    required String label,
    VoidCallback? onTap,
    IconData? icon,
    IconData? suffixIcon,
    bool isLoading = false,
    bool isDisabled = false,
    bool fullWidth = false,
    ButtonSize size = ButtonSize.md,
  }) => AppButton._(
    label: label,
    onTap: onTap,
    icon: icon,
    suffixIcon: suffixIcon,
    isLoading: isLoading,
    isDisabled: isDisabled,
    fullWidth: fullWidth,
    size: size,
    variant: _ButtonVariant.ghost,
  );

  /// Danger/Destructive button (Coral)
  factory AppButton.danger({
    required String label,
    VoidCallback? onTap,
    IconData? icon,
    IconData? suffixIcon,
    bool isLoading = false,
    bool isDisabled = false,
    bool fullWidth = false,
    ButtonSize size = ButtonSize.md,
  }) => AppButton._(
    label: label,
    onTap: onTap,
    icon: icon,
    suffixIcon: suffixIcon,
    isLoading: isLoading,
    isDisabled: isDisabled,
    fullWidth: fullWidth,
    size: size,
    variant: _ButtonVariant.danger,
  );

  /// Teal/Secondary accent button
  factory AppButton.teal({
    required String label,
    VoidCallback? onTap,
    IconData? icon,
    IconData? suffixIcon,
    bool isLoading = false,
    bool isDisabled = false,
    bool fullWidth = false,
    ButtonSize size = ButtonSize.md,
  }) => AppButton._(
    label: label,
    onTap: onTap,
    icon: icon,
    suffixIcon: suffixIcon,
    isLoading: isLoading,
    isDisabled: isDisabled,
    fullWidth: fullWidth,
    size: size,
    variant: _ButtonVariant.teal,
  );

  /// Soft/Muted button (light background)
  factory AppButton.soft({
    required String label,
    VoidCallback? onTap,
    IconData? icon,
    IconData? suffixIcon,
    bool isLoading = false,
    bool isDisabled = false,
    bool fullWidth = false,
    ButtonSize size = ButtonSize.md,
  }) => AppButton._(
    label: label,
    onTap: onTap,
    icon: icon,
    suffixIcon: suffixIcon,
    isLoading: isLoading,
    isDisabled: isDisabled,
    fullWidth: fullWidth,
    size: size,
    variant: _ButtonVariant.soft,
  );

  /// Custom color button
  factory AppButton.custom({
    required String label,
    required Color color,
    Color? textColor,
    VoidCallback? onTap,
    IconData? icon,
    IconData? suffixIcon,
    bool isLoading = false,
    bool isDisabled = false,
    bool fullWidth = false,
    ButtonSize size = ButtonSize.md,
  }) => AppButton._(
    label: label,
    onTap: onTap,
    icon: icon,
    suffixIcon: suffixIcon,
    isLoading: isLoading,
    isDisabled: isDisabled,
    fullWidth: fullWidth,
    size: size,
    variant: _ButtonVariant.custom,
    customColor: color,
    customTextColor: textColor ?? Colors.white,
  );

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isInteractive =
        !widget.isLoading && !widget.isDisabled && widget.onTap != null;
    final styles = _getStyles();
    final dimensions = _getDimensions();

    return GestureDetector(
      onTapDown: isInteractive
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: isInteractive ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isInteractive
          ? () => setState(() => _isPressed = false)
          : null,
      onTap: isInteractive ? widget.onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: widget.fullWidth ? double.infinity : null,
        height: dimensions.height,
        padding: dimensions.padding,
        decoration: BoxDecoration(
          color: _isPressed ? styles.pressedColor : styles.backgroundColor,
          borderRadius: LPRadius.button,
          border: styles.border,
          boxShadow: _isPressed ? LPShadows.none : styles.shadow,
        ),
        child: Row(
          mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Loading indicator
            if (widget.isLoading)
              SizedBox(
                width: dimensions.iconSize,
                height: dimensions.iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(styles.textColor),
                ),
              )
            // Leading icon
            else if (widget.icon != null)
              Icon(
                widget.icon,
                size: dimensions.iconSize,
                color: styles.textColor,
              ),

            // Spacing
            if ((widget.isLoading || widget.icon != null) &&
                widget.label.isNotEmpty)
              SizedBox(width: dimensions.iconSpacing),

            // Label
            if (widget.label.isNotEmpty)
              Text(
                widget.label,
                style: dimensions.textStyle.copyWith(color: styles.textColor),
              ),

            // Suffix icon
            if (widget.suffixIcon != null && !widget.isLoading) ...[
              SizedBox(width: dimensions.iconSpacing),
              Icon(
                widget.suffixIcon,
                size: dimensions.iconSize,
                color: styles.textColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  _ButtonStyles _getStyles() {
    final disabled = widget.isDisabled || widget.onTap == null;

    switch (widget._variant) {
      case _ButtonVariant.primary:
        return _ButtonStyles(
          backgroundColor: disabled ? LPColors.grey300 : LPColors.primary,
          pressedColor: LPColors.primaryDark,
          textColor: disabled ? LPColors.grey500 : Colors.white,
          shadow: disabled ? LPShadows.none : LPShadows.button,
        );

      case _ButtonVariant.secondary:
        return _ButtonStyles(
          backgroundColor: LPColors.surface,
          pressedColor: LPColors.grey50,
          textColor: disabled ? LPColors.grey400 : LPColors.primary,
          border: Border.all(
            color: disabled ? LPColors.grey200 : LPColors.border,
            width: 1.5,
          ),
          shadow: disabled ? LPShadows.none : LPShadows.xs,
        );

      case _ButtonVariant.ghost:
        return _ButtonStyles(
          backgroundColor: Colors.transparent,
          pressedColor: LPColors.grey50,
          textColor: disabled ? LPColors.grey400 : LPColors.primary,
        );

      case _ButtonVariant.danger:
        return _ButtonStyles(
          backgroundColor: disabled ? LPColors.grey300 : LPColors.coral,
          pressedColor: LPColors.coralDark,
          textColor: disabled ? LPColors.grey500 : Colors.white,
          shadow: disabled ? LPShadows.none : LPShadows.button,
        );

      case _ButtonVariant.teal:
        return _ButtonStyles(
          backgroundColor: disabled ? LPColors.grey300 : LPColors.secondary,
          pressedColor: LPColors.secondaryDark,
          textColor: disabled ? LPColors.grey500 : Colors.white,
          shadow: disabled ? LPShadows.none : LPShadows.button,
        );

      case _ButtonVariant.soft:
        return _ButtonStyles(
          backgroundColor: disabled
              ? LPColors.grey100
              : LPColors.primary.withValues(alpha: 0.05),
          pressedColor: LPColors.primary.withValues(alpha: 0.1),
          textColor: disabled ? LPColors.grey400 : LPColors.primary,
          border: Border.all(
            color: disabled
                ? Colors.transparent
                : LPColors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        );

      case _ButtonVariant.custom:
        return _ButtonStyles(
          backgroundColor: disabled ? LPColors.grey300 : widget.customColor!,
          pressedColor: LPColors.darken(widget.customColor!, 0.1),
          textColor: disabled ? LPColors.grey500 : widget.customTextColor!,
          shadow: disabled ? LPShadows.none : LPShadows.button,
        );
    }
  }

  _ButtonDimensions _getDimensions() {
    switch (widget.size) {
      case ButtonSize.sm:
        return _ButtonDimensions(
          height: 32,
          padding: LPSpacing.buttonCompact,
          textStyle: LPText.buttonSM,
          iconSize: 14,
          iconSpacing: 6,
        );
      case ButtonSize.md:
        return _ButtonDimensions(
          height: 44,
          padding: LPSpacing.button,
          textStyle: LPText.button,
          iconSize: 18,
          iconSpacing: 8,
        );
      case ButtonSize.lg:
        return _ButtonDimensions(
          height: 52,
          padding: LPSpacing.buttonLarge,
          textStyle: LPText.buttonLG,
          iconSize: 20,
          iconSpacing: 10,
        );
    }
  }
}

enum _ButtonVariant { primary, secondary, ghost, danger, teal, soft, custom }

class _ButtonStyles {
  final Color backgroundColor;
  final Color pressedColor;
  final Color textColor;
  final Border? border;
  final List<BoxShadow>? shadow;

  const _ButtonStyles({
    required this.backgroundColor,
    required this.pressedColor,
    required this.textColor,
    this.border,
    this.shadow,
  });
}

class _ButtonDimensions {
  final double height;
  final EdgeInsets padding;
  final TextStyle textStyle;
  final double iconSize;
  final double iconSpacing;

  const _ButtonDimensions({
    required this.height,
    required this.padding,
    required this.textStyle,
    required this.iconSize,
    required this.iconSpacing,
  });
}

// ═══════════════════════════════════════════
// ICON BUTTON VARIANT
// ═══════════════════════════════════════════

/// Icon-only button widget
class AppIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final bool isLoading;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 44,
    this.color,
    this.backgroundColor,
    this.isLoading = false,
  });

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isInteractive = !widget.isLoading && widget.onTap != null;

    return GestureDetector(
      onTapDown: isInteractive
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: isInteractive ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isInteractive
          ? () => setState(() => _isPressed = false)
          : null,
      onTap: isInteractive ? widget.onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _isPressed
              ? (widget.backgroundColor ?? LPColors.grey100).withValues(
                  alpha: 0.8,
                )
              : widget.backgroundColor ?? Colors.transparent,
          borderRadius: LPRadius.smBorder,
        ),
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  width: widget.size * 0.45,
                  height: widget.size * 0.45,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.color ?? LPColors.primary,
                    ),
                  ),
                )
              : Icon(
                  widget.icon,
                  size: widget.size * 0.5,
                  color: widget.color ?? LPColors.textSecondary,
                ),
        ),
      ),
    );
  }
}
