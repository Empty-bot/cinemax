import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

class CinemaxApp extends StatelessWidget {
  const CinemaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.select<ThemeProvider, ThemeMode>((p) => p.mode);

    return MaterialApp(
      title: 'Cinemax',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      themeAnimationDuration: const Duration(milliseconds: 400),
      home: const MainShell(),
    );
  }
}
