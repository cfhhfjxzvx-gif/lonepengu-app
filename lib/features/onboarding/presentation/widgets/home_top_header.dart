import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../brand_kit/domain/brand_kit_model.dart';

class HomeTopHeader extends StatefulWidget {
  final BrandKit? brandKit;
  final VoidCallback onDraftsTap;
  final VoidCallback? onSettingsTap;
  final int draftCount;

  const HomeTopHeader({
    super.key,
    this.brandKit,
    required this.onDraftsTap,
    this.onSettingsTap,
    required this.draftCount,
  });

  @override
  State<HomeTopHeader> createState() => _HomeTopHeaderState();
}

class _HomeTopHeaderState extends State<HomeTopHeader>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  late AnimationController _entranceController;
  late Animation<double> _entranceFade;
  late Animation<Offset> _entranceSlide;

  @override
  void initState() {
    super.initState();
    // AI Status Pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Entrance Animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _entranceFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _entranceSlide =
        Tween<Offset>(begin: const Offset(0, -0.05), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
          ),
        );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _entranceFade,
      child: SlideTransition(
        position: _entranceSlide,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            // Removed border and shadow to merge with the page content
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildPixelPerfectLogo(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppConstants.appName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: -0.8,
                              ),
                            ),
                            Text(
                              'Your AI Social Command Center',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildHeaderActions(context),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_buildWelcomeText(), _buildAiStatusChip()],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPixelPerfectLogo() {
    final theme = Theme.of(context);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11), // 1px less than container
        child: Image.asset(
          'assets/images/lonepengu_logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return Row(
      children: [
        _HeaderActionButton(
          icon: Icons.folder_rounded,
          onPressed: widget.onDraftsTap,
          badge: widget.draftCount > 0 ? widget.draftCount.toString() : null,
        ),
        const SizedBox(width: 8),
        _HeaderActionButton(
          icon: Icons.notifications_rounded,
          onPressed: () => context.push(AppRoutes.notifications),
          hasDot: true,
        ),
        const SizedBox(width: 8),
        _HeaderActionButton(
          icon: Icons.settings_rounded,
          onPressed:
              widget.onSettingsTap ?? () => context.push(AppRoutes.settings),
        ),
      ],
    );
  }

  Widget _buildAiStatusChip() {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulse effect
            Container(
              width: 84,
              height: 28,
              transform: Matrix4.identity()..scale(_pulseScale.value),
              transformAlignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: theme.colorScheme.primary.withOpacity(
                  _pulseOpacity.value,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 11),
                  SizedBox(width: 4),
                  Text(
                    'AI READY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWelcomeText() {
    final theme = Theme.of(context);
    final businessName = widget.brandKit?.businessName ?? 'User';
    return Expanded(
      child: Text(
        'Hi, $businessName 👋',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _HeaderActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? badge;
  final bool hasDot;

  const _HeaderActionButton({
    required this.icon,
    required this.onPressed,
    this.badge,
    this.hasDot = false,
  });

  @override
  State<_HeaderActionButton> createState() => _HeaderActionButtonState();
}

class _HeaderActionButtonState extends State<_HeaderActionButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.onSurface.withOpacity(0.02),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              if (widget.badge != null)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    constraints: const BoxConstraints(minWidth: 16),
                    child: Text(
                      widget.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (widget.hasDot)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
