import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/tax_data_manager.dart';
import './widgets/empty_state_widget.dart';
import './widgets/profile_card_widget.dart';
import './widgets/profile_creation_dialog.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  bool _isLoading = true;
  bool _isRefreshing = false;
  final TaxDataManager _dataManager = TaxDataManager();

  // Profiles list
  List<Map<String, dynamic>> _profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      final profiles = await _dataManager.loadProfiles();
      setState(() {
        _profiles = profiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Failed to load profiles');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
      );
    }

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
          if (_isRefreshing)
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

    try {
      await _loadProfiles();
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
    } catch (e) {
      setState(() {
        _isRefreshing = false;
      });
      _showErrorMessage('Failed to sync profiles');
    }
  }

  Future<void> _selectProfile(Map<String, dynamic> profile) async {
    try {
      // Set the current profile
      await _dataManager.setCurrentProfile(profile['id']);

      // Navigate to main dashboard with selected profile
      Navigator.pushNamed(
        context,
        '/main-dashboard',
        arguments: {'profileId': profile['id']},
      );
    } catch (e) {
      _showErrorMessage('Failed to select profile');
    }
  }

  void _showCreateProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => ProfileCreationDialog(
        onCreateProfile: _createProfile,
      ),
    );
  }

  Future<void> _createProfile(String name, String? avatarUrl) async {
    try {
      final newProfile = {
        "id": _profiles.isNotEmpty
            ? _profiles
                    .map((p) => p['id'] as int)
                    .reduce((a, b) => a > b ? a : b) +
                1
            : 1,
        "name": name,
        "avatar": avatarUrl,
        "lastCalculatedYear": "2024-25",
        "taxRegime": "New Regime",
        "totalIncome": 0.0,
        "taxPayable": 0.0,
        "lastModified": DateTime.now(),
        "isDefault": _profiles.isEmpty,
        "isSynced": false,
      };

      setState(() {
        _profiles.add(newProfile);
      });

      // Save to persistent storage
      await _dataManager.saveProfiles(_profiles);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile "$name" created successfully'),
          backgroundColor: AppTheme.lightTheme.primaryColor,
        ),
      );
    } catch (e) {
      _showErrorMessage('Failed to create profile');
    }
  }

  Future<void> _duplicateProfile(Map<String, dynamic> profile) async {
    try {
      final duplicatedProfile = Map<String, dynamic>.from(profile);
      duplicatedProfile['id'] =
          _profiles.map((p) => p['id'] as int).reduce((a, b) => a > b ? a : b) +
              1;
      duplicatedProfile['name'] = '${profile['name']} (Copy)';
      duplicatedProfile['isDefault'] = false;
      duplicatedProfile['isSynced'] = false;
      duplicatedProfile['lastModified'] = DateTime.now();

      setState(() {
        _profiles.add(duplicatedProfile);
      });

      // Copy profile data
      final originalData = await _dataManager.exportProfileData(profile['id']);
      await _dataManager.importProfileData(
          duplicatedProfile['id'], originalData);

      // Save to persistent storage
      await _dataManager.saveProfiles(_profiles);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile duplicated successfully'),
          backgroundColor: AppTheme.lightTheme.primaryColor,
        ),
      );
    } catch (e) {
      _showErrorMessage('Failed to duplicate profile');
    }
  }

  Future<void> _renameProfile(Map<String, dynamic> profile) async {
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
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                try {
                  setState(() {
                    profile['name'] = controller.text.trim();
                    profile['lastModified'] = DateTime.now();
                    profile['isSynced'] = false;
                  });

                  // Save to persistent storage
                  await _dataManager.saveProfiles(_profiles);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profile renamed successfully'),
                      backgroundColor: AppTheme.lightTheme.primaryColor,
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  _showErrorMessage('Failed to rename profile');
                }
              }
            },
            child: Text('Rename'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportProfile(Map<String, dynamic> profile) async {
    try {
      // Export profile data
      final exportData = await _dataManager.exportProfileData(profile['id']);

      // Show success message (in a real app, you'd trigger a file download)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile "${profile['name']}" exported successfully'),
          backgroundColor: AppTheme.lightTheme.primaryColor,
          action: SnackBarAction(
            label: 'View Data',
            onPressed: () {
              // Show export data in dialog for demonstration
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Export Data'),
                  content: SingleChildScrollView(
                    child: Text(exportData.toString()),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      _showErrorMessage('Failed to export profile');
    }
  }

  Future<void> _deleteProfile(Map<String, dynamic> profile) async {
    try {
      setState(() {
        _profiles.removeWhere((p) => p['id'] == profile['id']);

        // If deleted profile was default, make first profile default
        if (profile['isDefault'] == true && _profiles.isNotEmpty) {
          _profiles.first['isDefault'] = true;
        }
      });

      // Clear profile data from storage
      await _dataManager.clearProfileData(profile['id']);

      // Save updated profiles list
      await _dataManager.saveProfiles(_profiles);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile "${profile['name']}" deleted'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              try {
                setState(() {
                  _profiles.add(profile);
                  _profiles.sort(
                      (a, b) => (a['id'] as int).compareTo(b['id'] as int));
                });

                // Save updated profiles list
                await _dataManager.saveProfiles(_profiles);
              } catch (e) {
                _showErrorMessage('Failed to restore profile');
              }
            },
          ),
        ),
      );
    } catch (e) {
      _showErrorMessage('Failed to delete profile');
    }
  }
}
