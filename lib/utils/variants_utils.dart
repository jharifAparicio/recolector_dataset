import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

Future<File> generateOneVariantSync(File photo) async {
  // final originalBytes = await File(photoPath).readAsBytes();
  final originalBytes = await photo.readAsBytes();
  img.Image? original = img.decodeImage(originalBytes);

  if (original == null) {
    throw Exception('No se pudo leer la imagen: ${photo.path}');
  }

  var variant = original;

  // Lista de efectos posibles como funciones anónimas
  final effects = [
    () => variant = _blurImage(variant, 1 + Random().nextDouble() * (5 - 1)),
    () => variant = _zoomImage(
      variant,
      0.7 + Random().nextDouble() * (1.3 - 0.7),
    ),
    () => variant = _rotateAndCrop(variant, -20 + Random().nextDouble() * 40),
    () => variant = _applyRandomFlip(variant),
  ];

  // Mezclar la lista
  effects.shuffle();

  // Elegir entre 2 y 3 efectos aleatorios
  int effectsToApply = 2 + Random().nextInt(2); // 2 o 3
  for (int i = 0; i < effectsToApply; i++) {
    effects[i](); // aplicar efecto
  }

  final tempDir = await getTemporaryDirectory();
  //final variantFile = File('$dir/${uuid.v4()}.jpg');
  final variantFile = File('${tempDir.path}/${uuid.v4()}.jpg');
  // Guardar la imagen modificada
  await variantFile.writeAsBytes(img.encodeJpg(variant));

  return variantFile;
}

img.Image _adjustBrightness(img.Image src, double factor) {
  // factor entre 0.9 y 1.1
  int value = (factor * 100).clamp(0, 100).toInt();
  return img.adjustColor(src, brightness: value);
}

img.Image _blurImage(img.Image src, double radius) {
  int r = radius.round().clamp(1, 5); // mínimo 1, máximo 5
  return img.gaussianBlur(src, radius: r);
}

img.Image _zoomImage(img.Image src, double scale) {
  int newWidth = (src.width * scale).round().clamp(1, src.width);
  int newHeight = (src.height * scale).round().clamp(1, src.height);
  int x = ((src.width - newWidth) / 2).round();
  int y = ((src.height - newHeight) / 2).round();
  return img.copyCrop(src, x: x, y: y, width: newWidth, height: newHeight);
}

img.Image _rotateAndCrop(img.Image src, double angleDegrees) {
  // Rotar la imagen
  img.Image rotated = img.copyRotate(src, angle: angleDegrees);

  // Calcular factor de recorte para evitar bordes negros
  double radians = angleDegrees * pi / 180;
  int w = src.width;
  int h = src.height;
  double cosA = cos(radians).abs();
  double sinA = sin(radians).abs();

  int cropWidth = (w * cosA - h * sinA).abs().round();
  int cropHeight = (h * cosA - w * sinA).abs().round();

  // Asegurar que el tamaño mínimo sea al menos 1
  cropWidth = cropWidth.clamp(1, rotated.width);
  cropHeight = cropHeight.clamp(1, rotated.height);

  int x = ((rotated.width - cropWidth) / 2).round();
  int y = ((rotated.height - cropHeight) / 2).round();

  return img.copyCrop(
    rotated,
    x: x,
    y: y,
    width: cropWidth,
    height: cropHeight,
  );
}

img.Image _applyRandomFlip(img.Image src) {
  final rand = Random();
  int choice = rand.nextInt(3); // 0 = nada, 1 = horizontal, 2 = vertical

  switch (choice) {
    case 1:
      return img.flipHorizontal(src);
    case 2:
      return img.flipVertical(src);
    default:
      return src; // sin cambios
  }
}
