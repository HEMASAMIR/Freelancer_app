import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/features/admin/logic/host_listings_cubit.dart';
import 'package:freelancer/features/admin/logic/host_listings_state.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_state.dart';
import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';
import 'package:freelancer/features/host/logic/cubit/host_cubit.dart';
import 'package:freelancer/features/host/presentation/listing_management_screen.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_form_cubit.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_cubit.dart';
import 'package:freelancer/features/listing_wizard/presentation/view/listing_wizard_screen.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';
import 'package:freelancer/features/search/presentation/view/search_details.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:freelancer/core/utils/widgets/custom_app_bar.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';
import 'package:freelancer/core/utils/widgets/listings_sort_header.dart';

class HostListingsView extends StatefulWidget {
  final Function(ListingModel) onShowDetails;
  const HostListingsView({super.key, required this.onShowDetails});

  @override
  State<HostListingsView> createState() => _HostListingsViewState();
}

class _HostListingsViewState extends State<HostListingsView> {
  String _selectedSort = 'Newest first';
  final List<String> _sortOptions = [
    'Newest first',
    'Oldest first',
    'Price: High to Low',
    'Price: Low to High',
  ];

  final TextEditingController _searchController = TextEditingController();
  List<ListingModel> _allListings = [];
  List<ListingModel> _filteredListings = [];

  @override
  void initState() {
    super.initState();
    _fetchListings();
  }

  void _fetchListings() {
    if (!mounted) return;
    final authState = context.read<AuthCubit>().state;
    String? userId;
    if (authState is AuthAdminSuccess) {
      userId = authState.user.id;
    } else if (authState is AuthSuccess) {
      userId = authState.user.id;
    }
    if (userId != null) {
      context.read<HostListingsCubit>().getHostListings(
        userId,
        sortOption: _selectedSort,
      );
    }
  }

