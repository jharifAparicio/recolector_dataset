import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/home_page.dart';
import 'services/drive_service.dart';

final driveServiceProvider = Provider<DriveService>((ref) {
  final service = DriveService();
  // No hacemos init() aquí porque es async, mejor lo hacemos en initState del widget principal
  return service;
});

void main() {
  runApp(const ProviderScope(child: RecolectorDatasetApp()));
}

class RecolectorDatasetApp extends ConsumerStatefulWidget {
  const RecolectorDatasetApp({super.key});

  @override
  ConsumerState<RecolectorDatasetApp> createState() =>
      _RecolectorDatasetAppState();
}

class _RecolectorDatasetAppState extends ConsumerState<RecolectorDatasetApp> {
  @override
  void initState() {
    super.initState();
    _initDrive();
  }

  Future<void> _initDrive() async {
    final driveService = ref.read(driveServiceProvider);
    await driveService.init(); // aquí inicializas y haces login
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recolector Dataset',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomePage(),
    );
  }
}
