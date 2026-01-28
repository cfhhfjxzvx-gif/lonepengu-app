import 'package:lone_pengu/core/design/lp_design.dart';
import 'package:flutter/material.dart';
import '../../data/scheduler_models.dart';
import '../../data/scheduler_storage.dart';
import '../../../content_studio/data/content_models.dart';

/// Queue list widget showing reorderable queue items
class QueueList extends StatefulWidget {
  final VoidCallback? onRefresh;

  const QueueList({super.key, this.onRefresh});

  @override
  State<QueueList> createState() => _QueueListState();
}

class _QueueListState extends State<QueueList> {
  List<QueueItem> _queueItems = [];
  bool _isLoading = true;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    setState(() => _isLoading = true);

    try {
      final items = await SchedulerStorage.loadAllQueueItems();
      final paused = await SchedulerStorage.isQueuePaused();

      if (mounted) {
        setState(() {
          _queueItems = items;
          _isPaused = paused;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Queue controls header
        _buildQueueControls(),
        const SizedBox(height: 8),
        // Queue list
        Expanded(
          child: _queueItems.isEmpty
              ? _buildEmptyState()
              : _buildQueueListView(),
        ),
      ],
    );
  }

  Widget _buildQueueControls() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLow
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Queue status indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isPaused
                  ? theme.colorScheme.error.withOpacity(0.12)
                  : theme.colorScheme.tertiary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isPaused
                      ? Icons.pause_circle_outlined
                      : Icons.play_circle_outlined,
                  size: 16,
                  color: _isPaused
                      ? theme.colorScheme.error
                      : theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  _isPaused ? 'Paused' : 'Active',
                  style: TextStyle(
                    color: _isPaused
                        ? theme.colorScheme.error
                        : theme.colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${_queueItems.length} ${_queueItems.length == 1 ? 'item' : 'items'}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Pause/Resume button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isPaused
                ? ElevatedButton.icon(
                    key: const ValueKey('resume'),
                    onPressed: _handleResumeQueue,
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('Resume'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.tertiary,
                      foregroundColor: theme.colorScheme.onTertiary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                : OutlinedButton.icon(
                    key: const ValueKey('pause'),
                    onPressed: _handlePauseQueue,
                    icon: const Icon(Icons.pause_rounded, size: 18),
                    label: const Text('Pause'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.queue_rounded,
                size: 40,
                color: theme.colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Queue is Empty',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add content to your queue for\nautomatic publishing',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 180,
              child: AppButton.primary(
                label: 'Add Content',
                onTap: _handleAddToQueue,
                icon: Icons.add_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueListView() {
    final theme = Theme.of(context);
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _queueItems.length,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final double scale = Tween<double>(begin: 1, end: 1.02)
                .animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                )
                .value;
            return Transform.scale(
              scale: scale,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(20),
                shadowColor: theme.colorScheme.primary.withOpacity(0.3),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      onReorder: _handleReorder,
      itemBuilder: (context, index) {
        final item = _queueItems[index];
        return _buildQueueItemCard(item, index);
      },
    );
  }

  Widget _buildQueueItemCard(QueueItem item, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final estimatedTime = _getEstimatedPublishTime(index);

    return Container(
      key: ValueKey(item.id),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLow
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Order number with drag handle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Platform icons row
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: item.platforms.map((platform) {
                      return Text(
                        platform.icon,
                        style: const TextStyle(fontSize: 14),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  // Preview text
                  Text(
                    item.displayText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Estimated time
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(
                          0.7,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        estimatedTime,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Column(
              children: [
                // Drag handle
                ReorderableDragStartListener(
                  index: index,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.drag_handle_rounded,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(
                        0.5,
                      ),
                    ),
                  ),
                ),
                // Remove button
                IconButton(
                  onPressed: () => _handleRemoveFromQueue(item),
                  icon: const Icon(Icons.close_rounded),
                  iconSize: 20,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  tooltip: 'Remove from queue',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getEstimatedPublishTime(int index) {
    // Mock: Each item publishes every 2 hours starting from now
    final now = DateTime.now();
    final publishTime = now.add(Duration(hours: (index + 1) * 2));
    return OptimalTimeSuggestion.getDisplayString(publishTime);
  }

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _queueItems.removeAt(oldIndex);
      _queueItems.insert(newIndex, item);
    });

    await SchedulerStorage.reorderQueueItems(_queueItems);
    widget.onRefresh?.call();
  }

  Future<void> _handlePauseQueue() async {
    await SchedulerStorage.setQueuePaused(true);
    setState(() => _isPaused = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Queue paused'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleResumeQueue() async {
    await SchedulerStorage.setQueuePaused(false);
    setState(() => _isPaused = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Queue resumed'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleRemoveFromQueue(QueueItem item) async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove from Queue?'),
        content: const Text(
          'This item will be removed from the publishing queue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SchedulerStorage.deleteQueueItem(item.id);
      _loadQueue();
      widget.onRefresh?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from queue'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleAddToQueue() {
    // TODO: Navigate to content selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add content from Content Studio or Drafts'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
