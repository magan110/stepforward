import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestActivityRecognitionPermission() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  Future<bool> checkActivityRecognitionPermission() async {
    final status = await Permission.activityRecognition.status;
    return status.isGranted;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}
