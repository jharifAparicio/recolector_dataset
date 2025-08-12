import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier()
    : super(
        Settings(
          delay: 500,
          cantidadPhotos: 10,
          dataAugmentation: false,
          cantidadAugmentation: 5,
          themeMode: ThemeMode.light, // Modo claro por defecto
        ),
      ) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = Settings(
      delay: prefs.getInt('delay') ?? state.delay,
      cantidadPhotos: prefs.getInt('cantidadPhotos') ?? state.cantidadPhotos,
      dataAugmentation:
          prefs.getBool('dataAugmentation') ?? state.dataAugmentation,
      cantidadAugmentation:
          prefs.getInt('cantidadAugmentation') ?? state.cantidadAugmentation,
      themeMode: ThemeMode.values[prefs.getInt('themeMode') ?? 0],
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('delay', state.delay);
    await prefs.setInt('cantidadPhotos', state.cantidadPhotos);
    await prefs.setBool('dataAugmentation', state.dataAugmentation);
    await prefs.setInt('cantidadAugmentation', state.cantidadAugmentation);
    await prefs.setInt('themeMode', state.themeMode.index);
  }

  Future<void> updateSettings(Settings newSettings) async {
    state = newSettings;
    await _save();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((
  ref,
) {
  return SettingsNotifier();
});
