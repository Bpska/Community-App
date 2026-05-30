import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/location_service.dart';
import '../../../core/models/community_model.dart';
import '../../community/providers/community_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../community/screens/community_detail_screen.dart';
import '../../../core/config/theme_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  String _locationText = 'Fetching location...';
  bool _locationLoading = true;
  bool _mapReady = false;

  // Default center (India) – overridden once GPS arrives
  LatLng _center = const LatLng(20.5937, 78.9629);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocation();
      context.read<CommunityProvider>().fetchCommunities();
    });
  }

  // ─────────────── Location ───────────────

  Future<void> _fetchLocation() async {
    try {
      final locationService = LocationService.getInstance();
      final position = await locationService.getCurrentPosition();
      if (position != null && mounted) {
        String newLocationText = '';
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            if (place.locality != null && place.locality!.isNotEmpty) {
              newLocationText = place.locality!;
              if (place.country != null && place.country!.isNotEmpty) {
                newLocationText += ', ${place.country}';
              }
            } else if (place.subAdministrativeArea != null &&
                place.subAdministrativeArea!.isNotEmpty) {
              newLocationText = place.subAdministrativeArea!;
            }
          }
        } catch (_) {}

        setState(() {
          _currentPosition = position;
          _center = LatLng(position.latitude, position.longitude);
          _locationText = newLocationText.isNotEmpty
              ? newLocationText
              : '${position.latitude.toStringAsFixed(4)}°N, ${position.longitude.toStringAsFixed(4)}°E';
          _locationLoading = false;
        });

        if (_mapReady) {
          _animateMapTo(_center);
        }
      } else if (mounted) {
        setState(() {
          _locationText = 'Location unavailable';
          _locationLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _locationText = 'Location unavailable';
          _locationLoading = false;
        });
      }
    }
  }

  void _animateMapTo(LatLng target) {
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: target.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: target.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: 14.0,
    );
    final controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    final animation =
        CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) controller.dispose();
    });
    controller.forward();
  }

  Future<void> _handleRefresh() async {
    _fetchLocation();
    await context.read<CommunityProvider>().fetchCommunities();
  }

  // ─────────────── Bottom Sheet ───────────────

  void _showCommunitySheet(CommunityModel community) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? NearMeColors.navyCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(
              color: isDark ? NearMeColors.navyBorder : Colors.grey.shade200,
              width: 1.5,
            ),
            left: BorderSide(
              color: isDark ? NearMeColors.navyBorder : Colors.grey.shade200,
              width: 1.5,
            ),
            right: BorderSide(
              color: isDark ? NearMeColors.navyBorder : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(150),
              blurRadius: 30,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? NearMeColors.navyBorder : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header row
            Row(
              children: [
                // Logo with errorBuilder
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: community.logo != null
                      ? Image.network(
                          community.logo!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildLogoFallback(community),
                        )
                      : _buildLogoFallback(community),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        community.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: isDark ? NearMeColors.textPrimary : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.people_rounded,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            '${community.membersCount} members',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: community.type == 'public'
                                  ? NearMeColors.success.withAlpha(25)
                                  : NearMeColors.gold.withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              community.type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: community.type == 'public'
                                    ? NearMeColors.success
                                    : NearMeColors.gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Description
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                community.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? NearMeColors.textSecondary : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Creator
            if (community.creatorName != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Created by ${community.creatorName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? NearMeColors.textMuted : Colors.grey[500],
                  ),
                ),
              ),
            const SizedBox(height: 18),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CommunityDetailScreen(community: community),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('View Community'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoFallback(CommunityModel community) {
    return Container(
      color: NearMeColors.gold.withAlpha(40),
      child: Center(
        child: Text(
          community.name.isNotEmpty ? community.name[0].toUpperCase() : 'C',
          style: const TextStyle(
            color: NearMeColors.gold,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ─────────────── Markers ───────────────

  List<Marker> _buildMarkers(List<CommunityModel> communities) {
    final markers = <Marker>[];

    // User location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(
              _currentPosition!.latitude, _currentPosition!.longitude),
          width: 32,
          height: 32,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFF3B82F6), width: 2.5),
            ),
            child: const Center(
              child: Icon(Icons.circle,
                  color: Color(0xFF3B82F6), size: 14),
            ),
          ),
        ),
      );
    }

    // Community markers
    final colors = [
      const Color(0xFFEF4444),
      const Color(0xFFF97316),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
      const Color(0xFFEAB308),
    ];

    for (int i = 0; i < communities.length; i++) {
      final c = communities[i];
      if (c.latitude == null || c.longitude == null) continue;
      final color = colors[i % colors.length];

      markers.add(
        Marker(
          point: LatLng(c.latitude!, c.longitude!),
          width: 46,
          height: 58,
          child: GestureDetector(
            onTap: () => _showCommunitySheet(c),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                _PinTail(color: color),
              ],
            ),
          ),
        ),
      );
    }

    return markers;
  }

  // ─────────────── Build ───────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUser = context.watch<AuthProvider>().currentUser;

    // Adaptive overlay colours
    final overlayBg = isDark
        ? NearMeColors.navyCard.withAlpha(235)
        : Colors.white.withAlpha(230);
    final overlayBorder = isDark
        ? NearMeColors.navyBorder.withAlpha(120)
        : Colors.grey.shade200;
    final textPrimary = isDark ? NearMeColors.textPrimary : const Color(0xFF111827);
    final textSub = isDark ? NearMeColors.textSecondary : Colors.grey[600]!;

    return Scaffold(
      body: Stack(
        children: [
          // ── Map (OSM tiles) ──
          Consumer<CommunityProvider>(
            builder: (context, provider, _) {
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: 13.0,
                  minZoom: 3,
                  maxZoom: 19,
                  onMapReady: () {
                    _mapReady = true;
                    if (_currentPosition != null) {
                      _animateMapTo(_center);
                    }
                  },
                ),
                children: [
                  // OpenStreetMap – free, reliable, no API key needed
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.community.nearme',
                    maxZoom: 19,
                    // Respect OSM tile usage policy
                    additionalOptions: const {
                      'attribution':
                          '© OpenStreetMap contributors',
                    },
                  ),
                  MarkerLayer(
                    markers: _buildMarkers(provider.communities),
                  ),
                ],
              );
            },
          ),

          // ── Top Greeting Bar ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: overlayBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: overlayBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 120 : 40),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hello, ${currentUser?.name ?? 'User'} 👋',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: NearMeColors.gold, size: 14),
                      const SizedBox(width: 4),
                      if (_locationLoading)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: NearMeColors.gold,
                          ),
                        ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _locationText,
                          style: TextStyle(
                            color: textSub,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Communities count chip ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 96,
            left: 16,
            child: Consumer<CommunityProvider>(
              builder: (context, provider, _) {
                final total = provider.communities.length;
                final onMap = provider.communities
                    .where((c) => c.latitude != null && c.longitude != null)
                    .length;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: overlayBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: overlayBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 80 : 30),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people_alt_rounded,
                          size: 14, color: NearMeColors.gold),
                      const SizedBox(width: 6),
                      Text(
                        '$total communities  •  $onMap on map',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── FABs ──
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MapFAB(
                  icon: Icons.refresh_rounded,
                  onPressed: _handleRefresh,
                  heroTag: 'refresh',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _MapFAB(
                  icon: Icons.my_location_rounded,
                  onPressed: () {
                    if (_currentPosition != null) {
                      _animateMapTo(LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ));
                    }
                  },
                  heroTag: 'my_location',
                  accent: true,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // ── Loading overlay ──
          Consumer<CommunityProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && provider.communities.isEmpty) {
                return Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.15),
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _PinTail extends StatelessWidget {
  final Color color;
  const _PinTail({required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -2),
      child: Transform.rotate(
        angle: 0.785398, // 45 degrees
        child: Container(
          width: 8,
          height: 8,
          color: color,
        ),
      ),
    );
  }
}

class _MapFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String heroTag;
  final bool accent;
  final bool isDark;

  const _MapFAB({
    required this.icon,
    required this.onPressed,
    required this.heroTag,
    required this.isDark,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: FloatingActionButton(
        heroTag: heroTag,
        onPressed: onPressed,
        elevation: 6,
        backgroundColor: accent
            ? NearMeColors.gold
            : (isDark ? NearMeColors.navyCard : Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark ? NearMeColors.navyBorder : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 22,
          color: accent
              ? Colors.black
              : (isDark ? NearMeColors.textPrimary : const Color(0xFF111827)),
        ),
      ),
    );
  }
}
