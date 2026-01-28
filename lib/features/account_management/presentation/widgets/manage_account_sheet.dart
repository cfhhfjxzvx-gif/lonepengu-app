import 'package:lone_pengu/core/design/lp_design.dart';
import 'package:flutter/material.dart';
import '../../data/connected_account_model.dart';

/// Bottom sheet for managing a connected social account
class ManageAccountSheet extends StatefulWidget {
  final ConnectedAccount account;
  final Future<bool> Function() onDisconnect;
  final Future<bool> Function() onReconnect;

  const ManageAccountSheet({
    super.key,
    required this.account,
    required this.onDisconnect,
    required this.onReconnect,
  });

  /// Show the manage account sheet
  static Future<ManageAccountResult?> show(
    BuildContext context, {
    required ConnectedAccount account,
    required Future<bool> Function() onDisconnect,
    required Future<bool> Function() onReconnect,
  }) {
    return showModalBottomSheet<ManageAccountResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ManageAccountSheet(
        account: account,
        onDisconnect: onDisconnect,
        onReconnect: onReconnect,
      ),
    );
  }

  @override
  State<ManageAccountSheet> createState() => _ManageAccountSheetState();
}

/// Result of manage account action
enum ManageAccountResult { disconnected, reconnected, cancelled }

class _ManageAccountSheetState extends State<ManageAccountSheet> {
  bool _isDisconnecting = false;
  bool _isReconnecting = false;

  Future<void> _handleDisconnect() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Disconnect ${widget.account.platform.displayName}?'),
        content: Text(
          'You will no longer be able to publish or analyze content on ${widget.account.platform.displayName}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: LPColors.error),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDisconnecting = true);

    final success = await widget.onDisconnect();

    if (mounted) {
      if (success) {
        Navigator.pop(context, ManageAccountResult.disconnected);
      } else {
        setState(() => _isDisconnecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to disconnect. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleReconnect() async {
    setState(() => _isReconnecting = true);

    final success = await widget.onReconnect();

    if (mounted) {
      if (success) {
        Navigator.pop(context, ManageAccountResult.reconnected);
      } else {
        setState(() => _isReconnecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reconnect. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleViewPermissions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Permission management coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final platformColor = Color(widget.account.platform.colorValue);
    final isLoading = _isDisconnecting || _isReconnecting;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: LPColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Account info header
              Row(
                children: [
                  // Platform icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: platformColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        widget.account.platform.icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Account details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.account.platform.displayName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${widget.account.username}',
                          style: TextStyle(
                            fontSize: 14,
                            color: platformColor,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Connected badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: LPColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: LPColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Connected',
                          style: TextStyle(
                            fontSize: 11,
                            color: LPColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Connection info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: LPColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: LPColors.grey500,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Connected on ${widget.account.formattedConnectedDate}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: LPColors.grey600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              _buildActionButton(
                context,
                icon: Icons.refresh_rounded,
                label: 'Reconnect Account',
                subtitle: 'Refresh authorization',
                isLoading: _isReconnecting,
                disabled: isLoading,
                onTap: _handleReconnect,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                context,
                icon: Icons.security_rounded,
                label: 'View Permissions',
                subtitle: 'What LonePengu can access',
                disabled: isLoading,
                onTap: _handleViewPermissions,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                context,
                icon: Icons.link_off_rounded,
                label: 'Disconnect',
                subtitle: 'Remove this account',
                isDestructive: true,
                isLoading: _isDisconnecting,
                disabled: isLoading,
                onTap: _handleDisconnect,
              ),

              const SizedBox(height: 16),

              // Close button
              TextButton(
                onPressed: isLoading
                    ? null
                    : () =>
                          Navigator.pop(context, ManageAccountResult.cancelled),
                child: const Text('Close'),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isLoading = false,
    bool disabled = false,
  }) {
    final color = isDestructive ? LPColors.error : LPColors.primary;

    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDestructive
                ? LPColors.error.withValues(alpha: 0.3)
                : LPColors.grey200,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? LPColors.error
                          : LPColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: LPColors.grey500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: isDestructive
                    ? LPColors.error
                    : LPColors.grey400,
              ),
          ],
        ),
      ),
    );
  }
}
