import 'package:flutter/material.dart';

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
            icon: Icons.text_fields_rounded,
            label: 'Add Text',
            onTap: onAddText,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildAddButton(
            icon: Icons.category_rounded,
            label: 'Add Shape',
            onTap: onAddShape,
            color: Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildAddButton(
            icon: Icons.image_rounded,
            label: 'Add Image',
            onTap: onAddImage,
            color: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
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
