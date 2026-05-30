import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/location_service.dart';

class LocationPermissionScreen extends StatefulWidget {
  final VoidCallback onPermissionGranted;

  const LocationPermissionScreen({super.key, required this.onPermissionGranted});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isChecking = false;

  Future<void> _checkAndRequestPermission() async {
    setState(() => _isChecking = true);
    final locationService = LocationService.getInstance();
    
    LocationPermission permission = await locationService.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await locationService.requestPermission();
    }
    
    setState(() => _isChecking = false);

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      widget.onPermissionGranted();
    } else if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'Location permission is mandatory to run NearMe. Please enable it in system settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Geolocator.openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E27) : const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 50,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Location Access Required',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'NearMe is a hyperlocal network showing you the communities and people within 5 km of you. Location permission is mandatory to continue.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? const Color(0xFF8A9BC0) : Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: _isChecking
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _checkAndRequestPermission,
                        child: const Text(
                          'Allow Location Access',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
