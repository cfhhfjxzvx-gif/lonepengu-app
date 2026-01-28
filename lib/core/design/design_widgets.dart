/// Design System Widgets - BRD Section 10: Design Guidelines
///
/// Reusable UI components using design tokens

import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Styled Card widget using design tokens
class DesignCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final Border? border;

  const DesignCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.boxShadow,
    this.backgroundColor,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-aware defaults
    final effectiveBgColor =
        backgroundColor ??
        (isDark ? AppDesignColors.surfaceDark : AppDesignColors.surface);
    final effectiveBorder =
        border ??
        Border.all(
          color: isDark
              ? AppDesignColors.borderDark
              : AppDesignColors.borderLight,
          width: 1,
        );
    final effectiveShadow =
        boxShadow ?? (isDark ? AppShadows.md : AppShadows.card);

    final content = Container(
      padding: padding ?? AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: borderRadius ?? AppRadius.cardBorder,
        boxShadow: effectiveShadow,
        border: effectiveBorder,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}

/// Primary button using design tokens
class DesignButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final ButtonSize size;
  final ButtonVariant variant;
  final bool fullWidth;

  const DesignButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.size = ButtonSize.medium,
    this.variant = ButtonVariant.primary,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final textStyle = _getTextStyle();
    final height = _getHeight();
    final padding = _getPadding();

    Widget buttonContent = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == ButtonVariant.primary
                    ? AppDesignColors.white
                    : AppDesignColors.primary,
              ),
            ),
          )
        else if (icon != null)
          Icon(icon, size: 18),
        if ((icon != null || isLoading) && label.isNotEmpty)
          const SizedBox(width: 8),
        if (label.isNotEmpty) Text(label, style: textStyle),
      ],
    );

    return SizedBox(
      height: height,
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle.copyWith(padding: WidgetStatePropertyAll(padding)),
        child: buttonContent,
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppDesignColors.primary,
          foregroundColor: AppDesignColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder),
        );
      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppDesignColors.surface,
          foregroundColor: AppDesignColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorder,
            side: const BorderSide(color: AppDesignColors.primary, width: 1.5),
          ),
        );
      case ButtonVariant.ghost:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppDesignColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder),
        );
      case ButtonVariant.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: AppDesignColors.error,
          foregroundColor: AppDesignColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder),
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonSize.small:
        return const TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
      case ButtonSize.medium:
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
      case ButtonSize.large:
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    }
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return AppSizes.buttonHeightSm;
      case ButtonSize.medium:
        return AppSizes.buttonHeightMd;
      case ButtonSize.large:
        return AppSizes.buttonHeightLg;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return AppSpacing.buttonPaddingCompact;
      case ButtonSize.medium:
        return AppSpacing.buttonPadding;
      case ButtonSize.large:
        return AppSpacing.buttonPaddingLarge;
    }
  }
}

enum ButtonSize { small, medium, large }

enum ButtonVariant { primary, secondary, ghost, danger }

/// Text input using design tokens
class DesignTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final Widget? prefix;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool enabled;
  final FocusNode? focusNode;

  const DesignTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.onTap,
    this.enabled = true,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppDesignColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          onTap: onTap,
          enabled: enabled,
          focusNode: focusNode,
          style: const TextStyle(
            fontSize: 14,
            color: AppDesignColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppDesignColors.textTertiary,
              fontSize: 14,
            ),
            errorText: errorText,
            prefixIcon: prefix,
            suffixIcon: suffix,
            contentPadding: AppSpacing.inputPadding,
            filled: true,
            fillColor: enabled
                ? AppDesignColors.surface
                : AppDesignColors.grey100,
            border: OutlineInputBorder(
              borderRadius: AppRadius.inputBorder,
              borderSide: const BorderSide(color: AppDesignColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputBorder,
              borderSide: const BorderSide(color: AppDesignColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputBorder,
              borderSide: const BorderSide(
                color: AppDesignColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputBorder,
              borderSide: const BorderSide(color: AppDesignColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputBorder,
              borderSide: const BorderSide(
                color: AppDesignColors.error,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Section header using design tokens
class DesignSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsets? padding;

  const DesignSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppDesignColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppDesignColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Empty state widget using design tokens
class DesignEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const DesignEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppDesignColors.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppDesignColors.grey400),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppDesignColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppDesignColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              DesignButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading indicator using design tokens
class DesignLoading extends StatelessWidget {
  final String? message;
  final double size;

  const DesignLoading({super.key, this.message, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppDesignColors.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: AppDesignColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Chip using design tokens
class DesignChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DesignChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppDesignColors.grey100,
          borderRadius: AppRadius.chipBorder,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: textColor ?? AppDesignColors.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor ?? AppDesignColors.textSecondary,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: textColor ?? AppDesignColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
