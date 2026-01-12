import 'package:permission_handler/permission_handler.dart';

/// Centralized service for handling camera permissions throughout the app
class PermissionService {
  /// Request camera permission with proper flow handling
  /// Returns the permission status after the request
  ///
  /// Flow:
  /// 1. Check current permission status
  /// 2. If permanently denied -> Return status (caller should open settings)
  /// 3. If not granted -> Request permission
  /// 4. Return final status
  static Future<PermissionStatus> requestCameraPermission() async {
    try {
      // Step 1: Check current permission status
      final currentStatus = await Permission.camera.status;

      // Step 2: If permanently denied, can't request - return immediately
      if (currentStatus.isPermanentlyDenied) {
        return currentStatus;
      }

      // Step 3: If already granted, return immediately
      if (currentStatus.isGranted) {
        return currentStatus;
      }

      // Step 4: Request permission
      final result = await Permission.camera.request();
      return result;
    } catch (e) {
      print('Camera permission request error: $e');
      // Return denied status on error
      return PermissionStatus.denied;
    }
  }

  /// Check if camera permission is currently granted
  static Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Check if camera permission is permanently denied
  static Future<bool> isCameraPermissionPermanentlyDenied() async {
    final status = await Permission.camera.status;
    return status.isPermanentlyDenied;
  }

  /// Open app settings for manual permission grant
  static Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      print('Error opening app settings: $e');
      return false;
    }
  }
}
