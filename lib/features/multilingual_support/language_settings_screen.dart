import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('English'),
            onTap: () => context.setLocale(const Locale('en')),
            trailing:
                context.locale.languageCode == 'en'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
          ),
          ListTile(
            title: const Text('اردو'),
            onTap: () => context.setLocale(const Locale('ur')),
            trailing:
                context.locale.languageCode == 'ur'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
          ),
          ListTile(
            title: const Text('हिंदी'),
            onTap: () => context.setLocale(const Locale('hi')),
            trailing:
                context.locale.languageCode == 'hi'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
          ),
          ListTile(
            title: const Text('العربية'),
            onTap: () => context.setLocale(const Locale('ar')),
            trailing:
                context.locale.languageCode == 'ar'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
          ),
        ],
      ),
    );
  }
}
