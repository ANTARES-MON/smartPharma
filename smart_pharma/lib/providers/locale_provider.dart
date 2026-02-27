import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  static const _storage = FlutterSecureStorage();
  static const _localeKey = 'app_locale';

  Future<void> _loadSavedLocale() async {
    try {
      final savedLocale = await _storage.read(key: _localeKey);
      if (savedLocale != null && savedLocale.isNotEmpty) {
        state = Locale(savedLocale);
      }
    } catch (e) {
      debugPrint("Error loading saved locale: $e");
    }
  }

  Future<void> setLocale(String languageCode) async {
    try {
      state = Locale(languageCode);
      await _storage.write(key: _localeKey, value: languageCode);
    } catch (e) {
      debugPrint("Error setting locale: $e");
    }
  }

  String get currentLanguageCode => state.languageCode;

  bool get isRTL => state.languageCode == 'ar';
}
