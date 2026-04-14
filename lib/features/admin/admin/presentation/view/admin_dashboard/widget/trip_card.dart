// ─── trip_card.dart ───────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/bookings/data/models/booking_model.dart';
import 'package:intl/intl.dart';

class TripCard extends StatelessWidget {
  final BookingModel booking;
  const TripCard({super.key, required this.booking});

  Color _statusColor(String? status) {
    switch (status) {
      case 'confirmed':
      case 'upcoming':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkIn = booking.checkIn != null
        ? DateFormat('MMM d, yyyy').format(DateTime.parse(booking.checkIn!))
        : '-';
    final checkOut = booking.checkOut != null
        ? DateFormat('MMM d, yyyy').format(DateTime.parse(booking.checkOut!))
        : '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reservation #${(booking.id ?? '').substring(0, 8)}',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(booking.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status ?? '-',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _statusColor(booking.status)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.sub),
              const SizedBox(width: 6),
              Text('$checkIn → $checkOut',
                  style: const TextStyle(fontSize: 13, color: AppColors.sub)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.people_outline,
                  size: 14, color: AppColors.sub),
              const SizedBox(width: 6),
              Text(
                '${booking.guests ?? 1} guest${(booking.guests ?? 1) > 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 13, color: AppColors.sub),
              ),
              const Spacer(),
              Text(
                'EGP ${booking.subtotal?.toStringAsFixed(0) ?? '-'}',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink),
              ),
            ],
          ),
        ],
      ),
    );
  }
}