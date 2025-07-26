import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TaxDataManager {
  static const String _incomeDataKey = 'income_data';
  static const String _deductionsDataKey = 'deductions_data';
  static const String _profilesKey = 'tax_profiles';
  static const String _currentProfileKey = 'current_profile_id';
  static const String _userSettingsKey = 'user_settings';

  // Singleton pattern
  static final TaxDataManager _instance = TaxDataManager._internal();
  factory TaxDataManager() => _instance;
  TaxDataManager._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Income Data Management
  Future<void> saveIncomeData(
      int profileId, Map<String, Map<String, String>> incomeData) async {
    await initialize();
    final key = '${_incomeDataKey}_$profileId';
    final jsonString = jsonEncode(incomeData);
    await _prefs!.setString(key, jsonString);
  }

  Future<Map<String, Map<String, String>>> loadIncomeData(int profileId) async {
    await initialize();
    final key = '${_incomeDataKey}_$profileId';
    final jsonString = _prefs!.getString(key);

    if (jsonString != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(jsonString);
        return decoded.map((category, fields) => MapEntry(
              category,
              Map<String, String>.from(fields as Map),
            ));
      } catch (e) {
        return _getDefaultIncomeData();
      }
    }
    return _getDefaultIncomeData();
  }

  Map<String, Map<String, String>> _getDefaultIncomeData() {
    return {
      'salary': {
        'basic_da': '',
        'hra': '',
        'bonus': '',
        'other_allowances': '',
      },
      'business': {
        'business_income': '',
        'professional_income': '',
        'other_business': '',
      },
      'capital_gains': {
        'capital_gains_amount': '',
      },
      'other_sources': {
        'savings_interest': '',
        'fixed_deposits': '',
        'other_income': '',
      },
    };
  }

  // Deductions Data Management
  Future<void> saveDeductionsData(
      int profileId, Map<String, dynamic> deductionsData) async {
    await initialize();
    final key = '${_deductionsDataKey}_$profileId';
    final jsonString = jsonEncode(deductionsData);
    await _prefs!.setString(key, jsonString);
  }

  Future<Map<String, dynamic>> loadDeductionsData(int profileId) async {
    await initialize();
    final key = '${_deductionsDataKey}_$profileId';
    final jsonString = _prefs!.getString(key);

    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return _getDefaultDeductionsData();
      }
    }
    return _getDefaultDeductionsData();
  }

  Map<String, dynamic> _getDefaultDeductionsData() {
    return {
      'section_80c': 0.0,
      'section_80d': 0.0,
      'hra_amount': 0.0,
      'other_deductions': 0.0,
      'section_80c_details': <String, double>{},
      'section_80d_details': <String, double>{},
      'hra_details': <String, double>{},
      'other_details': <String, double>{},
    };
  }

  // Profile Management
  Future<void> saveProfiles(List<Map<String, dynamic>> profiles) async {
    await initialize();
    final profilesWithTimestamp = profiles.map((profile) {
      final updatedProfile = Map<String, dynamic>.from(profile);
      updatedProfile['lastModified'] =
          profile['lastModified']?.toIso8601String() ??
              DateTime.now().toIso8601String();
      return updatedProfile;
    }).toList();

    final jsonString = jsonEncode(profilesWithTimestamp);
    await _prefs!.setString(_profilesKey, jsonString);
  }

  Future<List<Map<String, dynamic>>> loadProfiles() async {
    await initialize();
    final jsonString = _prefs!.getString(_profilesKey);

    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded.map((profile) {
          final profileMap = Map<String, dynamic>.from(profile);
          if (profileMap['lastModified'] is String) {
            profileMap['lastModified'] =
                DateTime.parse(profileMap['lastModified']);
          }
          return profileMap;
        }).toList();
      } catch (e) {
        return _getDefaultProfiles();
      }
    }
    return _getDefaultProfiles();
  }

  List<Map<String, dynamic>> _getDefaultProfiles() {
    return [
      {
        "id": 1,
        "name": "My Tax Profile",
        "avatar": null,
        "lastCalculatedYear": "2024-25",
        "taxRegime": "New Regime",
        "totalIncome": 0.0,
        "taxPayable": 0.0,
        "lastModified": DateTime.now(),
        "isDefault": true,
        "isSynced": false,
      }
    ];
  }

  // Current Profile Management
  Future<void> setCurrentProfile(int profileId) async {
    await initialize();
    await _prefs!.setInt(_currentProfileKey, profileId);
  }

  Future<int> getCurrentProfile() async {
    await initialize();
    return _prefs!.getInt(_currentProfileKey) ?? 1;
  }

  // User Settings Management
  Future<void> saveUserSettings(Map<String, dynamic> settings) async {
    await initialize();
    final jsonString = jsonEncode(settings);
    await _prefs!.setString(_userSettingsKey, jsonString);
  }

  Future<Map<String, dynamic>> loadUserSettings() async {
    await initialize();
    final jsonString = _prefs!.getString(_userSettingsKey);

    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return _getDefaultSettings();
      }
    }
    return _getDefaultSettings();
  }

  Map<String, dynamic> _getDefaultSettings() {
    return {
      'theme_mode': 'light',
      'currency_format': 'INR',
      'calculation_mode': 'annual',
      'notifications_enabled': true,
    };
  }

  // Additional Income Settings
  Future<void> saveIncomeSettings(
      int profileId, Map<String, dynamic> settings) async {
    await initialize();
    final key = 'income_settings_$profileId';
    final jsonString = jsonEncode(settings);
    await _prefs!.setString(key, jsonString);
  }

  Future<Map<String, dynamic>> loadIncomeSettings(int profileId) async {
    await initialize();
    final key = 'income_settings_$profileId';
    final jsonString = _prefs!.getString(key);

    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return _getDefaultIncomeSettings();
      }
    }
    return _getDefaultIncomeSettings();
  }

  Map<String, dynamic> _getDefaultIncomeSettings() {
    return {
      'is_monthly': true,
      'selected_city_tier': 'metro',
      'selected_capital_gains_type': 'short_term_normal',
    };
  }

  // Clear all data for a profile
  Future<void> clearProfileData(int profileId) async {
    await initialize();
    await _prefs!.remove('${_incomeDataKey}_$profileId');
    await _prefs!.remove('${_deductionsDataKey}_$profileId');
    await _prefs!.remove('income_settings_$profileId');
  }

  // Clear all data
  Future<void> clearAllData() async {
    await initialize();
    await _prefs!.clear();
  }

  // Export profile data
  Future<Map<String, dynamic>> exportProfileData(int profileId) async {
    final incomeData = await loadIncomeData(profileId);
    final deductionsData = await loadDeductionsData(profileId);
    final incomeSettings = await loadIncomeSettings(profileId);

    return {
      'profile_id': profileId,
      'income_data': incomeData,
      'deductions_data': deductionsData,
      'income_settings': incomeSettings,
      'export_timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Import profile data
  Future<void> importProfileData(
      int profileId, Map<String, dynamic> data) async {
    if (data['income_data'] != null) {
      await saveIncomeData(
          profileId,
          Map<String, Map<String, String>>.from(data['income_data']
              .map((k, v) => MapEntry(k, Map<String, String>.from(v)))));
    }

    if (data['deductions_data'] != null) {
      await saveDeductionsData(profileId, data['deductions_data']);
    }

    if (data['income_settings'] != null) {
      await saveIncomeSettings(profileId, data['income_settings']);
    }
  }
}
