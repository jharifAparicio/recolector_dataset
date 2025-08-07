import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recolector_dataset/main.dart';
// import '../services/drive_service.dart';

Future<void> uploadAllPhotos(
  WidgetRef ref,
  List<File> photos,
  String folderId, // ahora es el ID directo de la carpeta destino
  void Function(double) onProgress, // callback
) async {
  final driveService = ref.read(driveServiceProvider);

  int total = photos.length;
  int uploaded = 0;

  for (final photo in photos) {
    try {
      await driveService.uploadFile(photo, folderId);
      uploaded++;
      onProgress(uploaded / total);

      // Eliminar foto local después de subir
      await photo.delete();
    } catch (e) {
      print('Error subiendo ${photo.path}: $e');
    }
  }
}
