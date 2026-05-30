import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'storage_service.dart';

class ThemeService with ChangeNotifier {
  final StorageService _storageService;
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeService(this._storageService) {
    _load();
  }

  ThemeMode get themeMode => _themeMode;

  String get selectedTheme {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  void _load() {
    final stored = _storageService.getString('theme_mode') ?? 'Dark';
    final loaded = _modeFromLabel(stored);
    if (loaded != _themeMode) {
      _themeMode = loaded;
      // Schedule notification after the widget tree is built
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> setTheme(String label) async {
    final newMode = _modeFromLabel(label);
    if (_themeMode == newMode) return;
    _themeMode = newMode;
    await _storageService.saveString('theme_mode', label);
    notifyListeners();
  }

  ThemeMode _modeFromLabel(String label) {
    switch (label) {
      case 'Light':
        return ThemeMode.light;
      case 'System Default':
        return ThemeMode.system;
      case 'Dark':
      default:
        return ThemeMode.dark;
    }
  }
}
