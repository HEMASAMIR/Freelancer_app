import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:freelancer/features/notifications/data/models/notification_model.dart';
import 'package:freelancer/features/notifications/data/services/local_notification_service.dart';

/// Listens to real-time booking inserts on the host's listings.
/// Only activates when a logged-in host is provided.
/// Fires both an OS-level local notification AND an in-app stream event.
class HostNotificationService {
  final SupabaseClient _supabase;

  RealtimeChannel? _channel;
  final _controller = StreamController<NotificationModel>.broadcast();

  HostNotificationService(this._supabase);

  Stream<NotificationModel> get notificationStream => _controller.stream;

  /// Call this when the host logs in.
  Future<void> startListening(String hostId) async {
    await stopListening(); // clean up any previous subscription

    _channel = _supabase
        .channel('host_bookings_$hostId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'bookings',
          callback: (payload) async {
            try {
              final newRow = payload.newRecord;
              final listingId = newRow['listing_id']?.toString();
              if (listingId == null) return;

              // ── 1. Verify this listing belongs to our host ──────────────
              final listingResp = await _supabase
                  .from('listings')
                  .select('id, title, user_id')
                  .eq('id', listingId)
                  .eq('user_id', hostId)
                  .maybeSingle();

              if (listingResp == null) return; // not the host's listing

              // ── 2. Fetch guest profile ──────────────────────────────────
              final guestId = newRow['user_id']?.toString() ?? '';
              Map<String, dynamic> guestProfile = {};
              if (guestId.isNotEmpty) {
                final gResp = await _supabase
                    .from('profiles')
                    .select('id, full_name, email')
                    .eq('id', guestId)
                    .maybeSingle();
                guestProfile = gResp ?? {};
              }

              final enriched = {
                ...newRow,
                'listing': listingResp,
                'guest': guestProfile,
              };

              // ── 3. Build notification model ─────────────────────────────
              final notification =
                  NotificationModel.fromBookingPayload(enriched);

              // ── 4. Show OS banner (works in foreground + background) ────
              await LocalNotificationService.instance.showBookingNotification(
                guestName: notification.guestName,
                listingTitle: notification.listingTitle,
                checkIn: notification.checkIn,
                checkOut: notification.checkOut,
                subtotal: notification.subtotal,
                bookingId: notification.bookingId,
              );

              // ── 5. Emit to in-app stream → cubit → UI list ──────────────
              _controller.add(notification);
            } catch (e) {
              debugPrint('[HostNotificationService] error: $e');
            }
          },
        )
        .subscribe();
  }

  /// Call when the host logs out.
  Future<void> stopListening() async {
    if (_channel != null) {
      await _supabase.removeChannel(_channel!);
      _channel = null;
    }
  }

  void dispose() {
    stopListening();
    _controller.close();
  }
}
