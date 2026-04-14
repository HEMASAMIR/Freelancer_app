import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─────────────────────────────────────────────
//  AccountScreen
// ─────────────────────────────────────────────
class AccountScreen extends StatefulWidget {
  final int initialTabIndex;

  const AccountScreen({super.key, this.initialTabIndex = 0});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // TODO: استبدل دول ببيانات من AccountCubit لما تكون جاهز
  final String _userName = 'joeeeeeeeee';
  final String _userEmail = 'joe@gmail.com';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ✅ FIX
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Manage your profile and settings.',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 24.h),
                    _UserCard(userName: _userName, userEmail: _userEmail),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  tabs: const [
                    Tab(text: 'Personal Info'),
                    Tab(text: 'Verification'),
                    Tab(text: 'Settings'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: const [
              PersonalInfoTab(),
              VerificationTab(),
              SettingsTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _UserCard  (widget مستقل بدل function)
// ─────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final String userName;
  final String userEmail;

  const _UserCard({required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 30.r, child: Text(userName[0].toUpperCase())),
          SizedBox(width: 16.w),
          Column(
            mainAxisSize: MainAxisSize.min, // ✅ FIX — كانت هنا المشكلة
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4.h),
              Text(
                userEmail,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PersonalInfoTab
// ─────────────────────────────────────────────
class PersonalInfoTab extends StatefulWidget {
  const PersonalInfoTab({super.key});

  @override
  State<PersonalInfoTab> createState() => _PersonalInfoTabState();
}

class _PersonalInfoTabState extends State<PersonalInfoTab> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // TODO: استبدل ببيانات من AccountCubit
  final String _userEmail = 'joe@gmail.com';

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      children: [
        _InfoSection(
          title: 'Contact Info',
          subtitle: 'Update your data',
          child: Column(
            mainAxisSize: MainAxisSize.min, // ✅ FIX
            children: [
              _InputField(controller: _phoneController, hint: 'Phone'),
              SizedBox(height: 16.h),
              _InputField(controller: _addressController, hint: 'Address'),
              SizedBox(height: 16.h),
              _InputField(controller: _bioController, hint: 'Bio'),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _InfoSection(
          title: 'Email',
          subtitle: 'Your email',
          child: Text(_userEmail, style: TextStyle(fontSize: 14.sp)),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  VerificationTab
// ─────────────────────────────────────────────
class VerificationTab extends StatelessWidget {
  const VerificationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: 200.h),
        Center(
          child: Text(
            'Verification',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  SettingsTab
// ─────────────────────────────────────────────
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: 200.h),
        Center(
          child: Text(
            'Settings',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  _InfoSection  (reusable card section)
// ─────────────────────────────────────────────
class _InfoSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _InfoSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ FIX
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey),
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _InputField  (reusable)
// ─────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _InputField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _TabBarDelegate
// ─────────────────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFFFAF9F6), child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar; // ✅ FIX — كان دايماً false
  }
}
