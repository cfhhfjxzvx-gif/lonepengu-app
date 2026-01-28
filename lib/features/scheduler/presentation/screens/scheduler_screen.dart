import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/lp_design.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/scheduler_models.dart';
import '../../data/scheduler_storage.dart';
import '../../../content_studio/data/content_models.dart';
import '../widgets/calendar_view.dart';
import '../widgets/queue_list.dart';
import '../widgets/scheduled_list.dart';
import '../widgets/schedule_modal.dart';

/// Main Scheduler screen with tabs for Calendar, Queue, and Scheduled posts
class SchedulerScreen extends StatefulWidget {
  final ScheduleArgs? args;

  const SchedulerScreen({super.key, this.args});

  @override
  State<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  // Stats for display
  int _scheduledCount = 0;
  int _queueCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadStats();

    // Auto-open scheduling modal if args are provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.args != null && widget.args!.contentId != null) {
        _openScheduleModal();
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() => _currentTabIndex = _tabController.index);
    }
  }

  Future<void> _loadStats() async {
    try {
      final posts = await SchedulerStorage.loadAllScheduledPosts();
      final queue = await SchedulerStorage.loadAllQueueItems();

      if (mounted) {
        setState(() {
          _scheduledCount = posts
              .where((p) => p.status == ScheduleStatus.scheduled)
              .length;
          _queueCount = queue.length;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _openScheduleModal() async {
    final DateTime? selectedTime = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScheduleModal(
        title: 'Schedule Content',
        platforms: widget.args?.platforms,
        initialDateTime: widget.args?.suggestedTime,
      ),
    );

    if (selectedTime != null && mounted) {
      final post = ScheduledPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        contentId: widget.args?.contentId,
        contentType: widget.args?.contentType ?? ContentMode.caption,
        platforms: widget.args?.platforms ?? [],
        scheduledAt: selectedTime,
        status: ScheduleStatus.scheduled,
        createdAt: DateTime.now(),
        caption: widget.args?.caption,
        previewText: widget.args?.previewText,
      );

      await SchedulerStorage.saveScheduledPost(post);
      _loadStats();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Post scheduled for ${OptimalTimeSuggestion.getDisplayString(selectedTime)}',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: LPRadius.smBorder),
          action: SnackBarAction(
            label: 'View',
            textColor: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              _tabController.animateTo(2);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      useSafeArea: true,
      appBar: AppBar(
        title: const Text('Scheduler'),
        leading: AppIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => context.pop(),
        ),
        actions: [
          Stack(
            children: [
              AppIconButton(
                icon: Icons.queue_rounded,
                onTap: () => _tabController.animateTo(1),
                color: _currentTabIndex == 1
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              if (_queueCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_queueCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const Gap(width: LPSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(theme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const ClampingScrollPhysics(),
              children: [
                CalendarView(onRefresh: _loadStats),
                QueueList(onRefresh: _loadStats),
                ScheduledList(onRefresh: _loadStats),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleCreateSchedule,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Schedule',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: LPSpacing.page,
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: theme.textTheme.labelMedium,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_month_rounded, size: 16),
                const Gap(width: 4),
                const Text('Calendar'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.queue_rounded, size: 16),
                const Gap(width: 4),
                const Text('Queue'),
                if (_queueCount > 0) ...[
                  const Gap(width: 4),
                  _buildCountBadge(theme, _queueCount, _currentTabIndex == 1),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event_note_rounded, size: 16),
                const Gap(width: 4),
                const Text('Scheduled'),
                if (_scheduledCount > 0) ...[
                  const Gap(width: 4),
                  _buildCountBadge(
                    theme,
                    _scheduledCount,
                    _currentTabIndex == 2,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountBadge(ThemeData theme, int count, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.12)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  void _handleCreateSchedule() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQuickScheduleSheet(),
    );
  }

  Widget _buildQuickScheduleSheet() {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      'Schedule Content',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    AppIconButton(
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildQuickActionCard(
                      context,
                      icon: Icons.auto_awesome_rounded,
                      title: 'From Content Studio',
                      subtitle: 'Create and schedule new content',
                      color: theme.colorScheme.primary,
                      onTap: () {
                        Navigator.pop(context);
                        context.push(AppRoutes.contentStudio);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActionCard(
                      context,
                      icon: Icons.drafts_rounded,
                      title: 'From Drafts',
                      subtitle: 'Schedule your saved drafts',
                      color: theme.colorScheme.secondary,
                      onTap: () {
                        Navigator.pop(context);
                        context.push(AppRoutes.drafts);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActionCard(
                      context,
                      icon: Icons.queue_play_next_rounded,
                      title: 'Add to Queue',
                      subtitle: 'Auto-publish at optimal times',
                      color: theme.colorScheme.tertiary,
                      onTap: () {
                        Navigator.pop(context);
                        _handleAddToQueue();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActionCard(
                      context,
                      icon: Icons.edit_calendar_rounded,
                      title: 'Quick Schedule',
                      subtitle: 'Create a quick text post',
                      color: theme.colorScheme.error,
                      onTap: () {
                        Navigator.pop(context);
                        _handleQuickSchedule();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Gap(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ],
      ),
    );
  }

  void _handleAddToQueue() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create content in Content Studio and add to queue'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleQuickSchedule() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _QuickScheduleDialog(),
    );

    if (result != null && mounted) {
      final platforms = result['platforms'] as List<SocialPlatform>;
      final caption = result['caption'] as String;

      final DateTime? selectedTime = await showModalBottomSheet<DateTime>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) =>
            ScheduleModal(title: 'Schedule Post', platforms: platforms),
      );

      if (selectedTime != null && mounted) {
        final post = ScheduledPost(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          contentType: ContentMode.caption,
          platforms: platforms,
          scheduledAt: selectedTime,
          status: ScheduleStatus.scheduled,
          createdAt: DateTime.now(),
          caption: caption,
          previewText: caption,
        );

        await SchedulerStorage.saveScheduledPost(post);
        _loadStats();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Post scheduled for ${OptimalTimeSuggestion.getDisplayString(selectedTime)}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _QuickScheduleDialog extends StatefulWidget {
  @override
  State<_QuickScheduleDialog> createState() => _QuickScheduleDialogState();
}

class _QuickScheduleDialogState extends State<_QuickScheduleDialog> {
  final _captionController = TextEditingController();
  final Set<SocialPlatform> _selectedPlatforms = {SocialPlatform.instagram};

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Quick Post'),
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _captionController,
              maxLines: 4,
              maxLength: 500,
              style: theme.textTheme.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'Write your post caption...',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Platforms',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SocialPlatform.values.map((platform) {
                final isSelected = _selectedPlatforms.contains(platform);
                return FilterChip(
                  selected: isSelected,
                  label: Text('${platform.icon} ${platform.displayName}'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedPlatforms.add(platform);
                      } else {
                        _selectedPlatforms.remove(platform);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        SizedBox(
          width: 100,
          child: AppButton.primary(
            label: 'Continue',
            onTap:
                _selectedPlatforms.isNotEmpty &&
                    _captionController.text.isNotEmpty
                ? () {
                    Navigator.pop(context, {
                      'platforms': _selectedPlatforms.toList(),
                      'caption': _captionController.text,
                    });
                  }
                : null,
            size: ButtonSize.sm,
          ),
        ),
      ],
    );
  }
}
