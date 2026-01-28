import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/lp_design.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/content_models.dart';
import '../../data/draft_storage.dart';

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

    if (_filterMode != null) {
      result = result.where((d) => d.mode == _filterMode).toList();
    }

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((d) {
        return d.promptText.toLowerCase().contains(query) ||
            (d.caption?.toLowerCase().contains(query) ?? false) ||
            d.hashtags.any((h) => h.toLowerCase().contains(query));
      }).toList();
    }

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
          AppButton.custom(
            label: 'Delete',
            onTap: () => Navigator.pop(context, true),
            size: ButtonSize.sm,
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DraftStorage.deleteDraft(id);
      await _loadDrafts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Draft deleted'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: LPRadius.smBorder),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      appBar: AppBar(
        title: const Text('Drafts'),
        leading: AppIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => context.pop(),
        ),
        actions: [
          AppIconButton(
            onTap: () {
              setState(() {
                _sortNewest = !_sortNewest;
                _applyFilters();
              });
            },
            icon: _sortNewest ? Icons.arrow_downward : Icons.arrow_upward,
          ),
          Gap(width: LPSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: LPSpacing.page,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search drafts...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: LPSpacing.md,
                      vertical: LPSpacing.sm,
                    ),
                  ),
                  onChanged: (_) {
                    setState(() => _applyFilters());
                  },
                ),
                const Gap(height: LPSpacing.sm),
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
          Expanded(
            child: _isLoading
                ? const AppLoading()
                : _filteredDrafts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: LPSpacing.page,
                    itemCount: _filteredDrafts.length,
                    itemBuilder: (context, index) {
                      return _buildDraftCard(_filteredDrafts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ContentMode? mode, String label) {
    final isSelected = _filterMode == mode;
    return Padding(
      padding: const EdgeInsets.only(right: LPSpacing.xs),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mode != null) ...[
              Text(mode.icon, style: const TextStyle(fontSize: 12)),
              const Gap(width: LPSpacing.xxs),
            ],
            Text(label),
          ],
        ),
        onSelected: (val) {
          setState(() {
            _filterMode = val ? mode : null;
            _applyFilters();
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          Gap(height: LPSpacing.md),
          Text(
            _searchController.text.isNotEmpty
                ? 'No drafts found'
                : 'No drafts yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(height: LPSpacing.xs),
          Text(
            'Create content in the Content Studio to save drafts',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(height: LPSpacing.lg),
          AppButton.primary(
            onTap: () => context.go(AppRoutes.contentStudio),
            label: 'Create Content',
            icon: Icons.add,
            size: ButtonSize.sm,
          ),
        ],
      ),
    );
  }

  Widget _buildDraftCard(ContentDraft draft) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: LPSpacing.sm),
      onTap: () {
        if (draft.extraData != null) {
          context.push(AppRoutes.editor, extra: draft);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening Studio drafts coming soon!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconBox(
            child: Text(draft.mode.icon, style: const TextStyle(fontSize: 24)),
            backgroundColor: _getModeColor(draft.mode).withValues(alpha: 0.1),
            size: 48,
          ),
          const Gap(width: LPSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.previewText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const Gap(height: LPSpacing.xs),
                Row(
                  children: [
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
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 12),
                      ),
                    Spacer(),
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const Gap(width: LPSpacing.xxs),
                    Text(
                      _formatTime(draft.createdAt),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(width: LPSpacing.xs),
          AppIconButton(
            onTap: () => _deleteDraft(draft.id),
            icon: Icons.delete_outline,
            size: 40,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Color _getModeColor(ContentMode mode) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (mode) {
      case ContentMode.auto:
        return colorScheme.secondary;
      case ContentMode.caption:
        return colorScheme.primary;
      case ContentMode.image:
        return colorScheme.secondary;
      case ContentMode.carousel:
        return colorScheme.tertiary; // Was coral
      case ContentMode.video:
        return colorScheme.tertiaryContainer; // Was accent
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
