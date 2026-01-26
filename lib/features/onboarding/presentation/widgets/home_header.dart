import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../brand_kit/domain/brand_kit_model.dart';

class HomeHeader extends StatelessWidget {
  final BrandKit? brandKit;
  final VoidCallback onDraftsTap;
  final int draftCount;

  const HomeHeader({
    super.key,
    this.brandKit,
    required this.onDraftsTap,
    required this.draftCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppConstants.spacingLg,
        right: AppConstants.spacingLg,
        bottom: AppConstants.spacingLg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.arcticBlue.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row
          Row(
            children: [
              _buildHeaderLogo(),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.arcticBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              const Spacer(),
              _buildIconButton(
                icon: Icons.folder_outlined,
                onPressed: onDraftsTap,
                badgeCount: draftCount,
              ),
              _buildIconButton(
                icon: Icons.notifications_none_rounded,
                onPressed: () {},
              ),
              _buildIconButton(icon: Icons.settings_outlined, onPressed: () {}),
            ],
          ),
          const SizedBox(height: 32),
          // Welcome Text
          Text(
            brandKit != null
                ? 'Welcome, ${brandKit!.businessName}! 👋'
                : 'Welcome to LonePengu! 👋',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.penguinBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your unified social media command center',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.grey600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderLogo() {
    if (brandKit != null && brandKit!.hasLogo) {
      if (brandKit!.logoBytes != null && brandKit!.logoBytes!.isNotEmpty) {
        return _logoWrapper(
          child: Image.memory(
            brandKit!.logoBytes!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const AppLogo(size: 42),
          ),
        );
      } else if (!kIsWeb &&
          brandKit!.logoPath != null &&
          brandKit!.logoPath!.isNotEmpty) {
        return _logoWrapper(
          child: Image.file(
            File(brandKit!.logoPath!),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const AppLogo(size: 42),
          ),
        );
      }
    }
    return const AppLogo(size: 42);
  }

  Widget _logoWrapper({required Widget child}) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.iceWhite,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.penguinBlack.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(10), child: child),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.auroraTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'AI READY',
        style: TextStyle(
          color: AppColors.auroraTeal,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    int badgeCount = 0,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: AppColors.iceWhite,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.grey200),
      ),
      child: IconButton(
        onPressed: onPressed,
        iconSize: 20,
        icon: badgeCount > 0
            ? Badge(
                label: Text('$badgeCount'),
                backgroundColor: AppColors.sunsetCoral,
                child: Icon(icon, color: AppColors.grey700),
              )
            : Icon(icon, color: AppColors.grey700),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
