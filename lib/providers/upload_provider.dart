import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recolector_dataset/models/images.dart';
import 'package:recolector_dataset/providers/images_provider.dart';
import 'package:recolector_dataset/providers/settings_provider.dart';
import 'package:recolector_dataset/utils/imagen_utils.dart';
import 'package:uuid/uuid.dart';
import '../utils/upload_all.dart';
import '../utils/variants_utils.dart';

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
  UploadNotifier(this.ref) : super(UploadState());

  final Ref ref;
  bool _isUploading = false;
  late final ProviderSubscription<List<Images>> _subscription;

  // Activa la escucha para seguir subiendo cuando lleguen nuevas imágenes
  void enableContinueOnNewImages() {
    _subscription = ref.listen<List<Images>>(imagesProvider, (previous, next) {
      if (_isUploading && next.isNotEmpty) {
        uploadPhotos();
      } else if (_isUploading && next.isEmpty) {
        _subscription.close();
        // print('No quedan fotos. Deteniendo subida continua.');
      }
    });
  }

  Future<void> startUpload() async {
    if (_isUploading) return;

    final images = ref.read(imagesProvider);
    if (images.isNotEmpty) {
      // Opcional: activar escucha para continuar subida
      enableContinueOnNewImages();

      await uploadPhotos();
    }
  }

  Future<void> uploadPhotos() async {
    if (_isUploading) return;
    _isUploading = true;

    final images = ref.read(imagesProvider);
    final settings = ref.read(settingsProvider);

    final photos = images.map((img) => File(img.localFolder)).toList();
    final photoIds = images.map((img) => img.id).toList();

    final int variantsCount = settings.dataAugmentation
        ? settings.cantidadAugmentation
        : 0;
    final int count = photos.length * (variantsCount + 1);

    state = state.copyWith(
      isUploading: true,
      total: count,
      uploaded: 0,
      progress: 0.0,
    );

    int progreso = 0;

    for (int i = 0; i < photos.length; i++) {
      final photo = photos[i];
      try {
        if (settings.dataAugmentation) {
          for (int v = 0; v < variantsCount; v++) {
            final variantPhotoPath = await generateOneVariantSync(photo);
            final variantPhoto = File(variantPhotoPath.path);
            final optimizedVariant = await resizeAndCompressImage(variantPhoto);
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
            print('Subida variante: ${optimizedVariant.path}');
          }
        }

        // Subir original siempre
        await uploadPhoto(
          ref,
          images.first.cloudFoler,
          photo.path,
          photoIds[i],
        );

        progreso++;
        state = state.copyWith(
          uploaded: progreso,
          progress: (progreso) / count,
        );

        // Remover la imagen del estado
        ref.read(imagesProvider.notifier).removeImage(photoIds[i]);
        print('Subida original: ${photo.path.split("/").last}');
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
