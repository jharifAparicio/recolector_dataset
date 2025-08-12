import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

const uuid = Uuid();

String generateOneVariantSync(String photoPath) {
  final original = img.decodeImage(File(photoPath).readAsBytesSync())!;
  var variant = original;

  // Lista de efectos posibles (funciones anónimas que modifican variant)
  final List<Function> effects = [
    () {
      // Ajustar brillo entre 70 y 130 (como factor 0.7 a 1.3)
      variant = _adjustBrightness(
        variant,
        (Random().nextDouble() * (130 - 70)) + 70,
      );
    },
    () {
      // Añadir borrosidad ligera (blur radius entre 0.5 y 1.5)
      variant = _blurImage(variant, 0.5 + Random().nextDouble());
    },
    () {
      // Ajustar saturación entre 70 y 130 (como factor 0.7 a 1.3)
      variant = _adjustSaturation(
        variant,
        (Random().nextDouble() * (110 - 70)) + 70,
      );
    },
  ];
  // Mezclamos la lista y tomamos máximo 2 efectos
  effects.shuffle();
  final int effectsCount = Random().nextInt(3); // 0, 1 o 2 efectos
  for (int i = 0; i < effectsCount; i++) {
    effects[i]();
  }

  final dir = Directory(photoPath).parent.path;
  final variantFile = File('$dir/${uuid.v4()}.jpg');
  variantFile.writeAsBytesSync(img.encodeJpg(variant));

  return variantFile.path;
}

img.Image _adjustBrightness(img.Image src, double value) {
  // value esperado entre 0 y 200 (dividido por 100 da factor 0.0 a 2.0)
  return img.adjustColor(src, brightness: value / 100);
}

// aplicamios saturacion
img.Image _adjustSaturation(img.Image src, double value) {
  // value esperado entre 0 y 200 (dividido por 100 da factor 0.0 a 2.0)
  return img.adjustColor(src, saturation: value / 100);
}

img.Image _blurImage(img.Image src, double radius) {
  // Aplica un blur gaussiano con radio (suave)
  return img.gaussianBlur(src, radius: radius.round());
}
