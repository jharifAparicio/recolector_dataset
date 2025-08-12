import 'package:flutter/material.dart';

class Settings {
  final int delay;
  final int cantidadPhotos;
  final bool dataAugmentation;
  final int cantidadAugmentation;
  final ThemeMode themeMode;

  Settings({
    required this.delay,
    required this.cantidadPhotos,
    required this.dataAugmentation,
    required this.cantidadAugmentation,
    required this.themeMode,
  });

  Settings copyWith({
    int? delay,
    int? cantidadPhotos,
    bool? dataAugmentation,
    int? cantidadAugmentation,
    ThemeMode? themeMode,
  }) {
    return Settings(
      delay: delay ?? this.delay,
      cantidadPhotos: cantidadPhotos ?? this.cantidadPhotos,
      dataAugmentation: dataAugmentation ?? this.dataAugmentation,
      cantidadAugmentation: cantidadAugmentation ?? this.cantidadAugmentation,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'delay': delay,
      'cantidadPhotos': cantidadPhotos,
      'dataAugmentation': dataAugmentation,
      'cantidadAugmentation': cantidadAugmentation,
      'themeMode': themeMode.index, // Guardamos como índice
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      delay: map['delay'] ?? 350,
      cantidadPhotos: map['cantidadPhotos'] ?? 10,
      dataAugmentation: map['dataAugmentation'] ?? false,
      cantidadAugmentation: map['cantidadAugmentation'] ?? 0,
      themeMode: ThemeMode.values[map['themeMode'] ?? 0],
    );
  }

  factory Settings.initial() {
    return Settings(
      delay: 350,
      cantidadPhotos: 10,
      dataAugmentation: false,
      cantidadAugmentation: 0,
      themeMode: ThemeMode.light,
    );
  }
}
