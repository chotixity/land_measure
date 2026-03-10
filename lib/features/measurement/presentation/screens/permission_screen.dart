import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:land_measure/core/theme/app_theme.dart';
import 'package:land_measure/features/measurement/presentation/widgets/feature_tile.dart';
import 'package:land_measure/features/measurement/presentation/screens/measurement_screen.dart';

enum _PermissionStatus {
  checking,
  notRequested,
  denied,
  deniedForever,
  serviceDisabled,
}

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with WidgetsBindingObserver {
  _PermissionStatus _status = _PermissionStatus.checking;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _status = _PermissionStatus.serviceDisabled);
      return;
    }

    final permission = await Geolocator.checkPermission();
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        _navigateToMeasurement();
      case LocationPermission.deniedForever:
        setState(() => _status = _PermissionStatus.deniedForever);
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        setState(() => _status = _PermissionStatus.notRequested);
    }
  }

  Future<void> _requestPermission() async {
    final permission = await Geolocator.requestPermission();
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        _navigateToMeasurement();
      case LocationPermission.deniedForever:
        setState(() => _status = _PermissionStatus.deniedForever);
      case LocationPermission.denied:
        setState(() => _status = _PermissionStatus.denied);
      case LocationPermission.unableToDetermine:
        setState(() => _status = _PermissionStatus.notRequested);
    }
  }

  void _navigateToMeasurement() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MeasurementScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: _status == _PermissionStatus.checking
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        size: 40,
                        color: AppColors.neonGreen,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _status == _PermissionStatus.serviceDisabled
                          ? 'Location Services Disabled'
                          : 'Location Access Required',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getDescription(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    const FeatureTile(
                      leading: Icons.gps_fixed,
                      title: 'GPS Tracking',
                      subtitle: 'Track your position as you walk the boundary',
                    ),
                    const SizedBox(height: 8),
                    const FeatureTile(
                      leading: Icons.square_foot,
                      title: 'Precise Measurements',
                      subtitle: 'Calculate accurate area and perimeter',
                    ),
                    const SizedBox(height: 8),
                    const FeatureTile(
                      leading: Icons.pin_drop,
                      title: 'Mark Coordinates',
                      subtitle: 'Drop pins at exact GPS locations',
                    ),
                    const Spacer(flex: 2),
                    _buildActionButton(),
                    if (_status == _PermissionStatus.denied ||
                        _status == _PermissionStatus.deniedForever)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Location permission is required to use this app.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.warning),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  String _getDescription() {
    switch (_status) {
      case _PermissionStatus.serviceDisabled:
        return 'Please enable location services on your device to use GPS-based land measurement.';
      case _PermissionStatus.deniedForever:
        return 'Location permission was permanently denied. Please grant it in your device settings to continue.';
      case _PermissionStatus.denied:
        return 'Location access was denied. Land Measure needs your GPS location to accurately measure land boundaries and calculate area.';
      default:
        return 'Land Measure uses your GPS location to accurately measure land boundaries and calculate area.';
    }
  }

  Widget _buildActionButton() {
    switch (_status) {
      case _PermissionStatus.serviceDisabled:
        return ElevatedButton.icon(
          onPressed: () => Geolocator.openLocationSettings(),
          icon: const Icon(Icons.settings),
          label: const Text('Enable Location'),
        );
      case _PermissionStatus.deniedForever:
        return ElevatedButton.icon(
          onPressed: () => Geolocator.openAppSettings(),
          icon: const Icon(Icons.settings),
          label: const Text('Open Settings'),
        );
      default:
        return ElevatedButton.icon(
          onPressed: _requestPermission,
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Grant Permission'),
        );
    }
  }
}
