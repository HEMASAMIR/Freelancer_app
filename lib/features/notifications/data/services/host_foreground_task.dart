import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:freelancer/core/constant/constant.dart';

// ── Entry point called by the OS in a separate isolate ────────────────────────
// Must be a top-level function annotated with @pragma('vm:entry-point')
@pragma('vm:entry-point')
void foregroundTaskEntryPoint() {
  FlutterForegroundTask.setTaskHandler(HostForegroundTaskHandler());
}

// ── Task Handler ──────────────────────────────────────────────────────────────
class HostForegroundTaskHandler extends TaskHandler {
  SupabaseClient? _supabase;
  RealtimeChannel? _channel;
  final _localNotif = FlutterLocalNotificationsPlugin();
  bool _notifInitialized = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // 1. Initialize Supabase (fresh isolate — needs re-init)
    if (Supabase.instance.client.auth.currentSession == null) {
      try {
        await Supabase.initialize(
          url: SupabaseKeys.supabaseUrl,
          anonKey: SupabaseKeys.supabaseAnonKey,
        );
      } catch (_) {
        // Already initialized in some edge cases — ignore
      }
    }
    _supabase = Supabase.instance.client;

    // 2. Initialize local notifications in this isolate
    await _initLocalNotif();

    // 3. Read saved hostId and start listening
    final hostId = await FlutterForegroundTask.getData<String>(key: 'hostId');
    if (hostId != null && hostId.isNotEmpty) {
      await _startListening(hostId);
    }
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    // Heartbeat — keeps the service alive. No heavy work needed here.
    // Supabase Realtime manages its own WebSocket keep-alive.
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    if (_channel != null && _supabase != null) {
      await _supabase!.removeChannel(_channel!);
    }
  }

  @override
  void onReceiveData(Object data) {
    // Called when main isolate sends data via sendDataToTask()
    if (data is Map<String, dynamic>) {
      final action = data['action'] as String?;
      final hostId = data['hostId'] as String?;

      if (action == 'start' && hostId != null) {
        _startListening(hostId);
      } else if (action == 'stop') {
        if (_channel != null && _supabase != null) {
          _supabase!.removeChannel(_channel!);
          _channel = null;
        }
      }
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _initLocalNotif() async {
    if (_notifInitialized) return;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    await _localNotif.initialize(
      const InitializationSettings(android: androidSettings),
    );

    const channel = AndroidNotificationChannel(
      'quickin_host_bookings',
      'New Bookings',
      description: 'Alerts when a guest books one of your listings',
      importance: Importance.high,
    );
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _notifInitialized = true;
  }

  Future<void> _startListening(String hostId) async {
    // Cancel previous channel if any
    if (_channel != null && _supabase != null) {
      await _supabase!.removeChannel(_channel!);
      _channel = null;
    }

    _channel = _supabase!
        .channel('fg_host_$hostId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'bookings',
          callback: (payload) async {
            try {
              final newRow = payload.newRecord;
              final listingId = newRow['listing_id']?.toString();
              if (listingId == null) return;

              // Check if listing belongs to this host
              final listing = await _supabase!
                  .from('listings')
                  .select('id, title, user_id')
                  .eq('id', listingId)
                  .eq('user_id', hostId)
                  .maybeSingle();

              if (listing == null) return;

              // Fetch guest name
              final guestId = newRow['user_id']?.toString() ?? '';
              String guestName = 'A guest';
              if (guestId.isNotEmpty) {
                final guest = await _supabase!
                    .from('profiles')
                    .select('full_name, email')
                    .eq('id', guestId)
                    .maybeSingle();
                guestName = guest?['full_name']?.toString() ??
                    guest?['email']?.toString() ??
                    'A guest';
              }

              final listingTitle =
                  listing['title']?.toString() ?? 'Your Property';
              final checkIn = newRow['check_in']?.toString() ?? '';
              final checkOut = newRow['check_out']?.toString() ?? '';
              final subtotal = (newRow['subtotal'] as num?) ?? 0;

              await _showNotification(
                guestName: guestName,
                listingTitle: listingTitle,
                checkIn: checkIn,
                checkOut: checkOut,
                subtotal: subtotal,
              );
            } catch (e) {
              // Silently ignore errors in background isolate
            }
          },
        )
        .subscribe();
  }

  Future<void> _showNotification({
    required String guestName,
    required String listingTitle,
    required String checkIn,
    required String checkOut,
    required num subtotal,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF;

    const androidDetails = AndroidNotificationDetails(
      'quickin_host_bookings',
      'New Bookings',
      channelDescription: 'Alerts when a guest books one of your listings',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      autoCancel: true,
    );

    await _localNotif.show(
      id,
      '🏠 New Booking Request',
      '$guestName wants to book "$listingTitle"\n'
          '$checkIn → $checkOut  •  EGP ${subtotal.toStringAsFixed(0)}',
      const NotificationDetails(android: androidDetails),
    );
  }
}
