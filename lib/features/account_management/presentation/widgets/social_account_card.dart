import 'package:lone_pengu/core/design/lp_design.dart';
import 'package:flutter/material.dart';
import '../../data/connected_account_model.dart';

/// Card widget displaying a social platform connection status
class SocialAccountCard extends StatelessWidget {
  final SocialPlatform platform;
  final ConnectedAccount? account;
  final bool isLoading;
  final VoidCallback onConnect;
  final VoidCallback onManage;

  const SocialAccountCard({
    super.key,
    required this.platform,
    this.account,
    this.isLoading = false,
    required this.onConnect,
    required this.onManage,
  });

  bool get isConnected => account != null && account!.isConnected;

  @override
  Widget build(BuildContext context) {
    final platformColor = Color(platform.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Platform icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: platformColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  platform.icon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Platform info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Platform name
                  Text(
                    platform.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  // Connection status
                  Row(
                    children: [
                      // Status dot
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isConnected
                              ? LPColors.accent
                              : LPColors.grey300,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6),
                      // Status text / username
                      Expanded(
                        child: Text(
                          isConnected
                              ? '@${account!.username}'
                              : 'Not Connected',
                          style: TextStyle(
                            fontSize: 13,
                            color: isConnected
                                ? LPColors.accent
                                : LPColors.grey500,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // CTA Button
            _buildActionButton(context, platformColor),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, Color platformColor) {
    if (isLoading) {
      return Container(
        width: 80,
        height: 36,
        decoration: BoxDecoration(
          color: platformColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: platformColor,
            ),
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: isConnected ? onManage : onConnect,
      style: ElevatedButton.styleFrom(
        backgroundColor: isConnected ? LPColors.grey100 : platformColor,
        foregroundColor: isConnected ? LPColors.grey700 : Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        minimumSize: const Size(80, 36),
      ),
      child: Text(
        isConnected ? 'Manage' : 'Connect',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
