import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/features/host/data/models/host_models.dart';
import 'package:freelancer/features/host/logic/cubit/host_cubit.dart';
import 'package:freelancer/features/host/logic/cubit/host_state.dart';
import 'package:freelancer/features/listing_wizard/data/models/wizard_models.dart';
import 'package:freelancer/features/listing_wizard/data/repos/listing_wizard_repo.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';
import 'package:intl/intl.dart';

// ============================================================
// MAIN SCREEN
// ============================================================
class ListingManagementScreen extends StatefulWidget {
  final ListingModel listing;
  const ListingManagementScreen({super.key, required this.listing});

  @override
  State<ListingManagementScreen> createState() =>
      _ListingManagementScreenState();
}

class _ListingManagementScreenState extends State<ListingManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late bool _isPublished;
  bool _togglingStatus = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _isPublished = widget.listing.isPublished ?? true;
    context.read<HostCubit>().getListingAvailability(
          widget.listing.id?.toString() ?? '',
        );
  }

  Future<void> _togglePublishStatus() async {
    setState(() => _togglingStatus = true);
    final id = widget.listing.id?.toString() ?? '';
    final newStatus = !_isPublished;
    
    // Using updateListingSettings to toggle the is_published field
    await context.read<HostCubit>().updateListingSettings(
      listingId: id,
      data: {'is_published': newStatus},
    );
    
    if (mounted) {
      setState(() {
        _isPublished = newStatus;
        _togglingStatus = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isPublished ? 'Listing Published ✓' : 'Listing Deactivated'),
          backgroundColor: _isPublished ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HostCubit, HostState>(
      listener: (context, state) {
        if (state is HostSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state is HostError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundCream,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.inkBlack, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.listing.title ?? 'Your Listing',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkBlack),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.listing.listingCode != null)
                Text(
                  widget.listing.listingCode!,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.greyText),
                ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.open_in_new,
                    size: 14, color: AppColors.primaryBurgundy),
                label: const Text('View listing',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.primaryBurgundy)),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryBurgundy,
            unselectedLabelColor: AppColors.greyText,
            indicatorColor: AppColors.primaryBurgundy,
            indicatorWeight: 2,
            isScrollable: false,
            labelStyle: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Availability'),
              Tab(text: 'Pricing'),
              Tab(text: 'Settings'),
              Tab(text: 'Conditions'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _AvailabilityTab(listing: widget.listing),
            _PricingTab(listing: widget.listing),
            _SettingsTab(listing: widget.listing),
            _ConditionsTab(listing: widget.listing),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.dividerGrey)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isPublished ? 'Published Listing' : 'Under Review / Private',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _isPublished ? Colors.green : AppColors.primaryRed,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text('No reviews yet',
                        style: TextStyle(fontSize: 12, color: AppColors.greyText)),
                  ],
                ),
                ElevatedButton(
                  onPressed: _togglingStatus ? null : _togglePublishStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isPublished ? Colors.red.shade50 : AppColors.primaryBurgundy,
                    foregroundColor:
                        _isPublished ? Colors.red : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: _togglingStatus
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _isPublished ? Colors.red : Colors.white,
                          ),
                        )
                      : Text(
                          _isPublished ? 'Deactivate listing' : 'Activate listing',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TAB 1 – AVAILABILITY CALENDAR
// ============================================================
class _AvailabilityTab extends StatefulWidget {
  final ListingModel listing;
  const _AvailabilityTab({required this.listing});

  @override
  State<_AvailabilityTab> createState() => _AvailabilityTabState();
}

class _AvailabilityTabState extends State<_AvailabilityTab> {
  DateTime _focusedMonth = DateTime.now();
  final Set<DateTime> _blockedDates = {};
  bool _saving = false;

  void _toggleDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    setState(() {
      _blockedDates.contains(d) ? _blockedDates.remove(d) : _blockedDates.add(d);
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final id = widget.listing.id?.toString() ?? '';
    final data = _blockedDates
        .map((d) => {
              'listing_id': id,
              'date': DateFormat('yyyy-MM-dd').format(d),
              'is_available': false,
            })
        .toList();
    await context.read<HostCubit>().updateAvailability(data);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HostCubit, HostState>(
      listener: (context, state) {
        if (state is HostAvailabilityLoaded) {
          setState(() {
            _blockedDates
              ..clear()
              ..addAll(state.unavailableDates
                  .where((a) => a.date != null)
                  .map((a) => DateTime(a.date!.year, a.date!.month, a.date!.day)));
          });
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              'Availability Calendar',
              'Tap dates to block / unblock for bookings.',
            ),
            const SizedBox(height: 20),
            _monthNav(),
            const SizedBox(height: 8),
            _weekdayHeader(),
            const SizedBox(height: 6),
            _calendarGrid(),
            const SizedBox(height: 16),
            _legend(),
            const SizedBox(height: 24),
            _primaryButton(
              label: 'Save Availability',
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _monthNav() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() => _focusedMonth =
                DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_focusedMonth),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() => _focusedMonth =
                DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
          ),
        ],
      );

  Widget _weekdayHeader() => Row(
        children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
            .map((d) => Expanded(
                  child: Center(
                    child: Text(d,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w600)),
                  ),
                ))
            .toList(),
      );

  Widget _calendarGrid() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startOffset = firstDay.weekday % 7;
    final today = DateTime.now();

    final cells = <Widget>[
      ...List.generate(startOffset, (_) => const SizedBox()),
      ...List.generate(daysInMonth, (i) {
        final date =
            DateTime(_focusedMonth.year, _focusedMonth.month, i + 1);
        final norm = DateTime(date.year, date.month, date.day);
        final isPast =
            date.isBefore(DateTime(today.year, today.month, today.day));
        final isBlocked = _blockedDates.contains(norm);

        Color bg = Colors.green.shade50;
        Color textColor = AppColors.inkBlack;
        if (isPast) {
          bg = Colors.grey.shade100;
          textColor = Colors.grey;
        } else if (isBlocked) {
          bg = AppColors.primaryBurgundy.withValues(alpha: 0.15);
          textColor = AppColors.primaryBurgundy;
        }

        return GestureDetector(
          onTap: isPast ? null : () => _toggleDate(date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Text('${i + 1}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isBlocked ? FontWeight.w700 : FontWeight.normal,
                      color: textColor)),
            ),
          ),
        );
      }),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1.1,
      children: cells,
    );
  }

  Widget _legend() => Row(
        children: [
          _dot(Colors.green.shade50, 'Available'),
          const SizedBox(width: 14),
          _dot(AppColors.primaryBurgundy.withValues(alpha: 0.15), 'Blocked'),
          const SizedBox(width: 14),
          _dot(Colors.grey.shade100, 'Past'),
        ],
      );

  Widget _dot(Color c, String label) => Row(children: [
        Container(
            width: 14,
            height: 14,
            decoration:
                BoxDecoration(color: c, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.greyText)),
      ]);
}

