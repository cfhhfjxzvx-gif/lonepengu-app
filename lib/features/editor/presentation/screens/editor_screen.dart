import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/design/lp_design.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../data/editor_models.dart';
import '../../data/editor_storage.dart';
import '../widgets/editor_canvas.dart';
import '../widgets/inspector_panel.dart';
import '../../data/editor_args.dart';
import '../../../brand_kit/data/brand_kit_storage.dart';
import '../../../brand_kit/domain/brand_kit_model.dart';

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
  BrandKit? _brandKit;

  @override
  void initState() {
    super.initState();
    _loadBrandKit();
    _handleIncomingArgs();
  }

  Future<void> _loadBrandKit() async {
    final brand = await BrandKitStorage.loadBrandKit();
    if (mounted) {
      setState(() => _brandKit = brand);
    }
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
        final preset = args.aspectPreset ?? args.asset?.tempUrl ?? '1:1';
        for (final ratio in EditorAspectRatio.values) {
          if (ratio.displayName == preset) {
            _aspectRatio = ratio;
            break;
          }
        }

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
            scale: 0.8,
          );

          _layers.add(layer);
          _selectedLayerId = id;

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

  void _onLayerScaleRotate(String id, double scale, double rotation) {
    final index = _layers.indexWhere((l) => l.id == id);
    if (index != -1 && !_layers[index].isLocked) {
      setState(() {
        _layers[index] = _layers[index].copyWith(
          scale: scale,
          rotation: rotation,
        );
      });
    }
  }

  Future<void> _onLayerEdit(String id) async {
    final index = _layers.indexWhere((l) => l.id == id);
    if (index == -1) return;

    final layer = _layers[index];
    if (layer.isLocked) return;

    // Handle Text Edit
    if (layer.type == LayerType.text) {
      final controller = TextEditingController(text: layer.text);
      final newText = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Text'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your text here...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            AppButton.primary(
              label: 'Update',
              onTap: () => Navigator.pop(context, controller.text),
              size: ButtonSize.sm,
            ),
          ],
        ),
      );

      if (newText != null && newText.isNotEmpty) {
        setState(() {
          _layers[index] = layer.copyWith(text: newText);
        });
      }
    }
    // Handle Image Edit (Replace)
    else if (layer.type == LayerType.image) {
      // Option to replace image?
      // For now, maybe just show a snackbar or nothing
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
            backgroundColor: LPColors.error,
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
          backgroundColor: success ? LPColors.success : LPColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: LPRadius.smBorder),
        ),
      );
    }
  }

  void _showPreview() {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: AppScaffold(
          appBar: AppBar(
            title: const Text('Post Preview'),
            leading: AppIconButton(
              icon: Icons.close_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: LPSpacing.page,
            child: GridView.count(
              crossAxisCount: kIsWeb ? 2 : 1,
              mainAxisSpacing: LPSpacing.md,
              crossAxisSpacing: LPSpacing.md,
              children: [
                _buildPreviewItem('Instagram Post', EditorAspectRatio.igPost),
                _buildPreviewItem('Story / Reel', EditorAspectRatio.igReel),
                _buildPreviewItem('LinkedIn', EditorAspectRatio.linkedIn),
                _buildPreviewItem('Facebook Post', EditorAspectRatio.fbPost),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewItem(String title, EditorAspectRatio ratio) {
    return Column(
      children: [
        Text(title, style: LPText.hSM),
        const Gap(height: LPSpacing.xs),
        Expanded(
          child: AppCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: LPRadius.card,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 400,
                  height: 400 / ratio.ratio,
                  child: EditorCanvas(
                    layers: _layers,
                    aspectRatio: ratio,
                    selectedLayerId: null,
                    onLayerSelected: (_) {},
                    onLayerDragged: (_, __) {},
                    onLayerScaleRotate: (_, __, ___) {},
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
    return AppScaffold(
      useSafeArea: true,
      appBar: AppBar(
        title: const Text('Post Editor'),
        actions: [
          AppIconButton(icon: Icons.visibility_outlined, onTap: _showPreview),
          const Gap(width: LPSpacing.xs),
          AppIconButton(icon: Icons.save_outlined, onTap: _saveDraft),
          const Gap(width: LPSpacing.xs),
          AppButton.secondary(
            label: 'Export',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export coming soon!')),
            ),
            size: ButtonSize.sm,
          ),
          const Gap(width: LPSpacing.sm),
        ],
      ),
      body: _isInitialLoading
          ? const AppLoading(message: 'Preparing your canvas...')
          : ResponsiveBuilder(
              builder: (context, deviceType) {
                final isMobile = deviceType == DeviceType.mobile;

                if (isMobile) {
                  return Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: LPSpacing.page,
                          child: _buildCanvasArea(),
                        ),
                      ),
                      Expanded(flex: 2, child: _buildInspector(true)),
                    ],
                  );
                }

                final isDark = Theme.of(context).brightness == Brightness.dark;
                final borderColor = isDark
                    ? LPColors.borderDark
                    : LPColors.divider;
                final bgColor = isDark ? LPColors.cardDark : LPColors.surface;

                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: LPSpacing.page,
                        child: _buildCanvasArea(),
                      ),
                    ),
                    Container(
                      width: 350,
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: borderColor)),
                        color: bgColor,
                      ),
                      child: _buildInspector(false),
                    ),
                  ],
                );
              },
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
                padding: const EdgeInsets.only(right: LPSpacing.xs),
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
        const Gap(height: LPSpacing.md),
        // Actual Canvas
        Expanded(
          child: EditorCanvas(
            layers: _layers,
            aspectRatio: _aspectRatio,
            selectedLayerId: _selectedLayerId,
            onLayerSelected: (id) => setState(() => _selectedLayerId = id),
            onLayerDragged: _onLayerDragged,
            onLayerScaleRotate: _onLayerScaleRotate,
            onLayerEdit: _onLayerEdit,
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
      brandKit: _brandKit,
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
