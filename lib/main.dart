import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/aqi_provider.dart';
import 'providers/location_provider.dart';
import 'providers/geofence_provider.dart';
import 'providers/route_provider.dart';
import 'providers/score_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AqiProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => GeofenceProvider()),
        ChangeNotifierProvider(create: (_) => RouteProvider()),
        ChangeNotifierProvider(create: (_) => ScoreProvider()),
      ],
      child: const AirQualityApp(),
    ),
  );
}
