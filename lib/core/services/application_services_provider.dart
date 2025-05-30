import 'package:flutter/material.dart';
import 'application_services.dart';

class ApplicationServicesProvider extends InheritedWidget {
  final ApplicationServices services;

  const ApplicationServicesProvider({
    super.key,
    required this.services,
    required super.child,
  });

  static ApplicationServices of(BuildContext context) {
    final provider =
        context
            .dependOnInheritedWidgetOfExactType<ApplicationServicesProvider>();
    assert(provider != null, 'No ApplicationServicesProvider found in context');
    return provider!.services;
  }

  @override
  bool updateShouldNotify(ApplicationServicesProvider oldWidget) => false;
}
