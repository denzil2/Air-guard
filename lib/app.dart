
import 'package:flutter/material.dart';

import 'config/theme.dart';
import 'config/routes.dart';

class AirQualityApp extends StatelessWidget {
  const AirQualityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AirGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
