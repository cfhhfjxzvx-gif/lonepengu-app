/// LonePengu Utility Widgets - Tailwind-like Component Helpers
///
/// Reusable UI components using design tokens
/// Usage: AppCard(...), AppSection(...), AppPill(...)

import 'package:flutter/material.dart';
import 'colors.dart';
import 'spacing.dart';
import 'radius.dart';
import 'shadows.dart';
import 'text_styles.dart';
import 'app_button.dart';

// ═══════════════════════════════════════════
// APP CARD - Surface container
// ═══════════════════════════════════════════

/// Standard card component with consistent styling
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadow;
  final Color? backgroundColor;
  final Border? border;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Gradient? gradient;
  final Clip clipBehavior;
  final bool useGlow;
  final Color? glowColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.shadow,
    this.backgroundColor,
    this.border,
    this.onTap,
    this.width,
    this.height,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
    this.useGlow = false,
    this.glowColor,
  });

  /// Card with no shadow (flat)
  const AppCard.flat({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.border,
    this.onTap,
    this.width,
    this.height,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
    this.useGlow = false,
    this.glowColor,
  }) : shadow = LPShadows.none;

  /// Card with elevated shadow
  factory AppCard.elevated({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    VoidCallback? onTap,
    bool useGlow = false,
    Color? glowColor,
  }) => AppCard(
    key: key,
    padding: padding,
    margin: margin,
    borderRadius: borderRadius,
    shadow: useGlow
        ? LPShadows.glow(glowColor ?? LPColors.primary)
        : LPShadows.cardElevated,
    backgroundColor: backgroundColor,
    onTap: onTap,
    useGlow: useGlow,
    glowColor: glowColor,
    child: child,
  );

  /// Card with border only (outlined)
  factory AppCard.outlined({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BorderRadius? borderRadius,
    Color? borderColor,
    VoidCallback? onTap,
  }) => AppCard(
    key: key,
    padding: padding,
    margin: margin,
    borderRadius: borderRadius,
    shadow: LPShadows.none,
    border: Border.all(color: borderColor ?? LPColors.border, width: 1),
    onTap: onTap,
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Ensure cards are ALWAYS visible in both modes
    // Use surfaceContainer for cards in dark mode to distinguish from black background
    final defaultBg = isDark
        ? theme.colorScheme.surfaceContainer
        : theme.colorScheme.surface;

    final effectiveBackgroundColor = gradient == null
        ? (backgroundColor ?? defaultBg)
        : null;

    // Appropriate shadows for each mode
    final effectiveShadow =
        shadow ??
        (useGlow
            ? [
                BoxShadow(
                  color: (glowColor ?? theme.colorScheme.primary).withOpacity(
                    isDark ? 0.3 : 0.2,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: isDark ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ]);

    // Visible borders for both modes
    // Dark mode usually needs a subtle border to separate from background if shadow is subtle
    final effectiveBorder =
        border ??
        Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(
            isDark ? 0.5 : 0.3,
          ),
          width: 1,
        );

    Widget content = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
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

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      clipBehavior: clipBehavior,
      child: content,
    );
  }
}

// ═══════════════════════════════════════════
// APP SECTION - Title + Content layout
// ═══════════════════════════════════════════

/// Section with title and optional trailing action
class AppSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsets? padding;
  final double? titleSpacing;

  const AppSection({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.child,
    this.padding,
    this.titleSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: LPText.hMD,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const Gap(height: 4),
                      Text(
                        subtitle!,
                        style: LPText.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const Gap(width: LPSpacing.sm),
                trailing!,
              ],
            ],
          ),
          Gap(height: titleSpacing ?? LPSpacing.sm),
          // Content
          child,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// APP DIVIDER - Consistent dividers
// ═══════════════════════════════════════════

/// Horizontal or vertical divider
class AppDivider extends StatelessWidget {
  final double thickness;
  final Color? color;
  final double? indent;
  final double? endIndent;
  final bool isVertical;
  final double? height;

