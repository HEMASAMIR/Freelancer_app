import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/account/logic/cubit/account_cubit.dart';
import 'package:freelancer/features/account/logic/cubit/account_state.dart';
import 'package:freelancer/features/account/data/models/account_models.dart';

class AccountScreen extends StatefulWidget {
  final int initialTabIndex;
  final Function(String)? onViewChanged;

  const AccountScreen({super.key, this.initialTabIndex = 0, this.onViewChanged});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _loadProfile();
  }

  void _loadProfile() {
    final authState = context.read<AuthCubit>().state;
    String? userId;
    if (authState is AuthSuccess) {
      userId = authState.user.id;
    } else if (authState is AuthAdminSuccess) {
      userId = authState.user.id;
    }
    if (userId != null) {
      context.read<AccountCubit>().getProfile(userId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            String userName = 'Guest User';
            String userEmail = 'guest@example.com';
            bool isAdmin = false;
            
            if (state is AuthSuccess) {
              userName = state.user.userMetadata['full_name'] ??
                  state.user.email.split('@')[0];
              userEmail = state.user.email;
            } else if (state is AuthAdminSuccess) {
              userName = state.user.userMetadata['full_name'] ??
                  state.user.email.split('@')[0];
              userEmail = state.user.email;
              isAdmin = true;
            }

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Manage your profile, verification, and account\nsettings',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700, height: 1.4),
                        ),
                        SizedBox(height: 24.h),
                        _UserCard(userName: userName, userEmail: userEmail),
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
                      tabAlignment: TabAlignment.start,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey.shade600,
                      labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                      unselectedLabelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal),
                      indicatorColor: Colors.black,
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.label,
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
                children: [
                  PersonalInfoTab(userName: userName, userEmail: userEmail),
                  VerificationTab(isAdmin: isAdmin),
                  SettingsTab(onViewChanged: widget.onViewChanged),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _UserCard
// ─────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final String userName;
  final String userEmail;

  const _UserCard({required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        bool isVerified = false;
        if (authState is AuthAdminSuccess) {
          isVerified = true; // Admins are always considered verified
        } else if (authState is AuthSuccess) {
          isVerified = authState.user.userMetadata['is_identity_verified'] == true;
        }

        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundColor: AppColors.backgroundCream,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 18.sp),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isVerified
                            ? Colors.green.withValues(alpha: 0.12)
                            : const Color(0xFFEFE6FF),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVerified ? Icons.verified_user : Icons.shield_outlined,
                            size: 14.sp,
                            color: isVerified ? Colors.green.shade700 : const Color(0xFF7A00F0),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            isVerified ? 'Identity Verified' : 'Identity not verified',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: isVerified ? Colors.green.shade700 : const Color(0xFF7A00F0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  PersonalInfoTab
// ─────────────────────────────────────────────
class PersonalInfoTab extends StatefulWidget {
  final String userName;
  final String userEmail;

  const PersonalInfoTab({super.key, required this.userName, required this.userEmail});

  @override
  State<PersonalInfoTab> createState() => _PersonalInfoTabState();
}

class _PersonalInfoTabState extends State<PersonalInfoTab> {
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onSave() {
    final state = context.read<AuthCubit>().state;
    String? userId;
    if (state is AuthSuccess) {
      userId = state.user.id;
    } else if (state is AuthAdminSuccess) {
      userId = state.user.id;
    }

    if (userId != null) {
      context.read<AccountCubit>().updateProfile(userId, {
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'bio': _bioController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCubit, AccountState>(
      listener: (context, state) {
        if (state is AccountProfileLoaded) {
          _phoneController.text = state.profile.phone ?? '';
          _addressController.text = state.profile.address ?? '';
          _bioController.text = state.profile.bio ?? '';
        }
        if (state is AccountSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
        }
        if (state is AccountError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<AccountCubit, AccountState>(
        builder: (context, state) {
          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            children: [
              // Contact Information Card
              _buildSectionCard(
                title: 'Contact Information',
                subtitle: 'Update your phone number and address',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phone Number', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8.r),
                        color: const Color(0xFFFCFAF8),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Row(
                              children: [
                                Text('🇪🇬', style: TextStyle(fontSize: 20.sp)),
                                SizedBox(width: 8.w),
                                Text('+20', style: TextStyle(fontSize: 14.sp)),
                                SizedBox(width: 4.w),
                                Icon(Icons.keyboard_arrow_down, size: 16.sp, color: Colors.grey.shade600),
                              ],
                            ),
                          ),
                          Container(height: 24.h, width: 1, color: Colors.grey.shade300),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                                hintText: 'Enter phone',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Select your country flag from the dropdown',
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                    ),
                    SizedBox(height: 20.h),
                    Text('Address', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: 'Your address',
                        prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFFFCFAF8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text('Bio', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _bioController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Experienced with a passion for hospitality...',
                        filled: true,
                        fillColor: const Color(0xFFFCFAF8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state is AccountLoading ? null : _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.ink,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: state is AccountLoading
                          ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Legal Name Card
              _buildSectionCard(
                title: 'Legal Name',
                subtitle: 'Contact support to change your name',
                child: Container(
                   width: double.infinity,
                   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                   decoration: BoxDecoration(
                     color: Colors.grey.shade50,
                     border: Border.all(color: Colors.grey.shade200),
                     borderRadius: BorderRadius.circular(8.r),
                   ),
                   child: Text(
                     widget.userName,
                     style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                   ),
                ),
              ),
              SizedBox(height: 16.h),
              // Email Address Card
              _buildSectionCard(
                title: 'Email Address',
                subtitle: 'Contact support to change your email',
                child: Container(
                   width: double.infinity,
                   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                   decoration: BoxDecoration(
                     color: Colors.grey.shade50,
                     border: Border.all(color: Colors.grey.shade200),
                     borderRadius: BorderRadius.circular(8.r),
                   ),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(
                         widget.userEmail,
                         style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                       ),
                       Container(
                         padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                         decoration: BoxDecoration(
                           color: Colors.green.shade50,
                           borderRadius: BorderRadius.circular(16.r),
                         ),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Icon(Icons.check_circle, size: 14.sp, color: Colors.green.shade600),
                             SizedBox(width: 4.w),
                             Text('Verified', style: TextStyle(fontSize: 11.sp, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                           ],
                         ),
                       )
                     ],
                   ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String subtitle, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, size: 18.sp, color: Colors.grey.shade700),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
             subtitle,
             style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
          ),
          SizedBox(height: 20.h),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  VerificationTab
// ─────────────────────────────────────────────
class VerificationTab extends StatelessWidget {
  final bool isAdmin;
  const VerificationTab({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) {
      return ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
            child: Column(
              children: [
                Icon(Icons.security, size: 48.sp, color: Colors.grey.shade400),
                SizedBox(height: 16.h),
                Text("Identity Verification", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Text("Please verify your identity to access full features.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
              ],
            ),
          )
        ],
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      children: [
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                     padding: EdgeInsets.all(10.w),
                     decoration: BoxDecoration(color: const Color(0xFFF9F5FF), shape: BoxShape.circle),
                     child: Icon(Icons.shield_outlined, color: const Color(0xFF7A00F0), size: 24.sp),
                   ),
                   SizedBox(width: 16.w),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Wrap(
                           crossAxisAlignment: WrapCrossAlignment.center,
                           spacing: 8.w,
                           runSpacing: 4.h,
                           children: [
                             Text('Internal Account', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                             Container(
                               padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                               decoration: BoxDecoration(color: const Color(0xFF7A00F0), borderRadius: BorderRadius.circular(12.r)),
                               child: Text('Current Verification Method', style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                             )
                           ],
                         ),
                         SizedBox(height: 8.h),
                         Text(
                           'As a staff member, your account is automatically verified for all actions.',
                           style: TextStyle(fontSize: 13.sp, color: const Color(0xFF7A00F0), height: 1.4),
                         ),
                       ],
                     ),
                   )
                ],
              ),
              SizedBox(height: 24.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                     padding: EdgeInsets.all(10.w),
                     decoration: BoxDecoration(color: const Color(0xFFF9F5FF), shape: BoxShape.circle),
                     child: Icon(Icons.check_circle_outline, color: const Color(0xFF7A00F0), size: 24.sp),
                   ),
                   SizedBox(width: 16.w),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text('Verification Bypassed', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                         SizedBox(height: 8.h),
                         Text(
                           'You can list properties and make bookings without identity verification.',
                           style: TextStyle(fontSize: 13.sp, color: const Color(0xFF7A00F0), height: 1.4),
                         ),
                       ],
                     ),
                   )
                ],
              )
            ],
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
  final Function(String)? onViewChanged;
  const SettingsTab({super.key, this.onViewChanged});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      children: [
        _buildSettingCard(Icons.lock_outline, 'Login & Security', 'Update your password and secure your account', onTap: () {
          Navigator.pushNamed(context, AppRoutes.security);
        }),
        SizedBox(height: 16.h),
        _buildSettingCard(Icons.payment_outlined, 'Payments & Payouts', 'Review payments, payouts, and taxes', onTap: () {
          if (onViewChanged != null) {
            onViewChanged!('Earnings & Balance');
          }
        }),
        SizedBox(height: 16.h),
        _buildSettingCard(Icons.notifications_none_outlined, 'Notifications', 'Choose notification preferences'),
      ],
    );
  }

  Widget _buildSettingCard(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24.sp, color: Colors.grey.shade700),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                SizedBox(height: 4.h),
                Text(subtitle, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500)),
              ],
            ),
          )
        ],
      ),
    ));
  }
}

// ─────────────────────────────────────────────
//  _TabBarDelegate
// ─────────────────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 8.h;

  @override
  double get maxExtent => tabBar.preferredSize.height + 8.h;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.backgroundCream, 
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          tabBar,
          Container(height: 1, color: Colors.grey.shade300), // Subtle base line for tabbar like airbnb
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar;
  }
}
