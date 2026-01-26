import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class PremiumFeatureCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? status;
  final String? badge;
  final bool isHero;

  const PremiumFeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.status,
    this.badge,
    this.isHero = false,
  });

  @override
  State<PremiumFeatureCard> createState() => _PremiumFeatureCardState();
}

class _PremiumFeatureCardState extends State<PremiumFeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onTap != null && widget.status == null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: isInteractive
            ? (_) => setState(() => _isHovered = true)
            : null,
        onTapUp: isInteractive
            ? (_) => setState(() => _isHovered = false)
            : null,
        onTapCancel: isInteractive
            ? () => setState(() => _isHovered = false)
            : null,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 0.98 : 1.0,
          duration: AppConstants.shortDuration,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(widget.isHero ? 20 : 16),
            decoration: BoxDecoration(
              color: AppColors.iceWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: widget.isHero
                    ? widget.color.withValues(alpha: 0.2)
                    : AppColors.grey200,
                width: widget.isHero ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(
                    alpha: _isHovered ? 0.08 : 0.04,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildIconContainer(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.penguinBlack,
                                ),
                          ),
                          if (widget.badge != null) ...[
                            const SizedBox(width: 8),
                            _buildBadge(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTrailingAction(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer() {
    return Container(
      width: widget.isHero ? 56 : 48,
      height: widget.isHero ? 56 : 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.color.withValues(alpha: 0.15),
            widget.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Icon(
          widget.icon,
          color: widget.color,
          size: widget.isHero ? 28 : 24,
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.frostPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        widget.badge!.toUpperCase(),
        style: const TextStyle(
          color: AppColors.frostPurple,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildTrailingAction() {
    if (widget.status != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          widget.status!,
          style: TextStyle(
            color: AppColors.grey500,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return Icon(
      Icons.chevron_right_rounded,
      color: AppColors.grey300,
      size: 24,
    );
  }
}