// ============================================================
// TAB 2 – PRICING
// ============================================================
class _PricingTab extends StatefulWidget {
  final ListingModel listing;
  const _PricingTab({required this.listing});

  @override
  State<_PricingTab> createState() => _PricingTabState();
}

class _PricingTabState extends State<_PricingTab> {
  late TextEditingController _basePrice;
  final _adjustments = <_PriceAdj>[];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _basePrice = TextEditingController(
        text: widget.listing.pricePerNight?.toStringAsFixed(0) ?? '0');
    // Default weekend adjustment
    _adjustments.add(_PriceAdj(name: 'Weekend Rate', percentage: 10, enabled: true));
  }

  @override
  void dispose() {
    _basePrice.dispose();
    super.dispose();
  }

  Future<void> _saveBase() async {
    setState(() => _saving = true);
    final price = double.tryParse(_basePrice.text) ?? 0;
    await context.read<HostCubit>().updateListingSettings(
      listingId: widget.listing.id?.toString() ?? '',
      data: {'price_per_night': price},
    );
    if (mounted) setState(() => _saving = false);
  }

  void _showAddAdjDialog() {
    final nameCtrl = TextEditingController();
    final pctCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Price Adjustment',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField('Name (e.g. Holiday Rate)', nameCtrl),
            const SizedBox(height: 12),
            _dialogField('Percentage (%)', pctCtrl,
                type: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final pct = double.tryParse(pctCtrl.text) ?? 0;
              setState(() => _adjustments.add(
                    _PriceAdj(
                        name: nameCtrl.text,
                        percentage: pct,
                        enabled: true),
                  ));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBurgundy,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Add',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController ctrl,
      {TextInputType? type}) =>
      TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.primaryBurgundy, width: 1.5),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final base = double.tryParse(_basePrice.text) ?? 0;
    final today = DateTime.now();

    return BlocBuilder<HostCubit, HostState>(
      builder: (context, state) {
        final overrides = state is HostAvailabilityLoaded
            ? state.priceOverrides
            : <AvailabilityModel>[];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('Base Price', 'Price per night for this listing.'),
              const SizedBox(height: 16),
              _outlineField(
                label: 'Base price per night',
                controller: _basePrice,
                prefix: 'EGP ',
                type: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _primaryButton(
                  label: 'Save Base Price',
                  loading: _saving,
                  onPressed: _saveBase),
              const SizedBox(height: 28),

              _sectionHeader(
                  'Price Adjustments',
                  'Customize prices for weekends, holidays, and special dates.'),
              const SizedBox(height: 16),

              ..._adjustments.asMap().entries.map((e) {
                final adj = e.value;
                final effective = base * (1 + adj.percentage / 100);
                return _AdjCard(
                  adj: adj,
                  effective: effective,
                  onToggle: (v) =>
                      setState(() => _adjustments[e.key].enabled = v),
                  onDelete: () =>
                      setState(() => _adjustments.removeAt(e.key)),
                );
              }),

              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _showAddAdjDialog,
                icon: const Icon(Icons.add, size: 16,
                    color: AppColors.primaryBurgundy),
                label: const Text('Add Price Adjustment',
                    style: TextStyle(color: AppColors.primaryBurgundy)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryBurgundy),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),

              if (overrides.isNotEmpty) ...[
                const SizedBox(height: 28),
                _sectionHeader('Price Preview (Base: EGP ${base.toStringAsFixed(0)})',
                    'Dates with custom prices.'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    7,
                    (i) {
                      final d = today.add(Duration(days: i));
                      final override = overrides.firstWhere(
                        (o) =>
                            o.date != null &&
                            o.date!.year == d.year &&
                            o.date!.month == d.month &&
                            o.date!.day == d.day,
                        orElse: () => AvailabilityModel(),
                      );
                      final price = override.priceOverride ?? base;
                      final hasOverride = override.priceOverride != null;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: hasOverride
                              ? AppColors.primaryBurgundy.withValues(alpha: 0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: hasOverride
                                ? AppColors.primaryBurgundy
                                : AppColors.dividerGrey,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(DateFormat('EEE').format(d),
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.greyText)),
                            Text(
                              'EGP ${price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: hasOverride
                                    ? AppColors.primaryBurgundy
                                    : AppColors.inkBlack,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PriceAdj {
  String name;
  double percentage;
  bool enabled;
  _PriceAdj({required this.name, required this.percentage, required this.enabled});
}

class _AdjCard extends StatelessWidget {
  final _PriceAdj adj;
  final double effective;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _AdjCard({
    required this.adj,
    required this.effective,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerGrey),
      ),
      child: Row(
        children: [
          Switch(
            value: adj.enabled,
            onChanged: onToggle,
            activeColor: AppColors.primaryBurgundy,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(adj.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(
                  '+${adj.percentage.toStringAsFixed(0)}%  ≈  EGP ${effective.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.greyText),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TAB 3 – SETTINGS
// ============================================================
class _SettingsTab extends StatefulWidget {
  final ListingModel listing;
  const _SettingsTab({required this.listing});

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  late TextEditingController _titleEn;
  late TextEditingController _titleAr;
  late TextEditingController _descEn;
  late TextEditingController _descAr;
  late TextEditingController _location;
  late TextEditingController _mapsLink;
  late TextEditingController _maxGuests;
  late TextEditingController _beds;
  late TextEditingController _bedrooms;
  late TextEditingController _bathrooms;
  late TextEditingController _basePrice;
  late TextEditingController _cleaningFee;
  late TextEditingController _minNights;
  late TextEditingController _currency;
  String _cancellationPolicy = 'flexible';
  bool _saving = false;

  List<LifestyleCategoryModel> _allLifestyles = [];
  final Set<String> _selectedLifestyles = {};
  bool _lifestylesLoading = true;

  // Amenities
  List<AmenityModel> _allAmenities = [];
  final Set<String> _selectedAmenities = {};
  bool _amenitiesLoading = true;
  Map<String?, List<AmenityModel>> _amenitiesByCategory = {};

  @override
  void initState() {
    super.initState();
    final l = widget.listing;
    final arTitle = l.translations?['ar']?['title'];
    final arDesc = l.translations?['ar']?['description'];

    _titleEn = TextEditingController(text: l.title ?? '');
    _titleAr = TextEditingController(text: arTitle ?? '');
    _descEn = TextEditingController(text: l.description ?? '');
    _descAr = TextEditingController(text: arDesc ?? '');
    _location = TextEditingController(text: l.location ?? '');
    _mapsLink = TextEditingController(text: l.googleMapsLink ?? '');
    _maxGuests = TextEditingController(text: '${l.maxGuests ?? 1}');
    _beds = TextEditingController(text: '${l.beds ?? 1}');
    _bedrooms = TextEditingController(text: '${l.bedrooms ?? 1}');
    _bathrooms = TextEditingController(text: '${l.bathrooms ?? 1}');
    _basePrice = TextEditingController(
        text: l.pricePerNight?.toStringAsFixed(0) ?? '0');
    _cleaningFee = TextEditingController(
        text: l.cleaningFee?.toStringAsFixed(0) ?? '0');
    _minNights = TextEditingController(text: '1');
    _currency = TextEditingController(text: l.currency ?? 'EGP');
    _cancellationPolicy = (l.cancellationPolicy?.isNotEmpty == true) 
        ? l.cancellationPolicy!.toLowerCase() 
        : 'flexible';

    _loadLifestyles();
    _loadAmenities();
  }

  Future<void> _loadLifestyles() async {
    final repo = sl<ListingWizardRepository>();
    final result = await repo.getLifestyleCategories();
    result.fold(
      (_) => setState(() => _lifestylesLoading = false),
      (list) {
        setState(() {
          _allLifestyles = list;
          _lifestylesLoading = false;
          // Pre-select existing lifestyles
          if (widget.listing.lifestyles != null) {
            for (final ls in widget.listing.lifestyles!) {
              final match = list.firstWhere(
                (c) => c.name.toLowerCase() == (ls.name ?? '').toLowerCase(),
                orElse: () => LifestyleCategoryModel(id: '', name: ''),
              );
              if (match.id.isNotEmpty) _selectedLifestyles.add(match.id);
            }
          }
        });
      },
    );
  }

  Future<void> _loadAmenities() async {
    final repo = sl<ListingWizardRepository>();
    // Load all amenities
    final amenResult = await repo.getAmenities();
    amenResult.fold(
      (_) => null,
      (list) {
        _allAmenities = list;
        _amenitiesByCategory = {};
        for (final a in list) {
          (_amenitiesByCategory[a.categoryId] ??= []).add(a);
        }
      },
    );
    // Load selected for this listing
    final selResult = await repo.getListingAmenities(
        widget.listing.id?.toString() ?? '');
    selResult.fold(
      (_) => null,
      (ids) => _selectedAmenities.addAll(ids),
    );
    if (mounted) setState(() => _amenitiesLoading = false);
  }

  Future<void> _saveAmenities() async {
    final repo = sl<ListingWizardRepository>();
    final result = await repo.upsertListingAmenities(
      listingId: widget.listing.id?.toString() ?? '',
      amenityIds: _selectedAmenities.toList(),
    );
    result.fold(
      (e) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e), backgroundColor: Colors.red)),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Amenities saved ✓'),
              backgroundColor: Colors.green)),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final id = widget.listing.id?.toString() ?? '';

    final data = {
      'title': _titleEn.text,
      'description': _descEn.text,
      'location': _location.text,
      'google_maps_link': _mapsLink.text,
      'max_guests': int.tryParse(_maxGuests.text) ?? 1,
      'beds': int.tryParse(_beds.text) ?? 1,
      'bedrooms': int.tryParse(_bedrooms.text) ?? 1,
      'bathrooms': int.tryParse(_bathrooms.text) ?? 1,
      'price_per_night': double.tryParse(_basePrice.text) ?? 0,
      'cleaning_fee': double.tryParse(_cleaningFee.text) ?? 0,
      'currency': _currency.text,
      'cancellation_policy': _cancellationPolicy,
      'translations': {
        'ar': {
          'title': _titleAr.text,
          'description': _descAr.text,
        }
      },
    };

    await context.read<HostCubit>().updateListingSettings(
          listingId: id,
          data: data,
        );

    if (mounted) setState(() => _saving = false);
  }

  @override
  void dispose() {
    for (final c in [
      _titleEn, _titleAr, _descEn, _descAr, _location, _mapsLink,
      _maxGuests, _beds, _bedrooms, _bathrooms, _basePrice, _cleaningFee,
      _minNights, _currency,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Listing Settings',
              'Manage your listing details and hosting setup.'),
          const SizedBox(height: 20),

          // ── Listing Details ─────────────────────────────────
          _card(children: [
            _outlineField(
                label: 'Title (English / Admin to change)',
                controller: _titleEn),
            const SizedBox(height: 12),
            _outlineField(label: 'Title (Arabic)', controller: _titleAr),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _outlineField(
                    label: 'Bedrooms', controller: _bedrooms,
                    type: TextInputType.number),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _outlineField(
                    label: 'Bathrooms', controller: _bathrooms,
                    type: TextInputType.number),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _infoField('Country',
                    widget.listing.country ?? 'Egypt'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _infoField('State', widget.listing.state ?? '—'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _infoField('City', widget.listing.city ?? '—'),
              ),
            ]),
          ]),
          const SizedBox(height: 16),

          // ── Descriptions ─────────────────────────────────────
          _card(children: [
            _outlineField(
                label: 'Description (English)', controller: _descEn,
                maxLines: 4),
            const SizedBox(height: 12),
            _outlineField(
                label: 'Description (Arabic)',
                controller: _descAr,
                maxLines: 4),
          ]),
          const SizedBox(height: 16),

          // ── Location ─────────────────────────────────────────
          _card(children: [
            _outlineField(
                label: 'Address / Location string',
                controller: _location),
            const SizedBox(height: 12),
            _outlineField(
                label: 'Google Maps Link', controller: _mapsLink),
          ]),
          const SizedBox(height: 16),

          // ── Numbers ──────────────────────────────────────────
          _card(children: [
            Row(children: [
              Expanded(
                child: _outlineField(
                    label: 'Max Guests', controller: _maxGuests,
                    type: TextInputType.number),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _outlineField(label: 'Beds', controller: _beds,
                    type: TextInputType.number),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _outlineField(
                    label: 'Base Price per Night',
                    controller: _basePrice,
                    prefix: 'EGP ',
                    type: TextInputType.number),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _outlineField(
                    label: 'Cleaning Fee',
                    controller: _cleaningFee,
                    prefix: 'EGP ',
                    type: TextInputType.number),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _outlineField(
                    label: 'Currency', controller: _currency),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _outlineField(
                    label: 'Minimum Nights', controller: _minNights,
                    type: TextInputType.number),
              ),
            ]),
          ]),
          const SizedBox(height: 16),

          // ── Cancellation Policy ───────────────────────────────
          _sectionLabel('Cancellation Policy'),
          const SizedBox(height: 10),
          _card(
            children: [
              _cancellationCard(
                title: 'Flexible',
                desc: 'Full refund on dates 1 day before check-in.',
                value: 'flexible',
              ),
              const Divider(height: 1, color: AppColors.dividerGrey),
              _cancellationCard(
                title: 'Moderate',
                desc: 'Full refund on dates 5 days before check-in.',
                value: 'moderate',
              ),
              const Divider(height: 1, color: AppColors.dividerGrey),
              _cancellationCard(
                title: 'Limited',
                desc: 'Full refund 14 days before check-in, 50% refund 7 days before check-in.',
                value: 'limited',
              ),
              const Divider(height: 1, color: AppColors.dividerGrey),
              _cancellationCard(
                title: 'Firm',
                desc: 'Full refund on dates 30 days before check-in. 50% refund > 14 days before check-in.',
                value: 'firm',
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Lifestyle Categories ──────────────────────────────
          _sectionLabel('Lifestyle Categories'),
          const SizedBox(height: 10),
          _lifestylesLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryBurgundy, strokeWidth: 2))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allLifestyles
                      .map((ls) {
                        final sel = _selectedLifestyles.contains(ls.id);
                        return GestureDetector(
                          onTap: () => setState(() => sel
                              ? _selectedLifestyles.remove(ls.id)
                              : _selectedLifestyles.add(ls.id)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppColors.primaryBurgundy
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: sel
                                    ? AppColors.primaryBurgundy
                                    : AppColors.dividerGrey,
                              ),
                            ),
                            child: Text(
                              ls.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: sel ? Colors.white : AppColors.inkBlack,
                              ),
                            ),
                          ),
                        );
                      })
                      .toList(),
                ),
          const SizedBox(height: 24),
          // ── Amenities ─────────────────────────────────────────
          _sectionLabel('What This Place Offers'),
          const SizedBox(height: 10),
          _amenitiesLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryBurgundy, strokeWidth: 2))
              : _allAmenities.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.dividerGrey),
                      ),
                      child: const Text(
                        'No amenities available yet. They will appear here after admin setup.',
                        style: TextStyle(
                            color: AppColors.greyText, fontSize: 13),
                      ),
                    )
                  : Column(
                      children: _amenitiesByCategory.entries.map((entry) {
                        final catAmenities = entry.value;
                        // Group label: use first letter of first amenity name as category fallback
                        final catLabel = _getCategoryLabel(entry.key);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.dividerGrey),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.category_outlined,
                                        size: 16, color: AppColors.greyText),
                                    const SizedBox(width: 6),
                                    Text(catLabel,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.inkBlack)),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: AppColors.dividerGrey),
                              ...catAmenities.map((a) {
                                final sel = _selectedAmenities.contains(a.id);
                                return CheckboxListTile(
                                  value: sel,
                                  onChanged: (v) => setState(() =>
                                      v! ? _selectedAmenities.add(a.id)
                                         : _selectedAmenities.remove(a.id)),
                                  activeColor: AppColors.primaryBurgundy,
                                  title: Text(a.name,
                                      style: const TextStyle(fontSize: 14)),
                                  secondary: a.icon != null && a.icon!.isNotEmpty
                                      ? Text(a.icon!,
                                          style: const TextStyle(fontSize: 20))
                                      : const Icon(Icons.check_circle_outline,
                                          size: 20, color: AppColors.greyText),
                                  dense: true,
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0)),
                                );
                              }),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
          if (!_amenitiesLoading && _allAmenities.isNotEmpty) ...
            [
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _saveAmenities,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryBurgundy),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text('Save Amenities',
                      style: TextStyle(
                          color: AppColors.primaryBurgundy,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          const SizedBox(height: 24),
          _primaryButton(
              label: 'Save Settings',
              loading: _saving,
              onPressed: _save),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _infoField(String label, String val) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.greyText)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.dividerGrey),
            ),
            child: Text(val,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.inkBlack)),
          ),
        ],
      );

  Widget _cancellationCard({
    required String title,
    required String desc,
    required String value,
    bool isLast = false,
  }) {
    final isSelected = _cancellationPolicy == value;
    return InkWell(
      onTap: () => setState(() => _cancellationPolicy = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: isSelected ? AppColors.selectedBg : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primaryBurgundy : AppColors.inkBlack,
                      )),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: const TextStyle(fontSize: 12, color: AppColors.greyText)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppColors.primaryBurgundy, size: 20),
          ],
        ),
      ),
    );
  }

  String _getCategoryLabel(String? categoryId) {
    // Map common category IDs to display names; admin controls the actual categories in DB
    const labels = {
      '1': 'Safety',
      '2': 'Comfort & Amenities',
      '3': 'Views & Surroundings',
      '4': 'Kitchen & Dining',
      '5': 'Entertainment',
    };
    return categoryId != null
        ? labels[categoryId] ?? 'Category $categoryId'
        : 'General';
  }
}

