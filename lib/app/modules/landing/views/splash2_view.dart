import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class Splash2View extends StatefulWidget {
  const Splash2View({super.key});

  @override
  State<Splash2View> createState() => _Splash2ViewState();
}

class _Splash2ViewState extends State<Splash2View>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            // Apply scale and fade animations to the SVG logo
            return Opacity(
              opacity: _textFade.value,
              child: Transform.scale(scale: _logoScale.value, child: child),
            );
          },
          child: SvgPicture.asset(
            'assets/icons/splash_logo_all.svg',
            width: 166.w,
            height: 196.h,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
