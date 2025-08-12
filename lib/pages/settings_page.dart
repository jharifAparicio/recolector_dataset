import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
// import '../models/settings.dart';

class SettingsPage extends ConsumerWidget {
  // const SettingsPage({Key? key}) : super(key: key); // modo antiguo
  const SettingsPage({super.key}); // modo moderno

  Widget _numberField({
    required String label,
    required String initialValue,
    required bool enabled,
    required void Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      enabled: enabled,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text("Ajustes Dataset")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ListTile(
              title: const Text("Tema"),
              trailing: IconButton(
                icon: Icon(
                  settings.themeMode == ThemeMode.dark
                      ? Icons
                            .wb_sunny // sol
                      : Icons.nightlight_round, // luna
                ),
                onPressed: () {
                  final newMode = settings.themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                  notifier.updateSettings(
                    settings.copyWith(themeMode: newMode),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _numberField(
              label: "Delay (ms)",
              initialValue: settings.delay.toString(),
              enabled: true,
              onChanged: (val) {
                final valor = int.tryParse(val) ?? settings.delay;
                notifier.updateSettings(settings.copyWith(delay: valor));
              },
            ),
            const SizedBox(height: 16),
            _numberField(
              label: "Cantidad de fotos",
              initialValue: settings.cantidadPhotos.toString(),
              enabled: true,
              onChanged: (val) {
                final v = int.tryParse(val) ?? settings.cantidadPhotos;
                notifier.updateSettings(settings.copyWith(cantidadPhotos: v));
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("Data Augmentation"),
              value: settings.dataAugmentation,
              onChanged: (val) {
                notifier.updateSettings(
                  settings.copyWith(
                    dataAugmentation: val,
                    cantidadAugmentation: val
                        ? settings.cantidadAugmentation
                        : 0,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _numberField(
              label: "Cantidad de imágenes aumentadas",
              initialValue: settings.cantidadAugmentation.toString(),
              enabled: settings.dataAugmentation,
              onChanged: (val) {
                final v = int.tryParse(val) ?? settings.cantidadAugmentation;
                notifier.updateSettings(
                  settings.copyWith(cantidadAugmentation: v),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
