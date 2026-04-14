import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
import 'package:freelancer/features/admin/admin/widget/staff_row.dart';
import 'package:freelancer/features/admin/admin/widget/table_header.dart';

class StaffDataTable extends StatelessWidget {
  final Color greyColor;
  const StaffDataTable({super.key, required this.greyColor});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String adminName = 'Platform Owner';
        String adminEmail = 'admin@example.com';
        
        if (state is AuthAdminSuccess) {
          adminName = state.user.userMetadata['full_name'] ?? state.user.email.split('@')[0];
          adminEmail = state.user.email;
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              TableHeaderRow(),
              const Divider(height: 1),
              StaffRow(
                name: adminName,
                email: adminEmail,
                role: 'PO',
                isMe: true,
                greyColor: greyColor,
                index: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}
