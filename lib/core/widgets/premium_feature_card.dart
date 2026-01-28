import 'package:flutter/material.dart';

enum PremiumBadgeType { ai, comingSoon, completed, custom }

/// Premium feature card with hover effects and animations
/// Fully theme-aware for dark mode support
class PremiumFeatureCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final String? badgeText;
  final PremiumBadgeType? badgeType;
  final Color? accentColor;
  final bool isHero;
  final String? status; // Added for compatibility with feature widget

  const PremiumFeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.badgeText,
    this.badgeType,
    this.accentColor,
    this.isHero = false,
    this.status,
  });

  @override
  State<PremiumFeatureCard> createState() => _PremiumFeatureCardState();
}

class _PremiumFeatureCardState extends State<PremiumFeatureCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _chevronAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _chevronAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) _controller.reverse();
  }

  void _handleTapCancel() {
    if (widget.onTap != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = widget.accentColor ?? theme.colorScheme.primary;

    // Theme-aware colors
    final cardBgColor = isDark
        ? theme.colorScheme.surfaceContainerLow
        : theme.colorScheme.surface;
    final borderColor = theme.colorScheme.outlineVariant.withOpacity(
      isDark ? (_isHovered ? 0.4 : 0.2) : (_isHovered ? 0.3 : 0.1),
    );

    final textPrimaryColor = theme.colorScheme.onSurface;
    final textSecondaryColor = theme.colorScheme.onSurfaceVariant;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        isDark
                            ? (_isHovered ? 0.3 : 0.15)
                            : (_isHovered ? 0.08 : 0.04),
                      ),
                      blurRadius: isDark ? 16 : 20,
                      offset: const Offset(0, 8),
                    ),
                    if (_isHovered)
                      BoxShadow(
                        color: color.withOpacity(0.1),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      border: Border.all(
                        color: borderColor,
                        width: widget.isHero ? 1.5 : 1.0,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Subtle gradient tint in top-left
                        Positioned(
                          top: -20,
                          left: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  color.withOpacity(isDark ? 0.2 : 0.15),
                                  color.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(widget.isHero ? 20.0 : 16.0),
                          child: Row(
                            children: [
                              // Icon Container
                              _buildIconContainer(color, isDark, theme),
                              const SizedBox(width: 16),
                              // Text content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            widget.title,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: textPrimaryColor,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (widget.badgeText != null) ...[
                                          const SizedBox(width: 8),
                                          _buildBadge(isDark, theme),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.subtitle,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: textSecondaryColor,
                                            fontWeight: FontWeight.w400,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Action Arrow or Status
                              if (widget.status != null)
                                _buildStatus(theme)
                              else
                                _buildActionArrow(color, isDark, theme),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIconContainer(Color color, bool isDark, ThemeData theme) {
    return Container(
      width: widget.isHero ? 56 : 44,
      height: widget.isHero ? 56 : 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(isDark ? 0.3 : 0.2),
            color.withOpacity(isDark ? 0.1 : 0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(widget.icon, color: color, size: widget.isHero ? 28 : 22),
      ),
    );
  }

  Widget _buildBadge(bool isDark, ThemeData theme) {
    Color bg;
    Color text;
    IconData? icon;

    // Default to comingSoon logic if not specified or custom
    final type = widget.badgeType ?? PremiumBadgeType.custom;

    switch (type) {
      case PremiumBadgeType.ai:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.tertiary, theme.colorScheme.primary],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 10,
                color: theme.colorScheme.onPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                widget.badgeText!,
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      case PremiumBadgeType.comingSoon:
        bg = isDark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surfaceContainerHigh;
        text = theme.colorScheme.onSurfaceVariant;
        break;
      case PremiumBadgeType.completed:
        bg = isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50;
        text = isDark ? Colors.green.shade300 : Colors.green.shade700;
        icon = Icons.check_circle_rounded;
        break;
      case PremiumBadgeType.custom:
        bg = theme.colorScheme.secondaryContainer;
        text = theme.colorScheme.secondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: text),
            const SizedBox(width: 4),
          ],
          Text(
            widget.badgeText!,
            style: TextStyle(
              color: text,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        widget.status!,
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildActionArrow(Color color, bool isDark, ThemeData theme) {
    final bgColor = _isHovered
        ? color.withOpacity(0.15)
        : (isDark
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.surfaceContainerHigh); // Approximations

    final iconColor = _isHovered ? color : theme.colorScheme.onSurfaceVariant;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Transform.translate(
        offset: Offset(_chevronAnimation.value, 0),
        child: Icon(Icons.chevron_right_rounded, color: iconColor, size: 20),
      ),
    );
  }
}
