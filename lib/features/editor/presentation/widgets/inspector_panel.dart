import 'package:flutter/material.dart';
import '../../data/editor_models.dart';
import 'add_panel.dart';
import 'template_panel.dart';
import 'style_panel.dart';
import 'layers_panel.dart';

class InspectorPanel extends StatefulWidget {
  final List<EditorLayer> layers;
  final String? selectedLayerId;
  final Function(EditorLayer newLayer) onAddLayer;
  final Function(EditorTemplate template) onApplyTemplate;
  final Function(EditorLayer updatedLayer) onUpdateLayer;
  final Function(int oldIndex, int newIndex) onReorderLayers;
  final Function(String id) onDeleteLayer;
  final Function(String id) onToggleLock;
  final bool isMobile;

  const InspectorPanel({
    super.key,
    required this.layers,
    required this.selectedLayerId,
    required this.onAddLayer,
    required this.onApplyTemplate,
    required this.onUpdateLayer,
    required this.onReorderLayers,
    required this.onDeleteLayer,
    required this.onToggleLock,
    this.isMobile = false,
  });

  @override
  State<InspectorPanel> createState() => _InspectorPanelState();
}

class _InspectorPanelState extends State<InspectorPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: widget.isMobile
            ? null
            : Border(left: BorderSide(color: Colors.grey.shade200)),
        borderRadius: widget.isMobile
            ? const BorderRadius.vertical(top: Radius.circular(20))
            : null,
      ),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(icon: Icon(Icons.add), text: 'Add'),
              Tab(icon: Icon(Icons.dashboard), text: 'Templates'),
              Tab(icon: Icon(Icons.style), text: 'Style'),
              Tab(icon: Icon(Icons.layers), text: 'Layers'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                AddPanel(
                  onAddText: () => widget.onAddLayer(
                    EditorLayer(
                      id: DateTime.now().toString(),
                      type: LayerType.text,
                      position: const Offset(50, 50),
                      text: 'New Text',
                      color: Colors.black,
                    ),
                  ),
                  onAddShape: () => widget.onAddLayer(
                    EditorLayer(
                      id: DateTime.now().toString(),
                      type: LayerType.shape,
                      position: const Offset(50, 50),
                      shapeType: ShapeType.rectangle,
                      color: Colors.blue,
                    ),
                  ),
                  onAddImage: () {
                    // This will be handled in the main screen with ImagePicker logic
                    // so we pass a placeholder or just trigger a callback.
                    // For now, let's assume we'll trigger the main screen's picker.
                    widget.onAddLayer(
                      EditorLayer(
                        id: 'img_${DateTime.now()}',
                        type: LayerType.image,
                        position: const Offset(50, 50),
                      ),
                    );
                  },
                ),
                TemplatePanel(onSelectTemplate: widget.onApplyTemplate),
                StylePanel(
                  selectedLayer: widget.selectedLayerId != null
                      ? widget.layers.firstWhere(
                          (l) => l.id == widget.selectedLayerId,
                        )
                      : null,
                  onUpdateLayer: widget.onUpdateLayer,
                ),
                LayersPanel(
                  layers: widget.layers,
                  selectedLayerId: widget.selectedLayerId,
                  onSelect: (id) => widget.onUpdateLayer(
                    widget.layers.firstWhere((l) => l.id == id),
                  ),
                  onReorder: widget.onReorderLayers,
                  onDelete: widget.onDeleteLayer,
                  onToggleLock: widget.onToggleLock,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
