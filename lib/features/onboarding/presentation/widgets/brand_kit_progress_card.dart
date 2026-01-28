import 'package:lone_pengu/core/design/lp_design.dart';
import 'package:flutter/material.dart';
import '../../../brand_kit/domain/brand_kit_model.dart';

class BrandKitProgressCard extends StatelessWidget {
  final BrandKit? brandKit;
  final VoidCallback onTap;

  const BrandKitProgressCard({super.key, this.brandKit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isValid = brandKit != null && brandKit!.isValid;
    final progress = _calculateProgress();
    final percentage = (progress * 100).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isValid
                ? [
                    LPColors.primary,
                    LPColors.primary.withValues(alpha: 0.8),
                  ]
                : [LPColors.surface, LPColors.surface],
          ),
          borderRadius: BorderRadius.circular(20),
          border: isValid ? null : Border.all(color: LPColors.grey200),
          boxShadow: [
            BoxShadow(
              color: isValid
                  ? LPColors.primary.withValues(alpha: 0.2)
                  : LPColors.textPrimary.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildIcon(isValid),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Brand Kit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isValid
                              ? LPColors.surface
                              : LPColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        isValid
                            ? 'Everything looks set!'
                            : 'Complete your setup',
                        style: TextStyle(
                          fontSize: 13,
                          color: isValid
                              ? LPColors.surface.withValues(alpha: 0.7)
                              : LPColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildProgressBadge(percentage, isValid),
              ],
            ),
            const SizedBox(height: 20),
            _buildProgressBar(progress, isValid),
          ],
        ),
      ),
    );
  }

  double _calculateProgress() {
    if (brandKit == null) return 0.0;
    int total = 4; // name, tone, colors, hashtags
    int completed = 0;
    if (brandKit!.businessName.isNotEmpty) {
      completed++;
    }
    if (brandKit!.voiceTone.isNotEmpty) {
      completed++;
    }
    if (brandKit!.colors.primary != BrandColors.defaultColors.primary) {
      completed++;
    }
    if (brandKit!.hashtagGroups.isNotEmpty) {
      completed++;
    }
    return completed / total;
  }

  Widget _buildIcon(bool isValid) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isValid
            ? LPColors.surface.withValues(alpha: 0.2)
            : LPColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isValid ? Icons.done_all_rounded : Icons.palette_outlined,
        color: isValid ? LPColors.surface : LPColors.accent,
      ),
    );
  }

  Widget _buildProgressBadge(int percentage, bool isValid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isValid
            ? LPColors.surface.withValues(alpha: 0.2)
            : LPColors.grey100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$percentage%',
        style: TextStyle(
          color: isValid ? LPColors.surface : LPColors.grey700,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress, bool isValid) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 8,
        backgroundColor: isValid
            ? LPColors.surface.withValues(alpha: 0.1)
            : LPColors.grey100,
        valueColor: AlwaysStoppedAnimation<Color>(
          isValid ? LPColors.surface : LPColors.accent,
        ),
      ),
    );
  }
}
