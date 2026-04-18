import 'package:flutter/material.dart';
import 'package:freelancer/core/constant/constant.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final String initials;
  final String memberSince;
  final bool isIdentityVerified;

  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    required this.initials,
    required this.memberSince,
    this.isIdentityVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFF3EFE9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B7E6D),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.sub.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isIdentityVerified ? Colors.green : AppColors.dividerGrey,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    color: isIdentityVerified
                        ? Colors.green.withValues(alpha: 0.08)
                        : Colors.transparent,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isIdentityVerified
                            ? Icons.verified_user_outlined
                            : Icons.shield_outlined,
                        size: 14,
                        color: isIdentityVerified ? Colors.green.shade700 : AppColors.sub,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isIdentityVerified ? 'Verified' : 'Not verified',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isIdentityVerified ? Colors.green.shade700 : AppColors.sub,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 16,
                color: AppColors.sub,
              ),
              const SizedBox(height: 4),
              const Text(
                'Member since',
                style: TextStyle(fontSize: 11, color: AppColors.sub),
              ),
              Text(
                memberSince,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
