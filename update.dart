import 'dart:io';

void main() async {
  final file = File('c:/freelancer/lib/features/host/presentation/listing_management_screen.dart');
  var content = await file.readAsString();

  // 1. Replace _AmenitiesTab and _CancellationTab
  final pattern1 = RegExp(r'class _AmenitiesTab extends StatelessWidget \{.*\}', multiLine: true, dotAll: true);
  
  final replacement1 = '''
// ============================================================
// TAB 5 – AMENITIES
// ============================================================
class _AmenitiesTab extends StatefulWidget {
  final ListingModel listing;
  const _AmenitiesTab({required this.listing});

  @override
  State<_AmenitiesTab> createState() => _AmenitiesTabState();
}

class _AmenitiesTabState extends State<_AmenitiesTab> {
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

  String _getCategoryLabel(String? categoryId) {
    const labels = {
      '1': 'Safety',
      '2': 'Comfort & Amenities',
      '3': 'Views & Surroundings',
      '4': 'Kitchen & Dining',
      '5': 'Entertainment',
    };
    return categoryId != null
        ? labels[categoryId] ?? 'Category \$categoryId'
        : 'General';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Amenities & Features',
                'Select what your place offers to guests.'),
            const SizedBox(height: 24),
            
            // ── Lifestyle Categories ──────────────────────────────
            _sectionLabel('Lifestyle Categories'),
            const SizedBox(height: 12),
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
            const SizedBox(height: 32),
            // ── Amenities ─────────────────────────────────────────
            _sectionLabel('What This Place Offers'),
            const SizedBox(height: 12),
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
                          final catLabel = _getCategoryLabel(entry.key);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.dividerGrey),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.category_outlined,
                                          size: 18, color: AppColors.greyText),
                                      const SizedBox(width: 8),
                                      Text(catLabel,
                                          style: const TextStyle(
                                              fontSize: 14,
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
                                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  );
                                }),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
            if (!_amenitiesLoading && _allAmenities.isNotEmpty) ...
              [
                const SizedBox(height: 24),
                _primaryButton(
                    label: 'Save Amenities',
                    loading: false,
                    onPressed: _saveAmenities),
              ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TAB 6 – CANCELLATION
// ============================================================
class _CancellationTab extends StatefulWidget {
  final ListingModel listing;
  const _CancellationTab({required this.listing});

  @override
  State<_CancellationTab> createState() => _CancellationTabState();
}

class _CancellationTabState extends State<_CancellationTab> {
  late String _cancellationPolicy;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _cancellationPolicy = (widget.listing.cancellationPolicy?.isNotEmpty == true)
        ? widget.listing.cancellationPolicy!.toLowerCase()
        : 'flexible';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final id = widget.listing.id?.toString() ?? '';

    final data = {
      'cancellation_policy': _cancellationPolicy,
    };

    await context.read<HostCubit>().updateListingSettings(
          listingId: id,
          data: data,
        );

    if (mounted) setState(() => _saving = false);
  }

  Widget _cancellationCard({
    required String title,
    required String desc,
    required String value,
  }) {
    final isSelected = _cancellationPolicy == value;
    return InkWell(
      onTap: () => setState(() => _cancellationPolicy = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primaryBurgundy : AppColors.inkBlack,
                      )),
                  const SizedBox(height: 6),
                  Text(desc,
                      style: const TextStyle(fontSize: 13, color: AppColors.greyText)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppColors.primaryBurgundy, size: 22),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Cancellation Policy',
                'Choose the policy that applies to guest bookings.'),
            const SizedBox(height: 24),
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
                ),
              ],
            ),
            const SizedBox(height: 32),
            _primaryButton(
                label: 'Save Policy',
                loading: _saving,
                onPressed: _save),
          ],
        ),
      ),
    );
  }
}
''';

  content = content.replaceFirst(pattern1, replacement1);

  // 2. Remove Lifestyles, Amenities and Cancellation from _SettingsTab
  final patternSettings = RegExp(r'// ============================================================\n// TAB 3 – SETTINGS\n// ============================================================.*?// ============================================================\n// TAB 4 – CONDITIONS \(Enhanced\)\n// ============================================================', multiLine: true, dotAll: true);
  
  final replacementSettings = '''// ============================================================
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
  bool _saving = false;

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
    _maxGuests = TextEditingController(text: '\${l.maxGuests ?? 1}');
    _beds = TextEditingController(text: '\${l.beds ?? 1}');
    _bedrooms = TextEditingController(text: '\${l.bedrooms ?? 1}');
    _bathrooms = TextEditingController(text: '\${l.bathrooms ?? 1}');
    _basePrice = TextEditingController(
        text: l.pricePerNight?.toStringAsFixed(0) ?? '0');
    _cleaningFee = TextEditingController(
        text: l.cleaningFee?.toStringAsFixed(0) ?? '0');
    _minNights = TextEditingController(text: '1');
    _currency = TextEditingController(text: l.currency ?? 'EGP');
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
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Listing Settings',
                'Manage your listing details and hosting setup.'),
            const SizedBox(height: 24),

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
            const SizedBox(height: 20),

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
            const SizedBox(height: 20),

            // ── Location ─────────────────────────────────────────
            _card(children: [
              _outlineField(
                  label: 'Address / Location string',
                  controller: _location),
              const SizedBox(height: 12),
              _outlineField(
                  label: 'Google Maps Link', controller: _mapsLink),
            ]),
            const SizedBox(height: 20),

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
            const SizedBox(height: 32),

            _primaryButton(
                label: 'Save Settings',
                loading: _saving,
                onPressed: _save),
          ],
        ),
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
}

// ============================================================
// TAB 4 – CONDITIONS (Enhanced)
// ============================================================
''';
  
  content = content.replaceFirst(patternSettings, replacementSettings);

  await file.writeAsString(content);
  print('Done rewriting ListingManagementScreen.');
}
