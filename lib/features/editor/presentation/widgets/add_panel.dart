import 'package:flutter/material.dart';
import '../../../../core/design/lp_design.dart';

/// Add panel for editor
/// Theme-aware: adapts to light/dark mode
class AddPanel extends StatelessWidget {
  final VoidCallback onAddText;
  final VoidCallback onAddShape;
  final VoidCallback onAddImage;

  const AddPanel({
    super.key,
    required this.onAddText,
    required this.onAddShape,
    required this.onAddImage,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAddButton(
            context: context,
            icon: Icons.text_fields_rounded,
            label: 'Add Text',
            onTap: onAddText,
            accentColor: LPColors.primary,
          ),
          const SizedBox(height: 12),
          _buildAddButton(
            context: context,
            icon: Icons.category_rounded,
            label: 'Add Shape',
            onTap: onAddShape,
            accentColor: LPColors.accent,
          ),
          const SizedBox(height: 12),
          _buildAddButton(
            context: context,
            icon: Icons.image_rounded,
            label: 'Add Image',
            onTap: onAddImage,
            accentColor: LPColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color accentColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme-aware background colors
    final bgColor = isDark
        ? accentColor.withValues(alpha: 0.15)
        : accentColor.withValues(alpha: 0.1);
    final borderColor = isDark
        ? accentColor.withValues(alpha: 0.4)
        : accentColor.withValues(alpha: 0.3);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: accentColor, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
