import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
import 'package:freelancer/features/bookings/data/models/booking_model.dart';
import 'package:freelancer/features/bookings/logic/cubit/bookings_cubit.dart';
import 'package:freelancer/features/bookings/logic/cubit/bookings_state.dart';
import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';
import 'package:intl/intl.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  String _selectedFilter = 'Upcoming';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess || authState is AuthAdminSuccess) {
      final userId = authState is AuthSuccess
          ? authState.user.id
          : (authState as AuthAdminSuccess).user.id;
      context.read<BookingsCubit>().getUserBookings(userId: userId);
    }
  }

  List<BookingModel> _filterBookings(List<BookingModel> bookings) {
    List<BookingModel> filtered;
    switch (_selectedFilter) {
      case 'Pending':
        filtered = bookings.where((b) => b.status == 'pending').toList();
        break;
      case 'History':
        filtered = bookings
            .where((b) => b.status == 'cancelled' || b.status == 'completed')
            .toList();
        break;
      case 'Upcoming':
      default:
        filtered = bookings
            .where((b) => b.status == 'confirmed' || b.status == 'upcoming')
            .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (b) =>
                (b.id ?? '').toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (b.listingId ?? '').toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F0EA),
      drawer: const SideDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header (Fixed Drawer Icon) ──────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: InkWell(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.menu, color: AppColors.ink, size: 24),
                ),
              ),
            ),
            
            // ── Main Content ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trips',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your booking requests and reservations.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.sub.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Search ─────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Find by reservation code...',
                        hintStyle: TextStyle(
                          color: AppColors.sub.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.sub.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Filter Chips ───────────────────────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Pending', 'Upcoming', 'History'].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedFilter = filter),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.ink : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    filter == 'Pending'
                                        ? Icons.access_time_rounded
                                        : filter == 'Upcoming'
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.history_rounded,
                                    size: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.sub,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    filter,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.sub,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Content ──────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<BookingsCubit, BookingsState>(
                builder: (context, state) {
                  if (state is BookingsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is BookingsError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is BookingsListLoaded) {
                    final filtered = _filterBookings(state.bookings);
                    if (filtered.isEmpty) {
                      return _EmptyTrips(filter: _selectedFilter);
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _TripCard(booking: filtered[i]),
                    );
                  }
                  return _EmptyTrips(filter: _selectedFilter);
                },
              ),
            ),

            // ── Footer ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 8),
              child: Center(
                child: Text(
                  '© 2026 QuickIn, Inc. · Terms · Sitemap · Privacy',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────────
class _EmptyTrips extends StatelessWidget {
  final String filter;
  const _EmptyTrips({required this.filter});

  @override
  Widget build(BuildContext context) {
    // ✅ كل تاب له محتوى مختلف
    final config = _emptyConfig(filter);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  config['icon'] as IconData,
                  size: 56,
                  color: AppColors.sub.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  config['title'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  config['subtitle'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.sub.withValues(alpha: 0.6),
                  ),
                ),

                // ✅ الزرار بيظهر بس لو مش History
                if (config['buttonLabel'] != null) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.searchResult),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        config['buttonLabel'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _emptyConfig(String filter) {
    switch (filter) {
      case 'Pending':
        return {
          'icon': Icons.access_time_rounded,
          'title': 'No pending requests',
          'subtitle':
              'Your booking requests that are awaiting host approval will appear here',
          'buttonLabel': 'Browse listings', // ✅ زرار مختلف
        };
      case 'History':
        return {
          'icon': Icons.history_rounded,
          'title': 'No past trips',
          'subtitle': 'Your completed and cancelled trips will appear here',
          'buttonLabel': null, // ✅ مفيش زرار
        };
      case 'Upcoming':
      default:
        return {
          'icon': Icons.calendar_month_outlined,
          'title': 'No upcoming trips',
          'subtitle': 'Time to plan your next adventure',
          'buttonLabel': 'Start searching',
        };
    }
  }
}

// ── Trip Card ────────────────────────────────────────────────────────────────
class _TripCard extends StatelessWidget {
  final BookingModel booking;
  const _TripCard({required this.booking});

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
                  color: AppColors.ink,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(booking.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status ?? '-',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _statusColor(booking.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.sub,
              ),
              const SizedBox(width: 6),
              Text(
                '$checkIn → $checkOut',
                style: const TextStyle(fontSize: 13, color: AppColors.sub),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.people_outline, size: 14, color: AppColors.sub),
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
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          if (booking.status == 'pending' || booking.status == 'confirmed') ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                final authState = context.read<AuthCubit>().state;
                final userId = authState is AuthSuccess
                    ? authState.user.id
                    : (authState as AuthAdminSuccess).user.id;
                context.read<BookingsCubit>().cancelBooking(
                  booking.id ?? '',
                  userId,
                );
              },
              child: Text(
                'Cancel reservation',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryRed,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primaryRed,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
