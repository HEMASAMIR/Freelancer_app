import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/utils/widgets/elegant_toast.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _smsEnabled = false;
  bool _promosEnabled = false;

  void _onToggle(String title, bool value, Function(bool) updateState) {
    setState(() {
      updateState(value);
    });
    
    // Show elegant toast with smooth animation
    ElegantToast.show(
      context,
      value ? '$title enabled' : '$title disabled',
      icon: value ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCream,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        physics: const BouncingScrollPhysics(),
        children: [
          Text(
            'Notification Preferences',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: AppColors.inkBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Choose how you want to be notified about your account, trips, and promotions.',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600, height: 1.4),
          ),
          SizedBox(height: 32.h),

          // Core Notifications
          _buildSectionHeader('Core Notifications'),
          SizedBox(height: 16.h),
          _buildToggleCard(
            title: 'Push Notifications',
            subtitle: 'Receive alerts on your device for messages and booking updates.',
            icon: Icons.smartphone_rounded,
            value: _pushEnabled,
            onChanged: (val) => _onToggle('Push Notifications', val, (v) => _pushEnabled = v),
          ),
          SizedBox(height: 16.h),
          _buildToggleCard(
            title: 'Email Notifications',
            subtitle: 'Receive booking confirmations and receipts via email.',
            icon: Icons.email_outlined,
            value: _emailEnabled,
            onChanged: (val) => _onToggle('Email Notifications', val, (v) => _emailEnabled = v),
          ),
          SizedBox(height: 16.h),
          _buildToggleCard(
            title: 'SMS Notifications',
            subtitle: 'Get text messages for urgent trip updates.',
            icon: Icons.chat_bubble_outline_rounded,
            value: _smsEnabled,
            onChanged: (val) => _onToggle('SMS Notifications', val, (v) => _smsEnabled = v),
          ),
          
          SizedBox(height: 32.h),
          
          // Marketing & Promos
          _buildSectionHeader('Marketing & Promos'),
          SizedBox(height: 16.h),
          _buildToggleCard(
            title: 'Promotions & Tips',
            subtitle: 'Receive exclusive offers, travel tips, and recommendations.',
            icon: Icons.local_offer_outlined,
            value: _promosEnabled,
            onChanged: (val) => _onToggle('Promotions', val, (v) => _promosEnabled = v),
          ),
          
          SizedBox(height: 48.h),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.inkBlack,
      ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundCream,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22.sp, color: AppColors.inkBlack),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkBlack,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          CupertinoSwitch(
            value: value,
            activeColor: AppColors.inkBlack,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
