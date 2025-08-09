import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/home_page.dart';
import 'services/drive_service.dart';

void main() {
  runApp(const ProviderScope(child: RecolectorDatasetApp()));
}

final driveServiceProvider = Provider<DriveService>((ref) => DriveService());

final driveInitProvider = FutureProvider<void>((ref) async {
  final driveService = ref.read(driveServiceProvider);
  await driveService.init();
});

class RecolectorDatasetApp extends ConsumerWidget {
  const RecolectorDatasetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initAsync = ref.watch(driveInitProvider);

    return initAsync.when(
      data: (_) => MaterialApp(
        title: 'Recolector Dataset',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.green),
        home: const HomePage(),
      ),
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (e, st) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Error al inicializar Drive: $e')),
        ),
      ),
    );
  }
}
