/// Model representing a booking notification for the host.
class NotificationModel {
  final String id;
  final String bookingId;
  final String listingTitle;
  final String guestName;
  final String checkIn;
  final String checkOut;
  final int guests;
  final num subtotal;
  final String status;
  final DateTime receivedAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.bookingId,
    required this.listingTitle,
    required this.guestName,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.subtotal,
    required this.status,
    required this.receivedAt,
    this.isRead = false,
  });

  factory NotificationModel.fromBookingPayload(Map<String, dynamic> booking) {
    final listing = booking['listing'] as Map<String, dynamic>? ?? {};
    final guest = booking['guest'] as Map<String, dynamic>? ?? {};

    return NotificationModel(
      id: 'notif_${booking['id'] ?? DateTime.now().millisecondsSinceEpoch}',
      bookingId: booking['id']?.toString() ?? '',
      listingTitle: listing['title']?.toString() ?? 'Your Property',
      guestName: guest['full_name']?.toString() ?? guest['email']?.toString() ?? 'A guest',
      checkIn: booking['check_in']?.toString() ?? '',
      checkOut: booking['check_out']?.toString() ?? '',
      guests: (booking['guests'] as int?) ?? 1,
      subtotal: (booking['subtotal'] as num?) ?? 0,
      status: booking['status']?.toString() ?? 'pending',
      receivedAt: DateTime.tryParse(booking['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(receivedAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String get statusLabel {
    switch (status) {
      case 'confirmed': return 'Confirmed';
      case 'cancelled': return 'Cancelled';
      case 'pending': return 'Pending';
      default: return status;
    }
  }
}
