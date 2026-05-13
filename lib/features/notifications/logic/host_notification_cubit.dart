import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/features/notifications/data/models/notification_model.dart';
import 'package:freelancer/features/notifications/data/services/host_notification_service.dart';

// ─── States ──────────────────────────────────────────────────────────────────

abstract class HostNotificationState {}

class HostNotificationInitial extends HostNotificationState {}

/// Emitted every time the list changes (new notification added / marked read).
class HostNotificationLoaded extends HostNotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  HostNotificationLoaded({
    required this.notifications,
    required this.unreadCount,
  });
}

class HostNewNotificationReceived extends HostNotificationState {
  final NotificationModel notification;
  HostNewNotificationReceived(this.notification);
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class HostNotificationCubit extends Cubit<HostNotificationState> {
  final HostNotificationService _service;

  final List<NotificationModel> _notifications = [];
  StreamSubscription<NotificationModel>? _sub;

  HostNotificationCubit(this._service) : super(HostNotificationInitial());

  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  /// Start listening for this host's booking notifications.
  Future<void> startForHost(String hostId) async {
    await _service.startListening(hostId);

    _sub = _service.notificationStream.listen((notification) {
      _notifications.insert(0, notification);
      emit(HostNewNotificationReceived(notification));
      _emitLoaded();
    });
  }

  /// Stop listening (on logout / dispose).
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    await _service.stopListening();
  }

  void markAllRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    _emitLoaded();
  }

  void markRead(String notifId) {
    final idx = _notifications.indexWhere((n) => n.id == notifId);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      _emitLoaded();
    }
  }

  void clearAll() {
    _notifications.clear();
    _emitLoaded();
  }

  void _emitLoaded() {
    emit(
      HostNotificationLoaded(
        notifications: List.from(_notifications),
        unreadCount: unreadCount,
      ),
    );
  }

  @override
  Future<void> close() async {
    await stop();
    return super.close();
  }
}
