import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recolector_dataset/main.dart';
import '../providers/images_provider.dart';

Future<void> uploadPhoto(
  Ref ref,
  String folderId,
  String localFolderImage,
  String imageId,
  void Function(String)? onMessage,
) async {
  final driveService = ref.read(driveServiceProvider);
  final file = File(localFolderImage);

  try {
    await driveService.uploadFile(file, folderId);
    await file.delete();
    ref.read(imagesProvider.notifier).removeImage(imageId);
  } catch (e) {
    onMessage?.call('Error subiendo $localFolderImage: $e');

    if (e.toString().contains('401')) {
      onMessage?.call('Token expirado, reintentando...');
      await driveService.init();
      await uploadPhoto(ref, folderId, localFolderImage, imageId, onMessage);
    }
  }
}
