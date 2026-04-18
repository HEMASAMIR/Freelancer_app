import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
import 'package:freelancer/features/bookings/data/models/booking_model.dart';
import 'package:freelancer/features/bookings/logic/cubit/bookings_cubit.dart';
import 'package:freelancer/features/bookings/logic/cubit/bookings_state.dart';
import 'package:intl/intl.dart';

class BookingRequestsView extends StatefulWidget {
  const BookingRequestsView({super.key});

  @override
  State<BookingRequestsView> createState() => _BookingRequestsViewState();
}

class _BookingRequestsViewState extends State<BookingRequestsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAdminSuccess) {
      context.read<BookingsCubit>().getHostBookings(hostId: authState.user.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<BookingModel> _applySearch(List<BookingModel> list) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list
        .where((b) =>
            (b.id ?? '').toLowerCase().contains(q) ||
            (b.listingId ?? '').toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingsCubit, BookingsState>(
      listener: (context, state) {
        if (state is BookingsConfirmed || state is BookingsCancelled) {
          final authState = context.read<AuthCubit>().state;
          if (authState is AuthAdminSuccess) {
            context.read<BookingsCubit>().getHostBookings(hostId: authState.user.id);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state is BookingsConfirmed ? 'Booking confirmed!' : 'Booking declined.'),
              backgroundColor: state is BookingsConfirmed ? Colors.green : Colors.red,
            ),
          );
        } else if (state is BookingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ─────────────────────────────────────────────────
        const Text(
          'Booking Requests',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage booking requests for your properties',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.sub.withValues(alpha: 0.8),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),

        // ── Search ─────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.dividerGrey.withValues(alpha: 0.5)),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Find by reservation code...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ── Tab Bar ─────────────────────────────────────────────────
        Container(
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            dividerColor: Colors.transparent,
            labelColor: AppColors.primaryBurgundy,
            unselectedLabelColor: AppColors.sub,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Confirmed'),
              Tab(text: 'All'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Content ─────────────────────────────────────────────────
        BlocBuilder<BookingsCubit, BookingsState>(
          builder: (context, state) {
            if (state is BookingsLoading) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBurgundy,
                    strokeWidth: 2.5,
                  ),
                ),
              );
            }

            List<BookingModel> all = [];
            if (state is BookingsListLoaded) all = state.bookings;

            final pending  = _applySearch(all.where((b) => b.status == 'pending').toList());
            final confirmed = _applySearch(all.where((b) => b.status == 'confirmed').toList());
            final filtered  = _applySearch(all);

            return SizedBox(
              height: 460,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _BookingList(
                    bookings: pending, 
                    emptyLabel: 'No pending booking requests',
                    icon: Icons.access_time_rounded,
                  ),
                  _BookingList(
                    bookings: confirmed, 
                    emptyLabel: 'No confirmed bookings',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                  _BookingList(
                    bookings: filtered, 
                    emptyLabel: 'No booking requests yet',
                    icon: Icons.calendar_month_outlined,
                  ),
                ],
              ),
            );
          },
        ),

        // ── Footer ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              const Divider(height: 1, color: AppColors.dividerGrey),
              const SizedBox(height: 24),
              Text(
                '© 2026 QuickIn, Inc. · Terms · Sitemap · Privacy',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.public, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  const Text(
                    'English (US)  EGP',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ink),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
      ),
    );
  }
}

// ── Booking List ─────────────────────────────────────────────────────────────
class _BookingList extends StatelessWidget {
  final List<BookingModel> bookings;
  final String emptyLabel;
  final IconData icon;
  const _BookingList({required this.bookings, required this.emptyLabel, required this.icon});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.dividerGrey.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: AppColors.sub.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                emptyLabel,
                style: const TextStyle(
                  fontSize: 15, 
                  color: AppColors.sub, 
                  fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _BookingCard(booking: bookings[i]),
    );
  }
}

// ── Booking Card ─────────────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

  Color _statusColor(String? s) {
    switch (s) {
      case 'confirmed': return Colors.green;
      case 'pending':   return Colors.orange;
      case 'cancelled': return Colors.red;
      default:          return Colors.grey;
    }
  }

  String _fmt(String? d) =>
      d != null ? DateFormat('MMM d, yyyy').format(DateTime.parse(d)) : '—';

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(booking.status);
    final canAct = booking.status == 'pending';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {}, // placeholder for detail navigation
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: ID + status badge ──────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Booking #${(booking.id ?? '').substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      booking.status ?? '—',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Dates ───────────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.sub),
                  const SizedBox(width: 6),
                  Text(
                    '${_fmt(booking.checkIn)}  →  ${_fmt(booking.checkOut)}',
                    style: const TextStyle(fontSize: 13, color: AppColors.sub),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ── Guests + Total ──────────────────────────────────
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
                    'EGP ${booking.subtotal?.toStringAsFixed(0) ?? '—'}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),

              // ── Action row (only for pending bookings) ──────────
              if (canAct) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.dividerGrey),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          final authState = context.read<AuthCubit>().state;
                          final hostId = authState is AuthAdminSuccess
                              ? authState.user.id
                              : (authState as AuthSuccess).user.id;
                          context.read<BookingsCubit>().confirmBooking(
                            booking.id ?? '',
                            hostId,
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Confirm',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          final authState = context.read<AuthCubit>().state;
                          final userId = authState is AuthAdminSuccess
                              ? authState.user.id
                              : (authState as AuthSuccess).user.id;
                          context.read<BookingsCubit>().cancelBooking(
                            booking.id ?? '',
                            userId,
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Decline',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
