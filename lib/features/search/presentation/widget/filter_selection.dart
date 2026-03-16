import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FiltersSection extends StatefulWidget {
  final double minPrice;
  final double maxPrice;
  final Set<String> selectedAmenities;
  final ValueChanged<RangeValues> onPriceChanged;
  final ValueChanged<String> onAmenityToggle;
  final VoidCallback onReset;

  const FiltersSection({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.selectedAmenities,
    required this.onPriceChanged,
    required this.onAmenityToggle,
    required this.onReset,
  });

  @override
  State<FiltersSection> createState() => _FiltersSectionState();
}

class _FiltersSectionState extends State<FiltersSection> {
  late TextEditingController _minController;
  late TextEditingController _maxController;

  static const _amenities = [
    {'label': 'Air Conditioning', 'icon': Icons.ac_unit},
    {'label': 'Beach Access', 'icon': Icons.beach_access},
    {'label': 'Full Kitchen', 'icon': Icons.kitchen},
    {'label': 'Wifi', 'icon': Icons.wifi},
    {'label': 'Pool', 'icon': Icons.pool},
    {'label': 'Parking', 'icon': Icons.local_parking},
  ];

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: widget.minPrice > 0 ? widget.minPrice.round().toString() : '',
    );
    _maxController = TextEditingController(
      text: widget.maxPrice < 99999 ? widget.maxPrice.round().toString() : '',
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _onPriceChange() {
    final min = double.tryParse(_minController.text) ?? 0;
    final max = double.tryParse(_maxController.text) ?? 99999;
    widget.onPriceChanged(RangeValues(min, max));
  }

  bool get _hasFilters =>
      widget.selectedAmenities.isNotEmpty ||
      widget.minPrice > 0 ||
      widget.maxPrice < 99999;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('filters'),
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.tune, size: 18.r, color: Colors.black87),
              SizedBox(width: 8.w),
              Text(
                "Price per night",
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Price inputs
          Row(
            children: [
              Expanded(child: _priceInput("Minimum", _minController, "No min")),
              SizedBox(width: 12.w),
              Expanded(child: _priceInput("Maximum", _maxController, "No max")),
            ],
          ),

          SizedBox(height: 24.h),

          Text(
            "Amenities",
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),

          // Amenity chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _amenities.map((a) {
              final label = a['label'] as String;
              final icon = a['icon'] as IconData;
              final isSelected = widget.selectedAmenities.contains(label);
              return GestureDetector(
                onTap: () => widget.onAmenityToggle(label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF8B1A1A).withOpacity(0.08)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF8B1A1A)
                          : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 14.r,
                        color: isSelected
                            ? const Color(0xFF8B1A1A)
                            : Colors.grey[600],
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF8B1A1A)
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          // Reset
          if (_hasFilters)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: GestureDetector(
                onTap: () {
                  _minController.clear();
                  _maxController.clear();
                  widget.onReset();
                },
                child: Text(
                  "Reset filters",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.red,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _priceInput(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    final hasValue = controller.text.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            border: Border.all(
              color: hasValue ? const Color(0xFF8B1A1A) : Colors.grey.shade300,
              width: hasValue ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Text(
                'EGP',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                  onChanged: (_) => _onPriceChange(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
