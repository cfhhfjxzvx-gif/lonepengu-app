import 'package:flutter/material.dart';
import '../../data/scheduler_models.dart';
import '../../data/scheduler_storage.dart';
import '../../../content_studio/data/content_models.dart';
import 'schedule_modal.dart';

/// Filter options for scheduled posts list
enum ScheduledFilter { all, today, thisWeek, thisMonth }

extension ScheduledFilterX on ScheduledFilter {
  String get displayName {
    switch (this) {
      case ScheduledFilter.all:
        return 'All';
      case ScheduledFilter.today:
        return 'Today';
      case ScheduledFilter.thisWeek:
        return 'This Week';
      case ScheduledFilter.thisMonth:
        return 'This Month';
    }
  }
}

/// Scheduled posts list widget with filtering
class ScheduledList extends StatefulWidget {
  final VoidCallback? onRefresh;

  const ScheduledList({super.key, this.onRefresh});

  @override
  State<ScheduledList> createState() => _ScheduledListState();
}

class _ScheduledListState extends State<ScheduledList> {
  List<ScheduledPost> _allPosts = [];
  List<ScheduledPost> _filteredPosts = [];
  ScheduledFilter _currentFilter = ScheduledFilter.all;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);

    try {
      final posts = await SchedulerStorage.loadAllScheduledPosts();
      // Sort by scheduled time
      posts.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      if (mounted) {
        setState(() {
          _allPosts = posts;
          _applyFilter();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilter() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfToday = today.add(const Duration(days: 1));
    final endOfWeek = today.add(Duration(days: 7 - now.weekday + 1));
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    switch (_currentFilter) {
      case ScheduledFilter.all:
        _filteredPosts = List.from(_allPosts);
        break;
      case ScheduledFilter.today:
        _filteredPosts = _allPosts
            .where(
              (p) =>
                  p.scheduledAt.isAfter(
                    today.subtract(const Duration(seconds: 1)),
                  ) &&
                  p.scheduledAt.isBefore(endOfToday),
            )
            .toList();
        break;
      case ScheduledFilter.thisWeek:
        _filteredPosts = _allPosts
            .where(
              (p) =>
                  p.scheduledAt.isAfter(
                    today.subtract(const Duration(seconds: 1)),
                  ) &&
                  p.scheduledAt.isBefore(endOfWeek),
            )
            .toList();
        break;
      case ScheduledFilter.thisMonth:
        _filteredPosts = _allPosts
            .where(
              (p) =>
                  p.scheduledAt.isAfter(
                    today.subtract(const Duration(seconds: 1)),
                  ) &&
                  p.scheduledAt.isBefore(endOfMonth),
            )
            .toList();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Filter chips
        _buildFilterChips(),
        const SizedBox(height: 8),
        // Posts list
        Expanded(
          child: _filteredPosts.isEmpty
              ? _buildEmptyState()
              : _buildPostsList(),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: ScheduledFilter.values.map((filter) {
          final isSelected = _currentFilter == filter;
          final count = _getFilterCount(filter);

          return FilterChip(
            selected: isSelected,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(filter.displayName),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.onPrimary.withOpacity(0.2)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            backgroundColor: theme.colorScheme.surfaceContainerHigh,
            selectedColor: theme.colorScheme.primary,
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            checkmarkColor: theme.colorScheme.onPrimary,
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
              ),
            ),
            onSelected: (selected) {
              setState(() {
                _currentFilter = filter;
                _applyFilter();
              });
            },
          );
        }).toList(),
      ),
    );
  }

  int _getFilterCount(ScheduledFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfToday = today.add(const Duration(days: 1));
    final endOfWeek = today.add(Duration(days: 7 - now.weekday + 1));
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    switch (filter) {
      case ScheduledFilter.all:
        return _allPosts.length;
      case ScheduledFilter.today:
        return _allPosts
            .where(
              (p) =>
                  p.scheduledAt.isAfter(
                    today.subtract(const Duration(seconds: 1)),
                  ) &&
                  p.scheduledAt.isBefore(endOfToday),
            )
            .length;
      case ScheduledFilter.thisWeek:
        return _allPosts
            .where(
              (p) =>
                  p.scheduledAt.isAfter(
                    today.subtract(const Duration(seconds: 1)),
                  ) &&
                  p.scheduledAt.isBefore(endOfWeek),
            )
            .length;
      case ScheduledFilter.thisMonth:
        return _allPosts
            .where(
              (p) =>
                  p.scheduledAt.isAfter(
                    today.subtract(const Duration(seconds: 1)),
                  ) &&
                  p.scheduledAt.isBefore(endOfMonth),
            )
            .length;
    }
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
                Icons.event_note_rounded,
                size: 40,
                color: theme.colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Scheduled Posts',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentFilter == ScheduledFilter.all
                  ? 'Schedule your first post to see it here'
                  : 'No posts ${_currentFilter.displayName.toLowerCase()}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredPosts.length,
      itemBuilder: (context, index) {
        return _buildScheduledPostCard(_filteredPosts[index]);
      },
    );
  }

  Widget _buildScheduledPostCard(ScheduledPost post) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with platforms and status
            Row(
              children: [
                // Platform icons
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: post.platforms.map((platform) {
                      final platformColor = _getPlatformColor(platform);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: platformColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: platformColor.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              platform.icon,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              platform.displayName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: platformColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Status pill
                _buildStatusPill(post.status),
              ],
            ),
            const SizedBox(height: 16),
            // Scheduled date & time
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDateTime(post.scheduledAt),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    post.contentType.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Preview text
            Text(
              post.displayText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 8),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (post.status == ScheduleStatus.scheduled) ...[
                  TextButton.icon(
                    onPressed: () => _handleEditSchedule(post),
                    icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                    label: const Text('Edit Schedule'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _handleCancel(post),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ] else ...[
                  TextButton.icon(
                    onPressed: () => _handleDelete(post),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Remove'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurfaceVariant,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(ScheduleStatus status) {
    final theme = Theme.of(context);
    Color bgColor;
    Color textColor;

    switch (status) {
      case ScheduleStatus.scheduled:
        bgColor = theme.colorScheme.primary.withOpacity(0.1);
        textColor = theme.colorScheme.primary;
        break;
      case ScheduleStatus.published:
        bgColor = theme.colorScheme.tertiary.withOpacity(0.1);
        textColor = theme.colorScheme.tertiary;
        break;
      case ScheduleStatus.failed:
        bgColor = theme.colorScheme.error.withOpacity(0.1);
        textColor = theme.colorScheme.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(status.icon, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPlatformColor(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.instagram:
        return const Color(0xFFE4405F);
      case SocialPlatform.facebook:
        return const Color(0xFF1877F2);
      case SocialPlatform.linkedin:
        return const Color(0xFF0A66C2);
      case SocialPlatform.x:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final timeStr = '$displayHour:$minute $period';

    if (date == today) {
      return 'Today, $timeStr';
    } else if (date == tomorrow) {
      return 'Tomorrow, $timeStr';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}, $timeStr';
    }
  }

  Future<void> _handleEditSchedule(ScheduledPost post) async {
    final newDateTime = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScheduleModal(
        initialDateTime: post.scheduledAt,
        title: 'Reschedule Post',
      ),
    );

    if (newDateTime != null && mounted) {
      final updatedPost = post.copyWith(scheduledAt: newDateTime);
      await SchedulerStorage.saveScheduledPost(updatedPost);
      _loadPosts();
      widget.onRefresh?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schedule updated'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleCancel(ScheduledPost post) async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Scheduled Post?'),
        content: const Text('This will remove the post from your schedule.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Cancel Post'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SchedulerStorage.deleteScheduledPost(post.id);
      _loadPosts();
      widget.onRefresh?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scheduled post cancelled'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(ScheduledPost post) async {
    await SchedulerStorage.deleteScheduledPost(post.id);
    _loadPosts();
    widget.onRefresh?.call();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post removed'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
