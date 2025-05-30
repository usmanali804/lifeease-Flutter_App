import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Locale>(
      value: context.locale,
      items: const [
        DropdownMenuItem(value: Locale('en'), child: Text('English 🇺🇸')),
        DropdownMenuItem(value: Locale('ur'), child: Text('اردو 🇵🇰')),
        DropdownMenuItem(value: Locale('hi'), child: Text('हिन्दी 🇮🇳')),
        DropdownMenuItem(value: Locale('ar'), child: Text('العربية 🇸🇦')),
      ],
      onChanged: (locale) {
        if (locale != null) context.setLocale(locale);
      },
    );
  }
}
