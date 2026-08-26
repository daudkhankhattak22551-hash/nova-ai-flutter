import 'package:flutter/material.dart';

class AppController extends ChangeNotifier {

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;


  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _isLoading = false;
  bool get isLoading => _isLoading;


  void changeTab(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }


  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }


  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }
}
