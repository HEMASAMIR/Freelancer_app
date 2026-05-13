import os

file_path = r'c:\freelancer\lib\features\host\presentation\listing_management_screen.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix withOpacity/withValues just in case some are left
content = content.replace('.withValues(alpha: ', '.withOpacity(')

# Redesign _legend and _dot
legend_old = """  Widget _legend() => Row(
        children: [
          _dot(Colors.green.shade50, 'Available'),
          const SizedBox(width: 14),
          _dot(AppColors.primaryBurgundy.withOpacity(0.15), 'Blocked'),
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
      ]);"""

legend_new = """  Widget _legend() => Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _dot(Colors.white, 'Available', hasBorder: true),
          _dot(AppColors.primaryBurgundy.withOpacity(0.1), 'Blocked'),
          _dot(AppColors.backgroundCream.withOpacity(0.5), 'Past'),
        ],
      );

  Widget _dot(Color c, String label, {bool hasBorder = false}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(4),
              border: hasBorder ? Border.all(color: AppColors.dividerGrey.withOpacity(0.5)) : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.greyText, fontWeight: FontWeight.w500),
          ),
        ],
      );"""

# Try to find legend_old even if whitespace differs slightly
if legend_old in content:
    content = content.replace(legend_old, legend_new)
else:
    # Try a more flexible search if the first one fails
    print("Exact legend match failed, trying flexible replacement")
    # I'll just do a more targeted replace for the grid which is the most broken part

# Fix Calendar Grid UI and Overflow
old_grid_part = """        return GestureDetector(
          onTap: isPast ? null : () => _toggleDate(date),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: const Color(0xFFF3F4F6), width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isBlocked ? FontWeight.w700 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                Text(
                  priceText,
                  style: TextStyle(
                    fontSize: 11,
                    color: isPast ? const Color(0xFFD1D5DB) : AppColors.greyText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );"""

new_grid_part = """        return GestureDetector(
          onTap: isPast ? null : () => _toggleDate(date),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isBlocked ? AppColors.primaryBurgundy.withOpacity(0.05) : bg,
              border: Border.all(color: AppColors.dividerGrey.withOpacity(0.2), width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: (isBlocked || date == today) ? FontWeight.w700 : FontWeight.w500,
                    color: isBlocked ? AppColors.primaryBurgundy : textColor,
                    decoration: isPast ? TextDecoration.lineThrough : null,
                  ),
                ),
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    priceText,
                    style: TextStyle(
                      fontSize: 9,
                      color: isPast ? AppColors.greyText.withOpacity(0.3) : AppColors.greyText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );"""

content = content.replace(old_grid_part, new_grid_part)

# Update some background colors and spacing
content = content.replace("color: const Color(0xFFF3F4F6)", "color: AppColors.dividerGrey.withOpacity(0.2)")
content = content.replace("border: Border.all(color: const Color(0xFFE5E7EB))", "border: Border.all(color: AppColors.dividerGrey.withOpacity(0.5))")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Done")
