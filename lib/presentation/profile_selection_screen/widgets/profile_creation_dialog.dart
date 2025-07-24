import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileCreationDialog extends StatefulWidget {
  final Function(String name, String? avatarUrl) onCreateProfile;

  const ProfileCreationDialog({
    super.key,
    required this.onCreateProfile,
  });

  @override
  State<ProfileCreationDialog> createState() => _ProfileCreationDialogState();
}

class _ProfileCreationDialogState extends State<ProfileCreationDialog> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedAvatarUrl;
  final _formKey = GlobalKey<FormState>();

  final List<String> _avatarOptions = [
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&h=150&fit=crop&crop=face',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(6.w),
        constraints: BoxConstraints(
          maxWidth: 90.w,
          maxHeight: 80.h,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Create New Profile',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                      size: 6.w,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Text(
                'Profile Name',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              SizedBox(height: 1.h),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter profile name (e.g., John Doe, Family Tax)',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'person',
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                      size: 5.w,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a profile name';
                  }
                  if (value.trim().length < 2) {
                    return 'Profile name must be at least 2 characters';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
                maxLength: 30,
              ),
              SizedBox(height: 2.h),
              Text(
                'Choose Avatar (Optional)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              SizedBox(height: 1.h),
              Container(
                height: 20.w,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _avatarOptions.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildAvatarOption(
                        context,
                        isDefault: true,
                        isSelected: _selectedAvatarUrl == null,
                        onTap: () {
                          setState(() {
                            _selectedAvatarUrl = null;
                          });
                        },
                      );
                    }

                    final avatarUrl = _avatarOptions[index - 1];
                    return _buildAvatarOption(
                      context,
                      avatarUrl: avatarUrl,
                      isSelected: _selectedAvatarUrl == avatarUrl,
                      onTap: () {
                        setState(() {
                          _selectedAvatarUrl = avatarUrl;
                        });
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _createProfile,
                      child: Text('Create Profile'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarOption(
    BuildContext context, {
    String? avatarUrl,
    bool isDefault = false,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 16.w,
        height: 16.w,
        margin: EdgeInsets.only(right: 3.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.dividerColor,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: ClipOval(
          child: isDefault
              ? Container(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 8.w,
                  ),
                )
              : CustomImageWidget(
                  imageUrl: avatarUrl!,
                  width: 16.w,
                  height: 16.w,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  void _createProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      widget.onCreateProfile(name, _selectedAvatarUrl);
      Navigator.pop(context);
    }
  }
}
