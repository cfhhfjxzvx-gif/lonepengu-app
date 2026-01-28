import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/lp_design.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_manager.dart';
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
    return AppCard(
      child: Row(
        children: [
          // Avatar
          AppIconBox(
            icon: Icons.person_rounded,
            size: 56,
            iconColor: LPColors.primary,
            backgroundColor: LPColors.primary.withValues(alpha: 0.1),
          ),
          Gap.md,
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LonePengu User', style: LPText.hSM),
                Gap.xxs,
                Text(
                  'user@lonepengu.com',
                  style: LPText.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Pro badge
          AppPill(
            label: 'PRO',
            backgroundColor: LPColors.secondary.withValues(alpha: 0.1),
            textColor: LPColors.secondaryDark,
            isSmall: true,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedAccountsSection() {
    return AppCard(
      onTap: () => context.push(AppRoutes.accounts),
      child: Row(
        children: [
          AppIconBox(
            icon: Icons.link_rounded,
            iconColor: LPColors.primary,
            backgroundColor: LPColors.primary.withValues(alpha: 0.1),
          ),
          Gap.md,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Connected Accounts', style: LPText.hSM),
                Gap.xxs,
                Text(
                  'Manage your social media connections',
                  style: LPText.caption,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: LPColors.textTertiary),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: LPSpacing.card,
            child: Text('Notifications', style: LPText.hSM),
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
    return ListTile(
      title: Text(
        title,
        style: LPText.bodyMD.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle, style: LPText.caption),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildAppearanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: LPSpacing.xs,
            bottom: LPSpacing.sm,
          ),
          child: Text('Appearance', style: LPText.hSM),
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
    final isSelected = _themeMode == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: () async {
        setState(() => _themeMode = value);
        await ThemeManager.instance.setThemeMode(mode);
      },
      useGlow: isSelected,
      glowColor: isSelected ? LPColors.secondary : null,
      border: isSelected
          ? Border.all(color: LPColors.secondary, width: 2)
          : Border.all(
              color: isDark ? LPColors.borderDark : LPColors.border,
              width: 1.5,
            ),
      backgroundColor: isSelected
          ? (isDark ? LPColors.surfaceDark : LPColors.surface)
          : (isDark
                ? LPColors.cardDark
                : LPColors.surface.withValues(alpha: 0.5)),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? color : LPColors.textSecondary,
            size: 28,
          ),
          Gap.sm,
          Text(
            label,
            style: LPText.bodySM.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? LPColors.textPrimary : LPColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: LPSpacing.card,
            child: Text('App Info', style: LPText.hSM),
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
    return ListTile(
      leading: Icon(icon, color: LPColors.textTertiary, size: 20),
      title: Text(title, style: LPText.bodyMD),
      trailing: value != null
          ? Text(value, style: LPText.caption)
          : const Icon(
              Icons.chevron_right_rounded,
              color: LPColors.textTertiary,
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
    return AppCard(
      onTap: _handleLogout,
      child: Row(
        children: [
          AppIconBox(
            icon: Icons.logout_rounded,
            iconColor: LPColors.error,
            backgroundColor: LPColors.error.withValues(alpha: 0.1),
          ),
          Gap.md,
          Expanded(
            child: Text(
              'Log Out',
              style: LPText.hSM.copyWith(color: LPColors.error),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: LPColors.error),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
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
            color: LPColors.error,
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await SettingsStorage.clearUserData();
      if (mounted) {
        context.go(AppRoutes.landing);
      }
    }
  }
}
