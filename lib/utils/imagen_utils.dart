import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

Future<File> resizeAndCompressImage(
  File imageFile, {
  int targetWidth = 600,
  int targetHeight = 800,
  int quality = 70,
}) async {
  final imageBytes = await imageFile.readAsBytes();
  final originalImage = img.decodeImage(imageBytes);
  if (originalImage == null) {
    throw Exception("No se pudo decodificar la imagen");
  }

  // Solo redimensionar si es más grande que el objetivo
  img.Image resizedImage = originalImage;
  if (originalImage.width > targetWidth ||
      originalImage.height > targetHeight ||
      originalImage.width < targetWidth ||
      originalImage.height < targetHeight) {
    resizedImage = img.copyResize(
      originalImage,
      width: targetWidth,
      height: targetHeight,
    );
  }

  // Codificar como JPEG optimizado
  final compressedBytes = img.encodeJpg(resizedImage, quality: quality);

  // Guardar en carpeta temporal
  final tempDir = await getTemporaryDirectory();
  final newFile = File('${tempDir.path}/${const Uuid().v4()}.jpg');

  await newFile.writeAsBytes(compressedBytes);
  return newFile;
}
