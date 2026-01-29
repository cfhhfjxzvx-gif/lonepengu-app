import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/lp_design.dart';
import '../../data/notification_model.dart';
import '../../data/notification_storage.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final data = await NotificationStorage.loadAll();
    if (mounted) {
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _markRead(String id) async {
    await NotificationStorage.markAsRead(id);
    _loadNotifications();
  }

  Future<void> _delete(String id) async {
    await NotificationStorage.deleteNotification(id);
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: AppIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => context.pop(),
        ),
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () async {
                for (var n in _notifications) {
                  if (!n.isRead) await NotificationStorage.markAsRead(n.id);
                }
                _loadNotifications();
              },
              child: const Text('Mark all read'),
            ),
          const Gap(width: LPSpacing.sm),
        ],
      ),
      body: _isLoading
          ? const AppLoading()
          : _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: LPSpacing.page,
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return const AppEmptyState(
      icon: Icons.notifications_none_rounded,
      title: 'No notifications yet',
      message: 'We will notify you here when there is something important.',
    );
  }

  Widget _buildNotificationCard(NotificationModel item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      margin: const EdgeInsets.only(bottom: LPSpacing.sm),
      onTap: () => _markRead(item.id),
      backgroundColor: item.isRead
          ? theme.colorScheme.surface
          : theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.05),
      border: isDark && !item.isRead
          ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3))
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIcon(item.type),
          const Gap(width: LPSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: item.isRead
                              ? FontWeight.w500
                              : FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (!item.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                Gap(height: LPSpacing.xxs),
                Text(
                  item.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: item.isRead
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
                  ),
                ),
                Gap(height: LPSpacing.xs),
                Text(
                  _formatTimestamp(item.timestamp),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onSelected: (val) {
              if (val == 'delete') _delete(item.id);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(NotificationType type) {
    final theme = Theme.of(context);
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.success:
        icon = Icons.check_circle_rounded;
        color = LPColors.success; // Semantic colors often persistent
        break;
      case NotificationType.warning:
        icon = Icons.warning_rounded;
        color = LPColors.warning;
        break;
      case NotificationType.error:
        icon = Icons.error_rounded;
        color = LPColors.error;
        break;
      case NotificationType.info:
        icon = Icons.info_rounded;
        color = theme.colorScheme.primary;
        break;
    }

    return AppIconBox(
      icon: icon,
      iconColor: color,
      backgroundColor: color.withValues(alpha: 0.1),
      size: 40,
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