  void _filterListings(String query) {
    if (!mounted) return;
    setState(() {
      _filteredListings = _allListings.where((listing) {
        final title = (listing.title ?? '').toLowerCase();
        final code = (listing.listingCode ?? '').toLowerCase();
        final location = (listing.location ?? '').toLowerCase();
        return title.contains(query.toLowerCase()) ||
            code.contains(query.toLowerCase()) ||
            location.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _openListingWizard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<ListingWizardCubit>()),
            BlocProvider(create: (_) => sl<ListingFormCubit>()),
          ],
          child: const ListingWizardScreen(),
        ),
      ),
    ).then((_) {
      if (mounted) _fetchListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: const CustomAppBar(),
      drawer: const SideDrawer(),
      body: BlocListener<HostListingsCubit, HostListingsState>(
        listener: (context, state) {
          if (state is HostListingsLoaded) {
            if (!mounted) return;
            setState(() {
              // ✅ المزامنة النهائية:
              // لو العقار ممسوح من الويب (is_published = false) هيختفي فوراً من الموبايل هنا
              // لو لسه بيظهر 21، راجع قاعدة البيانات هتلاقي الـ 12 التانيين is_published بتاعتهم لسه true
              _allListings = state.listings.where((l) => l.isPublished == true).toList();
              _filteredListings = _allListings;
            });
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            _fetchListings();
          },
          color: AppColors.primaryBurgundy,
          child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Greeting Banner (Dynamic — بياخد اسم اليوزر) ─────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 8.h),
                child: Builder(
                  builder: (context) {
                    // ✅ بنجيب اسم المستخدم من الـ AuthState
                    final authState = context.watch<AuthCubit>().state;
                    String userName = '';
                    if (authState is AuthSuccess) {
                      userName = authState.user.userMetadata['full_name'] ?? 
                                 authState.user.userMetadata['name'] ?? 
                                 authState.user.email.split('@').first;
                    } else if (authState is AuthAdminSuccess) {
                      userName = authState.user.userMetadata['full_name'] ?? 
                                 authState.user.userMetadata['name'] ?? 
                                 authState.user.email.split('@').first;
                    }

                    // ✅ تحية حسب الوقت
                    final hour = DateTime.now().hour;
                    String greeting;
                    IconData greetingIcon;
                    if (hour < 12) {
                      greeting = 'Good Morning';
                      greetingIcon = Icons.wb_sunny_rounded;
                    } else if (hour < 17) {
                      greeting = 'Good Afternoon';
                      greetingIcon = Icons.wb_cloudy_rounded;
                    } else {
                      greeting = 'Good Evening';
                      greetingIcon = Icons.nightlight_round;
                    }

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryBurgundy, AppColors.primaryBurgundy.withOpacity(0.75)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBurgundy.withOpacity(0.25),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              greetingIcon,
                              color: Colors.white,
                              size: 26.sp,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName.isNotEmpty
                                      ? 'Hey, $userName! 👋'
                                      : '$greeting! ✨',
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  userName.isNotEmpty
                                      ? '$greeting! Have a great day.'
                                      : 'Welcome back! Have a great day.',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Header ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 16.h,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.dividerGrey.withOpacity(0.5),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.ink,
                          size: 18,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Your listings',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Search & Filter ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage and monitor your properties activity.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.greyText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildSearchBar()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListingsSortHeader(
                      totalListings: _filteredListings.length,
                      selectedSort: _selectedSort,
                      sortOptions: _sortOptions,
                      onSortChanged: (newValue) {
                        if (newValue != null) {
                          setState(() => _selectedSort = newValue);
                          _fetchListings();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Listings ────────────────────────────────────────────
            BlocBuilder<HostListingsCubit, HostListingsState>(
              builder: (context, state) {
                if (state is HostListingsLoading) {
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, _) => _buildShimmerItem(),
                        childCount: 3,
                      ),
                    ),
                  );
                }

                if (state is HostListingsError) {
                  return SliverToBoxAdapter(
                    child: _buildErrorState(state.message),
                  );
                }

                if (_filteredListings.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final listing = _filteredListings[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _HostListingCard(
                          listing: listing,
                          onViewDetails: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(value: sl<AuthCubit>()),
                                  ],
                                  child: SearchDetails(listing: listing),
                                ),
                              ),
                            );
                          },
                          onManage: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => sl<HostCubit>(),
                                child: ListingManagementScreen(
                                  listing: listing,
                                ),
                              ),
                            ),
                          ),
                          onRefresh: _fetchListings,
                        ),
                      );
                    }, childCount: _filteredListings.length),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
            const SliverToBoxAdapter(child: CustomFooter()),
          ],
        ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openListingWizard,
        backgroundColor: AppColors.primaryBurgundy,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        label: const Text(
          'Add listing',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.dividerGrey.withOpacity(0.5)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterListings,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Search by title, ID...',
          hintStyle: TextStyle(
            color: AppColors.greyText.withOpacity(0.6),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.greyText,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }



  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Shimmer.fromColors(
        baseColor: Colors.white,
        highlightColor: AppColors.backgroundCream,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
              color: AppColors.primaryBurgundy.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.home_work_outlined,
              size: 80,
              color: AppColors.primaryBurgundy,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Ready to Host?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create your first listing to start earning and connecting with travelers.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.greyText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _openListingWizard,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBurgundy,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Create Listing',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String msg) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.greyText),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: _fetchListings,
            child: const Text(
              'Try Again',
              style: TextStyle(
                color: AppColors.primaryBurgundy,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HOST LISTING CARD — ✅ FIX: مفيش fixed height، الكارد بيكبر تلقائياً
// ══════════════════════════════════════════════════════════════════════════════
class _HostListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onViewDetails;
  final VoidCallback onManage;
  final VoidCallback onRefresh;

  const _HostListingCard({
    required this.listing,
    required this.onViewDetails,
    required this.onManage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    String imageUrl = (listing.images != null && listing.images!.isNotEmpty)
        ? listing.images!.first.url ?? 'URL_IS_NULL'
        : 'NO_IMAGES_IN_LIST';

    // ✅ إصلاح الصورة: لو الرابط نسبي (جاي من Supabase Storage مباشرة) نكمله بالمسار الصحيح
    if (imageUrl != 'NO_IMAGES_IN_LIST' && imageUrl != 'URL_IS_NULL') {
      if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
        if (imageUrl.startsWith('/')) {
          imageUrl = '${SupabaseKeys.supabaseUrl}$imageUrl';
        } else {
          imageUrl =
              '${SupabaseKeys.supabaseUrl}/storage/v1/object/public/$imageUrl';
        }
      }
    } else {
      imageUrl = ''; // Empty string ensures Image.network is not called
    }

    // استبدال أي backslashes عشان الروابط تشتغل بدون مشاكل
    final encodedUrl = imageUrl.isNotEmpty
        ? Uri.encodeFull(imageUrl.replaceAll('\\', '/'))
        : '';

    final isPublished = listing.isPublished ?? false;
    final location = listing.displayLocation ?? 'Location not set';
    final price = listing.pricePerNight;
    final listingCode = listing.listingCode ?? 'N/A';
    final dateStr = listing.createdAt != null
        ? 'Listed ${DateFormat('MMM d, yyyy').format(listing.createdAt!)}'
        : 'Date not set';

    return Container(
      // ✅ FIX: شيلنا height الثابتة وخلينا الكارد يكبر حسب المحتوى
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // ✅ FIX
        children: [
          // ── الصورة ──────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: SizedBox(
              width: 110.w,
              height: 110.w, // ✅ مربع ثابت للصورة بس
              child: encodedUrl.isNotEmpty
                  ? Image.network(
                      encodedUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, ___) => _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
          ),
          SizedBox(width: 12.w),

          // ── المحتوى ─────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان + Options
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        (listing.title != null &&
                                listing.title!.trim().isNotEmpty)
                            ? listing.title!
                            : 'Unnamed listing',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _buildOptionsButton(context),
                  ],
                ),
                SizedBox(height: 6.h),

                // الـ Badges في سطر واحد
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: [
                    _buildCopyBadge(context, listingCode),
                    _buildBadge(
                      isPublished ? 'Published' : 'Pending Approval',
                      isPublished
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFFF7ED),
                      textColor: isPublished
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),

                // الموقع
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 12.sp,
                      color: AppColors.ink.withOpacity(0.5),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          color: AppColors.ink.withOpacity(0.6),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // السعر والتاريخ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // ✅ إصلاح الـ Overflow: حطينا التاريخ في Expanded عشان ميخبطش في السعر
                    Expanded(
                      child: Text(
                        dateStr,
                        style: TextStyle(
                          color: AppColors.sub,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: price != null
                                ? NumberFormat('#,###').format(price)
                                : '—',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryBurgundy,
                            ),
                          ),
                          TextSpan(
                            text: '\nEGP/night',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.right,
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

  Widget _buildCopyBadge(BuildContext context, String code) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        _showTopToast(context);
      },
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: AppColors.bgColor,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.dividerGrey.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Code: $code',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.copy_rounded, size: 12.sp, color: AppColors.ink.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }

  void _showTopToast(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 24.w,
        right: 24.w,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -50 * (1 - value)),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.primaryBurgundy,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 12.w),
                  Text(
                    'Code copied to clipboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  Widget _buildBadge(
    String label,
    Color bgColor, {
    Color textColor = AppColors.ink,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      constraints: BoxConstraints(
        maxWidth: 180.w,
      ), // ✅ منع overflow لو النص طويل
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.dividerGrey.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis, // ✅ يقص الكلام لو طويل
      ),
    );
  }

  Widget _buildOptionsButton(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'manage') onManage();
        if (value == 'view') onViewDetails();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.dividerGrey),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Options',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.ink,
              size: 16.sp,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'manage',
          child: _MenuItemRow(icon: Icons.edit_outlined, label: 'Manage'),
        ),
        PopupMenuItem(
          value: 'view',
          child: _MenuItemRow(icon: Icons.visibility_outlined, label: 'View'),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.bgColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home_work_outlined, color: AppColors.sub, size: 32),
          ],
        ),
      ),
    );
  }
}

class _MenuItemRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MenuItemRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.ink),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}
