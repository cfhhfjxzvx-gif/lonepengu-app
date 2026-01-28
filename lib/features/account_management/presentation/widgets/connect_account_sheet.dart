import 'package:lone_pengu/core/design/lp_design.dart';
import 'package:flutter/material.dart';
import '../../data/connected_account_model.dart';

/// Bottom sheet for connecting a new social account
class ConnectAccountSheet extends StatefulWidget {
  final SocialPlatform platform;
  final Future<bool> Function() onConnect;

  const ConnectAccountSheet({
    super.key,
    required this.platform,
    required this.onConnect,
  });

  /// Show the connect account sheet
  static Future<bool?> show(
    BuildContext context, {
    required SocialPlatform platform,
    required Future<bool> Function() onConnect,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ConnectAccountSheet(platform: platform, onConnect: onConnect),
    );
  }

  @override
  State<ConnectAccountSheet> createState() => _ConnectAccountSheetState();
}

class _ConnectAccountSheetState extends State<ConnectAccountSheet> {
  bool _isLoading = false;

  Future<void> _handleConnect() async {
    setState(() => _isLoading = true);

    final success = await widget.onConnect();

    if (mounted) {
      Navigator.pop(context, success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final platformColor = Color(widget.platform.colorValue);

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

              // Platform icon
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: platformColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      widget.platform.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Title
              Text(
                'Connect ${widget.platform.displayName}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),

              // Description
              Text(
                "You'll be redirected to ${widget.platform.authUrl} to authorize LonePengu to access your account.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: LPColors.grey600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),

              // Permissions info
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: LPColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LonePengu will be able to:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPermissionItem(
                      context,
                      Icons.post_add_rounded,
                      'Post content on your behalf',
                    ),
                    _buildPermissionItem(
                      context,
                      Icons.bar_chart_rounded,
                      'Access analytics and insights',
                    ),
                    _buildPermissionItem(
                      context,
                      Icons.schedule_rounded,
                      'Schedule posts for publishing',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: LPColors.grey300),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Continue button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleConnect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: platformColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: LPColors.grey500),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: LPColors.grey600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
