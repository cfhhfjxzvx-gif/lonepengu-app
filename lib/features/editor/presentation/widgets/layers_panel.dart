import 'package:flutter/material.dart';
import '../../data/editor_models.dart';

class LayersPanel extends StatelessWidget {
  final List<EditorLayer> layers;
  final String? selectedLayerId;
  final Function(String layerId) onSelect;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(String layerId) onDelete;
  final Function(String layerId) onToggleLock;

  const LayersPanel({
    super.key,
    required this.layers,
    required this.selectedLayerId,
    required this.onSelect,
    required this.onReorder,
    required this.onDelete,
    required this.onToggleLock,
  });

  @override
  Widget build(BuildContext context) {
    if (layers.isEmpty) {
      return const Center(
        child: Text('No layers yet', style: TextStyle(color: Colors.grey)),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: layers.length,
      onReorder: onReorder,
      itemBuilder: (context, index) {
        final layer = layers[index];
        final isSelected = layer.id == selectedLayerId;

        return ListTile(
          key: ValueKey(layer.id),
          selected: isSelected,
          leading: _buildLayerIcon(layer),
          title: Text(
            layer.type == LayerType.text
                ? (layer.text ?? 'Text')
                : layer.type.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  layer.isLocked ? Icons.lock : Icons.lock_open,
                  size: 20,
                ),
                onPressed: () => onToggleLock(layer.id),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.redAccent,
                ),
                onPressed: () => onDelete(layer.id),
              ),
            ],
          ),
          onTap: () => onSelect(layer.id),
        );
      },
    );
  }

  Widget _buildLayerIcon(EditorLayer layer) {
    IconData icon = Icons.help_outline;
    switch (layer.type) {
      case LayerType.text:
        icon = Icons.text_fields;
        break;
      case LayerType.image:
        icon = Icons.image;
        break;
      case LayerType.shape:
        icon = Icons.category;
        break;
    }
    return Icon(icon, color: Colors.blueGrey);
  }
}
