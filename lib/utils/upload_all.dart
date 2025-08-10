import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recolector_dataset/main.dart';
import '../providers/images_provider.dart';

Future<void> uploadPhoto(
  Ref ref,
  String folderId,
  String localFolderImage,
  String imageId,
) async {
  final driveService = ref.read(driveServiceProvider);

  try {
    final file = File(localFolderImage);
    await driveService.uploadFile(file, folderId);
    //obtenemos el id del archivo subido
    await file.delete();
    ref.read(imagesProvider.notifier).removeImage(imageId);
  } catch (e) {
    print('Error subiendo ${localFolderImage}: $e');
  }
}
