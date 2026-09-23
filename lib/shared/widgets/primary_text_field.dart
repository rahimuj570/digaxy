import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrimaryTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const PrimaryTextField({
    super.key,
    this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  State<PrimaryTextField> createState() => _PrimaryTextFieldState();
}

class _PrimaryTextFieldState extends State<PrimaryTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Color(0xFF092832);
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14.sp,
        color: Color(0xFF092832),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: widget.hint,
        hintStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
          color: Color(0xFF092832),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        prefixIcon: widget.prefixIcon != null
            ? IconTheme(
                data: IconThemeData(color: iconColor),
                child: widget.prefixIcon!,
              )
            : null,
        suffixIcon: widget.obscure
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: iconColor,
                ),
              )
            : (widget.suffixIcon != null
                  ? IconTheme(
                      data: IconThemeData(color: iconColor),
                      child: widget.suffixIcon!,
                    )
                  : null),
      ),
    );
  }
}
