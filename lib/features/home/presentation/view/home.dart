// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:freelancer/core/utils/widgets/custom_app_bar.dart';
// import 'package:freelancer/features/home/presentation/widget/best_offers_banner.dart';
// import 'package:freelancer/features/home/presentation/widget/custom_card.dart';
// import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';
// import 'package:freelancer/features/home/presentation/widget/custom_her_widget.dart';
// import 'package:freelancer/features/home/presentation/widget/home_screen_body.dart';
// import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F6F2),
//       drawer: const SideDrawer(),
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(80.h), // متوافق مع طول الأب بار الجديد
//         child: const CustomAppBar(),
//       ),
//       body: const HomescreenBody(),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/utils/widgets/custom_app_bar.dart';
import 'package:freelancer/features/home/presentation/widget/home_screen_body.dart';
import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      drawer: const SideDrawer(), // اللوجيك كله بقى جوه هنا عند زرار الـ Host
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.h),
        child: const CustomAppBar(),
      ),
      body: const HomescreenBody(),
    );
  }
}