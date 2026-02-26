import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ToastState { success, error, warning }

class CustomToast {
  static void show(BuildContext context, String message, ToastState state) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) =>
          _ToastWidget(message: message, state: state, onDismiss: () {}),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastState state;
  final VoidCallback onDismiss;

  const _ToastWidget({
    super.key,
    required this.message,
    required this.state,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // ✅ التعديل هنا: يبدأ من أسفل الشاشة (1.5) وينتهي عند مكانه الطبيعي (0)
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        // ✅ التعديل هنا: المحاذاة لأسفل المنتصف
        alignment: Alignment.bottomCenter,
        child: Padding(
          // أضفنا Padding سفلي بسيط عشان ميبقاش لازق في حافة الشاشة
          padding: EdgeInsets.only(bottom: 40.h),
          child: SlideTransition(
            position: _offsetAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: _getBackColor(),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: _getMainColor(), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: _getMainColor().withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(
                        0,
                        -4,
                      ), // الظل بقا لفوق لأن التوست تحت
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getIcon(), color: _getMainColor(), size: 22.sp),
                    SizedBox(width: 12.w),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ... نفس الدوال (_getIcon, _getMainColor, _getBackColor) بدون تغيير
  IconData _getIcon() {
    switch (widget.state) {
      case ToastState.success:
        return Icons.check_circle_rounded;
      case ToastState.error:
        return Icons.error_rounded;
      case ToastState.warning:
        return Icons.warning_rounded;
    }
  }

  Color _getMainColor() {
    switch (widget.state) {
      case ToastState.success:
        return Colors.green;
      case ToastState.error:
        return Colors.red;
      case ToastState.warning:
        return Colors.orange;
    }
  }

  Color _getBackColor() {
    switch (widget.state) {
      case ToastState.success:
        return const Color(0xFFF1F8E9);
      case ToastState.error:
        return const Color(0xFFFFEBEE);
      case ToastState.warning:
        return const Color(0xFFFFF3E0);
    }
  }
}
