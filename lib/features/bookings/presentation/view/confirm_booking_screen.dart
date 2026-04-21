import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/utils/widgets/custom_app_bar.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/bookings/logic/cubit/bookings_cubit.dart';
import 'package:freelancer/features/bookings/logic/cubit/bookings_state.dart';
import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';
import 'package:intl/intl.dart';

// ═══════════════════════════════════════════════════════════════════
//  MODEL — data passed from BookingCard → ConfirmBookingScreen
// ═══════════════════════════════════════════════════════════════════
class ConfirmBookingArgs {
  final ListingModel listing;
  final DateTimeRange dateRange;
  final int guests;
  final double subtotal;
  final double serviceFee;
  final double total;
  final String? commissionRateId;
  final String userId;

  const ConfirmBookingArgs({
    required this.listing,
    required this.dateRange,
    required this.guests,
    required this.subtotal,
    required this.serviceFee,
    required this.total,
    required this.userId,
    this.commissionRateId,
  });
}

// ═══════════════════════════════════════════════════════════════════
//  SCREEN
// ═══════════════════════════════════════════════════════════════════
class ConfirmBookingScreen extends StatefulWidget {
  final ConfirmBookingArgs args;
  const ConfirmBookingScreen({super.key, required this.args});

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  bool _acceptPolicy = false;
  int _selectedPayment = 0; // 0=full, 1=part

  // ── helpers ──────────────────────────────────────────────────────
  String _fmtDate(DateTime d) => DateFormat('MMM d, yyyy').format(d);
  String _fmtMoney(double v) =>
      NumberFormat('#,##0', 'en_US').format(v);

  int get _nights =>
      widget.args.dateRange.end.difference(widget.args.dateRange.start).inDays;

  // ── submit ────────────────────────────────────────────────────────
  Future<void> _requestToBook() async {
    if (!_acceptPolicy) return;

    final cubit = context.read<BookingsCubit>();
    final success = await cubit.createBooking(
      listingId: widget.args.listing.id!,
      userId: widget.args.userId,
      checkIn: widget.args.dateRange.start.toIso8601String(),
      checkOut: widget.args.dateRange.end.toIso8601String(),
      guests: widget.args.guests,
      subtotal: widget.args.subtotal,
      commissionRateId: widget.args.commissionRateId,
    );

    if (!mounted) return;
    if (success) {
      // pop back to details then go to Trips
      Navigator.of(context).popUntil((r) => r.isFirst);
      Navigator.pushNamed(context, AppRoutes.trips);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingsCubit, BookingsState>(
      listener: (context, state) {
        if (state is BookingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF710E1F),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F3F0),
        appBar: const CustomAppBar(),
        drawer: const SideDrawer(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Your Trip ─────────────────────────────────────────
              _SectionCard(
                title: 'Your Trip',
                child: Column(
                  children: [
                    _TripRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Dates',
                      value:
                          '${_fmtDate(widget.args.dateRange.start)} – ${_fmtDate(widget.args.dateRange.end)}',
                      sub: '$_nights night${_nights > 1 ? 's' : ''}',
                    ),
                    SizedBox(height: 16.h),
                    _TripRow(
                      icon: Icons.people_outline,
                      label: 'Guests',
                      value:
                          '${widget.args.guests} guest${widget.args.guests > 1 ? 's' : ''}',
                    ),
                  ],
                ),
              ),

              // ── Confirm Your Booking ──────────────────────────────
              _SectionCard(
                title: 'Confirm Your Booking',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment options
                    Text(
                      'Payment options',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _PaymentOption(
                      index: 0,
                      selected: _selectedPayment,
                      label: 'Pay in full',
                      sublabel:
                          'Pay EGP ${_fmtMoney(widget.args.total)} now.',
                      onTap: () => setState(() => _selectedPayment = 0),
                    ),
                    SizedBox(height: 10.h),
                    _PaymentOption(
                      index: 1,
                      selected: _selectedPayment,
                      label: 'Pay part now, part later',
                      sublabel:
                          'EGP ${_fmtMoney(widget.args.total / 2)} now, rest due before check-in.',
                      onTap: () => setState(() => _selectedPayment = 1),
                    ),
                    SizedBox(height: 12.h),
                    // Wallet provider field (mock)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Select your preferred mobile wallet provider',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Host Requirements ─────────────────────────────────
              _SectionCard(
                title: 'Host Requirements',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please agree to bring or have in your possession with your booking.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _CheckRow(
                      checked: true,
                      label: 'No pets',
                      sub: 'Pets are not allowed on the property.',
                    ),
                  ],
                ),
              ),

              // ── Cancellation Policy ───────────────────────────────
              _SectionCard(
                title: 'Cancellation Policy',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PolicyBadge(label: 'Flexible'),
                    SizedBox(height: 8.h),
                    Text(
                      'Cancel before 1 day before check-in for a full refund. After that, the first night is non-refundable.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _acceptPolicy = !_acceptPolicy),
                      child: Row(
                        children: [
                          _SquareCheck(checked: _acceptPolicy),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'I accept the cancellation and refund policy',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.ink,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Request to Book Button ────────────────────────────
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                child: BlocBuilder<BookingsCubit, BookingsState>(
                  builder: (context, state) {
                    final loading = state is BookingsLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: ElevatedButton.icon(
                          onPressed:
                              (!_acceptPolicy || loading) ? null : _requestToBook,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _acceptPolicy
                                ? const Color(0xFF710E1F)
                                : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          icon: loading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 18,
                                ),
                          label: Text(
                            loading ? 'Processing...' : 'Request to Book',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 4.h),
              Center(
                child: Text(
                  'By selecting the button you agree to the terms of service.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),

              // ── Listing Thumbnail ─────────────────────────────────
              _SectionCard(
                title: '',
                child: _ListingThumbnail(listing: widget.args.listing),
              ),

              // ── Price Details ─────────────────────────────────────
              _SectionCard(
                title: 'Price Details',
                child: Column(
                  children: [
                    _PriceRow(
                      label:
                          '${DateFormat('EEE, MMM d').format(widget.args.dateRange.start)} (${_nights} nights)',
                      value: widget.args.subtotal,
                    ),
                    SizedBox(height: 8.h),
                    _PriceRow(
                      label: 'Subtotal (${_nights} nights)',
                      value: widget.args.subtotal,
                    ),
                    SizedBox(height: 8.h),
                    _PriceRow(label: 'Service fee', value: widget.args.serviceFee),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: const Divider(),
                    ),
                    _PriceRow(
                      label: 'Total (EGP)',
                      value: widget.args.total,
                      isBold: true,
                    ),
                  ],
                ),
              ),

              // ── Footer ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: const CustomFooter(),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF7F3F0),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: AppColors.ink,
      ),
      centerTitle: true,
      title: Text(
        'Confirm and Request',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Quick',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF710E1F),
                ),
              ),
              Text(
                'In',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Easy to Book. Easy to Love.',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Our mission is to help you find the perfect home-away-from-home design experience for months, travelling and you.',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Support',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 10.h),
          _footerLink('Help Center'),
          _footerLink('Safety Information'),
          _footerLink('Cancellation Options'),
          _footerLink('Report a Concern'),
        ],
      ),
    );
  }

  Widget _footerLink(String label) => Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.ink,
            decoration: TextDecoration.underline,
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  SMALL WIDGETS
// ═══════════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            SizedBox(height: 16.h),
          ],
          child,
        ],
      ),
    );
  }
}

