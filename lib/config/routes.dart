import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/aqi_detail_screen.dart';
import '../screens/set_home_screen.dart';
import '../screens/route_map_screen.dart';
import '../screens/score_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String aqiDetail = '/aqi-detail';
  static const String setHome = '/set-home';
  static const String routeMap = '/route-map';
  static const String score = '/score';

  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomeScreen(),
        aqiDetail: (_) => const AqiDetailScreen(),
        setHome: (_) => const SetHomeScreen(),
        routeMap: (_) => const RouteMapScreen(),
        score: (_) => const ScoreScreen(),
      };
}