// ============================================================
// TAB 4 – CONDITIONS (Enhanced)
// ============================================================
class _ConditionsTab extends StatefulWidget {
  final ListingModel listing;
  const _ConditionsTab({required this.listing});

  @override
  State<_ConditionsTab> createState() => _ConditionsTabState();
}

class _ConditionsTabState extends State<_ConditionsTab> {
  List<ListingConditionModel> _all = [];
  final Set<String> _selected = {};
  bool _loading = true;
  bool _submitting = false;
  bool _showAddForm = false;

  // Custom condition form controllers
  final _nameEnCtrl = TextEditingController();
  final _nameArCtrl = TextEditingController();
  final _descEnCtrl = TextEditingController();
  final _descArCtrl = TextEditingController();

  // System conditions that are always enforced
  static const _systemConditions = [
    _SysCondition('Check-in after 3 PM', 'Check-in time is after 3:00 PM.'),
    _SysCondition('Check-out before 11 AM', 'Check-out time is before 11:00 AM.'),
    _SysCondition('ID verification needed', 'Guests must ensure all 4 documents are in the space.'),
    _SysCondition('Maximum occupancy', 'This property may only host the listing max occupancy.'),
    _SysCondition('No parties or events', 'Parties, events, or large gatherings are not permitted.'),
    _SysCondition('No pets', 'Pets are not allowed in the property.'),
    _SysCondition('No smoking', 'Smoking is not allowed inside the property.'),
    _SysCondition('No unregistered guests', 'All guests only and night rights must be registered in the system.'),
    _SysCondition('Quiet hours', 'Guests must observe quiet hours from 11PM to 7AM.'),
    _SysCondition('Respect neighbors', 'Guests must be respectful and keep noise to the acceptable minimum.'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameEnCtrl.dispose();
    _nameArCtrl.dispose();
    _descEnCtrl.dispose();
    _descArCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = sl<ListingWizardRepository>();
    final result = await repo.getListingConditions();
    result.fold(
      (_) => setState(() => _loading = false),
      (c) => setState(() {
        _all = c;
        // Pre-select all by default
        _selected.addAll(c.map((x) => x.id));
        _loading = false;
      }),
    );
  }

  Future<void> _submitCustomCondition() async {
    if (_nameEnCtrl.text.isEmpty || _nameArCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in both condition names.'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _submitting = true);
    final repo = sl<ListingWizardRepository>();
    final result = await repo.submitCustomCondition(
      listingId: widget.listing.id?.toString() ?? '',
      nameEn: _nameEnCtrl.text.trim(),
      nameAr: _nameArCtrl.text.trim(),
      descEn: _descEnCtrl.text.trim().isEmpty ? null : _descEnCtrl.text.trim(),
      descAr: _descArCtrl.text.trim().isEmpty ? null : _descArCtrl.text.trim(),
    );
    result.fold(
      (e) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e), backgroundColor: Colors.red)),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Condition submitted for approval ✓'),
              backgroundColor: Colors.green),
        );
        _nameEnCtrl.clear();
        _nameArCtrl.clear();
        _descEnCtrl.clear();
        _descArCtrl.clear();
        setState(() => _showAddForm = false);
      },
    );
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(
              color: AppColors.primaryBurgundy, strokeWidth: 2.5));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'Booking Conditions',
            'Select conditions that guests must accept before booking your listing.',
          ),
          const SizedBox(height: 20),

          // ── System Conditions ─────────────────────────────────
          ..._systemConditions.map((c) {
            final apiModel = _all.firstWhere(
              (m) => m.name.toLowerCase().contains(
                    c.name.split(' ').first.toLowerCase()),
              orElse: () => ListingConditionModel(
                  id: '', name: c.name, description: c.description),
            );
            return _ConditionRow(
              name: c.name,
              description: apiModel.description ?? c.description,
              isSystem: true,
              isSelected: true,
              onChanged: null,
            );
          }),

          // ── Custom API Conditions ─────────────────────────────
          ..._all
              .where((c) => !_systemConditions
                  .any((s) => c.name.toLowerCase()
                      .contains(s.name.split(' ').first.toLowerCase())))
              .map((c) => _ConditionRow(
                    name: c.name,
                    description: c.description,
                    isSystem: false,
                    isSelected: _selected.contains(c.id),
                    onChanged: (v) => setState(() =>
                        v! ? _selected.add(c.id) : _selected.remove(c.id)),
                  )),

          const SizedBox(height: 24),

          // ── Add Custom Condition ───────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _showAddForm
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: OutlinedButton.icon(
              onPressed: () => setState(() => _showAddForm = true),
              icon: const Icon(Icons.add, size: 16,
                  color: AppColors.primaryBurgundy),
              label: const Text('Add Custom Condition',
                  style: TextStyle(color: AppColors.primaryBurgundy)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryBurgundy),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
            secondChild: _customConditionForm(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _customConditionForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryBurgundy.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pending_outlined, size: 18,
                  color: AppColors.primaryBurgundy),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('New Custom Condition',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Pending Approval',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Custom conditions are reviewed by admins. Once approved they will be visible to guests.',
            style: TextStyle(fontSize: 12, color: AppColors.greyText),
          ),
          const SizedBox(height: 16),
          _outlineField(
            label: 'Condition Name (English)',
            controller: _nameEnCtrl,
          ),
          const SizedBox(height: 10),
          _outlineField(
            label: 'Condition Name (Arabic)',
            controller: _nameArCtrl,
          ),
          const SizedBox(height: 10),
          _outlineField(
            label: 'Description (optional)',
            controller: _descEnCtrl,
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          _outlineField(
            label: 'Description (Arabic, optional)',
            controller: _descArCtrl,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitCustomCondition,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBurgundy,
                    disabledBackgroundColor: AppColors.primaryBurgundy,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Submit for Approval',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => setState(() => _showAddForm = false),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.dividerGrey),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
                child: const Text('Cancel',
                    style: TextStyle(color: AppColors.greyText)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper data class for system conditions
class _SysCondition {
  final String name;
  final String description;
  const _SysCondition(this.name, this.description);
}

class _ConditionRow extends StatelessWidget {
  final String name;
  final String? description;
  final bool isSystem;
  final bool isSelected;
  final ValueChanged<bool?>? onChanged;

  const _ConditionRow({
    required this.name,
    required this.description,
    required this.isSystem,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primaryBurgundy.withValues(alpha: 0.4) : AppColors.dividerGrey,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkBlack),
                      ),
                    ),
                    if (isSystem) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('System',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
                if (description != null && description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(description!,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.greyText)),
                  ),
              ],
            ),
          ),
          isSystem
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('System',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight: FontWeight.w600)),
                )
              : Checkbox(
                  value: isSelected,
                  onChanged: onChanged,
                  activeColor: AppColors.primaryBurgundy,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
        ],
      ),
    );
  }
}

// ============================================================
// SHARED HELPERS
// ============================================================
Widget _sectionHeader(String title, String subtitle) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.inkBlack)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: const TextStyle(fontSize: 13, color: AppColors.greyText)),
      ],
    );

Widget _sectionLabel(String label) => Text(label,
    style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.inkBlack));

Widget _card({required List<Widget> children}) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerGrey.withValues(alpha: 0.6)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );

Widget _outlineField({
  required String label,
  required TextEditingController controller,
  String? prefix,
  TextInputType? type,
  int maxLines = 1,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.dividerGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.primaryBurgundy, width: 1.5),
        ),
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.greyText),
      ),
    );

Widget _primaryButton({
  required String label,
  required bool loading,
  required VoidCallback onPressed,
}) =>
    SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBurgundy,
          disabledBackgroundColor: AppColors.primaryBurgundy,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
      ),
    );
