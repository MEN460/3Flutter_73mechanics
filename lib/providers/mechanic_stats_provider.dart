import 'package:flutter/material.dart';

class MechanicStatsProvider with ChangeNotifier {
  int _pending = 0;
  int _completed = 0;
  double _rating = 0.0;

  int get pending => _pending;
  int get completed => _completed;
  double get rating => _rating;

  Future<void> loadStats() async {
    // Implementation to load stats from backend
    _pending = 12;
    _completed = 24;
    _rating = 4.8;
    notifyListeners();
  }
}
