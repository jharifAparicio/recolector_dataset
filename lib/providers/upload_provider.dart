import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recolector_dataset/models/images.dart';
import 'package:recolector_dataset/providers/images_provider.dart';
import 'package:recolector_dataset/utils/imagen_utils.dart';
import 'package:uuid/uuid.dart';
import '../utils/upload_all.dart';
import 'package:image/image.dart' as img;
import 'dart:math';

// Estado para manejar la subida
class UploadState {
  final bool isUploading;
  final double progress;
  final int total;
  final int uploaded;

  UploadState({
    this.isUploading = false,
    this.progress = 0.0,
    this.total = 0,
    this.uploaded = 0,
  });

  UploadState copyWith({
    bool? isUploading,
    double? progress,
    int? total,
    int? uploaded,
  }) {
    return UploadState(
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
      total: total ?? this.total,
      uploaded: uploaded ?? this.uploaded,
    );
  }
}

const uuid = Uuid();

class UploadNotifier extends StateNotifier<UploadState> {
  UploadNotifier(this.ref) : super(UploadState()) {
    // Escuchar cambios en la lista global de imágenes
    _subscription = ref.listen<List<Images>>(imagesProvider, (previous, next) {
      _onImagesChanged();
    });
  }

  final Ref ref;
  bool _isUploading = false;
  late final ProviderSubscription<List<Images>> _subscription;

  Future<void> _onImagesChanged() async {
    if (_isUploading) return;

    final images = ref.read(imagesProvider);
    if (images.isNotEmpty) {
      await uploadPhotos();
    }
  }

  static String _generateOneVariantSync(String photoPath) {
    final original = img.decodeImage(File(photoPath).readAsBytesSync())!;
    // Rotar la imagen entre -5 y 5 grados
    var variant = img.copyRotate(
      original,
      angle: Random().nextDouble() * 10 - 5,
    );
    // 2️⃣ Inclinación ligera (-0.025 a +0.025 en X y Y)
    variant = _shearImage(
      variant,
      Random().nextDouble() * 0.05 - 0.03,
      Random().nextDouble() * 0.05 - 0.03,
    );
    // extraemos el path de la carpeta que lo contiene
    final dir = Directory(photoPath).parent.path;
    final variantFile = File('$dir/${uuid.v4()}.jpg');
    variantFile.writeAsBytesSync(img.encodeJpg(variant));

    return variantFile.path;
  }

  static img.Image _shearImage(img.Image image, double shearX, double shearY) {
    final w = image.width;
    final h = image.height;
    final newImg = img.Image(width: w, height: h);

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final nx = (x + shearX * y).round();
        final ny = (y + shearY * x).round();
        if (nx >= 0 && nx < w && ny >= 0 && ny < h) {
          newImg.setPixel(nx, ny, image.getPixel(x, y));
        }
      }
    }
    return newImg;
  }

  Future<void> uploadPhotos() async {
    if (_isUploading) return;
    _isUploading = true;

    final images = ref.read(imagesProvider);
    final photos = images.map((img) => File(img.localFolder)).toList();
    final photoIds = images.map((img) => img.id).toList();

    state = state.copyWith(
      isUploading: true,
      total: photos.length,
      uploaded: 0,
      progress: 0.0,
    );

    int progreso = 0;
    // creamos la variable de la cantidad de imagenes por subir
    int count = photos.length * 3; // 3 variantes + la original

    for (int i = 0; i < photos.length; i++) {
      final photo = photos[i];
      try {
        // geneneramos unas 3 variantes de la foto
        for (int v = 0; v < 3; v++) {
          final variantPhotoPath = await compute(
            _generateOneVariantSync,
            photo.path,
          );
          final variantPhoto = File(variantPhotoPath);
          // optimiza la imagen antes de subirla
          final optimizedVariant = await resizeAndCompressImage(variantPhoto);
          // subimos la variante
          await uploadPhoto(
            ref,
            images.first.cloudFoler,
            optimizedVariant.path,
            variantPhoto.path.split('/').last,
          );
          variantPhoto.deleteSync();
          progreso++;
          state = state.copyWith(
            uploaded: progreso,
            progress: (progreso) / count,
          );
          // print de la variante subida
          print('Subida variante: ${optimizedVariant.path}');
        }
        // subimos la foto original
        await uploadPhoto(
          ref,
          images.first.cloudFoler,
          photo.path,
          photoIds[i],
        );
        progreso++;
        // Eliminar la imagen del estado global después de subirla
        ref.read(imagesProvider.notifier).removeImage(photoIds[i]);
        print('Subida variante: ${photo.path.split("/").last}');

        state = state.copyWith(
          uploaded: progreso,
          progress: (progreso) / count,
        );
      } catch (e) {
        print('Error subiendo ${photo.path}: $e');
      }
    }

    _isUploading = false;
    state = state.copyWith(isUploading: false);
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

final uploadProvider = StateNotifierProvider<UploadNotifier, UploadState>((
  ref,
) {
  return UploadNotifier(ref);
});
