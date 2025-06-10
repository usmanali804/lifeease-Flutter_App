import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/settings_section.dart';
import '../providers/privacy_settings_provider.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Settings')),
      body: Consumer<PrivacySettingsProvider>(
        builder: (context, provider, child) => ListView(
          children: [
            SettingsSection(
              title: 'Data Collection',
              children: [
                SwitchListTile(
                  title: const Text('Analytics'),
                  subtitle: const Text(
                    'Help us improve by sending anonymous usage data',
                  ),
                  value: provider.settings.analyticsEnabled,
                  onChanged: provider.toggleAnalytics,
                ),
                SwitchListTile(
                  title: const Text('Personalization'),
                  subtitle: const Text(
                    'Customize your experience based on your usage',
                  ),
                  value: provider.settings.personalizationEnabled,
                  onChanged: provider.togglePersonalization,
                ),
              ],
            ),
            SettingsSection(
              title: 'Data Management',
              children: [
                ListTile(
                  title: const Text('Export Data'),
                  leading: const Icon(Icons.download),
                  onTap: () => provider.exportData(),
                ),
                ListTile(
                  title: const Text('Delete Account'),
                  leading: const Icon(Icons.delete_forever),
                  textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Delete Account'),
                          content: const Text(
                            'Are you sure you want to delete your account? This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO: Implement account deletion
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
