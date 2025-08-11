import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recolector_dataset/models/images.dart';
import 'package:recolector_dataset/providers/images_provider.dart';
import '../utils/upload_all.dart';

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

    for (int i = 0; i < photos.length; i++) {
      final photo = photos[i];
      try {
        await uploadPhoto(
          ref,
          images.first.cloudFoler,
          photo.path,
          photoIds[i],
        );
        // Eliminar la imagen del estado global después de subirla
        ref.read(imagesProvider.notifier).removeImage(photoIds[i]);

        state = state.copyWith(
          uploaded: i + 1,
          progress: (i + 1) / photos.length,
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
