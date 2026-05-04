import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const _key = 'isDark';
  Box? _box;
  bool _isDark = true;

  bool      get isDark    => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> init() async {
    _box    = await Hive.openBox('settings');
    _isDark = _box!.get(_key, defaultValue: true);
    notifyListeners();
  }

  Future<void> toggle() async {
    _isDark = !_isDark;
    await _box!.put(_key, _isDark);
    notifyListeners();
  }
}