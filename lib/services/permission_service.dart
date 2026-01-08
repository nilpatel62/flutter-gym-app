import 'package:permission_handler/permission_handler.dart';

/// Service to initialize and request permissions early in the app lifecycle
/// This ensures permissions appear in iOS Settings even if not immediately used
class PermissionService {
  /// Initialize permissions - requests them silently in the background
  /// This makes them appear in iOS Settings
  /// Uses batch request for better performance and user experience
  static Future<void> initializePermissions() async {
    try {
      // Request multiple permissions simultaneously
      final statuses = await [
        Permission.camera,
        Permission.microphone,
        Permission.photos,
        Permission.notification,
      ].request();

      // Handle each status as needed
      // Camera status: ${statuses[Permission.camera]}
      // Microphone status: ${statuses[Permission.microphone]}
      // Photos status: ${statuses[Permission.photos]}
      // Notification status: ${statuses[Permission.notification]}

      // Note: Local Network permission is automatically handled by iOS
      // when the app uses network services (like ML Kit)
    } catch (e) {
      // Silently handle errors - permissions will be requested when needed
      print('Permission initialization error: $e');
    }
  }

  /// Check if all required permissions are granted
  static Future<bool> checkRequiredPermissions() async {
    final cameraStatus = await Permission.camera.status;
    return cameraStatus.isGranted;
  }
}

