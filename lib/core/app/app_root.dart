import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/application_services.dart';
import '../services/application_services_provider.dart';
import 'app.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApplicationServices.instance.initialize(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error initializing app: ${snapshot.error}'),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return ApplicationServicesProvider(
          services: ApplicationServices.instance,
          child: const App(),
        );
      },
    );
  }
}
