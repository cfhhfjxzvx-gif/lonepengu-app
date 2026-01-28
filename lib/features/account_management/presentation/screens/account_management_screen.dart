import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/lp_design.dart';
import '../../data/connected_account_model.dart';
import '../../data/social_auth_service.dart';
import '../widgets/social_account_card.dart';
import '../widgets/connect_account_sheet.dart';
import '../widgets/manage_account_sheet.dart';

/// Account Management screen for connecting/disconnecting social accounts
class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final SocialAuthService _authService = SocialAuthServiceProvider.instance;

  // State
  Map<SocialPlatform, ConnectedAccount?> _accounts = {};
  Map<SocialPlatform, bool> _loadingStates = {};
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isInitializing = true);

    try {
      final connections = await _authService.getAllConnections();

      final Map<SocialPlatform, ConnectedAccount?> accountMap = {};
      for (final platform in SocialPlatform.values) {
        final account = connections
            .where((a) => a.platform == platform)
            .firstOrNull;
        accountMap[platform] = account;
      }

      if (mounted) {
        setState(() {
          _accounts = accountMap;
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _handleConnect(SocialPlatform platform) async {
    final result = await ConnectAccountSheet.show(
      context,
      platform: platform,
      onConnect: () async {
        final result = await _authService.connect(platform);
        if (result.success && result.account != null) {
          setState(() {
            _accounts[platform] = result.account;
          });
          return true;
        }
        return false;
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${platform.displayName} connected successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: LPColors.success,
          shape: RoundedRectangleBorder(borderRadius: LPRadius.smBorder),
        ),
      );
    }
  }

  Future<void> _handleManage(SocialPlatform platform) async {
    final account = _accounts[platform];
    if (account == null) return;

    final result = await ManageAccountSheet.show(
      context,
      account: account,
      onDisconnect: () async {
        final success = await _authService.disconnect(platform);
        if (success) {
          setState(() {
            _accounts[platform] = null;
          });
        }
        return success;
      },
      onReconnect: () async {
        final result = await _authService.reconnect(platform);
        if (result.success && result.account != null) {
          setState(() {
            _accounts[platform] = result.account;
          });
          return true;
        }
        return false;
      },
    );

    if (mounted) {
      switch (result) {
        case ManageAccountResult.disconnected:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${platform.displayName} disconnected'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: LPRadius.smBorder),
            ),
          );
          break;
        case ManageAccountResult.reconnected:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${platform.displayName} reconnected'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: LPColors.success,
              shape: RoundedRectangleBorder(borderRadius: LPRadius.smBorder),
            ),
          );
          break;
        default:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      appBar: AppBar(
        title: const Text('Connected Accounts'),
        leading: AppIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => context.pop(),
        ),
      ),
      body: _isInitializing
          ? const AppLoading()
          : AppPage(
              child: AppMaxWidth(
                maxWidth: 600,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info section
                    _buildInfoSection(),
                    Gap.lg,

                    // Section title
                    Text('Your Accounts', style: LPText.hSM),
                    Gap.sm,

                    // Platform cards
                    ...SocialPlatform.values.map((platform) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: LPSpacing.sm),
                        child: SocialAccountCard(
                          platform: platform,
                          account: _accounts[platform],
                          isLoading: _loadingStates[platform] ?? false,
                          onConnect: () => _handleConnect(platform),
                          onManage: () => _handleManage(platform),
                        ),
                      );
                    }),

                    Gap.lg,

                    // Disclaimer
                    _buildDisclaimer(),

                    Gap.xl,
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: LPSpacing.page,
      decoration: BoxDecoration(
        color: LPColors.primary.withValues(alpha: 0.05),
        borderRadius: LPRadius.card,
        border: Border.all(color: LPColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIconBox(
                icon: Icons.link_rounded,
                iconColor: LPColors.primary,
                backgroundColor: LPColors.primary.withValues(alpha: 0.1),
                size: 40,
              ),
              Gap.md,
              Expanded(
                child: Text(
                  'Connect Your Accounts',
                  style: LPText.hSM.copyWith(color: LPColors.primary),
                ),
              ),
            ],
          ),
          Gap.md,
          Text(
            'Connect your social media accounts to publish content, analyze performance, and schedule posts across platforms.',
            style: LPText.bodyMD.copyWith(color: LPColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return AppCard(
      padding: const EdgeInsets.all(LPSpacing.sm),
      backgroundColor: LPColors.grey100,
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: LPColors.textTertiary,
          ),
          Gap.sm,
          Expanded(
            child: Text(
              'You can disconnect anytime. Your data is secure.',
              style: LPText.caption,
            ),
          ),
        ],
      ),
    );
  }
}
