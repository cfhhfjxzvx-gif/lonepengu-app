import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            theme.colorScheme.primary.withOpacity(isDark ? 0.1 : 0.05),
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
              _buildHeaderLogo(context),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              const Spacer(),
              _buildIconButton(
                context,
                icon: Icons.folder_outlined,
                onPressed: onDraftsTap,
                badgeCount: draftCount,
              ),
              _buildIconButton(
                context,
                icon: Icons.notifications_none_rounded,
                onPressed: () {},
              ),
              _buildIconButton(
                context,
                icon: Icons.settings_outlined,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Welcome Text
          Text(
            brandKit != null
                ? 'Welcome, ${brandKit!.businessName}! 👋'
                : 'Welcome to LonePengu! 👋',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your unified social media command center',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderLogo(BuildContext context) {
    if (brandKit != null && brandKit!.hasLogo) {
      if (brandKit!.logoBytes != null && brandKit!.logoBytes!.isNotEmpty) {
        return _logoWrapper(
          context,
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
          context,
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

  Widget _logoWrapper(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: isDark
            ? Border.all(color: theme.colorScheme.outlineVariant)
            : null,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(10), child: child),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'AI READY',
        style: TextStyle(
          color: theme.colorScheme.tertiary,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    int badgeCount = 0,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: IconButton(
        onPressed: onPressed,
        iconSize: 20,
        icon: badgeCount > 0
            ? Badge(
                label: Text('$badgeCount'),
                backgroundColor: theme.colorScheme.error,
                child: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
              )
            : Icon(icon, color: theme.colorScheme.onSurfaceVariant),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
