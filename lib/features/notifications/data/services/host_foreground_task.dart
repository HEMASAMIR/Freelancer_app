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
    await _ensureSupabaseInitialized();

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
  
  Future<void> _ensureSupabaseInitialized() async {
    if (_supabase != null) return;
    try {
      _supabase = Supabase.instance.client;
    } catch (_) {
      try {
        await Supabase.initialize(
          url: SupabaseKeys.supabaseUrl,
          anonKey: SupabaseKeys.supabaseAnonKey,
        );
        _supabase = Supabase.instance.client;
      } catch (_) {}
    }
  }

  Future<void> _initLocalNotif() async {
    if (_notifInitialized) return;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    await _localNotif.initialize(
      const InitializationSettings(android: androidSettings),
    );

    const channel = AndroidNotificationChannel(
      'quickin_host_bookings_v3',
      'New Bookings Alert',
      description: 'Alerts when a guest books one of your listings',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _notifInitialized = true;
  }

  Future<void> _startListening(String hostId) async {
    await _ensureSupabaseInitialized();
    if (_supabase == null) return;

    // Cancel previous channel if any
    if (_channel != null) {
      try {
        await _supabase!.removeChannel(_channel!);
      } catch (_) {}
      _channel = null;
    }
    
    // Attempt to fetch the latest booking to update the notification text
    try {
      final listingsResp = await _supabase!
          .from('listings')
          .select('id, title')
          .eq('user_id', hostId);
          
      if (listingsResp != null && (listingsResp as List).isNotEmpty) {
        final listingIds = (listingsResp).map((e) => e['id']).toList();
        final lastBookingResp = await _supabase!
            .from('bookings')
            .select('*')
            .inFilter('listing_id', listingIds)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (lastBookingResp != null) {
          final listing = (listingsResp).firstWhere((e) => e['id'] == lastBookingResp['listing_id'], orElse: () => {'title': 'شاليه'});
          final guestId = lastBookingResp['user_id']?.toString() ?? '';
          String guestName = 'ضيف';
          if (guestId.isNotEmpty) {
            final guest = await _supabase!
                .from('profiles')
                .select('full_name, email')
                .eq('id', guestId)
                .maybeSingle();
            guestName = guest?['full_name']?.toString() ??
                guest?['email']?.toString() ??
                'ضيف';
          }
          final listingTitle = listing['title']?.toString() ?? 'شاليه';
          
          final checkIn = lastBookingResp['check_in']?.toString() ?? '';
          final checkOut = lastBookingResp['check_out']?.toString() ?? '';
          int durationDays = 0;
          try {
            final inDate = DateTime.tryParse(checkIn);
            final outDate = DateTime.tryParse(checkOut);
            if (inDate != null && outDate != null) {
              durationDays = outDate.difference(inDate).inDays;
            }
          } catch (_) {}

          await FlutterForegroundTask.updateService(
            notificationTitle: 'آخر حجز تم 🏠',
            notificationText: 'حجز $guestName "$listingTitle" لمدة $durationDays أيام',
          );
        }
      }
    } catch (_) {
      // Ignore errors when fetching the latest booking.
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
              final guests = (newRow['guests'] as num?)?.toInt() ?? 1;

              int durationDays = 0;
              try {
                final inDate = DateTime.tryParse(checkIn);
                final outDate = DateTime.tryParse(checkOut);
                if (inDate != null && outDate != null) {
                  durationDays = outDate.difference(inDate).inDays;
                }
              } catch (_) {}

              // 1. Update the background/foreground service notification text itself!
              await FlutterForegroundTask.updateService(
                notificationTitle: '🏠 طلب حجز جديد!',
                notificationText: 'قام $guestName بحجز "$listingTitle" لمدة $durationDays أيام',
              );

              // 2. Show local notification (plays sound and shows popup banner)
              await _showNotification(
                guestName: guestName,
                listingTitle: listingTitle,
                checkIn: checkIn,
                checkOut: checkOut,
                subtotal: subtotal,
                guests: guests,
                durationDays: durationDays,
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
    required int guests,
    required int durationDays,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF;

    const androidDetails = AndroidNotificationDetails(
      'quickin_host_bookings_v3',
      'New Bookings Alert',
      channelDescription: 'Alerts when a guest books one of your listings',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/launcher_icon',
      autoCancel: true,
      playSound: true,
      enableVibration: true,
    );

    // Format checkIn and checkOut dates to look cleaner (e.g. YYYY-MM-DD)
    String cleanCheckIn = checkIn;
    String cleanCheckOut = checkOut;
    try {
      final inDate = DateTime.tryParse(checkIn);
      final outDate = DateTime.tryParse(checkOut);
      if (inDate != null) cleanCheckIn = "${inDate.year}-${inDate.month.toString().padLeft(2, '0')}-${inDate.day.toString().padLeft(2, '0')}";
      if (outDate != null) cleanCheckOut = "${outDate.year}-${outDate.month.toString().padLeft(2, '0')}-${outDate.day.toString().padLeft(2, '0')}";
    } catch (_) {}

    await _localNotif.show(
      id,
      '🏠 طلب حجز جديد!',
      'قام $guestName بطلب حجز لـ "$listingTitle"\n'
          'المدة: $durationDays ليالي  •  العدد: $guests فرد\n'
          'التواريخ: $cleanCheckIn ← $cleanCheckOut\n'
          'الإجمالي: EGP ${subtotal.toStringAsFixed(0)}',
      const NotificationDetails(android: androidDetails),
    );
  }
}
