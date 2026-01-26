import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../data/content_models.dart';
import '../../data/draft_storage.dart';

import '../../../../core/widgets/app_background.dart';

class DraftsScreen extends StatefulWidget {
  const DraftsScreen({super.key});

  @override
  State<DraftsScreen> createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen> {
  final _searchController = TextEditingController();
  List<ContentDraft> _allDrafts = [];
  List<ContentDraft> _filteredDrafts = [];
  ContentMode? _filterMode;
  bool _isLoading = true;
  bool _sortNewest = true;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDrafts() async {
    setState(() => _isLoading = true);
    final drafts = await DraftStorage.loadAllDrafts();
    if (mounted) {
      setState(() {
        _allDrafts = drafts;
        _applyFilters();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<ContentDraft> result = List.from(_allDrafts);

    // Filter by mode
    if (_filterMode != null) {
      result = result.where((d) => d.mode == _filterMode).toList();
    }

    // Filter by search
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((d) {
        return d.promptText.toLowerCase().contains(query) ||
            (d.caption?.toLowerCase().contains(query) ?? false) ||
            d.hashtags.any((h) => h.toLowerCase().contains(query));
      }).toList();
    }

    // Sort
    result.sort(
      (a, b) => _sortNewest
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt),
    );

    _filteredDrafts = result;
  }

  Future<void> _deleteDraft(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Draft?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.sunsetCoral),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DraftStorage.deleteDraft(id);
      await _loadDrafts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Draft deleted'),
            backgroundColor: AppColors.grey600,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.iceWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.penguinBlack,
        ),
        title: Text(
          'Drafts',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          // Sort toggle
          IconButton(
            onPressed: () {
              setState(() {
                _sortNewest = !_sortNewest;
                _applyFilters();
              });
            },
            icon: Icon(
              _sortNewest ? Icons.arrow_downward : Icons.arrow_upward,
              size: 20,
            ),
            color: AppColors.grey600,
            tooltip: _sortNewest ? 'Newest first' : 'Oldest first',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AppBackground(
        useSafeArea: false,
        child: ResponsiveBuilder(
          builder: (context, deviceType) {
            return Column(
              children: [
                // Search and filters
                Container(
                  color: AppColors.iceWhite,
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  child: Column(
                    children: [
                      // Search bar
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search drafts...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: AppColors.grey100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (_) {
                          setState(() => _applyFilters());
                        },
                      ),
                      const SizedBox(height: 12),
                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(null, 'All'),
                            ...ContentMode.values.map((mode) {
                              return _buildFilterChip(mode, mode.displayName);
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Drafts list
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredDrafts.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppConstants.spacingMd),
                          itemCount: _filteredDrafts.length,
                          itemBuilder: (context, index) {
                            return _buildDraftCard(_filteredDrafts[index]);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(ContentMode? mode, String label) {
    final isSelected = _filterMode == mode;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filterMode = mode;
            _applyFilters();
          });
        },
        child: AnimatedContainer(
          duration: AppConstants.shortDuration,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.arcticBlue : AppColors.grey100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (mode != null) ...[
                Text(mode.icon, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.iceWhite : AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: AppColors.grey300),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'No drafts found'
                : 'No drafts yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.grey500),
          ),
          const SizedBox(height: 8),
          Text(
            'Create content in the Content Studio to save drafts',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.grey400),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go(AppRoutes.contentStudio),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Content'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.arcticBlue,
              foregroundColor: AppColors.iceWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftCard(ContentDraft draft) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.iceWhite,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.grey200),
      ),
      child: InkWell(
        onTap: () {
          if (draft.extraData != null) {
            context.push(AppRoutes.editor, extra: draft);
          } else {
            // TODO: Open draft in studio
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Opening Studio drafts coming soon!'),
                backgroundColor: AppColors.frostPurple,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getModeColor(draft.mode).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    draft.mode.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Preview text
                    Text(
                      draft.previewText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Metadata row
                    Row(
                      children: [
                        // Platforms
                        ...draft.platforms.take(3).map((p) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              p.icon,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }),
                        if (draft.platforms.length > 3)
                          Text(
                            '+${draft.platforms.length - 3}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.grey500),
                          ),
                        const Spacer(),
                        // Time
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(draft.createdAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.grey500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Delete button
              IconButton(
                onPressed: () => _deleteDraft(draft.id),
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.grey400,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getModeColor(ContentMode mode) {
    switch (mode) {
      case ContentMode.auto:
        return AppColors.auroraTeal;
      case ContentMode.caption:
        return AppColors.arcticBlue;
      case ContentMode.image:
        return AppColors.auroraTeal;
      case ContentMode.carousel:
        return AppColors.sunsetCoral;
      case ContentMode.video:
        return AppColors.frostPurple;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
