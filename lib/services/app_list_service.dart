import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_constants.dart';
import '../models/installed_app.dart';

class AppListService {
  static const MethodChannel _channel = MethodChannel(AppConstants.hardwareChannel);

  Future<List<InstalledApp>> getInstalledApplications() async {
    // If not running on Android (e.g. web, desktop, test), return rich mock apps
    if (kIsWeb || !Platform.isAndroid) {
      return getMockInstalledApps();
    }

    try {
      final List<dynamic>? rawList = await _channel.invokeListMethod<dynamic>('getInstalledApps');
      if (rawList == null || rawList.isEmpty) {
        return getMockInstalledApps();
      }

      final List<InstalledApp> apps = [];
      for (final item in rawList) {
        if (item is Map) {
          final name = item['name'] as String? ?? 'App';
          final pkg = item['packageName'] as String? ?? 'com.example.app';
          final iconData = item['icon'] as Uint8List?;
          apps.add(InstalledApp(
            name: name,
            packageName: pkg,
            iconBytes: iconData,
            isSelected: false,
          ));
        }
      }

      if (apps.isEmpty) {
        return getMockInstalledApps();
      }
      return apps;
    } catch (e) {
      debugPrint('AppListService error querying native packages: $e');
      return getMockInstalledApps();
    }
  }

  static List<InstalledApp> getMockInstalledApps() {
    return [
      InstalledApp(name: 'Google Chrome', packageName: 'com.android.chrome', isSelected: true),
      InstalledApp(name: 'WhatsApp', packageName: 'com.whatsapp', isSelected: true),
      InstalledApp(name: 'Spotify', packageName: 'com.spotify.music', isSelected: true),
      InstalledApp(name: 'Camera', packageName: 'com.android.camera2', isSelected: false),
      InstalledApp(name: 'Gmail', packageName: 'com.google.android.gm', isSelected: false),
      InstalledApp(name: 'YouTube', packageName: 'com.google.android.youtube', isSelected: false),
      InstalledApp(name: 'Instagram', packageName: 'com.instagram.android', isSelected: false),
      InstalledApp(name: 'Google Maps', packageName: 'com.google.android.apps.maps', isSelected: false),
      InstalledApp(name: 'Netflix', packageName: 'com.netflix.mediaclient', isSelected: false),
      InstalledApp(name: 'Settings', packageName: 'com.android.settings', isSelected: false),
      InstalledApp(name: 'Telegram', packageName: 'org.telegram.messenger', isSelected: false),
      InstalledApp(name: 'VS Code Mobile', packageName: 'com.microsoft.vscode', isSelected: false),
    ];
  }
}
