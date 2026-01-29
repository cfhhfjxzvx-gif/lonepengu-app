import 'package:flutter/material.dart';
import '../../data/editor_models.dart';

class TemplatePanel extends StatelessWidget {
  final Function(EditorTemplate template) onSelectTemplate;

  const TemplatePanel({super.key, required this.onSelectTemplate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 6 static templates for MVP
    final List<EditorTemplate> templates = [
      EditorTemplate(
        id: '1',
        name: 'Minimal Clean',
        layers: [
          EditorLayer(
            id: 't1',
            type: LayerType.text,
            position: const Offset(50, 50),
            text: 'Minimal Quote',
            fontSize: 32,
            color: Colors.black,
          ),
        ],
      ),
      EditorTemplate(
        id: '2',
        name: 'Modern Bold',
        layers: [
          EditorLayer(
            id: 't2',
            type: LayerType.shape,
            position: const Offset(20, 20),
            shapeType: ShapeType.rectangle,
            color: Colors.orange,
          ),
          EditorLayer(
            id: 't3',
            type: LayerType.text,
            position: const Offset(30, 30),
            text: 'Bold Headline',
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
      EditorTemplate(
        id: '3',
        name: 'Dark Elegance',
        layers: [
          EditorLayer(
            id: 't4',
            type: LayerType.text,
            position: const Offset(40, 40),
            text: 'STAY INSPIRED',
            fontSize: 36,
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ],
      ),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return InkWell(
          onTap: () => onSelectTemplate(template),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerLow
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.dashboard_customize_rounded,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    template.name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