class _TripRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? sub;
  const _TripRow({
    required this.icon,
    required this.label,
    required this.value,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: const Color(0xFF710E1F).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 18.sp, color: const Color(0xFF710E1F)),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              if (sub != null)
                Text(
                  sub!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final int index;
  final int selected;
  final String label;
  final String sublabel;
  final VoidCallback onTap;
  const _PaymentOption({
    required this.index,
    required this.selected,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == selected;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF710E1F).withValues(alpha: 0.05)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF710E1F) : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20.r,
              height: 20.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF710E1F)
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10.r,
                        height: 10.r,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF710E1F),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final bool checked;
  final String label;
  final String sub;
  const _CheckRow({
    required this.checked,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20.r,
          height: 20.r,
          decoration: BoxDecoration(
            color: checked ? const Color(0xFF710E1F) : Colors.transparent,
            border: Border.all(
              color: checked ? const Color(0xFF710E1F) : Colors.grey.shade400,
            ),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: checked
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : null,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PolicyBadge extends StatelessWidget {
  final String label;
  const _PolicyBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _SquareCheck extends StatelessWidget {
  final bool checked;
  const _SquareCheck({required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22.r,
      height: 22.r,
      decoration: BoxDecoration(
        color: checked ? const Color(0xFF710E1F) : Colors.transparent,
        border: Border.all(
          color: checked ? const Color(0xFF710E1F) : Colors.grey.shade400,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: checked
          ? const Icon(Icons.check, size: 15, color: Colors.white)
          : null,
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;
  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14.sp : 13.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? AppColors.ink : Colors.grey.shade700,
          ),
        ),
        Text(
          'EGP ${NumberFormat('#,##0', 'en_US').format(value)}',
          style: TextStyle(
            fontSize: isBold ? 14.sp : 13.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

class _ListingThumbnail extends StatelessWidget {
  final ListingModel listing;
  const _ListingThumbnail({required this.listing});

  @override
  Widget build(BuildContext context) {
    final String? img =
        (listing.images != null && listing.images!.isNotEmpty)
            ? listing.images!.first.url
            : null;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: img != null
              ? Image.network(
                  img,
                  width: 64.w,
                  height: 64.w,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderImg(),
                )
              : _placeholderImg(),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${listing.city ?? ''}, ${listing.country ?? ''}',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                listing.title ?? '',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _placeholderImg() {
    return Container(
      width: 64,
      height: 64,
      color: Colors.grey.shade200,
      child:
          const Icon(Icons.home_outlined, size: 32, color: Colors.grey),
    );
  }
}
