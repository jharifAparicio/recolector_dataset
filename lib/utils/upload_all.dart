import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recolector_dataset/main.dart';
// import '../services/drive_service.dart';

Future<void> uploadAllPhotos(
  WidgetRef ref,
  List<File> photos,
  String folderName,
) async {
  final driveService = ref.read(driveServiceProvider);

  // Obtener el ID de la carpeta en Google Drive (crear si no existe)
  final folderId =
      await driveService.getFolderIdByName(folderName) ??
      await driveService.createFolder(folderName);

  for (final photo in photos) {
    try {
      await driveService.uploadFile(photo, folderId);
      print('Foto ${photo.path} subida correctamente');
    } catch (e) {
      print('Error subiendo ${photo.path}: $e');
    }
  }
}
