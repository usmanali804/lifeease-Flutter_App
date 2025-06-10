import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool reminderEnabled;

  const NotificationSettings({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.reminderEnabled,
  });

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? reminderEnabled,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'pushEnabled': pushEnabled,
    'emailEnabled': emailEnabled,
    'reminderEnabled': reminderEnabled,
  };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['pushEnabled'] as bool,
      emailEnabled: json['emailEnabled'] as bool,
      reminderEnabled: json['reminderEnabled'] as bool,
    );
  }
}

class NotificationSettingsProvider with ChangeNotifier {
  static const String _settingsKey = 'notification_settings';
  final SharedPreferences _prefs;
  NotificationSettings _settings;

  NotificationSettingsProvider(this._prefs)
    : _settings = NotificationSettings.fromJson(
        Map<String, dynamic>.from(
          _prefs.getString(_settingsKey) != null
              ? jsonDecode(_prefs.getString(_settingsKey)!)
              : {
                'pushEnabled': true,
                'emailEnabled': true,
                'reminderEnabled': true,
              },
        ),
      );

  NotificationSettings get settings => _settings;

  Future<void> updateSettings(NotificationSettings newSettings) async {
    _settings = newSettings;
    await _prefs.setString(_settingsKey, jsonEncode(newSettings.toJson()));
    notifyListeners();
  }

  Future<void> togglePushNotifications(bool value) async {
    await updateSettings(_settings.copyWith(pushEnabled: value));
  }

  Future<void> toggleEmailNotifications(bool value) async {
    await updateSettings(_settings.copyWith(emailEnabled: value));
  }

  Future<void> toggleReminderNotifications(bool value) async {
    await updateSettings(_settings.copyWith(reminderEnabled: value));
  }
}
