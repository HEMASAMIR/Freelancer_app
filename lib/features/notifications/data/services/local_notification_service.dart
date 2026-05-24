import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles OS-level local notifications (no Firebase needed).
/// Works when the app is open AND when it's backgrounded/minimised.
class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── Notification channel (Android 8+) ─────────────────────────────────────
  static const _channelId = 'quickin_host_bookings';
  static const _channelName = 'New Bookings';
  static const _channelDescription =
      'Alerts when a guest books one of your listings';

  /// Call once in main() before runApp().
  Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onTap,
    );

    // Create the Android notification channel
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Ask permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
    debugPrint('[LocalNotificationService] initialized ✅');
  }

  /// Show a "New Booking" notification banner.
  Future<void> showBookingNotification({
    required String guestName,
    required String listingTitle,
    required String checkIn,
    required String checkOut,
    required num subtotal,
    required int guests,
    required int nights,
    String? bookingId,
  }) async {
    if (!_initialized) await init();

    final id = DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF;

    final body =
        '🎉 $guestName booked "$listingTitle"\n'
        '👥 $guests guests • 🌙 $nights nights\n'
        '💰 Total: EGP ${subtotal.toStringAsFixed(0)}';

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'New booking request',
      icon: '@mipmap/launcher_icon',
      styleInformation: BigTextStyleInformation(''),
      // Rich heads-up notification
      fullScreenIntent: false,
      autoCancel: true,
      ongoing: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id,
      '🏠 New Booking Request',
      body,
      details,
      payload: bookingId,
    );
  }

  /// Show a simple custom local notification.
  Future<void> showCustomNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await init();

    final id = DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/launcher_icon',
      styleInformation: BigTextStyleInformation(''),
      autoCancel: true,
      ongoing: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // ── Tap handler ───────────────────────────────────────────────────────────
  void _onTap(NotificationResponse response) {
    // You can navigate to the notifications screen here if needed
    debugPrint('[LocalNotificationService] tapped: ${response.payload}');
  }
}
