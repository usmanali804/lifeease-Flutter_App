import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (bool value) {
                // TODO: Implement theme switching
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Push Notifications'),
            trailing: Switch(
              value: true,
              onChanged: (bool value) {
                // TODO: Implement notification settings
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Privacy Settings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Navigate to privacy settings
            },
          ),
        ],
      ),
    );
  }
}
