import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../data/editor_models.dart';
import '../../data/editor_storage.dart';
import '../widgets/editor_canvas.dart';
import '../widgets/inspector_panel.dart';

import '../../data/editor_args.dart';

class EditorScreen extends StatefulWidget {
  final EditorArgs? args;
  const EditorScreen({super.key, this.args});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen>
    with SingleTickerProviderStateMixin {
  List<EditorLayer> _layers = [];
  EditorAspectRatio _aspectRatio = EditorAspectRatio.igPost;
  String? _selectedLayerId;
  final ImagePicker _picker = ImagePicker();
  bool _isInitialLoading = false;

  @override
  void initState() {
    super.initState();
    _handleIncomingArgs();
  }

  Future<void> _handleIncomingArgs() async {
    final args = widget.args;
    if (args == null) return;

    setState(() => _isInitialLoading = true);

    try {
      if (args.draft != null) {
        final state = EditorStorage.loadProjectFromDraft(args.draft!);
        if (state != null) {
          _layers = state.layers;
          _aspectRatio = state.aspectRatio;
        }
      } else if (args.asset != null || args.imageBytes != null) {
        // Auto-detect aspect ratio if provided
        final preset = args.aspectPreset ?? args.asset?.tempUrl ?? '1:1';
        for (final ratio in EditorAspectRatio.values) {
          if (ratio.displayName == preset) {
            _aspectRatio = ratio;
            break;
          }
        }

        // Auto-create image layer from generated asset or bytes
        final hasImage =
            args.imageBytes != null ||
            args.asset?.bytes != null ||
            args.asset?.tempUrl != null;
        if (hasImage) {
          final id = 'gen_img_${DateTime.now().millisecondsSinceEpoch}';
          final layer = EditorLayer(
            id: id,
            type: LayerType.image,
            position: const Offset(50, 50),
            imageBytes: args.imageBytes ?? args.asset?.bytes,
            imageUrl: args.asset?.tempUrl,
            imagePath: args.asset?.filePath,
            scale: 0.8, // Slightly smaller to anim in
          );

          _layers.add(layer);
          _selectedLayerId = id;

          // Simple animation effect: scale up to 1.0 after small delay
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                final idx = _layers.indexWhere((l) => l.id == id);
                if (idx != -1) {
                  _layers[idx] = _layers[idx].copyWith(scale: 1.0);
                }
              });
            }
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isInitialLoading = false);
      }
    }
  }

  void _addLayer(EditorLayer layer) {
    setState(() {
      _layers.add(layer);
      _selectedLayerId = layer.id;
    });
  }

  void _updateLayer(EditorLayer updatedLayer) {
    setState(() {
      final index = _layers.indexWhere((l) => l.id == updatedLayer.id);
      if (index != -1) {
        _layers[index] = updatedLayer;
      }
    });
  }

  void _onLayerDragged(String id, Offset delta) {
    final index = _layers.indexWhere((l) => l.id == id);
    if (index != -1 && !_layers[index].isLocked) {
      setState(() {
        _layers[index].position += delta;
      });
    }
  }

  Future<void> _pickImageLayer() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        _addLayer(
          EditorLayer(
            id: 'img_${DateTime.now().millisecondsSinceEpoch}',
            type: LayerType.image,
            position: const Offset(100, 100),
            imageBytes: bytes,
          ),
        );
      } else {
        _addLayer(
          EditorLayer(
            id: 'img_${DateTime.now().millisecondsSinceEpoch}',
            type: LayerType.image,
            position: const Offset(100, 100),
            imagePath: image.path,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveDraft() async {
    final success = await EditorStorage.saveEditorProject(
      EditorProjectState(layers: _layers, aspectRatio: _aspectRatio),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Draft saved successfully!' : 'Failed to save draft',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showPreview() {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: AppBackground(
          child: Column(
            children: [
              AppBar(
                title: const Text('Post Preview'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    crossAxisCount: kIsWeb ? 2 : 1,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildPreviewItem(
                        'Instagram Post',
                        EditorAspectRatio.igPost,
                      ),
                      _buildPreviewItem(
                        'Story / Reel',
                        EditorAspectRatio.igReel,
                      ),
                      _buildPreviewItem('LinkedIn', EditorAspectRatio.linkedIn),
                      _buildPreviewItem(
                        'Facebook House',
                        EditorAspectRatio.fbPost,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewItem(String title, EditorAspectRatio ratio) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 400, // Reference size for preview scaling
                  height: 400 / ratio.ratio,
                  child: EditorCanvas(
                    layers: _layers,
                    aspectRatio: ratio,
                    selectedLayerId: null,
                    onLayerSelected: (_) {},
                    onLayerDragged: (_, __) {},
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Post Editor'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showPreview,
            icon: const Icon(Icons.visibility_outlined),
            tooltip: 'Preview',
          ),
          IconButton(
            onPressed: _saveDraft,
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save Draft',
          ),
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export coming soon!')),
            ),
            child: const Text('Export'),
          ),
        ],
      ),
      body: _isInitialLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Preparing your canvas...'),
                ],
              ),
            )
          : AppBackground(
              child: ResponsiveBuilder(
                builder: (context, deviceType) {
                  final isMobile = deviceType == DeviceType.mobile;

                  if (isMobile) {
                    return Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: _buildCanvasArea(),
                          ),
                        ),
                        Expanded(flex: 2, child: _buildInspector(true)),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: _buildCanvasArea(),
                        ),
                      ),
                      SizedBox(width: 350, child: _buildInspector(false)),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildCanvasArea() {
    return Column(
      children: [
        // Aspect Ratio Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: EditorAspectRatio.values.map((ratio) {
              final isSelected = _aspectRatio == ratio;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(ratio.displayName),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _aspectRatio = ratio);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Actual Canvas
        Expanded(
          child: EditorCanvas(
            layers: _layers,
            aspectRatio: _aspectRatio,
            selectedLayerId: _selectedLayerId,
            onLayerSelected: (id) => setState(() => _selectedLayerId = id),
            onLayerDragged: _onLayerDragged,
          ),
        ),
      ],
    );
  }

  Widget _buildInspector(bool isMobile) {
    return InspectorPanel(
      layers: _layers,
      selectedLayerId: _selectedLayerId,
      isMobile: isMobile,
      onAddLayer: (layer) {
        if (layer.type == LayerType.image) {
          _pickImageLayer();
        } else {
          _addLayer(layer);
        }
      },
      onApplyTemplate: (template) {
        setState(() {
          _layers = List.from(template.layers);
          _aspectRatio = template.aspectRatio;
          _selectedLayerId = null;
        });
      },
      onUpdateLayer: _updateLayer,
      onReorderLayers: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = _layers.removeAt(oldIndex);
          _layers.insert(newIndex, item);
        });
      },
      onDeleteLayer: (id) {
        setState(() {
          _layers.removeWhere((l) => l.id == id);
          if (_selectedLayerId == id) _selectedLayerId = null;
        });
      },
      onToggleLock: (id) {
        final index = _layers.indexWhere((l) => l.id == id);
        if (index != -1) {
          setState(() {
            _layers[index] = _layers[index].copyWith(
              isLocked: !_layers[index].isLocked,
            );
          });
        }
      },
    );
  }
}
