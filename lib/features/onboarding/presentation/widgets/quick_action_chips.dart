import 'package:flutter/material.dart';

class QuickActionChipsRow extends StatelessWidget {
  final VoidCallback onNewCaption;
  final VoidCallback onNewCarousel;
  final VoidCallback onSchedule;

  const QuickActionChipsRow({
    super.key,
    required this.onNewCaption,
    required this.onNewCarousel,
    required this.onSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          _ActionPill(
            icon: Icons.edit_note_rounded,
            label: 'New Caption',
            color: Theme.of(context).colorScheme.primary,
            onTap: onNewCaption,
          ),
          _ActionPill(
            icon: Icons.view_carousel_rounded,
            label: 'New Carousel',
            color: Theme.of(context).colorScheme.secondary,
            onTap: onNewCarousel,
          ),
          _ActionPill(
            icon: Icons.calendar_today_rounded,
            label: 'Schedule Post',
            color: Theme.of(context).colorScheme.tertiary,
            onTap: onSchedule,
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionPill> createState() => _ActionPillState();
}

class _ActionPillState extends State<_ActionPill> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHigh
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: theme.colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(isDark ? 0.2 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 20, color: widget.color),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
