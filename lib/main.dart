import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: VigilApp()));
}

class VigilApp extends ConsumerWidget {
  const VigilApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'VIGIL',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark, // VIGIL only operates in dark mode
      routerConfig: appRouter,
    );
  }
}
