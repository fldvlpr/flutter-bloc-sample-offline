import 'package:flutter/material.dart';
import 'package:flutter_bloc_sample_offline/core/router/app_router.dart';
import 'core/di/injection.dart' as di;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 1. Initialize Dependency Injection
  di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Offline Notes App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      // 2. Attach our go_router configuration
      routerConfig: appRouter,
    );
  }
}