  const AppDivider({
    super.key,
    this.thickness = 1,
    this.color,
    this.indent,
    this.endIndent,
    this.height,
  }) : isVertical = false;

  const AppDivider.vertical({
    super.key,
    this.thickness = 1,
    this.color,
    this.height = 24,
  }) : isVertical = true,
       indent = null,
       endIndent = null;

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return Container(
        width: thickness,
        height: height,
        color: color ?? Theme.of(context).colorScheme.outlineVariant,
      );
    }

    return Divider(
      thickness: thickness,
      color: color ?? Theme.of(context).colorScheme.outlineVariant,
      indent: indent,
      endIndent: endIndent,
      height: height ?? 1,
    );
  }
}

// ═══════════════════════════════════════════
// APP PILL - Chips, tags, badges
// ═══════════════════════════════════════════

/// Pill/Chip/Tag component
class AppPill extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isSmall;

  const AppPill({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.onTap,
    this.onDelete,
    this.isSmall = false,
  });

  /// Primary colored pill
  factory AppPill.primary({
    required String label,
    IconData? icon,
    VoidCallback? onTap,
    bool isSmall = false,
  }) => AppPill(
    label: label,
    backgroundColor: LPColors.primary,
    textColor: LPColors.textOnPrimary,
    icon: icon,
    onTap: onTap,
    isSmall: isSmall,
  );

  /// Teal/Success colored pill
  factory AppPill.teal({
    required String label,
    IconData? icon,
    VoidCallback? onTap,
    bool isSmall = false,
  }) => AppPill(
    label: label,
    backgroundColor: LPColors.secondary,
    textColor: LPColors.textOnPrimary,
    icon: icon,
    onTap: onTap,
    isSmall: isSmall,
  );

  /// Error/Danger pill
  factory AppPill.error({
    required String label,
    IconData? icon,
    VoidCallback? onTap,
    bool isSmall = false,
  }) => AppPill(
    label: label,
    backgroundColor: LPColors.errorLight,
    textColor: LPColors.error,
    icon: icon,
    onTap: onTap,
    isSmall: isSmall,
  );

  /// Warning pill
  factory AppPill.warning({
    required String label,
    IconData? icon,
    VoidCallback? onTap,
    bool isSmall = false,
  }) => AppPill(
    label: label,
    backgroundColor: LPColors.warningLight,
    textColor: LPColors.warningDark,
    icon: icon,
    onTap: onTap,
    isSmall: isSmall,
  );

  /// Success pill
  factory AppPill.success({
    required String label,
    IconData? icon,
    VoidCallback? onTap,
    bool isSmall = false,
  }) => AppPill(
    label: label,
    backgroundColor: LPColors.successLight,
    textColor: LPColors.successDark,
    icon: icon,
    onTap: onTap,
    isSmall: isSmall,
  );

  /// Info pill
  factory AppPill.info({
    required String label,
    IconData? icon,
    VoidCallback? onTap,
    bool isSmall = false,
  }) => AppPill(
    label: label,
    backgroundColor: LPColors.infoLight,
    textColor: LPColors.infoDark,
    icon: icon,
    onTap: onTap,
    isSmall: isSmall,
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final bgColor =
        backgroundColor ??
        (isDark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surfaceContainerHigh);

    final fgColor =
        textColor ??
        (isDark
            ? theme.colorScheme.onSurfaceVariant
            : theme.colorScheme.onSurfaceVariant);

    final verticalPadding = isSmall ? 4.0 : 6.0;
    final horizontalPadding = isSmall ? 8.0 : 12.0;
    final fontSize = isSmall ? 10.0 : 12.0;
    final iconSize = isSmall ? 12.0 : 14.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20), // Standardize pill radius
          border: isDark
              ? null
              : Border.all(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                  width: 1,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize, color: fgColor),
              SizedBox(width: isSmall ? 4 : 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: fgColor,
              ),
            ),
            if (onDelete != null) ...[
              SizedBox(width: isSmall ? 4 : 6),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.close, size: iconSize, color: fgColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// APP ICON BOX - Icon container
// ═══════════════════════════════════════════

/// Styled icon container
class AppIconBox extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final double size;
  final Color? iconColor;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const AppIconBox({
    super.key,
    this.icon,
    this.child,
    this.size = 44,
    this.iconColor,
    this.backgroundColor,
    this.borderRadius,
  }) : assert(
         icon != null || child != null,
         'Either icon or child must be provided',
       );

  /// Primary colored icon box
  factory AppIconBox.primary({
    IconData? icon,
    Widget? child,
    double size = 44,
  }) => AppIconBox(
    icon: icon,
    child: child,
    size: size,
    iconColor: LPColors.primary,
    backgroundColor: LPColors.primary.withValues(alpha: 0.1),
  );

  /// Teal colored icon box
  factory AppIconBox.teal({IconData? icon, Widget? child, double size = 44}) =>
      AppIconBox(
        icon: icon,
        child: child,
        size: size,
        iconColor: LPColors.secondary,
        backgroundColor: LPColors.secondary.withValues(alpha: 0.1),
      );

  /// Grey/Neutral icon box
  factory AppIconBox.grey({IconData? icon, Widget? child, double size = 44}) =>
      AppIconBox(
        icon: icon,
        child: child,
        size: size,
        iconColor: LPColors.grey500,
        backgroundColor: LPColors.grey100,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveBg =
        backgroundColor ??
        (isDark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surface);

    final effectiveIconColor =
        iconColor ??
        (isDark
            ? theme.colorScheme.onSurfaceVariant
            : theme.colorScheme.onSurfaceVariant);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: isDark
            ? null
            : Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Center(
        child: child ?? Icon(icon, size: size * 0.5, color: effectiveIconColor),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// APP EMPTY STATE - No content placeholder
// ═══════════════════════════════════════════

/// Empty state widget with icon, title, message
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
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
        padding: LPSpacing.page,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIconBox.grey(icon: icon, size: 80),
            Gap.lg,
            Text(title, style: LPText.hMD, textAlign: TextAlign.center),
            if (message != null) ...[
              Gap.sm,
              Text(
                message!,
                style: LPText.caption,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              Gap.lg,
              AppButton.primary(label: actionLabel!, onTap: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// APP LOADING - Loading indicator
// ═══════════════════════════════════════════

/// Loading indicator widget
class AppLoading extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const AppLoading({super.key, this.message, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? LPColors.primary,
              ),
            ),
          ),
          if (message != null) ...[
            Gap.md,
            Text(message!, style: LPText.caption),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// APP TEXT FIELD - Styled inputs
// ═══════════════════════════════════════════

/// Standard text input with consistent design
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final bool enabled;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: LPText.labelMD.copyWith(
              color: isDark
                  ? LPColors.textSecondaryDark
                  : LPColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(height: LPSpacing.xs),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          enabled: enabled,
          style: LPText.bodyMD.copyWith(
            color: isDark ? LPColors.textPrimaryDark : LPColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: LPText.bodyMD.copyWith(
              color: isDark ? LPColors.textTertiaryDark : LPColors.textTertiary,
            ),
            errorText: errorText,
            prefixIcon: prefixIcon != null
                ? IconTheme(
                    data: IconThemeData(
                      color: isDark
                          ? LPColors.textTertiaryDark
                          : LPColors.textTertiary,
                    ),
                    child: prefixIcon!,
                  )
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark ? LPColors.surfaceDark : LPColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: LPRadius.mdBorder,
              borderSide: BorderSide(
                color: isDark ? LPColors.borderDark : LPColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: LPRadius.mdBorder,
              borderSide: BorderSide(
                color: isDark ? LPColors.borderDark : LPColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: LPRadius.mdBorder,
              borderSide: BorderSide(color: LPColors.secondary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: LPRadius.mdBorder,
              borderSide: BorderSide(color: LPColors.coral),
            ),
          ),
        ),
      ],
    );
  }
}
