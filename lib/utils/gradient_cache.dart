import 'package:flutter/material.dart';

class GradientCache {
  static LinearGradient get dashboardCardGradient => LinearGradient(
    colors: [Colors.grey[850]!, Colors.grey[900]!], // Dark gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
