import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/images.dart';
import '../providers/images_provider.dart';
import 'imagen_utils.dart';

Future<void> takeBurstPhotos({
  required CameraController controller,
  required WidgetRef ref,
  required String folderID,
  required int maxPhotos,
  required String datasetFolder,
  required void Function(int photosTaken) onProgress,
}) async {
  final uuid = Uuid();
  int photosTaken = 0;

  final dir = await getExternalStorageDirectory(); //
  final folderPath = '${dir!.path}/dataset/$folderID';
  final folder = Directory(folderPath);

  if (!await folder.exists()) {
    await folder.create(recursive: true);
  }

  for (int i = 0; i < maxPhotos; i++) {
    try {
      final fileName = '${uuid.v4()}.png';
      final filePath = '$folderPath/$fileName';

      final file = await controller.takePicture();
      final tempFile = await File(file.path).copy(filePath);
      final optimizedFile = await resizeAndCompressImage(tempFile);

      if (tempFile.path != optimizedFile.path) {
        await tempFile.delete();
      }

      final nuevaImagen = Images(
        id: uuid.v4(),
        localFolder: optimizedFile.path,
        cloudFoler: folderID,
      );
      ref.read(imagesProvider.notifier).addImage(nuevaImagen);

      photosTaken = i + 1;
      onProgress(photosTaken);

      await Future.delayed(
        const Duration(milliseconds: 450),
      ); // intervalo fijo, puedes parametrizar
    } catch (e) {
      print('Error capturando foto $i: $e');
    }
  }
}
