import 'package:flutter/material.dart';

class AppAnimations {
  AppAnimations._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;

  static Tween<Offset> slideInUp({double offset = 0.3}) {
    return Tween<Offset>(
      begin: Offset(0, offset),
      end: Offset.zero,
    );
  }

  static Tween<double> scaleIn({double begin = 0.9}) {
    return Tween<double>(begin: begin, end: 1);
  }
}
