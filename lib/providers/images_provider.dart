import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/images.dart';

final imagesProvider = StateNotifierProvider<ImagesNotify, List<Images>>((ref) {
  return ImagesNotify();
});

class ImagesNotify extends StateNotifier<List<Images>> {
  ImagesNotify() : super([]);

  void addImage(Images image) {
    state = [...state, image];
  }

  void removeImage(String id) {
    state = state.where((image) => image.id != id).toList();
  }

  void updateImage(Images updatedImage) {
    state = state.map((image) {
      return image.id == updatedImage.id ? updatedImage : image;
    }).toList();
  }

  List<Images> getImagesByFolder(String folderID) {
    return state.where((image) => image.cloudFoler == folderID).toList();
  }
}
