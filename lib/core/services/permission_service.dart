import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static PermissionService? _instance;

  static PermissionService getInstance() {
    _instance ??= PermissionService();
    return _instance!;
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Check location permission status
  Future<bool> hasLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  // Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Check camera permission status
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  // Request photo library permission
  Future<bool> requestPhotosPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  // Check photo library permission status
  Future<bool> hasPhotosPermission() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  // Open app settings
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  // Request all necessary permissions at once
  Future<Map<String, bool>> requestAllPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
      Permission.photos,
    ].request();

    return {
      'location': statuses[Permission.location]?.isGranted ?? false,
      'camera': statuses[Permission.camera]?.isGranted ?? false,
      'photos': statuses[Permission.photos]?.isGranted ?? false,
    };
  }
}
