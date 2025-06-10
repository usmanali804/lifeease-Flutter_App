import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_settings_provider.dart';
import 'screens/privacy_settings_screen.dart';
import '../../shared/widgets/settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SettingsSection(
            title: 'Appearance',
            children: [
              Consumer<ThemeProvider>(
                builder:
                    (context, themeProvider, _) => SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Use dark theme'),
                      secondary: const Icon(Icons.dark_mode),
                      value: themeProvider.isDarkMode,
                      onChanged: (_) => themeProvider.toggleTheme(),
                    ),
              ),
            ],
          ),
          SettingsSection(
            title: 'Notifications',
            children: [
              Consumer<NotificationSettingsProvider>(
                builder:
                    (context, provider, _) => Column(
                      children: [
                        SwitchListTile(
                          secondary: const Icon(Icons.notifications),
                          title: const Text('Push Notifications'),
                          value: provider.settings.pushEnabled,
                          onChanged: provider.togglePushNotifications,
                        ),
                        SwitchListTile(
                          secondary: const Icon(Icons.email),
                          title: const Text('Email Notifications'),
                          value: provider.settings.emailEnabled,
                          onChanged: provider.toggleEmailNotifications,
                        ),
                        SwitchListTile(
                          secondary: const Icon(Icons.alarm),
                          title: const Text('Task Reminders'),
                          value: provider.settings.reminderEnabled,
                          onChanged: provider.toggleReminderNotifications,
                        ),
                      ],
                    ),
              ),
            ],
          ),
          SettingsSection(
            title: 'Privacy & Security',
            children: [
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Privacy Settings'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacySettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
