import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/brand_kit_model.dart';

/// Hashtag group card widget
class HashtagGroupCard extends StatelessWidget {
  final HashtagGroup group;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HashtagGroupCard({
    super.key,
    required this.group,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.iceWhite,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.frostPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tag_rounded,
                  size: 18,
                  color: AppColors.frostPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${group.tags.length} hashtags',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.grey500),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: AppColors.grey500,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.sunsetCoral,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          if (group.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: group.tags.take(5).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$tag',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.grey700),
                  ),
                );
              }).toList(),
            ),
            if (group.tags.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '+${group.tags.length - 5} more',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Bottom sheet for adding/editing hashtag group
class HashtagGroupBottomSheet extends StatefulWidget {
  final HashtagGroup? existingGroup;
  final Function(HashtagGroup) onSave;

  const HashtagGroupBottomSheet({
    super.key,
    this.existingGroup,
    required this.onSave,
  });

  @override
  State<HashtagGroupBottomSheet> createState() =>
      _HashtagGroupBottomSheetState();
}

class _HashtagGroupBottomSheetState extends State<HashtagGroupBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingGroup?.name ?? '',
    );
    _tagsController = TextEditingController(
      text: widget.existingGroup?.tags.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  List<String> _parseTags(String input) {
    return input
        .split(RegExp(r'[,\s]+'))
        .map((tag) => tag.replaceAll('#', '').trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  void _handleSave() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    final tags = _parseTags(_tagsController.text);
    if (tags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one hashtag')),
      );
      return;
    }

    final group = HashtagGroup(
      id:
          widget.existingGroup?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      tags: tags,
    );

    widget.onSave(group);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingGroup != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.iceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: AppConstants.spacingLg,
        right: AppConstants.spacingLg,
        top: AppConstants.spacingLg,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + AppConstants.spacingLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isEditing ? 'Edit Hashtag Group' : 'New Hashtag Group',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          // Group name
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Group Name',
              hintText: 'e.g., Social Media Marketing',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          // Tags input
          TextField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: 'Hashtags',
              hintText: 'marketing, socialmedia, branding',
              helperText: 'Separate with commas or spaces',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.arcticBlue,
                foregroundColor: AppColors.iceWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isEditing ? 'Update Group' : 'Create Group'),
            ),
          ),
        ],
      ),
    );
  }
}
