import 'package:flutter/material.dart';
import '../../data/scheduler_models.dart';
import '../../data/scheduler_storage.dart';
import '../../../content_studio/data/content_models.dart';

/// Calendar view widget for the scheduler
class CalendarView extends StatefulWidget {
  final Function(DateTime date)? onDateTapped;
  final VoidCallback? onRefresh;

  const CalendarView({super.key, this.onDateTapped, this.onRefresh});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;
  Map<DateTime, List<ScheduledPost>> _postsMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _selectedDate = now;
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);

    try {
      final posts = await SchedulerStorage.loadAllScheduledPosts();
      final Map<DateTime, List<ScheduledPost>> map = {};

      for (final post in posts) {
        final dateKey = DateTime(
          post.scheduledAt.year,
          post.scheduledAt.month,
          post.scheduledAt.day,
        );
        if (map[dateKey] == null) {
          map[dateKey] = [];
        }
        map[dateKey]!.add(post);
      }

      if (mounted) {
        setState(() {
          _postsMap = map;
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
    return Column(
      children: [
        // Month navigation header
        _buildMonthHeader(),
        const SizedBox(height: 8),
        // Weekday labels
        _buildWeekdayLabels(),
        const SizedBox(height: 4),
        // Calendar grid
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildCalendarGrid(),
        ),
      ],
    );
  }

  Widget _buildMonthHeader() {
    final theme = Theme.of(context);
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month - 1,
                  1,
                );
              });
            },
            icon: const Icon(Icons.chevron_left_rounded),
            color: theme.colorScheme.primary,
          ),
          Text(
            '${months[_currentMonth.month - 1]} ${_currentMonth.year}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month + 1,
                  1,
                );
              });
            },
            icon: const Icon(Icons.chevron_right_rounded),
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    final theme = Theme.of(context);
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final daysInMonth = DateTime(
          _currentMonth.year,
          _currentMonth.month + 1,
          0,
        ).day;

        // Get the weekday of the first day (0 = Monday in our calendar)
        int firstWeekday = _currentMonth.weekday - 1;

        final cellWidth = (constraints.maxWidth - 16) / 7;
        // Calculate appropriate cell height to avoid overflow
        final totalRows = ((firstWeekday + daysInMonth) / 7).ceil();
        final availableHeight = constraints.maxHeight;
        final cellHeight = (availableHeight / totalRows).clamp(40.0, 64.0);

        final days = <Widget>[];

        // Add empty cells for days before the first of the month
        for (int i = 0; i < firstWeekday; i++) {
          days.add(SizedBox(width: cellWidth, height: cellHeight));
        }

        // Add day cells
        for (int day = 1; day <= daysInMonth; day++) {
          final date = DateTime(_currentMonth.year, _currentMonth.month, day);
          final dateKey = DateTime(date.year, date.month, date.day);
          final posts = _postsMap[dateKey] ?? [];
          final isToday = _isToday(date);
          final isSelected = _isSameDay(date, _selectedDate);

          days.add(
            _buildDayCell(
              date: date,
              posts: posts,
              isToday: isToday,
              isSelected: isSelected,
              cellWidth: cellWidth,
              cellHeight: cellHeight,
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(children: days),
          ),
        );
      },
    );
  }

  Widget _buildDayCell({
    required DateTime date,
    required List<ScheduledPost> posts,
    required bool isToday,
    required bool isSelected,
    required double cellWidth,
    required double cellHeight,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedDate = date);
        if (posts.isNotEmpty) {
          _showPostsBottomSheet(date, posts);
        }
        widget.onDateTapped?.call(date);
      },
      child: Container(
        width: cellWidth,
        height: cellHeight,
        padding: const EdgeInsets.all(2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.12)
                : isToday
                ? theme.colorScheme.tertiary.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isToday
                ? Border.all(color: theme.colorScheme.tertiary, width: 2)
                : isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isToday || isSelected
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: isToday
                      ? theme.colorScheme.tertiary
                      : isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
              if (posts.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildPostIndicator(posts),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostIndicator(List<ScheduledPost> posts) {
    final theme = Theme.of(context);
    if (posts.length <= 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: posts.map((post) {
          Color dotColor;
          switch (post.status) {
            case ScheduleStatus.scheduled:
              dotColor = theme.colorScheme.primary;
              break;
            case ScheduleStatus.published:
              dotColor = theme.colorScheme.tertiary;
              break;
            case ScheduleStatus.failed:
              dotColor = theme.colorScheme.error;
              break;
          }
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.surface, width: 0.5),
            ),
          );
        }).toList(),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${posts.length}',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  void _showPostsBottomSheet(DateTime date, List<ScheduledPost> posts) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        _formatDateTitle(date),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${posts.length} ${posts.length == 1 ? 'post' : 'posts'}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                // Posts list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return _buildScheduledPostCard(posts[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).then((_) {
      _loadPosts();
      widget.onRefresh?.call();
    });
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
            // Header row
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
                        child: Text(
                          platform.icon,
                          style: const TextStyle(fontSize: 14),
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
            // Content info
            Row(
              children: [
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
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(post.scheduledAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
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
                TextButton.icon(
                  onPressed: () => _handleEditPost(post),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
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
                  onPressed: () => _handleDeletePost(post),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
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
        bgColor = theme.colorScheme.primary.withOpacity(0.12);
        textColor = theme.colorScheme.primary;
        break;
      case ScheduleStatus.published:
        bgColor = theme.colorScheme.tertiary.withOpacity(0.12);
        textColor = theme.colorScheme.tertiary;
        break;
      case ScheduleStatus.failed:
        bgColor = theme.colorScheme.error.withOpacity(0.12);
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
      child: Text(
        status.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
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

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateTitle(DateTime date) {
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
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Future<void> _handleEditPost(ScheduledPost post) async {
    Navigator.pop(context);
    // TODO: Navigate to edit screen or show edit modal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleDeletePost(ScheduledPost post) async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Scheduled Post?'),
        content: const Text('This action cannot be undone.'),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SchedulerStorage.deleteScheduledPost(post.id);
      if (mounted) {
        Navigator.pop(context);
        _loadPosts();
        widget.onRefresh?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
