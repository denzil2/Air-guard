import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/location_provider.dart';
import '../widgets/glass_card.dart';

/// Screen to let the user set their home location.
/// Uses a simple lat/lng input + map placeholder.
/// Replace the form with a Google Maps picker in production.
class SetHomeScreen extends StatefulWidget {
  const SetHomeScreen({super.key});

  @override
  State<SetHomeScreen> createState() => _SetHomeScreenState();
}

class _SetHomeScreenState extends State<SetHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isSaving = false;
  bool _isDetectingGps = false;

  @override
  void initState() {
    super.initState();
    final home = context.read<LocationProvider>().homeLocation;
    if (home != null) {
      _latController.text = home.latitude.toString();
      _lngController.text = home.longitude.toString();
      _addressController.text = home.address;
    }
  }

  Future<void> _detectCurrentGpsLocation() async {
    setState(() => _isDetectingGps = true);
    final locProvider = context.read<LocationProvider>();
    final pos = await locProvider.getCurrentPosition();

    if (mounted) {
      setState(() => _isDetectingGps = false);
      if (pos != null) {
        _latController.text = pos.latitude.toStringAsFixed(6);
        _lngController.text = pos.longitude.toStringAsFixed(6);
        if (_addressController.text.trim().isEmpty) {
          _addressController.text = 'Home (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('GPS location detected!'),
            backgroundColor: AppTheme.accentGreen.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(locProvider.error ?? 'Could not detect location. Check GPS permissions.'),
            backgroundColor: AppTheme.accentRed.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    await context.read<LocationProvider>().setHomeLocation(
          latitude: double.parse(_latController.text.trim()),
          longitude: double.parse(_lngController.text.trim()),
          address: _addressController.text.trim(),
        );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Home location saved!'),
          backgroundColor: AppTheme.accentGreen.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Home Location')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Map placeholder ────────────────────────────────────
          GlassCard(
            padding: EdgeInsets.zero,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppTheme.surfaceLight,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.map_rounded,
                          size: 48,
                          color: AppTheme.accent.withOpacity(0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Map Preview',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add Google Maps API key for\ninteractive map picker',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.2),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Home pin overlay
                  const Center(
                    child: Icon(
                      Icons.location_on,
                      size: 40,
                      color: AppTheme.accentRed,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Geofence info ─────────────────────────────────────
          GlassCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.radar,
                    color: AppTheme.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Geofence Radius: 200m',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'You\'ll be notified when you leave or enter this zone',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Form ──────────────────────────────────────────────
          Form(
            key: _formKey,
            child: Column(
              children: [
                _buildField(
                  controller: _addressController,
                  label: 'Address / Label',
                  hint: 'e.g. My Home, Office',
                  icon: Icons.home_rounded,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter an address' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: _latController,
                        label: 'Latitude',
                        hint: '28.6139',
                        icon: Icons.north,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          final d = double.tryParse(v.trim());
                          if (d == null || d < -90 || d > 90) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        controller: _lngController,
                        label: 'Longitude',
                        hint: '77.2090',
                        icon: Icons.east,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          final d = double.tryParse(v.trim());
                          if (d == null || d < -180 || d > 180) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _latController.text = '28.6139';
                        _lngController.text = '77.2090';
                        _addressController.text = 'New Delhi, India';
                      },
                      icon: const Icon(Icons.location_city, size: 16),
                      label: const Text('Demo Delhi'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white54,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isDetectingGps ? null : _detectCurrentGpsLocation,
                      icon: _isDetectingGps
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.background),
                            )
                          : const Icon(Icons.my_location, size: 16),
                      label: Text(_isDetectingGps ? 'Detecting...' : 'Use Current GPS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: AppTheme.background,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Save Button ───────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.background,
                      ),
                    )
                  : const Text(
                      'Save Home Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Clear button ──────────────────────────────────────
          Consumer<LocationProvider>(
            builder: (context, loc, _) {
              if (!loc.hasHome) return const SizedBox.shrink();
              return Center(
                child: TextButton(
                  onPressed: () async {
                    await loc.clearHome();
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text(
                    'Remove Home Location',
                    style: TextStyle(color: AppTheme.accentRed),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
        prefixIcon: Icon(icon, color: AppTheme.accent, size: 20),
        filled: true,
        fillColor: AppTheme.surfaceLight.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.accentRed),
        ),
      ),
    );
  }
}
