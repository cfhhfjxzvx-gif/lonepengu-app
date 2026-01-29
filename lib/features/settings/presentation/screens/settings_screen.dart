import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/lp_design.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../data/settings_storage.dart';

/// Settings & Account screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notification preferences
  bool _postReminders = true;
  bool _scheduledAlerts = true;
  bool _weeklySummary = true;

  // Theme preference
  String _themeMode = 'light';

  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);

    try {
      final postReminders = await SettingsStorage.getPostReminders();
      final scheduledAlerts = await SettingsStorage.getScheduledAlerts();
      final weeklySummary = await SettingsStorage.getWeeklySummary();
      final themeMode = await SettingsStorage.getThemeMode();

      if (mounted) {
        setState(() {
          _postReminders = postReminders;
          _scheduledAlerts = scheduledAlerts;
          _weeklySummary = weeklySummary;
          _themeMode = themeMode;
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
    return AppScaffold(
      useSafeArea: true,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: AppIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const AppLoading()
          : AppPage(
              child: AppMaxWidth(
                maxWidth: 600,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Account Info
                    _buildAccountInfoSection(),
                    Gap.lg,

                    // Appearance (Redesigned)
                    _buildAppearanceSection(),
                    Gap.lg,

                    // Connected Accounts
                    _buildConnectedAccountsSection(),
                    Gap.lg,

                    // Notifications
                    _buildNotificationsSection(),
                    Gap.lg,

                    // App Info
                    _buildAppInfoSection(),
                    Gap.lg,

                    // Logout
                    _buildLogoutSection(),
                    Gap.xxl,
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAccountInfoSection() {
    final theme = Theme.of(context);
    return AppCard(
      child: Row(
        children: [
          // Avatar
          AppIconBox(
            icon: Icons.person_rounded,
            size: 56,
            iconColor: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
          Gap.md,
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LonePengu User', style: theme.textTheme.titleMedium),
                Gap.xxs,
                Text(
                  'user@lonepengu.com',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Pro badge
          AppPill(
            label: 'PRO',
            backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
            textColor: theme.colorScheme.secondary,
            isSmall: true,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedAccountsSection() {
    final theme = Theme.of(context);
    return AppCard(
      onTap: () => context.push(AppRoutes.accounts),
      child: Row(
        children: [
          AppIconBox(
            icon: Icons.link_rounded,
            iconColor: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
          Gap.md,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Connected Accounts', style: theme.textTheme.titleSmall),
                Gap.xxs,
                Text(
                  'Manage your social media connections',
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
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    final theme = Theme.of(context);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: LPSpacing.card,
            child: Text('Notifications', style: theme.textTheme.titleSmall),
          ),
          _buildToggleTile(
            title: 'Post Reminders',
            subtitle: 'Get reminded to create content',
            value: _postReminders,
            onChanged: (value) async {
              setState(() => _postReminders = value);
              await SettingsStorage.setPostReminders(value);
            },
          ),
          _buildToggleTile(
            title: 'Scheduled Post Alerts',
            subtitle: 'Notifications when posts are published',
            value: _scheduledAlerts,
            onChanged: (value) async {
              setState(() => _scheduledAlerts = value);
              await SettingsStorage.setScheduledAlerts(value);
            },
          ),
          _buildToggleTile(
            title: 'Weekly Performance Summary',
            subtitle: 'Weekly digest of your analytics',
            value: _weeklySummary,
            onChanged: (value) async {
              setState(() => _weeklySummary = value);
              await SettingsStorage.setWeeklySummary(value);
            },
          ),
          Gap.sm,
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildAppearanceSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: LPSpacing.xs,
            bottom: LPSpacing.sm,
          ),
          child: Text('Appearance', style: theme.textTheme.titleSmall),
        ),
        Row(
          children: [
            Expanded(
              child: _buildThemeCard(
                'Light',
                Icons.light_mode_rounded,
                'light',
                LPColors.coral,
                ThemeMode.light,
              ),
            ),
            Gap.md,
            Expanded(
              child: _buildThemeCard(
                'Dark',
                Icons.dark_mode_rounded,
                'dark',
                LPColors.accent,
                ThemeMode.dark,
              ),
            ),
            Gap.md,
            Expanded(
              child: _buildThemeCard(
                'System',
                Icons.settings_brightness_rounded,
                'system',
                LPColors.secondary,
                ThemeMode.system,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeCard(
    String label,
    IconData icon,
    String value,
    Color color,
    ThemeMode mode,
  ) {
    final theme = Theme.of(context);
    final isSelected = _themeMode == value;
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      onTap: () async {
        setState(() => _themeMode = value);
        await ThemeManager.instance.setThemeMode(mode);
      },
      useGlow: isSelected,
      glowColor: isSelected ? theme.colorScheme.secondary : null,
      border: isSelected
          ? Border.all(color: theme.colorScheme.secondary, width: 2)
          : Border.all(color: theme.colorScheme.outlineVariant, width: 1.5),
      backgroundColor: isSelected
          ? theme.colorScheme.surface
          : (isDark
                ? theme.colorScheme.surfaceContainer
                : theme.colorScheme.surface.withValues(alpha: 0.5)),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
            size: 28,
          ),
          Gap.sm,
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection() {
    final theme = Theme.of(context);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: LPSpacing.card,
            child: Text('App Info', style: theme.textTheme.titleSmall),
          ),
          _buildInfoTile('App Version', '1.0.0', Icons.info_outline_rounded),
          _buildInfoTile('Build Number', '1', Icons.build_rounded),
          _buildInfoTile(
            'Privacy Policy',
            null,
            Icons.privacy_tip_outlined,
            onTap: () => _showComingSoonSnackbar('Privacy Policy'),
          ),
          _buildInfoTile(
            'Terms of Service',
            null,
            Icons.description_outlined,
            onTap: () => _showComingSoonSnackbar('Terms of Service'),
          ),
          Gap.sm,
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    String title,
    String? value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 20),
      title: Text(title, style: theme.textTheme.bodyMedium),
      trailing: value != null
          ? Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
      onTap: onTap,
    );
  }

  void _showComingSoonSnackbar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature opening soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildLogoutSection() {
    final theme = Theme.of(context);
    return AppCard(
      onTap: _handleLogout,
      child: Row(
        children: [
          AppIconBox(
            icon: Icons.logout_rounded,
            iconColor: theme.colorScheme.error,
            backgroundColor: theme.colorScheme.error.withValues(alpha: 0.1),
          ),
          Gap.md,
          Expanded(
            child: Text(
              'Log Out',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: theme.colorScheme.error),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out?'),
        content: const Text(
          'Are you sure you want to log out? Your local data will be cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          AppButton.custom(
            label: 'Log Out',
            onTap: () => Navigator.pop(context, true),
            size: ButtonSize.sm,
            color: theme.colorScheme.error,
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await AuthProvider.instance.logout();
      // AppRouter will automatically redirect because of refreshListenable
    }
  }
}
