import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
import 'package:freelancer/features/bookings/data/models/booking_model.dart';
import 'package:freelancer/features/bookings/logic/cubit/bookings_cubit.dart';
import 'package:freelancer/features/bookings/logic/cubit/bookings_state.dart';

class BookingRequestsView extends StatefulWidget {
  const BookingRequestsView({super.key});

  @override
  State<BookingRequestsView> createState() => _BookingRequestsViewState();
}

class _BookingRequestsViewState extends State<BookingRequestsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            color: AppColors.sub.withOpacity(0.8),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 32),
        _buildSearchBar(),
        const SizedBox(height: 24),
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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            labelColor: Colors.black,
            unselectedLabelColor: AppColors.sub,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Confirmed'),
              Tab(text: 'All'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        BlocBuilder<BookingsCubit, BookingsState>(
          builder: (context, state) {
            List<BookingModel> bookings = [];
            if (state is BookingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is BookingsListLoaded) bookings = state.bookings;

            return SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBookingList(
                    bookings.where((b) => b.status == 'pending').toList(),
                    'No pending requests',
                  ),
                  _buildBookingList(
                    bookings.where((b) => b.status == 'confirmed').toList(),
                    'No confirmed bookings',
                  ),
                  _buildBookingList(bookings, 'No bookings found'),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerGrey.withOpacity(0.5)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Find by reservation code...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
        ),
      ),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings, String emptyMessage) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time, size: 48, color: AppColors.sub),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.sub,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final isConfirmed = booking.status == 'confirmed';
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            title: Text('Booking #${booking.id?.substring(0, 8) ?? "..."}'),
            subtitle: Text(
              'Listing: ${booking.listingId} | Guests: ${booking.guests}',
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: (isConfirmed ? Colors.green : Colors.orange).withOpacity(
                  0.1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                booking.status ?? 'unknown',
                style: TextStyle(
                  color: isConfirmed ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
