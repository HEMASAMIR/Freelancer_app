import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FiltersSection extends StatefulWidget {
  final double? minPrice;
  final double? maxPrice;
  final Set<String> selectedAmenities;
  final Function(double? min, double? max) onPriceChanged; // عدلنا الـ Callback
  final ValueChanged<String> onAmenityToggle;
  final VoidCallback onReset;

  const FiltersSection({
    super.key,
    this.minPrice,
    this.maxPrice,
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

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: widget.minPrice != null ? widget.minPrice!.round().toString() : '',
    );
    _maxController = TextEditingController(
      text: widget.maxPrice != null ? widget.maxPrice!.round().toString() : '',
    );
  }

  void _onPriceChange() {
    // لو الـ TextField فاضي بنبعت null
    final min = double.tryParse(_minController.text);
    final max = double.tryParse(_maxController.text);
    widget.onPriceChanged(min, max);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Price per night",
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _priceInput("Minimum", _minController, "0")),
              SizedBox(width: 12.w),
              Expanded(
                child: _priceInput("Maximum", _maxController, "Any price"),
              ),
            ],
          ),
          // ... (باقي كود الـ Amenities زي ما هو)
          SizedBox(height: 20.h),
          TextButton(
            onPressed: () {
              _minController.clear();
              _maxController.clear();
              widget.onReset();
            },
            child: const Text(
              "Reset all filters",
              style: TextStyle(color: Colors.red),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => _onPriceChange(),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: 'EGP ',
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: Color(0xFF8B1A1A),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
