import 'package:flutter/material.dart';
import 'package:lone_pengu/core/design/lp_design.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLow
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.tag_rounded,
                  size: 20,
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${group.tags.length} hashtags',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: theme.colorScheme.onSurfaceVariant,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 20),
                color: theme.colorScheme.error,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          if (group.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: group.tags.take(5).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  child: Text(
                    '#$tag',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (group.tags.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+${group.tags.length - 5} more',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
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
    final theme = Theme.of(context);
    final isEditing = widget.existingGroup != null;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
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
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isEditing ? 'Edit Hashtag Group' : 'New Hashtag Group',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // Group name
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Group Name',
              hintText: 'e.g., Social Media Marketing',
              prefixIcon: Icon(Icons.label_outline_rounded),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 20),
          // Tags input
          TextField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: 'Hashtags',
              hintText: 'marketing, socialmedia, branding',
              helperText: 'Separate with commas or spaces',
              prefixIcon: Icon(Icons.tag_rounded),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          // Save button
          SizedBox(
            width: double.infinity,
            child: AppButton.primary(
              label: isEditing ? 'Update Group' : 'Create Group',
              onTap: _handleSave,
            ),
          ),
        ],
      ),
    );
  }
}
