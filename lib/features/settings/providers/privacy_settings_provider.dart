import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacySettings {
  final bool analyticsEnabled;
  final bool personalizationEnabled;

  const PrivacySettings({
    required this.analyticsEnabled,
    required this.personalizationEnabled,
  });

  PrivacySettings copyWith({
    bool? analyticsEnabled,
    bool? personalizationEnabled,
  }) {
    return PrivacySettings(
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      personalizationEnabled:
          personalizationEnabled ?? this.personalizationEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'analyticsEnabled': analyticsEnabled,
    'personalizationEnabled': personalizationEnabled,
  };

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      analyticsEnabled: json['analyticsEnabled'] as bool,
      personalizationEnabled: json['personalizationEnabled'] as bool,
    );
  }
}

class PrivacySettingsProvider with ChangeNotifier {
  static const String _settingsKey = 'privacy_settings';
  final SharedPreferences _prefs;
  late final PrivacySettings _settings;

  PrivacySettingsProvider(this._prefs) {
    _settings = PrivacySettings.fromJson(
      Map<String, dynamic>.from(
        _prefs.getString(_settingsKey) != null
            ? jsonDecode(_prefs.getString(_settingsKey)!)
            : {'analyticsEnabled': false, 'personalizationEnabled': false},
      ),
    );
  }

  PrivacySettings get settings => _settings;

  Future<void> updateSettings(PrivacySettings newSettings) async {
    _settings = newSettings;
    await _prefs.setString(_settingsKey, jsonEncode(newSettings.toJson()));
    notifyListeners();
  }

  Future<void> toggleAnalytics(bool value) async {
    await updateSettings(_settings.copyWith(analyticsEnabled: value));
  }

  Future<void> togglePersonalization(bool value) async {
    await updateSettings(_settings.copyWith(personalizationEnabled: value));
  }

  Future<void> exportData() async {
    // TODO: Implement data export functionality
    // This will be implemented based on what data needs to be exported
  }

  Future<void> deleteAccount() async {
    // TODO: Implement account deletion
    // This will require integration with the backend services
  }
}
