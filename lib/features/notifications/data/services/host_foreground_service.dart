import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'host_foreground_task.dart';

/// Manages starting and stopping the Android Foreground Service
/// that keeps Supabase Realtime alive when the app is killed.
class HostForegroundService {
  HostForegroundService._();
  static final instance = HostForegroundService._();

  static const _serviceId = 7788;

  // ── Initialization (call once in main) ───────────────────────────────────
  static void initForegroundTask() {
    if (kIsWeb) return; // flutter_foreground_task is not supported on web
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'quickin_host_service_v4',
        channelName: 'QuickIn Host Service',
        channelDescription: 'Keeps booking alerts active in the background',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        playSound: false,
        enableVibration: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(30000), // ping every 30s
        autoRunOnBoot: true,   // restart after device reboot
        allowWakeLock: true,   // prevent CPU sleep
        allowWifiLock: true,   // keep WiFi alive
      ),
    );
  }

  // ── Start service for a host ──────────────────────────────────────────────
  Future<void> startForHost(String hostId) async {
    if (kIsWeb) return; // flutter_foreground_task is not supported on web

    // Save hostId so the isolate can read it on restart
    await FlutterForegroundTask.saveData(key: 'hostId', value: hostId);

    if (await FlutterForegroundTask.isRunningService) {
      // Already running — just tell the handler to switch host
      FlutterForegroundTask.sendDataToTask({'action': 'start', 'hostId': hostId});
      debugPrint('[HostForegroundService] updated hostId in running service');
    } else {
      final result = await FlutterForegroundTask.startService(
        serviceId: _serviceId,
        notificationTitle: 'QuickIn Host',
        notificationText: 'جاهز لاستقبال طلبات الحجز 🏠',
        notificationIcon: const NotificationIcon(
          metaDataName: 'com.pravera.flutter_foreground_task.NOTIFICATION_ICON',
        ),
        callback: foregroundTaskEntryPoint,
      );
      debugPrint('[HostForegroundService] start result: $result');
    }
  }

  // ── Stop service ──────────────────────────────────────────────────────────
  Future<void> stop() async {
    if (kIsWeb) return; // flutter_foreground_task is not supported on web
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
      debugPrint('[HostForegroundService] stopped');
    }
  }

  // ── Request battery optimisation exemption (optional UX prompt) ───────────
  Future<void> requestBatteryOptimizationExemption() async {
    if (kIsWeb) return; // flutter_foreground_task is not supported on web
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }
  }
}
