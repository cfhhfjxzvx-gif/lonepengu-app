import 'package:flutter/material.dart';
import '../../data/editor_models.dart';

class TemplatePanel extends StatelessWidget {
  final Function(EditorTemplate template) onSelectTemplate;

  const TemplatePanel({super.key, required this.onSelectTemplate});

  @override
  Widget build(BuildContext context) {
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
      // Add more as needed...
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return InkWell(
          onTap: () => onSelectTemplate(template),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.dashboard_customize_rounded,
                  size: 40,
                  color: Colors.blueGrey,
                ),
                const SizedBox(height: 8),
                Text(
                  template.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
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
