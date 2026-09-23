import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoleButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool filled;
  final EdgeInsets? padding;

  const RoleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsets effectivePadding =
        padding ?? const EdgeInsets.symmetric(vertical: 14, horizontal: 24);

    if (filled) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: effectivePadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp),
            ),
          ),
        ),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white54),
        padding: effectivePadding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp),
          ),
        ),
      ),
    );
  }
}
