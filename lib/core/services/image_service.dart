import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ImageService {
  static ImageService? _instance;
  final ImagePicker _picker = ImagePicker();

  static ImageService getInstance() {
    _instance ??= ImageService();
    return _instance!;
  }

  // Request camera permission
  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Request gallery/photos permission
  Future<bool> _requestGalleryPermission() async {
    try {
      // Android 13+ uses READ_MEDIA_IMAGES (photos), older uses READ_EXTERNAL_STORAGE
      if (Platform.isAndroid) {
        // Request photos permission first
        final photos = await Permission.photos.request();
        if (photos.isGranted) return true;
        
        // Request storage permission
        final storage = await Permission.storage.request();
        if (storage.isGranted) return true;
        
        // Fallback: On Android, ImagePicker can often work without permission by using the system picker
        return true; 
      } else {
        // iOS
        final status = await Permission.photos.request();
        return status.isGranted || status.isLimited;
      }
    } catch (_) {
      return true; // Fallback to let image_picker try
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) {
      print('Camera permission denied');
      return null;
    }
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null) return File(image.path);
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    final hasPermission = await _requestGalleryPermission();
    if (!hasPermission) {
      print('Gallery permission denied');
      return null;
    }
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null) return File(image.path);
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // Generic pick image – requests the right permission based on source
  Future<File?> pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) return null;
    } else {
      final hasPermission = await _requestGalleryPermission();
      if (!hasPermission) return null;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null) return File(image.path);
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }
}
