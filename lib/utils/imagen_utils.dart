import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageUtils {
  /// Redimensiona una imagen a un ancho objetivo (proporcional)
  /// y guarda en PNG para reducir peso.
  static Future<File> resizeAndCompressImage(
    File imageFile, {
    int targetWidth = 600, // usa 600x800 que pediste antes
    int targetHeight = 800,
  }) async {
    final imageBytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(imageBytes)!;

    final resizedImage = img.copyResize(
      originalImage,
      width: targetWidth,
      height: targetHeight,
    );

    // Codificar como PNG
    final resizedBytes = img.encodePng(resizedImage);

    final tempDir = await getTemporaryDirectory();
    final newFile = File('${tempDir.path}/${const Uuid().v4()}.png');

    await newFile.writeAsBytes(resizedBytes);
    return newFile;
  }
}
