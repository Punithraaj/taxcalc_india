import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/profile_card_widget.dart';
import './widgets/profile_creation_dialog.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  bool _isLoading = false;
  bool _isRefreshing = false;

  // Mock data for tax profiles
  List<Map<String, dynamic>> _profiles = [
    {
      "id": 1,
      "name": "Rajesh Kumar",
      "avatar":
          "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
      "lastCalculatedYear": "2024-25",
      "taxRegime": "New Regime",
      "totalIncome": 1200000.0,
      "taxPayable": 78000.0,
      "lastModified": DateTime.now().subtract(Duration(days: 2)),
      "isDefault": true,
      "isSynced": true,
    },
    {
      "id": 2,
      "name": "Priya Sharma",
      "avatar":
          "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face",
      "lastCalculatedYear": "2024-25",
      "taxRegime": "Old Regime",
      "totalIncome": 850000.0,
      "taxPayable": 45000.0,
      "lastModified": DateTime.now().subtract(Duration(days: 5)),
      "isDefault": false,
      "isSynced": true,
    },
    {
      "id": 3,
      "name": "Family Tax Profile",
      "avatar": null,
      "lastCalculatedYear": "2023-24",
      "taxRegime": "New Regime",
      "totalIncome": 2500000.0,
      "taxPayable": 312500.0,
      "lastModified": DateTime.now().subtract(Duration(days: 15)),
      "isDefault": false,
      "isSynced": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: Text(
          'Tax Profiles',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        actions: [
          if (_profiles.isNotEmpty)
            IconButton(
              onPressed: _showCreateProfileDialog,
              icon: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.lightTheme.primaryColor,
                size: 6.w,
              ),
            ),
        ],
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: _profiles.isEmpty ? _buildEmptyState() : _buildProfilesList(),
      ),
      floatingActionButton:
          _profiles.isNotEmpty ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.lightTheme.primaryColor,
                  AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomIconWidget(
                  iconName: 'calculate',
                  color: Colors.white,
                  size: 12.w,
                ),
                SizedBox(height: 2.h),
                Text(
                  'TaxCalc India',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  'v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'person',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 6.w,
                  ),
                  title: Text('Profiles'),
                  selected: true,
                  selectedTileColor:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'settings',
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                    size: 6.w,
                  ),
                  title: Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'contact_support',
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                    size: 6.w,
                  ),
                  title: Text('Contact & About'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to contact/about
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'login',
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                    size: 6.w,
                  ),
                  title: Text('Login / Sign Up'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/authentication-screen');
                  },
                ),
                Divider(),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'star',
                    color: Colors.amber,
                    size: 6.w,
                  ),
                  title: Text('Go Premium'),
                  subtitle: Text('Unlock advanced features'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to premium
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      onCreateProfile: _showCreateProfileDialog,
    );
  }

  Widget _buildProfilesList() {
    return RefreshIndicator(
      onRefresh: _refreshProfiles,
      child: Column(
        children: [
          if (_isLoading)
            LinearProgressIndicator(
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.lightTheme.primaryColor,
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              itemCount: _profiles.length,
              itemBuilder: (context, index) {
                final profile = _profiles[index];
                return ProfileCardWidget(
                  profile: profile,
                  onTap: () => _selectProfile(profile),
                  onDuplicate: () => _duplicateProfile(profile),
                  onRename: () => _renameProfile(profile),
                  onExport: () => _exportProfile(profile),
                  onDelete: () => _deleteProfile(profile),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showCreateProfileDialog,
      icon: CustomIconWidget(
        iconName: 'add',
        color: Colors.white,
        size: 5.w,
      ),
      label: Text(
        'Add Profile',
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _refreshProfiles() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
      // Update sync status
      for (var profile in _profiles) {
        profile['isSynced'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profiles synced successfully'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
    );
  }

  void _selectProfile(Map<String, dynamic> profile) {
    // Navigate to main dashboard with selected profile
    Navigator.pushNamed(
      context,
      '/main-dashboard',
      arguments: {'profileId': profile['id']},
    );
  }

  void _showCreateProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => ProfileCreationDialog(
        onCreateProfile: _createProfile,
      ),
    );
  }

  void _createProfile(String name, String? avatarUrl) {
    setState(() {
      _profiles.add({
        "id": _profiles.length + 1,
        "name": name,
        "avatar": avatarUrl,
        "lastCalculatedYear": "2024-25",
        "taxRegime": "New Regime",
        "totalIncome": 0.0,
        "taxPayable": 0.0,
        "lastModified": DateTime.now(),
        "isDefault": _profiles.isEmpty,
        "isSynced": false,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile "$name" created successfully'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
    );
  }

  void _duplicateProfile(Map<String, dynamic> profile) {
    setState(() {
      final duplicatedProfile = Map<String, dynamic>.from(profile);
      duplicatedProfile['id'] = _profiles.length + 1;
      duplicatedProfile['name'] = '${profile['name']} (Copy)';
      duplicatedProfile['isDefault'] = false;
      duplicatedProfile['isSynced'] = false;
      duplicatedProfile['lastModified'] = DateTime.now();
      _profiles.add(duplicatedProfile);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile duplicated successfully'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
    );
  }

  void _renameProfile(Map<String, dynamic> profile) {
    final TextEditingController controller =
        TextEditingController(text: profile['name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename Profile'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Profile Name',
            hintText: 'Enter new profile name',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  profile['name'] = controller.text.trim();
                  profile['lastModified'] = DateTime.now();
                  profile['isSynced'] = false;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profile renamed successfully'),
                    backgroundColor: AppTheme.lightTheme.primaryColor,
                  ),
                );
              }
            },
            child: Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _exportProfile(Map<String, dynamic> profile) {
    // Simulate export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting "${profile['name']}" profile...'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Handle view exported file
          },
        ),
      ),
    );
  }

  void _deleteProfile(Map<String, dynamic> profile) {
    setState(() {
      _profiles.removeWhere((p) => p['id'] == profile['id']);

      // If deleted profile was default, make first profile default
      if (profile['isDefault'] == true && _profiles.isNotEmpty) {
        _profiles.first['isDefault'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile "${profile['name']}" deleted'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _profiles.add(profile);
              _profiles
                  .sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
            });
          },
        ),
      ),
    );
  }
}
