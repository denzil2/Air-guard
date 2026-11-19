import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/aqi_provider.dart';
import '../providers/location_provider.dart';
import '../providers/geofence_provider.dart';
import '../widgets/aqi_gauge.dart';
import '../widgets/glass_card.dart';
import '../widgets/geofence_status_widget.dart';
import '../widgets/health_tip_card.dart';
import '../widgets/forecast_chart.dart';
import '../utils/aqi_utils.dart';
import '../utils/format_utils.dart';

/// Main dashboard screen – the first thing the user sees.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final locProvider = context.read<LocationProvider>();
    final aqiProvider = context.read<AqiProvider>();
    final geofenceProvider = context.read<GeofenceProvider>();

    await locProvider.loadHome();

    // 1. Try to get real current GPS position first
    final pos = await locProvider.getCurrentPosition();
    final double lat = pos?.latitude ?? locProvider.homeLocation?.latitude ?? 28.6139;
    final double lng = pos?.longitude ?? locProvider.homeLocation?.longitude ?? 77.2090;

    if (mounted) {
      // 2. Fetch real AQI for actual location
      aqiProvider.fetchAqi(lat, lng);

      // 3. Evaluate initial geofence state if home is configured
      if (locProvider.hasHome && locProvider.currentPosition != null) {
        geofenceProvider.evaluate(
          position: locProvider.currentPosition!,
          home: locProvider.homeLocation!,
          currentAqi: aqiProvider.currentAqi?.aqi ?? 0,
        );
      }

      // 4. Start continuous real-time GPS tracking stream
      await locProvider.startTracking(distanceFilterMeters: 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTab,
        children: const [
          _DashboardTab(),
          _ExploreTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.cardBorder, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (i) => setState(() => _currentTab = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Dashboard Tab
// ════════════════════════════════════════════════════════════════
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AqiProvider>(
      builder: (context, aqiProvider, _) {
        final aqi = aqiProvider.currentAqi;

        return RefreshIndicator(
          onRefresh: () => aqiProvider.refresh(),
          color: AppTheme.accent,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── App Bar ──────────────────────────────────────
              SliverAppBar(
                floating: true,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.air, color: AppTheme.accent, size: 24),
                    const SizedBox(width: 8),
                    const Text('AirGuard'),
                  ],
                ),
                actions: [
                  // Live indicator
                  if (aqi != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGreen,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppTheme.accentGreen.withOpacity(0.5),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'LIVE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.accentGreen,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),

                    // ── Location & station name ────────────────
                    Consumer<LocationProvider>(
                      builder: (context, loc, _) {
                        return Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: AppTheme.accent),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                aqi?.locationName ??
                                    loc.homeLocation?.address ??
                                    'Set your location',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (aqi != null)
                              Text(
                                'Updated ${FormatUtils.time(aqi.timestamp)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Error state ─────────────────────────────
                    if (aqiProvider.error != null && aqi == null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              const Icon(Icons.cloud_off,
                                  size: 48, color: AppTheme.accentOrange),
                              const SizedBox(height: 12),
                              Text(
                                aqiProvider.error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => aqiProvider.refresh(),
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accent,
                                  foregroundColor: AppTheme.background,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )

                    // ── Loading state ───────────────────────────
                    else if (aqiProvider.isLoading && aqi == null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(60),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(
                                color: AppTheme.accent,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Fetching live AQI data...',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )

                    // ── Live AQI Gauge + content ────────────────
                    else if (aqi != null) ...[
                      Center(child: AqiGauge(aqi: aqi.aqi)),

                      const SizedBox(height: 18),

                      // ── AQI Category & Status Banner ─────────
                      _AqiStatusBanner(aqi: aqi),

                      const SizedBox(height: 18),

                      // Quick action chips
                      _QuickActions(),

                      const SizedBox(height: 24),

                      // ── Geofence Status ──────────────────────
                      Consumer2<LocationProvider, GeofenceProvider>(
                        builder: (context, loc, gf, _) {
                          if (loc.hasHome && loc.currentPosition != null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              gf.evaluate(
                                position: loc.currentPosition!,
                                home: loc.homeLocation!,
                                currentAqi: aqi.aqi,
                              );
                            });
                          }
                          return GeofenceStatusWidget(data: gf.data);
                        },
                      ),

                      const SizedBox(height: 16),

                      // ── Forecast Chart ───────────────────────
                      ForecastChart(forecast: aqiProvider.forecast),

                      const SizedBox(height: 16),

                      // ── Health Tip ───────────────────────────
                      HealthTipCard(aqi: aqi.aqi),

                      const SizedBox(height: 32),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AqiStatusBanner extends StatelessWidget {
  final dynamic aqi;

  const _AqiStatusBanner({required this.aqi});

  @override
  Widget build(BuildContext context) {
    final color = AqiUtils.colorForAqi(aqi.aqi);
    final label = AqiUtils.labelForAqi(aqi.aqi);
    final emoji = AqiUtils.emojiForAqi(aqi.aqi);
    final advice = AqiUtils.adviceForAqi(aqi.aqi);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  advice,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionChip(
          icon: Icons.score,
          label: 'Score',
          onTap: () => Navigator.pushNamed(context, AppRoutes.score),
        ),
        const SizedBox(width: 10),
        _ActionChip(
          icon: Icons.map_outlined,
          label: 'Routes',
          onTap: () => Navigator.pushNamed(context, AppRoutes.routeMap),
        ),
        const SizedBox(width: 10),
        _ActionChip(
          icon: Icons.info_outline,
          label: 'Details',
          onTap: () => Navigator.pushNamed(context, AppRoutes.aqiDetail),
        ),
        const SizedBox(width: 10),
        _ActionChip(
          icon: Icons.home_outlined,
          label: 'Set Home',
          onTap: () => Navigator.pushNamed(context, AppRoutes.setHome),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.accent, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Explore Tab
// ════════════════════════════════════════════════════════════════
class _ExploreTab extends StatelessWidget {
  const _ExploreTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Explore',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Discover air quality around you',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            const SizedBox(height: 32),
            _ExploreCard(
              icon: Icons.map_rounded,
              title: 'Low-Pollution Routes',
              subtitle: 'Find the cleanest path to your destination',
              color: AppTheme.accentGreen,
              onTap: () => Navigator.pushNamed(context, AppRoutes.routeMap),
            ),
            const SizedBox(height: 16),
            _ExploreCard(
              icon: Icons.analytics_rounded,
              title: 'Health Score',
              subtitle: 'View your exposure score breakdown',
              color: AppTheme.accent,
              onTap: () => Navigator.pushNamed(context, AppRoutes.score),
            ),
            const SizedBox(height: 16),
            _ExploreCard(
              icon: Icons.bar_chart_rounded,
              title: 'Detailed AQI',
              subtitle: 'Pollutant breakdown and history',
              color: AppTheme.accentOrange,
              onTap: () => Navigator.pushNamed(context, AppRoutes.aqiDetail),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ExploreCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Profile Tab
// ════════════════════════════════════════════════════════════════
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            GlassCard(
              child: Consumer<LocationProvider>(
                builder: (context, loc, _) {
                  return Column(
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundColor: AppTheme.surfaceLight,
                        child:
                            Icon(Icons.person, size: 40, color: AppTheme.accent),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Air Quality User',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.hasHome
                            ? '📍 ${loc.homeLocation!.address}'
                            : 'No home location set',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _ProfileTile(
              icon: Icons.home_rounded,
              label: 'Set Home Location',
              onTap: () => Navigator.pushNamed(context, AppRoutes.setHome),
            ),
            const SizedBox(height: 10),
            _ProfileTile(
              icon: Icons.tune,
              label: 'Notification Settings',
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _ProfileTile(
              icon: Icons.info_outline,
              label: 'About AirGuard',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
        ],
      ),
    );
  }
}
